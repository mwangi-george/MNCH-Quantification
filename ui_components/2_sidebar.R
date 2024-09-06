
# JS code to close browser window upon clicking logout button
jscode <- "shinyjs.closeWindow = function() { window.close(); }"


# sidebar definition
sidebar <- dashboardSidebar(
  fixed = TRUE,
  skin = "light",
  status = "danger",
  id = "sidebar",
  width = 400,
  collapsed = FALSE,
  sidebarUserPanel(
    image = "https://adminlte.io/themes/v3/dist/img/AdminLTELogo.png",
    name = "Welcome Onboard!"
  ),
  sidebarMenu(
    id = "sidabar",
    flat = FALSE,
    compact = FALSE,
    childIndent = TRUE,
    menuItem("Trend Analyis", tabName = "trend_analysis", icon = icon("chart-line")),
    menuItem("Anomaly Detection", tabName = "anomaly_detection", icon = icon("wand-magic-sparkles")),
    menuItem("Forecasting", tabName = "forecasting", icon = icon("wand-magic-sparkles"))
  )
)
