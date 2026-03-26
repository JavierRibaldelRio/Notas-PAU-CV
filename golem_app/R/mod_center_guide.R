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
  # overflow-y:auto neutralises the fillable flex context coming from page_fillable,
  # preventing leaflet's absolutely-positioned layers from escaping their card.
  tags$div(
    style = "overflow-y: auto; height: 100%; padding: 1rem;",
    uiOutput("center_page")
  )
}


# ── UI: home ──────────────────────────────────────────────────────────────────

# Renders the home page: a searchable list of all high schools as clickable links.
# Clicking a link fires a JS event that sets input$go_to_center on the server. 
page_home_ui <- function() {
  tagList(
    h2(icon("school"), " Guía de centros"),

    # Search bar with icon — raw input avoids the form-group wrapper that breaks input-group
    tags$div(
      class = "input-group mb-3",
      tags$span(class = "input-group-text", icon("magnifying-glass")),
      tags$input(
        type        = "text",
        id          = "center_search",
        class       = "form-control",
        placeholder = "Buscar centro..."
      )
    ),

    # List and count rendered server-side so filtering is handled in R
    uiOutput("center_count"),
    uiOutput("center_list")
  )
}


# ── UI: center detail sub-components ──────────────────────────────────────────

# Photo column: shows the school image or an empty placeholder to keep the grid.
center_photo_ui <- function(img_base64) {
  if (!is.null(img_base64)) {
    tags$img(
      src   = paste0("data:image/jpeg;base64,", img_base64),
      style = "width:100%; height:320px; object-fit:cover; border-radius:10px;"
    )
  } else {
    tags$div(style = "height:320px;")
  }
}

# General-info card: field list on the left, embedded mini-map on the right.
center_info_card_ui <- function(center) {
  regime_map   <- c("0" = "Público", "1" = "Concertado", "2" = "Privado")
  regime_label <- regime_map[as.character(center$type_id)]

  # add info if exists data
  addr_parts <- Filter(nzchar, c(
    if (!is.na(center$address))           center$address           else "",
    if (!is.na(center$postal_code))       center$postal_code       else "",
    if (!is.na(center$municipality_name)) center$municipality_name else "",
    if (!is.na(center$province_name))     center$province_name     else "",
    if (!is.na(center$region_name))       center$region_name       else ""
  ))

  card(
    fill  = FALSE,
    style = "height:320px; overflow-y:auto;",
    card_header(icon("circle-info"), " Información general"),

    tags$div(
      style = "display:flex; gap:1rem; height:100%;",

      # Fields — flex:1 + min-width:0 allow text to wrap without squeezing the map
      tags$ul(
        class = "list-unstyled mb-0",
        style = "flex:1 1 0; min-width:0; overflow-wrap:break-word;",
        if (!is.na(center$code) && nzchar(center$code))
          tags$li(icon("hashtag"), " ", strong("Código: "), center$code),
        if (!is.na(center$cif) && nzchar(center$cif))
          tags$li(icon("id-card"), " ", strong("CIF: "), center$cif),
        if (!is.na(regime_label))
          tags$li(icon("building"), " ", strong("Régimen: "), tags$span(class = "noun", regime_label)),
        if (!is.na(center$owner) && nzchar(center$owner))
          tags$li(icon("user"), " ", strong("Titularidad: "), tags$span(class = "noun", center$owner)),
        if (length(addr_parts) > 0)
          tags$li(
            icon("location-dot"), " ",
            strong("Dirección: "),
            tags$span(class = "noun", paste(addr_parts, collapse = ", "))
          )
      ),

      # Map — fills remaining horizontal space
      if (!is.na(center$latitude) && !is.na(center$longitude))
        tags$div(
          style = "flex:1 1 0; position:relative; min-height:200px;",
          leafletOutput("center_map", height = "100%")
        )
    )
  )
}

# Contact card: email (mailto), phone, website.
center_contact_card_ui <- function(center) {
  card(
    fill = FALSE,
    card_header(icon("address-book"), " Contacto"),

    tags$ul(
      class = "list-unstyled mb-0",
      if (!is.na(center$email) && nzchar(center$email))
        tags$li(
          icon("envelope"), " ",
          tags$a(center$email, href = paste0("mailto:", center$email))
        ),
      if (!is.na(center$phone_number) && nzchar(center$phone_number))
        tags$li(icon("phone"), " ", center$phone_number),
      if (!is.na(center$website) && nzchar(center$website))
        tags$li(
          icon("globe"), " ",
          tags$a(center$website, href = center$website, target = "_blank")
        )
    )
  )
}

