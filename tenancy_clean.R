# ============================================================
# DELIVERABLE WEEK 8: DETAILED QUARTERLY TENANCY / RENTAL BOND DATA CLEANING
# ============================================================

# ------------------------------------------------------------
# 1. Load packages
# ------------------------------------------------------------

library(tidyverse)
library(lubridate)


# ------------------------------------------------------------
# 2. File paths
# ------------------------------------------------------------

dir_path <- "../Data_Wrangling_Datasets"

input_file <- "Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv"

output_file <- "cleaned_bond_data.csv"


# ------------------------------------------------------------
# 3. Read dataset
# ------------------------------------------------------------

bond_raw <- read_csv(
  file.path(dir_path, input_file),
  na = c("", "NA", "NULL", "null")
)


# ------------------------------------------------------------
# 4. Inspect dataset
# ------------------------------------------------------------

glimpse(bond_raw)

dim(bond_raw)

names(bond_raw)


# ------------------------------------------------------------
# 5. Check column types
# ------------------------------------------------------------

data.frame(
  Column = names(bond_raw),
  Type = sapply(bond_raw, class)
)


# ------------------------------------------------------------
# 6. Check missing values
# ------------------------------------------------------------

missing_summary <- bond_raw %>%
  summarise(
    across(
      everything(),
      ~ sum(is.na(.))
    )
  ) %>%
  pivot_longer(
    cols = everything(),
    names_to = "column",
    values_to = "missing_values"
  ) %>%
  arrange(desc(missing_values))

print(missing_summary)


# ------------------------------------------------------------
# 7. Check duplicate rows
# ------------------------------------------------------------

duplicate_count <- bond_raw %>%
  duplicated() %>%
  sum()

cat(
  "Number of duplicate rows:",
  duplicate_count,
  "\n"
)


# ------------------------------------------------------------
# 8. Convert TimeFrame to Date
# ------------------------------------------------------------

bond_clean <- bond_raw %>%
  mutate(
    TimeFrame = as.Date(TimeFrame)
  )


# ------------------------------------------------------------
# 9. Clean Location Id
# ------------------------------------------------------------

bond_clean <- bond_clean %>%
  mutate(
    `Location Id` = as.integer(`Location Id`)
  )


# ------------------------------------------------------------
# 10. Clean Number Of Beds
# ------------------------------------------------------------

# Keep values such as "ALL" and "5+".
# Therefore, treat this column as character.

bond_clean <- bond_clean %>%
  mutate(
    `Number Of Beds` = as.character(`Number Of Beds`),
    `Number Of Beds` = na_if(`Number Of Beds`, "")
  )


# ------------------------------------------------------------
# 11. Standardise Dwelling Type
# ------------------------------------------------------------

bond_clean <- bond_clean %>%
  mutate(
    `Dwelling Type` = str_trim(`Dwelling Type`),
    `Dwelling Type` = str_to_title(`Dwelling Type`)
  )


# ------------------------------------------------------------
# 12. Remove completely duplicated records
# ------------------------------------------------------------

bond_clean <- bond_clean %>%
  distinct()


# ------------------------------------------------------------
# 13. Basic validity checks
# ------------------------------------------------------------

# Bond counts should not be negative

bond_clean <- bond_clean %>%
  filter(
    `Total Bonds` >= 0,
    `Active Bonds` >= 0,
    `Closed Bonds` >= 0
  )


# ------------------------------------------------------------
# 14. Check rental price values
# ------------------------------------------------------------

# Rental prices should not be negative.
# NA values are retained because they may represent
# suppressed or unavailable values.

bond_clean <- bond_clean %>%
  filter(
    is.na(`Median Rent`) |
      `Median Rent` >= 0,
    
    is.na(`Geometric Mean Rent`) |
      `Geometric Mean Rent` >= 0,
    
    is.na(`Upper Quartile Rent`) |
      `Upper Quartile Rent` >= 0,
    
    is.na(`Lower Quartile Rent`) |
      `Lower Quartile Rent` >= 0
  )


# ------------------------------------------------------------
# 15. Check rent consistency
# ------------------------------------------------------------

# Expected relationship:
#
# Lower Quartile <= Median <= Upper Quartile

rent_check <- bond_clean %>%
  filter(
    !is.na(`Lower Quartile Rent`),
    !is.na(`Median Rent`),
    !is.na(`Upper Quartile Rent`)
  ) %>%
  filter(
    `Lower Quartile Rent` > `Median Rent` |
      `Median Rent` > `Upper Quartile Rent`
  )

cat(
  "Rows with inconsistent rent quartiles:",
  nrow(rent_check),
  "\n"
)


# ------------------------------------------------------------
# 16. Keep useful columns
# ------------------------------------------------------------

# Location Id and TimeFrame are retained because they
# will be required when combining the bond dataset
# with the Airbnb dataset.

bond_clean <- bond_clean %>%
  select(
    TimeFrame,
    `Location Id`,
    `Dwelling Type`,
    `Number Of Beds`,
    `Total Bonds`,
    `Active Bonds`,
    `Closed Bonds`,
    `Median Rent`,
    `Geometric Mean Rent`,
    `Upper Quartile Rent`,
    `Lower Quartile Rent`,
    `Log Std Dev Weekly Rent`
  )


# ------------------------------------------------------------
# 17. Align timeframe with Airbnb dataset
# ------------------------------------------------------------

