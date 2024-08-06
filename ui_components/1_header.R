bg_color <- "navy"

# Header definition
header <- dashboardHeader(
  disable = FALSE,
  status = bg_color,
  fixed = FALSE,
  skin = bg_color,
  a(
    "MNCH Trend Analysis",
    href = "https://hiskenya.org/",
    target = "_blank",
    style = "color: #dc3545;"
  ) %>% h3() %>% div(),
  title = dashboardBrand(
    title = strong("MNCH Products") %>% h4(style = "font-size: 16px; color: #dc3545;"),
    color = bg_color,
    image = "img/analytics.png",
    opacity = 1
  )
)
