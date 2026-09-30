# ===============================================================================
# WEEK 8 Deliverable: DATA CLEANING AND PREPARATION of Christchurch Listings Data
# ===============================================================================

# ------------------------------------------------------------------------------
# Load Required Libraries
# ------------------------------------------------------------------------------
# Import the tidyverse package suite for data manipulation, cleaning, and visualization

library(tidyverse)
library(lubridate)

# ------------------------------------------------------------------------------
# Define File Paths and File Names
# ------------------------------------------------------------------------------
# Set the relative folder directory path where raw datasets are stored

dir_path <- "../Data_Wrangling_Datasets"

# Specify the input CSV filename containing combined Christchurch listing data

input_file <- "christchurch_oct2025_jun2026_combined.csv"

# ------------------------------------------------------------------------------
# Read and Inspect Raw Dataset
# ------------------------------------------------------------------------------
# Construct full file path and load CSV while mapping empty strings, "NA", "NULL", and "null" to R's NA format

christchurch_all <- read_csv(file.path(dir_path, input_file), na = c("", "NA", "NULL", "null"))

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


# ------------------------------------------------------------------------------
# Map Christchurch Listings to Quarterly Timeframes
# ------------------------------------------------------------------------------
# Start pipe pipeline to filter target months and attach quarterly reference dates

christchurch_aligned <- christchurch_clean %>%
  filter(
    month_year %in% c(
      "October 2025", "November 2025", "December 2025",
      "January 2026", "February 2026", "March 2026",
      "April 2026", "May 2026", "June 2026"
    )
  ) %>%
  mutate(
    TimeFrame = case_when(
      month_year %in% c("October 2025", "November 2025", "December 2025") ~ 
        "01-10-2025",
      
      month_year %in% c("January 2026", "February 2026", "March 2026") ~ 
        "01-01-2026",
      
      month_year %in% c("April 2026", "May 2026", "June 2026") ~ 
        "01-04-2026",
      
      TRUE ~ NA_character_
    )
  )

# ------------------------------------------------------------------------------
# SAVE CLEANED DATASETS LOCALLY
# ------------------------------------------------------------------------------

# Standard CSV format

write.csv(christchurch_aligned, file.path(dir_path, "christchurch_aligned_oct2025_jun2026_combined.csv"), row.names = FALSE)
