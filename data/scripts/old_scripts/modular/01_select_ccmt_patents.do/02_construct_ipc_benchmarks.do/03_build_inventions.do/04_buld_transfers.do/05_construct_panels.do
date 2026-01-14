/********************************************************************
* Balanced country–technology–year panels
********************************************************************/

use "$datapath/CCMT_transfers.dta", clear
tsset technology invt_iso publn_year

tsfill, full
replace inv_weight = 0 if missing(inv_weight)
replace transfer = 0 if missing(transfer)

save "$datapath/CCMT_panel.dta", replace
