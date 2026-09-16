## -----------------------------------------------------------------------------
knitr::opts_chunk$set(collapse = TRUE, comment = "#>")
options(tibble.print_min = 6L, tibble.print_max = 6L, digits = 3)

## -----------------------------------------------------------------------------
library(dbplyr)
library(dplyr, warn.conflicts = FALSE)

## -----------------------------------------------------------------------------
lf <- lazy_frame(x = 1, y = 2, g = "a")
lf |> mutate(z = (x + y) / 2)

## -----------------------------------------------------------------------------
lf_sqlite <- lazy_frame(x = 1, con = simulate_sqlite())
lf_access <- lazy_frame(x = 1, con = simulate_access())

lf_sqlite |> transmute(z = x^2)
lf_access |> transmute(z = x^2)

## -----------------------------------------------------------------------------
lf |> filter(x == "x")

## -----------------------------------------------------------------------------
lf |> transmute(z = 1)
lf |> transmute(z = 1L)

## -----------------------------------------------------------------------------
lf |> transmute(x = x / 2, y = x^2 + y^2)

lf |> transmute(x = log(x), y = round(y, 1))

## -----------------------------------------------------------------------------
df <- tibble(
  x = c(10L, 10L, -10L, -10L),
  y = c(3L, -3L, 3L, -3L)
)
db <- copy_to(memdb(), df)

df |> mutate(x %% y)
db |> mutate(x %% y)

## -----------------------------------------------------------------------------
lf |> filter(x > 5 | y == 2)

lf |> filter(x %in% c(1, 2, 3))

lf |> filter(between(x, 1, 5))

## -----------------------------------------------------------------------------
lf |> transmute(x = bitwAnd(x, 3L), y = bitwShiftL(x, 2L))

## -----------------------------------------------------------------------------
lf |> transmute(x = as.integer(y), y = as.character(x))

## -----------------------------------------------------------------------------
lf |> transmute(x = as(x, "TIME"), y = as(y, "DECIMAL(10, 2)"))

## -----------------------------------------------------------------------------
lf |> filter(!is.na(x))

lf |> transmute(x = coalesce(x, 0L))

lf |> transmute(x = na_if(x, 0L))

## -----------------------------------------------------------------------------
lf |> summarise(z = mean(x))
lf |> summarise(z = mean(x, na.rm = TRUE))

## -----------------------------------------------------------------------------
lf |> mutate(z = mean(x, na.rm = TRUE))
lf |> filter(mean(x, na.rm = TRUE) > 0)

## -----------------------------------------------------------------------------
lf |> transmute(z = ifelse(x > 5, "big", "small"))

## -----------------------------------------------------------------------------
lf |> 
  mutate(z = case_when(
    x > 10 ~ "medium",
    x > 30 ~ "big", 
    .default = "small"
  ))

lf |> mutate(z = switch(g, a = 1L, b = 2L, 3L))

## -----------------------------------------------------------------------------
lf |> transmute(x = paste0(g, " dog"))

lf |> transmute(x = substr(g, 1L, 2L))

## -----------------------------------------------------------------------------
lf_dt <- lazy_frame(dt = Sys.time())

lf_dt |> transmute(
  year = year(dt),
  month = month(dt),
  day = day(dt)
)

## -----------------------------------------------------------------------------
lf |> mutate(z = foofify(x, y))

## -----------------------------------------------------------------------------
lf |> transmute(z = .sql$foofify(x, y))

## -----------------------------------------------------------------------------
lf |> filter(x %LIKE% "%foo%")

## -----------------------------------------------------------------------------
lf |> filter(str_like(x, "%foo%"))

## -----------------------------------------------------------------------------
lf |> transmute(z = x %||% y)
lf |> transmute(z = paste0(x, y))
lf |> transmute(z = paste(x, y))

## -----------------------------------------------------------------------------
lf |> transmute(z = sql("x!"))
lf |> transmute(z = x == sql("ANY VALUES(1, 2, 3)"))

## -----------------------------------------------------------------------------
lf |> transmute(factorial = sql("x!"))
lf |> transmute(factorial = sql("CAST(x AS FLOAT)"))

## -----------------------------------------------------------------------------
try({
options(dplyr.strict_sql = TRUE)
lf |> mutate(z = glob(x, y))
})

## -----------------------------------------------------------------------------
knitr::include_graphics("windows.png", dpi = 300)

## -----------------------------------------------------------------------------
lf <- lazy_frame(g = 1, year = 2020, id = 3, con = simulate_dbi())

lf |> transmute(
  mean = mean(g), 
  rank = min_rank(g), 
  cumsum = cumsum(g),
  lag = lag(g)
)

## -----------------------------------------------------------------------------
lf |> arrange(year) |> mutate(z = cummean(g))
lf |> group_by(id) |> mutate(z = rank())

## -----------------------------------------------------------------------------
lf |> transmute(
  x1 = min_rank(g),
  x2 = order_by(year, cumsum(g)),
  x3 = lead(g, order_by = year)
)

