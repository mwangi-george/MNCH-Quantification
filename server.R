# Back end
server <- function(input, output, session) {
  # calling modules
  comparison_plotServer("consumption_trend")
  anomaly_detectionServer("anomalies_plot")
  forecastingServer("forecasts")
}