#' normalise incucyte metrics
#'
#' \code{norm_incu()} normalises an incucyte metric to a given vector of reference wells and to a given timepoint. This step requires a \code{Reference} column in your incucyte annotation table indicating comma separated reference wells.
#'
#' @param incu_tbl A tibble generated with \code{\link{read_incu}}
#' @param ref_time Reference timepoint.
#' @return A normalised tibble of incucyte metrics.
#' @import tidyverse
#' @import stringr
#' @examples
#' incu_tbl <- read_incu(file = system.file("extdata", "sample_data_GO_Confluence_percent.txt", package = "incucyter"),
#' annotation = system.file("extdata", "sample_data_annotation.tsv", package = "incucyter"))
#' norm_incu(incu_tbl, 72)
#' @export
norm_incu <- function(incu_tbl, ref_time = 72) {

  ref_tbl <- incu_tbl %>%
    distinct(Analysis_Job, Metric, Reference, .keep_all = F) %>%
    apply(1, function(x) incu_tbl %>%
            filter(Analysis_Job == x[1],
                   Metric == x[2],
                   Well %in% unlist(str_split(x[3], ",")),
                   Elapsed == ref_time) %>%
            group_by(Analysis_Job, Metric, Reference) %>%
            summarise(Ref_Value = mean(Value))) %>%
    bind_rows()

  incu_tbl %>%
    left_join(ref_tbl, by = c("Analysis_Job", "Metric", "Reference")) %>%
    mutate(Value = Value/Ref_Value,
           Description = paste0(Description, ", norm. to ", ref_time, "h"))

}
