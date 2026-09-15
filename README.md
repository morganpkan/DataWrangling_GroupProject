# Data Wrangling Group Project

Group project for **DATA201 -- Data Wrangling**

## Authors

-   Magesh Anbalagan
-   Morgan Perry Kan
-   Charlie Stridiron-Leiva
-   Bhuvaneshwari Thirunavukarasu

------------------------------------------------------------------------

# Airbnb Listings -- New Zealand (June 2026)

## 📌 Project Overview

This project focuses on data wrangling and exploratory data analysis of the Inside Airbnb New Zealand (June 2026) dataset. Using KNIME Analytics Platform and R, we cleaned, transformed, and analysed Airbnb listing data to identify patterns in pricing, availability, room types, host activity, and neighbourhood distribution. The project demonstrates practical data preparation techniques.

## 🚀 Getting Started

Follow these steps to run the project locally in RStudio.

### 1. Clone the Repository

```bash
git clone https://github.com/morganpkan/DataWrangling_GroupProject.git
```

### 2. Open the Project

- Open **RStudio**.
- Select **File → Open Project...**
- Navigate to the cloned repository.
- Open `DataWrangling_GroupProject.Rproj`.

### 3. Install Required Packages

Install the required R packages if they are not already installed.

```r
install.packages(c("tidyverse"))
```

### 4. Load the Dataset

Ensure that the dataset (`listings.csv`) is available in the project directory (or in the `data/` folder if applicable).

Example:

```r
data <- read.csv("listings.csv")
```

or

```r
data <- read.csv("data/listings.csv")
```

### 5. Run the Analysis

Open `main.R` and click **Source**, or run:

```r
source("main.R")
```

This will execute the data wrangling and analysis workflow.

## 📊 Dataset Information

| Attribute | Details |
|-----------|---------|
| **Dataset Name** | Airbnb Listings - New Zealand (June 2026) |
| **Source** | Inside Airbnb |
| **Dataset File** | `listings.csv` |
| **File Format** | CSV |
| **Country** | New Zealand |
| **Collection Period** | June 2026 |
| **Data Provider** | Inside Airbnb |
| **Dataset Description** | Public Airbnb listing data containing information about hosts, properties, pricing, availability, and reviews. |
| **Official Website** | https://insideairbnb.com/get-the-data/ |

## 📑 Dataset Columns

| Column | Description |
|---------|-------------|
| **id** | Unique identifier for each Airbnb listing |
| **name** | Listing title |
| **host_id** | Unique identifier for the host |
| **host_name** | Name of the host |
| **neighbourhood_group** | Region or city grouping |
| **neighbourhood** | Specific neighbourhood |
| **latitude** | Latitude coordinate |
| **longitude** | Longitude coordinate |
| **room_type** | Type of accommodation (Entire home/apartment, Private room, Shared room, etc.) |
| **price** | Nightly price (NZD) |
| **minimum_nights** | Minimum number of nights required for booking |
| **number_of_reviews** | Total number of reviews received |
| **last_review** | Date of the most recent review |
| **reviews_per_month** | Average reviews per month |
| **calculated_host_listings_count** | Number of listings managed by the host |
| **availability_365** | Number of days available in a year |
| **number_of_reviews_ltm** | Reviews received in the last 12 months |
| **license** | License or registration information (if available) |

> **Note:** Column definitions are based on the Inside Airbnb data
> dictionary.

## 🛠 Tools Used

-   **KNIME Analytics Platform**
    -   Data cleaning
    -   Data transformation
    -   Data filtering
    -   Data wrangling
    -   Basic visualisation

## 📁 Repository Structure

```text
DataWrangling_GroupProject/
│
├── .gitignore
├── DataWrangling_GroupProject.Rproj
├── README.md
├── main.R
└── test/
```

## 📄 Dataset License

The dataset is provided by **Inside Airbnb** for research and
educational purposes.

Please refer to the official Inside Airbnb website for licensing details
and updates.

# Rental Bond Dataset — README

## Source
**Detailed quarterly report, January 2020 – April 2026**
Ministry of Business, Innovation and Employment (MBIE) / Tenancy Services
https://www.tenancy.govt.nz/about-tenancy-services/data-and-statistics/rental-bond-data/

Covers private-sector rental bonds lodged since January 1993, listed by tenancy start date using SA2-2019 area definitions from Statistics NZ. Privacy protection is applied: fixed random rounding to base 3, and suppression of results where fewer than 5 bonds exist for a given selection.

The data is made available under a Creative Commons Attribution 3.0 New Zealand licence — free to use for analysis, provided MBIE is credited as the source.

## Columns

| Column | Meaning |
|---|---|
| `Location Id` | Geographic area code based on Stats NZ's SA2-2019 classification (roughly suburb-sized statistical areas). Can be cross-referenced at the Stats NZ Geographic Data Service (https://datafinder.stats.govt.nz/layer/123515-statistical-area-2-2026/)|
| `TimeFrame` | Quarter-start date the row represents (e.g. `2025-10-01` = Q4 2025: Oct/Nov/Dec) |
| `Dwelling Type` | Category of dwelling the bond relates to (e.g. house, apartment); includes an `"ALL"` rollup category representing the total across all dwelling types, alongside the specific type breakdowns |
| `Number Of Beds` | Bedroom count category for the properties in this row; includes an `"ALL"` rollup category representing the total across all bedroom counts, alongside specific breakdowns (`1`, `2`, `3`, `4`, `5`, `5+`, `6`, `9`) |
| `Total Bonds` | Total number of bonds lodged for this Location/TimeFrame/Dwelling Type combination |
| `Active Bonds` | Number of currently active bonds |
| `Closed Bonds` | Number of bonds that have been closed/refunded |
| `Median Rent` | Traditional median weekly rent (NZD) |
| `Geometric Mean Rent` | An alternative to the standard median. Because rents cluster around round numbers (e.g. $300 is far more common than $297.50), standard medians tend to plateau for months before jumping by $10-20, making time-series analysis difficult. The geometric mean (the nth root of the product of values) closely approximates the median when the data follows a log-normal distribution, which is common for variables that can't go below zero, like rent |
| `Upper Quartile Rent` | A "synthetic" 75th percentile, estimated under the same log-normal distribution assumption as the geometric mean, rather than read directly off the raw data. This avoids the same round-number plateauing issue affecting standard quartiles |
| `Lower Quartile Rent` | A synthetic 25th percentile, calculated the same way as the upper quartile |
| `Log Std Dev Weekly Rent` | Standard deviation of log(weekly rent) — a measure of rent dispersion/spread, consistent with the log-normal approach used for the geometric mean and synthetic quartiles |