## -----------------------------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
options(tibble.print_min = 6L, tibble.print_max = 6L, digits = 3)

## ----setup, message = FALSE---------------------------------------------------
library(dplyr)
library(dbplyr)
library(DBI)

## -----------------------------------------------------------------------------
con <- DBI::dbConnect(RSQLite::SQLite(), path = ":memory:")
DBI::dbWriteTable(con, "mtcars", mtcars)

tbl(con, "mtcars")

## -----------------------------------------------------------------------------
#' @importFrom dbplyr dbplyr_edition
#' @export
dbplyr_edition.myConnectionClass <- function(con) 2L

## ----eval = FALSE-------------------------------------------------------------
# #' @export
# sql_dialect.myConnectionClass <- function(con) {
#   new_sql_dialect(
#     "mybackend",
#     quote_identifier = function(x) sql_quote(x, '"')
#   )
# }

## -----------------------------------------------------------------------------
con <- simulate_dbi()

# Create an index
index_name <- "index"
table <- I("schema.table")
columns <- c("column1", "column2")
sql_glue2(con, "CREATE INDEX {.id index_name} ON {.tbl table} {.id columns*}")

# Insert values safely
name <- "O'Brien"
sql_glue2(con, "INSERT INTO students (name) VALUES {name*}")

# Build a query
table <- "my_table"
cols <- c("id", "name", "value")
sql_glue2(con, "SELECT {.id cols} FROM {.tbl table}")

## ----eval = FALSE-------------------------------------------------------------
# # Method on dialect class (recommended)
# sql_translation.sql_dialect_mybackend <- function(con) {
#   sql_variant(
#     scalar = sql_translator(base_scalar, ...), # Functions in SELECT (non-aggregated)
#     aggregate = sql_translator(base_aggregate, ...), # Aggregation functions (mean, sum, etc.)
#     window = sql_translator(base_win, ...) # Window functions (lead, lag, rank, etc.)
#   )
# }

## ----eval = FALSE-------------------------------------------------------------
# sql_translator(
#   base_scalar, # Inherit most translations
#   # Override specific functions for your backend
#   `+` = sql_infix("+"),
#   mean = sql_aggregate("AVG", "mean")
# )

## -----------------------------------------------------------------------------
# sql_translation.sql_dialect_mybackend <- function(con) {
#   sql_variant(
#     scalar = sql_translator(
#       base_scalar,
#       # Standard SQL functions
#       cos = sql_prefix("COS", 1),
#       round = sql_prefix("ROUND", 2),
#       # Infix operators
#       `+` = sql_infix("+"),
#       `*` = sql_infix("*"),
#       `==` = sql_infix("="),
#       # Type casting
#       as.numeric = sql_cast("NUMERIC"),
#       as.character = sql_cast("VARCHAR")
#     ),
#     aggregate = sql_translator(base_agg),
#     window = sql_translator(base_win)
#   )
# }

## -----------------------------------------------------------------------------
# sql_translation.sql_dialect_mybackend <- function(con) {
#   sql_variant(
#     scalar = sql_translator(base_scalar),
#     aggregate = sql_translator(
#       .parent = base_agg,
#       # Single-argument aggregates
#       mean = sql_aggregate("AVG", "mean"),
#       var = sql_aggregate("VAR_SAMP", "var"),
#       # Two-argument aggregates
#       cov = sql_aggregate_2("COVAR_SAMP"),
#       # Variadic aggregates
#       pmin = sql_aggregate_n("LEAST", "pmin"),
#       pmax = sql_aggregate_n("GREATEST", "pmax"),
#       # Unsupported functions
#       median = sql_not_supported("median")
#     ),
#     window = sql_translator(base_win)
#   )
# }

## ----eval = FALSE-------------------------------------------------------------
# window = sql_translator(
#   base_win,
#   # Ranking functions
#   row_number = win_rank("ROW_NUMBER"),
#   rank = win_rank("RANK"),
#   dense_rank = win_rank("DENSE_RANK"),
#   # Aggregate functions as window functions
#   mean = win_aggregate("AVG"),
#   sum = win_aggregate("SUM"),
#   # Cumulative functions
#   cumsum = win_cumulative("SUM"),
#   # Absent functions
#   cume_dist = win_absent("cume_dist")
# )

## ----eval = FALSE-------------------------------------------------------------
# scalar = sql_translator(
#   base_scalar,
# 
#   # Custom log function with change of base
#   log = function(x, base = exp(1)) {
#     if (isTRUE(all.equal(base, exp(1)))) {
#       sql_glue("LN({x})")
#     } else {
#       sql_glue("LOG({x}) / LOG({base})")
#     }
#   },
# 
#   # Custom paste function using CONCAT
#   paste = function(..., sep = " ") {
#     sql_glue("CONCAT_WS({sep}, {...})")
#   }
# )