# Chart card: metric selector + plot output.
center_chart_card_ui <- function() {
  card(
    fill = FALSE,
    card_header(icon("chart-line"), " Evolución de resultados PAU"),

    tags$div(
      style = "display:flex; flex-wrap:wrap; gap:1rem; align-items:flex-start;",

      tags$div(
        style = "flex:1 1 200px;",
        selectizeInput(
          "metric",
          "Indicador",
          choices = c(
            "Nota media PAU"          = "average_compulsory_pau",
            "Nota media Bachillerato" = "average_bach",
            "Aprobados (%)"           = "pass_percentatge",
            "Desv. estándar PAU"      = "standard_dev_pau",
            "Diferencia Bach–PAU"     = "diference_average_bach_pau",
            "Coef. variación PAU"     = "coeff_variation_pau",
            "Matriculados"            = "enrolled_total",
            "Presentados"             = "candidates",
            "Aprobados"               = "pass"
          ),
          selected = "average_compulsory_pau"
        )
      ),

      # Rendered server-side so min/max come from the actual data
      tags$div(style = "flex:1 1 200px;", uiOutput("year_range_slider"))
    ),

    plotOutput("center_marks_plot", height = "400px"),

    br(),
    tags$div(class = "mb-n3", DTOutput("center_marks_table"))
  )
}

# Returns a Bootstrap badge for the school regime type.
center_regime_badge <- function(type_id) {
  cfg <- switch(
    as.character(type_id),
    "0" = list(label = "Público",     class = "bg-success"),
    "1" = list(label = "Concertado",  class = "bg-warning text-dark"),
    "2" = list(label = "Privado",     class = "bg-danger"),
         list(label = "Desconocido", class = "bg-secondary")
  )
  tags$span(class = paste("badge", cfg$class), cfg$label)
}

# Full detail page assembled from sub-components.
page_center_ui <- function(center) {
  img_base64 <- NULL
  if (!is.null(center$image[[1]]))
    img_base64 <- base64enc::base64encode(center$image[[1]])

  card(
    fill = FALSE,

    card_header(
      class = "d-flex align-items-center gap-2",
      icon("school"),
      tags$span(class = "noun", center$name),
      center_regime_badge(center$type_id)
    ),

    layout_columns(
      col_widths = c(4, 8),
      style      = "height: 320px;",
      center_photo_ui(img_base64),
      center_info_card_ui(center)
    ),

    br(),
    center_contact_card_ui(center),
    br(),
    uiOutput("center_kpi_boxes"),
    br(),
    center_chart_card_ui(),
    br(),

    tags$div(
      class = "d-flex justify-content-start mt-2",
      tags$a(
        href    = "#",
        class   = "btn btn-outline-primary d-flex align-items-center gap-2",
        onclick = "Shiny.setInputValue('go_to_center', '0', {priority: 'event'}); return false;",
        icon("arrow-left"),
        tags$span("Volver a la guía de centros")
      )
    )
  )
}

# Fallback page shown when a center_id in the URL does not match any school.
page_invalid_ui <- function() {
  tagList(
    h2("Centro no encontrado"),
    p("El identificador solicitado no existe."),
    br(),
    tags$a(href = "?#centros", "Volver a la guía")
  )
}


# ── Server helpers (pure functions) ───────────────────────────────────────────

# Builds the comparison ggplot from pre-fetched data frames.
# Pure function — no reactivity, easy to unit-test.
build_marks_plot <- function(marks_df, nearest_df, global_df,
                             center_name, metric, theme_palette) {
  school_only <- c("diference_average_bach_pau", "coeff_variation_pau")
  cols        <- c("year", "source", metric)
  sources_ord <- character(0)
  color_map   <- character(0)
  dfs         <- list()

  # 1. Global — first in legend
  if (!metric %in% school_only && metric %in% names(global_df)) {
    dfs         <- c(dfs, list(global_df[, cols, drop = FALSE]))
    sources_ord <- c(sources_ord, "Global")
    color_map   <- c(color_map, theme_palette[["Global"]])
  }

  # 2. Selected center
  marks_df$source <- center_name
  dfs             <- c(dfs, list(marks_df[, cols, drop = FALSE]))
  sources_ord     <- c(sources_ord, center_name)
  color_map       <- c(color_map, theme_palette[["current"]])

  # 3. Nearest centers in distance order
  if (!is.null(nearest_df) && metric %in% names(nearest_df)) {
    near_names <- unique(nearest_df$source)
    near_keys  <- c("near_1", "near_2")
    for (i in seq_along(near_names)) {
      nm          <- near_names[[i]]
      dfs         <- c(dfs, list(nearest_df[nearest_df$source == nm, cols, drop = FALSE]))
      sources_ord <- c(sources_ord, nm)
      color_map   <- c(color_map, theme_palette[[near_keys[[i]]]])
    }
  }

  legend_labels      <- toTitleCase(sources_ord)
  df_combined        <- do.call(rbind, dfs)
  df_combined$source <- factor(df_combined$source, levels = sources_ord)
  names(color_map)   <- sources_ord

  ggplot(df_combined, aes(x = year, y = .data[[metric]], color = source, group = source)) +
    geom_line(linewidth = 1) +
    geom_point(size = 3) +
    scale_color_manual(values = color_map, labels = legend_labels) +
    labs(x = "Año", y = NULL, color = NULL) +
    scale_x_continuous(
      breaks = seq(
        min(df_combined$year, na.rm = TRUE),
        max(df_combined$year, na.rm = TRUE),
        by = 2
      )
    ) +
    theme_base()
}

