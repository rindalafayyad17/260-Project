# 260-Project
#### Authors: Rindala Fayyad, Daniel Herrera, Nona Jiang, Yuning Liu, Mengyao Zheng

# Checks and Cities

A salary comparison dashboard and analysis into cost of living and salary data. 

The files should be looked at in the order described below:

## Description

File: Description.Rmd 

This file contains information about the project overview and motivation, objectives, related work, initial questions, data, exploratory analysis, and final analysis. However, details about Data collection, EDA and Final analyses can be found in their respective files. 

## Data Collection and Cleaning

File: 260 proj data collection.rmd

This file starts by describing our project and stating our goals and objectives. 

The cost of living (COL) data for this dashboard was collected using webscraping with the 'rvest' and 'httr' packages within R from numbeo.com. This process was done first for a  subset of some important COL metrics and again to extract more COL metrics for each city, resulting in the 'fulldata.csv' file.  These datasets were then cleaned utilizing the tidyverse and subsequent dplyr functions,resulting in the 'col_citydata.csv' for the subset and 'full_col_data.csv' for the full dataset. The dataset 'ful_col_data.csv' was utilized for the shiny app, while a combination of 'col_citydata' and 'full_col_data' was utilized for the analysis.

The current markdown file will not attempt to create the COL datasets again since it requires accessing the server to pull the data for the cost of living. We do this to be polite, but leave the command in the file commented out. There are files which include "col" in the title for this data. 

The wages data for this dashboard was collected from the Bureau of Labor Statistics (BLS) for 50 cities in the United States. The data are accessible online. The inital data is stores as 'wages.csv'. This data was then lightly cleaned, removing special charaters and keeping only unique rows for city/occupations, resulting in the dataset 'wages_norepeats.csv'. Strictly for aesthetic reasons in the ggplot of the shinyapp, 'cleaned_occupations.csv' removed the "all others" found in some occupation names. 


## EDA

File: EDA.Rmd

We first looked at the relationship between the average monthly salary in a city and different predictor variables. Multiple scatter plots were done to get a first glance at the relationship between average monthly net salary and other variables such as apartment price in city center, apartment price outside of the center, cost of basic utilities, price of 1 gallon of gasoline, price of an inexpensive meal, price of the internet, price of a meal and McDonalds, price of a meal for two, and a yearly tuition for a child and an international primary school. 

We then looked at the distribution of the price of an inexpensive meal and how that price varies in different cities. 

We also looked at the relationship between a McMeal at Mcdonalds and the average monthly net salary per city. This plot was also able to tell us which cities had the highest cost of a McMeal and Mcdonalds. 

We then looked at the distribution of the apartment prices in the centers of the cities. We noticed that there were outliers, so we plotted a 1D graph showing the apartment price in the city center of each city, and were able to determine what cities correspond to these outliers.

We then looked at the relationship between the apartment price in the city center and all the different predictor variables mentioned above. 

We then plotted the average salary vs average living expenses in each city, and the relationship that we got did not surprise us: the higher the living expenses, the higher the salary. 


## WordClouds

File: WordClouds.Rmd, wordcloud folder and tmp_files folder


First, at the national level, we created a wordcloud for the occupations with salaries higher than the 95th percentile in the 50 cities. The wordcloud picture was stored as total.png in the wordcloud folder.

Then, We would like to investigate whether there is difference among the high-paying jobs in different cities in the USA. Thus, we created the wordcloud for the high-paying jobs in different cities. The wordcloud pictures were stored in the wordcloud folder, named after the city name. tmp.html is the temporary html file created for converting the interactive wordcloud to a static picture.

In the tmp_files folders, there are some JavaScript files needed by running the wordcloud2 packages.


## Analysis

File: Analysis.Rmd

This folder contains some additional data analysis and regressions.

#### Predicting Average Monthly Net Salary

We performed a linear regression model to predict the average monthly net salary, but we only included as predictors the variables with which average monthly net salary had a linear relationship (we looked at the relationships in the EDA file)

We then created a Decision Tree using rpart, in another attempt to predict the average monthly next salary based on other variables.

#### Predicting Apartment Price in the City Center

We also performed linear regression model to predict the apartment price in the city center. We pick the predictor based on the graph in EDA file and choose the predictor has clear relationship. 

We used gradient boosting trees algorithm to test the relevance of each predicted variables and test the importance of each variables and compared with the importance level with the result from regression models.


## Shiny App
File: savvy salary folder

The dashboard created uses various tabs to guide users towards making a smarter decision with salary information. The following tabs were created:
1) General Salary by City
2) General Salary by Occupation
3) Offer Comparison

The app utilizes not only the use of the shiny package, but also of ggplots2, dplyr, stringr and general tidyverse practices.

#### General Salary by City
The 'General Salary by City' tab offers information for the mean salary within certain states. This data uses estimates from the BLS dataset. 

#### General Salary by Occupation
The 'General Salary by Occupation' tab plots the mean salary for the occupation of choice across the 50 cities. This is useful to assess which cities offer more competitive salaries for the desired occupation. 

#### Offer Comparison
The 'Offer Comparison' tab is useful for comparing salary offers across two cities. Plots included are:
1) the average cost of living in the city of interest which is defined as the sum of: 

    a) 16 inexpensive meals at restaurants (because the average American eats out 4 times a week)
  
    b) apartment cost in city center for one bedroom
  
    c) basic utilities such as electricity, cooling, water, garbage for 915 sq ft apartment
  
    d) internet (speed 60 mbps or more)

2) the average monthly salary for your inputted offer
3) the discretionary income (2-1) after accounting for cost of living


