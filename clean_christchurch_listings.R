# ==============================================================================
# WEEK 8: DATA CLEANING AND PREPARATION
# ==============================================================================

library(tidyverse)
library(lubridate)

# Base directory where the datasets are stored
dir_path <- "../Data_Wrangling_Datasets"

# Define the monthly files and their corresponding month-year values
files_info <- tribble(
  ~file_tag,        ~month_year,
  "October_2025",   "October 2025",
  "November_2025",  "November 2025",
  "December_2025",  "December 2025",
  "January_2026",   "January 2026",
  "February_2026",  "February 2026",
  "March_2026",     "March 2026",
  "April_2026",     "April 2026",
  "May_2026",       "May 2026",
  "June_2026",      "June 2026"
)

# Read each monthly file and add the corresponding month-year
process_raw_file <- function(file_tag, month_year) {
  file_path <- file.path(dir_path, paste0("listings_", file_tag, ".csv"))
  read.csv(file_path) %>% 
    mutate(month_year = month_year)
}

# Combine all monthly datasets into one New Zealand dataset
newzealand_all <- map2_dfr(
  files_info$file_tag,
  files_info$month_year,
  process_raw_file
)

# Filter the dataset to include Christchurch City listings only
christchurch_all <- newzealand_all %>%
  filter(str_to_lower(neighbourhood_group) == "christchurch city")

# Check the number of records for each month
table(christchurch_all$month_year)

# Save the combined datasets as CSV files
write.csv(christchurch_all, file.path(dir_path, "christchurch_oct2025_jun2026_combined.csv"), row.names = FALSE)


# Check the number and percentage of missing values in each column by month
missing_summary <- christchurch_all %>%
  group_by(month_year) %>%
  summarise(across(everything(), 
                   list(missing = ~sum(is.na(.)), 
                        percentage = ~mean(is.na(.)) * 100))) %>%
  pivot_longer(
    cols = -month_year,
    names_to = c("column", ".value"),
    names_pattern = "(.*)_(missing|percentage)"
  )

missing_summary


# Remove the license column because it is 100% missing
christchurch_clean <- christchurch_all %>%
  select(-license)


# Check missing price values by month
# Price is important, so missing values are kept as NA
christchurch_all %>%
  group_by(month_year) %>%
  summarise(
    total_rows = n(),
    missing_price = sum(is.na(price)),
    price_available = sum(!is.na(price))
  )


# Check missing minimum_nights values by month
christchurch_all %>%
  group_by(month_year) %>%
  summarise(
    missing = sum(is.na(minimum_nights)),
    total = n(),
    percentage = mean(is.na(minimum_nights)) * 100
  )

# Remove rows where minimum_nights is missing
christchurch_clean <- christchurch_all %>%
  filter(!is.na(minimum_nights))

# ============================================================
# Map Christchurch Airbnb Listings to Matching Quarterly Periods
# ============================================================

# Filter to match the 9 months and create matching period labels
christchurch_aligned <- christchurch_clean %>%
  filter(
    month_year %in% c(
      "October 2025",  "November 2025", "December 2025",
      "January 2026",  "February 2026", "March 2026",
      "April 2026",    "May 2026",      "June 2026"
    )
  ) %>%
  mutate(
    # Map monthly records to exact quarterly TimeFrame dates
    Period = case_when(
      month_year %in% c("October 2025", "November 2025", "December 2025") ~ 
        "October-December 2025",
      
      month_year %in% c("January 2026", "February 2026", "March 2026") ~ 
        "January-March 2026",
      
      month_year %in% c("April 2026", "May 2026", "June 2026") ~ 
        "April-June 2026",
      
      TRUE ~ NA_character_
    )
  )

# ------------------------------------------------------------------------------
# 4. SAVE CLEANED DATASETS LOCALLY
# ------------------------------------------------------------------------------

# Standard CSV format
write.csv(christchurch_aligned, file.path(dir_path, "christchurch_aligned_oct2025_jun2026_combined.csv"), row.names = FALSE)