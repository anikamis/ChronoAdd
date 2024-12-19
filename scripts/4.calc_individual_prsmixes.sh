#!/bin/bash

# get name of trait from first command-line argument
trait=$1

# location of trait directory created in step 0
trait_dir=$2

# location of all scripts, with subdirectory containing helper scripts
script_dir=$3


cal_indiv_prsmix () {
    trait=$1

    cd $obj_trait_dir

    in_score_prefix=scores/summed_scores/${trait}.ACAF.ALL
    out_score_prefix=scores/summed_scores/${trait}.ACAF.with_ChronoAddPrsmix.all

    num_scores=$( ls add_in_prsmix/with_*/${trait}.score_list.txt | wc -w )

    for i in $(seq 1 $num_scores ); 
    do
        prsmix_dir=add_in_prsmix/with_${i}/all

        pgp_name=$( head -n $i add_in_prsmix/${trait}.pgs_to_pgp.tsv | tail -1 | awk -F "\t" '{print $2}' )
        colname="with_${i}_${pgp_name}_SUM"
        
        if [[ "$i" == "1" ]]; then
            in_score=$in_score_prefix
            out_score=$out_score_prefix
        else
            in_score=$out_score_prefix
            out_score=$out_score_prefix
        fi

        python3 ${obj_script_dir}/helper/apply_individual_prsmix.py $trait $in_score $out_score $prsmix_dir $colname
    done
    
    
    echo -e "finished running all add in PRSmix!"
    
    cd $cwd
}

cwd=$PWD
obj_trait_dir=${cwd}/${trait_dir}
obj_script_dir=${cwd}/${script_dir}

cal_indiv_prsmix $trait 

echo -e "finished all step 4 tasks for trait ${trait} ! \n"
cd $cwd
