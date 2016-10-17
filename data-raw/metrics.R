library(tidyverse)
metrics <- read_tsv("data-raw/metrics.tsv", col_types = "ccccc")
devtools::use_data(metrics, internal = T, overwrite = T)
