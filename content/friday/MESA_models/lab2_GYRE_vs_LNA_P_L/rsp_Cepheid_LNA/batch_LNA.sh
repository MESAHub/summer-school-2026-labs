#!/usr/bin/env bash

# Set input parameters. Optionally pass the Lab 1 mod_dir as the first argument.
mod_dir="${1:-quick_mod_dir/}"

# Set output file. This must match x_character_ctrl(10).
out_file="${2:-RSP_full_grid.dat}"

# Get list of mod files
mod_files=`ls "$mod_dir"/*.mod`
#mod_files=("270_4.43664_5695_2294.mod") # Run only one model for testing

# Remove output file from previous runs
rm -f "$out_file"

# Write a header in our output file 
echo 'model_number	star_mass	luminosity	effective_temperature	W_VI	RSP_F_period	RSP_F_growth	GYRE_F_period	GYRE_F_growth' > "$out_file"

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
		RSP_L $lum \
		'x_character_ctrl(10)' "'$out_file'" \
		'x_integer_ctrl(10)' $mod_num

	# Do the MESA run for this star 
	./rn 
done 
