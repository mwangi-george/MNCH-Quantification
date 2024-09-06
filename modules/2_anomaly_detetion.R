anomaly_detectionUI <- function(id){
  ns <- NS(id)
  tagList(
    pickerInput(
      ns("analytic_anomaly"),
      "Product", 
      width = "40%",
      choices = anomalized_df %>% distinct(analytic) %>% arrange(analytic) %>% pull(analytic), 
      multiple = F
    ),
    pickerInput(
      ns("org_unit_anomaly"),
      "Org Unit", 
      width = "40%",
      choices = anomalized_df %>% distinct(org_unit) %>% arrange(org_unit) %>% pull(org_unit), 
      selected = "Kenya", multiple = F
    ),
    box(
      title = "Anomaly Detection",
      width = 12,
      height = 600,
      maximizable = TRUE,
      solidHeader = TRUE,
      status = "danger",
      plotlyOutput(ns("anomalies_plot"), height = 580) %>% withSpinner(type = 4, size = 0.5)
    ),
    box(
      title = "Anomaly Handling",
      width = 12,
      height = 600,
      maximizable = TRUE,
      solidHeader = TRUE,
      status = "danger",
      plotlyOutput(ns("cleaned_anomaly_plot"), height = 580) %>% withSpinner(type = 4, size = 0.5)
    )
  )
}

anomaly_detectionServer <-  function(id) {
  moduleServer(id, function(input, output, session) {
    
    anomaly_df <- reactive({
      anomalized_df %>%
        filter(
          org_unit == input$org_unit_anomaly,
          analytic == input$analytic_anomaly
        ) 
    })
   
    
    output$anomalies_plot <- renderPlotly({
      anomaly_df() %>% 
        plot_anomalies(period)
    })
    
    output$cleaned_anomaly_plot <- renderPlotly({
      anomaly_df() %>% 
        plot_anomalies_cleaned(period)
    })
  }
)}