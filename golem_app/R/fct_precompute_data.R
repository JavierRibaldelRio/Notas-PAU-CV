#' precompute_data
#'
#' @description A fct function
#'
#' @return The return value, if any, from executing the function.
#'
#'

precompute_data <- function(force = TRUE) {
  message("Precompute data")

  con <- create_sqlite_con_precompute()

  create_region_data(con)
  create_municialities_data(con)

  on.exit(DBI::dbDisconnect(con), add = TRUE)
}

# Each YEAR
# summarise fore each data
summarise_pau_metrics <- function(data) {
  data |>
    dplyr::summarise(
      enrolled_total_sum = sum(enrolled_total, na.rm = TRUE), # total students enrolled
      candidates_total_sum = sum(candidates, na.rm = TRUE), # total PAU candidates
      pass_total = sum(pass, na.rm = TRUE), # total students who passed
      pass_percentatge = pass_total / candidates_total_sum * 100, # overall pass rate (weighted)

      average_bach = sum(average_bach * candidates, na.rm = TRUE) /
        candidates_total_sum, # weighted mean of bach grades
      average_compulsory_pau = sum(
        average_compulsory_pau * candidates,
        na.rm = TRUE
      ) /
        candidates_total_sum,

      diference_average_bach_pau = average_bach - average_compulsory_pau,

      .groups = "drop"
    )
}

# Global of YEARS (year=0)
summarise_pau_metrics_all <- function(data) {
  data |>
    dplyr::summarise(
      pass_total = sum(pass_total),
      average_bach = sum(enrolled_total_sum * average_bach) /
        sum(enrolled_total_sum),
      average_compulsory_pau = sum(
        candidates_total_sum * average_compulsory_pau
      ) /
        sum(candidates_total_sum),
      enrolled_total_sum = sum(enrolled_total_sum),
      candidates_total_sum = sum(candidates_total_sum),
      pass_percentatge = pass_total / candidates_total_sum,
      diference_average_bach_pau = average_bach - average_compulsory_pau,
      year = as.integer(0),
      .groups = "drop"
    )
}

# region data
create_region_data <- function(con) {
  # Query regional-level education data by joining high schools, municipalities, and regions, and retrieving aggregated academic performance metrics.
  df <- DBI::dbGetQuery(
    con,
    "
    SELECT
      regions.name,
      regions.region_code,
      high_schools.type_id,
      year,
      call,
      enrolled_total,
      candidates,
      pass,
      pass_percentatge ,
      average_bach ,
      standard_dev_bach ,
      average_compulsory_pau ,
      standard_dev_pau,
      diference_average_bach_pau , 
	    coeff_variation_bach, 
	    coeff_variation_pau
    FROM high_schools
    JOIN municipalities 
      ON high_schools.municipality_id = municipalities.id
    JOIN regions
      ON municipalities.region = regions.id
    LEFT JOIN high_school_marks
      ON high_school_marks.high_school_id = high_schools.id
    ORDER BY regions.name;
    "
  )

  # data per name-regioncode -type_idecenter-year-call-variable-value
  region_data <- dplyr::bind_rows(
    # separte for eacht type_id
    df |>
      dplyr::group_by(name, region_code, type_id, year, call) |>
      summarise_pau_metrics(),

    #without separate for each type_id under type_id = 3
    df |>
      dplyr::group_by(name, region_code, year, call) |>
      summarise_pau_metrics() |>
      dplyr::mutate(type_id = as.integer(3))
  )

  resu <-
  dplyr::bind_rows(
    
    region_data |>
      dplyr::filter(type_id != 3) |>
      dplyr::group_by(name, region_code, type_id, call) |>
      summarise_pau_metrics_all(),

    region_data |>
      dplyr::filter(type_id != 3) |>
      dplyr::group_by(name, region_code, call) |>
      summarise_pau_metrics_all() |>
      dplyr::mutate(type_id = as.integer(3))
  )

  # Every year + global year 
  region_data <- dplyr::bind_rows(region_data, resu)

  
  # stores the data

  saveRDS(region_data, file = "inst/app/data/data_region.rds")

  message("data_region was successfully created.")
}

create_municialities_data <- function(con) {

  df <- DBI::dbGetQuery(
    con,
    "
    SELECT 
      regions.id AS code_region,
      regions.name AS regiones,
      municipalities.id AS code_municipality,
      municipalities.name AS municipios,
      high_schools.id AS code_high_school,
      high_schools.name AS name_high_school,
      high_school_types.id AS type_id_high_school,
      high_school_types.type AS type_high_school,
      year,
      call,
      enrolled_total,
      candidates,
      pass,
      pass_percentatge,
      average_bach,
      standard_dev_bach,
      average_compulsory_pau,
      standard_dev_pau,
      diference_average_bach_pau,
      coeff_variation_bach,
      coeff_variation_pau
    FROM high_school_marks 
    INNER JOIN high_schools 
      ON high_school_marks.high_school_id = high_schools.id 
    INNER JOIN high_school_types 
      ON high_schools.type_id = high_school_types.id 
    INNER JOIN municipalities 
      ON high_schools.municipality_id = municipalities.id 
    INNER JOIN regions 
      ON municipalities.region = regions.id
    ORDER BY code_high_school;
    "
  )

  # data per name-regioncode -type_idecenter-year-call-variable-value
  municipality_data <- dplyr::bind_rows(
    # separte for eacht type_id
    df |>
      dplyr::group_by(code_region, regiones, code_municipality, municipios, type_id_high_school, year, call) |>
      summarise_pau_metrics(),

    #without separate for each type_id under type_id = 4
    df |>
      dplyr::group_by(code_region, regiones, code_municipality, municipios, year, call) |>
      summarise_pau_metrics() |>
      dplyr::mutate(type_id_high_school = as.integer(3))
  )

  resu <-
  dplyr::bind_rows(
    
    municipality_data |>
      dplyr::filter(type_id_high_school != 3) |>
      dplyr::group_by(code_region, regiones, code_municipality, municipios, type_id_high_school, call) |>
      summarise_pau_metrics_all(),

    municipality_data |>
      dplyr::filter(type_id_high_school != 3) |>
      dplyr::group_by(code_region, regiones, code_municipality, municipios, call) |>
      summarise_pau_metrics_all() |>
      dplyr::mutate(type_id_high_school = as.integer(3))
  )

  municipality_data <- dplyr::bind_rows(municipality_data, resu)

  # Store data
  saveRDS(municipality_data, file = "inst/app/data/data_municipality.rds")
  message("data_municipality was successfully created.")
}


# create the connection to the database
create_sqlite_con_precompute <- function(
  db_path = "notas-pau.db",
  flags = RSQLite::SQLITE_RO,
  pragmas = c(
    journal_mode = "WAL",
    busy_timeout = 5000,
    synchronous = "NORMAL",
    cache_size = 10000
  )
) {
  con <- DBI::dbConnect(
    drv = RSQLite::SQLite(),
    dbname = db_path,
    flags = flags
  )

  for (i in seq_along(pragmas)) {
    key <- names(pragmas)[i]
    val <- pragmas[[i]]
    stmt <- sprintf(
      "PRAGMA %s = %s;",
      key,
      if (is.character(val)) val else as.character(val)
    )
    try(DBI::dbExecute(con, stmt), silent = TRUE)
  }

  con
}
