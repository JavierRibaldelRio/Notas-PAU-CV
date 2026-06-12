# Modelo 1: nota media de la PAU (efectos fijos, within)
# Fuente única de cómputo. Se incluye con #| file: _modelo1.R
# Construye los objetos de salida sin imprimirlos.

suppressMessages({
  library(DBI); library(RSQLite); library(dbplyr); library(tidyverse)
  library(plm); library(lmtest); library(sandwich); library(DT); library(leaflet)
})

con <- dbConnect(RSQLite::SQLite(), "../data/notas-pau.db", flags = RSQLite::SQLITE_RO)

high_schools   <- tbl(con, "high_schools")
municipalities <- tbl(con, "municipalities")

datos <- tbl(con, "high_school_marks") |>
  inner_join(high_schools,   by = c("high_school_id" = "id")) |>
  inner_join(municipalities, by = c("municipality_id" = "id")) |>
  filter(call == 0, type_id != 2) |>
  select(high_school_id, year, average_compulsory_pau, average_bach,
         candidates, standard_dev_bach, type_id, region) |>
  collect()

datos <- datos |>
  arrange(high_school_id, year, is.na(standard_dev_bach)) |>
  distinct(high_school_id, year, .keep_all = TRUE) |>
  group_by(high_school_id) |>
  filter(n() > 10) |>
  ungroup() |>
  mutate(type_id = factor(type_id), region = factor(region))

panel <- datos |> as.data.frame() |> pdata.frame(index = c("high_school_id", "year"))

# Modelo within sobre la nota media de la PAU
fe_pau <- plm(
  average_compulsory_pau ~ average_bach + log(candidates) + standard_dev_bach,
  data = panel, model = "within"
)
b_avg_pau <- unname(round(coef(fe_pau)["average_bach"], 2))

# Efectos aleatorios y test de Hausman (FE vs RE)
re_pau <- plm(
  average_compulsory_pau ~ average_bach + log(candidates) + standard_dev_bach,
  data = panel, model = "random"
)
hausman_pau <- phtest(fe_pau, re_pau)

# Diagnóstico de los errores
hetero_pau <- bptest(fe_pau)   # heterocedasticidad (Breusch-Pagan)
auto_pau   <- pbgtest(fe_pau)  # autocorrelación temporal (Breusch-Godfrey/Wooldridge)
cross_pau  <- pcdtest(fe_pau)  # dependencia transversal (Pesaran CD)

diag_tests <- tibble::tibble(
  Contraste     = c("Breusch-Pagan", "Breusch-Godfrey / Wooldridge", "Pesaran CD"),
  `Qué detecta` = c("Heterocedasticidad", "Autocorrelación temporal",
                    "Dependencia transversal"),
  `p-valor`     = signif(c(hetero_pau$p.value, auto_pau$p.value, cross_pau$p.value), 3)
)

# Inferencia robusta: errores estándar HC + autocorrelación intra-centro
fe_pau_robust <- coeftest(
  fe_pau,
  vcov = vcovHC(fe_pau, method = "arellano", type = "HC1", cluster = "group")
)

# --- Efectos aleatorios: modelo twoways (introduce los efectos temporales) ---

# Within twoways: para el Hausman con la misma estructura de efectos
fe_pau_tw <- plm(
  average_compulsory_pau ~ average_bach + log(candidates) + standard_dev_bach,
  data = panel, model = "within", effect = "twoways"
)

# Random twoways: efecto del centro aleatorio + efectos temporales comunes lambda_t
re_pau_tw <- plm(
  average_compulsory_pau ~ average_bach + log(candidates) + standard_dev_bach,
  data = panel, model = "random", effect = "twoways", random.method = "walhus"
)

# Test de Hausman (twoways): ¿efectos fijos o aleatorios?
hausman_pau_tw <- phtest(fe_pau_tw, re_pau_tw)

# Diagnóstico de los errores del modelo aleatorio
hetero_re <- bptest(re_pau_tw)
auto_re   <- pbgtest(re_pau_tw)
cross_re  <- pcdtest(re_pau_tw)

diag_tests_re <- tibble::tibble(
  Contraste     = c("Breusch-Pagan", "Breusch-Godfrey / Wooldridge", "Pesaran CD"),
  `Qué detecta` = c("Heterocedasticidad", "Autocorrelación temporal",
                    "Dependencia transversal"),
  `p-valor`     = signif(c(hetero_re$p.value, auto_re$p.value, cross_re$p.value), 3)
)

