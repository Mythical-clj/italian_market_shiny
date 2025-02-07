function(input, output, session) {
  
  plot_data <- reactive({
    
    if (input$item == 'All' & input$market == 'Both'){
      plot_data <-  full_data
    }
    
    if (input$item != 'All' & input$market == 'Both'){
      plot_data <- full_data |> 
        subset(item %in% input$item) 
    }
    
    if (input$item == 'All' & input$market != 'Both') {
      plot_data <- full_data |> 
        filter(weekday == input$market)
    }
    
    if (input$item != 'All' & input$market != 'Both') {
      plot_data <- full_data |> 
        filter(weekday == input$market)|> 
        subset(item %in% input$item)
    }
    
    return(plot_data)
  })
  
  histdata <- rnorm(5)
  
  observeEvent(once = TRUE,ignoreNULL = FALSE, ignoreInit = FALSE, eventExpr = histdata, { 
    # event will be called when histdata changes, which only happens once, when it is initially calculated
    showModal(modalDialog(
      title = h1(span("Italian", 
                   style = "color: #008F45;
                   font-family: 'Times New Roman'",
                   span("Farmer's", 
                        style = "color: #595959;
                        font-family: 'Times New Roman'",
                        span("Market", 
                             style = "color: #CA2A36;
                             font-family: 'Times New Roman'"))
                   )
      ), 
      h2('Welcome to the Italian Market app!', 
         style = "font-family: 'Times New Roman';
         color: #008F45;
        text-align: center;"),
     
       p(HTML("This app allows us to explore the sales data of a friend's farmer's market stand for the year 2024.<br>
       This project will help this friend with understanding their sales data and seeing which of <br>
their inventory sells the best, when their strongest times are, how frequent sales occur, and analysis of amount made weekly."), 
      style = "font-family: 'Times New Roman';
        text-align: center;"),
      
      p('We want to know what the data reveals to us about the sales trends. Questions such as top products, highest revenue days, and weather relationships are what we are seeking to answer.', 
        style = "font-family: 'Times New Roman';
        text-align: center;"),
      
      h3(HTML('The data is viewed through 3 Tabs:<br>
         Summary, Exploration, and Models'), 
         style = "font-family: 'Times New Roman';
         color: #595959;
        text-align: center;"),
      
      p(HTML('Select one of the tabs, and along the top, there are four options to choose from to help sort:<br>
        "Choose a product" - This allows for the single choice of product offered, or the selection of all at once.<br>
        "Choose a start date" - This allows for the first day in a date range to be chosen.<br>
        "Choose an end date" - This allows for the last day in a date range to be chosen. By narrowing these down, we can view monthly and daily trends.<br>
         "Choose a market" - There are two different markets in the week, one on Saturday, and one on Tuesday. Selecting this allows us to see distinct market trends.'), 
        style = "font-family: 'Times New Roman';
        text-align: center;"),
      
      h3('The MVP and Goals for this Project', 
         style = "font-family: 'Times New Roman';
         color: #CA2A36;
        text-align: center;"),
      
      p(HTML('The minimum viable product (MVP) is a deployed shiny app that allows for the use of at least two of the inputs in the filtering of data.<br>
        Goals for this app are to include more search parameters, such as allowing a user to input their own number and return days where sales were within a range of that number,<br>
             and allowing the user to see the number of customers in a given frequency of time.'), 
        style = "font-family: 'Times New Roman';
        text-align: center;"),
      
      p(HTML('Thank you for visiting the app, I hope it works smoothly for you.'), 
        style = "font-family: 'Times New Roman';
        text-align: center;")
    ))
  })
  
  output$img1 <- renderUI({
    if(input$item == "All"){            
      img(height = 480, width = 800, src = "all-1.jpg")
    }                                        
    else if(input$item == "Pasta"){
      img(height = 480, width = 800, src = "pasta.jpg")
    }
    else if(input$item == "Strawberry Lemonade"){
      img(height = 480, width = 800, src = "lemonade.jpg")
    }
    else if(input$item == "Wagyu Meatballs"){
      img(height = 480, width = 800, src = "meatballs.jpg")
    }
    else if(input$item == "Meat Lasagna"){
      img(height = 480, width = 800, src = "meat-las.jpg")
    }
    else if(input$item == "Other"){
      img(height = 480, width = 800, src = "green-pasta.jpg")
    }
    else if(input$item == "Dried Pasta"){
      img(height = 480, width = 800, src = "other-pasta.jpg")
    }
    else if(input$item == "1 Ginger Shot (L)"){
      img(height = 480, width = 800, src = "ginger-shot.jpg")
    }
    else if(input$item == "Veggie Lasagna"){
      img(height = 480, width = 800, src = "veg-las.jpg")
    }
    else{
      img(height = 480, width = 800, src = "all-2.jpg")
    }
  })
  
  output$count <- renderValueBox({
    if (input$item == 'All'){
      subtitle = glue('Amount of all products sold between {format(input$date1, "%m/%d")} and {format(input$date2, "%m/%d")}')
    }
    else {subtitle = glue("{input$item} sold between {format(input$date1, '%m/%d')} and {format(input$date2, '%m/%d')}")}
    valueBox(product_count(input$item, input$date1, input$date2, input$market), subtitle = subtitle, color = 'red'
    )
  })
  
  output$earnings <- renderValueBox({
    if (input$item == 'All'){
      subtitle = glue('All net sales between {format(input$date1, "%m/%d")} and {format(input$date2, "%m/%d")}')
    }
    else {subtitle = glue("Net sales of {input$item} between {format(input$date1, '%m/%d')} and {format(input$date2, '%m/%d')}")}
    
    valueBox(product_earnings(input$item, input$date1, input$date2, input$market), subtitle = subtitle, color = 'green' 
    )
  })
  
  output$friends <- renderValueBox({
    if (input$item == 'All'){
      subtitle = glue('Select a product to see what it sold most with!')
    }
    else {subtitle = glue('sold most with {input$item}')}
    valueBox(value = tags$p(product_friends(input$item), style = "text-align:center;
                            font-size: 35px;"),
             subtitle = subtitle,
             color = 'red'
             )
  })
  
  output$food <- renderPlotly({
    plot_data() |> 
      filter(
        date >= as.Date(input$date1),
        date <= as.Date(input$date2)) |> 
      group_by(transaction_id) |> 
      ggplot(aes(net_sales)) +
      geom_histogram() +
      labs(title = glue('Total Count of {input$item} by Sales')) +
      ylab(glue('Total Counts of {input$item}')) +
      xlab(glue('Sales between {input$date1} and {input$date2}')) +
      theme(panel.background = element_blank(), 
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank())
  })
  
  output$linear <- renderPlotly({
    plot_data() |> 
      filter(
        date >= as.Date(input$date1),
        date <= as.Date(input$date2)) |> 
      group_by(item) |> 
      ggplot(aes(x=date, y= net_sales)) +
      geom_point(aes(color=item)) +
      geom_smooth(method = 'lm', se = FALSE, formula = y ~ log(x)) +
      scale_color_brewer(palette = 'Greens')
  })
  
  output$card <- renderPlotly({
    plot_data() |> 
      filter(date >= as.Date(input$date1),
             date <= as.Date(input$date2)) |>
      group_by(card_brand, card_entry_methods) |>
      summarize(`gross revenue` = sum(net_sales)) |> 
      ggplot(aes(x=card_brand, y=`gross revenue`, fill=card_entry_methods)) +
      geom_col() +
      labs(title = 'Types of Payment Taken by Card Type and Entry Method') +
      scale_fill_manual(values = c('#CA2A36', '#008F45')) +
      scale_y_continuous(labels = scales::dollar) +
      theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1),
            panel.background = element_blank(), 
            panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank())
  })
  
  output$rain <- renderPlotly({
    rain_market_plot(input$item, 
                     input$date1, 
                     input$date2, 
                     input$market)
  })
  
  output$poisson <- renderPlotly({
    poisson_plot(input$market)
  })
}

