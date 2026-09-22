# ============================================================
# DELIVERABLE 5: AIRBNB AND TENANCY COMPARISON
# ============================================================

library(tidyverse)
library(lubridate)

dir_path <- "../Data_Wrangling_Datasets"

# ============================================================
# 1. LOAD THE PREPARED AIRBNB DATA
# ============================================================

airbnb <- read_csv(
  file.path(dir_path, "airbnb_with_areacodes.csv")
)

# ============================================================
# 2. LOAD AND PREPARE THE TENANCY DATA
# Based on Morgan's cleaning work
# ============================================================

tenancy <- read_csv(
  file.path(
    dir_path,
    "Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv"
  )
)

# Keep the same timeframe as the Airbnb analysis
tenancy <- tenancy %>%
  filter(
    TimeFrame >= as_date("2025-10-01"),
    TimeFrame <= as_date("2026-04-30")
  )

# Make Location Id usable for joining
tenancy <- tenancy %>%
  mutate(`Location Id` = as.integer(`Location Id`)) %>%
  filter(!is.na(`Location Id`))

# Make the rent columns numeric
tenancy <- tenancy %>%
  mutate(
    across(
      c(
        `Median Rent`,
        `Geometric Mean Rent`,
        `Upper Quartile Rent`,
        `Lower Quartile Rent`
      ),
      as.numeric
    )
  )

# ============================================================
# 3. CHECK THE DATA BEFORE JOINING
# ============================================================

# Check the Airbnb scrape dates
sort(unique(airbnb$scrape_date))

# Check the tenancy quarters
sort(unique(tenancy$TimeFrame))

# Check the types of rental properties in the tenancy data
unique(tenancy$`Dwelling Type`)

# Check the bedroom categories
unique(tenancy$`Number Of Beds`)

# ============================================================
# 4. MATCH AIRBNB DATES TO TENANCY QUARTERS
# ============================================================

airbnb <- airbnb %>%
  mutate(
    TimeFrame = case_when(
      scrape_date >= as.Date("2025-10-01") &
        scrape_date <= as.Date("2025-12-31") ~ as.Date("2025-10-01"),
      
      scrape_date >= as.Date("2026-01-01") &
        scrape_date <= as.Date("2026-03-31") ~ as.Date("2026-01-01"),
      
      scrape_date >= as.Date("2026-04-01") &
        scrape_date <= as.Date("2026-06-30") ~ as.Date("2026-04-01"),
      
      TRUE ~ as.Date(NA)
    )
  )

table(airbnb$TimeFrame)

# ============================================================
# 5. KEEP ONE OVERALL RENTAL RECORD PER AREA AND QUARTER
# ============================================================

tenancy_overall <- tenancy %>%
  filter(
    `Dwelling Type` == "ALL",
    `Number Of Beds` == "ALL"
  )

# ============================================================
# 6. JOIN AIRBNB AND TENANCY DATA
# ============================================================

# Keep the tenancy columns we need
tenancy_join <- tenancy_overall %>%
  select(
    `Location Id`,
    TimeFrame,
    `Median Rent`,
    `Active Bonds`
  )

# Make sure the Airbnb area code is numeric
airbnb <- airbnb %>%
  mutate(sa2_code = as.integer(sa2_code))

# Join by area code AND quarter
airbnb_joined <- airbnb %>%
  left_join(
    tenancy_join,
    by = c(
      "sa2_code" = "Location Id",
      "TimeFrame" = "TimeFrame"
    )
  )

# Check that the join did not create extra Airbnb rows
nrow(airbnb)
nrow(airbnb_joined)

# How many Airbnb rows got a matching rental price?
sum(!is.na(airbnb_joined$`Median Rent`))

# How many did not get a rental price?
sum(is.na(airbnb_joined$`Median Rent`))

# Airbnb listings with no SA2 area code
sum(is.na(airbnb_joined$sa2_code))

# Airbnb listings that have an SA2 code but no matching tenancy rent
sum(
  !is.na(airbnb_joined$sa2_code) &
    is.na(airbnb_joined$`Median Rent`)
)

# ============================================================
# 7. CHRISTCHURCH CENTRAL AIRBNB PRICE
# ============================================================

central_airbnb <- airbnb_joined %>%
  filter(sa2_code == 326600)

median(
  central_airbnb$price,
  na.rm = TRUE
)

nrow(central_airbnb)

sum(!is.na(central_airbnb$price))

