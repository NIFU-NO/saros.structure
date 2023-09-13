################################################################################
############ Describe the dataset in general terms (no specific      ###########
############ univariate descriptives of the outcome variables yet.   ###########
############ Just check that things are read and prepared correctly. ###########
################################################################################

#### By part of the country and ownership, provide summary stats.
dat_sporringene %>%
  group_by(landsdel, orgform) %>%
  summarize(antall_skoler = n(),
            snitt_arsverk = mean(arsverk, na.rm=TRUE),
            sd_arsverk = sd(arsverk, na.rm=TRUE))

################################################################################
### Report sample size, response rates, etc of your original (unfiltered) dataset.
################################################################################
dat_survey_raw %>% # Total
  tabyl(resp_status) %>%
  adorn_totals() %>%
  adorn_pct_formatting()

dat_survey_raw %>% # Per språk
  tabyl(resp_status, lang) %>%
  adorn_totals(where = c("row", "col")) %>%
  adorn_percentages(denominator = "all") %>%
  adorn_pct_formatting() %>%
  adorn_title(placement = "top",
              row_name = "Response status",
              col_name = "Language")

dat_survey_raw %>% # I snitt per skole
  mutate(resp_status_simple = 1*resp_status %in% c("4-Completed", "3-Partial response")) %>%
  tabyl(resp_status_simple, skole) %>%
  adorn_percentages(denominator = "col") %>%
  rowwise(resp_status_simple) %>%                              # When taking means, sd, etc below, we want to do this within each row, hence rowwise(), otherwise it will use all the data in the columns
  summarize(Mean = mean(c_across(everything()), na.rm = TRUE),
            SD = sd(c_across(everything()), na.rm = TRUE),
            Min = min(c_across(everything()), na.rm = TRUE),
            Max = max(c_across(everything()), na.rm = TRUE),
            Median = median(c_across(everything()), na.rm = TRUE))

################################################################################
######## Create (partially anonymous) geographical map of schools ##############
################################################################################
# https://kartkatalog.geonorge.no/?type=dataset&type=series&type=service&organization=Kartverket&dataaccess=Det%20er%20ingen%20begrensninger%20p%C3%A5%20tilgang%20til%20datasett%20og%20tjenester&theme=Eiendom


ggplot() +
  geom_polygon(
    data =
      norway_nuts3_map_b2020_split_dt %>%
      as_tibble() %>%
      mutate(fylke = case_when(location_code == "county54" ~ "Troms & Finnmark",
                               location_code == "county50" ~ "Trøndelag",
                               location_code == "county46" ~ "Vestland",
                               location_code == "county42" ~ "Agder",
                               location_code == "county38" ~ "Vestfold & Telemark",
                               location_code == "county34" ~ "Innlandet",
                               location_code == "county30" ~ "Viken",
                               location_code == "county18" ~ "Nordland",
                               location_code == "county15" ~ "Møre & Romsdal",
                               location_code == "county11" ~ "Rogaland",
                               location_code == "county03" ~ "Oslo",
                               TRUE ~ location_code)),
               mapping = aes( x = long, y = lat,
                              group = group,
                              # fill = fylke
                              ), size=0.1, color="black", fill="white",
               ) +
  geom_label_repel(
    data =
      dat_survey %>%
      distinct(skole, municipality, fylke, .keep_all = TRUE) %>%
      mutate(long = ifelse(fylke %in% c("Nordland", "Troms og Finnmark"),
                           long-16.71756, long),
             lat = ifelse(fylke %in% c("Nordland", "Troms og Finnmark"),
                          lat-5.48839, lat)),
    mapping = aes(x = long, y = lat, label = " "), fill="red", label.r = .4) +
  theme_void() +
  coord_quickmap() +
  labs(title = "Skoler i utvalget", fill="Fylke")
ggsave(filename = "school_map.png", path = paths$analysis_figures, width = 20, height = 20, units = "cm")


################################################################################
### Explore & report missingness using naniar package (unfinished template) ####
################################################################################





