import os
import sys
import shutil
import subprocess
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import seaborn as sns

# Set visual style for plots
sns.set_theme(style="whitegrid")

# ==============================================================================
# DYNAMIC PATH RESOLUTION
# ==============================================================================
def resolve_dataset_directory():
    """Dynamically locates and cleans the dataset folder path."""
    candidate_paths = [
        r"C:\Users\MAGGIE\OneDrive\Documents\Data_Wrangling_Datasets",
        os.path.abspath("../Data_Wrangling_Datasets"),
        os.path.abspath("./Data_Wrangling_Datasets"),
        os.path.abspath(".")
    ]

    for path in candidate_paths:
        clean_p = path.strip().strip('"').strip("'")
        if os.path.exists(clean_p):
            files = os.listdir(clean_p)
            has_csv = any(f.lower().endswith(".csv") for f in files)
            if has_csv:
                return os.path.abspath(clean_p)

    return r"C:\Users\MAGGIE\OneDrive\Documents\Data_Wrangling_Datasets"


DIR_PATH = resolve_dataset_directory().strip()


def find_rscript():
    """Locates the Rscript executable on Windows or system PATH."""
    rscript_path = shutil.which("Rscript")
    if rscript_path:
        return rscript_path

    default_r_dir = r"C:\Program Files\R"
    if os.path.exists(default_r_dir):
        versions = os.listdir(default_r_dir)
        for ver in sorted(versions, reverse=True):
            candidate = os.path.join(default_r_dir, ver, "bin", "Rscript.exe")
            if os.path.exists(candidate):
                return candidate

    return None


