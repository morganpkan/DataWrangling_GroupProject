library(tidyverse)
christchurch_raw <- read_csv('christchurch.csv')

#Cleaning

#NOTE: Price is NA from Dec 2025, Jan 2026, and Feb 2026
#This is an error from airbnb raw data.


#Deduplicate data using april listings as most recent
#April listings used as most recent tenancy/rental bond data in April 2026
#May and June 2026 data excluded from this dataset.
christchurch <- christchurch_raw |>
  filter(scrape_date <= as_date("2026-04-22")) |>
  group_by(id) |>
  slice_max(scrape_date, n = 1, with_ties = FALSE) |>
  ungroup() |>
  mutate(days_since_review = as.numeric(scrape_date - as_date(last_review)))

#Removed license column as it was entirely NA
christchurch <- christchurch |> select(-license)

#Removed source file column; Derivable from month and year columns
christchurch <- christchurch |> select(-source_file)

#Renamed neighbourhood_group to city.: All Rows = Christchurch City
christchurch <- christchurch |> rename(city = neighbourhood_group)

#Changed room_type and neighbourhood from strings to factor
christchurch <- christchurch |>
  mutate(room_type = as.factor(room_type),
         neighbourhood = as.factor(neighbourhood))

#Removes 4 rows where minimum nights was NA
christchurch <- christchurch |> filter(!is.na(minimum_nights))

#Changed NAs in reviews per month to 0
christchurch <- christchurch |>
  mutate(
    reviews_per_month = if_else(is.na(reviews_per_month), 0, reviews_per_month))

airbnb <- christchurch |>
      select(id, latitude, longitude)
write_csv(airbnb, 'py/airbnb_data.csv')

write_csv(christchurch, "christchurch_data_cleaned.csv")