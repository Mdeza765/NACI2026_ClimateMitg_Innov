*===========================================================
* MODULE EV-01: EV inventions – BRICS vs Rest of World
*===========================================================

use "$patstpath/mitigation/ElecVehicles_ZOOM_inventor_ctry_year", clear

* Keep analysis window
keep if publn_year >=1995 & publn_year <=2025

* Harmonise naming
rename world_hvi_EVall world_hvi_EV

* Identify BRICS-5
gen byte brics = inlist(invt_iso,"BRA","RUS","IND","CHN","ZAF")

* Aggregate yearly EV inventions
bysort publn_year: egen EV_BRICS = sum(world_hvi_EV * brics)
bysort publn_year: egen EV_WORLD = sum(world_hvi_EV)

gen EV_RoW = EV_WORLD - EV_BRICS

keep publn_year EV_BRICS EV_RoW EV_WORLD
duplicates drop
sort publn_year

save "$datapath/Analysis/EV/EV_BRICS_RoW_year.dta", replace
