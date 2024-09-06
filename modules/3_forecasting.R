forecastingUI <- function(id){
  ns <- NS(id)
  
  tagList(
    box(
      width = 2, height = 110,
      status = "danger", solidHeader = T,
      pickerInput(
        ns("org_unit_forecasting"),
        "Org Unit", 
        width = "100%",
        choices = anomalized_df %>% distinct(org_unit) %>% arrange(org_unit) %>% pull(org_unit), 
        selected = "Kenya", multiple = F
      )
    ),
    box(
      width = 2, height = 110, status = "danger", solidHeader = T,
      pickerInput(
        ns("analytic_forecasting"),
        "Product", 
        width = "100%",
        choices = anomalized_df %>% distinct(analytic) %>% arrange(analytic) %>% pull(analytic), 
        multiple = F
      )
    ),
    box(
      width = 2, height = 110, status = "danger", solidHeader = T,
      radioButtons(ns("seasonality"), "Show Seasonality", choices = c(Yes = T, No = F), selected = F)
    ),
    box(
      width = 2, height = 110, status = "danger", solidHeader = T,
      radioButtons(ns("growth"), "Growth Type", choices = c(Linear = "linear", Flat = "flat"), selected = "linear")
    ),
    box(
      width = 2, height = 110, status = "danger", solidHeader = T,
      numericInput(ns("horizon"), "Forecast Horizon:", min = 1, max = 100, value = 12)
    ),
    box(
      width = 2, height = 110, status = "danger", solidHeader = T,
      actionButton(
        ns("run_forecast"), "Forecast", icon = icon("line-chart", lib = "font-awesome"),
        style = "color: #fff; background-color: steelblue; border-color: steelblue;width: 150px; height: 35px;"
      )
    ),
    box(
      title = "Forecast",
      width = 12,
      height = 600,
      maximizable = TRUE,
      solidHeader = TRUE,
      status = "danger",
      plotlyOutput(ns("forecast_plot"), height = 580) %>% withSpinner(type = 4, size = 0.5)
    ),
    box(
      title = "Monthly Forecast",
      width = 12,
      height = 600,
      maximizable = TRUE,
      solidHeader = TRUE,
      status = "danger",
      DTOutput(ns("monthly_forecast"), height = 580) %>% withSpinner(type = 4, size = 0.5)
    ),
    valueBoxOutput(ns("forecast_summary_value"))
  )
}

forecastingServer <- function(id) {
  moduleServer(id, function(input, output, session) {
    
    data <- eventReactive(input$run_forecast, {
      anomalized_df %>%
        filter(
          org_unit == input$org_unit_forecasting,
          analytic == input$analytic_forecasting
        ) %>% 
        transmute(ds = period, y = round(observed_clean)) %>% 
        arrange(ds)
    })
    
    forecast_data <- eventReactive(input$run_forecast, {
      if (nrow(data()) >= 2) {
        fit <- prophet(
          data(),
          growth = input$growth, seasonality.mode = "additive",
          yearly.seasonality = input$seasonality, interval.width = 0.95
        )
        future <- make_future_dataframe(fit, periods = input$horizon, freq = "1 month", include_history = T)
        last_date <- tail(data()$ds, n = 1)
        future <- future %>% filter(ds > last_date)
        forecast <- predict(fit, future)
        return(forecast)
      } else {
        NULL
      }
    })
    
    observeEvent(input$run_forecast, {
      # This function renders a plotly chart of the actual data and the forecast.
      output$forecast_plot <- renderPlotly({
        if (!is.null(forecast_data())) {
          plot_ly() %>%
            add_trace(
              data = data(), x = ~ds, y = ~y, type = "scatter",
              mode = "lines+markers", name = "Actual Data",
              line = list(color = "#E73846"), marker = list(color = "#E73846", size = 5)
            ) %>%
            add_trace(
              data = forecast_data(), x = ~ds, y = ~yhat,
              type = "scatter", mode = "lines+markers", line = list(color = "#1C3557"),
              marker = list(color = "#1C3557", size = 5), name = "Forecast"
            ) %>%
            add_ribbons(
              data = forecast_data(), x = ~ds, ymin = ~yhat_lower, ymax = ~yhat_upper,
              fillcolor = "gray90", line = list(color = "transparent"), name = "Forecast Interval"
            ) %>%
            layout(
              title = str_c(input$org_unit_1, input$analytic_forecasting, "Forecast Plot", sep = " "),
              xaxis = list(title = "Date"), yaxis = list(title = input$analytic_forecasting), showlegend = FALSE
            )
        }
      })
      
      forecast_table <- reactive({
        forecast_data() %>%
          transmute(
            product = input$analytic_forecasting,
            org_unit = input$org_unit_forecasting,
            Date = as.Date(ds), Forecast = round(yhat), Lower = round(yhat_lower), Upper = round(yhat_upper)
          )
      })
      
      # This function renders a gt table of the forecast summary.
      output$monthly_forecast <- renderDT({
        if (!is.null(forecast_data())) {
          forecast_table() %>%
            datatable(
              rownames = F, extensions = "Buttons",editable = T,
              fillContainer = T, 
              options = list(
                dom = "Bfrt", buttons = c("excel", "pdf"), pageLength = 40,
                initComplete = JS(
                  "function(settings, json) {",
                  "$(this.api().table().header()).css({'background-color': 'red', 'color': 'white'});",
                  "}")
              )
            )
        }
      })
      
      
      output$forecast_summary_value <- renderValueBox({
        var <- forecast_table() %>% 
          summarize(
            total = sum(Forecast, na.rm = T)
          ) %>% pull(total)
        
        valueBox(value = format(var, big.mark = ", "), subtitle = "Summary Value", color = "danger")
      })
      
      
      # end of observer
    })
  })
}