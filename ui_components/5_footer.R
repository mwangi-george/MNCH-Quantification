today <- year(today())

footer <- dashboardFooter(
  fixed = FALSE,
  left = a(
    href = "https://github.com/ihl-kenya",
    target = "_blank", HTML(paste("Powered by R, Shiny & HighchartsJS", icon("heart"))),
    style = "text-decoration: underline; font-size: 14px"
  ),
  right = h6(" ")
)