# Inferencia robusta del modelo aleatorio
re_pau_robust <- coeftest(
  re_pau_tw,
  vcov = vcovHC(re_pau_tw, method = "arellano", type = "HC1", cluster = "group")
)

# Efecto fijo estimado por centro
fe_pau_eta <- tibble(
  high_school_id = as.integer(names(fixef(fe_pau))),
  eta            = as.numeric(fixef(fe_pau))
) |>
  left_join(distinct(datos, high_school_id, type_id), by = "high_school_id")

# Datos auxiliares (con la conexión todavía abierta)
nombres_centros <- high_schools |> select(high_school_id = id, centro = name) |> collect()
coords          <- high_schools |>
  select(high_school_id = id, centro = name, latitude, longitude) |> collect()
geo_centros     <- high_schools |>
  select(high_school_id = id, latitude, longitude, postal_code, municipality_id) |> collect()
mun_geo         <- municipalities |>
  select(municipality_id = id, region_id = region, province_id = province) |> collect()
comarcas        <- tbl(con, "regions")   |> select(region_id = id, comarca = name)  |> collect()
provincias      <- tbl(con, "provinces") |> select(province_id = id, provincia = name) |> collect()

dbDisconnect(con)

media_bach <- datos |>
  group_by(high_school_id) |>
  summarise(media_bach = mean(average_bach, na.rm = TRUE), .groups = "drop")

geo_eta <- fe_pau_eta |>
  left_join(geo_centros, by = "high_school_id") |>
  left_join(mun_geo,     by = "municipality_id") |>
  left_join(comarcas,    by = "region_id") |>
  left_join(provincias,  by = "province_id") |>
  mutate(comarca = factor(comarca), provincia = factor(provincia))

# --- Objetos de salida ---

theme_feria <- theme_minimal() +
  theme(
    panel.background = element_rect(fill = "transparent", colour = NA),
    plot.background  = element_rect(fill = "transparent", colour = NA),
    panel.grid.major = element_line(colour = "grey80"),
    panel.grid.minor = element_line(colour = "grey90"),
    axis.line        = element_line(colour = "grey70"),
    axis.ticks       = element_line(colour = "grey70")
  )

# Histograma de los efectos fijos por centro
g_histograma <- ggplot(fe_pau_eta, aes(x = eta)) +
  geom_histogram(bins = 40, fill = "darkorange", colour = "white") +
  labs(x = expression(hat(eta)[i]), y = "Nº de institutos") +
  theme_feria

# Tabla interactiva: efecto fijo por centro
dt_eta <- fe_pau_eta |>
  left_join(nombres_centros, by = "high_school_id") |>
  left_join(media_bach,      by = "high_school_id") |>
  transmute(
    Centro                    = centro,
    Titularidad               = if_else(type_id == "0", "Público", "Concertado"),
    `Nota media Bachillerato` = round(media_bach, 3),
    `Efecto fijo (eta)`       = round(eta, 3)
  ) |>
  arrange(desc(`Efecto fijo (eta)`)) |>
  datatable(rownames = FALSE, filter = "top",
            options = list(pageLength = 8, order = list(list(3, "desc"))))

# Mapa de efectos fijos
mapa_eta <- fe_pau_eta |>
  left_join(coords, by = "high_school_id") |>
  filter(!is.na(latitude), !is.na(longitude))
pal_eta <- colorNumeric(palette = "RdYlGn", domain = mapa_eta$eta)
m_mapa <- leaflet(mapa_eta) |>
  addProviderTiles(providers$CartoDB.Positron) |>
  setView(lng = -0.3763, lat = 39.4699, zoom = 10) |>
  addCircleMarkers(
    lng = ~longitude, lat = ~latitude, radius = 5,
    stroke = FALSE, fillOpacity = 0.8, color = ~pal_eta(eta),
    popup = ~paste0("<b>", centro, "</b><br>Efecto fijo: ", round(eta, 3))
  ) |>
  addLegend("bottomright", pal = pal_eta, values = ~eta,
            title = "Efecto fijo", opacity = 1)

