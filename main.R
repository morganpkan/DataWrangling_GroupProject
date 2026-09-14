library(tidyverse) #install.packages("tidyverse")
library(dplyr)
library(purrr)
library(readr)

#finds every csv in airbnb_datasets and compiles into list of filepaths
files <- list.files(path = "airbnb_datasets", pattern = "\\.csv$", full.names = TRUE)

#Files must have naming convention: listings_month_year_.csv

###COMPILING DATASETS
#reads every csv in 'files', extracts month + year from each filename
compiled_data <- files |>
  map_df(~ read_csv(.x) |>
           mutate(
             source_file = .x,
             month_name  = str_extract(.x, "(?<=listings_)[a-zA-Z]+"), #regex expression to pull the string following listings_
             year        = str_extract(.x, "\\d{4}") # returns the first instance of four digits in a row which is the year.
           )
  ) 


compiled_data <- compiled_data |>
  group_by(month_name, year) |>
  mutate(scrape_date = max(last_review, na.rm=TRUE)) |>
  ungroup()


write_csv(compiled_data, "listings_compiled.csv") #concatenated christchurch dataset not deduplicated

#deduplicates based on most recent scrape for all nz
nz_latest <- compiled_data |>
  group_by(id) |>
  slice_max(scrape_date, n = 1, with_ties = FALSE) |>
  ungroup()

christchurch_latest <- nz_latest |>
  filter(neighbourhood_group == "Christchurch City") |>
  mutate(days_since_review = as.numeric(scrape_date - as_date(last_review)))




###SUMMARY STATS

categorical <- c( "neighbourhood", "room_type")
numeric <- c("price", "minimum_nights", "number_of_reviews",
             "reviews_per_month", "calculated_host_listings_count",
             "availability_365", "number_of_reviews_ltm")



numeric_summary <- christchurch_latest |>
  select(all_of(numeric)) |>
  summarise(across(everything(), list(
    min       = ~min(., na.rm = TRUE),
    p25       = ~quantile(., 0.25, na.rm = TRUE),
    median    = ~median(., na.rm = TRUE),
    mean      = ~mean(., na.rm = TRUE),
    p75       = ~quantile(., 0.75, na.rm = TRUE),
    p99       = ~quantile(., 0.99, na.rm = TRUE),
    max       = ~max(., na.rm = TRUE),
    sd        = ~sd(., na.rm = TRUE),
    n_missing = ~sum(is.na(.))
  ))) |>
  pivot_longer(everything(), names_to = c("variable", ".value"),
               names_pattern = "(.*)_(min|p25|median|mean|p75|p99|max|sd|n_missing)")

categorical_summary <- map(categorical, ~ christchurch_latest |> count(.data[[.x]], sort = TRUE))
names(categorical_summary) <- categorical


#counts in christchurch
categorical_summary$neighbourhood
categorical_summary$room_type

###


# 1. Price distribution — overall (NZ) vs Christchurch

nz_latest |>
  mutate(region = "New Zealand") |>
  bind_rows(
    christchurch_latest |> mutate(region = "Christchurch City")
  ) |>
  filter(price > 0, price <= quantile(nz_latest$price, 0.99, na.rm = TRUE)) |> # filter price greater than zero, less than 99th quantile to remove outliers 
  ggplot(aes(x = price, fill = region, after_stat(density))) +
  geom_histogram(alpha = 0.5, position = "identity", bins = 50, boundary = 0) 
  
  labs(
    x = "Price (NZD)", y = "Density",
    title = "Price Distribution: New Zealand vs Christchurch City",
    fill = "Region"
  ) +
  theme_minimal()


# 2. Days since last review — Christchurch only

christchurch_latest <- christchurch_latest |>
  mutate(days_since_review = as.numeric(scrape_date - as_date(last_review)))

ggplot(christchurch_latest, aes(x = days_since_review)) +
  geom_histogram(fill = "steelblue", bins = 50, boundary = 0, na.rm = TRUE) +
  labs(
    x = "Days Since Last Review", y = "Count",
    title = "Distribution of Days Since Last Review — Christchurch City"
  ) +
  theme_minimal()


# 3. Top 10% most-reviewed properties in NZ, Christchurch's share

review_threshold <- quantile(nz_latest$number_of_reviews, 0.90, na.rm = TRUE)

top_reviewed_nz <- christchurch_latest |>
  filter(number_of_reviews >= review_threshold)

n_top_total       <- nrow(top_reviewed_nz)
n_top_christchurch <- top_reviewed_nz |>
  filter(neighbourhood_group == "Christchurch City") |>
  nrow()

#proportion_christchurch <- n_top_christchurch / n_top_total

#n_top_total              # total listings in NZ's top 10% by reviews
#n_top_christchurch       # how many of those are in Christchurch
#proportion_christchurch  # Christchurch's share of the top 10%

#Cleaning Christchurch_latest dataset



