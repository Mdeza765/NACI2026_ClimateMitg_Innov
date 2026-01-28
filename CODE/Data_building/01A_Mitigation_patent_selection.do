*===============================================================================
* NACI Report 2026
* Chapter: Sustainability and Climate Change – Climate Change Mitigation Technologies
*
* Objective:
* - Identify climate change mitigation patents using CPC Y02 codes
* - Exclude adaptation technologies (Y02A)
* - Align CPC-based selection with IPC 4-digit technology benchmark
*===============================================================================

clear all
set more off

*===============================================================================
* 1. LOAD CPC CODES AND SELECT MITIGATION TECHNOLOGIES
*===============================================================================

use "$patstpath/general/CPC_codes.dta", clear

* Keep CPC Y02 mitigation codes, exclude adaptation (Y02A)
keep if substr(cpc_code,1,3)=="Y02" & substr(cpc_code,1,4)!="Y02A"

* Basic quality check
assert substr(cpc_code,1,3)=="Y02"
assert substr(cpc_code,1,4)!="Y02A"

*===============================================================================
* 2. CPC–IPC ALIGNMENT (MANDATORY)
*===============================================================================

* Merge official CPC–IPC concordance
merge m:1 cpc_code using "$patstpath/general/CPC_IPC_concordance.dta"

* Keep only CPC codes with a valid IPC mapping
keep if _merge == 3
drop _merge

* Define IPC benchmark at the 4-digit level
gen ipc_4d = substr(ipc_code,1,4)
label var ipc_4d "IPC technology field (4-digit benchmark)"

* Safety check: CPC and IPC must align at 4-digit level
gen cpc_4d = substr(cpc_code,1,4)
assert cpc_4d == ipc_4d
drop cpc_4d

*===============================================================================
* 3. CREATE TECHNOLOGY CLASSIFICATION LEVELS
*===============================================================================

* Aggregate mitigation technology
gen tech_3d = substr(ipc_4d,1,3)
label var tech_3d "Aggregate mitigation technology (IPC 3-digit)"

* Technology field (benchmark)
gen technology = ipc_4d
label var technology "Mitigation technology field (IPC 4-digit)"

* Sub-technology (for optional fine-grained analysis)
gen tech_6d = substr(cpc_code,1,6)
label var tech_6d "Mitigation sub-technology (CPC 6-digit)"

*===============================================================================
* 4. SAVE CORE CPC–IPC ALIGNED DATASET
*===============================================================================

save "$datapath/CPC_CCMT_IPC_aligned_2026.dta", replace

*===============================================================================
* 5. DERIVED DATASETS FOR DOWNSTREAM USE
*===============================================================================

*-------------------------------------------------
* 5.1 Aggregate mitigation (Y02)
*-------------------------------------------------
use "$datapath/CPC_CCMT_IPC_aligned_2026.dta", clear
keep cpc_code tech_3d
duplicates drop
gen level = "aggregate"
save "$datapath/Y02_PatstatCAT_mitigation.dta", replace

*-------------------------------------------------
* 5.2 Technology fields (IPC 4-digit benchmark)
*-------------------------------------------------
use "$datapath/CPC_CCMT_IPC_aligned_2026.dta", clear
keep cpc_code technology
duplicates drop
gen level = "technology"
save "$datapath/bycat_PatstatCAT_mitigation.dta", replace

*-------------------------------------------------
* 5.3 Append aggregate and technology-level datasets
*-------------------------------------------------
use "$datapath/Y02_PatstatCAT_mitigation.dta", clear
append using "$datapath/bycat_PatstatCAT_mitigation.dta"
label var level "Aggregation level: aggregate (Y02) or technology (IPC 4-digit)"
save "$datapath/Patstat_mitigation2026.dta", replace

*-------------------------------------------------
* 5.4 Sub-technology dataset (CPC 6-digit)
*-------------------------------------------------
use "$datapath/CPC_CCMT_IPC_aligned_2026.dta", clear
keep cpc_code technology tech_6d
duplicates drop
save "$datapath/Y02_SubtechCAT_mitigation.dta", replace

*-------------------------------------------------
* 5.5 Focus subset: Renewable energy technologies
*-------------------------------------------------
use "$datapath/CPC_CCMT_IPC_aligned_2026.dta", clear

* Renewable energy mitigation technologies (Y02E10*)
keep if substr(cpc_code,1,6)=="Y02E10"

label data "Renewable energy mitigation technologies (CPC Y02E10*)"
save "$datapath/Focus_RE_PatstatCAT_mitigation_2026.dta", replace

*-------------------------------------------------
* 5.6 Focus subset: Transport
*-------------------------------------------------
use "$datapath/CPC_CCMT_IPC_aligned_2026.dta", clear

* Transport mitigation technologies (Y02T*)
keep if substr(cpc_code,1,6)=="Y02T"

label data "Transport mitigation technologies (CPC Y02T*)"
save "$datapath/Focus_TR_PatstatCAT_mitigation_2026.dta", replace
*===============================================================================
* End of CPC selection and alignment script
*===============================================================================



