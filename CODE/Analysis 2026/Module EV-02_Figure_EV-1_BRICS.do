use "$datapath/Analysis/EV/EV_BRICS_RoW_year.dta", clear

gen sh_BRICS_EV = 100 * EV_BRICS / EV_WORLD

keep publn_year sh_BRICS_EV
export excel "$droppath/Analysis/EV/Figure_EV1_BRICS_share.xlsx", ///
replace firstrow(variables)
