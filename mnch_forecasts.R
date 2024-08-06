pacman::p_load(
  DBI, googledrive, janitor
)


drive_download(
  "https://docs.google.com/spreadsheets/d/1CZBck_eEsOYVZ0-WPaj1nMic-rORcn9ATkJP0JA2XkQ/",
  path = "data/mnch_product_list.xlsx",
  overwrite = TRUE
)

product_dfs <- openxlsx::read.xlsx("data/mnch_product_list.xlsx", sheet = "Dataset") %>% 
  clean_names()

product_list <- product_dfs %>% 
  pull(name_of_product) 

product_str <- paste0("'", paste0(product_list, "'", collapse = ", '"))

# connection to sqlite db
sqlite_conn <- function(db_name) {
  conn <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{db_name}.db"))
  return(conn)
}

laikipia_narok <- sqlite_conn("databases/laikipia_narok")

other_counties <- sqlite_conn("databases/other_counties")

dbListTables(laikipia_narok)
dbListFields(laikipia_narok, "extrapolated_data_for_laikipia_county")
dbListTables(other_counties)
dbListFields(other_counties, "forecasts_all_counties")

get_data <- function(db_conn, table_name, product_column = "item_description_name_form_strength") {
  
  query <- glue(
    "
    SELECT 
      county,
      {product_column} as product_name,
      pack_size,
      --ROUND(AVG(price_kes)) as avg_price_kes,
      ROUND(SUM(quantity_required_for_period_specified_above), 0) as quantity_required
    FROM {table_name}
    WHERE 
      {product_column} IN ({product_str})
    GROUP BY {product_column}, county
    "
  )
  
  res <- dbGetQuery(
    db_conn, query
  )
  return(res)
}

laikipia_df <- get_data(laikipia_narok, "extrapolated_data_for_laikipia_county")
narok_df <- get_data(laikipia_narok, "extrapolated_data_for_narok_county")


other_counties_df <- get_data(other_counties, "forecasts_all_counties", "product_name")

laikipia_df %>% 
  bind_rows(narok_df) %>% 
  bind_rows(other_counties_df) %>% 
  pivot_wider(names_from = county, values_from = quantity_required) -> forecasts_df
  

forecasts_df %>%  openxlsx::write.xlsx("data/mnch_forecasts.xlsx")


product_dfs %>% 
  anti_join(forecasts_df, join_by(name_of_product == product_name)) %>% 
  openxlsx::write.xlsx("data/missing_mnch_forecasts.xlsx")













