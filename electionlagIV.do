* Load your dataset

cd "C:\Users\hp\Desktop\Aidthesis"

* STEP 1: Load the processed balanced panel
use "aid_panel_with_elections.dta", clear
* STEP 2: Keep only ODA Grants, Disbursements
keep if measure == "ODA Grants, Disbursements"

* STEP 3: Create analysis variables
gen poverty = real(povertyheadcountratioat215aday20)
gen aid = obs_value
replace year = round(year)
gen education_spend = real(governmentexpenditureoneducation)
gen capital_formation = real(grosscapitalformationofgdp)
gen internet_use = real(individualsusingtheinternetofpop)
*rename lifeexpectancyatbirthtotalyears life_expectancy
replace year = round(year)

foreach var in poverty ///
              accesstoelectricityofpopulation ///
              internet_use ///
              education_spend ///
              capital_formation ///
              {
    
    destring `var', replace ignore(" .")
}

* STEP 3b: Fill missing values with last year's value per country
sort country_name year

* Use aliases to avoid long variable name errors
local vars_orig poverty ///
    accesstoelectricityofpopulation ///
    internet_use ///
    education_spend ///
    capital_formation ///


local vars_short pov elec internet edu invest 

local i = 1
foreach orig of local vars_orig {
    local short : word `i' of `vars_short'

    gen `short'_f = .
    by country_name (year): replace `short'_f = `orig'
    by country_name (year): replace `short'_f = `short'_f[_n-1] if missing(`short'_f)

    replace `orig' = `short'_f
    drop `short'_f

    local ++i
}

* STEP 4: Drop missing analysis vars
drop if missing(poverty, aid, education_spend, capital_formation, internet_us)

* STEP 5: Encode fixed effects
encode country_name, gen(country)
encode donar, gen(donor)

* STEP 6: Collapse to 1 row per country-donor-year with all variables
collapse (sum) aid (mean) poverty education_spend capital_formation internet_use (max) election_year  , ///
    by(country donor year)

* STEP 7: Create lag and panel ID
egen panel_id = group(country donor)
xtset panel_id year
sort panel_id year
gen lag_aid = L.aid

* STEP 8: Drop if lag is missing
drop if missing(lag_aid)

* STEP 9: Generate year fixed effects

levelsof year, local(years)

foreach y of local years {
    gen year_`y' = (year == `y')
}

* STEP 10: Run IV regression
gen aid_election = aid * election_year

egen cluster_id = group(country donor)
xtivreg2 poverty (aid = lag_aid) ///
    election_year aid_election education_spend capital_formation internet_use ///
	year_2001 year_2002 year_2003 year_2004 year_2005 year_2006 year_2007 ///
    year_2008 year_2009 year_2010 year_2011 year_2012 year_2013 year_2014 ///
    year_2015 year_2016 year_2017 year_2018 year_2019 year_2020 year_2021 ///
    year_2022 year_2023, fe cluster(cluster_id) first
