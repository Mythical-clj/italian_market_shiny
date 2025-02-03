dashboardPage(
  header,
  dashboardSidebar(
    sidebarMenu(id = 'tabs',
                menuItem("Summary", 
                         tabName = "FoodTab",
                         icon = icon("wheat-awn")),
                menuItem("Exploration",
                         tabName = "CardTab",
                         icon = icon("fa-solid fa-dollar-sign"),
                         menuSubItem("sub menu",
                                     tabName = "subMenu")),
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
                       pickerInput("item", "Choose a product:",
                                   choices = c('All', unique(full_data$item)), 
                                   selected = 'All',
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
                       checkboxInput('check', 'Only look at start date',
                                     value = FALSE)
                ),
              ),
              fluidRow(
                column(8,
                       valueBoxOutput('count'),
                       valueBoxOutput(('earnings'))
                ),
                column(10,
                       plotlyOutput("food", 
                                    height = '300px')
                )
              )
      ),
      
      tabItem(tabName = 'linear_reg',
              fluidRow(
                column(4,
                       
                       pickerInput("item", "Choose a food:",
                                   choices = c('All', unique(full_data$item)), 
                                   selected = unique(full_data$item)[1],
                                   multiple = TRUE),
                       
                       dateInput("date1", "Choose a start date:",
                                 min = '2024-01-02',
                                 max = '2024-12-31',
                                 value = '2024-01-02',
                                 format = 'mm/dd/yy',
                                 weekstart = 0,
                                 daysofweekdisabled = c(0,1,3,4,5)),
                       tags$style(HTML(".datepicker {z-index:99999 !important;}")),
                       
                       checkboxInput('check', 'Only look at start date',
                                     value = FALSE),
                       
                       dateInput("date2", "Choose an end date:",
                                 min = '2024-01-02',
                                 max = '2024-12-31',
                                 value = '2024-12-31',
                                 format = 'mm/dd/yy',
                                 weekstart = 0,
                                 daysofweekdisabled = c(0,1,3,4,5))),
                column(8,
                       plotlyOutput('linear', 
                                    height = '300px')
                )
              )
      ),
      
      tabItem(tabName = "subMenu",
              h2("First tab")),
      
      tabItem(tabName = "CardTab", plotlyOutput('card'),
              
              pickerInput("item", "Choose a food:",
                          choices = c('All', unique(full_data$item)), 
                          selected = unique(full_data$item)[1],
                          multiple = TRUE),
              
              dateInput("date1", "Choose a start date:",
                        min = '2024-01-02',
                        max = '2024-12-31',
                        value = '2024-01-02',
                        format = 'mm/dd/yy',
                        weekstart = 0,
                        daysofweekdisabled = c(0,1,3,4,5)),
              tags$style(HTML(".datepicker {z-index:99999 !important;}")),
              
              checkboxInput('check', 'Only look at start date',
                            value = FALSE),
              
              dateInput("date2", "Choose an end date:",
                        min = '2024-01-02',
                        max = '2024-12-31',
                        value = '2024-12-31',
                        format = 'mm/dd/yy',
                        weekstart = 0,
                        daysofweekdisabled = c(0,1,3,4,5)
              )
      ),
      
      tabItem(tabName = 'rainSales', plotlyOutput('rain'),
              
              pickerInput("item", "Choose a food:",
                          choices = c('All', unique(full_data$item)), 
                          selected = unique(full_data$item)[1],
                          multiple = TRUE),
              
              dateInput("date1", "Choose a start date:",
                        min = '2024-01-02',
                        max = '2024-12-31',
                        value = '2024-01-02',
                        format = 'mm/dd/yy',
                        weekstart = 0,
                        daysofweekdisabled = c(0,1,3,4,5)),
              tags$style(HTML(".datepicker {z-index:99999 !important;}")),
              
              checkboxInput('check', 'Only look at start date',
                            value = FALSE),
              
              dateInput("date2", "Choose an end date:",
                        min = '2024-01-02',
                        max = '2024-12-31',
                        value = '2024-12-31',
                        format = 'mm/dd/yy',
                        weekstart = 0,
                        daysofweekdisabled = c(0,1,3,4,5)
              )
      )
      
    )
  )
)