library(tidyverse)

airbnb <- read_csv("christchurch_data_cleaned.csv")
area_codes <- read_csv("py/airbnb_area_codes.csv")

airbnb <- airbnb |>
  left_join(area_codes, by = c('id' = "listing_id"))