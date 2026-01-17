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

  #on.exit(DBI::dbDisconnect(con), add = TRUE)
}


# region data
create_region_data <- function(con) {
  # Query regional-level education data by joining high schools, municipalities, and regions, and retrieving aggregated academic performance metrics.
  df <- DBI::dbGetQuery(
    con,
    "SELECT
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
    standard_dev_pau ,
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

  # summarise fore each data
  summarise_pau_metrics <- function(data) {
    data |>
      dplyr::summarise(
        enrolled_total_sum = sum(enrolled_total, na.rm = TRUE), # total students enrolled
        candidates_total_sum = sum(candidates, na.rm = TRUE), # total PAU candidates
        pass_total = sum(pass, na.rm = TRUE), # total students who passed
        pass_percentatge = pass_total / candidates_total_sum, # overall pass rate (weighted)

        average_bach = sum(average_bach * candidates, na.rm = TRUE) /
          candidates_total_sum, # weighted mean of bach grades
        average_compulsory_pau = sum(
          average_compulsory_pau * candidates,
          na.rm = TRUE
        ) /
          candidates_total_sum,

        .groups = "drop"
      )
  }

  # data per name-regioncode -type_idecenter-year-call-variable-value
  region_data <- dplyr::bind_rows(
    # separte for eacht type_id
    df |>
      dplyr::group_by(name, region_code, type_id, year, call) |>
      summarise_pau_metrics(),

    #without separate for each type_id under type_id = 4
    df |>
      dplyr::group_by(name, region_code, year, call) |>
      summarise_pau_metrics() |>
      dplyr::mutate(type_id = as.integer(3))
  )

  # stores the data

  saveRDS(region_data, file = "inst/app/data/data_region.rds")

  message("data_region was successfully created.")
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
