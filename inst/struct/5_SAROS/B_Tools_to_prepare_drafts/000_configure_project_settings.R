################################################################################
### Global project settings across all SAROS-based reports and website
### Usually no need to touch the below if folder structure follows standard.
### Not to be run by itself. Will be run when running configure_report_settings.R
### NB: Possibly convert this into an easier-to-read _vars.yaml?
################################################################################

project_long <- "Spørringer til Skole-Norge"
project_short <- "Spørringene"

################################################################################
########## VARIABLE (COLUMN) NAMES USED ACROSS ALL REPORTS #####################
################################################################################

vars <- list() ### Initialize variable list here.
# Some variables may be constant across report cycles, then can be listed below.
# They will be merged with any  variables in a specific configure_report_settings.R
vars$predictor_binary <- c()
vars$predictor_ordinal <- c()
vars$predictor_nominal <- c()
vars$predictor_interval <- c()
# if the outcome variables below are empty, will assume all non-predictor variables as outcome variables.
vars$outcome_binary <- c()
vars$outcome_ordinal <- c()
vars$outcome_nominal <- c()
vars$outcome_integer <- c()


################################################################################
####################### Paths to folders and files #############################
################################################################################
paths <- list()

paths$dir_qmd_to_be_checked <- here::here("qmd_to_be_checked")

paths$dir_qmd_checked <- here::here("qmd_checked")
paths$dir_qmd_checked_main <- here::here(paths$dir_qmd_checked, "main")

paths$dir_data <- here::here("data")
paths$dir_pdf_all <- here::here(paths$dir_data, "pdf")
paths$dir_structure_all <- here::here(paths$dir_data, "kapitteloversikt")
paths$dir_questionnaire_all <- here::here(paths$dir_data, "spørreskjema")
paths$dir_surveydata_all <- here::here(paths$dir_data, "surveydata")
paths$dir_samplingframe_all <- here::here(paths$dir_data, "utvalg")
paths$dir_population_all <- here::here(paths$dir_data, "populasjon")

#### DO NOT CHANGE PATHS BELOW ####

paths$dir_images <- here::here("images")
paths$file_css <- here::here("_css/styles.scss")
paths$dir_site <- here::here("_site")
paths$saros_core <- here::here(Sys.getenv("USERPROFILE"), "NIFU", "Metode - General", "SAROS")
paths$renv_cache <- here::here(paths$saros_core, "renv_cache")
paths$dir_map <- here::here(paths$saros_core, "shared_data", "kart")
paths$dir_templates <- here::here(paths$saros_core, "shared_data", "maler")
template_report <- 
  here::here(paths$dir_templates, "Rapport_norsk_2020c.docx")
template_workpaper <- 
  here::here(paths$dir_templates, "Arbeidsnotat_norsk_2020d.docx")
# 
# paths$dir_r_scripts <- "R" 
# paths$dir_r_scripts_generate_report <-
#   paste0(paths$dir_r_scripts, "/generate_report")

################################################################################
################### Colours and fonts from Word templates ######################
################################################################################


colour_palette <- list(
  blue = c("#90D4E0", "#70C7D7", "#50BBCE", "#36AABF", "#2D8E9F", "#24727F", "#1B555F"),
  red = c("#E8B0B7", "#DE919A", "#D5727D", "#C84957", "#BC3848", "#9D2F3C", "#7E2630"),
  mixed = c(red="#C82D49", black="#363636", blue="#2D8E9F", gray="#E7E6E6", beige="#EDE2D2")
)

# officer::read_docx(template_report) %>% officer::styles_info()
word_styles <-
  tibble::tibble(surveyreport_style = 
                   c("heading_1", "heading_2", 
                     "heading_3", "paragraph", "figure", "figure_caption", "table_body", 
                     "table_caption",
                     "pptx_master", "pptx_layout"), 
                 template_style = 
                   c("NIFU_Overskrift 1", "NIFU_Overskrift 2 nummerert", "NIFU_Overskrift 3 nummerert", 
                     "NIFU_Normal første", "NIFU_Figuranker_bred", "NIFU_Figur tittel", 
                     "NIFU_Tabell kropp", "NIFU_Tabell tittel",
                     "NIFU_ppt_NO", "Tittel og innhold"),
                 font_family = 
                   c("Calibri", "Calibri", "Calibri",
                     "Cambria", "Calibri", "Calibri",
                     "Calibri", "Calibri", "Wingdings", "Wingdings"),
                 font_size = c(23.5, 15.5, 13.5, 10.5, 8.5, 10.5, 8.5, 10.5, 7, 7)
  )

setup_figure_specs <- 
  list(
    docx_template = template_report,
    colour_palette = colour_palette$red,
    colour_na = "#E7E6E6",
    chart_formatting = 
      word_styles |>  
      dplyr::filter(surveyreport_style == "figure") |>  
      dplyr::pull(template_style),
    font_family =      
      word_styles |>  
      dplyr::filter(surveyreport_style == "figure") |>  
      dplyr::pull(font_family),
    label_font_size = 9,
    main_font_size = 9,
    showNA = "no", 
    digits = 0,
    percent_sign = FALSE,
    desc = TRUE,
    height_per_col = .3,
    hide_label_if_below = 3,
    percent_sign = FALSE,
    height_fixed = 1)

