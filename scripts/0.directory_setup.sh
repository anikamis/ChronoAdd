#!/bin/bash

# trait is read from first command line argument, dir will be named for_${trait}
trait=$1

# tab-separated file of all single scores in chronological order by publication date
# first column contains PGS ID, second column contains publication PGP ID
pgs_to_pgp=$2

set_up_dirs () {
    trait=$1
    pgs_to_pgp=$2

    # make directory and copy directory structure
    mkdir for_${trait} ; cp dirs.txt for_${trait}/. ; cd for_${trait} 
    mkdir -p scores/summed_scores scores/raw_scores add_in_prsmix pgs_catalog_harmonized_weights weights all_harmonized_weights

    cp $cwd/$pgs_to_pgp add_in_prsmix/${trait}.pgs_to_pgp.tsv
    pgs_to_pgp=add_in_prsmix/${trait}.pgs_to_pgp.tsv

    # extract names of PGS into single file
    awk -F "\t" '{print $1}' $pgs_to_pgp > weights/${trait}.score_list.txt


    # create all add_in_prsmix subdirectories for each ChronoAdd iteration
    # and create PRSmix input score files for each ChronoAdd iteration
    counter=1
    for pgp in $( awk -F "\t" '{print $2}' $pgs_to_pgp | uniq ) ; do mkdir -p add_in_prsmix/with_${counter}/all && outfile=add_in_prsmix/with_${counter}/${trait}.score_list.txt ; linenum=$( grep -n "$pgp" $pgs_to_pgp | tail -1 | cut -d : -f 1 ) ; echo $pgp ; echo $linenum ; echo $outfile ; awk -F "\t" '{print $1}' $pgs_to_pgp | head -n $linenum > $outfile ; counter=$((counter + 1)) ; done

    cd $cwd
}

cwd=$PWD

set_up_dirs $trait $pgs_to_pgp

echo -e "finished all step 0 tasks for ${trait} ! \n"
cd $cwd

