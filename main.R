# ==============================================================================
# WEEK 5 DELIVERABLES: DATA PREPARATION, CONCATENATION & SUMMARY STATISTICS
# ==============================================================================

library(tidyverse)
library(lubridate)

# Base directory where your datasets are stored
dir_path <- "../Data_Wrangling_Datasets"

# Define mapping of file tags and corresponding Month Year values (Oct 2025 - Jun 2026)
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

# Helper function to read raw dataset and add month_year column
process_raw_file <- function(file_tag, month_year) {
  file_path <- file.path(dir_path, paste0("listings_", file_tag, ".csv"))
  read.csv(file_path) %>% 
    mutate(month_year = month_year)
}


# --- Step 1: Process and concatenate all files (Oct 2025 to June 2026) into master datasets ---
newzealand_all <- map2_dfr(files_info$file_tag, files_info$month_year, process_raw_file)


# Filter dataset for Christchurch City only
christchurch_all <- newzealand_all %>%
  filter(str_to_lower(neighbourhood_group) == "christchurch city")

# Verify record counts per month
table(christchurch_all$month_year)
table(newzealand_all$month_year)

# --- Step 2: Store concatenated datasets into new files ---
write.csv(newzealand_all, file.path(dir_path, "newzealand_oct2025_jun2026_combined.csv"), row.names = FALSE)
write.csv(christchurch_all, file.path(dir_path, "christchurch_oct2025_jun2026_combined.csv"), row.names = FALSE)

# --- Step 3: Data Cleaning ---
new_zealand_clean <- newzealand_all %>%
  # Remove missing prices
  filter(!is.na(price)) %>%
  # Remove missing minimum_nights
  filter(!is.na(minimum_nights)) %>%
  # Replace NA in reviews_per_month with 0 (properties with no reviews)
  mutate(reviews_per_month = replace_na(reviews_per_month, 0)) %>%
  # Drop empty license column
  select(-license)

# Clean Christchurch dataset specifically
christchurch_clean <- new_zealand_clean %>%
  filter(str_to_lower(neighbourhood_group) == "christchurch city")

# Verify post-cleaning counts
table(christchurch_all$month_year)
table(newzealand_all$month_year)

# --- Step 4: Summary Statistics & Missing Values Analysis ---
# Summary statistics for all columns
summary(christchurch_clean)
summary(new_zealand_clean)

# Missing values count per column
colSums(is.na(christchurch_clean))
colSums(is.na(new_zealand_clean))


# ==============================================================================
# WEEK 4 DELIVERABLES: DISTRIBUTION PLOTS & REVIEW ANALYSIS
# ==============================================================================

# --- Task 1: Price Distribution Histograms ---

# Process a single raw file directly
christchurch_june2026 <- process_raw_file("June_2026", "June 2026") %>%
  filter(str_to_lower(neighbourhood_group) == "christchurch city")

new_zealand_june2026 <- process_raw_file("June_2026", "June 2026")

# Individual Histogram: All New Zealand
ggplot(new_zealand_june2026 %>% filter(price < 1000), aes(x = price)) +
  geom_histogram(binwidth = 25, fill = "skyblue", color = "black") +
  labs(
    title = "Price Distribution - All New Zealand",
    x = "Price ($)",
    y = "Count"
  ) +
  theme_minimal()

# Individual Histogram: Christchurch City Only
ggplot(christchurch_june2026 %>% filter(price < 1000), aes(x = price)) +
  geom_histogram(binwidth = 25, fill = "orange", color = "black") +
  labs(
    title = "Price Distribution - Christchurch City",
    x = "Price ($)",
    y = "Count"
  ) +
  theme_minimal()

# Overlaid Combined Histogram: New Zealand vs. Christchurch
combined_price_data <- bind_rows(
  new_zealand_june2026 %>% mutate(location = "All New Zealand"),
  christchurch_june2026 %>% mutate(location = "Christchurch City")
)

ggplot(combined_price_data %>% filter(price < 1000), aes(x = price, fill = location)) +
  geom_histogram(binwidth = 25, position = "identity", alpha = 0.5, color = "black") +
  scale_fill_manual(values = c("All New Zealand" = "skyblue", "Christchurch City" = "orange")) +
  labs(
    title = "Price Distribution Comparison: New Zealand vs. Christchurch",
    x = "Price ($)",
    y = "Count",
    fill = "Location"
  ) +
  theme_minimal()

# --- Task 2: Calculate Days Since Last Review & Plot Distribution ---
new_zealand_added_date <- new_zealand_june2026 %>%
  mutate(
    scrape_date = as.Date(case_when(
      str_detect(month_year, "June 2026")  ~ "2026-06-01",
      TRUE ~ NA_character_
    )),
    last_review_date = as.Date(last_review),
    days_since_last_review = as.numeric(scrape_date - last_review_date)
  )

# Histogram of days since last review
ggplot(new_zealand_added_date %>% filter(!is.na(days_since_last_review)), aes(x = days_since_last_review)) +
  geom_histogram(binwidth = 40, fill = "#2c7fb8", color = "black", alpha = 0.85) +
  labs(
    title = "Distribution of Days Since Last Review",
    subtitle = "Difference between scrape date and last review date",
    x = "Days Since Last Review",
    y = "Number of Listings"
  ) +
  theme_minimal()

# --- Task 3: Top 10% Most Reviewed Properties Analysis ---
# duplicate properties using the latest snapshot per property ID
latest_nz_properties <- new_zealand_june2026 %>%
  arrange(desc(month_year))

# Calculate 90th percentile threshold for top 10%
review_cutoff <- quantile(latest_nz_properties$number_of_reviews, probs = 0.90, na.rm = TRUE)


# Filter top 10% unique properties in New Zealand
top_10_percent_nz <- latest_nz_properties %>%
  filter(number_of_reviews >= review_cutoff)


# Count top 10% properties located in Christchurch City
chch_top_count <- top_10_percent_nz %>%
  filter(str_to_lower(neighbourhood_group) == "christchurch city") %>%
  nrow()

# Output the results
cat("90th Percentile Cutoff Threshold:", review_cutoff, "reviews\n")
cat("Total Unique Top 10% Properties in New Zealand:", nrow(top_10_percent_nz), "\n")
cat("Unique Top 10% Properties in Christchurch City:", chch_top_count, "\n")