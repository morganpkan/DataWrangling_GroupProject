library(tidyverse)
christchurch <- read_csv('christchurch.csv')


#Cleaning

#NOTE: Price is NA from Dec 2025, Jan 2026, and Feb 2026
#This is an error from airbnb raw data.

#Removed license column as it was entirely NA
christchurch <- christchurch |> select(-license)

#Removed source file column; Derivable from month and year columns
christchurch <- christchurch |> select(-source_file)

#Omit redundant neighbourhood_group: All Rows = Christchurch City
christchurch <- christchurch |> rename(city = neighbourhood_group)

#Changed room_type and neighbourhood from strings to factor
christchurch <- christchurch |>
  mutate(room_type = as.factor(room_type),
         neighbourhood = as.factor(neighbourhood))

#Changed NAs in reviews per month to 0
christchurch <- christchurch |>
  mutate(
    reviews_per_month = if_else(is.na(reviews_per_month), 0, reviews_per_month))

