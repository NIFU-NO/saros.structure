#' Initialize Folder Structure
#'
#' Can be used programatically from the console, or simply use the New Project Wizard..
#'
#' @param path String, path to where to create the project files
#' @param structure_path String. Path to the YAML file that defines the folder structure. Defaults to system.file("templates", "_structure_en.yaml").
#' @param numbering_prefix String. One of c("none", "max_local", "max_global").
#' @param numbering_inheritance Flag. Whether to inherit numbering from parent folder.
#' @param word_separator String. Replace separators between words in folder names. Defaults to NULL.
#' @param numbering_parent_child_separator String. Defaults to word_separator.
#' @param case String. One of c("asis", "sentence", "lower", "upper", "title", "snake").
#' @param create Boolean. Defaults to FALSE.
#' @param count_existing_folders Boolean. Defaults to FALSE.
#' @param r_files_source_path String, path to where to find CSV-fiel containing the columns folder_name, folder_scope, file_name, file_scope. If NULL, defaults to system.file("templates", "r_files.csv")).
#' @param r_files_out_path String, path to where to place R placeholder files. If NULL, will not create any.
#' @param r_numbering_inheritance
#' @param r_numbering_parent_child_separator
#' @param r_numbering_name_separator
#' @param r_case
#' @param r_add_folder_scope_as_README
#'
#' @return
#' @export
#'
#' @examples initialize_saros_project(path = getwd())
initialize_saros_project <-
  function(path,
           structure_path = NULL,
           numbering_prefix = c("none", "max_local", "max_global"),
           numbering_inheritance = TRUE,
           word_separator = NULL,
           numbering_parent_child_separator = word_separator,
           case = c("asis", "sentence", "title", "lower", "upper", "snake"),
           count_existing_folders = FALSE,

           r_files_out_path = NULL,
           r_files_source_path = system.file("templates", "r_files.csv", package="saros.structure"),
           r_optionals = TRUE,
           r_add_file_scope = TRUE,
           r_prefix_file_scope = "### ",
           r_add_folder_scope_as_README = FALSE) {

    if(is.null(structure_path)) structure_path <- system.file("templates", "_structure_en.yaml")

    create_directory_structure(path = path,
                               structure_path = structure_path,
                               numbering_prefix = numbering_prefix,
                               numbering_inheritance = numbering_inheritance,
                               word_separator = word_separator,
                               numbering_parent_child_separator = numbering_parent_child_separator,
                               case = case,
                               create = TRUE,
                               count_existing_folders = count_existing_folders)
    if(!is.null(r_files_location)) {
      create_r_files(r_files_out_path = r_files_out_path,
                                                  r_files_source_path = r_files_source_path,
                                                  optionals = optionals,
                                                  add_file_scope = add_file_scope,
                                                  prefix_file_scope = prefix_file_scope,
                                                  add_folder_scope_as_README = add_folder_scope_as_README)
    }
}
