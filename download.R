pacman::p_load(DBI, janitor, dhis2r, tidyverse)


data_elements <- c("GOFxghdlf5n", "qoEFejcajz1", "WbDKZsPHAOK", "pxdnKL8X8aP") %>% str_c(".hDCmaVTXH7W")

product_names <- read_csv("data/product_names.csv", show_col_types = F)

set_names(
  product_names %>% pull(dataid),
  product_names %>% pull(dataname)
) -> product_names_list


my_db_connection <- dbConnect(drv = odbc::odbc(), .connection_string = "Driver={PostgreSQL ANSI(x64)};",
                              database = "FP", UID = Sys.getenv("POSTGRES_DB_NAME"), PWD = Sys.getenv("POSTGRES_DB_PASSWORD"),
                              Port = 5432, timeout = 10)


org_units <- dbGetQuery(
  my_db_connection,
  "SELECT DISTINCT county_id FROM organisation_units"
)

period <- c("202101": "202406")

# Connection to KHIS
dhis_con <- Dhis2r$new(
  base_url = "https://hiskenya.org",
  username = Sys.getenv("DHIS2_USERNAME"),
  password = Sys.getenv("DHIS2_PASSWORD")
)


# Extract and format
response <- dhis_con$get_analytics(
  analytic = product_names %>% pull(dataid),
  org_unit = org_units %>% pull(county_id),
  period = period,
  output_scheme = "NAME"
) %>%
  mutate(
    analytic = analytic %>% str_remove_all("MOH 647_|.Total Quantity issued this month"),
    org_unit = org_unit %>% str_remove_all(" County"),
    period = period %>% my()
  )

aggregate <- response %>%
  summarise(
    value = sum(value, na.rm = TRUE),
    .by = c(analytic, period)
  ) %>%
  mutate(
    org_unit = "Kenya"
  ) %>%
  relocate(org_unit, .after = analytic)

response <- response %>%
  bind_rows(aggregate) %>%
  write_csv("data/mnch_moh_647_data.csv")














