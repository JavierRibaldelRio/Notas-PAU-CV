#' main_dashboard UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_main_dashboard_ui <- function(id) {
  ns <- NS(id)
  tagList(
   
    # Main plots section
    layout_columns(
      layout_column_wrap(
        navset_card_tab(
          title="Evolución y perfil",
          full_screen = TRUE,
          nav_panel(
            "Evo. académica",
            plotOutput(outputId = ns("candidates_over_years"))
          ),
          nav_panel(
            "Perfil del Presentado",
            plotOutput(outputId = ns("student_profile"))
          )
        ),

        layout_columns(
          navset_card_tab(
            title = "Rendimiento académico",
            full_screen = TRUE,
  
            nav_panel(
              "Distribución de las medias",
              plotOutput(outputId = ns("boxplot_diff_avg"))
            ),
            nav_panel(
             "Diferencia PAU vs. Bach.",
             plotOutput(outputId = ns("diff_average_bach_pau")) 
            ),
            nav_panel(
              "Variación diferencia",
              plotOutput(outputId = ns("diff_tendence_smooth"))
            )
          ),
          navset_card_tab(
            title = "Estadísticas por sexos",
            full_screen = TRUE,
            nav_panel(
              "Presentad@s",
              plotOutput(outputId = ns("stacked_area_chart"))
            ),
            nav_panel(
              "Aprobad@s",
              plotOutput(outputId = ns("line_chart_pass_percentage"))
            )
          )
        ),
        width = 1,
        heights_equal = "row"
      ),
      #card()
    )
  )     
}

# Grouped bar plot relation between enrolled, candidates and pass over the years
candidates_over_years_plot <- function(output, df, colors) {

  # Just the data we need, and pivot longer
  long_df <- df |> 
    select(
      year,
      candidates,
      pass
    ) |> 
    pivot_longer(
      cols = c(candidates, pass), 
      names_to = "metrica",
      values_to = "valor"
    ) |> 
    mutate(metrica = factor(metrica, levels = c("candidates", "pass")))
  
  
  plot <- long_df |> 
    filter(!is.na(metrica)) |> 
    ggplot(aes(x = factor(year), y = valor, fill = metrica)) +
    geom_col(position = "identity", width = 0.6) +  # "identity" collapses the bar of each value
    scale_y_continuous(
      labels = scales::label_number(big.mark = ".", decimal.mark = ",")
    ) +
    scale_fill_manual(
      values = c("candidates" = colors[["danger"]], "pass" = colors[["success"]]),
      labels = c("Suspendidos", "Aprobados")
    ) +
    coord_cartesian(ylim = c(15000, NA)) +
    labs(
      title = "Aprobados y Suspendidos",
      subtitle = "Comparativa anual",
      x = "Año",
      y = "Número de estudiantes"
    ) + 
    theme_base() + 
    theme(
      legend.title = element_blank(),
      # No collapse in compact view
      axis.text.x = element_text(angle = 45, hjust = 1)
    )
  
  output$candidates_over_years <- renderPlot(plot)
}

# Boxplot diferences between averages (PAU, Bach, NAU)
boxplot_diff_averages <- function(output, df, colors) {

  long_df <- df |> 
    select(
      average_nau,
      average_pau,
      average_bach
    ) |> 
    pivot_longer(
      cols = everything(),
      names_to = "type",
      values_to = "averages"
    ) |> 
    mutate(
      type = case_when(
        type == "average_pau" ~ "Media PAU",
        type == "average_bach" ~ "Media Bachillerato",
        type == "average_nau" ~ "Media NAU"
      )
    )
  
  plot <- long_df |> 
    ggplot(aes(x = type, y = averages, color = type)) +
    geom_boxplot(fill = NA, size = 1, width = 0.5) +
    scale_color_manual(
      values = c(
        "Media PAU" = colors[["primary"]],
        "Media Bachillerato" = colors[["danger"]],
        "Media NAU" = colors[["success"]]
      )
    ) +
    labs(
      title = "Distribución de las Medias",
      x = "",
      y = "Nota Media"
    ) +
    theme_base() +
    theme(legend.position = "none")

  output$boxplot_diff_avg <- renderPlot(plot)
}

