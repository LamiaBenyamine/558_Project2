#libraries needed
library(shiny)
library(jsonlite)
library(dplyr)
library(httr)
library(tidyverse)
library(lubridate)
library(DT)
library(ggplot2)
library(GGally)

fluidPage(
    tabsetPanel(
      #details about the data used and the app contents
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
              a(href="https://www.energidataservice.dk/tso-electricity/Forecasts_Hour", h5("Forecast Wind and Solar Power (Forecast Power)")), 
              p("-The forecast valid for the current time. The user inputs are: Start Date, Forecast Type (all, solar, hydro)"),
              a(href= "https://www.energidataservice.dk/tso-electricity/DeclarationProduction#metadata-info", h5("Declaration, Production Types and Emissions (Production Power)")),
              p("-Declaration of production per Price area per hour. The user inputs are: Columns Sort Descending, Production Type (all, ...), Number of records"),
              a(href= "https://www.energidataservice.dk/gas-storage-denmark/StorageUtilization", h5("Gas Storage Utilization (Storage Utilization)")),
              p("-The total stored, injected, and withdrawn gas per day (MWh). The user inputs are: Start Date, and Number of records"),
              em("Note: all dates/times are in UTC time zone"),
              br(),
              em("Denmark is divided in two price areas (bidding zones) divided by the Great Belt. DK1 is west of the Great Belt and DK2 is east of the Great Belt."),
              h2("Data Exploration"),
              p("This page allows the user to specify a combination of variables to summarize. The plot types and summary tables will be customizable."),
              hr(),
              img(src = "https://www.energidataservice.dk/images/eds-logo.png", width = 600, height = 300 )
              
      ),
      tabPanel("Data Download", 
               titlePanel("Data Download"),
               sidebarLayout(
                sidebarPanel(
                  h3("Select the enpoints, modifications, and subsets for the Energi API data"),
                  selectInput("endpoint", "Select an endpoint",
                              choices=list("Forecast Power"="forecastPower", "Production Power"="productionPower", "Storage Utilization"="storageUsage")),
                  # Include conditional panels for user input on data endpoint functions 
                  conditionalPanel(
                    condition = "input.endpoint == 'forecastPower'",
                      dateInput("start", "Choose Start Date", value = "2024-05-01"),
                      radioButtons("forecast", "Select Forecast Type",
                                         choices = list("All Forecast Types" = "all", "Solar Power" = "Solar", "Offshore Wind Power" = "Offshore%20Wind", "Onshore Wind Power" = "Onshore%20Wind"))),
                  conditionalPanel(
                    condition = "input.endpoint == 'productionPower'",
                      selectInput("sort", "Select a column to sort by (descending)",
                                  choices=list("Date & Time (UTC)" = "HourUTC", "Price Area" = "PriceArea", "Production Type" = "ProductionType", "Delivery Type" = "DeliveryType", "CO2 per kWh" = "CO2PerkWh", "SO2 per kWh" = "SO2PerkWh")),
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
                  #display the summary table based on the user inputs
                  h3("Report Output"),
                  
                  fluidRow(
                    #display loading animation
                    shinycssloaders::withSpinner(DTOutput("sumTable"))
                    ),
                  
                  #allow the user to download the results to csv
                  fluidRow(
                    downloadButton("downloadFile", "Export data to csv file.")
                    )
               )
            )
      ),
      tabPanel("Data Exploration", 
               titlePanel("Data Exploration"),
               #add a row for user inputs
               wellPanel(fluidRow(
                 column(3, selectInput("tab", "Select dataset",
                                       choices=list("Forecast Power"="forecastPower", "Production Power"="productionPower"))),
                 column(6, 
                   conditionalPanel(
                     
                       condition = "input.tab == 'productionPower'",
                       selectInput("plotCombos", "Select plot type",
                                   choices=list("Correlation between CO2 and SO2 emissions by Price Area" = "prodCor",
                                                "Mean CO2 values by Production Type, Faceted by Price Area" = "prodArea"))),
                   conditionalPanel(
                     condition = "input.tab == 'forecastPower'", 
                        selectInput("plotCombos", "Select plot type",
                                       choices=list("Mean Power Forecast by Forecast Type and Price Area" = "forcArea",
                                                    "Time series of Mean Power Forecast" = "forcDates"))),
                  ),
                 column(3, strong("Submit button"), br(), actionButton("apply2", "Apply Inputs"))
               )),
              
               #display the plot based on user selection
               fluidRow(
                 h4("Summary Plots"),
                 #display loading animation
                 shinycssloaders::withSpinner(plotOutput("plot"))
                 ),
               
               #display the table based on user selection
               fluidRow(
                 h4("Summary Tables"),
                 DTOutput("dataTable")
               )
    )
)
)