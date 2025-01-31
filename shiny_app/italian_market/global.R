library(arrow)
library(tidyverse)
library(shiny)
library(shinyWidgets)
library(glue)
library(forecast)
library(maps)
library(lubridate)
library(shinydashboard)
library(plotly)
library(DT)
library(magick)
library(leaflet)

market_df <- read_parquet('../../../data/pasta_df.parquet')

market_df <- market_df |> 
  separate(date, c('date', 'hour'), sep = ' ') |> 
  mutate(date = ymd(date)) |> 
  mutate(date = (date + 1))

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
                       minute(seconds_to_period(time))))

header_img <- tags$img(
  src='https://upload.wikimedia.org/wikipedia/commons/0/03/Flag_of_Italy.svg',
  style = 'height: 50px; width: 224px; position: floating; left: -20%; transform: translateX(-50%);',
  alt = 'Italian Market'
)
header <-  htmltools::tagQuery(dashboardHeader(title = ""))
header <- header$
  addAttrs(style = "position: relative")$ # add some styles to the header 
  find(".navbar.navbar-static-top")$ # find the header right side
  append(header_img)$ # inject our img
  allTags()