def run_airbnb_pipeline():
    """Executes R preprocessing for Airbnb data and exports PNGs, interactive plots, and a multi-page PDF."""
    abs_dir_path = os.path.abspath(DIR_PATH).strip()
    os.makedirs(abs_dir_path, exist_ok=True)
    print(f"[INFO] Using Dataset Directory: '{abs_dir_path}'")

    # --------------------------------------------------------------------------
    # STEP 1: R PREPROCESSING (AIRBNB ONLY)
    # --------------------------------------------------------------------------
    print("\n--- Step 1: Running R Airbnb Preprocessing ---")

    rscript_bin = find_rscript()
    if not rscript_bin:
        print("[CRITICAL ERROR] Rscript.exe was not found on your system!")
        print("Please ensure R is installed at 'C:\\Program Files\\R' or added to system PATH.")
        sys.exit(1)

    r_dir_path = abs_dir_path.replace("\\", "/").rstrip("/")
    temp_r_script = os.path.join(abs_dir_path, "temp_airbnb_preprocessing.R")

    r_code = f"""
    options(warn = 1)
    dir_path <- trimws("{r_dir_path}")

    suppressPackageStartupMessages({{
      library(tidyverse)
      library(lubridate)
    }})

    cat("R Working Directory Path: '", dir_path, "'\\n", sep = "")

    all_csv_files <- list.files(dir_path, pattern = "\\\\.csv$", full.names = TRUE, ignore.case = TRUE)
    base_names <- basename(all_csv_files)
    
    listings_mask <- grepl("^listings.*\\\\.csv$", base_names, ignore.case = TRUE) & 
                     !grepl("combined|aligned|sa2|summary|cleaned", base_names, ignore.case = TRUE)
    
    listings_files <- all_csv_files[listings_mask]

    cat("Raw Airbnb listings files found:", length(listings_files), "\\n")

    process_raw_file <- function(file_path) {{
      cat("  -> Loading dataset:", basename(file_path), "\\n")
      df <- read.csv(file_path, na.strings = c("", "NA", "NULL", "null"), check.names = FALSE)
      names(df) <- str_to_lower(gsub("[^[:alnum:]_]", "", names(df)))
      
      file_name <- basename(file_path)
      df$month_year <- file_name
      
      if ("price" %in% names(df)) {{
        df$price <- as.numeric(gsub("[$,]", "", as.character(df$price)))
      }} else {{
        df$price <- NA_real_
      }}
      return(df)
    }}

    if (length(listings_files) > 0) {{
      newzealand_all <- map_dfr(listings_files, process_raw_file)
    }} else {{
      stop("CRITICAL: No raw listings CSV files matching 'listings*.csv' were found in DIR_PATH!")
    }}

    if (!"price" %in% names(newzealand_all)) newzealand_all$price <- numeric(0)
    if (!"month_year" %in% names(newzealand_all)) newzealand_all$month_year <- character(0)

    match_christchurch <- function(df, col_name) {{
      if (col_name %in% names(df)) {{
        str_detect(str_to_lower(coalesce(as.character(df[[col_name]]), "")), "christchurch")
      }} else {{
        rep(FALSE, nrow(df))
      }}
    }}

    christchurch_all <- newzealand_all %>%
      filter(
        match_christchurch(., "neighbourhood_group") |
        match_christchurch(., "neighbourhood_cleansed") |
        match_christchurch(., "neighbourhood") |
        match_christchurch(., "city")
      )

    cat("Total rows after Christchurch text filter:", nrow(christchurch_all), "\\n")

    if (nrow(christchurch_all) == 0 && all(c("latitude", "longitude") %in% names(newzealand_all))) {{
      cat("Text filter returned 0 rows. Attempting spatial coordinate bounding box filtering...\\n")
      christchurch_all <- newzealand_all %>%
        mutate(
          lat_num = as.numeric(as.character(latitude)),
          lon_num = as.numeric(as.character(longitude))
        ) %>%
        filter(between(lat_num, -43.65, -43.35) & between(lon_num, 172.40, 172.80)) %>%
        select(-lat_num, -lon_num)
      cat("Total rows after spatial bounding box filter:", nrow(christchurch_all), "\\n")
    }}

    if (nrow(christchurch_all) == 0) {{
      cat("Warning: All Christchurch filters returned 0 rows. Using all listings data instead.\\n")
      christchurch_all <- newzealand_all
    }}

    write.csv(newzealand_all, file.path(dir_path, "newzealand_oct2025_aug2026_combined.csv"), row.names = FALSE)
    write.csv(christchurch_all, file.path(dir_path, "christchurch_oct2025_aug2026_combined.csv"), row.names = FALSE)

    christchurch_aligned <- christchurch_all %>%
      mutate(
        month_year_str = as.character(month_year),
        TimeFrame = case_when(
          str_detect(month_year_str, "(?i)october|november|december") ~ "01-10-2025",
          str_detect(month_year_str, "(?i)january|february|march")   ~ "01-01-2026",
          str_detect(month_year_str, "(?i)april|may|june")         ~ "01-04-2026",
          str_detect(month_year_str, "(?i)july|august")           ~ "01-07-2026",
          TRUE ~ "01-10-2025"
        )
      ) %>%
      select(-month_year_str)

    write.csv(christchurch_aligned, file.path(dir_path, "christchurch_aligned_oct2025_aug2026_combined.csv"), row.names = FALSE)
    cat("--- R Preprocessing Complete ---\\n")
    """

    with open(temp_r_script, "w", encoding="utf-8") as f:
        f.write(r_code)

    try:
        process = subprocess.run(
            [rscript_bin, temp_r_script],
            capture_output=True,
            text=True,
            check=True
        )
        print(process.stdout)
    except subprocess.CalledProcessError as err:
        print("\n================ R EXECUTION ERROR ================")
        if err.stdout:
            print("STDOUT:", err.stdout)
        if err.stderr:
            print("STDERR:", err.stderr)
        print("====================================================\n")
        sys.exit(1)
    finally:
        if os.path.exists(temp_r_script):
            os.remove(temp_r_script)

    # --------------------------------------------------------------------------
    # STEP 2: GENERATE ALL PLOTS & SAVE MULTI-PAGE PDF
    # --------------------------------------------------------------------------
    print("\n--- Step 2: Generating Visualizations and PDF Report ---")

    aligned_csv = os.path.join(DIR_PATH, "christchurch_aligned_oct2025_aug2026_combined.csv")
    if not os.path.exists(aligned_csv):
        print(f"[ERROR] Processed CSV not found at: {aligned_csv}")
        return

    df = pd.read_csv(aligned_csv)

    if df.empty:
        print("[WARNING] Processed dataset is empty. Cannot generate plots.")
        return

    # Clean extreme price outliers for visual clarity
    df_clean = df[(df["price"] > 0) & (df["price"] <= 1000)].copy()

    # Define PDF Output Path
    pdf_path = os.path.join(DIR_PATH, "Christchurch_Airbnb_Visualizations_Report.pdf")

    # Use PdfPages to store all 5 plots in a single multi-page file
    with PdfPages(pdf_path) as pdf:

        # ----------------------------------------------------------------------
        # PLOT 1: price_distribution_july_aug.png (and Page 1 of PDF)
        # ----------------------------------------------------------------------
        df_clean["month_lower"] = df_clean["month_year"].astype(str).str.lower()
        df_july_aug = df_clean[df_clean["month_lower"].str.contains("july|august")].copy()

        if df_july_aug.empty:
            df_july_aug = df_clean.copy()
            df_july_aug["Month"] = df_july_aug["month_year"]
        else:
            df_july_aug["Month"] = df_july_aug["month_lower"].apply(
                lambda x: "July 2026" if "july" in x else ("August 2026" if "august" in x else "Other")
            )

        fig1, ax1 = plt.subplots(figsize=(10, 6))
        sns.kdeplot(
            data=df_july_aug,
            x="price",
            hue="Month",
            common_norm=False,
            fill=True,
            alpha=0.3,
            linewidth=2,
            ax=ax1
        )
        ax1.set_title("Christchurch Airbnb Nightly Price Distribution (July vs. August 2026)", fontsize=14, fontweight="bold")
        ax1.set_xlabel("Nightly Price ($ NZD)", fontsize=12)
        ax1.set_ylabel("Density", fontsize=12)
        ax1.set_xlim(0, 600)
        plt.tight_layout()

        # Save standalone PNG and attach page to PDF
        png_path_1 = os.path.join(DIR_PATH, "price_distribution_july_aug.png")
        fig1.savefig(png_path_1, dpi=300)
        pdf.savefig(fig1)
        plt.show()
        plt.close(fig1)

        # ----------------------------------------------------------------------
        # PLOT 2: room_type_counts.png (and Page 2 of PDF)
        # ----------------------------------------------------------------------
        fig2, ax2 = plt.subplots(figsize=(9, 5))
        if "room_type" in df_clean.columns:
            counts = df_clean["room_type"].value_counts().reset_index()
            counts.columns = ["room_type", "count"]

            barplot = sns.barplot(data=counts, x="room_type", y="count", palette="Blues_r", ax=ax2)
            ax2.set_title("Christchurch Airbnb Listings Count by Room Type", fontsize=14, fontweight="bold")
            ax2.set_xlabel("Room Type", fontsize=12)
            ax2.set_ylabel("Total Listings", fontsize=12)

            for p in barplot.patches:
                height = p.get_height()
                if not pd.isna(height) and height > 0:
                    ax2.annotate(
                        f"{int(height):,}",
                        (p.get_x() + p.get_width() / 2., height),
                        ha="center", va="bottom",
                        fontsize=10, fontweight="bold",
                        xytext=(0, 3), textcoords="offset points"
                    )
        else:
            ax2.text(0.5, 0.5, "room_type column missing", ha="center", va="center")

        plt.tight_layout()

        # Save standalone PNG and attach page to PDF
        png_path_2 = os.path.join(DIR_PATH, "room_type_counts.png")
        fig2.savefig(png_path_2, dpi=300)
        pdf.savefig(fig2)
        plt.show()
        plt.close(fig2)

        # ----------------------------------------------------------------------
        # PLOT 3: Nightly Price Distribution Across Room Types (Page 3 of PDF)
        # ----------------------------------------------------------------------
        fig3, ax3 = plt.subplots(figsize=(10, 6))
        if "room_type" in df_clean.columns:
            sns.boxplot(data=df_clean, x="room_type", y="price", palette="Set2", ax=ax3)
            ax3.set_title("Christchurch Airbnb Nightly Price Distribution (Oct 2025 - Aug 2026)", fontsize=14, fontweight="bold")
            ax3.set_xlabel("Room Type", fontsize=12)
            ax3.set_ylabel("Nightly Price ($ NZD)", fontsize=12)
        else:
            sns.histplot(df_clean["price"], kde=True, color="skyblue", bins=30, ax=ax3)
            ax3.set_title("Christchurch Airbnb Nightly Price Distribution (Oct 2025 - Aug 2026)", fontsize=14, fontweight="bold")
            ax3.set_xlabel("Nightly Price ($ NZD)", fontsize=12)
            ax3.set_ylabel("Count", fontsize=12)
        
        plt.tight_layout()
        pdf.savefig(fig3)
        plt.show()
        plt.close(fig3)

        # ----------------------------------------------------------------------
        # PLOT 4: Top 10 Suburbs by Number of Listings (Page 4 of PDF)
        # ----------------------------------------------------------------------
        suburb_col = next((col for col in ["neighbourhood_cleansed", "neighbourhood"] if col in df_clean.columns), None)
        if suburb_col:
            top_suburbs = df_clean[suburb_col].value_counts().head(10)
            
            fig4, ax4 = plt.subplots(figsize=(12, 6))
            sns.barplot(x=top_suburbs.values, y=top_suburbs.index, palette="viridis", ax=ax4)
            ax4.set_title("Top 10 Christchurch Suburbs by Listing Count (Oct 2025 - Aug 2026)", fontsize=14, fontweight="bold")
            ax4.set_xlabel("Number of Listings", fontsize=12)
            ax4.set_ylabel("Suburb / Neighbourhood", fontsize=12)
            plt.tight_layout()
            pdf.savefig(fig4)
            plt.show()
            plt.close(fig4)

        # ----------------------------------------------------------------------
        # PLOT 5: Median Price Across Mapped TimeFrames (Page 5 of PDF)
        # ----------------------------------------------------------------------
        if "TimeFrame" in df_clean.columns:
            timeframe_df = df_clean.groupby("TimeFrame")["price"].median().reset_index()
            timeframe_df["TimeFrame"] = pd.to_datetime(timeframe_df["TimeFrame"], format="%d-%m-%Y")
            timeframe_df = timeframe_df.sort_values("TimeFrame")
            timeframe_df["TimeFrame_Str"] = timeframe_df["TimeFrame"].dt.strftime("%b %Y")

            fig5, ax5 = plt.subplots(figsize=(9, 5))
            sns.lineplot(data=timeframe_df, x="TimeFrame_Str", y="price", marker="o", color="crimson", linewidth=2.5, markersize=8, ax=ax5)
            ax5.set_title("Christchurch Airbnb Median Nightly Price Trend (Oct 2025 - Aug 2026)", fontsize=14, fontweight="bold")
            ax5.set_xlabel("Quarter Start Date", fontsize=12)
            ax5.set_ylabel("Median Price ($ NZD)", fontsize=12)
            ax5.grid(True, linestyle="--", alpha=0.6)
            plt.tight_layout()
            pdf.savefig(fig5)
            plt.show()
            plt.close(fig5)

    print("\n================ OUTPUT SUMMARY ================")
    print(f"Target Directory: '{DIR_PATH}'")
    print(f"  [x] PDF Report Saved: {os.path.basename(pdf_path)}")
    print(f"  [x] price_distribution_july_aug.png Saved: {os.path.exists(png_path_1)}")
    print(f"  [x] room_type_counts.png Saved:           {os.path.exists(png_path_2)}")
    print("================================================")


if __name__ == "__main__":
    run_airbnb_pipeline()