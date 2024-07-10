#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

library(shiny)
library(jsonlite)
library(dplyr)
library(httr)
library(tidyverse)
library(lubridate)
library(DT)

fluidPage(
    tabsetPanel(
      tabPanel("About", 
              h1("Purpose of the EnergiAPI app"),
              p("This app lets the user query different endpoints of the Energi API, allows for personalized subsets of the data to be downloaded, and many customizable visualizations."),
              hr(),
              h1("Data source"),
              p("Energi Data Service is an open energy data source from Energinet. This app accesses data from two organizations in Energinet: Gas Storage Denmark and TSO Electricity."),
              p("Gas Storage Denmark owns and operates two gas storage facilities in Denmark. Energinet is Denmark's transmission system operator (TSO) for electricty. They own and operate the overall electricity and natural gas transmission system in the country to integrate renewable energy and ensure security of supply in Denmark."),
              p("Energinet is an independent public enterprise owned by the Danish Ministry of Energy, Utilities and Climate."),
              a(href = "https://www.energidataservice.dk/", "For more information click this link"),
              hr(),
              h1("Tab Details"),
              h2("Data Download"),
              p("This page allows the user to specify any changes to the Energi API and return the data. The user will also be able to subset the rows and columns of the dataset and save to .csv file."),
              h4("Endpoints"),
              a(href="https://www.energidataservice.dk/tso-electricity/Forecasts_Hour", h5("Forecast Wind and Solar Power")), 
              p("-The forecast valid for the current time. The user inputs are: Start Date, Forecast Type (all, solar, hydro)"),
              a(href= "https://www.energidataservice.dk/tso-electricity/DeclarationProduction#metadata-info", h5("Declaration, Production Types and Emissions")),
              p("-Declaration of production per Price area per hour. The user inputs are: Columns Sort Descending, Production Type (all, ...), Number of records"),
              a(href= "https://www.energidataservice.dk/gas-storage-denmark/StorageUtilization", h5("Storage Utilization")),
              p("-The total stored, injected, and withdrawn Gas per day (MWh). The user inputs are: Start Date, and Number of records"),
              em("Note: all dates/times are in UTC time zone"),
              br(),
              em("Denmark is divided in two price areas (bidding zones) divided by the Great Belt. DK1 is west of the Great Belt and DK2 is east of the Great Belt."),
              h2("Data Exploration"),
              p("This page allows the user to specify a combination of variables to summarize. The plot types and summary tables will be customizable."),
              img(src = "https://www.energidataservice.dk/images/eds-logo.png", width = 600, height = 300 )
              
      ),
      tabPanel("Data Download", 
               titlePanel("Data Download"),
               sidebarLayout(
                sidebarPanel(
                  h3("Select the enpoints, modifications, and subsets for the Energi API data"),
                  selectInput("endpoint", "Select an endpoint",
                              choices=list("Forecast Power"="forecastPower", "Production Power"="productionPower", "Storage Utilization"="storageUsage")),
                  # Include conditional panels for user input on data endpoints
                  conditionalPanel(
                    condition = "input.endpoint == 'forecastPower'",
                      dateInput("start", "Choose Start Date", value = "2024-05-01"),
                      radioButtons("forecast", "Select Forecast Type",
                                         choices = list("All Forecast Types" = "all", "Solar Power" = "Solar", "Offshore Wind Power" = "Offshore%20Wind", "Onshore Wind Power" = "Onshore%20Wind"))),
                  conditionalPanel(
                    condition = "input.endpoint == 'productionPower'",
                      selectInput("sort", "Select a column to sort by (descending)",
                                  choices=list("Date & Time (UTC)" = "HourUTC", "Price Area" = "PriceArea", "Production Type" = "ProductionType", "Delivery Type" = "DeliveryType", "CO2 per kWh" = "CO2PerkWh", "SO2 per kWh" = "SO2PerkWh", "NOx  per kWh" = "NOxPerkWh")),
                      radioButtons("production", "Select Production Type",
                                 choices=list("All Production Types" = "all", "BioGas", "Coal",  "Fossil Oil", "Fossil Gas" = "FossilGas", "Hydro", "Solar", "Straw", "Waste", "Onshore Wind" = "WindOnshore", "Offshore Wind" = "WindOffshore", "Wood" )),
                      numericInput("num", h3("Enter the number of records to output"), 
                                   value=0, min=0, max=100000, step=100),
                    em("Note: 0 is all records")
                  ),
                  conditionalPanel(
                    condition = "input.endpoint == 'storageUsage'",
                    dateInput("start", "Choose Start Date", value = "2024-05-01"),
                    numericInput("num", h3("Enter the number of records to output"), 
                                 value=0, min=0, max=100000, step=100),
                    em("Note: 0 is all records")
                  ),
                  actionButton("apply", "Apply Inputs")
                ),
                mainPanel(
                  h2("Report Output"),
                  DTOutput("sumTable"),
                  
                  downloadButton(
                    "downloadFile", "Export data to csv file.")
               )
            )
      ),
      tabPanel("Data Exploration", 
               titlePanel("Data Exploration"),
               h3("Summarize data from the Declaration, Production Types and Emissions dataset."),
               
                 # Show a plot of the generated distribution
                   
                   fluidRow(
                     h4("Summary Plots"),
                     plotOutput("plot")
                     ),
                   
                   fluidRow(
                     h4("Summary Tables"),
                     fluidRow(
                       column(4, selectInput("tab", "Select dataset",
                                          choices=list("Forecast Power"="forecastPower", "Production Power"="productionPower"))),
                       column(4, "Select categorical variables"),
                       column(4, actionButton("apply2", "Apply Inputs"))
                     ),
                     DTOutput("dataTable")
                   )
    )
)
)