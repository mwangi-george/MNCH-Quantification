server <- function(input, output, session) {
  
  observeEvent(list(input$org_unit, input$analytic), {
    comparison_plotServer("consumption_trend")
  })
  
}