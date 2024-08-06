controlbar <- dashboardControlbar(
  id = "controlbar",
  skin = "light",
  pinned = FALSE,
  width = 500,
  overlay = TRUE,
  controlbarMenu(
    id = "controlbarMenu",
    type = "tabs",
    controlbarItem(
      "Inputs",
      # inputs goes here
      sliderInput("graph_line_width", "Toggle Line Width", min = 1, max = 7, value = 5, step = 1, width = "100%")
    ),
    controlbarItem(
      "Skin",
      skinSelector()
    )
  )
)
