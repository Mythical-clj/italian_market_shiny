
# Define UI for application that draws a histogram
fluidPage(
  titlePanel("Italian Market"),
  sidebarLayout(
    sidebarPanel(
      selectInput("item", "Choose a food:",
                  choices = unique(market_df$item)),
      dateRangeInput("dates", "Choose a date range:",
                     start = "2024-01-01",
                     end = "2024-12-31")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel('Food sales by date', plotOutput("food"))
      )
    )
  )
)
