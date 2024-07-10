# 558_Project2
Dynamic UI

ST 558 Project 2
Author: Lamia Benyamine
Submitted: 07/10/2024
------------------------

This app lets the user query different endpoints of an Energy API, allows for personalized subsets of the data to be downloaded, and many customizable visualizations depending on the endpoint selected.  

• A list of packages needed to run the app.
library(shiny)
library(jsonlite)
library(dplyr)
library(httr)
library(tidyverse)
library(lubridate)
library(DT)
library(ggplot2)
library(GGally)

• A line of code that would install all the packages used (so we can easily grab that and run it prior to running your app).
install.packages(c("shiny", "jsonlite", "dyplr", "httr", "tidyverse", "lubridate", "DT", "ggplot2", "GGally"))


• The shiny::runGitHub() code that we can copy and paste into RStudio to run your app.
shiny::runGitHub("https://github.com/LamiaBenyamine/558_Project2.git", "LamiaBenyamine")

*Note*: The plots on the Data Exploration tab might not load the first time you select the plot type. If you click in on the other selection, the plot will render, and then you can go back to the initial selection.