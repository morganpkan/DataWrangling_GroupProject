# Design Principles and Sanity Check -- Airbnb and Bond Data Pipeline

## 1. Overview

This document describes the design principles for the Python
data-wrangling pipeline used to combine Christchurch Airbnb listing data
with bond rental data.

The pipeline is implemented in the **Week 10 Deliverable Jupyter
Notebook** and follows this general process:

``` text
Airbnb CSV + Bond CSV
        |
        v
Data ingestion
        |
        v
Clean column names and standardise ID fields
        |
        v
Parse TimeFrame dates
        |
        v
Filter bond data to ALL dwelling types and ALL bedrooms
        |
        v
Inner join on SA2/location ID + TimeFrame
        |
        v
Calculate daily bond rent and price gap
        |
        v
Run automated sanity checks
        |
        v
Export combined CSV
```

------------------------------------------------------------------------

# 2. Inputs to the Pipeline

The pipeline accepts three path arguments:

``` python
run_pipeline(
    airbnb_csv_path,
    bond_csv_path,
    output_dir
)
```

### 2.1 Airbnb input

The Airbnb input used in the notebook is:

``` text
christchurch_airbnb_with_sa2.csv
```

The Airbnb dataset is expected to contain, among other fields, the
following columns used by the pipeline:

-   `id`
-   `price`
-   `sa2_code`
-   `TimeFrame`

The `sa2_code` field provides the spatial key used to connect Airbnb
listings with the bond dataset.

### 2.2 Bond input

The bond input is:

``` text
cleaned_bond_data_aligned.csv
```

The pipeline uses:

-   `Location Id`
-   `TimeFrame`
-   `Dwelling Type`
-   `Number Of Beds`
-   `Median Rent`

The bond dataset is filtered to rows where:

``` text
Dwelling Type = ALL
Number Of Beds = ALL
```

This creates the summary-level bond dataset used for the join.

### 2.3 Output directory

The pipeline creates the output directory if it does not already exist:

``` python
os.makedirs(output_dir, exist_ok=True)
```

The final output is written to:

``` text
output/christchurch_airbnb_with_sa2.csv
```

------------------------------------------------------------------------

# 3. Outputs from the Pipeline

The main output is a combined CSV containing Airbnb and bond information
for records that successfully match on the spatial and time-period keys.

The output contains the original Airbnb and selected bond fields,
together with calculated metrics.

## 3.1 `daily_bond_rent`

The pipeline converts the median weekly bond rent into a daily value:

``` python
merged_df["daily_bond_rent"] = merged_df["Median Rent"] / 7.0
```

Therefore:

``` text
daily_bond_rent = Median Rent / 7
```

## 3.2 `price_gap`

The pipeline calculates the difference between the Airbnb price and the
daily bond rent:

``` python
merged_df["price_gap"] = merged_df["price"] - merged_df["daily_bond_rent"]
```

Therefore:

``` text
price_gap = Airbnb price - daily bond rent
```

A positive value means the Airbnb price is numerically higher than the
calculated daily bond rent, while a negative value means it is lower.

## 3.3 Final output file

The final dataframe is exported using:

``` python
merged_df.to_csv(output_path, index=False)
```

The pipeline also returns `merged_df` to the notebook so that its shape
and contents can be inspected.

------------------------------------------------------------------------

# 4. Main Pipeline Steps

## 4.1 Data ingestion

The pipeline reads both input CSV files using pandas:

``` python
raw_airbnb = pd.read_csv(airbnb_csv_path)
raw_bond = pd.read_csv(bond_csv_path)
```

This keeps the data-loading process inside the reusable `run_pipeline()`
function.

------------------------------------------------------------------------

## 4.2 Clean column names

Whitespace is removed from column names:

``` python
raw_airbnb.columns = raw_airbnb.columns.str.strip()
raw_bond.columns = raw_bond.columns.str.strip()
```

This helps avoid problems caused by accidental spaces in column names.

------------------------------------------------------------------------

## 4.3 Standardise spatial IDs

The `clean_id()` helper function standardises ID values.

For example:

``` text
316700.0
```

is converted to:

``` text
316700
```

The function also removes surrounding whitespace and converts missing
IDs to an empty string.

It is applied to both join-key columns:

``` python
raw_airbnb['sa2_code'] = raw_airbnb['sa2_code'].apply(clean_id)
raw_bond['Location Id'] = raw_bond['Location Id'].apply(clean_id)
```

This ensures that equivalent spatial IDs have a consistent
representation before joining.

------------------------------------------------------------------------

## 4.4 Parse time periods

