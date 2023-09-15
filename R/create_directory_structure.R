#' Handle Naming Conventions
#'
#' @param name String. Original folder name.
#' @param case String. One of c("asis", "sentence", "lower", "upper", "title", "snake").
#' @param word_separator String.
#' @param replacement_list Character vector, named.
#' @return String. Modified folder name.
handle_naming_conventions <- function(name = "Journal manuscripts",
                                      case="asis",
                                      word_separator = NULL,
                                      replacement_list = NULL) {


  # Apply case transformations
  name <-
  switch(case,
         "asis" = name,
         "sentence" = stringi::stri_trans_totitle(name),
         "lower" = stringi::stri_trans_tolower(name),
         "upper" = stringi::stri_trans_toupper(name),
         "title" = stringi::stri_trans_totitle(name),
         "snake" =
           stringi::stri_replace_all_fixed(stringi::stri_trans_totitle(name),
                                           pattern = " ", replacement = "")
         )

  # Replace spaces. CONSIDER CHANGING " " TO EVERYTHING NON-ALPHANUMERIC?
  if(rlang::is_string(word_separator)) {
    name <- stringi::stri_replace_all_fixed(name, pattern = "[[:space:]]+", replacement = word_separator)
  }
  for(i in seq_along(replacement_list)) {
    name <- stringi::stri_replace_all_fixed(name, pattern = paste0("{{", names(replacement_list)[i], "}}"),
                                            replacement = unname(replacement_list)[i])
  }

  name
}


#' Handle Maximum Observed Numbering
#'
#' @param parent_path String. The path to the parent directory.
#' @param count_existing_folders Boolean. Whether to count existing folders for numbering.
#' @return String. Appropriate numbering based on the maximum observed value.
handle_max_observed <- function(parent_path = getwd(), count_existing_folders = FALSE) {
  if(count_existing_folders) {
    existing_folders <- list.dirs(parent_path, recursive = FALSE, full.names = FALSE)
    existing_numbers <- stringi::stri_extract_first_regex(existing_folders, "^\\d+")
    existing_numbers <- existing_numbers[!is.na(existing_numbers)]
    max_number <- max(as.integer(existing_numbers), na.rm = TRUE)

    if (is.finite(max_number)) {
      return(as.character(max_number + 1))
    }
  }

  return("1")
}

#' Handle numbering inheritance
#'
#' @param counter digit
#' @param numbering_prefix One of "none", "0", "00", "000", "max_observed"
#' @param parent_path String, path to parent folder
#' @param parent_numbering String
#' @param numbering_parent_child_separator String
#' @param count_existing_folders Boolean
#' @param max_folder_count_digits Integer.
#'
#' @return String
handle_numbering_inheritance <- function(counter = 1,
                                         numbering_prefix = "none",
                                         max_folder_count_digits = 0,
                                         parent_path = "Journal manuscripts",
                                         parent_numbering = NA,
                                         numbering_parent_child_separator = "_",
                                         count_existing_folders = FALSE) {
  # Generate numbering based on prefix
  numbering <- switch(numbering_prefix,
                      "none" = "",
                      "max_local" = sprintf(paste0("%0", max_folder_count_digits, "d"), counter),
                      "max_global" = sprintf(paste0("%0", max_folder_count_digits, "d"), counter)
  )

  # Combine with parent numbering
  if (!is.na(parent_numbering)) {
    stringi::stri_c(parent_numbering, numbering_parent_child_separator, numbering, ignore_null = TRUE)
  } else {
    numbering
  }
}

# Recursive function to find the length of the longest list in a nested list
find_longest_list_length <- function(lst) {
  max_length <- 0

  for (item in lst) {
    if (is.list(item)) {
      # Recursive call if the item is a list
      candidate_length <- find_longest_list_length(item)
    } else {
      # If the item is not a list, consider the length of the parent list
      candidate_length <- length(lst)
    }

    # Update max_length if a longer list is found
    if (candidate_length > max_length) {
      max_length <- candidate_length
    }
  }

  max_length
}


