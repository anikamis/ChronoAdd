#!/bin/bash

# get name of trait from first command-line argument
trait=$1

# location of trait directory created in step 0
trait_dir=$2

# location of all scripts, with subdirectory containing helper scripts
script_dir=$3

# prefix of plink files up til chromosome number, e.g. aou_acaf/acaf_threshold.chr
plink_file_prefix=$4

# how many scores to run at once
num_at_a_time=$5

# how many threads to use to run a single score 
num_threads=$6

# how much memory to use to run a single score
mem_per_score=$7


run_plink_scoring () {
    trait=$1
    obj_plink_file_prefix=$2

    num_at_a_time=$3
    num_threads=$4
    mem_per_score=$5

    cd $obj_trait_dir

    echo -e "starting plink2 scoring for all chromosomes for trait ${trait}! \n"

    num_cols=$( head -1 all_harmonized_weights/${trait}.all_harmonized_weights.ALL_SNPS.ALL_CHRS.txt | wc -w ) ; parallel -j $3 plink2 --threads $4 --memory $5 --bfile $obj_plink_file_prefix{} --score all_harmonized_weights/${trait}.all_harmonized_weights.ALL_SNPS.chr{}.txt cols=fid,scoresums no-mean-imputation header-read --score-col-nums 4-$num_cols --out scores/raw_scores/${trait}.ACAF.chr{} ::: {22..1} X

    echo -e "finished plink2 scoring for all chromosomes for trait ${trait}! \n"

    cd $cwd

}

sum_per_chr_scores () {
    trait=$1

    cd $obj_trait_dir

    echo -e "starting to sum per-chrom scores for trait ${trait}! \n"

    python3 $obj_script_dir/helper/sum_per_chr_scores.py $trait    

    echo -e "finished summing per-chrom scores for trait ${trait}! \n"

    cd $cwd
}


cwd=$PWD
obj_trait_dir=${cwd}/${trait_dir}
obj_script_dir=${cwd}/${script_dir}
obj_plink_file_prefix=${cwd}/$plink_file_prefix


run_plink_scoring $trait $obj_plink_file_prefix $num_at_a_time $num_threads $mem_per_score
sum_per_chr_scores $trait

echo -e "finished all step 2 tasks for trait ${trait} ! \n"
cd $cwd