The pipeline converts the `TimeFrame` values into pandas datetime
values:

``` python
raw_airbnb['TimeFrame_dt'] = pd.to_datetime(
    raw_airbnb['TimeFrame'],
    dayfirst=True,
    errors='coerce'
)

raw_bond['TimeFrame_dt'] = pd.to_datetime(
    raw_bond['TimeFrame'],
    dayfirst=True,
    errors='coerce'
)
```

The new `TimeFrame_dt` field is then used as part of the join key.

Using `errors='coerce'` means values that cannot be parsed are converted
to missing datetime values rather than causing the entire pipeline to
fail at that step.

------------------------------------------------------------------------

## 4.5 Filter the bond dataset

The bond dataset is restricted to summary rows:

``` python
bond_summary = raw_bond[
    (raw_bond['Dwelling Type'].astype(str).str.upper() == 'ALL') &
    (raw_bond['Number Of Beds'].astype(str).str.upper() == 'ALL')
].copy()
```

This avoids mixing different dwelling types and bedroom categories when
calculating the bond-rent comparison.

------------------------------------------------------------------------

## 4.6 Join the datasets

The Airbnb and bond datasets are joined using:

-   `sa2_code` ↔ `Location Id`
-   `TimeFrame_dt` ↔ `TimeFrame_dt`

The pipeline uses an **inner join**:

``` python
merged_df = raw_airbnb.merge(
    bond_summary,
    left_on=["sa2_code", "TimeFrame_dt"],
    right_on=["Location Id", "TimeFrame_dt"],
    how="inner"
)
```

Therefore, only Airbnb records with a matching SA2/location ID and
matching time period in the filtered bond dataset are retained.

------------------------------------------------------------------------

## 4.7 Calculate derived metrics

Two new variables are calculated.

### Daily bond rent

``` python
merged_df["daily_bond_rent"] = merged_df["Median Rent"] / 7.0
```

### Price gap

``` python
merged_df["price_gap"] = (
    merged_df["price"] - merged_df["daily_bond_rent"]
)
```

These derived fields provide the basis for comparing Airbnb prices with
the corresponding daily bond-rent value.

------------------------------------------------------------------------

## 4.8 Automated quality-control checks

Before exporting the data, the pipeline calls:

``` python
verify_pipeline_handoff(raw_airbnb, merged_df)
```

The function checks that the final dataframe contains the essential
columns:

``` text
id
price
sa2_code
area_name
TimeFrame_dt
price_gap
```

It also checks the business rule that Airbnb prices must be positive:

``` python
invalid_prices = (final_df["price"] <= 0).sum()
assert invalid_prices == 0
```

If a required column is missing or an invalid price is detected, an
assertion fails and the pipeline stops before exporting the result.

------------------------------------------------------------------------

## 4.9 Export

The pipeline creates the output directory when required and removes an
existing file with the same output path before writing the new result.

The final dataframe is saved as:

``` text
output/christchurch_airbnb_with_sa2.csv
```

This provides a reproducible output from the pipeline.

------------------------------------------------------------------------

# 5. Example Sanity Check

A useful sanity check is to verify the calculation of `price_gap` for
one row in the final dataframe.

For example, take one output record and inspect:

``` text
price
Median Rent
daily_bond_rent
price_gap
```

The expected calculation is:

``` text
daily_bond_rent = Median Rent / 7

price_gap = price - daily_bond_rent
```

### Example

If one record has:

``` text
Airbnb price = 100
Median Rent = 560
```

then:

``` text
daily_bond_rent = 560 / 7
                = 80

price_gap = 100 - 80
          = 20
```

Therefore, the `price_gap` value for that record should be:

``` text
20
```

This is a simple manual check that the economic metric has been
calculated according to the intended formula.

## Additional automated sanity checks

The pipeline also performs automated checks before export:

1.  Required columns must exist in the final dataframe.
2.  Airbnb prices must be greater than zero.
3.  If either check fails, an `assert` statement stops the pipeline
    before the output is saved.

This provides a safety check between the transformation stage and the
final export.

------------------------------------------------------------------------

# 6. Overall Coding and Software Strategies

The project uses several software and coding practices to make the
pipeline easier to understand, reuse, and check.

## 6.1 Modular design

The pipeline is organised into reusable functions rather than putting
every operation into one long sequence of notebook commands.

For example:

``` python
def clean_id(val):
    ...
```

and:

``` python
def verify_pipeline_handoff(raw_df, final_df):
    ...
```

The main processing is contained in:

``` python
def run_pipeline(airbnb_csv_path, bond_csv_path, output_dir):
    ...
```