#' Create a Pre-defined Directory Hierarchy on Disk
#'
#' @inheritParams initialize_saros_project
#' @return NULL
#'
#' @export
#' @examples
#' create_directory_structure()
create_directory_structure <- function(
    path = getwd(),
    structure_path = system.file("templates", "_structure_en.yaml", package = "saros.structure"),
    numbering_prefix = c("none", "max_local", "max_global"),
    numbering_inheritance = TRUE,
    word_separator = NULL,
    numbering_parent_child_separator = word_separator,
    numbering_name_separator = " ",
    case = c("asis", "sentence", "title", "lower", "upper", "snake"),
    replacement_list = c(project_initials = "SSN"),
    create = FALSE,
    count_existing_folders = FALSE
) {

  if(!file.exists(structure_path)) cli::cli_abort(message = c(x="{.arg structure_path} not found: {.file {structure_path}}"))
  numbering_prefix <- rlang::arg_match(numbering_prefix)
  case <- rlang::arg_match(case)
  # Read the YAML file to get the folder structure
  folder_structure <- yaml::read_yaml(structure_path)


  if(numbering_prefix=="max_global") {
    max_folder_count_digits <- find_longest_list_length(folder_structure)
    max_folder_count_digits <- floor(log10(max_folder_count_digits))+1
  } else {
    max_folder_count_digits <- 0
  }

  counter <- 1
  # Recursive function to traverse and create folders
  create_folders_recursive <- function(folder_list, parent_path, parent_numbering = "") {
    for (name in names(folder_list)) {
      # Apply naming conventions
      modified_name <- handle_naming_conventions(name = name, case = case, word_separator = word_separator,
                                                 replacement_list = replacement_list)

      # Handle numbering inheritance
      if(numbering_prefix=="max_local") {
        max_folder_count_digits <- floor(log10(length(folder_list)))+1
      }
      numbering <- handle_numbering_inheritance(counter = counter,
                                                parent_path = parent_path,
                                                numbering_prefix = numbering_prefix,
                                                max_folder_count_digits = max_folder_count_digits,
                                                parent_numbering = if(numbering_inheritance) parent_numbering else NA,
                                                numbering_parent_child_separator = numbering_parent_child_separator)

      # Full folder name
      full_name <- stringi::stri_c(numbering,
                                   if(numbering != "") numbering_name_separator,
                                   modified_name, ignore_null = TRUE)

      # Full path
      full_path <- file.path(parent_path, full_name)

      # Print or create folder
      if(create) {
        if (!dir.exists(full_path)) {
          dir.create(full_path, recursive = TRUE, showWarnings = FALSE)
        }
      } else {
        cat(full_path, "\n")
      }

      counter <- counter + 1
      # Recursive call for sub-folders
      if(is.list(folder_list[[name]])) {
        create_folders_recursive(folder_list = folder_list[[name]],
                                 parent_path = full_path,
                                 parent_numbering = numbering)
      }

    }
  }

  # Start the folder creation process
  create_folders_recursive(folder_list = folder_structure, parent_path = path)
}



#' Generate YAML File from Directory Structure
#'
#' @param input_path String. The path to the directory whose structure needs to be captured.
#' @param output_yaml_path String. The path where the YAML file will be saved.
#' @param remove_prefix_numbers Boolean. Whether to remove numeric prefixes and any resulting leading non-alphanumeric characters from folder names. Defaults to FALSE.
#' @return NULL
#' @export
#' @examples
#' generate_yaml_from_directory(output_yaml_path = tempfile("_structure_en", fileext=".yaml"))
generate_yaml_from_directory <- function(input_path = getwd(),
                                         output_yaml_path = "_structure_en.yaml",
                                         remove_prefix_numbers = FALSE) {
  # Recursive function to traverse directory and build list
  traverse_directory <- function(dir_path) {
    folders <- list.dirs(dir_path, recursive = FALSE, full.names = FALSE)
    folder_structure <- list()

    for (folder in folders) {
      # Remove numeric prefixes if required
      folder_name <- if (remove_prefix_numbers) {
        cleaned_name <- stringi::stri_replace_first_regex(folder, "^[0-9\\s_-]+", "")
        if (stringi::stri_length(cleaned_name) == 0) {
          folder  # Keep original name if cleaning results in an empty string
        } else {
          cleaned_name
        }
      } else {
        folder
      }

      sub_path <- file.path(dir_path, folder)
      if (file.info(sub_path)$isdir) {
        folder_structure[[folder_name]] <- traverse_directory(sub_path)
      }
    }

    return(folder_structure)
  }

  # Generate the folder structure list
  folder_structure <- traverse_directory(input_path)

  # Write to YAML file
  yaml::write_yaml(folder_structure, output_yaml_path)
}