# Airbnb dataset covers:
#
# October 2025
# November 2025
# December 2025
# January 2026
# February 2026
# March 2026
# April 2026
# May 2026
# June 2026
#
# The bond dataset is quarterly, so the equivalent periods are:
#
# Q4 2025 = October - December 2025
# Q1 2026 = January - March 2026
# Q2 2026 = April - June 2026


bond_aligned <- bond_clean %>%
  filter(
    TimeFrame %in% as.Date(c(
      "2025-10-01",
      "2026-01-01",
      "2026-04-01"
    ))
  )


# ------------------------------------------------------------
# 18. Create matching period labels
# ------------------------------------------------------------

bond_aligned <- bond_aligned %>%
  mutate(
    Period = case_when(

      TimeFrame == as.Date("2025-10-01") ~
        "October-December 2025",

      TimeFrame == as.Date("2026-01-01") ~
        "January-March 2026",

      TimeFrame == as.Date("2026-04-01") ~
        "April-June 2026",

      TRUE ~ NA_character_
    )
  )


# ------------------------------------------------------------
# 19. Remove rows with missing Location Id
# ------------------------------------------------------------

# Location Id is required for future geographic comparison
# with the Airbnb dataset.

bond_aligned <- bond_aligned %>%
  filter(
    !is.na(`Location Id`)
  )


# ------------------------------------------------------------
# 20. Check final timeframe
# ------------------------------------------------------------

cat("\n==============================\n")
cat("TIMEFRAME CHECK\n")
cat("==============================\n")

print(
  unique(
    bond_aligned %>%
      select(TimeFrame, Period)
  )
)


# ------------------------------------------------------------
# 21. Check Location Id
# ------------------------------------------------------------

cat("\n==============================\n")
cat("LOCATION CHECK\n")
cat("==============================\n")

cat(
  "Unique Location IDs:",
  n_distinct(bond_aligned$`Location Id`),
  "\n"
)


# ------------------------------------------------------------
# 22. Save aligned bond dataset
# ------------------------------------------------------------

write.csv(
  bond_aligned,
  file.path(dir_path, "cleaned_bond_data_aligned.csv"),
  row.names = FALSE
)


# ------------------------------------------------------------
# 23. Save complete cleaned dataset
# ------------------------------------------------------------

write.csv(
  bond_clean,
  file.path(dir_path, output_file),
  row.names = FALSE
)


# ------------------------------------------------------------
# 24. Final summary
# ------------------------------------------------------------

cat("\n==============================\n")
cat("FINAL DATASET SUMMARY\n")
cat("==============================\n")

cat(
  "Original rows:",
  nrow(bond_raw),
  "\n"
)

cat(
  "Cleaned rows:",
  nrow(bond_clean),
  "\n"
)

cat(
  "Aligned rows:",
  nrow(bond_aligned),
  "\n"
)

cat(
  "Number of columns:",
  ncol(bond_aligned),
  "\n"
)

cat(
  "Unique Location IDs:",
  n_distinct(bond_aligned$`Location Id`),
  "\n"
)

cat(
  "Time periods:",
  n_distinct(bond_aligned$TimeFrame),
  "\n"
)

cat("==============================\n")

# ------------------------------------------------------------
# 19. Remove rows with missing Location Id
# ------------------------------------------------------------

# Location Id is required for future geographic comparison
# with the Airbnb dataset.

bond_aligned <- bond_aligned %>%
  filter(
    !is.na(`Location Id`)
  )


# ------------------------------------------------------------
# 20. Check final timeframe
# ------------------------------------------------------------

cat("\n==============================\n")
cat("TIMEFRAME CHECK\n")
cat("==============================\n")

print(
  unique(
    bond_aligned %>%
      select(TimeFrame, Period)
  )
)


# ------------------------------------------------------------
# 21. Check Location Id
# ------------------------------------------------------------

cat("\n==============================\n")
cat("LOCATION CHECK\n")
cat("==============================\n")

cat(
  "Unique Location IDs:",
  n_distinct(bond_aligned$`Location Id`),
  "\n"
)


# ------------------------------------------------------------
# 22. Save aligned bond dataset
# ------------------------------------------------------------

write.csv(
  bond_aligned,
  file.path(dir_path, "cleaned_bond_data_aligned.csv"),
  row.names = FALSE
)


# ------------------------------------------------------------
# 23. Save complete cleaned dataset
# ------------------------------------------------------------

write.csv(
  bond_clean,
  file.path(dir_path, output_file),
  row.names = FALSE
)


# ------------------------------------------------------------
# 24. Final summary
# ------------------------------------------------------------

cat("\n==============================\n")
cat("FINAL DATASET SUMMARY\n")
cat("==============================\n")

cat(
  "Original rows:",
  nrow(bond_raw),
  "\n"
)

cat(
  "Cleaned rows:",
  nrow(bond_clean),
  "\n"
)

cat(
  "Aligned rows:",
  nrow(bond_aligned),
  "\n"
)

cat(
  "Number of columns:",
  ncol(bond_aligned),
  "\n"
)

cat(
  "Unique Location IDs:",
  n_distinct(bond_aligned$`Location Id`),
  "\n"
)

cat(
  "Time periods:",
  n_distinct(bond_aligned$TimeFrame),
  "\n"
)

cat("==============================\n")
