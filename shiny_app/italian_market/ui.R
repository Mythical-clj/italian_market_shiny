
fluidPage(
  titlePanel("Italian Market"),
  sidebarLayout(
    sidebarPanel(
      tags$style(type='text/css',
                 ".selectize-dropdown-content{
                 height: 1000px;
                 width: 800px;
                 background-color: #b0c4de;
                 font-size: 12px; line-height: 12px;
                }"),
      selectInput("item", "Choose a food:",
                  choices = c('All', unique(full_data$item)), 
                  selected = unique(full_data$item)[1],
                  multiple = TRUE),
      dateRangeInput("dates", "Choose a date:",
                     start = '2024-01-01',
                     end = '2024-12-31')),
    mainPanel(
      tabsetPanel(
        tabPanel('Food sales by date',
                 fluidRow(
                   column(
                     width = 6,
                     plotOutput("food", 
                                height = '300px')
                   ),
                   column(
                     width = 6,
                     plotOutput('linear',
                                height = '300px')
                   )
                 )
        ),
        tabPanel('Card Payments', plotOutput('card'))
      )
    )
   )
  )