This makes individual responsibilities clearer and allows the pipeline
to be run again with different input/output paths.

------------------------------------------------------------------------

## 6.2 Descriptive variable and function names

Names such as:

``` text
raw_airbnb
raw_bond
bond_summary
merged_df
daily_bond_rent
price_gap
verify_pipeline_handoff
```

describe what the data or function represents.

This improves readability and makes the workflow easier for another team
member to understand.

------------------------------------------------------------------------

## 6.3 Avoiding duplicated transformation logic

The `clean_id()` function is defined once and then applied to both
datasets.

Instead of repeating the ID-cleaning operations separately, the same
function is reused:

``` python
raw_airbnb['sa2_code'] = raw_airbnb['sa2_code'].apply(clean_id)
raw_bond['Location Id'] = raw_bond['Location Id'].apply(clean_id)
```

This reduces duplicated code and helps keep the same cleaning rule
across datasets.

------------------------------------------------------------------------

## 6.4 Assertions for defensive programming

The `verify_pipeline_handoff()` function uses `assert` statements to
check important assumptions.

For example:

``` python
assert col in final_df.columns
```

and:

``` python
assert invalid_prices == 0
```

This is a defensive programming strategy because the pipeline does not
silently export data when an essential structural or business-rule check
has failed.

------------------------------------------------------------------------

## 6.5 Logging

The pipeline uses Python's `logging` module:

``` python
logging.info("Starting Pipeline Execution...")
```

and:

``` python
logging.info(
    f"Pipeline finished successfully. Output saved to: {output_path}"
)
```

This provides basic execution information and makes it easier to
identify when the pipeline starts and finishes.

------------------------------------------------------------------------

## 6.6 Explicit input and output paths

The pipeline receives file locations as function arguments:

``` python
run_pipeline(
    airbnb_csv_path=...,
    bond_csv_path=...,
    output_dir=...
)
```

This is preferable to hard-coding every path inside the transformation
logic because the same pipeline structure can be reused with different
locations.

------------------------------------------------------------------------

## 6.7 Reproducible processing

The transformations are explicitly defined in Python rather than relying
on manual spreadsheet operations.

The same sequence can therefore be rerun:

``` text
Read
→ Clean
→ Parse
→ Filter
→ Join
→ Calculate
→ Validate
→ Export
```

This supports reproducibility and makes the processing steps easier to
inspect and maintain.

------------------------------------------------------------------------

# 7. Design Principles Summary

The pipeline follows these main principles:

  -----------------------------------------------------------------------
  Principle                           Implementation
  ----------------------------------- -----------------------------------
  Clear inputs                        Airbnb and bond CSV paths are
                                      passed to `run_pipeline()`

  Consistent join keys                `clean_id()` standardises
                                      SA2/location IDs

  Consistent time representation      `TimeFrame_dt` is created for both
                                      datasets

  Controlled bond records             Bond data is filtered to `ALL`
                                      dwelling and bedroom categories

  Explicit joining                    Inner join uses spatial ID and time
                                      period

  Derived metrics                     `daily_bond_rent` and `price_gap`
                                      are calculated explicitly

  Quality control                     Required columns and positive
                                      prices are checked

  Reusable code                       Processing is organised into
                                      functions

  Readability                         Descriptive function and variable
                                      names are used

  Reproducibility                     The same processing sequence can be
                                      rerun

  Safe output                         The output directory is created and
                                      the final dataframe is exported
                                      after validation
  -----------------------------------------------------------------------

------------------------------------------------------------------------

# 8. Match Between Design and Implementation

The design described in this document matches the implementation in the
**Week 10 Deliverable Jupyter Notebook**:

-   The notebook reads two CSV inputs.
-   Column names are stripped of surrounding whitespace.
-   SA2/location IDs are standardised with `clean_id()`.
-   `TimeFrame` values are converted to `TimeFrame_dt`.
-   Bond records are filtered to `ALL` dwelling type and `ALL` bedrooms.
-   An inner join is performed using the spatial and time keys.
-   `daily_bond_rent` and `price_gap` are calculated.
-   `verify_pipeline_handoff()` checks required columns and positive
    Airbnb prices.
-   The combined dataframe is exported to CSV.
-   The resulting dataframe is returned and its shape is printed.

The design principles therefore describe the current pipeline rather
than an intended pipeline that is different from the implemented code.

------------------------------------------------------------------------

## AI Used

**ChatGPT (OpenAI)** was used to construct and organise this
design-principles document from the project's Week 10 Python notebook
and the stated deliverable requirements.
