# Helper functions created and used in Shiny App

#Forecasts Power Endpoint function: allows the user to select the start date and the forecast type from the Energi API. Only the current forecast is selected, along with the time stamp when the forecast was generated. The date and time were parsed into different columns.

forecastPower <- function(startDate, forecastType){
  baseURL <- "https://api.energidataservice.dk/dataset/"
  if(forecastType == "all") {
    ep1 <- "Forecasts_Hour?columns=TimestampUTC,PriceArea,ForecastType,ForecastCurrent&start="
    urlID <- paste(baseURL, ep1, startDate, sep = "")
  }
  else {
    ep1 <- "Forecasts_Hour?columns=TimestampUTC,PriceArea,ForecastType,ForecastCurrent&start="
    ep2 <- "&filter={\"ForecastType\":[\""
    ep3 <- "\"]}"
    urlID <- paste(baseURL, ep1, startDate, ep2, forecastType, ep3, sep = "")
  }
  
  parsed <- fromJSON(urlID)
  data_tb <- as_tibble(parsed$records) |>
    mutate(hour = hour(ymd_hms(TimestampUTC)), TimestampUTC = as_date(ymd_hms(TimestampUTC))) |>
    select(TimestampUTC, hour, everything())|> #reorder the columns to put date up front
    group_by(TimestampUTC, hour, PriceArea)
  return(data_tb)
}

#Production Power Endpoint function: allows the user to modify the descending sort variable, production type, and the number of records from the Energi API. Some of the emission columns were selected. The date and time were parsed into different columns.

productionPower <- function(sortDes, productionType, num){
  baseURL <- "https://api.energidataservice.dk/dataset/"
  
  if(productionType == "all") {
    ep1 <- "DeclarationProduction?start=2024-05-01&columns=HourUTC,PriceArea,ProductionType,DeliveryType,CO2PerkWh,SO2PerkWh,NOxPerkWh&sort="
    ep2 <- "%20desc&limit="
    urlID <- paste(baseURL, ep1, sortDes, ep2, num, sep = "")
  }
  else {
    ep1 <- "DeclarationProduction?start=2024-01-01&columns=HourUTC,PriceArea,ProductionType,DeliveryType,CO2PerkWh,SO2PerkWh,NOxPerkWh&filter={\"ProductionType\":[\""
    ep2 <- "\"]}&sort="
    ep3 <- "%20desc&limit="
    urlID <- paste(baseURL, ep1, productionType, ep2, sortDes, ep3, num, sep = "")
  }
  
  parsed <- fromJSON(urlID)
  data_tb <- as_tibble(parsed$records) |>
    mutate(dateUTC = as_date(ymd_hms(HourUTC)), hour = hour(ymd_hms(HourUTC))) |>
    select(dateUTC, hour, 2:6)|> #reorder the columns to put date up front
    group_by(dateUTC, hour, PriceArea)
  return(data_tb)
}

#Storage Utilization Endpoint function: allows the user to input start date and number of records from the Energi API. Gas Day is sorting ascending so the number of records selected is from the date the user selects. Only the total utilization columns are selected.

storageUsage <- function(startDate, num){
  baseURL <- "https://api.energidataservice.dk/dataset/"
  ep1 <- "StorageUtilization?sort=GasDay&start="
  ep2 <- "&limit="
  
  urlID <- paste(baseURL, ep1, startDate, ep2, num, sep = "")
  
  parsed <- fromJSON(urlID)
  data_tb <- as_tibble(parsed$records) |>
    mutate(GasDay = as_date(ymd_hms(GasDay))) |>
    select(GasDay, contains("Total")) #reorder the columns to put date up front
  return(data_tb)
}

#Wrapper API function for the user to select the data endpoint.

energiAPI <- function(data,...){
  if(data == "forecastPower"){
    output <- forecastPower(...)
  }
  else if(data == "productionPower"){
    output <- productionPower(...)
  }
  else if(data == "storageUsage"){
    output <- storageUsage(...)
  }
  else {
    print("ERROR: Please input a valid data argument: forecastPower, productionPower, storageUsage")
    return(NA_real_)
    stop()
  }
  return(output)
}