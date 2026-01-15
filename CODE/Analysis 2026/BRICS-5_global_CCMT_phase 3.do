/****************************************************************************************
* NACI Report 2026 – Phase 3: BRICS-5 in Global CCMT Innovation
* Objective:
*   - Compare BRICS-5 performance to Rest of World in CCMT
*   - Ensure full compatibility with Phase 2 indicators
****************************************************************************************/

version 17
clear all
set more off

*------------------------------------------------------------------------------
* 0. Parameters and country groups
*------------------------------------------------------------------------------
global STARTYEAR 1995
global ENDYEAR   2025

global INDATA  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year.dta"
global OUTPATH "$droppath/Analysis/Phase3_BRICS"

cap mkdir "$OUTPATH"

* BRICS-5 ISO codes
local BRICS "BRA RUS IND CHN ZAF"

*------------------------------------------------------------------------------
* 1. Load core dataset
*------------------------------------------------------------------------------
use "$INDATA", clear
keep if inrange(publn_year, $STARTYEAR, $ENDYEAR)

keep technology tech_name publn_year invt_iso ///
     nb_hvi_CCMT world_hvi_CCMT

gen brics = inlist(invt_iso, `"`BRICS'"')

label var brics "BRICS-5 inventor country"

*------------------------------------------------------------------------------
* 2. FIGURE 4 – BRICS-5 share in global CCMT (Y02)
*------------------------------------------------------------------------------
preserve

keep if technology == "Y02"

collapse (sum) nb_hvi_CCMT, by(brics publn_year)
reshape wide nb_hvi_CCMT, i(publn_year) j(brics)

gen world = nb_hvi_CCMT0 + nb_hvi_CCMT1
gen sh_BRICS_CCMT = 100 * nb_hvi_CCMT1 / world

keep publn_year sh_BRICS_CCMT

export excel "$OUTPATH/Figure4_BRICS_Share_Global_CCMT.xlsx", ///
    replace firstrow(variables)

restore

*------------------------------------------------------------------------------
* 3. FIGURE 5 – Growth performance: BRICS-5 vs Rest of World
*------------------------------------------------------------------------------
preserve

keep if technology == "Y02"

collapse (sum) nb_hvi_CCMT, by(brics publn_year)
sort brics publn_year

bys brics: gen growth = ///
    100 * (nb_hvi_CCMT - nb_hvi_CCMT[_n-1]) / nb_hvi_CCMT[_n-1]

drop if missing(growth)

gen period = .
replace period = 1 if inrange(publn_year, 1996, 2012)
replace period = 2 if inrange(publn_year, 2013, $ENDYEAR)

collapse (mean) growth, by(brics period)

reshape wide growth, i(brics) j(period)

rename growth1 avg_growth_9512
rename growth2 avg_growth_1325

label var avg_growth_9512 "1995–2012"
label var avg_growth_1325 "2013–2025"

export excel "$OUTPATH/Figure5_Growth_BRICS_vs_RoW.xlsx", ///
    replace firstrow(variables)

restore

*------------------------------------------------------------------------------
* 4. FIGURE 6 – Technology specialisation (RTA-style)
*------------------------------------------------------------------------------
preserve

keep if technology != "Y02"

collapse (sum) nb_hvi_CCMT, by(technology tech_name brics)

egen tot_group = sum(nb_hvi_CCMT), by(brics)
egen tot_tech  = sum(nb_hvi_CCMT), by(technology)
egen tot_all   = sum(nb_hvi_CCMT)

gen RTA = (nb_hvi_CCMT / tot_group) / (tot_tech / tot_all)

keep technology tech_name brics RTA
export excel "$OUTPATH/Figure6_BRICS_RTA.xlsx", ///
    replace firstrow(variables)

restore

*------------------------------------------------------------------------------
* 5. TABLE 2 – Technology structure (early vs recent period)
*------------------------------------------------------------------------------
preserve

keep if technology != "Y02"

gen period = .
replace period = 1 if inrange(publn_year, 1995, 2000)
replace period = 2 if inrange(publn_year, 2015, 2025)
keep if period < .

collapse (sum) nb_hvi_CCMT, by(brics technology tech_name period)

egen tot_period = sum(nb_hvi_CCMT), by(brics period)
gen sh_CCMT = 100 * nb_hvi_CCMT / tot_period

export excel "$OUTPATH/Table2_Structure_BRICS.xlsx", ///
    replace firstrow(variables)

restore

*------------------------------------------------------------------------------
* END – Phase 3 BRICS-5
*------------------------------------------------------------------------------
