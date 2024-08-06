dir_ls("modules/") %>% map(~source(.x))
dir_ls("ui_components/") %>% map(., ~source(.x))


# Build UI using sourced components
ui <- dashboardPage(
  # preloader = list(html = tagList(spin_1(), "Getting data, please wait..."), color = "navy"),
  header = header,
  sidebar = sidebar,
  controlbar = controlbar,
  body = body,
  footer = footer,
  skin = "light",
  dark = FALSE,
  help = TRUE,
  fullscreen = TRUE,
  scrollToTop = TRUE
)