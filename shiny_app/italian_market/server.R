function(input, output, session) {
  output$food <- renderPlot({
    market_df |> 
      filter(item == input$item,
             date >= input$dates[1],
             date <= input$dates[2]) |> 
      group_by(transaction_id) |> 
      ggplot(aes(gross_sales)) +
      geom_histogram()
  })
}

