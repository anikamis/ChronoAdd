import sys
import glob
import pandas as pd

trait = sys.argv[1]

glob_path = f"scores/raw_scores/*.sscore"
raw_scores = glob.glob(glob_path)

out_fn = f"scores/summed_scores/{trait}.ACAF.ALL.sscore"

sums = pd.DataFrame()
prev_len = 0

for score in raw_scores:
    print(f"starting reading {score}!")

    if sums.empty:
        sums = pd.read_csv(score, sep='\t')
        sums = sums.loc[:,~sums.columns.str.endswith("_AVG")]
        prev_len = len(sums)
    else:
        temp = pd.read_csv(score, sep='\t')
        temp = temp.loc[:,~temp.columns.str.endswith("_AVG")].drop(columns=["NMISS_ALLELE_CT", "NAMED_ALLELE_DOSAGE_SUM", "ALLELE_CT"], errors="ignore")

        sums = sums.merge(temp, on=["IID"], how='left', suffixes=["", "_temp"])

        if prev_len != len(sums):
            print(f"Error: mismatched n individuals between chromosomes for {score}!\n")
            break

        for c in sums.columns:
            if f"{c}_temp" not in sums:
                continue

            sums[c] = sums[c] + sums[c + "_temp"]

        sums = sums.loc[:,~sums.columns.str.endswith("_temp")]
        prev_len = len(sums)

    print(f"finished reading {score}!")

sums.to_csv(out_fn, sep='\t', index=False)