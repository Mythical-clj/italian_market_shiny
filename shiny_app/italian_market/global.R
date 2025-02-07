library(arrow)
library(plotly)
library(tidyverse)
library(shiny)
library(shinyWidgets)
library(glue)
library(lubridate)
library(shinydashboardPlus)
library(shinydashboard)
library(dashboardthemes)
library(shinyjs)
library(bslib)
library(data.table)
library(RColorBrewer)

full_data <- read_parquet('../../../data/full_data.parquet')

combo_data <- read_csv('../../../data/combo_df.csv')

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
                                                            style = "color: #008F45", 
                                                            span("Farmer's", 
                                                                 style = "color: white",
                                                                 span("Market", 
                                                                      style = "color: #CA2A36")
                                                            )
),
titleWidth = '350')
)

header <- header$
  addAttrs(style = "position: floating")$ 
  find(".navbar.navbar-static-top")$ 
  append(header_img)$ 
  allTags()



product_count <- function(product, date1, date2, market) {
  
  if (product == 'All' & market == 'Both') {
    product_count <- full_data |> 
    filter(date >= as.Date(date1),
           date <= as.Date(date2)) |> 
    summarize(count = sum(qty)) |> 
    pull(count)
  }
  
  if (product != 'All' & market == 'Both') {
    product_count <- full_data |> 
      filter(date >= as.Date(date1),
             date <= as.Date(date2)) |>
      filter(item == product) |> 
      summarize(count = sum(qty)) |> 
      pull(count)
  }
  
  if  (market != 'Both' & product != 'All') {
    product_count <- full_data |> 
      filter(date >= as.Date(date1),
             date <= as.Date(date2)) |>
      filter(item == product) |> 
      filter(weekday == market) |> 
      summarize(count = sum(qty))
  }  
  
  if  (market != 'Both' & product == 'All') {
    product_count <- full_data |> 
      filter(date >= as.Date(date1),
             date <= as.Date(date2)) |>
      filter(weekday == market) |> 
      summarize(count = sum(qty))
  }  
  return(product_count)
}

product_earnings <- function(product, date1, date2, market) {
  
 if (product == 'All' & market == 'Both') {
   product_earnings <- full_data |> 
     filter(date >= as.Date(date1),
            date <= as.Date(date2)) |> 
     summarize(count = sum(net_sales)) |> 
     pull(count)
 }
 
 if (product != 'All' & market == 'Both') {
   product_earnings <- full_data |> 
     filter(date >= as.Date(date1),
            date <= as.Date(date2)) |>
     filter(item == product) |> 
     summarize(count = sum(net_sales)) |> 
     pull(count)
 }
 
 if  (market != 'Both' & product != 'All') {
   product_earnings <- full_data |> 
     filter(date >= as.Date(date1),
            date <= as.Date(date2)) |>
     filter(item == product) |> 
     filter(weekday == market) |> 
     summarize(count = sum(net_sales)) |> 
     pull(count)
 }  
 
 if  (market != 'Both' & product == 'All') {
   product_earnings <- full_data |> 
     filter(date >= as.Date(date1),
            date <= as.Date(date2)) |>
     filter(weekday == market) |> 
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


product_friends <- function(product) {
  data <- combo_data |> 
    filter(item1 == product) |> 
    select(c(count, item1, item2)) |> 
    arrange(desc(count)) |> 
    select(-item1) |> 
    head(1)
  
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
            colors = c('#787878', '#CA2A36', '#008F45')) |>
    add_lines(y= ~`rain_sum (inch)`,
              yaxis='y', 
              color='Rain Fall') |> 
    add_lines(y= ~total_sales, 
              yaxis='y2', 
              color='Daily Sales') |>
    add_lines(y= ~`temperature_2m_max (°F)`,
              yaxis='y3', 
              color='Temperature') |>
    layout(title= list(text = glue('Sales by Rainfall and Temperature for {lubridate::wday(date1, label = TRUE)}, {month(date1)}-{day(date1)} to {lubridate::wday(date2, label = TRUE)}, {month(date2)}-{day(date2)}'),
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
                         overlaying='y')
    )
}

poisson_plot <- function(market) {
  
  poisson_plot <- reactive({
    
    week_day <- full_data |> 
      select(date, weekday) |> 
      mutate(date = as.character(date))
    
    
    time_interval <- full_data |> 
      mutate(date_time = paste(full_data$date, 
                               full_data$minute, 
                               sep=' ')) |> 
      mutate(interval = floor_date(as.POSIXct(date_time), '10 minutes')) |> 
      group_by(interval) |>
      count(transaction_id) |>
      summarize(total = sum(n()))  |> 
      separate_wider_delim(interval, delim = ' ', names = c('date', 'hour_and_min')) |> 
      right_join(week_day, by ='date')
    
    if(market != 'Both') {
      time_interval <- full_data |> 
        mutate(date_time = paste(full_data$date, 
                                 full_data$minute, 
                                 sep=' ')) |> 
        mutate(interval = floor_date(as.POSIXct(date_time), '10 minutes')) |> 
        group_by(interval) |>
        count(transaction_id) |>
        summarize(total = sum(n()))  |> 
        separate_wider_delim(interval, delim = ' ', names = c('date', 'hour_and_min')) |> 
        right_join(week_day, by ='date') |> 
        filter(weekday == market)
    }
    
  })
  
  lambda <- mean(time_interval$total)
  min <- min(time_interval$total)
  max <- max(time_interval$total)
  
  data <- data.frame(x = min:max, 
                     y = dpois(min:max, lambda = lambda)) 
  
  ggplot(data, aes(x = x, y = y)) +
    geom_bar(stat = "identity", fill = "#008F45") +
    labs(title = glue("Poisson Distribution (λ = {lambda})"), 
         x = "Number of Events", 
         y = "Probability") +
    theme_bw()
}


