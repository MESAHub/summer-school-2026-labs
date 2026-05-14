#!/usr/bin/env bash

# Stop on script errors.
set -euo pipefail

# Empty globs give no files.
shopt -s nullglob

# Set input parameters. Optionally pass the Lab 1 mod_dir as the first argument.
mod_dir="${1:-quick_mod_dir/}"

# Require a real mod_dir.
if [[ ! -d "$mod_dir" ]]; then
	echo "Missing mod_dir: $mod_dir"
	exit 1
fi

# Set output file. This must match x_character_ctrl(10).
out_file="${2:-RSP_full_grid.dat}"
final_out_file="$out_file"

# Read X/Z from the Lab 1 GYRE table when available.
gyre_table="${3:-}"
if [[ -z "$gyre_table" && -f "$mod_dir/gyre_in_mesa.data" ]]; then
	gyre_table="$mod_dir/gyre_in_mesa.data"
fi

# Require the requested Lab 1 GYRE table.
if [[ -n "$gyre_table" && ! -f "$gyre_table" ]]; then
	echo "Missing Lab 1 GYRE table: $gyre_table"
	exit 1
fi

# Give shmesa a local filename.
mesa_out_file="$(basename "$out_file")"
failed_models_file="${mesa_out_file}.failed_models"

# Avoid broken Fortran quoting.
if [[ "$mesa_out_file" == *"'"* ]]; then
	echo "Output filename cannot contain a single quote: $mesa_out_file"
	exit 1
fi

# Create requested output folder.
if [[ "$out_file" == */* ]]; then
	out_dir="$(dirname "$out_file")"
	mkdir -p "$out_dir"
	final_out_file="$(cd "$out_dir" && pwd)/$(basename "$out_file")"
fi

# Get list of mod files
mod_files=("$mod_dir"/*.mod)

# Require at least one model.
if [[ "${#mod_files[@]}" -eq 0 ]]; then
	echo "No .mod files found in $mod_dir"
	exit 1
fi
#mod_files=("270_4.43664_5695_2294.mod") # Run only one model for testing

# Remove output file from previous runs
rm -f "$mesa_out_file" "$final_out_file" "$failed_models_file" "${final_out_file}.failed_models"

# Write a fixed-width header in our output file.
printf '%12s %20s %20s %20s %20s %20s %20s\n' \
	'model_number' 'star_mass' 'luminosity' 'Teff' 'RSP_W_VI' 'RSP_F_period' 'RSP_F_growth' > "$mesa_out_file"

lookup_rsp_xz() {
	local model="$1"
	local table="$2"

	awk -v target="$model" '
		function scan_header(   i) {
			model_col = x_col = z_col = 0
			for (i = 1; i <= NF; i++) {
				if ($i == "model_number") model_col = i
				if ($i == "X") x_col = i
				if ($i == "Z") z_col = i
			}
			return model_col && x_col && z_col
		}
		{
			if ($1 == "#") {
				$1 = ""
				sub(/^[[:space:]]+/, "")
			}
			if (!have_header) {
				if (scan_header()) have_header = 1
				next
			}
			if (int($model_col + 0.5) == target) {
				x = $x_col + 0
				z = $z_col + 0
				if (x <= 0 || z <= 0) exit 2
				printf "%.12g %.12g\n", x, z
				found = 1
				exit
			}
		}
		END {
			if (!have_header || !found) exit 1
		}
	' "$table"
}

# Loop over each mod_file 
for file in "${mod_files[@]}"
do 
	mod_id="$(basename "$file" .mod)"
	echo "Doing $mod_id" # for initial set up
	# Get values of M, Teff, L, needed for RSP set up 
	IFS=_ read -r mod_num mass teff lum <<< "$mod_id"

	# Require expected filename parts.
	if [[ -z "$mod_num" || -z "$mass" || -z "$teff" || -z "$lum" ]]; then
		echo "Unexpected .mod filename: $file"
		exit 1
	fi

	echo "$mass $teff"

	rsp_controls=(RSP_mass "$mass" RSP_Teff "$teff" RSP_L "$lum")
	if [[ -n "$gyre_table" ]]; then
		# Get Lab 1 X/Z.
		if ! read -r rsp_x rsp_z < <(lookup_rsp_xz "$mod_num" "$gyre_table"); then
			echo "Failed to find X/Z for model $mod_num in $gyre_table"
			exit 1
		fi
		echo "X=$rsp_x Z=$rsp_z"
		rsp_controls+=(RSP_X "$rsp_x" RSP_Z "$rsp_z")
	fi

	# Update scalar RSP controls.
	if ! shmesa change inlist_rsp_Cepheid "${rsp_controls[@]}"
	then
		echo "Failed to update inlist_rsp_Cepheid for $mod_id"
		exit 1
	fi

	# Set array controls directly.
	tmp_inlist="${TMPDIR:-/tmp}/batch_LNA_inlist.$$"
	awk -v out_file="$mesa_out_file" -v model_num="$mod_num" '
		/^[[:space:]]*x_character_ctrl\(10\)[[:space:]]*=/ {
			sub(/=.*/, "= '\''" out_file "'\''")
		}
		/^[[:space:]]*x_integer_ctrl\(10\)[[:space:]]*=/ {
			sub(/=.*/, "= " model_num " ! Lab 1 model number")
		}
		{ print }
	' inlist_rsp_Cepheid > "$tmp_inlist"
	mv "$tmp_inlist" inlist_rsp_Cepheid

	# Do the MESA run for this star 
	# Count rows before MESA.
	rows_before="$(awk 'NR > 1 && NF > 0 { count++ } END { print count + 0 }' "$mesa_out_file")"

	# Stop if MESA fails.
	if ! ./rn; then
		echo "$mod_id ./rn failed" >> "$failed_models_file"
		echo "./rn failed for $mod_id; continuing"
		continue
	fi

	# Confirm a row was added.
	rows_after="$(awk 'NR > 1 && NF > 0 { count++ } END { print count + 0 }' "$mesa_out_file")"
	if [[ "$rows_after" -le "$rows_before" ]]; then
		echo "$mod_id no data row" >> "$failed_models_file"
		echo "No data row was written for $mod_id; continuing"
		continue
	fi
done 

# Copy to requested path.
if [[ "$final_out_file" != "$(pwd)/$mesa_out_file" && "$final_out_file" != "$mesa_out_file" ]]; then
	cp "$mesa_out_file" "$final_out_file"
	if [[ -f "$failed_models_file" ]]; then
		cp "$failed_models_file" "${final_out_file}.failed_models"
	fi
fi
