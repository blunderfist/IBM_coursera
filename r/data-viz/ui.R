
# Application Layout
shinyUI(
  fluidPage(
    theme = shinytheme("cerulean"),
    #shinythemes::themeSelector(),
    br(),
    # App title
    titlePanel("Trends in Demographics and Income"),
    p("Explore the difference between people who earn less than 50K and more than 50K. You can filter the data by country, then explore various demogrphic information."),

    # select country    
    fluidRow(
      column(12, 
             wellPanel(selectInput(inputId = "country", "Select Country", 
                                   choices = levels(factor(adult$native_country)),
                                   selected = "United-States"))
             )
    ),
    
    # continuous variables
    fluidRow(
      column(3, 
             wellPanel(
               p("Select a continuous variable and graph type (histogram or boxplot) to view on the right."),
               radioButtons(inputId = "continuous", "Continuous", 
                            choices = c("age", "hours_per_week")),   #  radio buttons for continuous variables
               radioButtons(inputId = "graph_type", "Graph", 
                            choices = c("boxplot", "histogram")),   # radio buttons for continuous variables
               )
             ),
      column(9, plotOutput("p1")) 
    ),
    
    # categorical variables
    fluidRow(
      column(3, 
             wellPanel(
               p("Select a categorical variable to view bar chart on the right. Use the check box to view a stacked bar chart to combine the income levels into one graph. "),
               radioButtons(inputId = "categorical", "Categorical", 
                            choices = c("education", "workclass","sex")),   # radio buttons for continuous variables,    # add radio buttons for categorical variables
               checkboxInput("is_stacked", "Stack Bar Charts")     # check box input for stacked bar chart option
               )
             ),
      column(9, plotOutput("p2"))
    )
  )
)
