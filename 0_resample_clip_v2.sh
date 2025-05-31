#!/bin/bash

# Set output directory
output_dir="/exports/geos.ed.ac.uk/landteam/N/chris_fire/1_processed"
shapefile="/exports/geos.ed.ac.uk/landteam/N/chris_fire/shp/proj_area_34S.shp"

# Set the target resolution
target_resolution="28.88155 30.08150"

# Create output directory if it doesn't exist
mkdir -p "$output_dir"

# List of input raster paths
categorical_rasters=(
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/0_original_data/3.tif" #deg1
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/0_original_data/4.tif" #deg2
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/0_original_data/5.tif" #deg3
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/1_combined/deg_combined.tif" #combined deg
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr01_adjacent_count.tif" #deg_adj
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr02_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr03_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr04_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr05_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr06_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr07_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr08_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr09_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr10_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr11_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr12_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr13_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr14_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr15_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr16_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr17_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr18_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr19_adjacent_count.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Degradation/2_adjacent/lr20_adjacent_count.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/def_combined.tif" # def
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2000.tif" #landcover
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2001.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2002.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2003.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2004.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2005.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2006.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2007.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2008.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2009.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2010.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2011.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2012.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2013.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2014.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2015.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2016.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2017.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2018.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2019.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/LC2020.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2000.tif" #proportion of flammable landcover
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2001.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2002.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2003.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2004.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2005.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2006.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2007.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2008.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2009.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2010.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2011.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2012.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2013.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2014.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2015.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2016.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2017.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2018.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2019.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/Landcover/flammable_lc/FLC_2020.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2000.tif" #modis
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2001.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2002.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2003.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2004.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2005.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2006.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2007.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2008.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2009.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2010.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2011.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2012.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2013.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2014.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2015.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2016.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2017.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2018.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2019.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2020.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2021.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2022.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/MCD64A1/3_years/2023.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/VIIRS_NRT_375/2_years/viirs_2012.tif" #VIIRS
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/VIIRS_NRT_375/2_years/viirs_2013.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/VIIRS_NRT_375/2_years/viirs_2014.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/VIIRS_NRT_375/2_years/viirs_2015.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/VIIRS_NRT_375/2_years/viirs_2016.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/VIIRS_NRT_375/2_years/viirs_2017.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/VIIRS_NRT_375/2_years/viirs_2018.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/VIIRS_NRT_375/2_years/viirs_2019.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/VIIRS_NRT_375/2_years/viirs_2020.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/VIIRS_NRT_375/2_years/viirs_2021.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/VIIRS_NRT_375/2_years/viirs_2022.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/VIIRS_NRT_375/2_years/viirs_2023.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/adm2.tif" # covariates
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/adm3.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/catchments.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/syndrome.tif"
    # Add more categorical rasters as needed
)

continuous_rasters=(
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/markets.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/roads.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/urban.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/pop.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/slope.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/def_dist_2010.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/wedge_in_2010.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/wedge_out_2010.tif"
    "/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/mcnicol_angola_agc_alos1.tif"
    #"/exports/geos.ed.ac.uk/landteam/N/chris_fire/covariates/1_4326/SRTM_mTPI.tif"
    # Add more continuous rasters as needed
)

# Function to resample and clip a list of rasters
resample_and_clip() {
    local resampling_method=$1
    shift
    local input_rasters=("$@")

    for input_raster in "${input_rasters[@]}"; do
        filename=$(basename "$input_raster" .tif)
        output_raster="$output_dir/${filename}_resampled.tif"

        gdalwarp -s_srs EPSG:4326 -t_srs EPSG:32734 -tr $target_resolution -r $resampling_method -cutline "$shapefile" -crop_to_cutline -tap "$input_raster" "$output_raster"

        # Optionally, add additional processing steps here if needed
    done
}

# Resample and clip categorical rasters using nearest neighbor
resample_and_clip "near" "${categorical_rasters[@]}"

# Resample and clip continuous rasters using bilinear
resample_and_clip "bilinear" "${continuous_rasters[@]}"

echo "Resampling and clipping completed."