# ============================================================
# 8. COMPARE AIRBNB AND LONG-TERM RENTAL PRICES
# ============================================================

airbnb_joined <- airbnb_joined %>%
  mutate(
    rental_nightly = `Median Rent` / 7,
    price_gap = price - rental_nightly
  )

gap_by_area <- airbnb_joined %>%
  filter(
    !is.na(price_gap),
    !is.na(sa2_name)
  ) %>%
  group_by(sa2_code, sa2_name) %>%
  summarise(
    median_gap = median(price_gap, na.rm = TRUE),
    number_of_airbnbs = n(),
    .groups = "drop"
  ) %>%
  arrange(desc(median_gap))

head(gap_by_area, 10)


head(gap_by_area, 10)

# ============================================================
# 9. FOCUS ON AREAS WITH ENOUGH AIRBNB LISTINGS
# ============================================================

gap_by_area_reliable <- gap_by_area %>%
  filter(number_of_airbnbs >= 10) %>%
  arrange(desc(median_gap))

head(gap_by_area_reliable, 10)

# Take the 10 areas with the largest median gap
top_gap_areas <- gap_by_area_reliable %>%
  slice_head(n = 10)

ggplot(
  top_gap_areas,
  aes(
    x = reorder(sa2_name, median_gap),
    y = median_gap
  )
) +
  geom_col() +
  coord_flip() +
  labs(
    title = "Largest Airbnb vs Long-Term Rental Price Gaps",
    x = "SA2 Area",
    y = "Median Price Gap ($ per night)"
  ) +
  theme_minimal()

head(gap_by_area_reliable, 10)

# ============================================================
# 10. COMPARE AIRBNB NUMBERS WITH LONG-TERM RENTALS
# ============================================================

# Count unique Airbnbs in each area for April 2026
airbnb_counts <- airbnb_joined %>%
  filter(
    TimeFrame == as.Date("2026-04-01"),
    !is.na(sa2_code)
  ) %>%
  group_by(sa2_code, sa2_name) %>%
  summarise(
    airbnb_count = n_distinct(id),
    .groups = "drop"
  )

rental_counts <- tenancy_overall %>%
  filter(TimeFrame == as.Date("2026-04-01")) %>%
  select(
    sa2_code = `Location Id`,
    rental_count = `Active Bonds`
  )

property_counts <- airbnb_counts %>%
  inner_join(
    rental_counts,
    by = "sa2_code"
  )

property_counts %>%
  arrange(desc(airbnb_count)) %>%
  head(10)

# ============================================================
# 11. PLOT AIRBNB VS LONG-TERM RENTAL COUNTS
# ============================================================

top_property_counts <- property_counts %>%
  arrange(desc(airbnb_count)) %>%
  slice_head(n = 10) %>%
  pivot_longer(
    cols = c(airbnb_count, rental_count),
    names_to = "rental_type",
    values_to = "count"
  )

ggplot(
  top_property_counts,
  aes(
    x = reorder(sa2_name, count),
    y = count,
    fill = rental_type
  )
) +
  geom_col(position = "dodge") +
  coord_flip() +
  labs(
    title = "Airbnb Listings vs Active Rental Bonds",
    x = "SA2 Area",
    y = "Count",
    fill = "Rental Type"
  ) +
  theme_minimal()

# ============================================================
# FINAL RESULTS CHECK
# ============================================================

# 1. Christchurch Central median Airbnb price
central_result <- central_airbnb %>%
  summarise(
    total_airbnb_rows = n(),
    usable_prices = sum(!is.na(price)),
    median_airbnb_price = median(price, na.rm = TRUE)
  )

central_result


# 2. Largest raw median price gap
gap_by_area %>%
  slice_head(n = 1)


# 3. Largest median price gap with at least 10 Airbnbs
gap_by_area_reliable %>%
  slice_head(n = 1)


# 4. Christchurch Central Airbnb vs active rental bonds
property_counts %>%
  filter(sa2_code == 326600)


# 5. Join quality
cat("Airbnb rows before join:", nrow(airbnb), "\n")
cat("Airbnb rows after join:", nrow(airbnb_joined), "\n")
cat("Rows with matching tenancy rent:",
    sum(!is.na(airbnb_joined$`Median Rent`)), "\n")
cat("Rows with no matching tenancy rent:",
    sum(is.na(airbnb_joined$`Median Rent`)), "\n")
cat("Rows with no SA2 code:",
    sum(is.na(airbnb_joined$sa2_code)), "\n")