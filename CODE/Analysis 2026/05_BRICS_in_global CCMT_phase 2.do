/****************************************************************************************
* NACI Report 2026 – Phase 2: Global CCMT Trends
* Objective:
*   - Describe global trends in climate change mitigation technologies (CCMT, Y02)
*   - Provide figures and tables for the main report text
* Time coverage: 1995–2025
* Data source: Final CCMT invention panel (post CPC–IPC alignment)
****************************************************************************************/

version 17
clear all
set more off

*------------------------------------------------------------------------------
* 0. Global parameters
*------------------------------------------------------------------------------
global STARTYEAR 1995
global ENDYEAR   2025

global INDATA  "$datapath/Final_database/mitigation_inv_tech_inventor_ctry_year.dta"
global OUTPATH "$droppath/Analysis/Phase2_Global"

cap mkdir "$OUTPATH"

*------------------------------------------------------------------------------
* 1. Load and harmonise core dataset (single entry point)
*------------------------------------------------------------------------------
use "$INDATA", clear

keep if inrange(publn_year, $STARTYEAR, $ENDYEAR)

keep technology tech_name publn_year ///
     world_inv_CCMT world_hvi_CCMT ///
     world_hvi_all

duplicates drop

label var world_inv_CCMT "All CCMT inventions"
label var world_hvi_CCMT "High-value CCMT inventions"
label var world_hvi_all  "High-value inventions (all technologies)"

*------------------------------------------------------------------------------
* 2. TABLE 1 – Technology fields and total invention counts (1995–2025)
*------------------------------------------------------------------------------
preserve

collapse (sum) world_inv_CCMT world_hvi_CCMT, by(technology tech_name)

egen tot_inv_CCMT = sum(world_inv_CCMT)
egen tot_hvi_CCMT = sum(world_hvi_CCMT)

gen sh_inv_CCMT = 100 * world_inv_CCMT / tot_inv_CCMT
gen sh_hvi_CCMT = 100 * world_hvi_CCMT / tot_hvi_CCMT

order technology tech_name world_inv_CCMT world_hvi_CCMT sh_inv_CCMT sh_hvi_CCMT
sort technology

export excel "$OUTPATH/Table1_CCMT_Technology_Overview.xlsx", ///
    replace firstrow(variables)

restore

*------------------------------------------------------------------------------
* 3. FIGURE 1 – Global CCMT invention trajectory (index 1995 = 1)
*------------------------------------------------------------------------------
preserve

keep if technology == "Y02"

collapse (sum) world_hvi_CCMT world_hvi_all, by(publn_year)

summ world_hvi_CCMT if publn_year == $STARTYEAR, meanonly
scalar CCMT95 = r(mean)

summ world_hvi_all if publn_year == $STARTYEAR, meanonly
scalar ALL95 = r(mean)

gen idx_CCMT = world_hvi_CCMT / CCMT95
gen idx_ALL  = world_hvi_all  / ALL95

label var idx_CCMT "CCMT inventions (1995=1)"
label var idx_ALL  "All technologies (1995=1)"

line idx_CCMT idx_ALL publn_year, sort ///
    legend(order(1 "CCMT inventions" 2 "All technologies")) ///
    xtitle("Publication year") ///
    ytitle("Index (1995 = 1)") ///
    graphregion(fcolor(white))

graph export "$OUTPATH/Figure1_Global_CCMT_Trends.png", replace
export excel "$OUTPATH/Figure1_Global_CCMT_Trends.xlsx", replace firstrow(variables)

restore

*------------------------------------------------------------------------------
* 4. FIGURE 2 – Average annual growth by CCMT technology field
*------------------------------------------------------------------------------
preserve

keep if technology != "Y02"
sort technology publn_year

bys technology: gen growth_CCMT = ///
    100 * (world_hvi_CCMT - world_hvi_CCMT[_n-1]) / world_hvi_CCMT[_n-1]

drop if missing(growth_CCMT)

gen period = .
replace period = 1 if inrange(publn_year, 1996, 2012)
replace period = 2 if inrange(publn_year, 2013, $ENDYEAR)

label define period 1 "1995–2012" 2 "2013–2025"
label values period period

collapse (mean) growth_CCMT, by(technology tech_name period)

reshape wide growth_CCMT, i(technology tech_name) j(period)

rename growth_CCMT1 avg_growth_9512
rename growth_CCMT2 avg_growth_1325

export excel "$OUTPATH/Figure2_Growth_by_Technology.xlsx", ///
    replace firstrow(variables)

restore

*------------------------------------------------------------------------------
* 5. FIGURE 3 – Structural composition of CCMT (shares over time)
*------------------------------------------------------------------------------
preserve

keep if technology != "Y02"

collapse (sum) world_hvi_CCMT, by(technology tech_name publn_year)

egen tot_year = sum(world_hvi_CCMT), by(publn_year)
gen sh_CCMT = 100 * world_hvi_CCMT / tot_year

gen period = .
replace period = 1 if inrange(publn_year, 1995, 2000)
replace period = 2 if inrange(publn_year, 2015, 2025)

keep if period < .

collapse (mean) sh_CCMT, by(technology tech_name period)

label define period 1 "1995–2000" 2 "2015–2025"
label values period period

export excel "$OUTPATH/Figure3_Structure_CCMT.xlsx", ///
    replace firstrow(variables)

restore

*------------------------------------------------------------------------------
* END – Phase 2 Global CCMT Trends
*------------------------------------------------------------------------------
