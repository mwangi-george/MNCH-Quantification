pacman::p_load(
  shiny, tidyverse, bs4Dash, shinycssloaders, highcharter, fs, timetk, DT,
  glue, janitor, waiter, thematic, shinyWidgets, shinyjs, httr, plotly, prophet
)

response <- read_csv("data/mnch_moh_647_data.csv", show_col_types = F)
anomalized_df <- read_csv("data/mnch_moh_647_data_anomalized.csv", show_col_types = F)

options(
  shiny.launch.browser = TRUE
)

