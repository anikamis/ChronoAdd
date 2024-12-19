#!/bin/bash

# trait is read from first command line argument
trait=$1

# location of trait directory created in step 0
trait_dir=$2

# location of all scripts, with subdirectory containing helper scripts
script_dir=$3


# download GRCh38-harmonized scores from PGS Catalog
download_from_pgs () {
    trait=$1
    cd $obj_trait_dir

    echo -e "starting pgs catalog downloads for trait ${trait}! \n"

    ./parallel -a weights/${trait}.score_list.txt -j 4 --dry-run 'wget -O  "pgs_catalog_harmonized_weights/{}_hmPOS_GRCh38.txt.gz" https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/{}/ScoringFiles/Harmonized/{}_hmPOS_GRCh38.txt.gz && gzip -d pgs_catalog_harmonized_weights/{}_hmPOS_GRCh38.txt.gz'

    echo -e "finished pgs catalog downloads for trait ${trait}! \n"
}

# reformat weights from PGS Catalog to be PRSmix-input compatible 
format_pgs_weights () {
    trait=$1
    cd $obj_trait_dir

    echo -e "starting formatting for trait ${trait}! \n"

    # reformat weights from pgs catalog to be prsmix-input compatiblec
    ./parallel -j 4 python3 $obj_script_dir/helper/reformat_pgs_weights.py ${trait} {} < weights/${trait}.score_list.txt

    echo -e "finished formatting weights for trait ${trait}! \n"
}

# use PRSmix to harmonize weights together
harmonize_pgs_weights () {
    trait=$1
    cd $obj_trait_dir

    echo -e "starting harmonization for trait ${trait}! \n"

    # run prsmix script to harmonize all pgs weight files together
    Rscript --vanilla $obj_script_dir/helper/harmonize_snpeffect_toALT_prsmix.R ${trait}

    # split into per-chr files
    for i in {1..22} X ; do infile=all_harmonized_weights/${trait}.all_harmonized_weights.ALL_SNPS.txt ; outfile=all_harmonized_weights/${trait}.all_harmonized_weights.ALL_SNPS.chr${i}.txt ; head -1 $infile > $outfile ; pattern="chr${i}:" ; grep $pattern $infile >> $outfile ; done

    echo -e "finished harmonizing weight files together for trait ${trait}! \n"
}


cwd=$PWD
obj_trait_dir=${cwd}/${trait_dir}
obj_script_dir=${cwd}/${script_dir}

download_from_pgs $trait
format_pgs_weights $trait
harmonize_pgs_weights $trait

echo -e "finished all step 1 tasks for trait ${trait} ! \n"
cd $cwd

