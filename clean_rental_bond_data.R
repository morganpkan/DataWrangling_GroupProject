library(tidyverse)
library(lubridate)

tenancy_raw <- read_csv('Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv')


#Time frame set to match christchurch airbnb dataset. Timeframe 2025-10-01 - 2026-04-01
tenancy <- tenancy_raw |>
  filter(TimeFrame >= as_date("2025-10-01"),
         TimeFrame <= as_date("2026-04-30"))



#Changed 'Location Id' column from char to int. 'NULL' became NA
tenancy <- tenancy |> mutate(`Location Id` = as.integer(`Location Id`))

#Removed 94 rows where Location ID was NA. Data would not be useable for next week deliverable. May create bias depending on why Location ID was missing.
tenancy <- tenancy |> filter(!is.na(`Location Id`))

#Changed Median, Geometric Mean, Upper Quartile, and Lower Quartile rents from char to numeric
tenancy <- tenancy |>
  mutate(across(c(`Median Rent`, `Geometric Mean Rent`, `Upper Quartile Rent`, `Lower Quartile Rent`),
                as.numeric))

#Changed Log Std Dev Weekly Rent from char to numeric.
tenancy <- tenancy |> mutate(`Log Std Dev Weekly Rent` = as.numeric(`Log Std Dev Weekly Rent`))