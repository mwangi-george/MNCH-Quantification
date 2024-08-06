comparison_plotUI <- function(id) {
  ns <- NS(id)
  tagList(
    pickerInput(
      ns("analytic"),
      "Product", 
      width = "40%",
      choices = GET("http://127.0.0.1:8000/products") %>%  
        content() %>%
        as_vector(), 
      multiple = F
    ),
    pickerInput(
      ns("org_unit"),
      "Org Unit", 
      width = "40%",
      choices = GET("http://127.0.0.1:8000/org_units") %>%  
        content() %>%
        as_vector(), 
      selected = "Kenya", multiple = F
    ),
    actionButton(ns("get_data_from_api_btn"), "Get Data", style = "background-color: #dc3545;", width = "10%"),
    box(
      title = "Output",
      width = 12,
      height = 600,
      maximizable = TRUE,
      solidHeader = TRUE,
      status = "danger",
      highchartOutput(ns("comparison_plot"), height = 580) %>% withSpinner(type = 4, size = 0.5)
    )
  )
}

comparison_plotServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    plotting_df <- eventReactive(input$get_data_from_api_btn, {
      
      url <- "http://127.0.0.1:8000/data"
      params <- list(
        analytic = input$analytic, org_unit = input$org_unit
      )
      
      res <- GET(url, query = params, add_headers(accept = "application/json"))
      
      # Print the content of the response
      df <- content(res, "text") %>% fromJSON()
      
      df <- df$data %>% 
        mutate(period = period %>% ymd()) %>% 
        arrange(period)
      
      
      # response %>% 
      #   filter(
      #     org_unit == input$org_unit,
      #     analytic == input$analytic
      #   ) %>% 
      #   arrange(period)
    })
    
    output$comparison_plot <- renderHighchart({
      plotting_df() %>%
        hchart(
          type = "spline",
          hcaes(
            x = as.Date(period),
            y = as.numeric(value)
            # group = method
          ),
          showInLegend = TRUE,
          dataLabels = list(enabled = TRUE)
        ) %>%
        hc_exporting(enabled = TRUE) %>%
        hc_tooltip(
          crosshairs = TRUE,
          backgroundColor = "lightsalmon",
          shared = T, 
          borderWidth = 0
        ) %>%
        hc_legend(title = list(text = "Click to hide method")) %>%
        hc_title(
          text = "Total Quantity Issued over Time",
          align = "left", style = list(fontweight = "bold", fontsize = "17px")
        ) %>%
        hc_subtitle(
          text = str_c("Showing data for", input$org_unit, sep = " "), align = "left",
          style = list(fontweight = "bold", fontsize = "15px")
        ) %>%
        hc_caption(
          text = "Data from KHIS (MOH 647)", align = "left"
        ) %>%
        hc_add_theme(hc_theme_538()) %>%
        hc_chart(zoomType = "x") %>%
        hc_xAxis(title = list(text = "Date")) %>%
        hc_yAxis(title = list(text = "Value"), labels = list(enabled = TRUE)) %>%
        hc_legend(align = "center", verticalAlign = "bottom", layout = "horizontal") %>%
        hc_rangeSelector(enabled = TRUE, selected = 6, verticalAlign = "bottom") %>%
        hc_plotOptions(series = list(lineWidth = 5))
    })
  })
}
