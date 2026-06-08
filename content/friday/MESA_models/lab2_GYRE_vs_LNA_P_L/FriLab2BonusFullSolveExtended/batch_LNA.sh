#!/usr/bin/env bash

set -e

# Set input parameters. Optionally pass the Lab 1 mod_dir as the first argument.
mod_dir="${1:-quick_mod_dir/}"

# Require a real mod_dir.
if [ ! -d "$mod_dir" ]; then
	echo "Missing mod_dir: $mod_dir"
	exit 1
fi

# Set output file.
out_file='RSP.dat'

# Remove output file from previous runs
rm -f "$out_file"

# Write a fixed-width header in our output file
printf '%12s %20s %20s %20s %20s %20s %20s %20s %20s\n' \
	'model_number' 'star_mass' 'luminosity' 'Teff' 'RSP_W_VI' \
	'RSP_F_period' 'RSP_F_growth' 'RSP_F1_period' 'RSP_F1_growth' > "$out_file"

# Loop over each mod_file
for file in "$mod_dir"/*.mod
do
	if [ ! -e "$file" ]; then
		echo "No .mod files found in $mod_dir"
		exit 1
	fi

	mod_id="$(basename "$file" .mod)"
	echo "Doing $mod_id" # for initial set up
	# Get values of M, Teff, L, needed for RSP set up
	mod_num=$(echo "$mod_id" | cut -d '_' -f 1)
	mass=$(echo "$mod_id" | cut -d '_' -f 2)
	teff=$(echo "$mod_id" | cut -d '_' -f 3)
	lum=$(echo "$mod_id" | cut -d '_' -f 4)

	echo $mass $teff

	# Use shmesa to update inlist_rsp_Cepheid
	shmesa change inlist_rsp_Cepheid \
		set_initial_model_number .true. \
		initial_model_number "$mod_num" \
		RSP_mass "$mass" \
		RSP_Teff "$teff" \
		RSP_L "$lum"

	# Do the MESA run for this star
	./rn
done
