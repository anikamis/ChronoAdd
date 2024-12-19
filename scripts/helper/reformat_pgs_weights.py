import sys
import pandas as pd
import numpy as np
import re

trait = sys.argv[1]
pgs_id = sys.argv[2]

in_weights_path = f"pgs_catalog_harmonized_weights/"
infile = f"{in_weights_path}{pgs_id}_hmPOS_GRCh38.txt"

out_weights_path = f"weights/"
outfile = f"{out_weights_path}{pgs_id}.txt"

print(f"starting {pgs_id}...")

cols_to_keep = ['effect_allele', 'effect_weight','hm_chr', 'hm_pos', 'hm_inferOtherAllele']
dtypes = [str,'float64', str, str, str]

# orig_weights = pd.read_csv(infile, sep='\t', comment="#", usecols=cols_to_keep, dtype=dict(zip(cols_to_keep, dtypes)))
orig_weights = pd.read_csv(infile, sep='\t', comment="#", dtype=dict(zip(cols_to_keep, dtypes)))

if "other_allele" not in orig_weights:
    orig_weights["other_allele"] = np.nan

# if any missing values in other_allele, fill value with hm_inferOtherAllele
orig_weights["other_allele"] = orig_weights["other_allele"].fillna(orig_weights["hm_inferOtherAllele"])

# basically just for PGS000337
if orig_weights["hm_inferOtherAllele"].isna().sum() == len(orig_weights) and "variant_description" in list(orig_weights.columns):
    variant_description = orig_weights["variant_description"]
    variant_description = [x.split(":") for x in variant_description if not pd.isna(x)]
    lens = set([len(x) for x in variant_description])

    if (set(lens) == set([4])):

        orig_weights["A1"] = orig_weights.apply(lambda x : x["other_allele"] if pd.isna(x["variant_description"]) else x["variant_description"].split(":")[-1], axis=1)
        orig_weights["A2"] = orig_weights.apply(lambda x : x["other_allele"] if pd.isna(x["variant_description"]) else x["variant_description"].split(":")[-2], axis=1)
        orig_weights["other_allele"] = orig_weights.apply(lambda x: x["A1"] if x["A2"] == x["effect_allele"] else x["A2"], axis=1)

orig_weights = orig_weights[['effect_allele', 'other_allele', 'effect_weight','hm_chr', 'hm_pos']]

# drop with hm_inferOtherAllele now that we have the info we need
# orig_weights = orig_weights.drop(columns=["hm_inferOtherAllele"])

# drop rows with any nas
orig_weights = orig_weights.dropna(axis="index", how="any")

# if several alleles
orig_weights["effect_allele"] = orig_weights.apply(lambda x : x["effect_allele"].split("/") , axis=1)
orig_weights = orig_weights.explode("effect_allele")

# if several alleles
orig_weights["other_allele"] = orig_weights.apply(lambda x : x["other_allele"].split("/") , axis=1)
orig_weights = orig_weights.explode("other_allele")

# only keep alleles ACGT
orig_weights["test"] = orig_weights.apply(lambda x: int(bool(re.match(r'^[ACGT]+$', x["effect_allele"])) and bool(re.match(r'^[ACGT]+$', x["other_allele"]))), axis=1)
orig_weights = orig_weights[orig_weights["test"] == 1]
orig_weights = orig_weights.drop(columns=["test"])


# add two versions of snp ids, chr:pos:effect:other and chr:pos:other:effect just in case
orig_weights["SNP"] = orig_weights.apply(lambda x : [f'chr{x["hm_chr"]}:{x["hm_pos"]}:{x["effect_allele"]}:{x["other_allele"]}',f'chr{x["hm_chr"]}:{x["hm_pos"]}:{x["other_allele"]}:{x["effect_allele"]}'], axis=1)
orig_weights = orig_weights.explode("SNP")


# subset down to columns we care about and rename to match convention of others
orig_weights = orig_weights[["SNP", "effect_allele", "effect_weight"]].rename(columns={"effect_allele": "A1", "effect_weight": "BETA"})
orig_weights = orig_weights.drop_duplicates("SNP", keep=False)

orig_weights.to_csv(outfile, sep='\t', index=False)

