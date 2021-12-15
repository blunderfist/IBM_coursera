if (!require('shiny')) install.packages("shiny")
if (!require('shinythemes')) install.packages("shinythemes")
if (!require('tidyverse')) install.packages("tidyverse")

adult <- read_csv("adult.csv")
names(adult) <- tolower(names(adult))
