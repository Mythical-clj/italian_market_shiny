dashboardPage(
  header,
  dashboardSidebar(
    sidebarMenu(id = 'tabs',
                menuItem("Summary", 
                         tabName = "FoodTab",
                         icon = icon("fa-solid fa-dollar-sign")),
                menuItem("Exploration",
                         tabName = "CardTab",
                         icon = icon("fa-regular fa-map")),
                menuItem('Models',
                         tabName = 'linear_reg',
                         icon = icon("line-chart")),
                menuItem('Findings',
                         tabName = 'rainSales',
                         icon = icon("book"))
                
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
                      text-align: left;}
                      .modal.in .modal-dialog {
        width:100%;
        height:100%;
        margin:0px;}
      .modal-content{
        width:100%;
        height:100%;}')
                 
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
                       selectInput('market', 'choose a market:',
                                   choices = c('Both', unique(full_data$weekday)))
                )
              ),
              fluidRow(
                column(12,
                       valueBoxOutput('count'),
                       valueBoxOutput('earnings'),
                       valueBoxOutput('friends')
                )
              ),
              fluidRow(
                column(
                  12, align = 'center',
                  uiOutput('img1')
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
                       selectInput('market', 'choose a market:',
                                   choices = c('Both', unique(full_data$weekday)))
                ),
                column(12, style = "padding: 15px;",
                       plotlyOutput('linear', 
                                    height = '300px'),
                       plotlyOutput('poisson',
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
                       selectInput('market', 'choose a market:',
                                   choices = c('Both', unique(full_data$weekday)))
                )
              ),
              fluidRow(
                column(4, style = "padding: 10px;",
                       plotlyOutput("food", 
                                    height = '300px')
                ),
                column(8, style = "padding: 10px;",
                       plotlyOutput('card', 
                                    height = '300px')
                )
              ),
              fluidRow(
                column(12, style = "padding: 10px;",
                       plotlyOutput('rain',
                                    height = '300px')
                )
              )
      ),
      
      tabItem(tabName = 'rainSales',
              fluidRow(
                
              )
      )
      
    )
  )
)