# Percentage of candidates that passed over the years
line_chart_pass_percentage_plot <- function(output, df, colors) {

  long_df <- df |> 
    select(
      pass_percentage_m,
      pass_percentage_w
    ) |> 
    pivot_longer(
      cols = everything(),               
      names_to = "sexo",                 
      values_to = "porcentaje"           
    ) |> 
    mutate(
      # Set names to separate
      sexo = case_when(
        sexo == "pass_percentage_m" ~ "Hombres",
        sexo == "pass_percentage_w" ~ "Mujeres"
      )
    )
  
  plot <- long_df |> 
    ggplot(aes(x = sexo, y = porcentaje, color = sexo)) +
    geom_jitter(width = 0.15, alpha = 0.6) +
    geom_boxplot(width = 0.35, size = 1,  fill = NA, outlier.shape = NA) +
    scale_color_manual(values = c("Hombres" = colors[["info"]], "Mujeres" = colors[["warning"]])) +
    scale_y_continuous(
      labels = scales::label_number(suffix = "%")
    ) +
    coord_cartesian(ylim = c(93, 99),) +
    
    labs(
      title = "Distribución de Aprobados",
      x = "",
      y = "Porcentaje de aprobados"
    ) +
    theme_base() +
    theme(legend.position = "none")

  output$line_chart_pass_percentage <- renderPlot(plot)
}

# Dumbell plot to show the difference between the marks at Bachillerato and PAU
diff_average_dumbell_chart <- function(output, df, colors) {

  new_df <- df |> 
    select(
      year,
      average_bach,
      average_pau
    )
  
  plot <- new_df |> 
    ggplot() +
    geom_segment(
      aes(
        x = average_pau, 
        xend = average_bach,
        y = year,
        yend = year,
      ),
      color = "grey",
      size = 2
    ) +
    geom_point(aes(x = average_pau, y = year, color = "Media PAU"), size = 4) +
    geom_point(aes(x = average_bach, y = year, color = "Media Bachillerato"), size = 4) +
    coord_cartesian(xlim = c(5, 8)) +
    scale_y_continuous(
      breaks = unique(new_df$year),
    ) +
    scale_color_manual(
      name = "Tipo de nota",
      values = c(
        "Media PAU" = colors[["primary"]],
        "Media Bachillerato" = colors[["danger"]]
      )
    ) +
    labs(
      title = "Diferencia entre las medias de Bachillerato y PAU",
      x = "Nota Media",
      y = "Año",
      color = "Tipo de nota"
    ) +
    theme_base() +
    theme(
      legend.position = "right"
    )


  output$diff_average_bach_pau <- renderPlot(plot)
}

# Tendency of the variation of the means
diff_tendence <- function(output, df, colors) {
  
  new_df <- df |> 
    select(
      year,
      average_bach,
      average_pau
    ) |> 
    mutate(
      diff = average_bach - average_pau,
    ) |> 
    filter(
      !is.na(diff)
    )
  
  modelo_loess <- loess(diff ~ year, data = new_df, span = 0.75)
  new_df$smooth <- predict(modelo_loess)

  
  
  plot <- new_df |> 
    filter(!is.na(smooth)) |> 
    ggplot(aes(year, diff)) +
    geom_smooth(color = colors[["dark"]], se = FALSE) +
    geom_ribbon(aes(ymin = 0, ymax = smooth), alpha = 0.5, fill = colors[["default"]]) +
    coord_cartesian(ylim = c(0.5, 1.5)) +
    scale_x_continuous(
      breaks = unique(new_df$year)
    ) +
    labs(
      x = "Año",
      y = "Diferencia PAU - Bachillerato",
      title = "Variación de la diferencia entre las medias de Bachillerato y PAU"
    ) +
    theme_base()

  output$diff_tendence_smooth <- renderPlot(plot)
}

