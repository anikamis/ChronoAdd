library(PRSmix)

args = commandArgs(trailingOnly=TRUE)


trait = args[1]
covariate_file = args[2]
score_files_list = args[3]
trait_specific_score_file = args[4]
pheno_file = args[5]
pheno_name = args[6]
isbinary = args[7]
out = args[8]
ncores = args[9]


score_files_list <- c(score_files_list)
covar_list <- c("age", "sex", paste0("PC", c(1:10)))
cat_covar_list <- c("sex")

PRSmix::combine_PRS(
    pheno_file=pheno_file,
    covariate_file=covariate_file,
    score_files_list=score_files_list,
    trait_specific_score_file=trait_specific_score_file,
    pheno_name=pheno_name,
    isbinary=isbinary,
    out=out,
    covar_list=covar_list,
    cat_covar_list=cat_covar_list,
    ncores=ncores
)