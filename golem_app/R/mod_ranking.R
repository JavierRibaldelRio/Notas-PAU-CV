#' ranking UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_ranking_ui <- function(id) {
  ns <- NS(id)
  tagList(
    # CSS for the table
    tags$head(
      tags$style(HTML(
        paste0(
          "#",
          ns("ranking_subjects_dt"),
          " table.dataTable { font-size: 16px !important; border: 2px solid #555 !important;}",

          "#",
          ns("ranking_subjects_dt"),
          " table.dataTable td, ",
          "#",
          ns("ranking_subjects_dt"),
          " table.dataTable th { ",
          "   vertical-align: middle !important;",
          "}",

          "#",
          ns("ranking_subjects_dt"),
          " thead tr:first-child th { text-align: center; }",

          "#",
          ns("ranking_subjects_dt"),
          " thead tr:first-child th, ",
          "#",
          ns("ranking_subjects_dt"),
          " thead tr:nth-child(2) th:nth-child(2n) ,",
          "#",
          ns("ranking_subjects_dt"),
          " tbody td:nth-child(2n+1) { 
              border-right: 2px solid #999 !important; 
          }"
        )
      ))
    ),

    br(), # Separation between the top of the card and selector

    fluidRow(
      # Centered container
      column(
        width = 8,
        offset = 2,

        # This creates the gray background
        wellPanel(
          fluidRow(
            # Radio buttons
            column(
              width = 6,
              align = "center",
              radioButtons(
                inputId = ns("ranking_subjects"),
                label = "Modo de visualización",
                choices = list("Global", "Año"),
                selected = "Global",
                inline = TRUE
              )
            ),

            # Selector (only appears if "Año" is selected)
            column(
              width = 6,
              align = "center",
              conditionalPanel(
                ns = ns,
                condition = "input.ranking_subjects == 'Año'",
                selectInput(
                  ns("ranking_subjects_select"),
                  "Selecciona el año",
                  choices = 2010:2024,
                  width = "100%"
                )
              )
            )
          )
        )
      )
    ),
    # Here we show the table
    fluidRow(
      # Centered table
      column(
        width = 10,
        offset = 1,
        DTOutput(ns("ranking_subjects_dt"))
      )
    )
  )
}

# Transform data
transform_to_table <- function(dt) {
  umbral_presentados <- 30

  # Mean
  notas <- dt |>
    group_by(name) |>
    summarise(
      average = mean(average, na.rm = TRUE),
      candidates = mean(candidates, na.rm = TRUE)
    ) |>
    ungroup()


  # Filter by grades
  notas_filtradas <- notas |>
    filter(candidates > umbral_presentados)

  # With the purpose of having the number of the ranking as another col
  best_grades <- notas_filtradas |>
    arrange(desc(average)) |>
    select(
      Asig_Mejor = name,
      Nota_Mejor = average
    )

  # Binding of all data into one
  ranking_final <- bind_cols(
    # Thanks to best_grades we can have the number in the ranking
    tibble(Pos = 1:nrow(best_grades)),

    # Best grades
    best_grades,

    # Worst grades
    notas_filtradas |>
      arrange(average) |>
      select(
        Asig_Peor = name,
        Nota_Peor = average
      ),

    # More candidates
    notas_filtradas |>
      arrange(desc(candidates)) |>
      select(
        Asig_Mas = name,
        Cand_Mas = candidates
      ),

    # Less candidates
    notas_filtradas |>
      arrange(candidates) |>
      select(
        Asig_Menos = name,
        Cand_Menos = candidates
      )
  )

  return(ranking_final)
}

#' ranking Server Functions
#'
#' @noRd
mod_ranking_server <- function(id, pool) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Data extraction from DB
    datos_brutos <- reactive({
      req(input$ranking_subjects)
      opcion <- input$ranking_subjects

      # Different query for different the selected table
      if (opcion == "Global") {
        df <- dbGetQuery(
          pool,
          "SELECT subjects.name, marks.average, marks.candidates FROM marks INNER JOIN subjects ON subjects.id = marks.subject_id;"
        )
        return(df)
      } else if (opcion == "Año") {
        req(input$ranking_subjects_select)
        year <- input$ranking_subjects_select


        # call = 2 to get the data of global of a single year
        sql_query <- glue_sql(
          "SELECT subjects.name, marks.average, marks.candidates FROM marks INNER JOIN subjects on subjects.id = marks.subject_id WHERE marks.year = {year} AND call=2 ;",
          .con = pool
        )

        df <- dbGetQuery(pool, sql_query)
        return(df)
      }
    })

    # Data transform
    datos_finales <- reactive({
      req(datos_brutos()) # Wait until the data is ready
      transform_to_table(datos_brutos())
    })

    # Render the table
    output$ranking_subjects_dt <- renderDT({
      req(datos_finales()) # Wait until the table is ready

      # Custom header
      sketch <- withTags(table(
        class = 'display cell-border compact',
        thead(
          tr(
            th(rowspan = 2, '#'),
            th(colspan = 2, 'Mejores calificaciones'),
            th(colspan = 2, 'Peores calificaciones'),
            th(colspan = 2, 'Mayor número de presentados'),
            th(colspan = 2, 'Menor número de presentados')
          ),
          tr(
            th('Asignatura'),
            th('Nota'),
            th('Asignatura'),
            th('Nota'),
            th('Asignatura'),
            th('Presentados'),
            th('Asignatura'),
            th('Presentados')
          )
        )
      ))

      # Return dt
      datatable(
        datos_finales(),
        container = sketch,
        rownames = FALSE,
        options = list(
          dom = 't',
          ordering = FALSE, # Is already ordered
          autoWidth = FALSE,
          scrollColapse = TRUE,
          columnDefs = list(
            # Ranking position
            list(
              targets = 0,
              className = 'dt-center dt-bold',
              width = '4%',
              searchable = FALSE
            ),
            # Subject names
            list(
              targets = c(1, 3, 5, 7),
              className = 'dt-left',
              width = '18%'
            ),

            # Grades
            list(
              targets = c(2, 4, 6, 8),
              className = 'dt-center',
              width = '7%'
            )
          )
        )
      ) |>
        # Change ',' by '.' and vice versa, and specific decimal digits
        formatRound(
          columns = c("Nota_Mejor", "Nota_Peor"),
          digits = 3,
          dec.mark = ",",
          mark = "."
        ) |>
        formatRound(
          columns = c("Cand_Mas", "Cand_Menos"),
          digits = 2,
          dec.mark = ",",
          mark = "."
        )
    })
  })
}
