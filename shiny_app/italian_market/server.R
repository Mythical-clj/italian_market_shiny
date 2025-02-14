function(input, output, session) {
  
  # This plot data is using the reactive that has four if statements and logical 
  # operators. Alexa helped me realize this is what was needed to make my inputs work
  
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
  
  # This histdata is a placeholder for triggering the landing page event
  
  histdata <- rnorm(5)
  
  # Creates a landing page for the app
  
  observeEvent(once = TRUE,ignoreNULL = FALSE, ignoreInit = FALSE, eventExpr = histdata, { 

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
      
      p(HTML('We want to know what the data reveals to us about the sales trends. Questions such as <b>top products, highest revenue days</b>, and <b>weather relationships</b> are what we are seeking to answer.'), 
        style = "font-family: 'Times New Roman';
        text-align: center;"),
      
      h3(HTML('The data is viewed through 3 Tabs:<br>
         <b>Summary, Exploration, and Models</b>'), 
         style = "font-family: 'Times New Roman';
         color: #595959;
        text-align: center;"),
      
      p(HTML('Select one of the tabs, and along the top, there are four options to choose from to help sort:<br>
        <b>"Choose a product"</b> - This allows for the single choice of product offered, or the selection of all at once.<br>
        <b>"Choose a start date"</b> - This allows for the first day in a date range to be chosen.<br>
        <b>"Choose an end date"</b> - This allows for the last day in a date range to be chosen. By narrowing these down, we can view monthly and daily trends.<br>
         <b>"Choose a market"</b> - There are two different markets in the week, one on Saturday, and one on Tuesday. Selecting this allows us to see distinct market trends.'), 
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
  
  # These allow for different images to appear on the app deo
  
  output$img1 <- renderUI({
    if(input$item == "All"){            
      img(height = 480, width = 900, src = "all-1.jpg")
    }                                        
    else if(input$item == "Pasta"){
      img(height = 480, width = 900, src = "pasta.jpg")
    }
    else if(input$item == "Strawberry Lemonade"){
      img(height = 480, width = 900, src = "lemonade.jpg")
    }
    else if(input$item == "Wagyu Meatballs"){
      img(height = 480, width = 900, src = "meatballs.jpg")
    }
    else if(input$item == "Meat Lasagna"){
      img(height = 480, width = 900, src = "meat-las.jpg")
    }
    else if(input$item == "Other"){
      img(height = 480, width = 900, src = "focaccia.jpg")
    }
    else if(input$item == "Dried Pasta"){
      img(height = 480, width = 900, src = "other-pasta.jpg")
    }
    else if(input$item == "1 Ginger Shot (L)"){
      img(height = 480, width = 900, src = "ginger-shot.jpg")
    }
    else if(input$item == "Veggie Lasagna"){
      img(height = 480, width = 900, src = "veg-las.jpg")
    }
    else if(input$item == "Bolognese"){
      img(height = 480, width = 900, src = "bolognese.jpg")
    }
    else if(input$item == "Large Vodka Sauce"){
      img(height = 480, width = 900, src = "vodka-sauce.jpg")
    }
    else if(input$item == "Vodka Sauce"){
      img(height = 480, width = 900, src = "vodka-sauce.jpg")
    }
    else if(input$item == "Butternut Squash Ravioli"){
      img(height = 480, width = 900, src = "squash-rav.jpg")
    }
    else if(input$item == "Wagyu Beef Ravioli"){
      img(height = 480, width = 900, src = "meat-rav.jpg")
    }
    else if(input$item == "Short Rib Ravioli"){
      img(height = 480, width = 900, src = "meat-rav.jpg")
    }
    else{
      img(height = 480, width = 900, src = "all-2.jpg")
    }
  })
  
  output$img2 <- renderUI({
    img(height = 720, width = 1280, src = "findings-slide.jpg")
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
      mutate(qty = round(qty, digits=1)) |>
      ggplot(aes(qty)) +
      geom_histogram() +
      labs(title = glue('Total Count of {input$item} transactions by Quantity')) +
      ylab(glue('Total Count of {input$item}')) +
      xlab(glue('Quantity between {input$date1} and {input$date2}')) +
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
      geom_smooth(method = 'lm', 
                  se = FALSE, 
                  formula = y ~ x,
                  color = '#CA2A36') +
      scale_color_brewer(palette = 'Greens', n=9) +
      ylab('Net Sales')
  })
  
  output$card <- renderPlotly({
    plot_data() |> 
      filter(date >= as.Date(input$date1),
             date <= as.Date(input$date2)) |>
      group_by(card_brand, card_entry_methods) |>
      summarize(`gross revenue` = sum(net_sales)) |> 
      ggplot(aes(x=card_brand, y=`gross revenue`, fill=card_entry_methods)) +
      geom_col() +
      labs(title = 'Types of Payment Taken by Card Type and Entry Method', 
           fill = "Card Entry Methods") +
      xlab('Card Brands') +
      ylab('Gross Revenue') +
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
    poisson_plot(input$date1, input$date2, input$market)
  })
}

