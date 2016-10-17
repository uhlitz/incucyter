theme_incu <- function(base_size = 12, base_family = "", ...) {
  theme_bw(base_size = base_size, base_family = base_family, ...) %+replace%
    theme(
      panel.border     = element_rect(fill = NA),
      axis.line        = element_line(colour = "black",size=0.75,lineend="round"),
      axis.ticks       = element_line(colour = "black",size=0.75,lineend="round"),
      panel.grid.major.y = element_line(colour = "#CCCCCC",size=0.5,lineend="round",linetype=3),

      panel.grid.major.x = element_line(colour = "#CCCCCC",size=0.5,lineend="round",linetype=3),
      panel.grid.minor = element_blank(),
      panel.background = element_blank(),
      strip.background = element_blank(),
      panel.margin     = unit(1, "lines"),
      strip.text       = element_text(colour="black",face="bold",vjust=0.5,hjust=0.5),
      plot.title       = element_text(face="bold",vjust=1),
      plot.margin      = unit(c(1.5,2.5,1.5,1.5),"mm"),
      legend.key       = element_blank(),
      legend.background= element_rect(colour = "white",fill=alpha("white",0.5)),
      ...
    )
}
