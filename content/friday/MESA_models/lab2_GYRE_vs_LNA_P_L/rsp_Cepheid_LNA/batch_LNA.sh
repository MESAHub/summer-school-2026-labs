#!/usr/bin/env bash

# Set input paramters 
mod_dir="quick_mod_dir/"

# Set output file 
out_file='RSP.dat'

# Get list of mod files
mod_files=`ls $mod_dir/*.mod`
#mod_files=("270_4.43664_5695_2294.mod") # Run only one model for testing

# Remove output file from previous runs
rm $out_file

# Write a header in our output file 
echo 'star_mass	luminosity	effective_temperature	 W_VI	RSP_F_period	RSP_F_growth	GYRE_F_Period	GRYE_F_Growth' > $out_file

# Loop over each mod_file 
for file in $mod_files 
do 
	mod_id="$(basename $file .mod)"
	echo 'Doing ' $mod_id # for initial set up 
	# Get values of M, Teff, L, needed for RSP set up 
	mod_num=$(echo $mod_id | cut -d '_' -f 1) 
	mass=$(echo $mod_id | cut -d '_' -f 2) 
	teff=$(echo $mod_id | cut -d '_' -f 3) 
	lum=$(echo $mod_id | cut -d '_' -f 4) 

	echo $mass $teff 

	# use shmesa to update inlist_rsp_Cepheid
	shmesa change inlist_rsp_Cepheid \
		RSP_mass $mass \
		RSP_Teff $teff \
		RSP_L $lum

	# Do the MESA run for this star 
	./rn 
done 