# Builds the four KPI value boxes from the latest-year row.
# prev may be NULL when there is only one year of data.
# Pure function — no reactivity.
build_kpi_boxes <- function(latest, prev = NULL) {
  fmt <- function(x, digits = 2) {
    if (is.null(x) || is.na(x)) return("—")
    formatC(round(x, digits), format = "f", digits = digits)
  }

  # Returns a trend icon comparing current vs previous value.
  # higher_is_better controls whether an increase is shown in green or red.
  trend_icon <- function(cur, old, higher_is_better = TRUE) {
    if (is.null(old) || is.na(old) || is.null(cur) || is.na(cur)) return(NULL)
    if (cur > old) icon(if (higher_is_better) "arrow-trend-up"   else "arrow-trend-down")
    else if (cur < old) icon(if (higher_is_better) "arrow-trend-down" else "arrow-trend-up")
    else icon("minus")
  }

  layout_columns(
    col_widths = c(3, 3, 3, 3),
    value_box(
      title    = paste("Nota media PAU", latest$year),
      value    = tagList(fmt(latest$average_compulsory_pau),
                         trend_icon(latest$average_compulsory_pau, prev$average_compulsory_pau)),
      showcase = icon("graduation-cap"),
      theme    = "primary"
    ),
    value_box(
      title    = paste("Aprobados", latest$year),
      value    = tagList(paste0(fmt(latest$pass_percentatge, 1), " %"),
                         trend_icon(latest$pass_percentatge, prev$pass_percentatge)),
      showcase = icon("circle-check"),
      theme    = "success"
    ),
    value_box(
      title    = paste("Diferencia Bach–PAU", latest$year),
      value    = tagList(fmt(latest$diference_average_bach_pau),
                         trend_icon(latest$diference_average_bach_pau, prev$diference_average_bach_pau,
                                    higher_is_better = FALSE)),
      showcase = icon("scale-unbalanced"),
      theme    = "warning"
    ),
    value_box(
      title    = paste("Presentados", latest$year),
      value    = tagList(latest$candidates %||% "—",
                         trend_icon(latest$candidates, prev$candidates)),
      showcase = icon("users"),
      theme    = "secondary"
    )
  )
}


# ── Server helpers (reactive / observer setup) ────────────────────────────────

# Registers all URL-routing observers. Called once inside mod_center_guide_server.
setup_routing_observers <- function(input, session, center_id) {
  # Tab change → update URL hash; leaving "centros" resets selected center.
  observeEvent(input$page_selector, {
    target_tab <- input$page_selector
    if (target_tab == "centros") {
      updateQueryString(
        paste0(session$clientData$url_search, "#", target_tab),
        mode = "replace", session
      )
    } else {
      center_id("0")
      updateQueryString(paste0("?#", target_tab), mode = "replace", session)
    }
  }, ignoreInit = TRUE)

  # On startup: navigate navbar to the tab matching the URL hash.
  observeEvent(session$clientData$url_hash, {
    tab <- sub("^#", "", session$clientData$url_hash)
    if (nzchar(tab) && input$page_selector != tab)
      updateNavbarPage(session, "page_selector", selected = tab)
    if (tab != "centros") center_id("0")
  }, ignoreInit = FALSE)

  # Write a hash when the URL has none.
  observe({
    tab <- sub("^#", "", session$clientData$url_hash)
    if (!nzchar(tab) && !is.null(input$page_selector))
      updateQueryString(paste0("?#", input$page_selector), mode = "replace", session)
  })

  # Clean up stale center_id param when not on the "centros" tab.
  observe({
    tab   <- sub("^#", "", session$clientData$url_hash)
    query <- parseQueryString(session$clientData$url_search)
    if (!is.null(query$center_id) && tab != "centros")
      updateQueryString(paste0("?#", tab), mode = "replace", session)
  })

  # Sync center_id from URL query string.
  observe({
    query <- parseQueryString(session$clientData$url_search)
    center_id(query$center_id %||% "0")
  })

  # In-page navigation: school link or back button.
  observeEvent(input$go_to_center, {
    newURL <- if (input$go_to_center != "0")
      paste0("?center_id=", input$go_to_center, "#centros")
    else ""
    center_id(input$go_to_center)
    updateQueryString(newURL, mode = "replace", session)
  })
}


