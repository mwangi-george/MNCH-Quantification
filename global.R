# Load Required libraries
pacman::p_load(
  shiny, tidyverse, bs4Dash, shinycssloaders, highcharter, fs, timetk, DT,
  glue, janitor, waiter, thematic, shinyWidgets, shinyjs, httr, plotly, prophet
)

# read data sets 
response <- read_csv("data/mnch_moh_647_data.csv", show_col_types = F)
anomalized_df <- read_csv("data/mnch_moh_647_data_anomalized.csv", show_col_types = F)

# Run time options
options(
  shiny.launch.browser = TRUE
)

