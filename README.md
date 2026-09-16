# Data Wrangling Group Project

Group project for **DATA201 -- Data Wrangling**

## Authors

- Magesh Anbalagan
- Morgan Perry Kan
- Charlie Stridiron-Leiva
- Bhuvaneshwari Thirunavukarasu

------------------------------------------------------------------------

# Airbnb Listings -- New Zealand (June 2026)

## 📌 Project Overview

This project focuses on data wrangling and exploratory data analysis of the Inside Airbnb New Zealand (June 2026) dataset. Using KNIME Analytics Platform and R, we cleaned, transformed, and analysed Airbnb listing data to identify patterns in pricing, availability, room types, host activity, and neighbourhood distribution. The project demonstrates practical data preparation techniques.

## 🚀 Getting Started

Follow these steps to run the project locally in RStudio.

### 1. Clone the Repository

``` bash
git clone https://github.com/morganpkan/DataWrangling_GroupProject.git
```

### 2. Open the Project

- Open **RStudio**.
- Select **File → Open Project...**
- Navigate to the cloned repository.
- Open `DataWrangling_GroupProject.Rproj`.

### 3. Install Required Packages

Install the required R packages if they are not already installed.

``` r
install.packages(c("tidyverse"))
```

### 4. Load the Dataset

Ensure that the dataset (`listings.csv`) is available in the project directory (or in the `data/` folder if applicable).

Example:

``` r
data <- read.csv("listings.csv")
```

or

``` r
data <- read.csv("data/listings.csv")
```

### 5. Run the Analysis

Open `main.R` and click **Source**, or run:

``` r
source("main.R")
```

This will execute the data wrangling and analysis workflow.

## 📊 Dataset Information

| Attribute | Details |
|----|----|
| **Dataset Name** | Airbnb Listings - New Zealand (June 2026) |
| **Source** | Inside Airbnb |
| **Dataset File** | `listings.csv` |
| **File Format** | CSV |
| **Country** | New Zealand |
| **Collection Period** | June 2026 |
| **Data Provider** | Inside Airbnb |
| **Dataset Description** | Public Airbnb listing data containing information about hosts, properties, pricing, availability, and reviews. |
| **Official Website** | <https://insideairbnb.com/get-the-data/> |

## 📑 Dataset Columns

| Column | Description |
|----|----|
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

> **Note:** Column definitions are based on the Inside Airbnb data dictionary.

## 🛠 Tools Used

- **KNIME Analytics Platform**
  - Data cleaning
  - Data transformation
  - Data filtering
  - Data wrangling
  - Basic visualisation

## 📁 Repository Structure

``` text
DataWrangling_GroupProject/
│
├── .gitignore
├── DataWrangling_GroupProject.Rproj
├── README.md
├── main.R
└── test/
```

## 📄 Dataset License

The dataset is provided by **Inside Airbnb** for research and educational purposes.

Please refer to the official Inside Airbnb website for licensing details and updates.

## Detailed Quarterly Tenancy / Rental Bond Dataset

### Data Source

The rental bond dataset was obtained from **Tenancy Services, New Zealand**.

Official source:

<https://www.tenancy.govt.nz/about-tenancy-services/data-and-statistics/rental-bond-data/>

The dataset contains information about private rental bonds recorded by Tenancy Services. The detailed quarterly dataset uses tenancy start dates and SA2-2019 geographic area definitions.

Tenancy Services notes that privacy protection measures are applied to the data, including fixed random rounding and suppression where there are fewer than five bonds. The latest data may also be provisional because of ongoing migration to the new bond management system.

### Dataset Used

**File:** `Detailed-Quarterly-Tenancy-Q1-2020-Q3-2026.csv`

The dataset contains quarterly rental bond information from 2020 onwards.

### Columns

| Column | Description |
|----|----|
| `TimeFrame` | Start date representing the quarterly reporting period. |
| `Location Id` | Geographic identifier for the location. This is retained because it will be required when combining the bond dataset with the Airbnb dataset. |
| `Dwelling Type` | Type of dwelling, such as House, Flat, Apartment, Boarding House or Room. |
| `Number Of Beds` | Number of bedrooms associated with the dwelling. Values can include individual bedroom counts, `5+`, or `ALL`. |
| `Total Bonds` | Total number of bonds recorded for the relevant combination of time, location, dwelling type and bedroom category. |
| `Active Bonds` | Number of bonds that remain active in the dataset. |
| `Closed Bonds` | Number of bonds recorded as closed. |
| `Median Rent` | Median weekly rent for the relevant group. |
| `Geometric Mean Rent` | Geometric mean of weekly rent. |
| `Upper Quartile Rent` | Upper quartile of weekly rent. |
| `Lower Quartile Rent` | Lower quartile of weekly rent. |
| `Log Std Dev Weekly Rent` | Logarithmic standard deviation of weekly rent, representing variation in rental prices. |

### Data Cleaning

The following cleaning steps were applied:

1.  Converted `TimeFrame` to a proper R Date variable.
2.  Converted `Location Id` to an integer while retaining the column.
3.  Standardised the `Dwelling Type` values.
4.  Retained `Number Of Beds`, including `ALL` and `5+`, because bedroom information may be useful when combining datasets.
5.  Removed completely duplicated records.
6.  Checked bond-count variables for invalid negative values.
7.  Checked rental-price variables for invalid negative values.
8.  Checked the logical relationship between lower quartile, median and upper quartile rent.
9.  Removed records with missing `Location Id` from the final comparison dataset because geographic matching will be required later.
10. Retained `TimeFrame` and `Location Id` specifically for the future dataset-combination stage.

### Timeframe Filtering

The other dataset used in this project contains **monthly Airbnb data from October 2025 to June 2026**.

The Rental Bond dataset is provided on a **quarterly basis**, rather than monthly. Therefore, the Airbnb timeframe was matched to the corresponding quarterly periods available in the Rental Bond dataset.

The Airbnb dataset covers:

- October 2025
- November 2025
- December 2025
- January 2026
- February 2026
- March 2026
- April 2026
- May 2026
- June 2026

To align the two datasets, the monthly Airbnb period was grouped into the following three quarters:

| Rental Bond `TimeFrame` | Period  | Corresponding Airbnb months |
|-------------------------|---------|-----------------------------|
| `2025-10-01`            | Q4 2025 | October–December 2025       |
| `2026-01-01`            | Q1 2026 | January–March 2026          |
| `2026-04-01`            | Q2 2026 | April–June 2026             |

The Rental Bond dataset was therefore filtered to the following `TimeFrame` values:

`2025-10-01`, `2026-01-01`, and `2026-04-01`.

This approach ensures that both datasets cover the same overall period from **October 2025 to June 2026**, while respecting the different temporal granularities of the datasets. The quarterly Rental Bond data was not converted into artificial monthly observations.

### Columns Removed

No major analytical columns were removed from the final bond dataset. This was intentional because the next stage of the project requires combining the rental bond and Airbnb datasets.

`Location Id`, `TimeFrame`, `Dwelling Type`, and `Number Of Beds` were therefore retained to support future geographic, temporal and property-type comparisons.

### Output Files

The cleaning script produces the following output files:

- **cleaned_bond_data.csv** — The complete cleaned Rental Bond dataset after data cleaning and validation.

- **cleaned_bond_data_aligned.csv** — The filtered Rental Bond dataset containing only Q4 2025, Q1 2026, and Q2 2026. This is the final dataset intended for comparison and combination with the Airbnb dataset.

The aligned dataset retains important fields such as Location Id and TimeFrame to support geographical and temporal matching with the Airbnb dataset in the next stage of the analysis.
