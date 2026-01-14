#' ranking UI Function
#'
#' @description A shiny Module.
#'
#' Uses CSS from external file
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_ranking_ui <- function(id) {
  ns <- NS(id)
  layout_sidebar(
    class = "mod-ranking",
    
    sidebar = sidebar(
      open = "always",
      width = 240,
      
      card(
        class = "bg-light",
        mod_mean_year_selector_ui(
          ns("mean_year_selector_1"),
          label = "Ámbito temporal",
        )
      )
    ),
    
 
      

      
     
        DTOutput(ns("ranking_subjects_dt"))
     

    
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
    selected_year <- mod_mean_year_selector_server("mean_year_selector_1")


    # Data extraction from DB
    datos_brutos <- reactive({
      opcion <-selected_year()


      # Different query for different the selected table
      if (opcion == 0) {
        df <- dbGetQuery(
          pool,
          "SELECT subjects.name, marks.average, marks.candidates FROM marks INNER JOIN subjects ON subjects.id = marks.subject_id  WHERE call=2 ;"
        )
        return(df)
      } else  {
        year <- opcion

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
      datos <- req(datos_brutos())
      transform_to_table(datos)
    })

    # Render the table
    output$ranking_subjects_dt <- renderDT({
      final_data <- req(datos_finales()) # Wait until the table is ready

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
        final_data,
        # allow only to select one row
        selection= "single",
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
