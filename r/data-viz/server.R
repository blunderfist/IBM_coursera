# Load libraries
# library(shiny)
# library(tidyverse)

# data
#adult <- read_csv("adult.csv")
# column names to lowercase for convenience 
#names(adult) <- tolower(names(adult))

# Define server logic
shinyServer(function(input, output) {
  
  df_country <- reactive({
    adult %>% filter(native_country == input$country)
  })

  # plot histogram or boxplot
  output$p1 <- renderPlot({
    if (input$graph_type == "histogram") {
      # Histogram
      ggplot(df_country(), aes_string(x = input$continuous)) +
        geom_histogram() +  # histogram geom
        labs(title = paste("Trends for", input$continuous), x = input$continuous, y = "Count") +  # labels
        facet_wrap(~ prediction, nrow = 1)    # facet by prediction
    }
    else {
      # Boxplot
      ggplot(df_country(), aes_string(y = input$continuous)) +
        geom_boxplot() +  # boxplot geom
        coord_flip() +
        labs(title = paste("Trends for", input$continuous), x = input$continuous, y = "Count") +  # labels
        facet_wrap(~ prediction, nrow = 1)    # facet by prediction
    }

  })

  # plot faceted bar chart or stacked bar chart
  output$p2 <- renderPlot({
    # Bar chart
    p <- ggplot(df_country(), aes_string(x = input$categorical)) +
      labs(title = paste("Trends for", input$categorical), x = input$categorical, y = "Count") +  # labels
      theme(legend.position = "bottom", axis.text.x = element_text(angle = 90))

    if (input$is_stacked) {
      p + geom_bar(aes(fill = prediction))  # bar geom
    }
    else{
      p +
        geom_bar(stat = "count", aes_string(fill = input$categorical)) +
        facet_wrap(~ prediction, nrow = 1)   # facet by prediction
    }
  })

})
