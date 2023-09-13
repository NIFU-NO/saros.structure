################################################################################
############ Describe the dataset in general terms (no specific      ###########
############ univariate descriptives of the outcome variables yet.   ###########
############ Just check that things are read and prepared correctly. ###########
################################################################################
library(surveyreport)

# One-way table
crosstable()

# Two-way table, optionally with percentages (by row, total, or all)
dat_survey %>%
  crosstable(epis_01, by=lang) %>%
  as_flextable()

# Multiple one-way tables combined into one (useful for instruments with same response alternatives)
dat_survey %>%
  crosstable(cols = matches("epis_"), percent_pattern = "{p_col}") %>%
  pivot_crosstable()

# For lazy people who want to make multiple one-way tables, for all the instruments (columns sharing same variable label prefix and value labels)
# [function is work in progress]


################################################################################
############ Graphical displays of the above information      ###########
################################################################################
# using the surveyreport-package
devtools::install_github("sda030/surveyreport")
docx_template <-
  system.file("template","NIFUmal_tom.docx", package = "surveyreport", mustWork = TRUE)
colour_palette <-
  readxl::read_excel(system.file("template", "NIFUmal_stiler.xlsx",
                                 package = "surveyreport", mustWork = TRUE),
                     sheet = "NIFUblue") %>%
  dplyr::pull(hex)
chart_format <-
  readxl::read_excel(system.file("template", "NIFUmal_stiler.xlsx",
                                 package = "surveyreport", mustWork = TRUE), sheet = 1) %>%
  dplyr::filter(surveyreport_style == "figure") %>%
  dplyr::pull(template_style)

## Selve innholdet
min_nifu_rapport <-
  dat_survey %>%
  select(matches("epis")) %>%
  surveyreport::report_chart_likert() %>%
  report_chart_likert(cols = b_1:b_3,
                      docx_template = docx_template,
                      colour_palette = colour_palette,
                      chart_formatting = chart_format,
                      height_per_col = .3,
                      height_fixed = 1)
print(min_nifu_rapport, target = "min_nifu_rapport2.docx")

