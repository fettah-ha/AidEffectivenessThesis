* STEP 1: Load raw merged dataset
import delimited "merged_aid_outcome_data.csv", clear

* STEP 2: Create obs_value and drop incomplete rows
gen obs_value = real(aidamount)
drop if missing(country_name, donar, measure, year)

* STEP 3: Save unique values for country, donor, and measure
levelsof country_name, local(countries)
levelsof donar, local(donors)
levelsof measure, local(measures)

* STEP 4: Create full year list (2000–2023)
clear
set obs 24
gen year = 1999 + _n
tempfile all_years
save `all_years', replace

* STEP 5: Build full panel grid (country × donor × measure × year)
clear
tempfile panel_grid
save `panel_grid', emptyok

foreach c of local countries {
    foreach d of local donors {
        foreach m of local measures {
            use `all_years', clear
            gen country_name = "`c'"
            gen donar = "`d'"
            gen measure = "`m'"
            append using `panel_grid'
            save `panel_grid', replace
        }
    }
}

* STEP 6: Prepare original data for merging
import delimited "merged_aid_outcome_data.csv", clear
gen obs_value = real(aidamount)
drop if missing(year)
keep country_name donar measure year obs_value

collapse (sum) obs_value, by(country_name donar measure year)

* STEP 7: Merge full grid with actual data and fill missing obs_value
merge 1:1 country_name donar measure year using `panel_grid', nogen
replace obs_value = 0 if missing(obs_value)

* STEP 8: Extract country-year-level outcomes (preserve panel!)
preserve
import delimited "merged_aid_outcome_data.csv", clear

keep country_name year ///
    accesstoelectricityofpopulation ///
    individualsusingtheinternetofpop ///
    lifeexpectancyatbirthtotalyears ///
    povertyheadcountratioat215aday20 ///
    governmentexpenditureoneducation ///
    grosscapitalformationofgdp

duplicates drop country_name year, force
tempfile outcomes
save `outcomes', replace
restore

* STEP 9: Merge outcomes into the full panel
merge m:1 country_name year using `outcomes', nogen

* STEP 10: Save final balanced panel
save "balanced_aid_panel_2000_2023.dta", replace
