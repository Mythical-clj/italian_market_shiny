function(input, output, session) {
  
  plot_data <- reactive({
    
    plot_data <-  full_data
    
    if (input$item != 'All'){
      plot_data <- plot_data |> 
        filter(item == input$item)
    }
    return(plot_data)
  })
  
  output$food <- renderPlot({
    plot_data() |> 
      filter(
             date >= input$dates[1],
             date <= input$dates[2]) |> 
      group_by(transaction_id) |> 
      ggplot(aes(total_sales)) +
      geom_histogram()
  })
  output$linear <- renderPlot({
    plot_data() |> 
      filter(qty > 0) |>
      filter(
             date >= input$dates[1],
             date <= input$dates[2]) |> 
      group_by(item) |> 
      ggplot(aes(x=date, y=net_sales, color = item)) +
      geom_point() +
      geom_smooth(method = 'lm', se = FALSE)
  })
  
  output$card <- renderPlot({
    plot_data() |> 
      filter(date >= input$dates[1],
             date <= input$dates[2]) |> 
      group_by(card_brand) |> 
      summarize(`gross revenue` = sum(gross_sales)) |> 
      ggplot(aes(x=card_brand, y=`gross revenue`)) +
      geom_col()
     
  })
  
}

