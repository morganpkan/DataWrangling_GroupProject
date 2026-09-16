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

The dataset is provided by **Inside Airbnb** for research and
educational purposes.

Please refer to the official Inside Airbnb website for licensing details
and updates.
