# edu_obstacles

This repo contains the code I used to analyze data from the 2016 Canadian General Social Survey about obstacles students face in obtaining higher education. 

It appeared as a blog post on my blog, https://rebecca-yang.com/posts/financial-situation-is-greatest-obstacle/. 

## Data 
The 2016 GSS focused on Canadians at Work and Home. 
The data is available to be accessed via the CHASS Data Centre with the proper credentials. I was able to access it as a student at the University of Toronto. 
I downloaded the data for all variables. 

The repo is structured as follows:

## Inputs 
Inputs contain items unchanged from their original
- work_survey2.csv - the 2016 GSS data downloaded from CHASS in csv format
- labels2.txt - the variable names needed for cleaning 
##  Scripts 
Scripts take in inputs and create outputs 
- gss-2016_cleaning.R - modified cleaning script originally from Rohan Alexander

## Outputs 
Outputs include modifications of the input data and the final report 
- financial_situation.Rmd - final report
- *student_data.csv, the cleaned GSS data should be in here as well 
