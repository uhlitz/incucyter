#' read incucyte metrics
#'
#' \code{read_incu} reads incucyte metrics. Please provide an annotation table for downstream analyses.
#'
#' @param file Metrics file exported with IncuCyte ZOOM® software.
#' @param annotation Annotation file with at least three columns: Well (e.g. "A1"), Treatment (e.g. "ctrl") and Reference (can be multiple e.g. "A1,B1"), and one row per well.
#' @param delay Time between treatment and first image acquisition in minutes (default 0).
#' @param per_image Were metrics exported per image or grouped by well (TRUE or FALSE, default TRUE)?
#' @return A tibble of incucyte metrics.
#' @import tidyverse
#' @import stringr
#' @examples
#' read_incu(file = system.file("extdata", "sample_data_GO_Confluence_percent.txt", package = "incucyter"), annotation = system.file("extdata", "sample_data_annotation.tsv", package = "incucyter"))
#' @export
read_incu <- function(file, annotation = NULL, delay = 0, per_image = T) {

  result <- file %>%
    lapply(read_incu_single, delay = delay, per_image = per_image) %>%
    set_names(file %>% basename) %>%
    bind_rows(.id = "File")

  if(!is.null(annotation)) {

    result <- result %>%
      left_join(read_tsv(annotation), by = "Well")

  } else {

    warning("Please provide an annotation file to make use of all plotting features")

  }

  return(result)

}

