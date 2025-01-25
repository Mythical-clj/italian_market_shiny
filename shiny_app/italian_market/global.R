library(arrow)
library(tidyverse)
library(shiny)
library(shinyWidgets)
library(glue)

market_df <- read_parquet('../../../data/pasta_df.parquet')

