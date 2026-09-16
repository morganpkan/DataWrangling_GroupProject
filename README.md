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

## 📊 Dataset Information — Airbnb Listings (New Zealand)

| Attribute | Details |
|-----------|---------|
| **Dataset Name** | Christchurch Airbnb Listings (Combined Oct 2025 – Jun 2026) |
| **Source** | Inside Airbnb |
| **Dataset File** | `christchurch_aligned_oct2025_jun2026_combined.csv` |
| **File Format** | CSV / Parquet |
| **Country** | New Zealand (Christchurch City) |
| **Collection Period** | October 2025 – June 2026 (Monthly) |
| **Data Provider** | Inside Airbnb |
| **Dataset Description** | Public Airbnb listing data for Christchurch City containing host details, property coordinates, room types, pricing, availability, and review metrics across 9 monthly snapshots. |
| **Official Website** | https://insideairbnb.com/get-the-data/ |

## 📑 Dataset Columns — Airbnb Listings (Christchurch)

| Column | Description |
|---------|-------------|
| **id** | Unique identifier for each Airbnb listing. Retained as primary property key. |
| **name** | Title/name of the listing property. |
| **host_id** | Unique identifier for the host managing the listing. |
| **host_name** | Display name of the host. |
| **neighbourhood_group** | Region grouping (`Christchurch City`). |
| **neighbourhood** | Local ward or specific neighbourhood name. |
| **latitude** | Latitude coordinate. **Mandatory:** Retained for spatial location mapping. |
| **longitude** | Longitude coordinate. **Mandatory:** Retained for spatial location mapping. |
| **room_type** | Accommodation classification (`Entire home/apt`, `Private room`, `Shared room`). |
| **price** | Nightly listing price (NZD). Missing values retained as `NA` to preserve active supply counts. |
| **minimum_nights** | Minimum night stay requirement. Cleaned (37 missing rows removed). |
| **number_of_reviews** | Total count of cumulative reviews received. |
| **last_review** | Date of the most recent review logged. |
| **reviews_per_month** | Average monthly review volume. Missing values retained as `NA`. |
| **calculated_host_listings_count** | Total active listings managed by the host. |
| **availability_365** | Total available booking days within a 365-day calendar. |
| **number_of_reviews_ltm** | Total review count received in the past 12 months. |
| **month_year** | Source monthly collection label (e.g., `"October 2025"`). |
| **Period** | **Added Key:** Quarterly reporting period label (`"October-December 2025"`, `"January-March 2026"`, `"April-June 2026"`) for merging with bond data. |

## 📊 Dataset Information — Tenancy Services Rental Bond Data

