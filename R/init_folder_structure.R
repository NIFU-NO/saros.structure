#' Initialize Folder Structure
#'
#' Can be used programatically from the console, or simply use the New Project Wizard..
#'
#' @param path String, path to where to create the project files
#' @param saros_folder Flag, defaults to TRUE. Whether to include the Saros system.
#' @param non_saros_folders Flag, defaults to TRUE. Whether to include all the other folders.
#' @param r_files Flag, defaults to TRUE. Whether to include template R files.
#' @param readme_files Flag, defaults to TRUE. Whether to include assistance files.
#' @param main_folder_numbering Flag, defaults to TRUE. Whether main folders are numbered. Adviced to leave on.
#' @param word_separtor String, defaults to "_". to be inserted between all words to ensure valid path names.
#'
#' @return
#' @export
#'
#' @examples init_folder_structure(path = getwd())
init_folder_structure <- function(path,
                                  saros_folder=TRUE,
                                  non_saros_folders=TRUE,
                                  r_files=TRUE,
                                  readme_files=TRUE,
                                  main_folder_numbering=TRUE,
                                  word_separator = "_") {

  folder <- system.file("struct", package="saros.structure")

  pattern <- c()
  if(isFALSE(saros_folder)) pattern <- c(pattern, "5_SAROS/")
  if(isFALSE(non_saros_folders)) pattern <- c(pattern, "^[12346789]_")
  if(isFALSE(r_files)) pattern <- c(pattern, "\\.[Rr]$")
  if(isFALSE(readme_files)) pattern <- c(pattern, "^[README]")
  pattern <- stringi::stri_c(pattern, collapse="|", ignore_null=TRUE)

  main_folders <-
    dir(path = folder, all.files = TRUE, full.names = FALSE,
        recursive = TRUE, no.. = TRUE)
  # if(isFALSE(saros_folder)) main_folders <- main_folders[main_folders != "5_SAROS"]
  # if(isFALSE(non_saros_folders)) main_folders <- grep(pattern = "^[12346789]_", main_folders, invert = TRUE)

  # lapply(main_folders, function(folder) {
  #
  # })
    main_folders
}
