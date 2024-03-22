#' Wrapper to Download and Unzip a Github Repo to A Folder
#'
#' @param github_zip_url URL to zip file, as string.
#' @param zip_path String, where to store zip-file. Defaults to a temporary location.
#' @param out_path String, directory to where to store the unzipped files.
#' @param files Character vector of files in zip-file to include. See `zip::unzip()`.
#' @param overwrite Flag, whether to overwrite files in out_path. Defaults to FALSE.
#' @param prompt Flag, whether to ask user if conflicting files should be overwritten, if any. Defaults to TRUE.
#' @return Character vector of unzipped files.
#' @export
#' @importFrom fs dir_ls
#' @importFrom zip unzip
#' @importFrom utils download.file
#'
#' @examples
#' download_zip_to_folder(
#'    github_zip_url = "https://github.com/NIFU-NO/nifutemplates/archive/refs/heads/main.zip",
#'    out_path = tempdir(), overwrite=TRUE)
download_zip_to_folder <-
  function(github_zip_url = "https://github.com/NIFU-NO/nifutemplates/archive/refs/heads/main.zip",
           zip_path = tempfile(fileext = ".zip"),
           files = NULL,
           out_path = getwd(),
           prompt = TRUE,
           overwrite = FALSE) {

    tmpfolder <- file.path(tempdir(), paste0(sample(letters, size = 5, replace = TRUE), collapse=""))
    utils::download.file(url = github_zip_url, destfile = zip_path, method = "auto", cacheOK = TRUE)
    zip_temp_path <- zip::unzip(zipfile = zip_path, files = files, exdir = tmpfolder, junkpaths = FALSE, overwrite = TRUE)
    folder_in_temp_path <- fs::dir_ls(path = tmpfolder, recurse = FALSE, type = "directory")
    new_files <- fs::dir_ls(folder_in_temp_path, recurse = TRUE, type = "file", all = TRUE)
    new_files <- gsub(x = new_files, pattern = folder_in_temp_path, replacement = "")
    new_files <- gsub(x = new_files, pattern = "^/", replacement = "")
    old_files <- fs::dir_ls(out_path, recurse = TRUE, type = "file", all = TRUE)
    old_files <- gsub(x = old_files, pattern = out_path, replacement = "")
    old_files <- gsub(x = old_files, pattern = "^/", replacement = "")
    intersects <- new_files[new_files %in% old_files]
    if(isTRUE(prompt) && length(intersects) > 0 && isTRUE(overwrite)) {
      cat(intersects, sep = "\n")
      choice <-
      utils::menu(title = "These files will be overwritten. Are you sure?",
                  choices = c("Yes, overwrite all.", "No, abort!"))
      if(choice == 2) return()
    }
    copy_folder_contents_to_dir(from = folder_in_temp_path, to = out_path, overwrite = overwrite)
    out_path
  }
