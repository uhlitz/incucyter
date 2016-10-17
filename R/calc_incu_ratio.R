#' calc incucyte metrics ratios
#'
#' Metrics ratios relate different measures from the same or different channels to one another.
#'
#' @param incu_tbl A tibble generated with \code{\link{read_incu}}
#' @return A tibble of incucyte metrics with ratios columns.
#' @import tidyverse
#' @import stringr
#' @examples
#' incu_tbl <- read_incu(file = system.file("extdata", c("sample_data_GO_Confluence_percent.txt",
#'                                                       "sample_data_PO_Confluence_percent.txt",
#'                                                       "sample_data_GO_Count_image.txt"),
#'                                          package = "incucyter"),
#' annotation = system.file("extdata", "sample_data_annotation.tsv",
#'                           package = "incucyter"))
#' ratios_tbl <- calc_incu_ratios(incu_tbl)
#' @export
calc_incu_ratios <- function(incu_tbl) {

  if ("Ref_Value" %in% colnames(incu_tbl)) {
    stop("Did you normalise your data? Please first calculate ratios before normalising.")
  }

  metric_names <- unique(incu_tbl$Metric)

  if (length(metric_names) < 2) {
    stop("You need at least two different metrics in your data to calculate metric ratios.")
  }

  incu_wide <- incu_tbl %>%
    select(Analysis_Job, Elapsed, Well, img, Metric, Value) %>%
    spread(Metric, Value)

  metric_ratio_names <- combn(metric_names, 2, simplify = F)

  metric_ratios <- lapply(metric_ratio_names,
                          function(x) incu_wide[,x[1]] / incu_wide[,x[2]]) %>%
    set_names(lapply(metric_ratio_names, paste, collapse = "_")) %>%
    lapply(unlist) %>%
    lapply(unname)

  incu_ratios <- incu_wide %>%
    bind_cols(metric_ratios) %>%
    gather(Metric, Value, -Analysis_Job, -Elapsed, -Well, -img) %>%
    mutate(is.ratio = ifelse(Metric %in% metric_names, F, T)) %>%
    ungroup

  result <- incu_tbl %>%
    select(-Metric, -Value, -File) %>%
    distinct(Analysis_Job, Elapsed, Well, img, .keep_all = T) %>%
    left_join(incu_ratios, by = c("Analysis_Job", "Elapsed", "Well", "img"))

  return(result)

}
