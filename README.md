# AidEffectivenessThesis
This repository gather all the conducted experiments  to assess the effectiveness of aids on poverty reduction

# Data processing: 
The aid and outcome (kpis) data is scrapped from OECD and WorldBank respectively. The aid data reported the different aid flows from country donor to country receiver per year. and the outcomes data consists of some kpis per country receiving the aids serving as intermediate outcomes of the received aids.
The data processing is done in 4 main steps:
* Step 1: Retrieving the data in csv files format from the 2 data sources (websites) and doing some manual cleaning like fixing some non well formatted caracters, removing useless columns etc ...
* Step 2: Linking the aid data and the outcomes data using the key "country receiver and year" as a joint key. As well as, applying some processing allowing better presentation of the data including: allignment of countries between the two data sets before linking them (e.g: in 1 data the countries were in french and in english in the other. So, to ensure valid merge of the data 1 file should converge to the other): done in the python notebook  Data_Processing_Aid_Outcome.ipynb
* Step 3: Preparing the data with lagged aids. To do so, it was mandatory to make sure that for each pair (receiver, donor) we have data records for all years from 2000 to 2023. That being said, if for a given pair there is no aids given we will create the record to ensure the smooth integration of lags and force the aid amoutn to zero. done in the stata file  Data_Processing_Add_LagAid.do
* Step 4: Scrap the election years of the countries receiving te aids from https://v-dem.net/ and add a column in the resulted data from Step 3 telling if the year the aid was received is corresponding to an election year or not (done in the stata file Data_Processing_Add_ElectionYear.do)

# Modeling the impact of the Aids on the poverty reduction: 
### Model_Baeline_AllAidTypes.do:

* Used the data generated from the second step
* It is a  regression model aiming to measure the effect of 5 diffrent aid types on the poverty reduction while introducing some intermediate outcomes as control variables
* Output: Only the Grants Aid Type has a statistically significant effect on the poverty. Choose to scope the next models on this Grant aid type

### Model_IVREG_LaggedAid.do:
* Used the data generated from the 3rd step
* I included the lagged received add in the previous year as an instrument aiming to catch long term effect (the aid received on t-1 will have an imapct 1 year later)
* Output: The lagged effect reduces the endogenity as described int the thesis (check if I can make it public)

### Model_IVREG_laggedAid_Election.do: 
* Used the data data generated from the 4th step
* i
