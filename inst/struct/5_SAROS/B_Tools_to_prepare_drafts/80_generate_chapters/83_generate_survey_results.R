

dat_analysis <- arrow::read_json_arrow(file = here::here("../", "data", "dat_analysis.json"))

results_ordinal <-
purrr::map(.x = vars$outcomes_ordinal, 
           .f = function(outcome) {
             
             
             ### UNIVARIATES
             dat_outcome <- 
               dat_analysis |> 
               dplyr::select(tidyselect::matches(outcome, ignore.case = FALSE))
             
             outcome_tbl <-
               crosstable::crosstable(data = dat_outcome, 
                                      cols = tidyselect::everything(),
                                      percent_digits = setup_table_specs$digits,
                                      num_digits = setup_table_specs$digits,
                                      showNA = setup_table_specs$showNA)
             
             dat_outcome_fig <-
               crosstable::crosstable(data = dat_outcome, 
                                      cols = tidyselect::everything(),
                                      percent_digits = setup_figure_specs$digits, # Must leave as setup_figure_specs
                                      num_digits = setup_figure_specs$digits,
                                      showNA = setup_figure_specs$showNA,
                                      percent_pattern = "{n}")
             
             outcome_fig_gg <- # Must convert to stand-alone function
               ggplot2::ggplot(data = dat_outcome_fig, 
                               mapping = ggplot2::aes(x = label, y = value, 
                                                      group = variable, 
                                                      fill = variable, 
                                                      colour = variable)) +
               ggplot2::geom_col(position = ggplot2::position_stack()) + 
               ggplot2::theme_classic() +
               ggplot2::scale_color_manual(aesthetics = )
               
           })