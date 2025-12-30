#' subjects_page UI Function
#'
#' @description A shiny Module.
#'
#' @param id Internal parameters for {shiny}.
#' @param last_year Last year of we have data.
#' @noRd
#'
mod_subjects_page_ui <- function(id, last_year) {
  ns <- NS(id)

  tagList(
    navset_card_tab(
      # Panel 1: plots
      nav_panel(
        "Gráficas",
        layout_sidebar(
          sidebar = subjects_sidebar_ui(ns, last_year = last_year),
          main_panel_content_ui(ns)
        )
      ),

      # Panel 2: browse data set
      nav_panel("Todos los datos", DTOutput(ns("table_all_data"))),

      # Panel 3: heatmap

      nav_panel(em("Heatmap"), heat_map_layout_ui(ns)),

      nav_panel(em("Ranking"),mod_ranking_ui(ns("ranking_1")))
    )
  )
}


# Content of the sidebar, main configurations
subjects_sidebar_ui <- function(ns, last_year) {
  # Form that selects
  tagList(
    # Stat selector
    radioButtons(
      inputId = ns("variable"),
      label = "Variable",
      choices = list(
        "Presentados" = "candidates",
        "Aprobados" = "pass",
        "Aprobados (%)" = "pass_percentatge",
        "Media" = "average",
        "Coeficiente de variación" = "coefficient_variation"
      )
    ),

    # Call selector
    selectInput(
      ns("select_call"),
      "Convocatoria",
      list("Ordinaria" = 0, "Extraordinaria" = 1, "Global" = 2)
    ),

    #Graph selector
    input_switch(
      ns("visualization_mode"),
      "Mostrar como gráfico de barras"
    ),

    # Years selector
    sliderInput(
      ns("years"),
      "Años seleccionados",
      min = 2010,
      max = last_year,
      value = c(2010, last_year),
      sep = "",
    ),

    # Arima prediction
    # checkboxInput("predict", "Predicción", FALSE),
  )
}

# main panel ui
main_panel_content_ui <- function(ns) {
  tagList(
    # Selector of subjects
    selectizeInput(
      ns("select_subject"),
      "Asignaturas",
      list(),
      multiple = TRUE,
      width = "100%"
    ),

    plotOutput(outputId = ns("subjects_main"))
  )
}


# Heatmap layout
heat_map_layout_ui <- function(ns) {
  tagList(
    radioButtons(
      inputId = ns("selector_heatmap"),
      label = " ",
      inline = TRUE,
      choices = list(
        "Aprobados (%)" = "pass_percentatge",
        "Media" = "average",
        "Coeficiente de variación" = "coefficient_variation"
      )
    ),
    div(
      style = "overflow-y: scroll;",
      plotOutput(ns("heatmap_subjects"), height = "800px")
    )
  )
}


#' subjects_page Server Functions
#'
#' @noRd
mod_subjects_page_server <- function(id, pool) {
  moduleServer(id, function(input, output, session) {

    ns <- session$ns
    # Graph View
    #############
    # get subjects and use them as options of selectize
    create_options_selectize(input, output, session, pool)

    # create main plot
    create_line_bar_plot(input, output, session, pool)

    # All data table
    create_all_data_table(input, output, session, pool)

    # Heatmap
    create_heatmap_subjects(input, output, session, pool)

    # Ranking

    mod_ranking_server("ranking_1", pool)
  })
}


# get subjects and use them as options of selectize

create_options_selectize <- function(input, output, session, pool) {
  df <- dbGetQuery(pool, "SELECT id, name FROM subjects")

  # choices con "etiqueta visible" = nombre y "valor" = id
  choices <- setNames(df$id, df$name)

  updateSelectizeInput(
    session,
    "select_subject",
    choices = choices,
    selected = c(4, 30),
    options = list(maxItems = 8), # comment to remove max
    server = TRUE
  )
}

# create main plot

# Main bar plot - line plot
create_line_bar_plot <- function(input, output, session, pool) {
  output$subjects_main <- renderPlot({
    # Get all the data of input
    varname <- input$variable
    call <- input$select_call
    first_year <- input$years[1]
    last_year <- input$years[2]
    subjects_id <- input$select_subject

    # preparate query
    sqlQuery <- glue_sql(
      "SELECT code, {`varname`}, subject_id, year  FROM subjects INNER JOIN marks ON subjects.id = marks.subject_id WHERE call = {call} AND year >= {first_year} AND year <= {last_year} AND subject_id IN ({subjects_id*})",
      .con = pool
    )

    # execute query on db
    df <- dbGetQuery(
      pool,
      sqlQuery
    )

    # The same as df but includes missing convinations
    df_completo <- df |>
      complete(code, year = seq(first_year, last_year, by = 1))

    # check if there is something to show
    if (is.null(subjects_id) || length(subjects_id) == 0) {
      return(NULL)
    }

    # Adds NA

    # Calculate ylim
    y_lims <- switch(
      varname,
      pass_percentatge = c(20, 100),
      coefficient_variation = c(0, 75),
      average = c(3, 9.5),
      range(df[[varname]], na.rm = TRUE) # <- default
    )

    # creates the plot
    plot <- ggplot(
      df,
      aes(x = year, y = !!sym(varname))
    )

    # checks if it is a barplot or a line plot
    if (input$visualization_mode) {
      plot <- plot +
        geom_col(position = "dodge", aes(fill = code))
    } else {
      # line plot
      plot <- plot +
        # Dashed line that goes bellow
        geom_line(linewidth = 2, linetype = "dashed", aes(color = code)) +

        # Solid line overposed to dashed line
        geom_line(
          data = df_completo,
          linewidth = 2,
          aes(color = code),
          na.rm = TRUE
        ) +

        # Point
        geom_point(size = 4, aes(color = code)) +
        scale_x_continuous(
          breaks = seq(
            min(df$year, na.rm = TRUE),
            max(df$year, na.rm = TRUE),
            by = 2
          )
        )
    }

    # Adds % symbol to pass_% and coefficiente of variation

    if (varname == "pass_percentatge" || varname == "coefficient_variation") {
      plot <- plot + scale_y_continuous(labels = function(x) paste0(x, "%"))
    }

    # configure the visual aspect of the plot, and return it
    plot +
      # Sets fixed ylim by range and years
      coord_cartesian(ylim = y_lims, xlim = c(first_year, last_year)) +
      guides(
        color = guide_legend(title = "Asignaturas"),
        fill = guide_legend(title = "Asignaturas")
      ) +
      labs(x = "Año", y = NULL, legend = NULL) +
      # TODO: modify look
      theme_minimal() +
      theme(
        panel.grid.major = element_line(color = "gray90"),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        axis.line = element_line(color = "black"),
        axis.ticks = element_line(color = "black"),
        plot.background = element_rect(fill = "white", color = NA),
        panel.background = element_rect(fill = "white", color = NA),
      )
  })
}


