#'
#' Get URLS for climate directories in PAGASA pubfiles
#' 
#' @param .url URL for PAGASA climate directories. Default is currently
#'   https://pubfiles.pagasa.dost.gov.ph/pagasaweb/files/cad/
#'
#' @returns A character vector of URLs for the various directories for PAGASA
#'   climate data
#'   
#' @examples
#' climate_get_pdf_directory_urls()
#'
#' @export
#'

climate_get_pdf_directory_urls <- function(.url = "https://pubfiles.pagasa.dost.gov.ph/pagasaweb/files/cad/") {
  pagasa_session <- rvest::session(.url)
  
  rvest::html_elements(pagasa_session, css = "pre a") |>
    rvest::html_text() |>
    (\(x) x[stringr::str_detect(string = x, pattern = "\\.\\.\\/|Bulletin", negate = TRUE)])() |>
    (\(x) paste0(.url, x))() |>
    stringr::str_replace_all(pattern = " ", replacement = "%20")
}


#'
#' Get URLs for all PDF files within the PAGASA climate data directories
#' 
#' @param url_dir A URL for a specific PAGASA climate data directory
#' 
#' @returns A character vector of URLs of PDFs from specified PAGASA
#'   climate data directory
#'
#' @examples
#' climate_get_pdf_urls(url_dir = "https://pubfiles.pagasa.dost.gov.ph/pagasaweb/files/cad/CLIMATOLOGICAL%20NORMALS%20(1991-2020)/")
#'
#' @export
#'

climate_get_pdf_urls <- function(url_dir) {
  pagasa_session <- rvest::session(url_dir)
  
  rvest::html_elements(pagasa_session, css = "pre a") |>
    rvest::html_attr(name = "href") |>
    (\(x) x[stringr::str_detect(string = x, pattern = "pdf")])() |>
    (\(x) paste0(url_dir, x))()
}


#'
#' Download climate data PDFs from PAGASA pubfiles URL
#' 
#' @param pdf_url A URL for a specific climate data PDF from PAGASA pubfiles
#' @param directory A character value for name of directory to store downloaded
#'   files to. Default is *"data-raw"*.
#' @param overwrite Should a file with the same name in `directory` be
#'   overwritten? Default to FALSE.
#'   
#' @returns A  file path or a vector of file paths to downloaded climate data 
#'   PDFs
#' 
#' @examples
#' climate_download_pdf()
#'
#' @rdname climate_download
#' @export
#'

climate_download_pdf <- function(pdf_url, 
                                 directory = "data-raw", 
                                 overwrite = FALSE) {
  ## Get year ----
  ref_year <- stringr::str_remove_all(string = pdf_url, pattern = "%20") |>
    stringr::str_extract(pattern = "[0-9]{4}")
  
  download_dir <- file.path(directory, "climate", ref_year)
  
  if (!dir.exists(download_dir)) dir.create(download_dir, recursive = TRUE)
  
  file_name <- basename(pdf_url) |>
    stringr::str_replace_all(pattern = "%20", replacement = "_") |>
    stringr::str_remove_all(pattern = "%28|%29")
  
  if (overwrite | !file_name %in% list.files(download_dir))
    download.file(
      url = pdf_url,
      destfile = file.path(download_dir, file_name)
    )
  
  ## Return file path ----
  file.path(download_dir, file_name)
}


#'
#' @rdname climate_download
#' @export
#'

climate_download_pdfs <- function(pdf_url, 
                                  directory = "data-raw", 
                                  overwrite = FALSE) {
  lapply(
    X = pdf_url,
    FUN = climate_download_pdf,
    directory = directory,
    overwrite = overwrite
  ) |>
    unlist()
}