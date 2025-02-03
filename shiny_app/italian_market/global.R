library(arrow)
library(plotly)
library(tidyverse)
library(shiny)
library(shinyWidgets)
library(glue)
library(forecast)
library(lubridate)
library(shinydashboardPlus)
library(shinydashboard)
library(DT)
library(dashboardthemes)
library(shinyjs)
library(bslib)


market_df <- read_parquet('../../../data/pasta_df.parquet')

market_df <- market_df |> 
  separate(date, c('date', 'hour'), sep = ' ') |> 
  mutate(date = ymd(date)) |> 
  mutate(date = (date + 1)) |> 
  mutate(item = str_replace_all(string = item,
                                pattern = c('Extruded HP' = 'Pasta',
                                            'Drank!!' = 'Strawberry Lemonade',
                                            'Lasagna (Meat)' = 'Meat Lasagna',
                                            'Vodka Sauce (Small)' = 'Small Vodka Sauce',
                                            'Vodka Sauce Add On (Large)' = 'Large Vodka Sauce')))

weather <- read_csv("../../../data/open-meteo-36.00N86.02W204m.csv", skip = 3)

weather <- weather |> 
  select(time, `rain (inch)`) |> 
  separate(time, c('date', 'hour'),sep = " ") |> 
  mutate(date = ymd(date)) |> 
  mutate(weekday = wday(date, label = TRUE))

weather_clean <- weather |> 
  filter(weekday == c('Sat', 'Tue')) |> 
  group_by(date) |> 
  summarize(rainfall = sum(`rain (inch)`))

full_data <- market_df |> right_join(weather_clean, by = join_by(date))

full_data <- full_data |> 
  mutate(time = paste(hour((seconds_to_period(time))), 
                      minute(seconds_to_period(time)))) |> 
  filter(qty > 0) |> 
  filter(net_total > 0)

header_img <- tags$header(
  style = 'background-image: url("https://upload.wikimedia.org/wikipedia/commons/0/03/Flag_of_Italy.svg");
  background-color: #ECECEC;
  background-size: 100px;
  background-repeat: space;
  border: 2px #ECECEC;
  height: 50px; 
  width: auto;'
)

header <-  htmltools::tagQuery(dashboardHeader(title = span("Italian", 
                                                            style = "color: green", 
                                                            span("Farmer's", 
                                                                 style = "color: white",
                                                                 span("Market", 
                                                                      style = "color: red")
                                                            )
),
titleWidth = '350')
)

header <- header$
  addAttrs(style = "position: floating")$ 
  find(".navbar.navbar-static-top")$ 
  append(header_img)$ 
  allTags()

product_count <- function(product, date1, date2) {
  product_count <- full_data |> 
    filter(date >= as.Date(date1),
           date <= as.Date(date2)) |> 
    group_by(item) |> 
    summarize(count = sum(qty)) |> 
    pull(count)
  if (product != 'All') {
    product_count <- full_data |> 
      filter(date >= as.Date(date1),
             date <= as.Date(date2)) |>
      filter(item == product) |> 
      group_by(item) |> 
      summarize(count = sum(qty)) |> 
      pull(count)
  } 
  return(product_count)
}

product_earnings <- function(product, date1, date2) {
  product_earnings <- full_data |> 
    filter(date >= as.Date(date1),
           date <= as.Date(date2)) |> 
    group_by(item) |> 
    summarize(count = sum(net_sales)) |> 
    pull(count) 
    
  if (product != 'All') {
    product_earnings <- full_data |> 
      filter(date >= as.Date(date1),
             date <= as.Date(date2)) |>
      filter(item == product) |> 
      group_by(item) |> 
      summarize(count = sum(net_sales)) |> 
      pull(count) 
  }
  product_earnings <- 
    paste0('$',
           format(product_earnings, 
                  big.mark=',', 
                  scientific=FALSE))
  return(product_earnings)
}

rain_market_plot <- function(item, date1, date2, check) {
  
  plot_data <- reactive({
    
    full_data <-  full_data |> 
      filter(date >= as.Date(date1),
             date <= as.Date(date2))
    
    if(item != 'All'){
      full_data <- full_data |> 
        subset(item %in% item)
    }
    return(full_data)
    
    if (check == TRUE){
      full_data <- full_data |> 
        filter(date == as.Date(date1)) 
    }
    return(full_data)
  })
  
  plot_data() |> 
    group_by(date) |> 
    summarize(total_sales = sum(net_sales)) |> 
    inner_join(weather_clean) |> 
    plot_ly(x=~date, 
            colors = c('red', 'blue')) |>
    add_lines(y= ~rainfall,
              yaxis='y', 
              color='Rain Fall') |> 
    add_lines(y= ~total_sales, 
              yaxis='y2', 
              color='Daily Sales') |>
    layout(title= list(text = glue('Sales by Rainfall for \n {wday(date1, label = TRUE)}, {month(date1)}-{day(date1)} to {wday(date2, label = TRUE)}, {month(date2)}-{day(date2)}'),
                       x = 0.1),
           yaxis=list(side='left', 
                      showgrid=FALSE,
                      title='Daily Rainfall'), 
           yaxis2 = list(side='right', 
                         overlaying='y', 
                         title='Daily Sales'))
  
}

