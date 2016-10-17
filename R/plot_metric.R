#' plot metrics, summarise by condition
#'
#' \code{plot_microplate()} plots microplate for a given metric.
#'
#' @param incu_tbl A tibble generated with \code{\link{read_incu}}
#' @param analysis_job Which runs should be plotted (e.g. "Experiment_I")?
#' @param metric Which metrics (e.g. "Phase_Confluence")?
#' @param color Which columns from your annotation table should be used for coloring?
#' @param label Which columns from your annotation table should be used as a text label?
#' @param summarise plot mean values instead of single images
#' @return A tibble of incucyte metrics.
#' @import tidyverse
#' @import stringr
#' @examples
#' incu_tbl <- read_incu(file = system.file("extdata", "sample_data_GO_Confluence_percent.txt",
#' package = "incucyter"),
#' annotation = system.file("extdata", "sample_data_annotation.tsv",
#' package = "incucyter"))
#' plot_metrics(incu_tbl, color = c("Treatment"), label = c("Treatment"), summarise = T)
#' @export
plot_metrics <- function(incu_tbl,
                         analysis_job = unique(incu_tbl$Analysis_Job),
                         metric = unique(incu_tbl$Metric),
                         color = "Treatment",
                         linetype = NULL,
                         label = NULL,
                         alpha = 0.5,
                         summarise = T) {

  color_key_name <- paste(color, collapse = "+")
  data_tbl <- incu_tbl %>%
    filter(Analysis_Job %in% analysis_job,
           Metric %in% metric) %>%
    unite_("Color_Key", color, sep = "+", remove = F)

  if (!is.null(linetype)) {

    lt_key_name <- paste(linetype, collapse = "+")
    data_tbl <- data_tbl %>%
      unite_("Lt_Key", linetype, sep = "+", remove = F)

  } else {

    data_tbl$Lt_Key <- 1

  }

  metric_description <- unique(data_tbl$Description) %>%
    str_replace_all("\\(", "[") %>%
    str_replace_all("\\)", "]") %>%
    str_replace_all("Percent", "%")

  if (!is.null(label)) {

    data_tbl <- data_tbl %>%
      replace_na(rep("", length(label)) %>% set_names(label) %>% as.list) %>%
      unite_("Text_Label", label, sep = "\n", remove = F)

  } else {

    data_tbl$Text_Label <- ""

  }

  ## base plot
  p <- ggplot(data_tbl, aes(Elapsed, Value, group = interaction(img, Well))) +
    facet_grid(Metric ~ Analysis_Job, scales = "free_y") +
    scale_color_discrete(color_key_name) +
    scale_x_continuous("Time [h]", breaks = seq(0, max(data_tbl$Elapsed), 24)) +
    scale_y_continuous() +
    theme_incu() +
    ggtitle("")

  if (summarise) {

    data_tbl <- data_tbl %>%
      mutate(Upper = Value,
             Lower = Value) %>%
      group_by(Analysis_Job, Elapsed, Metric, Color_Key, Lt_Key, Text_Label) %>%
      summarise(Value = mean(Value),
                Upper = mean(Upper) + sd(Upper),
                Lower = mean(Lower) - sd(Lower)) %>%
      mutate(img = NA,
             Well = NA) %>%
      ungroup

    ## summarised plot
    p <- {p %+% data_tbl} +
      scale_fill_discrete(color_key_name)

  }

  if (summarise & is.null(linetype)) {

    p <- p +
      geom_ribbon(aes(ymax = Upper, ymin = Lower,
                      group = Color_Key, fill = Color_Key),
                  alpha = alpha) +
      geom_line(aes(color = Color_Key,
                    group = Color_Key))

  } else if (!summarise & is.null(linetype)) {

    p <- p +
      geom_line(aes(color = Color_Key,
                    group = interaction(Well, img)))

  } else if (summarise & !is.null(linetype)) {

    p <- p +
      geom_line(aes(color = Color_Key,
                    group = interaction(Color_Key, Lt_Key),
                    linetype = Lt_Key)) +
      geom_ribbon(aes(ymax = Upper, ymin = Lower,
                      group = interaction(Color_Key, Lt_Key),
                      fill = Color_Key),
                  alpha = alpha)

  } else if (!summarise & !is.null(linetype)) {

    p <- p +
      geom_line(aes(color = Color_Key,
                    group = interaction(Well, img),
                    linetype = Lt_Key))

  }

  if (!is.null(label)) {

    # add labels to plot
    p <- p +
      geom_text(aes(label = Text_Label, group = interaction(img, Well),
                    x = mr_Elapsed, y = mr_Value),
                color = "black",
                data = data_tbl %>%
                  mutate(mr_Elapsed = mean(range(Elapsed)),
                         mr_Value = mean(range(Value))) %>%
                  distinct(Analysis_Job, Metric, .keep_all = T))

  }

  return(p)

}




# setwd("/Users/uhlitz/Projects/R/Current/HEK_RAF_2014")
#
# library(incucyter)
# library(tidyverse)
# library(readxl)
#
# ## merge annotation files:
# incu_annotation <- lapply(1:7, function(x) {
#   read_excel("microarray_analysis/lab/incucyte/incucyte_annotation.xlsx",
#              sheet = x)
# }) %>%
#   bind_rows
#
# incu_tbl <- list.files("microarray_analysis/dep/incucyte", full.names = T) %>%
#   read_incu(incu_annotation, delay = 2) %>%
#   ## filter Wells
#   ## run I: get rid of edge effect
#   ## (wells in the periphery evaporated over the course of the experiment)
#   filter(!(Analysis_Job == "2016_03_23_HEK293RAF1ER_Casp3_panel_I" &
#              (WellX %in% c(1, 12) | WellY %in% c("A", "H")))) %>%
#   ## run III: C5
#   filter(!(Analysis_Job == "2016_05_26_HEK293RAF1ER_Casp3_panel_III" &
#              Well == "C5")) %>%
#   ## run VI:
#   filter(!(Analysis_Job == "2016_09_06_HEK293RAF1ER_Casp3_panel_VI" &
#              Well == "C7"))
#
# ## simplify Analysis_Job factor:
# Simple_Job <- unique(incu_tbl$Analysis_Job) %>%
#   set_names(paste0("run", 1:length(.)), .)
#
# incu_tbl <- incu_tbl %>%
#   mutate(Analysis_Job = Simple_Job[Analysis_Job])
#
# incu_ratios <- calc_incu_ratios(incu_tbl)
# incu_tbl_norm <- norm_incu(incu_ratios, 72)
#
# incu_tbl_norm %>%
#   filter(Analysis_Job %in% c("run5", "run7")) %>%
#   #filter(siRNA %in% c("Mock", "NR4A1")) %>%
#   filter(Metric %in% c("Green_Confluence_Phase_Confluence")) %>%
#   filter(siRNA_id == "*") -> incu_tbl
#
# plot_metrics(incu_tbl, summarise = T,
#              color = c("siRNA"),
#              linetype = c("Treatment", "Inhibition"))
#
