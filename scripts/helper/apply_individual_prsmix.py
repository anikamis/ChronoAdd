import sys
import glob
import os
import pandas as pd



def apply_prsmix(in_score_prefix, out_score_prefix, prsmix_dir, prsmix_colname):


	weight_fn = f"{prsmix_dir}/{trait}*weight_PRSmix.txt"
	weight_files = glob.glob(weight_fn)


	# read in per-indiv score file
	score_fn = f"{in_score_prefix}.sscore"
	scores = pd.read_csv(score_fn, sep='\s+')

	out_score_fn = f"{out_score_prefix}.sscore"

	prsmix_weights=dict()

	if len(weight_files) > 1:
		print(f"Warning: more than one weight file present in dir {prsmix_dir}\n")
	elif len(weight_files) == 0:
		print(f"PRSmix weight file not found\n")
		scores.to_csv(out_score_fn, sep='\t', index=False)
	else:
		# read in prsmix mixing weights file
		prsmix_weights = pd.read_csv(weight_files[0], sep='\s+').rename(columns={"c.topprs.": "prs", "ww": "weight"})

		# drop all prs with weight of 0
		prsmix_weights = prsmix_weights[prsmix_weights["weight"] != 0]

		# rename prs column to match naming convention of weights file: add "_SUM" suffix to all names
		prsmix_weights["prs"] = prsmix_weights["prs"].apply(lambda x: f"{x}_SUM")

		# convert prsmix_weights df to dict mapping prs_name to weight
		prsmix_weights = dict(zip(prsmix_weights["prs"], prsmix_weights["weight"]))


	scores[prsmix_colname] = 0

	# for each score with a non-zero prsmix weight, multiply raw score and add
	for prs, weight in prsmix_weights.items():
		if prs in scores.columns:
			scores[prsmix_colname] = scores[prsmix_colname] + (scores[prs] * weight)
			# print(f"applied {prs} to scores for group!")

	scores.to_csv(out_score_fn, sep='\t', index=False)


	print(f"finished calculating all prsmix scores from dir {prsmix_dir}!\n")


trait = sys.argv[1]


# e.g. {trait}.ACAF or {trait}.ACAF.with_all_prsmix
in_score_prefix=sys.argv[2]

# e.g. f"{trait}.ACAF.with_all_prsmix"
out_score_prefix = sys.argv[3]

# e.g. for_prsmix/by_${group_name}
prsmix_dir=sys.argv[4]

prsmix_colname=sys.argv[5]

apply_prsmix(in_score_prefix=in_score_prefix,
				out_score_prefix=out_score_prefix, 
				prsmix_dir=prsmix_dir,
				prsmix_colname=prsmix_colname)

