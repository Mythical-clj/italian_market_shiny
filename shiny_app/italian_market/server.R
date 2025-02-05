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
    if (input$item == 'All'){
      subtitle = glue('Amount of all products sold between {format(input$date1, "%m/%d")} and {format(input$date2, "%m/%d")}')
    }
    else {subtitle = glue("{input$item} sold between {format(input$date1, '%m/%d')} and {format(input$date2, '%m/%d')}")}
    valueBox(product_count(input$item, input$date1, input$date2), subtitle = subtitle
    )
  })
  
  output$earnings <- renderValueBox({
    if (input$item == 'All'){
      subtitle = glue('All net sales between {format(input$date1, "%m/%d")} and {format(input$date2, "%m/%d")}')
    }
    else {subtitle = glue("Net sales of {input$item} between {format(input$date1, '%m/%d')} and {format(input$date2, '%m/%d')}")}
    
    valueBox(product_earnings(input$item, input$date1, input$date2), subtitle = subtitle 
    )
  })
  
  output$mean <- renderValueBox({
    valueBox(product_mean(input$item),
             subtitle = glue('Median amount of {input$item} purchased at once')
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
      ggplot(aes(x=date, y=log(net_sales))) +
      geom_point(aes(color=item)) +
      geom_smooth(method = 'lm', se = FALSE)
  })
  
  output$card <- renderPlotly({
    plot_data() |> 
      filter(date >= as.Date(input$date1),
             date <= as.Date(input$date2)) |>
      group_by(card_brand) |>
      mutate(`gross revenue` = sum(net_sales)) |> 
      ggplot(aes(x=card_brand, y=`gross revenue`, color=card_entry_methods)) +
      geom_col() +
      scale_y_continuous(labels = scales::comma) +
      theme_minimal()
  })
  
  output$rain <- renderPlotly({
    rain_market_plot(input$item, 
                     input$date1, 
                     input$date2, 
                     input$market)
  })
}

