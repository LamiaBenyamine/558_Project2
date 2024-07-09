#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    https://shiny.posit.co/
#

# Functions created for the user to select and modify the Energi API endpoints.
source("helpers.R")

library(shiny)

# Define server logic required to draw a histogram
function(input, output, session) {
    output$logo <- renderImage({
      list(src = "eds-logo.jpeg",
          # content_type = 'image/png',
           alt = "Energi logo")
      }, deleteFile = FALSE)
    
    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white',
             xlab = 'Waiting time to next eruption (in mins)',
             main = 'Histogram of waiting times')

    })
    output$sumTable <- renderDT({
      
        if(input$endpoint == "forecastPower"){
          outputData <- energiAPI(data = input$endpoint, startDate = input$start, forecastType = input$forecast)
        } else if(input$endpoint == "productionPower"){
          outputData <- energiAPI(data = input$endpoint, sortDes = input$sort, productionType = input$production, num = input$num) 
        } else if(input$endpoint == "storageUsage"){
          outputData <- energiAPI(data = input$endpoint, startDate = input$start, num = input$num)}
      outputData
      })

}
