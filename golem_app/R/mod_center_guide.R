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
    # Placeholder that gets swapped between the home list and a center detail page
    uiOutput("center_page")
  )
}

#' UI auxiliar function

# Renders the home page: a list of all high schools as clickable links.
# Clicking a link fires a JS event that sets input$go_to_center on the server.
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
            # Use JS to notify Shiny of the selected center ID without a full page reload
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

# Renders the detail page for a single high school.
# Fetches info, contact, and a plot of PAU results over the years.
page_center_ui <- function(id, pool) {
  center <- dbGetQuery(
    pool,
    "SELECT * FROM high_schools WHERE id = ?",
    params = list(id)
  )

  # Guard: show a friendly card if the ID does not exist in the DB
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

  # Encode the stored image blob as base64 so it can be embedded in an <img> tag
  img_base64 <- NULL
  if (!is.null(center$image[[1]])) {
    img_base64 <- base64enc::base64encode(center$image[[1]])
  }

  bslib::card(
    fill = FALSE, # disables fillable behaviour so the card sizes to its content

    bslib::card_header(
      paste("Ficha del centro:", center$name)
    ),

    # IMAGE — only rendered when the school has a stored photo
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

    # GENERAL INFO
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

    # CONTACT
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

    # RESULTS CHART — metric is controlled by the selectizeInput below
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

    # Back button: sets go_to_center to "0" which the server treats as "go home"
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

# Fallback page shown when a center_id in the URL does not match any school
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
  # Reactive value holding the currently selected center ID.
  # "0" means no center selected (home view).
  center_id <- reactiveVal("0")

  # ── Routing ───────────────────────────────────────────────────────────────

  # When the user switches tabs via the navbar, update the URL hash accordingly.
  # If leaving the "centros" tab, reset center_id so the home list is shown on return.
  observeEvent(input$page_selector, {
    target_tab <- input$page_selector

    if (target_tab == "centros") {
      current_query <- session$clientData$url_search

      # TODO: fix bug of having center_id at centers
      updateQueryString(
        paste0(current_query, "#", target_tab),
        mode = "replace",
        session
      )
    } else {
      center_id("0")   # reset center selection when leaving the tab

      updateQueryString(
        paste0("?#", target_tab),
        mode = "replace",
        session
      )
    }
  }, ignoreInit = TRUE)

  # On startup, read the URL hash and navigate the navbar to the matching tab.
  # Also resets center_id when the hash points away from "centros".
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

  # If there is no hash in the URL, write one based on the active tab
  # so the URL always reflects the current view.
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

  # Remove a stale center_id query param from the URL when the user is not
  # on the "centros" tab (e.g. after navigating away via the navbar).
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

  # Sync center_id reactive value from the URL query string on every URL change.
  # Falls back to "0" (home) when no center_id param is present.
  observe({
    query <- parseQueryString(session$clientData$url_search)
    id <- query$center_id %||% "0"

    center_id(id)
  })


  # ── In-page navigation ────────────────────────────────────────────────────

  # Fired when the user clicks a school link or the "back" button.
  # Updates both the reactive state and the URL so the view and address bar stay in sync.
  observeEvent(input$go_to_center, {
    newURL <- ""
    if (input$go_to_center != "0") {
      newURL <- paste0(
        "?center_id=",
        input$go_to_center,
        "#centros"
      )
    }

    center_id(input$go_to_center) # update state immediately (no need to wait for URL observer)

    updateQueryString(newURL, mode = "replace", session)
  })


  # ── Data ──────────────────────────────────────────────────────────────────

  # Fetches PAU result rows for the given school (call = 2 = ordinary sitting)
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

  # ── Outputs ───────────────────────────────────────────────────────────────

  # Line chart of PAU metrics over the years for the current center.
  # Re-renders whenever the selected metric or center changes.
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

  # Swaps between the home list, a center detail page, or the invalid-ID fallback
  # depending on the current center_id value.
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
