dashboardPage(
  header,
  dashboardSidebar(
    sidebarMenu(id = 'tabs',
                menuItem("Summary", 
                         tabName = "FoodTab",
                         icon = icon("wheat-awn")),
                menuItem("Exploration",
                         tabName = "CardTab",
                         icon = icon("fa-solid fa-dollar-sign")),
                menuItem('Models',
                         tabName = 'linear_reg',
                         icon = icon("line-chart")),
                menuItem('Conclusion',
                         tabName = 'rainSales')
                
    )
  ),
  dashboardBody(
    tags$head( 
      tags$style(HTML('.main-header .logo { 
      font-family: "Times New Roman"; 
                      width: auto; 
                      font-size: 180%;
                      font-weight: Bold;
                      position: relative;
                      text-align: left;
                      }')
                 
      )
    ),
    shinyDashboardThemes(
      theme = "grey_light"
    ),
    
    tabItems(
      tabItem(tabName = "FoodTab",
              fluidRow(
                column(2,
                       selectInput("item", "Choose a product:",
                                   choices = c('All', unique((full_data$item))), 
                                   selected = c('All'),
                                   multiple = FALSE)
                ),
                column(2,
                       dateInput("date1", "Choose a start date:",
                                 min = '2024-01-02',
                                 max = '2024-12-31',
                                 value = '2024-01-02',
                                 format = 'mm/dd/yy',
                                 weekstart = 0,
                                 daysofweekdisabled = c(0,1,3,4,5)),
                       tags$style(HTML(".datepicker {z-index:99999 !important;}"))
                ),
                column(2,
                       dateInput("date2", "Choose an end date:",
                                 min = '2024-01-02',
                                 max = '2024-12-31',
                                 value = '2024-12-31',
                                 format = 'mm/dd/yy',
                                 weekstart = 0,
                                 daysofweekdisabled = c(0,1,3,4,5)),
                       tags$style(HTML(".datepicker {z-index:99999 !important;}")
                       )
                ),
                column(2,      
                       selectInput('market', 'choose a market',
                                   choices = c('Both', unique(full_data$weekday)))
                )
              ),
              fluidRow(
                column(12,
                       valueBoxOutput('count'),
                       valueBoxOutput('earnings'),
                       valueBoxOutput('mean')
                )
              )
      ),
      
      tabItem(tabName = 'linear_reg',
              fluidRow(
                column(2,
                       selectInput("item", "Choose a product:",
                                   choices = c('All', unique((full_data$item))), 
                                   selected = c('All'),
                                   multiple = FALSE)
                ),
                column(2,
                       dateInput("date1", "Choose a start date:",
                                 min = '2024-01-02',
                                 max = '2024-12-31',
                                 value = '2024-01-02',
                                 format = 'mm/dd/yy',
                                 weekstart = 0,
                                 daysofweekdisabled = c(0,1,3,4,5)),
                       tags$style(HTML(".datepicker {z-index:99999 !important;}"))
                ),
                column(2,
                       dateInput("date2", "Choose an end date:",
                                 min = '2024-01-02',
                                 max = '2024-12-31',
                                 value = '2024-12-31',
                                 format = 'mm/dd/yy',
                                 weekstart = 0,
                                 daysofweekdisabled = c(0,1,3,4,5)),
                       tags$style(HTML(".datepicker {z-index:99999 !important;}")
                       )
                ),
                column(2,      
                       selectInput('market', 'choose a market',
                                   choices = c('Both', unique(full_data$weekday)))
                ),
                column(8,
                       plotlyOutput('linear', 
                                    height = '300px')
                )
              )
      ),
      
      tabItem(tabName = "CardTab", 
              fluidRow(
                column(2,
                       selectInput("item", "Choose a product:",
                                   choices = c('All', unique((full_data$item))), 
                                   selected = c('All'),
                                   multiple = FALSE)
                ),
                column(2,
                       dateInput("date1", "Choose a start date:",
                                 min = '2024-01-02',
                                 max = '2024-12-31',
                                 value = '2024-01-02',
                                 format = 'mm/dd/yy',
                                 weekstart = 0,
                                 daysofweekdisabled = c(0,1,3,4,5)),
                       tags$style(HTML(".datepicker {z-index:99999 !important;}"))
                ),
                column(2,
                       dateInput("date2", "Choose an end date:",
                                 min = '2024-01-02',
                                 max = '2024-12-31',
                                 value = '2024-12-31',
                                 format = 'mm/dd/yy',
                                 weekstart = 0,
                                 daysofweekdisabled = c(0,1,3,4,5)),
                       tags$style(HTML(".datepicker {z-index:99999 !important;}")
                       )
                ),
                column(2,      
                       selectInput('market', 'choose a market',
                                   choices = c('Both', unique(full_data$weekday)))
                )
              ),
              fluidRow(
                column(6,
                       plotlyOutput("food", 
                                    height = '300px')
                ),
                column(6,
                       plotlyOutput('card')
                )
              ),
              fluidRow(
                column(12,
                       plotlyOutput('rain')
                )
              )
      ),
    
    tabItem(tabName = 'rainSales',
            fluidRow(
              column(2,
                     selectInput("item", "Choose a product:",
                                 choices = c('All', unique((full_data$item))), 
                                 selected = c('All'),
                                 multiple = FALSE)
              ),
              column(2,
                     dateInput("date1", "Choose a start date:",
                               min = '2024-01-02',
                               max = '2024-12-31',
                               value = '2024-01-02',
                               format = 'mm/dd/yy',
                               weekstart = 0,
                               daysofweekdisabled = c(0,1,3,4,5)),
                     tags$style(HTML(".datepicker {z-index:99999 !important;}"))
              ),
              column(2,
                     dateInput("date2", "Choose an end date:",
                               min = '2024-01-02',
                               max = '2024-12-31',
                               value = '2024-12-31',
                               format = 'mm/dd/yy',
                               weekstart = 0,
                               daysofweekdisabled = c(0,1,3,4,5)),
                     tags$style(HTML(".datepicker {z-index:99999 !important;}")
                     )
              ),
              column(2,      
                     selectInput('market', 'choose a market',
                                 choices = c('Both', unique(full_data$weekday)))
              )
            )
    )
    
  )
)
)