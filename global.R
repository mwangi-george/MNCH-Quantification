pacman::p_load(
  shiny, tidyverse, bs4Dash, shinycssloaders, highcharter, fs,
  glue, janitor, waiter, thematic, shinyWidgets, shinyjs
)

response <- read_csv("data/mnch_moh_647_data.csv", show_col_types = F)

options(
  shiny.launch.browser = TRUE
)


response %>% distinct(analytic) 