# Obtains all the data from the database and renders it to the database

create_all_data_table <- function(input, output, session, pool) {
  sqlQuery <- "
      SELECT
        name  AS Nombre,
        year  AS Año,
        call  AS Convocatoria,
        candidates AS Presentados,
        pass  AS Aptos,
        pass_percentatge AS Aptos2,
        average AS Media,
        coefficient_variation
      FROM subjects
      INNER JOIN marks ON subjects.id = marks.subject_id
    "
  df_pre <- dbGetQuery(
    pool,
    sqlQuery
  ) |>
    mutate(
      Convocatoria = case_match(
        as.integer(Convocatoria),
        0 ~ "Ordinaria",
        1 ~ "Extra",
        2 ~ "Global",
        .default = NA
      ) |>
        factor(levels = c("Ordinaria", "Extra", "Global")),
      `Aptos (%)` = Aptos2,
      `Coef. Variación` = coefficient_variation
    ) |>
    select(
      Nombre,
      Año,
      Convocatoria,
      Presentados,
      Aptos,
      `Aptos (%)`,
      Media,
      `Coef. Variación`
    )

  # Render DT with built-in column filters
  output$table_all_data <- renderDT({
    datatable(
      df_pre,
      filter = list(position = "top"),
      rownames = TRUE,
      # allow only to select one row
      selection= "single",
      options = list(
        pageLength = 25,
        lengthChange = FALSE, # hide "Show n entries"
        dom = "tp", # filters + table + info + pagination
        columnDefs = list(
          list(targets = c(4, 5, 6, 7, 8), searchable = FALSE), # disable filter on Aptos(%)
          list(targets = c(4, 5, 6, 7, 8), className = "dt-right") # right-align numeric cols
        )
      )
    ) |>
      formatRound(columns = c("Media", "Coef. Variación"), digits = 3)
  })
}

## To be copied in the UI
# mod_subjects_page_ui("subjects_page_1")

## To be copied in the server
# mod_subjects_page_server("subjects_page_1")

#  Creates the heatmap of subjects

create_heatmap_subjects <- function(input, output, session, pool) {
  output$heatmap_subjects <- renderPlot({
    varname <- input$selector_heatmap

    # preparate query
    sqlQuery <- glue_sql(
      "SELECT code, name, {`varname`} as value, subject_id, year FROM subjects INNER JOIN marks ON subjects.id = marks.subject_id WHERE call = 2",
      .con = pool
    )

    # Get the dataframe
    df <- dbGetQuery(
      pool,
      sqlQuery
    ) 
      
    # Creates the heatmap
    df |>
      add_count(name, name = "n_obs") |> # Sorts by the number of observations of each subject and then  by name
      group_by(name) |>
      mutate(n_obs = sum(!is.na(value))) |>
      ungroup() |>
      arrange(n_obs, desc(name)) |>
      mutate(name = factor(name, levels = unique(name))) |> 
      ggplot(aes(x = year, y = name, fill =  value)) +
      geom_tile(
        color = "white",
        linewidth = 0,
        width = 0.95,
        height = 0.85,
      ) +
      geom_text(aes(
        label = number(value, accuracy = 0.1),
        fontface = "bold",
        size = 4
      )) +
      coord_fixed(ratio = 0.375) +
      scale_fill_gradient2(
        low = "#c22d22ff",
        mid = "#e3e63bff",
        high = "#34f83eff",
        midpoint = mean(df$value, na.rm =TRUE),

        # Título de la leyenda de intensidad de color
        name = " "
      ) +
      scale_x_continuous(
        breaks = seq(min(df$year), max(df$year), by = 1),
        sec.axis = dup_axis()
      ) +
      scale_y_discrete(expand = expansion(mult = c(0.01, 0.01))) +
      guides(size = "none") +
      labs(
        x = "Año",
        y = "Asignatura",
      ) +
      # Tema limpio y legible
      theme_minimal(base_size = 12) +
      theme(
        panel.grid = element_blank(),
        axis.text.x = element_text(color = "black", size = 12),
        axis.text.y = element_text(color = "black", size = 12)
      )
  })
}
