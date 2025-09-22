library(shiny)
library(bslib)
library(DBI) # also install rsqlite
library(pool)
library(tidyverse)
library(glue)
library(rlang)

subjects_server <- function(input, output, session, pool) {
  # get subjects and use them as options of selectize
  create_options_selectize(input, output, session, pool)

  # create main plot
  create_line_bar_plot(input, output, session, pool)
}

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
      options = list(maxItems = 8),
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

    # creates the plot
    plot <- ggplot(
      df,
      aes(x = year, y = !!sym(varname))
    )

    # checks if it is a barplot o a line plot
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

    # configure the visual aspect of the plot, and return it
    plot +
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
