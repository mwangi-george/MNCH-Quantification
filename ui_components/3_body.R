# custom sidebar defined in utils


# Body tabs
trend_analysis_tab <- tabItem(
  tabName = "trend_analysis",
  fluidRow(
    comparison_plotUI("consumption_trend")
  )
)


anomaly_detection_tab <- tabItem(
  tabName = "anomaly_detection",
  fluidRow(
    anomaly_detectionUI("anomalies_plot")
  )
)

forecasting_tab <- tabItem(
  tabName = "forecasting",
  fluidRow(
    forecastingUI("forecasts")
  )
)



# putting tabs together
body <- dashboardBody(
  tabItems(
    trend_analysis_tab, anomaly_detection_tab, forecasting_tab
  )
)
