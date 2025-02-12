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

# Reads in my two data sets used. Full_Data has weather and rain data attached
# while combo_data is the data used to figure out the pairs of products that occur
# the most frequently together

full_data <- read_parquet('data/full_data.parquet')
# May have to adjust the directory to wherever you store the data 
combo_data <- read_csv('data/combo_df.csv')

# Fixes full_data as R undoes a lot of time series fixes made in Python
# Creating a new minute column to allow for a poisson analysis.
# The filters are to remove all refund transactions, which are marked as negative
# in the data

full_data <- full_data |> 
  separate(date, c('date', 'hour'), sep = ' ') |> 
  mutate(date = ymd(date) + 1) |> 
  mutate(minute = as.ITime(hms::hms(seconds_to_period(time))), .after = 'time') |> 
  filter(qty > 0) |> 
  filter(net_total > 0) |> 
  select(-hour)

# Chunk of confusing code that allows for the Italian flag to be taken off of the
# Wiki page and displayed here. I figured this out before making my www folder so I
# left it as is. 

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

# First function to be used, this allows for the calculation of the amount of product
# purchased at any given time frame or market.
# Four if statements are used to account for all possible conditions.

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

# Second function, this one allows for the calculation of the sum of net sales for 
# a given time frame for a selected product.
# Same four if statements are used for conditions.

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


# Third function present is used to count how often two products are purchased 
# together. Uses combo_data to find pairs.

product_friends <- function(product) {
  data <- combo_data |> 
    filter(item1 == product) |> 
    select(c(count, item1, item2)) |> 
    arrange(desc(count)) |> 
    select(-item1) |> 
    head(1)
  
} 

# First plotting function. This one generates a line plot with three lines representing
# net sales data, rain in inches, and median temperature for any given time frame
# and product. This allows for the user to see whether rain or temp have an effect
# on the sales of the product(s).

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
  
  # Actual plot of the function.
  
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

# Second plotting function, allows for the user to view a plot of a poisson regression
# showing the probability that a number of transactions will occur within a 30 minute
# period of time.

poisson_plot <- function(date1, date2, market) {
  
  week_day <- full_data |> 
    select(date, weekday) |> 
    mutate(date = as.character(date))
  
  if(market == 'Both') {
    time_interval <- full_data |>
      mutate(date_time = paste(full_data$date, 
                               full_data$minute, 
                               sep=' ')) |> 
      mutate(interval = floor_date(as.POSIXct(date_time), '30 minutes')) |> 
      group_by(interval) |>
      count(transaction_id) |>
      summarize(total = sum(n()))  |> 
      separate_wider_delim(interval, delim = ' ', names = c('date', 'hour_and_min')) |> 
      right_join(week_day, 
                 by ='date', 
                 relationship = "many-to-many") |> 
      filter(date >= as.Date(date1),
             date <= as.Date(date2))
  }
    
    if(market == 'Tuesday') {
      time_interval <- full_data |> 
        mutate(date_time = paste(full_data$date, 
                                 full_data$minute, 
                                 sep=' ')) |> 
        mutate(interval = floor_date(as.POSIXct(date_time), '30 minutes')) |> 
        group_by(interval) |>
        count(transaction_id) |>
        summarize(total = sum(n()))  |> 
        separate_wider_delim(interval, delim = ' ', names = c('date', 'hour_and_min')) |> 
        right_join(week_day, 
                   by ='date', 
                   relationship = "many-to-many") |>
        filter(date >= as.Date(date1),
               date <= as.Date(date2)) |>
        filter(weekday == market)
    }
    
    if(market == 'Saturday') {
      time_interval <- full_data |> 
        mutate(date_time = paste(full_data$date, 
                                 full_data$minute, 
                                 sep=' ')) |> 
        mutate(interval = floor_date(as.POSIXct(date_time), '30 minutes')) |> 
        group_by(interval) |>
        count(transaction_id) |>
        summarize(total = sum(n()))  |> 
        separate_wider_delim(interval, delim = ' ', names = c('date', 'hour_and_min')) |> 
        right_join(week_day, 
                   by ='date', 
                   relationship = "many-to-many") |>
        filter(date >= as.Date(date1),
               date <= as.Date(date2)) |>
        filter(weekday == market)
    }
    
    lambda <- mean(time_interval$total)
    min <- min(time_interval$total)
    max <- max(time_interval$total)
    
    data <- data.frame(x = min:max, 
                       y = dpois(min:max, lambda = lambda)) 
    
    ggplot(data, aes(x = x, y = y)) +
      geom_bar(stat = "identity", fill = "#008F45") +
      labs(title = glue("Poisson Distribution (λ = {round(lambda, digits=3)}) for the number of transactions in a 30 minute period"), 
           x = "Number of Events", 
           y = "Probability") +
      theme_bw()
  }
  


# rsconnect::deployApp('C:/Users/cavin/Documents/NSS_Projects/R_Studio/pasta_project/italian_market_shiny/shiny_app/italian_market')

# rsconnect::showLogs(appName = "italian_market") # appDir = "C:/Users/cavin/Documents/NSS_Projects/R_Studio/pasta_project/italian_market_shiny/shiny_app/italian_market")
  