#' plot microplate graphs
#'
#' \code{plot_microplate()} plots microplate for a given metric.
#'
#' @param incu_tbl A tibble generated with \code{\link{read_incu}}
#' @param analysis_job Which run should be plotted (e.g. "Experiment_I")?
#' @param metric Which metric (e.g. "Phase_Confluence")?
#' @param color Which columns from your annotation table should be used for coloring?
#' @param label Which columns from your annotation table should be used as a text label?
#' @param summarise plot mean values instead of single images
#' @return A tibble of incucyte metrics.
#' @import tidyverse
#' @import stringr
#' @examples
#' incu_tbl <- read_incu(file = system.file("extdata", "sample_data_GO_Confluence_percent.txt", package = "incucyter"),
#'                       annotation = system.file("extdata", "sample_data_annotation.tsv", package = "incucyter"))
#' plot_microplate(incu_tbl, metric = "Green_Confluence", color = c("Treatment"), label = c("Treatment"), summarise = T)
#' @export
plot_microplate <- function(incu_tbl,
                            analysis_job = incu_tbl$Analysis_Job[1],
                            metric = incu_tbl$Metric[1],
                            color = "Treatment",
                            label = NULL,
                            summarise = F) {

  color_key_name <- paste(color, collapse = "+")

  data_tbl <- incu_tbl %>%
    filter(Analysis_Job == analysis_job,
           Metric == metric) %>%
    unite_("Color_Key", color, sep = "+")

  metric_description <- unique(data_tbl$Description) %>%
    str_replace_all("\\(", "[") %>%
    str_replace_all("\\)", "]") %>%
    str_replace_all("Percent", "%")

  if (!is.null(label)) {

    data_tbl <- data_tbl %>%
      replace_na(rep("", length(label)) %>% set_names(label) %>% as.list) %>%
      unite_("Text_Label", label, sep = "\n")

  } else {

    data_tbl <- data_tbl %>%
      mutate(Text_Label = "")

  }

  ## base plot
  p <- ggplot(data_tbl, aes(Elapsed, Value, group = img)) +
    geom_line(aes(color = Color_Key)) +
    facet_grid(WellY ~ WellX, switch = "y") +
    scale_color_discrete(color_key_name) +
    scale_x_continuous("Time [h]", breaks = seq(0, max(data_tbl$Elapsed), 24)) +
    scale_y_continuous(metric_description) +
    theme_incu() +
    ggtitle(paste(metric_description, analysis_job, sep = ", "))

  if (summarise) {

    data_tbl <- data_tbl %>%
      mutate(Upper = Value,
             Lower = Value) %>%
      group_by(Analysis_Job, Elapsed, Well, WellX, WellY, Metric, Color_Key, Text_Label) %>%
      summarise(Value = mean(Value),
                Upper = mean(Upper) + sd(Upper),
                Lower = mean(Lower) - sd(Lower)) %>%
      mutate(img = NA) %>%
      ungroup

    ## summarised plot
    p <- {p %+% data_tbl} +
      geom_ribbon(aes(ymax = Upper, ymin = Lower,
                      fill = Color_Key),
                  alpha = 0.5) +
      scale_fill_discrete(color_key_name)

  }

  if (!is.null(label)) {

    # add labels to plot
    p <- p +
      geom_text(aes(label = Text_Label, group = interaction(WellY, WellX),
                    x = mr_Elapsed, y = mr_Value),
                color = "black",
                data = data_tbl %>%
                  mutate(mr_Elapsed = mean(range(Elapsed)),
                         mr_Value = mean(range(Value))) %>%
                  distinct(WellY, WellX, .keep_all = T))

  }

  return(p)

}

# incu_tbl <- read_incu(file = system.file("extdata", "sample_data_GO_Confluence_percent.txt", package = "incucyter"),
#                       annotation = system.file("extdata", "sample_data_annotation.tsv", package = "incucyter"))
#
# plot_microplate(incu_tbl, metric = "Green_Confluence", color = c("Treatment"), summarise = F, label = "siRNA")
