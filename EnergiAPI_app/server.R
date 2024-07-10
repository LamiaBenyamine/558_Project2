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
shinyServer(function(input, output, session) {
    output$logo <- renderImage({
      list(src = "eds-logo.jpeg",
          # content_type = 'image/png',
           alt = "Energi logo")
      }, deleteFile = FALSE)
    
    dataDownload <- eventReactive(input$apply, {
      if(input$endpoint == "forecastPower"){
        energiAPI(data = input$endpoint, startDate = input$start, forecastType = input$forecast)
      } else if(input$endpoint == "productionPower"){
        energiAPI(data = input$endpoint, sortDes = input$sort, productionType = input$production, num = input$num) 
      } else if(input$endpoint == "storageUsage"){
        energiAPI(data = input$endpoint, startDate = input$start, num = input$num)}
    })
    
    output$sumTable <- renderDT({
      dataDownload()
      })
    
    output$downloadFile <- downloadHandler(
      filename = function(){
        paste(input$endpoint,"_export_", Sys.Date(), ".csv", sep="" )
      },
      content = function(filename){
        write.csv(dataDownload(),file)
      }
    )
    
    prodInfo <- energiAPI(data = "productionPower", sortDes = "HourUTC", productionType = "all", num = 0) |>
      mutate(prodType = as.factor(ProductionType))
    forcInfo <- energiAPI(data = "forecastPower", forecastType = "all", startDate = '2024-01-01') |>
      mutate(forcType = as.factor(ForecastType))
    
    
    dataExplore <- eventReactive(input$apply2, {
      if(input$tab == "productionPower"){
        prod_tb <- prodInfo |>
          group_by(prodType) |>
          summarize(mean_CO2 = round(mean(CO2PerkWh),2), mean_SO2 = round(mean(SO2PerkWh),2), .groups = 'drop')
        prod_tb
      } else if(input$tab == "forecastPower"){
        forc_tb <- forcInfo |>
          group_by(forcType) |>
          summarize(mean_forecast = round(mean(ForecastCurrent),2), median_forecast = round(median(ForecastCurrent),2), .groups = 'drop')
        forc_tb
      }
    })
    
    output$dataTable <- DT::renderDT({
      dataExplore()
      
    })     
    output$plot <- renderPlot({
      data <- dataExplore()
      if(input$tab == "forecastPower"){
        f1 <- ggplot(data, aes(x=TimestampUTC, y = mean_forecast)) + geom_line(color="steelblue") +  geom_point(size = 0.5, color = "steelblue") + scale_x_date(date_labels = "%b-%Y") + ylab("Mean forecast MWh") + ggtitle("Time series of Mean Power Forecast") + theme_light() + facet_wrap(~ forcType)
        f1
      } else if (input$tab == "productionPower"){
        p1 <- ggplot(data, aes(x = prodType, y = mean_co2))
        p1 + geom_col() + facet_wrap(~ PriceArea) + theme_light() + ylab("mean CO2 per kWh") + xlab("Production Type") + ggtitle("Mean CO2 values by Production Type, Faceted by Price Area") + theme(axis.text.x=element_text(angle=60, hjust=1)) 
        p1
      }
    })
    

})


