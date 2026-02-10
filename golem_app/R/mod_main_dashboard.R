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
    
    # Summary cards: pass rate, total, average, difference
    layout_columns(
      fill = FALSE,
      card(
        card_header("Tasa de Aprobado Global"),
        card_body(
          textOutput(outputId = ns("pass_percentage_1"))
        )
      ),
      card(
        card_header("Total de Presentados"),
        card_body(
          textOutput(outputId = ns("candidates_1"))
        )
      ),
      card(
        card_header("Nota Media"),
        card_body(
          textOutput(outputId = ns("final_average_pass_1"))
        )
      ),
      card(
        card_header("Diferencia Notas (PAU vs. Bachillerato)"),
        card_body(
          textOutput(outputId = ns("diff_bach_pau_1"))
        )
      )
    ),    
    # Main plots section
    layout_columns(
      card(
        full_screen = TRUE,
        card_header("Tendencias"),
        card_body(
          plotOutput(outputId = ns("candidates_over_years")),
          hr(),
          plotOutput(outputId = ns("boxplot_diff_avg"))
        )
      ),
      layout_column_wrap(
        # Tabs: academic performance comparison
        navset_card_tab(
          title = "Rendimiento académico",
          full_screen = TRUE,
          nav_panel(
            "Diferencia PAU vs. Bach",
            plotOutput(outputId = ns("diff_average_bach_pau")) 
          ),
          nav_panel(
            "Variación diferencia",
            plotOutput(outputId = ns("diff_tendence_smooth"))
          )
        ),
        # Student profile by phase and origin
        card(
          full_screen = TRUE,
          card_header("Fases y origen"),
          card_body(
            plotOutput(outputId = ns("student_profile"))
          )
        ),
        width = 1,
        heights_equal = "row"
      ), 
      # Demographics: gender distribution
      card(
        full_screen = TRUE,
        card_header("Demografía y género"),
        card_body(
          plotOutput(outputId = ns("stacked_area_chart")),
          hr(),
          plotOutput(outputId = ns("line_chart_pass_percentage"))
        )
      )
    )
    
  )     
}

# Calculate summary statistics for top cards
extract_global_averages <- function(output, df) {

  summary_df <- df |>
    summarise(
      total_candidates = sum(candidates, na.rm = TRUE),
      pass_percentage = sum(pass_percentage * candidates, na.rm = TRUE),
      real_pass_percentage = pass_percentage / total_candidates,
      diff_bach_pau = sum((average_bach - average_pau) * candidates, na.rm = TRUE),
      real_diff_bach_pau = diff_bach_pau / total_candidates,
      total_average_pondered = sum(final_average_pass * candidates, na.rm = TRUE),
      final_average_pass = total_average_pondered / total_candidates
    )

  output$pass_percentage_1 <- renderText({
    paste0(format(floor(summary_df$real_pass_percentage * 100) / 100, decimal.mark = ","), "%")
  })

  output$candidates_1 <- renderText({format(summary_df$total_candidates, big.mark = ".", decimal.mark = ",")})

  output$final_average_pass_1 <- renderText({
    format(floor(summary_df$final_average_pass * 100) / 100, nsmall = 2, decimal.mark = ",")
  })

  output$diff_bach_pau_1 <- renderText({
    format(floor(summary_df$real_diff_bach_pau * 100) / 100, nsmall = 2, decimal.mark = ",")
  })
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
      title = "Evolución Académica: Aprobados y Suspendidos",
      subtitle = "Comparativa anual",
      x = "Año",
      y = "Número de estudiantes"
    ) + 
    theme_base() + 
    theme(
      legend.title = element_blank()
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
    geom_jitter(width = 0.15, alpha = 0.6, color = colors[["secondary"]]) +
    geom_boxplot(width = 0.35, size = 1,  fill = NA, outlier.shape = NA) +
    scale_color_manual(values = c("Hombres" = colors[["info"]], "Mujeres" = colors[["warning"]])) +
    scale_y_continuous(
      labels = scales::label_number(suffix = "%")
    ) +
    coord_cartesian(ylim = c(93, 99),) +
    
    labs(
      title = "Distribución de Aprobados: Hombres vs Mujeres",
      subtitle = "Cada punto representa un año académico",
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
      y = "Diferencia PAU - Bachillerato"
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
        names == "fp_candidates_especific" ~ "Vienen de FP",
        TRUE ~ "Solo específica"
      )
    )
  
  plot_data <- bind_rows(df_general, df_specific) |> 
    mutate(
      tipo_alumno = factor(
        tipo_alumno,
        levels = c("Ambas fases", "Solo general", "Solo específica", "Vienen de FP")
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
        "Vienen de FP" = colors[["success"]]
      )
    ) +
    scale_y_continuous(
      labels = scales::label_number(big.mark = ".", decimal.mark = ",")
    ) +
    labs(
      title = "Perfil del Candidato",
      subtitle = "Todos aquellos que no realizan las dos fases",
      x = "Año",
      y = "Número de alumnos",
      color = "Origen del alumno"
    ) +
    theme_base()

  output$student_profile <- renderPlot(plot)
}

#Stacked area chart to visualize the gap between male and female candidates
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
      title = "Evolución de candidatos por género",
      x = "Año",
      y = "Número de estudiantes",
      fill = "Género"
    ) +
    theme_base()

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
    theme <- bslib::bs_current_theme()
    colors <- bslib::bs_get_variables(
      theme,
      varnames = c("primary", "secondary", "success", "danger",  "warning", "info", "dark", "default")
    )


    # Global averages funtion
    extract_global_averages(output, df)

    # Evolution over the years in terms of enrolled, candidates and pass
    candidates_over_years_plot(output, df, colors)

    # Difference between values of different averages
    boxplot_diff_averages(output, df, colors)

    # Evolution over the years in terms of pass percentage
    line_chart_pass_percentage_plot(output, df, colors)
  
    # Academic performance based on the visual diference between average_bach and average_pau
    diff_average_dumbell_chart(output, df, colors)

    diff_tendence(output, df, colors)

    # Candidates profile
    student_profile_chart(output, df, colors)

    stacked_area_chart_candidates(output, df, colors)
  })
}
