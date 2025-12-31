#' theme_base 
#'
#' @description A utils function
#'
#' @return The return value, if any, from executing the utility.
#'
#' @noRd
theme_base <- function() {
  theme(
    panel.grid.major = element_line(color = "gray90"),
    panel.grid.minor = element_blank(),
    panel.border = element_blank(),
    axis.line = element_line(color = "black"),
    axis.ticks = element_line(color = "black"),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    panel.grid = element_blank(),
    axis.title = element_text(family = "Lato",size = 16, color="black"), # Títulos ejes
    axis.text = element_text(family = "Lato",size = 13, color="black"), # Texto de ticks
    legend.title = element_text(family = "Lato",size = 15, color="black"), # Título leyenda
    legend.text = element_text(family = "Lato",size = 14, color="black", ) # Texto leyenda
  )
}