ssc install xtivreg2, replace
cd "C:\Users\hp\Desktop\Aidthesis"



* STEP 1: Load your balanced aid panel to extract the country list
use "balanced_aid_panel_2000_2023.dta", clear

* STEP 2: Save unique countries from the panel
keep country_name
duplicates drop
tempfile panel_countries
save `panel_countries'

* STEP 3: Load V-Dem election dataset
use "electiondata/V-Dem-CY-Full+Others-v15.dta", clear

* STEP 4: Keep only countries from your panel
keep country_name year v2xel_elecpres v2xel_elecpar
merge m:1 country_name using `panel_countries', keep(match) nogen

* STEP 5: Create binary election year indicator
gen election_year = (v2xel_elecpres == 1 | v2xel_elecpar == 1)
replace election_year = 0 if missing(election_year)

* Drop raw election variables if not needed
drop v2xel_elecpres v2xel_elecpar

* STEP 6: Save cleaned, filtered election data
save "electiondata\vdem_election_filtered.dta", replace

* STEP 7: Load aid panel again and merge election data
use "balanced_aid_panel_2000_2023.dta", clear
merge m:1 country_name year using "electiondata\vdem_election_filtered.dta", nogen

* STEP 8: Replace missing election values with 0
replace election_year = 0 if missing(election_year)

* STEP 9: Save final dataset with election info
save "aid_panel_with_elections.dta", replace