# Chart with the pourpouse
student_profile_chart <- function(output, df, colors) {

  df_general <- df |> 
    select(
      year,
      exclusive_candidates_general
    ) |> 
    pivot_longer(
      cols = c(exclusive_candidates_general),
      names_to = "names",
      values_to = "values"
    ) |> 
    mutate(
      fase = "Fase General",
      tipo_alumno = "Solo general"
    )
  
  df_specific <- df |> 
    select(
      year,
      exclusive_candidates_especific,
      fp_candidates_especific
    ) |> 
    pivot_longer(
      cols = c(exclusive_candidates_especific, fp_candidates_especific),
      names_to = "names",
      values_to = "values"
    ) |> 
    mutate(
      fase = "Fase Específica",
      tipo_alumno = case_when(
        names == "fp_candidates_especific" ~ "FP",
        TRUE ~ "Solo específica"
      )
    )
  
  plot_data <- bind_rows(df_general, df_specific) |> 
    mutate(
      tipo_alumno = factor(
        tipo_alumno,
        levels = c("Ambas fases", "Solo general", "Solo específica", "FP")
      )
    )
  
  plot <- plot_data |> 
    ggplot(aes(x = factor(year), y = values, color = tipo_alumno, group = tipo_alumno)) +
    geom_line(size = 1) +
    coord_cartesian(ylim = c(200, 2500)) +
    scale_color_manual(
      values = c(
        "Solo general" = colors[["primary"]],
        "Solo específica" = colors[["danger"]],
        "FP" = colors[["success"]]
      )
    ) +
    scale_y_continuous(
      labels = scales::label_number(big.mark = ".", decimal.mark = ",")
    ) +
    labs(
      title = "Perfil del Candidato",
      x = "Año",
      y = "Número de alumnos",
      color = "Origen del alumno"
    ) +
    theme_base() +
    theme(
      # No collapse in compact view
      axis.text.x = element_text(angle = 45, hjust = 1)
    )

  output$student_profile <- renderPlot(plot)
}

# Stacked area chart to visualize the gap between male and female candidates
stacked_area_chart_candidates <- function(output, df, colors) {
  
  plot <- df |> 
    select(year, candidates_m, candidates_w) |> 
    pivot_longer(
      cols = c(candidates_w, candidates_m),
      names_to = "genero",
      values_to = "cantidad"
    ) |> 
    ggplot(aes(x = year, y = cantidad, fill = genero)) +
    geom_col(position = "stack", width = 0.6) + 
    scale_x_continuous(
      breaks = unique(df$year)
    ) +
    scale_y_continuous(
      labels = scales::label_number(big.mark = ".", decimal.mark = ","),
      expand = c(0,0)
    ) +
    scale_fill_manual(
      values = c("candidates_w" = colors[["warning"]], "candidates_m" = colors[["info"]]),
      labels = c("Hombres", "Mujeres")
    ) +
    labs(
      title = "Evolución de presentados por sexo",
      x = "Año",
      y = "Número de estudiantes",
      fill = "Sexo"
    ) +
    theme_base() +
    theme(
      # No collapse in compact view
      axis.text.x = element_text(angle = 45, hjust = 1)
    )

  output$stacked_area_chart <- renderPlot(plot)
}

#' main_dashboard Server Functions
#'
#' @noRd 
mod_main_dashboard_server <- function(id, pool){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    sql_query <- "
      SELECT 
        *
      FROM global_results 
      WHERE call = 2
    "
    df <- dbGetQuery(
      pool,
      sql_query
    )

    # Get theme colors
    theme <- bs_current_theme()
    colors <- bs_get_variables(
      theme,
      varnames = c("primary", "secondary", "success", "danger",  "warning", "info", "dark", "default")
    )

    # Plot: Evolution over the years in terms of enrolled, candidates and pass
    candidates_over_years_plot(output, df, colors)

    # Plot: Difference between values of different averages
    boxplot_diff_averages(output, df, colors)

    # Plot: Evolution over the years in terms of pass percentage
    line_chart_pass_percentage_plot(output, df, colors)
  
    # Plot: Academic performance based on the visual diference between average_bach and average_pau
    diff_average_dumbell_chart(output, df, colors)

    # Plot: Smooth of the variation of difference between means
    diff_tendence(output, df, colors)

    # Plot: Candidates profile
    student_profile_chart(output, df, colors)

    # Plot: Male and female candidates over the years
    stacked_area_chart_candidates(output, df, colors)
  })
}
