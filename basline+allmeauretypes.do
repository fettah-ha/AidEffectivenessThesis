

* STEP 1: Load the dataset
*import delimited "merged_aid_outcome_data.csv", clear
import delimited "merged_aid_loan_grant_outcome_data", clear

* STEP 2: Generate numeric variables
gen poverty = real(povertyheadcountratioat215aday20)
gen aid = real(aidamount)
gen education_spend = real(governmentexpenditureoneducation)
gen capital_formation = real(grosscapitalformationofgdp)
gen internet_use = real(individualsusingtheinternetofpop)



* STEP 3: Drop observations with missing core variables
drop if missing(poverty, education_spend, capital_formation, internet_use, aidamount, measure)

* STEP 4: Encode IDs
encode country_name, gen(country)
encode donar, gen(donor)

* STEP 5: Clean the measure type for naming
gen measure_clean = lower(measure)
replace measure_clean = subinstr(measure_clean, " ", "_", .)
replace measure_clean = subinstr(measure_clean, "'", "", .)
replace measure_clean = subinstr(measure_clean, ",", "", .)
replace measure_clean = subinstr(measure_clean, "%", "pct", .)
replace measure_clean = subinstr(measure_clean, "/", "_", .)
gen measure_short = substr(measure_clean, 1, 20)

* STEP 6: Save controls before reshape
preserve
collapse (mean) poverty education_spend capital_formation internet_use, ///
    by(country donor year)
tempfile controls
save `controls'
restore

* STEP 7: Prepare for reshape
gen aid_value = real(aidamount)
collapse (sum) aid_value, by(country donor year measure_short)

* STEP 8: Reshape to wide format
reshape wide aid_value, i(country donor year) j(measure_short) string

* STEP 9: Replace missing aid types with 0
foreach var of varlist aid_value* {
    replace `var' = 0 if missing(`var')
}

* STEP 10: Merge controls back
merge 1:1 country donor year using `controls', nogen

* STEP 11: Run regression with fixed effects
ssc install reghdfe, replace
reghdfe poverty aid_value* education_spend capital_formation internet_use, ///
    absorb(country donor year) vce(cluster country)
