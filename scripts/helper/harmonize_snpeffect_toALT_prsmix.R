library(PRSmix)

args = commandArgs(trailingOnly=TRUE)

trait = args[1]
ref_file = args[2]
pgs_folder = args[3]
pgs_list = args[4]
out = args[5]

PRSmix::harmonize_snpeffect_toALT(
	ref_file = ref_file, 
	pgs_folder = pgs_folder,
	pgs_list = pgs_list,
	isheader = TRUE,
	out=out
)