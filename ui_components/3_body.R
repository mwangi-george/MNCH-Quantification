# custom sidebar defined in utils


# Body tabs
trend_analysis_tab <- tabItem(
  tabName = "trend_analysis",
  fluidRow(
    comparison_plotUI("consumption_trend")
  )
)



# putting tabs together
body <- dashboardBody(
  tabItems(
    trend_analysis_tab
  )
)
