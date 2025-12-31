#' single_subject UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_single_subject_ui <- function(id) {
  ns <- NS(id)
  tagList(
    layout_column_wrap(
      width = NULL,

      style = css(grid_template_columns = "5fr 7fr "),

      # Left Column

      tagList(
        wellPanel(
          selectizeInput(ns("select_single_subject"), "Asignatura", list())
        ),
        card(
          layout_column_wrap(
            width = NULL,
            style = css(grid_template_columns = "2fr 1fr "),

            radioButtons(
              ns("convocatoria_double_plot"),
              label = "Convocatoria",
              choices = c("Ordinaria" = 0, "Extraordinaria" = 1, "Global" = 2),
              selected = 1,
              inline = TRUE
            ),
            selectizeInput(
              ns("double_plot_data"),
              "",
              choices = list(
                "Media" = "average",
                "Aptos (%)" = "pass_percentatge"
              )
            )
          ),
          plotOutput(ns("double_plot"), width = "100%")
        )
      ),
      card(
        mod_mean_year_selector_ui(
          ns("mean_year_selector_2"),
          label = "",
        ),
        plotOutput(ns("attendance_plot"), width = "100%")
      )
    )
  )
}

#' single_subject Server Functions
#'
#' @noRd
mod_single_subject_server <- function(id, pool) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    selected_year <- mod_mean_year_selector_server("mean_year_selector_2")

    # fills the select with the subjects
    fill_subjects(
      input,
      output,
      session,
      pool,
      "select_single_subject",
      selected = 4
    )

    # global data
    global_data <- reactiveVal()

    observe({
      gd <- dbGetQuery(
        pool,
        "SELECT year, call, enrolled, pass_percentage AS pass_percentatge, average_pau AS average FROM global_results"
      )

      global_data(gd)
    })

    # stores all the observations of a subject
    subject_data <- reactiveVal()

    #if ther ris a change in select_single_subject we update subject_data

    observeEvent(input$select_single_subject, {
      data <- dbGetQuery(
        pool,
        "SELECT * FROM marks WHERE subject_id = ?",
        list(input$select_single_subject)
      )

      subject_data(data)
    })

    output$double_plot <- renderPlot({
      # get data of the selected subject
      sd <- req(subject_data()) |>
        filter(call == input$convocatoria_double_plot)

      # varibles for the plots
      variable <- input$double_plot_data

      if (variable == "pass_percentatge") {
        yLabel <- labs(y = "Aptos (%)")
        y_lims <- c(20, 100)
      } else if (variable == "average") {
        yLabel <- labs(y = "Media")
        y_lims <- c(3, 9.5)
      } else {
        yLabel <- labs(y = "Media")
        y_lims <- range(df[[variable]], na.rm = TRUE)
      }

      top_margin <- 20

      # get primary color for plot
      theme <- bslib::bs_current_theme()
      primary_hex <- bslib::bs_get_variables(theme, varnames = "primary")

      # line plot (RIGHT)
      line_plot <- sd |>
        ggplot(aes(x = year, y = !!sym(variable))) +
        geom_smooth(
          se = FALSE,
          method = "loess",
          formula = 'y ~ x',
          color = primary_hex
        ) +
        coord_cartesian(ylim = y_lims) +
        scale_y_continuous(position = "right") +
        scale_x_continuous(
          breaks = seq(
            min(sd$year, na.rm = TRUE),
            max(sd$year, na.rm = TRUE),
            by = 2
          )
        ) +
        yLabel +
        labs(x = "Año") +
        theme_base() +
        theme(
          plot.margin = margin(top_margin, 0, 0, 0),
          axis.title.y = element_blank()
        )

      # box plot (LEFT)
      box_plot <- sd |>
        ggplot(aes(x = "", y = !!sym(variable))) +
        coord_cartesian(ylim = y_lims) +
        geom_boxplot(color = primary_hex) +
        geom_jitter(alpha = 0.25, color = primary_hex) +
        yLabel +
        theme_base() +
        theme(
          axis.title.x = element_blank(),
          axis.text.x = element_blank(),
          axis.ticks.x = element_blank(),
          plot.margin = margin(top_margin, 0, 0, 0)
        )

      # Put nexto and divide space
      (box_plot | line_plot) + plot_layout(widths = c(2, 11))
    })
    output$attendance_plot <- renderPlot({
      # get only data from global call
      sd <- req(subject_data()) |>
        filter(call == 2)

      # Hacer la media de todas las columnas
      df_mean <- sd |>
        summarise(across(where(is.numeric), mean, na.rm = TRUE)) |>
        mutate(
          candidates_total = candidates,
          pass_total = pass
        ) |>
        pivot_longer(
          cols = c(
            enrolled_total,
            candidates_total,
            pass_total,
            candidates_compulsory,
            pass_compulsory,
            candidates_optional,
            pass_optional
          ),
          names_to = "variable",
          values_to = "mean"
        ) |>
        mutate(
          scope = case_when(
            str_detect(variable, "total") ~ "Total",
            str_detect(variable, "compulsory") ~ "Compulsory",
            str_detect(variable, "optional") ~ "Optional"
          ),
          type = case_when(
            str_detect(variable, "enrolled") ~ "Matriculados",
            str_detect(variable, "candidates") ~ "Presentados",
            str_detect(variable, "pass") ~ "Aprobados"
          )
        ) |>

        mutate(
          scope = factor(
            scope,
            levels = c("Total", "Compulsory", "Optional")
          ),
          type = factor(
            type,
            levels = c("Aprobados", "Presentados", "Matriculados")
          )
        )
      ggplot(df_mean, aes(x = type, y = mean, fill = type)) +
        geom_col(
          width = 0.6,
          position = position_dodge2(
            width = 0.6,
            preserve = "single"
          )
        ) +
        coord_flip() +
          scale_y_continuous(
            sec.axis = dup_axis(name = NULL)
          ) +
          
        facet_grid(
          rows = vars(scope),
          scales = "free_y",
          space = "free_y"
                ) +
        labs(
          x = NULL,
          y = NULL,
          fill = NULL
        ) +
        theme(
          strip.placement = "outside",
          panel.spacing = unit(0, "pt"),
          plot.margin = margin(0, 0, 0, 0),

          strip.background = element_blank(),
          panel.background = element_rect(fill = "grey95", color = NA)
        ) +
        theme_base()
    })
  })
}

## To be copied in the UI
# mod_single_subject_ui("single_subject_1")

## To be copied in the server
# mod_single_subject_server("single_subject_1")
