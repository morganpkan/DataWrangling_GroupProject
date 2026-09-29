# ==============================================================================
# Script Name: main.R
# Description: Main execution script for the Data Wrangling Group Project
# Date: 2026
# ==============================================================================

# Clear workspace
rm(list = ls())

# Set global options
options(stringsAsFactors = FALSE, scipen = 999)

# Load required packages
library(tidyverse)
library(httr)
library(jsonlite)
library(DBI)
library(RSQLite)