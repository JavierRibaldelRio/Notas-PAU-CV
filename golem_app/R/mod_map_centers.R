#' map_centers UI Function
#'
#' @description Full-page Leaflet map showing all high schools,
#'   colour-coded by regime type with clickable markers that navigate
#'   to the center's detail page in the guide.
#'
#' @param id Internal parameter for {shiny}.
#' @noRd
mod_map_centers_ui <- function(id) {
  ns <- NS(id)
  card(
    fill = FALSE,
    card_header(icon("map-location-dot"), " Mapa de centros"),
    leafletOutput(ns("map"), height = "75vh")
  )
}


#' map_centers Server Function
#'
#' @param id Internal parameter for {shiny}.
#' @param pool Database connection pool.
#' @noRd
mod_map_centers_server <- function(id, pool) {
  moduleServer(id, function(input, output, session) {

    # Palette matching center_regime_badge() colours
    type_colors <- c("0" = "#198754", "1" = "#ffc107", "2" = "#dc3545")
    type_labels <- c("0" = "Público",  "1" = "Concertado", "2" = "Privado")

    # Load all schools with coordinates once — data does not change at runtime
    all_centers <- dbGetQuery(
      pool,
      "SELECT id, name, type_id, latitude, longitude
       FROM high_schools
       WHERE latitude IS NOT NULL AND longitude IS NOT NULL"
    ) |>
      mutate(
        type_id_chr  = as.character(type_id),
        marker_color = unname(type_colors[type_id_chr]),
        label_type   = unname(type_labels[type_id_chr]),
        name         = toTitleCase(tolower(name))
      )

    # Render the map with all markers directly — no filter, no proxy needed
    output$map <- renderLeaflet({
      leaflet(options = leafletOptions(scrollWheelZoom = TRUE)) |>
        addTiles() |>
        setView(lng = -0.75, lat = 39.5, zoom = 8) |>
        addLegend(
          position = "bottomright",
          colors   = unname(type_colors),
          labels   = unname(type_labels),
          title    = "Tipo de centro",
          opacity  = 1
        ) |>
        addCircleMarkers(
          data        = all_centers,
          lng         = ~longitude,
          lat         = ~latitude,
          radius      = 7,
          color       = ~marker_color,
          weight      = 1.5,
          fillColor   = ~marker_color,
          fillOpacity = 0.9,
          popup = ~sprintf(
            "<strong>%s</strong><br>
             <span class='badge' style='background:%s'>%s</span><br><br>
             <a href='#' onclick=\"
               Shiny.setInputValue('go_to_center', '%s', {priority: 'event'});
               document.querySelector('[data-value=centros]').click();
               return false;\">Ver ficha &rarr;</a>",
            name, marker_color, label_type, id
          ),
          label       = ~name
        )
    })

  })
}