#' center_guide Server Functions
#'
#' @noRd
mod_center_guide_server <- function(id, input, output, session, pool) {
  center_id <- reactiveVal("0")

  setup_routing_observers(input, session, center_id)

  # ── Home list ───────────────────────────────────────────────────────────────

  # All centers loaded once — they don't change at runtime
  all_centers <- dbGetQuery(pool, "SELECT id, name, type_id FROM high_schools ORDER BY name")

  # Filtered subset reacts to the search input
  filtered_centers <- reactive({
    query <- trimws(input$center_search %||% "")
    if (!nzchar(query)) return(all_centers)
    all_centers |> filter(grepl(query, name, ignore.case = TRUE))
  })

  output$center_count <- renderUI({
    n     <- nrow(filtered_centers())
    total <- nrow(all_centers)
    p(class = "text-muted",
      if (n == total) sprintf("%d centros disponibles", total)
      else            sprintf("%d de %d centros", n, total)
    )
  })

  output$center_list <- renderUI({
    df <- filtered_centers()

    if (nrow(df) == 0) {
      return(p(class = "text-muted fst-italic", "No se han encontrado centros con ese nombre."))
    }

    tags$div(
      class = "list-group",
      lapply(seq_len(nrow(df)), function(i) {
        tags$a(
          href    = "#",
          class   = "list-group-item list-group-item-action d-flex justify-content-between align-items-center py-3",
          onclick = sprintf(
            "Shiny.setInputValue('go_to_center', '%s', {priority: 'event'}); return false;",
            df$id[i]
          ),
          tags$div(
            class = "d-flex align-items-center gap-2",
            center_regime_badge(df$type_id[i]),
            tags$span(class = "noun", df$name[i])
          ),
          icon("chevron-right")
        )
      })
    )
  })

  # ── Theme ──────────────────────────────────────────────────────────────────
  theme_palette <- isolate({
    tv <- bs_get_variables(
      session$getCurrentTheme(),
      c("primary", "warning", "success", "dark")
    )
    c(Global = tv[["dark"]], current = tv[["primary"]],
      near_1 = tv[["warning"]], near_2 = tv[["success"]])
  })

  # ── Reactives ──────────────────────────────────────────────────────────────

  # Get data of center
  center_data <- reactive({
    id <- center_id()
    if (is.null(id) || id == "0") return(NULL)
    row <- dbGetQuery(
      pool,
      "SELECT hs.*, m.name AS municipality_name,
              p.name AS province_name, r.name AS region_name
       FROM high_schools hs
       LEFT JOIN municipalities m ON m.id = hs.municipality_id
       LEFT JOIN provinces      p ON p.id = m.province
       LEFT JOIN regions        r ON r.id = m.region
       WHERE hs.id = ?",
      params = list(id)
    )
    if (nrow(row) == 0) return(NULL)
    row[1, ]
  })

  # get data of the center
  marks_data <- reactive({
    center <- req(center_data())
    dbGetQuery(
      pool,
      "SELECT year, call, enrolled_total, candidates, pass,
              pass_percentatge, average_bach, average_compulsory_pau,
              standard_dev_pau, diference_average_bach_pau, coeff_variation_pau
       FROM high_school_marks
       WHERE high_school_id = ? AND call = 2
       ORDER BY year",
      params = list(center$id)
    )
  })

  nearest_marks <- reactive({
    center <- req(center_data())
    if (is.na(center$latitude) || is.na(center$longitude)) return(NULL)

    # get shorter distance centers
    nc <- dbGetQuery(
      pool,
      "SELECT id, name FROM high_schools
       WHERE id != ? AND latitude IS NOT NULL AND longitude IS NOT NULL
       ORDER BY ((latitude - ?) * (latitude - ?) + (longitude - ?) * (longitude - ?)) ASC
       LIMIT 2",
      params = list(center$id,
                    center$latitude, center$latitude,
                    center$longitude, center$longitude)
    )
    if (nrow(nc) == 0) return(NULL)

    
    placeholders <- paste(rep("?", nrow(nc)), collapse = ", ")
    
    # get data of nearest centers
    dbGetQuery(
      pool,
      sprintf(
        "SELECT hsm.year, hs.id AS source_id, hs.name AS source,
                hsm.enrolled_total, hsm.candidates, hsm.pass,
                hsm.pass_percentatge, hsm.average_bach,
                hsm.average_compulsory_pau, hsm.standard_dev_pau,
                hsm.diference_average_bach_pau, hsm.coeff_variation_pau
         FROM high_school_marks hsm
         JOIN high_schools hs ON hs.id = hsm.high_school_id
         WHERE hsm.high_school_id IN (%s) AND hsm.call = 2
         ORDER BY hsm.year", placeholders
      ),
      params = as.list(nc$id)
    )
  })

  global_marks <- reactive({
    df <- dbGetQuery(
      pool,
      "SELECT year, enrolled AS enrolled_total, candidates, pass,
              pass_percentage AS pass_percentatge, average_bach,
              average_pau AS average_compulsory_pau, standard_dev_pau
       FROM global_results WHERE call = 2 ORDER BY year"
    )
    df$source <- "Global"
    df
  })

  # ── Outputs ────────────────────────────────────────────────────────────────

  # Year range slider — built from the actual years available for this center
  output$year_range_slider <- renderUI({
    years <- marks_data()$year
    req(length(years) > 0)
    sliderInput(
      "year_range",
      "Rango de años",
      min   = min(years),
      max   = max(years),
      value = c(min(years), max(years)),
      step  = 1,
      sep   = ""
    )
  })

  output$center_marks_plot <- renderPlot({
    req(length(input$year_range) == 2)
    yr <- input$year_range

    build_marks_plot(
      marks_df    = marks_data()   |> filter(year >= yr[1], year <= yr[2]),
      nearest_df  = nearest_marks() |> (\(nd) if (!is.null(nd)) filter(nd, year >= yr[1], year <= yr[2]) else NULL)(),
      global_df   = global_marks()  |> filter(year >= yr[1], year <= yr[2]),
      center_name = req(center_data())$name,
      metric      = req(input$metric),
      theme_palette
    )
  })

  output$center_marks_table <- renderDT({
    req(length(input$year_range) == 2, input$metric)
    yr     <- input$year_range
    metric <- input$metric

    center <- req(center_data())

    list(
      marks_data()   |> mutate(source_id = center$id,  source = center$name),
      nearest_marks(),
      global_marks() |> mutate(source_id = NA_integer_)
    ) |>
      compact() |>
      bind_rows() |>
      filter(year >= yr[1], year <= yr[2]) |>
      select(source_id, source, year, value = all_of(metric)) |>
      pivot_wider(names_from = year, values_from = value) |>
      mutate(
        across(where(is.numeric), \(x) round(x, 2)),
        Centro = case_when(
          source_id == center$id ~
            paste0('<strong class="noun">', source, "</strong>"),
          is.na(source_id) ~
            paste0('<span class="noun">', source, "</span>"),
          .default = sprintf(
            "<a href='#' class='noun' onclick=\"Shiny.setInputValue('go_to_center', '%s', {priority: 'event'}); return false;\">%s</a>",
            source_id, source
          )
        )
      ) |>
      select(-source, -source_id) |>
      relocate(Centro) |>
      datatable(
        rownames = FALSE,
        escape   = FALSE,
        options  = list(dom = "t", ordering = TRUE)
      )
  })

  output$center_kpi_boxes <- renderUI({
    df <- marks_data() |> arrange(year)
    if (nrow(df) == 0) return(NULL)
    latest <- df[nrow(df), ]
    prev   <- if (nrow(df) >= 2) df[nrow(df) - 1, ] else NULL
    build_kpi_boxes(latest, prev)
  })

  output$center_map <- renderLeaflet({
    center <- req(center_data())
    req(!is.na(center$latitude), !is.na(center$longitude))
    leaflet(options = leafletOptions(scrollWheelZoom = FALSE)) |>
      addTiles() |>
      addMarkers(lng = center$longitude, lat = center$latitude, popup = center$name)
  })

  output$center_page <- renderUI({
    id <- center_id()
    if (is.null(id) || id == "0") return(page_home_ui())
    center <- center_data()
    if (is.null(center)) return(page_invalid_ui())
    page_center_ui(center)
  })
}

## To be copied in the UI
# mod_center_guide_ui("center_guide_1")

## To be copied in the server
# mod_center_guide_server("center_guide_1")
