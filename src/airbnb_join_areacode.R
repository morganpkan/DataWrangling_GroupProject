library(tidyverse)

airbnb <- read_csv("output/christchurch_data_cleaned.csv")
area_codes <- read_csv("src/py/airbnb_area_codes.csv")

airbnb <- airbnb |>
  left_join(area_codes, by = c('id' = "listing_id"))