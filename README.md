# AidEffectivenessThesis
This repository gather all the conducted experiments  to assess the effectiveness of aids on poverty reduction

# Data processing: 
* The aid and outcome (kpis) data is scrapped from OECD and WorldBank respectively. The aid data reported the different aid flows from country donor to country receiver per year. and the outcomes data consists of some kpis per country receiving the aids serving as intermediate outcomes of the received aids.
* The data processing is done in 3 main steps:
* Step 1: Retrieving the data in csv files format from the 2 data sources (websites) and doing some manual cleaning like fixing some non well formatted caracters, removing useless columns etc ...
* Step 2: Linking the aid data and the outcomes data using the key "country receiver and year" as a joint key. As well as, applying some processing allowing better presentation of the data including: allignment of countries between the two data sets before linking them (e.g: in 1 data the countries were in french and in english in the other. So, to ensure valid merge of the data 1 file should converge to the other): done in the python notebook  Data_Processing_Aid_Outcome.ipynb
* Step 3: Preparing the data with lagged aids. To do so, it was mandatory to make sure that for each pair (receiver, donor) we have data records for all years from 2000 to 2023. That being said, if for a given pair there is no aids given we will create the record to ensure the smooth integration of lags and force the aid amoutn to zero. done in the stata file  Data_Processing_Add_LagAid.do

# Modeling the impact of the Aids on the poverty reduction: 

