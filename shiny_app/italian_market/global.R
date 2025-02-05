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
library(data.table)
library(highcharter)

full_data <- read_parquet('../../../data/full_data.parquet')

full_data <- full_data |> 
  separate(date, c('date', 'hour'), sep = ' ') |> 
  mutate(date = ymd(date) + 1) |> 
  mutate(minute = as.ITime(hms::hms(seconds_to_period(time))), .after = 'time') |> 
  filter(qty > 0) |> 
  filter(net_total > 0) |> 
  select(-hour)

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
    summarize(count = sum(qty)) |> 
    pull(count)
  
  if (product != 'All') {
    product_count <- full_data |> 
      filter(date >= as.Date(date1),
             date <= as.Date(date2)) |>
      filter(item == product) |> 
      summarize(count = sum(qty)) |> 
      pull(count)
  } 
  return(product_count)
}

product_earnings <- function(product, date1, date2) {
  product_earnings <- full_data |> 
    filter(date >= as.Date(date1),
           date <= as.Date(date2)) |> 
    summarize(count = sum(net_sales)) |> 
    pull(count) 
  
  if (product != 'All') {
    product_earnings <- full_data |> 
      filter(date >= as.Date(date1),
             date <= as.Date(date2)) |>
      filter(item == product) |>
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


product_mean <- function(product) {
  data <- expand(full_data, 
                 nesting(transaction_id, 
                         item,
                         net_sales,
                         qty)) |>
    group_by(transaction_id) |> 
    filter(item == product) |>
    pull(qty) |> 
    head(n=1)
  
} 

rain_market_plot <- function(product, date1, date2, market) {
  
  plot_data <- reactive({
    
    full_data <-  full_data |> 
      filter(date >= as.Date(date1),
             date <= as.Date(date2))
    
    if(product != 'All'){
      full_data <- full_data |> 
        filter(date >= as.Date(date1),
               date <= as.Date(date2)) |> 
        subset(item %in% product)
    }
    
    if(market != 'Both'){
      full_data <- full_data |> 
        filter(date >= as.Date(date1),
               date <= as.Date(date2)) |>
        filter(weekday %in% market)
    }
    return(full_data)
  })
  
  plot_data() |> 
    group_by(date) |> 
    summarize(total_sales = sum(net_sales)) |> 
    inner_join(full_data) |> 
    plot_ly(x=~date, 
            colors = c('red', 'blue', 'green')) |>
    add_lines(y= ~`rain_sum (inch)`,
              yaxis='y', 
              color='Rain Fall') |> 
    add_lines(y= ~total_sales, 
              yaxis='y2', 
              color='Daily Sales') |>
    add_lines(y= ~`temperature_2m_max (°F)`,
              yaxis='y3', 
              color='Temperature') |>
    layout(title= list(text = glue('Sales by Rainfall and Temperature for \n {lubridate::wday(date1, label = TRUE)}, {month(date1)}-{day(date1)} to {lubridate::wday(date2, label = TRUE)}, {month(date2)}-{day(date2)}'),
                       x = 0.1),
           yaxis=list(side='left', 
                      showgrid=FALSE,
                      title='Daily Rainfall and Temperature'), 
           yaxis2 = list(side='right',
                         showgrid=FALSE,
                         overlaying='y', 
                         title='Daily Sales'),
           yaxis3 = list(side='left',
                         showgrid=FALSE,
                         overlaying='y'))
  
}


time_interval <- full_data |> 
  mutate(date_time = paste(full_data$date, 
                           full_data$minute, 
                           sep=' ')) |> 
  mutate(interval = floor_date(as.POSIXct(date_time), '10 minutes')) |> 
  group_by(interval) |>
  count(transaction_id) |>
  summarize(total = sum(n()))


poisson_plot <- function(item, date1, date2, time_interval) {
  poisson_data <- full_data
  
  poisson <- dpois(time_interval$interval[1]:time_interval$interval[-1], lambda = 10)
  
  plot_data <- barplot(
    poisson, 
    names.arg = time_range, 
    xlab = 'Time interval in 10 minutes', 
    ylab = 'Probabilities'
  )
  
}

