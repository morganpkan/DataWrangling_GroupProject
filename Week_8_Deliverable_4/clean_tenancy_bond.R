# ==========================================================================
# DELIVERABLE WEEK 8: DETAILED QUARTERLY TENANCY / RENTAL BOND DATA CLEANING
# ==========================================================================

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

input_file <- "Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv"

# ------------------------------------------------------------
# Read dataset
# ------------------------------------------------------------
# specified different representations of missing values so that empty strings, 
# NA, NULL and null are treated consistently as missing data.

bond_raw <- read_csv(
  file.path(dir_path, input_file),
  na = c("", "NA", "NULL", "null")
)

# ------------------------------------------------------------
# Inspect dataset
# ------------------------------------------------------------

glimpse(bond_raw) #see the structure and data types

dim(bond_raw) #the number of rows and columns

names(bond_raw) #shows all the column names

#Check column types because it needs to be converted to other types if needed

data.frame(Column = names(bond_raw), Type = sapply(bond_raw, class))

# Check missing values

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

# Convert TimeFrame to Date

bond_clean <- bond_raw %>%
  mutate(
    TimeFrame = as.Date(TimeFrame)
  )

# Clean Location Id

bond_clean <- bond_clean %>%
  mutate(
    `Location Id` = as.integer(`Location Id`)
  )

# Clean Number Of Beds
# Keeping values such as "ALL" and "5+".
# convert this column as character.

bond_clean <- bond_clean %>%
  mutate(
    `Number Of Beds` = as.character(`Number Of Beds`),
    `Number Of Beds` = na_if(`Number Of Beds`, "")
  )

# Standardise Dwelling Type

bond_clean <- bond_clean %>%
  mutate(
    `Dwelling Type` = str_trim(`Dwelling Type`),
    `Dwelling Type` = str_to_title(`Dwelling Type`)
  )

# Remove completely duplicated records

bond_clean <- bond_clean %>%
  distinct()

# Basic validity checks
# Bond counts should not be negative

bond_clean <- bond_clean %>%
  filter(
    `Total Bonds` >= 0,
    `Active Bonds` >= 0,
    `Closed Bonds` >= 0
  )

# Check rental price values

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

# Remove rows with missing Location Id

# Location Id is required for future geographic comparison with the Airbnb dataset.

bond_clean <- bond_clean %>%
  filter(
    !is.na(`Location Id`),
    `Location Id` != -99
  )

# ------------------------------------------------------------
# Save aligned bond dataset
# ------------------------------------------------------------

write.csv(
  bond_clean,
  file.path(dir_path, "cleaned_bond_data_aligned.csv"),
  row.names = FALSE
)
