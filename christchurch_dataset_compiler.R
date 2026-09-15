library(tidyverse) 
library(dplyr)
library(purrr)
library(readr)

# finds every csv in airbnb_datasets and compiles into list of filepaths
files <- list.files(path = "airbnb_datasets", pattern = "\\.csv$", full.names = TRUE)

# Files must have naming convention: listings_month_year.csv

### COMPILING DATASETS
# reads every csv in 'files', extracts month + year from each filename
compiled_data <- files |>
  map_df(~ read_csv(.x) |>
           mutate(
             source_file = .x,
             month_name  = str_extract(.x, "(?<=listings_)[a-zA-Z]+"), # regex to pull the string following listings_
             year        = str_extract(.x, "\\d{4}") # returns the first instance of four digits in a row, which is the year
           )
  )

compiled_data <- compiled_data |>
  group_by(month_name, year) |>
  mutate(scrape_date = max(last_review, na.rm = TRUE)) |>
  ungroup()

# filter down to Christchurch, then deduplicate based on most recent scrape
christchurch_latest <- compiled_data |>
  filter(neighbourhood_group == "Christchurch City") |>
  group_by(id) |>
  slice_max(scrape_date, n = 1, with_ties = FALSE) |>
  ungroup() |>
  mutate(days_since_review = as.numeric(scrape_date - as_date(last_review)))

# save the deduplicated Christchurch dataset for cleaning
write_csv(christchurch_latest, "christchurch.csv")