# ¿Cuánto del efecto-centro explica la ubicación? (R² ajustado de 2ª etapa)
r2_ubicacion <- tibble(
  nivel = c("Coordenadas", "Provincia", "Comarca", "Código postal"),
  r2    = c(summary(lm(eta ~ latitude + longitude, data = geo_eta))$adj.r.squared,
            summary(lm(eta ~ provincia,            data = geo_eta))$adj.r.squared,
            summary(lm(eta ~ comarca,              data = geo_eta))$adj.r.squared,
            summary(lm(eta ~ factor(postal_code),  data = geo_eta))$adj.r.squared)
)

g_ubicacion <- ggplot(r2_ubicacion, aes(x = reorder(nivel, r2), y = r2)) +
  geom_col(fill = "steelblue", alpha = 0.85, width = 0.65) +
  geom_text(aes(label = scales::percent(r2, accuracy = 0.1)),
            hjust = -0.1, size = 5) +
  coord_flip() +
  scale_y_continuous(labels = scales::percent,
                     expand = expansion(mult = c(0, 0.18))) +
  labs(x = NULL, y = "Varianza del efecto-centro explicada (R² ajustado)") +
  theme_feria +
  theme(text = element_text(size = 15))

# Beta convergencia: ¿los centros con peor nota inicial crecen más rápido?
conv_centros <- datos |>
  filter(!is.na(average_compulsory_pau)) |>
  group_by(high_school_id) |>
  filter(n() >= 2) |>
  summarise(
    year_ini  = min(year),
    year_fin  = max(year),
    pau_ini   = average_compulsory_pau[which.min(year)],
    pau_fin   = average_compulsory_pau[which.max(year)],
    .groups   = "drop"
  ) |>
  mutate(
    anios     = year_fin - year_ini,
    crec_anual = (pau_fin - pau_ini) / anios,
    quintil   = ntile(pau_ini, 5)
  ) |>
  filter(anios > 0)

conv_quintiles <- conv_centros |>
  group_by(quintil) |>
  summarise(
    pau_ini_medio  = mean(pau_ini),
    crec_anual_medio = mean(crec_anual),
    n = n(),
    .groups = "drop"
  )

beta_fit <- lm(crec_anual ~ pau_ini, data = conv_centros)
beta_coef <- unname(round(coef(beta_fit)["pau_ini"], 3))

g_convergencia <- ggplot(conv_centros, aes(x = pau_ini, y = crec_anual)) +
  geom_point(aes(colour = factor(quintil)), alpha = 0.45, size = 1.5) +
  geom_smooth(method = "lm", se = FALSE, colour = "black", linewidth = 0.8) +
  geom_point(data = conv_quintiles,
             aes(x = pau_ini_medio, y = crec_anual_medio),
             colour = "black", fill = "white", shape = 21, size = 4, stroke = 1.2) +
  scale_colour_viridis_d(option = "plasma", end = 0.9, name = "Quintil\nnota inicial") +
  labs(x = "Nota media PAU inicial",
       y = "Crecimiento anual medio de la nota PAU") +
  theme_feria

trayectorias_quintiles <- datos |>
  inner_join(conv_centros |> select(high_school_id, quintil),
             by = "high_school_id") |>
  filter(!is.na(average_compulsory_pau))

g_convergencia_q <- ggplot(trayectorias_quintiles,
                           aes(x = year, y = average_compulsory_pau,
                               colour = factor(quintil), fill = factor(quintil))) +
  geom_smooth(method = "loess", linewidth = 1.1,
              se = TRUE, alpha = 0.12, level = 0.5) +
  geom_point(stat = "summary", fun = mean, size = 2, alpha = 0.35) +
  scale_colour_viridis_d(option = "plasma", end = 0.9,
                         name = "Quintil\nnota inicial") +
  scale_fill_viridis_d(option = "plasma", end = 0.9, guide = "none") +
  labs(x = "Año", y = "Nota media PAU") +
  theme_feria

# Ranking por comarca
g_comarca <- geo_eta |>
  filter(!is.na(comarca)) |>
  ggplot(aes(x = reorder(comarca, eta, FUN = median), y = eta)) +
  geom_hline(yintercept = 0, linetype = "dashed", colour = "grey60") +
  geom_boxplot(fill = "steelblue", alpha = 0.5, outlier.size = 0.5) +
  coord_flip() +
  labs(x = "Comarca", y = expression(hat(eta)[i])) +
  theme_feria
