# 260-Project

# Checks and Cities
A salary comparison dashboard and analysis into cost of living and salary data. 


## Data Collection
File: 260 proj data collection.rmd

The cost of living data for this dashboard was collected using webscraping with the 'rvest' and 'httr' packages within R. This data was then cleaned utilizing the tidyverse, and subsequent dplyr funcitons, and will be utilized within the shiny app and other analysis. The current markdown file will not attempt to create this dataset again since it requires assessing the server to pull the data for the cost of living. We do this to be polite, but leave the command in the file commented out. There are files which include "col" in the title for this data. However, either 'full_col_data.csv' and 'col_citydata.csv' are the files generally used in the analysis and shiny app sections.

The wages data for this dashboard was collected from the Bureau of Labor Statistics (BLS) for 50 cities in the United States. The data are accessible online. This data were lightly cleaned and are found as wages_norepeats.csv. 

Both of these datasets are found within the folder for the shiny app, so they will be found when implementing the shiny app. 

## Shiny App
File: savvy salary folder
The dashboard created uses various tabs to guide users towards making a smarter decision with salary information. The following tabs were created:
1) General Salary by City
2) General Salary by Occupation
3) Offer Comparison

The app utilizes not only the use of the shiny package, but also of ggplots2, dplyr, stringr and general tidyverse practices.

### General Salary by City
The 'General Salary by City' tab offers information for the mean salary within certain states. This data uses estimates from the BLS dataset. 

### General Salary by Occupation
The 'General Salary by Occupation' tab plots the mean salary for the occupation of choice across the 50 cities. This is useful to assess which cities offer more competitive salaries for the desired occupation. 

### Offer Comparison
The 'Offer Comparison' tab is useful for comparing salary offers across two cities. Plots included are:
1) the average cost of living in the city of interest which is defined as the sum of: 

    a) 16 inexpensive meals at restaurants (because the average American eats out 4 times a week)
  
    b) apartment cost in city center for one bedroom
  
    c) basic utilities such as electricity, cooling, water, garbage for 915 sq ft apartment
  
    d) internet (speed 60 mbps or more)

2) the average monthly salary for your inputted offer
3) the discretionary income (2-1) after accounting for cost of living
