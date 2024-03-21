#' Convenience Function to Copy Only the Contents of A Folder to Another Folder
#'
#' @param to,from String, path from where to copy the contents, and where to copy them to.
#' @param overwrite Flag. Defaults to FALSE.
#'
#' @return NULL
#' @export
#'
#' @examples
#' copy_folder_contents_to_dir(from = system.file("help", "figures", package = "dplyr"),
#'                             to = tempdir())
copy_folder_contents_to_dir <-
  function(from,
           to,
           overwrite = FALSE) {

    subfolders <- list.dirs(from, full.names = FALSE, recursive = FALSE)
    lapply(subfolders, function(x) fs::dir_copy(path = fs::path_dir(fs::path(from, x)),
                                                new_path = fs::path(to),
                                                overwrite = overwrite))
    cli::cli_inform("Copied: {subfolders}")
  }