| Attribute | Details |
|-----------|---------|
| **Dataset Name** | Detailed Quarterly Tenancy Bond Data (2020–2026) |
| **Source** | Tenancy Services, New Zealand |
| **Dataset File** | `cleaned_bond_data_aligned.csv` |
| **File Format** | CSV / Parquet |
| **Country** | New Zealand |
| **Collection Period** | October 2025 – June 2026 (Aligned to Q4 2025, Q1 2026, Q2 2026) |
| **Data Provider** | Ministry of Business, Innovation and Employment (MBIE) |
| **Dataset Description** | Public private-sector rental bond lodgements recorded by tenancy start dates using Statistics NZ SA2 (2019) boundaries. Includes fixed random rounding to base 3 and privacy suppression (<5 bonds). |
| **Official Website** | [Tenancy Services Rental Bond Data](https://www.tenancy.govt.nz/about-tenancy-services/data-and-statistics/rental-bond-data/) |

## 📑 Dataset Columns — Tenancy Services Rental Bond Data

| Column | Description |
|---------|-------------|
| **TimeFrame** | Start date representing the quarterly period (`YYYY-MM-DD`). **Mandatory:** Retained as primary join key. |
| **Location Id** | Geographic area identifier corresponding to Statistics NZ SA2 (2019) boundaries. **Mandatory:** Retained as spatial key. |
| **Dwelling Type** | Property classification (`ALL`, `Apartment`, `Flat`, `House`, `Boarding House`, `Room`). |
| **Number Of Beds** | Bedroom count classification (`1`, `2`, `3`, `4`, `5+`, `ALL`). |
| **Total Bonds** | Total number of new rental bonds lodged during the period. |
| **Active Bonds** | Total active rental bonds held at the end of the period. |
| **Closed Bonds** | Total rental bonds refunded or closed during the period. |
| **Median Rent** | Median weekly rent (NZD). Primary metric for long-term price comparisons. |
| **Geometric Mean Rent** | Geometric mean of weekly rent (NZD). |
| **Upper Quartile Rent** | 75th percentile weekly rent (NZD). |
| **Lower Quartile Rent** | 25th percentile weekly rent (NZD). |
| **Log Std Dev Weekly Rent** | Logarithmic standard deviation of weekly rent, measuring price variation. |
| **Period** | **Added Key:** Standardized period label (`"October-December 2025"`, `"January-March 2026"`, `"April-June 2026"`) matching Airbnb quarterly alignment. |

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
├── clean_christchurch_listings.R
├── clean_tenancy_bond.R
└── test/
```

## 📄 Dataset Licenses & Attribution

### 1. Inside Airbnb Dataset
- **Provider:** [Inside Airbnb](https://insideairbnb.com/get-the-data/)
- **License & Usage:** Provided as open data for non-commercial research, public policy analysis, and educational purposes.
- **Terms:** Please refer to the official [Inside Airbnb Data Policies](https://insideairbnb.com/about/) for full licensing guidelines and data usage terms.

### 2. Tenancy Services Rental Bond Dataset
- **Provider:** [Tenancy Services New Zealand](https://www.tenancy.govt.nz/about-tenancy-services/data-and-statistics/rental-bond-data/) (Ministry of Business, Innovation and Employment — MBIE)
- **Copyright & Open Data:** Crown copyright material licensed under the [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/) license.
- **Privacy Controls:** Data includes automated privacy protection measures applied by MBIE, including fixed random rounding to base 3 and suppression of cell values where bond counts are below 5.

# Deliverable 8: Data Preprocessing and Cleaning Documentation

## 1. Christchurch Airbnb Listings Dataset

### Cleaning Decisions for Christchurch

- **License:** The `license` column was removed. It contained missing values for 100% of observations across all nine months, providing no usable information for the analysis.
- **Minimum nights:** Rows with missing `minimum_nights` values were removed — 37 rows (0.13% of the dataset).
- **Reviews per month:** Missing values in `reviews_per_month` were retained as `NA`. Rows were not removed on this basis, as doing so would cause unnecessary data loss. No imputation was performed.
- **Price:** The `price` column was retained, as it is required for the planned rental price comparison. Missing values were kept as `NA` rather than removed or imputed. December 2025, January 2026, and February 2026 have no recorded prices; removing these rows would exclude all listings from those months entirely. Observations with missing prices can be excluded at the analysis stage where required.
- **Spatial Keys:** Preserved `latitude` and `longitude` coordinates to enable geographic mapping in subsequent analysis steps.
- **Timeframe Alignment:** Added a standardized `Period` column mapping monthly records to quarterly reporting windows (`"October-December 2025"`, `"January-March 2026"`, and `"April-June 2026"`) to align with the Tenancy Services bond dataset.

### Dataset Size Before and After Cleaning — Christchurch Airbnb Listings

| Stage | Observations | Variables |
|---|---:|---:|
| Raw combined dataset (Oct 2025 – Jun 2026) | 28,795 | 19 |
| Final cleaned & aligned dataset (`christchurch_aligned`) | 28,758 | 19 |
| Rows removed (missing `minimum_nights`) | 37 | – |
| Columns removed | – | 1 (`license`) |
| Columns added | – | 1 (`Period`) |

> **Timeframe Alignment Note:** The Christchurch Airbnb listings were filtered and grouped across the exact same 9 months timeframe (**October 2025 to June 2026**) to match the quarterly reporting periods of the rental bond dataset.

### Output Files — Christchurch

The cleaning and alignment script generates the following output files for Christchurch:

- **`christchurch_oct2025_jun2026_combined.csv`**: The initial combined dataset containing raw Christchurch City observations across all nine monthly files prior to cleaning.
- **`christchurch_aligned_oct2025_jun2026_combined.csv`**: The final cleaned and aligned Christchurch dataset. It excludes the empty `license` column, drops rows missing `minimum_nights`, and includes the standardized `Period` quarterly labels.

## 2. Tenancy Services Rental Bond Dataset

### Data Cleaning & Validation Rules

The following processing steps were applied to the Tenancy Services rental bond dataset:

1. **Date Parsing:** Converted `TimeFrame` text strings into a standard R `Date` object (`YYYY-MM-DD`).
2. **Key Retention:** Retained `Location Id` as an integer and preserved `TimeFrame` specifically to support temporal and spatial joining in the dataset-combination stage.
3. **Data Type Standardization:** Standardized `Dwelling Type` text values and verified structural formatting.
4. **Bedroom Count Preservation:** Retained `Number Of Beds` (including `"ALL"` and `"5+"`) to enable property-type stratification during rental price comparisons.
5. **Deduplication:** Identified and removed 100% identical duplicate rows across the dataset.
6. **Numeric Auditing:** Audited `Total Bonds`, `Active Bonds`, and `Closed Bonds` for non-sensical negative counts.
7. **Price Integrity Auditing:** Audited `Median Rent`, `Geometric Mean Rent`, `Upper Quartile Rent`, and `Lower Quartile Rent` for negative values and verified the logical inequality relationship: `Lower Quartile Rent <= Median Rent <= Upper Quartile Rent`.
8. **Geographic Cleaning:** Dropped observations missing a valid `Location Id` (and excluded national aggregate rows `-99`) to ensure clean geographical matching.
9. **Missing Value Handling:** Replaced string `"NULL"` placeholders across price metrics with explicit `NA` values.

### Timeframe Harmonization

The Airbnb dataset covers monthly snapshots from **October 2025 to June 2026**. Because the Rental Bond dataset is published on a **quarterly basis**, the Airbnb timeframe was harmonized to match the available quarterly periods in the Rental Bond dataset:

| Rental Bond `TimeFrame` | Standardized `Period` Label | Corresponding Airbnb Months |
|-------------------------|-----------------------------|-----------------------------|
| **2025-10-01**          | Q4 2025 (`October–December 2025`) | October 2025, November 2025, December 2025 |
| **2026-01-01**          | Q1 2026 (`January–March 2026`)    | January 2026, February 2026, March 2026 |
| **2026-04-01**          | Q2 2026 (`April–June 2026`)       | April 2026, May 2026, June 2026 |

The Rental Bond dataset was filtered strictly to `TimeFrame` values `2025-10-01`, `2026-01-01`, and `2026-04-01`. This ensures both datasets cover the exact period from **October 2025 to June 2026** without constructing artificial monthly bond estimates.

### Dataset Size Before and After Cleaning — Tenancy Services Rental Bond Data

| Stage | Observations | Variables |
|---|---:|---:|
| Raw dataset (2020–2026) | 226,080 | 12 |
| After cleaning & validation (`bond_clean`) | 226,080 | 12 |
| Final aligned dataset (`bond_aligned`) | 27,118 | 13 |
| Rows removed (filtering to Q4 2025 – Q2 2026) | 198,962 | – |
| Columns removed | – | 0 |
| Columns added | – | 1 (`Period`) |

> **Timeframe Alignment Note:** The rental bond dataset was filtered strictly to **Q4 2025 (`2025-10-01`)**, **Q1 2026 (`2026-01-01`)**, and **Q2 2026 (`2026-04-01`)**. This ensures it covers the exact same months (**October 2025 to June 2026**) as the Christchurch Airbnb dataset for a direct baseline comparison.

### Output Files — Tenancy Services

The bond preprocessing pipeline produces the following output files:

- **`cleaned_bond_data.csv`**: The complete, validated Rental Bond dataset after null conversion and data type cleaning.
- **`cleaned_bond_data_aligned.csv`**: The final filtered Rental Bond dataset restricted to Q4 2025, Q1 2026, and Q2 2026. This dataset is optimized for direct merging with the Christchurch Airbnb dataset.
