/********************************************************************
* IPC benchmark construction for CCMT technologies
* Coverage threshold: 75%
********************************************************************/

local coverage = 0.75

*--- Merge IPC codes to CCMT mitigation patents
use "$datapath/Patstat_mitigation2026.dta", clear
merge 1:m appln_id using "$patstpath/general/ipc_codes.dta", keep(match)
drop _merge

*====================================================
* A. IPC-3 benchmark (primary)
*====================================================

preserve
drop if technology=="Y02"   // Y02 benchmark = full PATSTAT

gen ipc3 = substr(ipc_code,1,3)

bysort technology ipc3: gen n_ipc3 = _N
bysort technology: gen n_total = _N

bysort technology ipc3: keep if _n==1
gen share = n_ipc3 / n_total

gsort technology -share
by technology: gen cumshare = sum(share)

keep if cumshare <= `coverage'
keep technology ipc3
duplicates drop

save "$datapath/Selected_IPC3_benchmark_CCMT.dta", replace
restore
