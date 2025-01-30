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
