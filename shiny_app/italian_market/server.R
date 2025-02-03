function(input, output, session) {
  
  plot_data <- reactive({
    
    plot_data <-  full_data
    
    if (input$item != 'All'){
      plot_data <- full_data |> 
        subset(item %in% input$item) 
    }
    return(plot_data)
  })
  
  output$count <- renderValueBox({
    valueBox(product_count(input$item, input$date1, input$date2),
      
      if (input$item == 'All'){
        subtitle = 'Amount of all products sold between {format(input$date1, "%m/%d")} and {format(input$date2, "%m/%d")}'
      }
      else {subtitle = glue("{input$item}s sold between {format(input$date1, '%m/%d')} and {format(input$date2, '%m/%d')}")}
    )
  })
  
  output$earnings <- renderValueBox({
    valueBox(product_earnings(input$item, input$date1, input$date2),
             
             if (input$item == 'All'){
               subtitle = 'All net sales between {format(input$date1, "%m/%d")} and {format(input$date2, "%m/%d")}'
             }
             else {subtitle = glue("Net sales of {input$item} between {format(input$date1, '%m/%d')} and {format(input$date2, '%m/%d')}")}
    )
  })
  
  output$food <- renderPlotly({
    plot_data() |> 
      filter(
        date >= as.Date(input$date1),
        date <= as.Date(input$date2)) |> 
      group_by(transaction_id) |> 
      ggplot(aes(net_sales)) +
      geom_histogram()
  })
  
  output$linear <- renderPlotly({
    plot_data() |> 
      filter(
        date >= as.Date(input$date1),
        date <= as.Date(input$date2)) |> 
      group_by(item) |> 
      ggplot(aes(x=date, y=net_sales, color = item)) +
      geom_point() +
      geom_smooth(method = 'lm', se = FALSE)
  })
  
  output$card <- renderPlotly({
    plot_data() |> 
      filter(date >= as.Date(input$date1),
             date <= as.Date(input$date2)) |> 
      group_by(card_brand) |> 
      summarize(`gross revenue` = sum(net_sales)) |> 
      ggplot(aes(x=card_brand, y=`gross revenue`)) +
      geom_col()
  })
  
  output$rain <- renderPlotly({
    rain_market_plot(input$item, 
                     input$date1, 
                     input$date2, 
                     input$check)
  })
}

