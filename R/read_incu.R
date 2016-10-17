#' read incucyte metrics
#'
#' \code{read_incu()} reads incucyte metrics. Please provide an annotation table for downstream analyses.
#'
#' @param file Metrics file exported with IncuCyte ZOOM® software.
#' @param annotation Annotation file with at least four columns: Analysis_Job (e.g. "Experiment_I"), Well (e.g. "A1"), Treatment (e.g. "ctrl") and Reference (can be multiple e.g. "A1,B1"), and one row per well.
#' @param delay Time between treatment and first image acquisition in minutes (default 0).
#' @param per_image IncuCyte ZOOM® can export values per image or export mean values per well. Hence, set per_image = T or F depending on your export settings.
#' @return A tibble of incucyte metrics.
#' @import tidyverse
#' @import stringr
#' @examples
#' read_incu(file = system.file("extdata", "sample_data_GO_Confluence_percent.txt", package = "incucyter"),
#' annotation = system.file("extdata", "sample_data_annotation.tsv", package = "incucyter"))
#' @export
read_incu <- function(file, annotation = NULL, delay = 0, per_image = T) {

  result <- file %>%
    lapply(read_incu_single, delay = delay, per_image = per_image) %>%
    set_names(file %>% basename) %>%
    bind_rows(.id = "File")

  if (!is.null(annotation)) {

    if (is.character(annotation)) {

      result <- result %>%
        left_join(read_tsv(annotation), by = c("Well", "Analysis_Job"))

    } else if (is.data.frame(annotation)) {

      result <- result %>%
        left_join(annotation, by = c("Well", "Analysis_Job"))

    } else {

      stop("Please provide annotation file as string or data frame")

    }

  } else {

    warning("Please provide an annotation file to make use of all plotting features")

  }

  return(result)

}
