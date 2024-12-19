#!/bin/bash

# get name of trait from first command-line argument
trait=$1

# location of trait directory created in step 0
trait_dir=$2

# location of all scripts, with subdirectory containing helper scripts
script_dir=$3

# location of covariate file
covariate_file=$4

# location of phenotype file
pheno_file=$5

# name of phenotype column
pheno_name=$6

# TRUE if trait is binary else FALSE
isbinary=$7

# number of cores to run a single iteration of PRSmix
ncores=$8


# for each type of classification
run_aoi_prsmix () {
    trait=$1
    covariate_file=$2
    pheno_file=$3
    pheno_name=$4
    isbinary=$5
    ncores=$6
    
    cd $obj_trait_dir

    score_files_list=scores/summed_scores/${trait}.ACAF.ALL.sscore

    num_scores=$( ls add_in_prsmix/with_*/${trait}.score_list.txt | wc -w )
    echo -e "starting prsmix for trait ${trait}! \n"

    for i in $(seq 1 $num_scores ); 
    do
        trait_specific_score_file=add_in_prsmix/with_${i}/${trait}.score_list.txt
        out=add_in_prsmix/with_${i}/all/${trait}
        
        Rscript --vanilla ${obj_script_dir}/helper/run_PRSmix.R $trait $covariate_file $score_files_list $trait_specific_score_file $pheno_file $pheno_name $isbinary $out $ncores

        echo -e "finished" >> add_in_prsmix/with_${i}/aoi.finished.txt
    done
    
    
    echo -e "finished running all add in PRSmix!"
    
    cd $cwd
}

cwd=$PWD
obj_trait_dir=${cwd}/${trait_dir}
obj_script_dir=${cwd}/${script_dir}

run_aoi_prsmix $trait ${cwd}/$covariate_file ${cwd}/$pheno_file $pheno_name $isbinary $ncores

echo -e "finished all step 3 tasks for trait ${trait} ! \n"
cd $cwd
