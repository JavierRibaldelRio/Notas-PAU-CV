#' subjects_page UI Function
#'
#' @description A shiny Module.
#'
#' @param id Internal parameters for {shiny}.
#' @param last_year Last year of we ha
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_subjects_page_ui <- function(id, last_year) {
  ns <- NS(id)

  print(last_year)
  tagList(
    card(
      layout_sidebar(
        sidebar = subjects_sidebar_ui(ns, last_year = last_year),
        main_panel_content_ui(ns)
      )
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


#' subjects_page Server Functions
#'
#' @noRd
mod_subjects_page_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    # get subjects and use them as options of selectize
    create_options_selectize(input, output, session, pool)

    # create main plot
    create_line_bar_plot(input, output, session, pool)
  })
}


subjects_server <- function(input, output, session, pool) {}

# get subjects and use them as options of selectize

create_options_selectize <- function(input, output, session, pool) {
  observe({
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
  })
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

    # check if there is something to show
    if (is.null(subjects_id) || length(subjects_id) == 0) {
      return(NULL)
    }

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
      plot <- plot +
        geom_point(aes(color = code)) +
        geom_line(linewidth = 2, aes(color = code)) +
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
      coord_cartesian(ylim = y_lims) +
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

## To be copied in the UI
# mod_subjects_page_ui("subjects_page_1")

## To be copied in the server
# mod_subjects_page_server("subjects_page_1")
