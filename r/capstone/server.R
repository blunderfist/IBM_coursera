# Install and import required libraries
require(shiny)
require(ggplot2)
require(leaflet)
require(tidyverse)
require(httr)
require(scales)
# Import model_prediction R which contains methods to call OpenWeather API and make predictions
source("model_prediction.R")


test_weather_data_generation <- function(){
  #Test generate_city_weather_bike_data() function
  city_weather_bike_df <- generate_city_weather_bike_data()
  stopifnot(length(city_weather_bike_df)>0)
  print(head(city_weather_bike_df))
  return(city_weather_bike_df)
}

# Create a RShiny server
shinyServer(function(input, output){
  # Define a city list
  
  # Define color factor
  color_levels <- colorFactor(c("green", "yellow", "red"), 
                              levels = c("small", "medium", "large"))
  city_weather_bike_df <- test_weather_data_generation()
  
  cities_max_bike <- city_weather_bike_df %>% 
    group_by(CITY_ASCII, LNG, LAT, BIKE_PREDICTION_LEVEL, DETAILED_LABEL) %>% 
    filter(BIKE_PREDICTION == max(BIKE_PREDICTION))

  pal <- colorFactor(palette = "Blues", 
                     domain = cities_max_bike$BIKE_PREDICTION_LEVEL, 
                     levels = levels(factor(cities_max_bike$BIKE_PREDICTION_LEVEL)),
                     reverse = T)  
  
  # Observe drop-down event
  observeEvent(input$city_select, {
    if(input$city_select != "All"){
      dfw <- city_weather_bike_df %>% filter(CITY_ASCII == input$city_select)
      
      output$city_bike_map <- renderLeaflet({
        df <- cities_max_bike %>% filter(CITY_ASCII == input$city_select)
        df %>%
          leaflet() %>% 
          addProviderTiles("Stamen.Watercolor") %>% 
          addMarkers(lng = df$LNG, 
                     lat = df$LAT,
                     popup = df$DETAILED_LABEL) %>%
          addCircleMarkers(lng = df$LNG, 
                           lat = df$LAT, 
                           color = ~pal(BIKE_PREDICTION_LEVEL),
                           popup = df$DETAILED_LABEL) %>%
          addLegend("topright", pal = pal, values = ~BIKE_PREDICTION_LEVEL, title = "Predicted Bike Demand Level")
      })

      output$temp_line <- renderPlot({
        ggplot(dfw, aes(x = FORECASTDATETIME, y = TEMPERATURE)) +
          geom_point(color = "blue") +
          geom_line(aes(group = CITY_ASCII), color = "yellow") +
          geom_text(aes(label = TEMPERATURE), check_overlap = T) +
          labs(title = "Temperature chart",
               subtitle = "3 hours between each point",
               x = "Forecast (days)",
               y = "Temperature (C)") +
          scale_x_discrete(breaks = dfw$FORECASTDATETIME[c(T,F,F,F,F,F,F)],
                           labels = seq(0,5,1)) 
      })  
      
      output$bike_line <- renderPlot({
        ggplot(dfw, aes(x = FORECASTDATETIME, y = BIKE_PREDICTION)) +
          geom_point(color = "green") +
          geom_line(aes(group = CITY_ASCII), color = "blue") +
          geom_text(aes(label = BIKE_PREDICTION)) +
          labs(title = "Bike prediction chart",
               subtitle = "3 hours between each point",
               x = "Forecast (days)",
               y = "Predicted Bike Demand") +
          #theme(axis.text.x = element_text(angle = 90)) +
          scale_x_discrete(breaks = dfw$FORECASTDATETIME[c(T,F,F,F,F,F,F)],
                           labels = seq(0,5,1)) 
      })  
      
      output$bike_date_output <- renderText({
        if(is.null(input$plot_click)){
          return("Click a point to display it's values here")
        }else{
          paste0("Date Time = ", as.Date(input$plot_click$x, origin = Sys.Date()), "\n", 
               "Bike Preduction = ", round(input$plot_click$y, 1))
        }
      })
      
      output$humidity_pred_chart <- renderPlot({
        ggplot(dfw, aes(x = HUMIDITY, y = BIKE_PREDICTION)) +
          geom_point(color = "purple") +
          geom_smooth(method = 'lm', formula = y ~ poly(x, 4), color = "red") +
          labs(title = "Bike prediction chart",
               x = "Humidity",
               y = "Predicted Bike Demand") +
          theme(axis.text.x = element_text(angle = 90)) 
      })  
      
    }else{
  output$city_bike_map <- renderLeaflet({
    cities_max_bike %>% 
      leaflet() %>% 
      addProviderTiles("Stamen.Watercolor") %>% 
      addCircleMarkers(lng = cities_max_bike$LNG, 
                       lat = cities_max_bike$LAT, 
                       color = ~pal(BIKE_PREDICTION_LEVEL),
                       popup = cities_max_bike$DETAILED_LABEL) %>%
      addLegend("topright", pal = pal, values = ~BIKE_PREDICTION_LEVEL, title = "Predicted Bike Demand Level")
    })
      }
  })
  
})
