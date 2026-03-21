#' center_guide UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_center_guide_ui <- function(id) {
  tagList(
    uiOutput("center_page")
  )
}

#' UI auxiliar function

page_home_ui <- function(con) {
  centers <- DBI::dbGetQuery(
    con,
    "SELECT name, id FROM high_schools"
  )

  tagList(
    h2("Guía de centros"),
    p("Seleccione un centro:"),

    tags$ul(
      lapply(seq_len(nrow(centers)), function(i) {
        tags$li(
          tags$a(
            href = "#",
            centers$name[i],
            onclick = sprintf(
              "Shiny.setInputValue('%s', '%s', {priority: 'event'}); return false;",
              "go_to_center",
              centers$id[i]
            )
          )
        )
      })
    )
  )
}
page_center_ui <- function(id, pool) {
  center <- dbGetQuery(
    pool,
    "SELECT * FROM high_schools WHERE id = ?",
    params = list(id)
  )

  if (nrow(center) == 0) {
    return(
      bslib::card(
        fill = FALSE,
        bslib::card_header("Centro no encontrado"),
        "El centro solicitado no existe."
      )
    )
  }

  center <- center[1, ]

  img_base64 <- NULL
  if (!is.null(center$image[[1]])) {
    img_base64 <- base64enc::base64encode(center$image[[1]])
  }

  bslib::card(
    fill = FALSE, # ← rompe el comportamiento fillable

    bslib::card_header(
      paste("Ficha del centro:", center$name)
    ),

    # IMAGEN
    if (!is.null(img_base64)) {
      tags$div(
        style = "margin-bottom:30px;",

        tags$img(
          src = paste0("data:image/jpeg;base64,", img_base64),
          style = "
            max-width:100%;
            max-height:420px;
            object-fit:contain;
            border-radius:10px;
            display:block;
            margin-left:auto;
            margin-right:auto;
          "
        )
      )
    },

    # INFORMACIÓN
    bslib::card(
      fill = FALSE,
      bslib::card_header("Información general"),

      tags$ul(
        tags$li(strong("Código: "), center$code),
        tags$li(strong("CIF: "), center$cif),
        tags$li(strong("Titularidad: "), center$owner),
        tags$li(strong("Dirección: "), center$address),
        tags$li(strong("Código postal: "), center$postal_code)
      )
    ),

    br(),

    # CONTACTO
    bslib::card(
      fill = FALSE,
      bslib::card_header("Contacto"),

      tags$ul(
        tags$li(strong("Email: "), center$email),
        tags$li(strong("Teléfono: "), center$phone_number),
        tags$li(
          strong("Web: "),
          tags$a(center$website, href = center$website, target = "_blank")
        )
      )
    ),

    br(),

    # GRÁFICA
    bslib::card(
      fill = FALSE,
      bslib::card_header("Evolución de resultados PAU"),

      selectizeInput(
        "metric",
        "Indicador",
        choices = c(
          "Nota media PAU" = "average_compulsory_pau",
          "Nota media Bachillerato" = "average_bach",
          "Aprobados (%)" = "pass_percentatge",
          "Desv. estándar PAU" = "standard_dev_pau"
        ),
        selected = "average_compulsory_pau"
      ),

      plotOutput(
        "center_marks_plot",
        height = "400px"
      )
    ),

    br(),

    tags$a(
      href = "#",
      class = "btn btn-outline-secondary",
      "Volver a la guía",
      onclick = sprintf(
        "Shiny.setInputValue('%s', '%s', {priority: 'event'}); return false;",
        "go_to_center",
        "0"
      )
    )
  )
}

page_invalid_ui <- function() {
  tagList(
    h2("Centro no encontrado"),

    p("El identificador solicitado no existe."),

    br(),

    tags$a(
      href = "?#centros",
      "Volver a la guía"
    )
  )
}


#' center_guide Server Functions
#'
#' @noRd
mod_center_guide_server <- function(id, input, output, session, pool) {
  center_id <- reactiveVal("0")

  observeEvent(input$page_selector, {
    target_tab <- input$page_selector
  
    if (target_tab == "centros") {
      current_query <- session$clientData$url_search
  
      updateQueryString(
        paste0(current_query, "#", target_tab),
        mode = "replace",
        session
      )
    } else {
      center_id("0")   # resetear aquí
  
      updateQueryString(
        paste0("?#", target_tab),
        mode = "replace",
        session
      )
    }
  }, ignoreInit = TRUE)

  # -----------------------------------------------------
  # 2) URL → UI  (deep links, back/forward, carga inicial)
  # -----------------------------------------------------
  observeEvent(
    session$clientData$url_hash,
    {
      tab <- sub("^#", "", session$clientData$url_hash)

      if (nzchar(tab) && input$page_selector != tab) {
        updateNavbarPage(
          session,
          "page_selector",
          selected = tab
        )
      }

      if (tab != "centros") {
        center_id("0")
      }
    },
    ignoreInit = FALSE
  )

  # -----------------------------------------------------
  # 3) Inicialización si no hay hash
  # -----------------------------------------------------
  observe({
    tab <- sub("^#", "", session$clientData$url_hash)

    if (!nzchar(tab) && !is.null(input$page_selector)) {
      updateQueryString(
        paste0("?#", input$page_selector),
        mode = "replace",
        session
      )
    }


  })

  # -----------------------------------------------------
  # 4) Limpiar center_id fuera de #centros
  # -----------------------------------------------------
  observe({
    tab <- sub("^#", "", session$clientData$url_hash)
    query <- parseQueryString(session$clientData$url_search)

    if (!is.null(query$center_id) && tab != "centros") {
      updateQueryString(
        paste0("?#", tab),
        mode = "replace",
        session
      )
    }
  })

  observe({
    query <- parseQueryString(session$clientData$url_search)
    id <- query$center_id %||% "0"

    center_id(id)
  })

  

  get_marks <- function(cente_id) {
    dbGetQuery(
      pool,
      "SELECT year, call,
               average_compulsory_pau,
               average_bach,
               pass_percentatge,
               standard_dev_pau
        FROM high_school_marks
        WHERE high_school_id = ? and call = 2
        ",
      params = list(cente_id)
    )
  }

  observeEvent(input$go_to_center, {
    # update url
    newURL <- ""
    if (input$go_to_center != "0") {
      newURL <- paste0(
        "?center_id=",
        input$go_to_center,
        "#centros"
      )
    }

    center_id(input$go_to_center) # Update state

    updateQueryString(newURL, mode = "replace", session)
  })

  output$center_marks_plot <- renderPlot({
    req(input$metric)
    id <- center_id()

    df <- get_marks(id)

    ggplot(
      df,
      aes(
        x = year,
        y = .data[[input$metric]],
        group = call
      )
    ) +
      geom_line(linewidth = 1) +
      geom_point(size = 3) +
      labs(
        x = "Año",
        y = NULL,
        color = "Convocatoria"
      ) +
      theme_base()
  })

  output$center_page <- renderUI({
    id <- center_id()

    if (is.null(id) || id == "0") {
      return(page_home_ui(pool))
    }

    if (id != "23") {
      return(page_center_ui(id, pool))
    }

    page_invalid_ui()
  })
}

## To be copied in the UI
# mod_center_guide_ui("center_guide_1")

## To be copied in the server
# mod_center_guide_server("center_guide_1")
