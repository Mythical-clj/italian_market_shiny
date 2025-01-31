function(input, output, session) {
  
  plot_data <- reactive({
    
    plot_data <-  full_data
    
    if (input$item != 'All'){
      plot_data <- full_data |> 
        filter(item == input$item)
    }
    return(plot_data)
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
      filter(qty > 0) |>
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
  
}

