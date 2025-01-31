dashboardPage(
  header,
  skin = 'black',
  dashboardSidebar(
    sidebarMenu(
      menuItem("Food Sales", 
               tabName = "FoodTab",
               icon = icon("wheat-awn")),
      menuItem("Card Payments",
               tabName = "CardTab",
               icon = icon("fa-solid fa-dollar-sign")),
      menuItem('Linear Regression',
               tabName = 'linear_reg',
               icon = icon("line-chart"))
        
      ),
      
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
      
      dateInput("date2", "Choose an end date:",
                min = '2024-01-02',
                max = '2024-12-31',
                value = '2024-12-31',
                format = 'mm/dd/yy',
                weekstart = 0,
                daysofweekdisabled = c(0,1,3,4,5))
    ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "FoodTab",
              plotlyOutput("food", 
                           height = '300px')),
      
      tabItem(tabName = 'linear_reg',
              plotlyOutput('linear', 
                           height = '300px')),
      
      tabItem(tabName = "CardTab", plotlyOutput('card'))
    )
  )
)