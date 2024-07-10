# Functions created for the user to select and modify the Energi API endpoints.
source("helpers.R")

library(shiny)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
   ## About Tab  
    #Including the API company's logo
    output$logo <- renderImage({
      list(src = "eds-logo.jpeg",
          # content_type = 'image/png',
           alt = "Energi logo")
      }, deleteFile = FALSE)
    
  ## Download Tab  
    #Select the data from the API based on user inputs and the 'apply' button pressed
    dataDownload <- eventReactive(input$apply, {
      #display loading animation
      Sys.sleep(1.5)
      if(input$endpoint == "forecastPower"){
        energiAPI(data = input$endpoint, startDate = input$start, forecastType = input$forecast)
      } else if(input$endpoint == "productionPower"){
        energiAPI(data = input$endpoint, sortDes = input$sort, productionType = input$production, num = input$num) 
      } else if(input$endpoint == "storageUsage"){
        energiAPI(data = input$endpoint, startDate = input$start, num = input$num)}
    })
    
    #Display the data based on the dataDownload conditions after the 'apply' button is pressed
    output$sumTable <- renderDT({
      dataDownload()
      })
    
    #Allow the user to download the data from the table rendered
    output$downloadFile <- downloadHandler(
      filename = function(){
        paste(input$endpoint, "_export_", Sys.Date(), ".csv", sep="" )
      },
      content = function(file){
        write.csv(dataDownload(), file, row.names = FALSE)
      })
    outputOptions(output, "downloadFile", suspendWhenHidden = FALSE)
    
  ## Explore tab  
    #Create global data tables with standard inputs for the visualizations
    prod <- reactive({
      prodInfo <- energiAPI(data = "productionPower", sortDes = "HourUTC", productionType = "all", num = 30000) |>
        mutate(prodType = as.factor(ProductionType))
    })
    forc <- reactive({
      forcInfo <- energiAPI(data = "forecastPower", forecastType = "all", startDate = '2024-01-01') |>
        mutate(forcType = as.factor(ForecastType))
    })
    
    #Select the API dataset based on user inputs and create summary variables after the 'apply2' button is pressed
    dataExplore <- eventReactive(input$apply2, {
      if(input$tab == "productionPower"){
        prod_tb <- prod() |>
          group_by(prodType, PriceArea) |>
          summarize(mean_co2 = round(mean(CO2PerkWh),2), mean_so2 = round(mean(SO2PerkWh),2), .groups = 'drop')
        prod_tb
      } else if(input$tab == "forecastPower"){
        forc_tb <- forc() |>
          group_by(forcType, TimestampUTC) |>
          summarize(mean_forecast = round(mean(ForecastCurrent),2), median_forecast = round(median(ForecastCurrent),2), .groups = 'drop')
        forc_tb
      }
    })
    
    #Display the data based on the dataExplore conditions after the 'apply2' button is pressed
    output$dataTable <- DT::renderDT({
      dataExplore()
    }) 
    
    #Output plot based on the user inputs
    output$plot <- renderPlot({
      plotData <- dataExplore()
        #forecast power plots
      #display loading animation
       Sys.sleep(1.5)
        if(input$tab == "forecastPower" && input$plotCombos == "forcDates") {
        f1 <- ggplot(data = dataExplore(), aes(x=TimestampUTC, y = mean_forecast)) 
        f1 + geom_line(color="steelblue") +  geom_point(size = 0.5, color = "steelblue") + 
          scale_x_date(date_labels = "%b-%Y") + ylab("Mean forecast MWh") + 
          ggtitle("Time series of Mean Power Forecast") + theme_light() + 
          facet_wrap(~ forcType)
      } else if(input$tab == "forecastPower" && input$plotCombos == "forcArea") {
        f2 <- ggplot(data = forc() |> mutate(meanForecast = round(mean(ForecastCurrent))) |> group_by(forcType, PriceArea), 
                    aes(x = forcType, y = meanForecast, fill = PriceArea))
        f2 + geom_col() + ggtitle("Mean Power Forecast by Forecast Type and Price Area") + 
          ylab("Mean forecast MWh") + xlab("Forecast Type") + theme_light()
      } #production power plots
        else if (input$tab == "productionPower" && input$plotCombos == "prodArea") {
        p1 <- ggplot(data = dataExplore(), aes(x = prodType, y = mean_co2))
        p1 + geom_col() + facet_wrap(~ PriceArea) + 
          ylab("mean CO2 per kWh") + xlab("Production Type") + 
          ggtitle("Mean CO2 values by Production Type, Faceted by Price Area") + 
          theme(axis.text.x=element_text(angle=60, hjust=1)) + theme_light()
      } else if (input$tab == "productionPower" && input$plotCombos == "prodCor") {
        p2 <- ggpairs(prod(), columns = 6:7, ggplot2::aes(color=PriceArea)) 
        p2 + ggtitle("Correlation between CO2 and SO2 emissions by Price Area")
      }
    })
})