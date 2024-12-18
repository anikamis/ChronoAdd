#!/bin/bash

# trait is read from first command line argument
trait=$1

set_up_dir () {
	trait=$1
	cd ~/workspaces/runlargeprs/individual_data/anikamis/
	
	# make directory and copy directory structure
	mkdir for_${trait} ; cd for_${trait} ; xargs mkdir -p < ../dirs.txt ; cd ..
	
	# copy score file list into directory (already made)
	cp score_file_lists/${trait}.score_list.txt for_${trait}/weights/.
	cp score_file_lists/${trait}.score_list.txt for_${trait}/for_prsmix/.
}

download_from_pgs () {
	trait=$1
	cd ~/workspaces/runlargeprs/individual_data/anikamis/for_${trait}
	
	echo -e "starting pgs catalog downloads for trait ${trait}! \n"
	
	num_scores=$(wc -l weights/${trait}.score_list.txt | cut -d " " -f1 ) ; for i in $(seq 1 $num_scores ) ; do x=$(head -$i weights/${trait}.score_list.txt | tail -1) ; echo $x ; outfn="pgs_catalog_harmonized_weights/${x}_hmPOS_GRCh38.txt.gz" ; wget -O$outfn "https://ftp.ebi.ac.uk/pub/databases/spot/pgs/scores/${x}/ScoringFiles/Harmonized/${x}_hmPOS_GRCh38.txt.gz" ; gzip -d $outfn ; echo -e "finished downloading ${x}! \n" ; done
	
	echo -e "finished pgs catalog downloads for trait ${trait}! \n"
}

format_pgs_weights () {
	trait=$1
	cd ~/workspaces/runlargeprs/individual_data/anikamis/for_${trait}
	
	echo -e "starting formatting for trait ${trait}! \n"

	# reformat weights from pgs catalog to be prsmix-input compatible
	~/workspaces/runlargeprs/individual_data/anikamis/tools/parallel -j 4 python3 ~/workspaces/runlargeprs/individual_data/anikamis/scripts/reformat_pgs_weights.py ${trait} {} < weights/${trait}.score_list.txt
	
	echo -e "finished formatting weights for trait ${trait}! \n"
}

harmonize_pgs_weights () {
	trait=$1
	cd ~/workspaces/runlargeprs/individual_data/anikamis/for_${trait}
	
	echo -e "starting harmonization for trait ${trait}! \n"
	
	# run prsmix script to harmonize all pgs weight files together
	Rscript --vanilla ~/workspaces/runlargeprs/individual_data/anikamis/scripts/harmonize_snpeffect_toALT_prsmix.R ${trait}
	
	# split into per-chr files
	for i in {1..22} X ; do infile=all_harmonized_weights/${trait}.all_harmonized_weights.ALL_SNPS.txt ; outfile=all_harmonized_weights/${trait}.all_harmonized_weights.ALL_SNPS.chr${i}.txt ; head -1 $infile > $outfile ; pattern="chr${i}:" ; grep $pattern $infile >> $outfile ; done

	echo -e "finished harmonizing weight files together for trait ${trait}! \n"
}

run_plink_scoring () {
	trait=$1
	cd ~/workspaces/runlargeprs/individual_data/anikamis/for_${trait}

	echo -e "starting plink2 scoring for all chromosomes for trait ${trait}! \n"
	
	num_cols=$( head -1 all_harmonized_weights/${trait}.all_harmonized_weights.ALL_SNPS.txt | wc -w ) ; ../tools/parallel -j 5 ../tools/plink2 --threads 18 --memory 80000 --bfile ../aou_acaf/acaf_threshold.chr{} --score all_harmonized_weights/${trait}.all_harmonized_weights.ALL_SNPS.chr{}.txt cols=fid,scoresums no-mean-imputation header-read --score-col-nums 4-$num_cols --out scores/raw_scores/${trait}.ACAF.chr{} ::: {1..22}
	
	echo -e "finished plink2 scoring for all chromosomes for trait ${trait}! \n"

}

# get name of trait from first command-line argument
trait=$1

#set_up_dir $trait
#download_from_pgs $trait
#format_pgs_weights $trait
#harmonize_pgs_weights $trait
run_plink_scoring $trait

echo -e "finished all tasks for trait ${trait} ! \n"
cd ~/workspaces/runlargeprs/individual_data/anikamis/
