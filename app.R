library(shiny)
library(bslib)
library(DBI) # also install rsqlite
library(pool)
library(tidyverse)
library(glue)
library(rlang)

# Import UI
source("R/ui/ui.R")

DB_PATH <- "data/notas-pau.db"


server <- function(input, output, session) {
  # Conection to the database
  pool <- dbPool(
    drv = RSQLite::SQLite(),
    dbname = DB_PATH,
    flags = RSQLite::SQLITE_RO
  )

  # Settings of sqlite
  try(dbExecute(pool, "PRAGMA journal_mode = WAL;"), silent = TRUE)
  try(dbExecute(pool, "PRAGMA busy_timeout = 5000;"), silent = TRUE)
  try(dbExecute(pool, "PRAGMA synchronous = NORMAL;"), silent = TRUE)
  try(dbExecute(pool, "PRAGMA cache_size = 10000;"), silent = TRUE)

  onStop(function() poolClose(pool))

  # get options of selectize
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

  output$subjects_main <- renderPlot({
    varname <- input$variable
    call <- input$select_call
    first_year <- input$years[1]
    last_year <- input$years[2]

    subjects_id <- input$select_subject
    sqlQuery <- glue_sql(
      "SELECT code, {`varname`}, subject_id, year  FROM subjects INNER JOIN marks ON subjects.id = marks.subject_id WHERE call = {call} AND year >= {first_year} AND year <= {last_year} AND subject_id IN ({subjects_id*})",
      .con = pool
    )

    df <- dbGetQuery(
      pool,
      sqlQuery
    )

    plot <- ggplot(
      df,
      aes(x = year, y = !!sym(varname))
    )

    if (input$visualization_mode) {
      plot <- plot +
        geom_col(position = "dodge", aes(fill = code))
    } else {
      plot <- plot +
        geom_point(aes(color = code)) +
        geom_line(size = 2, aes(color = code)) +
        scale_x_continuous(
          breaks = seq(
            min(df$year, na.rm = TRUE),
            max(df$year, na.rm = TRUE),
            by = 2
          )
        )
    }

    plot <- plot +
      guides(
        color = guide_legend(title = "Asignaturas"),
        fill = guide_legend(title = "Asignaturas")
      ) +
      labs(x = "Año", y = NULL, legend = NULL) +
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

    plot
  })
}

shinyApp(ui = ui, server = server)
