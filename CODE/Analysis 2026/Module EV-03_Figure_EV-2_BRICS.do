use "$datapath/Analysis/EV/EV_BRICS_RoW_year.dta", clear

* Base year (1995)
gen base_BRICS = EV_BRICS if publn_year==1995
egen BRICS_1995 = max(base_BRICS)

gen base_RoW = EV_RoW if publn_year==1995
egen RoW_1995 = max(base_RoW)

gen idx_BRICS = EV_BRICS / BRICS_1995
gen idx_RoW   = EV_RoW   / RoW_1995

keep publn_year idx_BRICS idx_RoW
sort publn_year

export excel "$droppath/Analysis/EV/Figure_EV2_growth.xlsx", ///
replace firstrow(variables)
