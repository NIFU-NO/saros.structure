################################################################################
############                                                     ###############
############ Prepare raw data (identifiable ID variables).       ###############
############                                                     ###############
################################################################################
# Try to leave it as generic as possible to ease re-usability across projects
# although this is hard. No statistical analyses here!



### Data obtained from Spørringene til Skole-Norge survey
### Internal path to folder with meta-information (questionnaire form,
### sources of instruments, application form for retrieving data, etc.) about the data:
### NA

dat_sporringene <- # To obtain stratification variables, municipality size, etc.
  import(file = paths$dat_sporringer, setclass = "tbl") #%>%
  # select(gsiid, arsverk, sk5d, sk4d, landsdel,        # Which columns to keep
  #        gs3d, målform, orgform, folketall)

## View data, either by clicking the symbol next to the data-set in the
## environment list on the right, or using syntax (not capital V):
view(dat_sporringene)

### Check variable names and labels (latter if applicable)
names(dat_sporringene)
dat_sporringene %>%
  lookfor(details = FALSE) %>%
  view()

### Sort variables (temporarily, unless we assign back to dat_sporringene)
dat_sporringene %>%
  arrange(landsdel, desc(folketall)) %>%
  view()


### Data obtained from (URL): https://gsi.udir.no
### Internal path to folder with meta-information (questionnaire form,
### sources of instruments, application form for retrieving data, etc.) about the data:
### NA

dat_gsi <- # To retrieve street addresses and number of students per school
  import(file = paths$dat_gsi, setclass = "tbl",
             skip = 6,             # Skip first 6 lines (see for yourself in Excel-file). We also ignore the existing column names (line 6)
             col_names = c("school", "year", "gsiid",
                           "visit_address", "postal_address",
                           "postal_number", "postal_place",
                           "postal_number2", "postal_place2",
                           "municipality_number", "municipality",
                           "fylke_number", "fylke",
                           "skole_type", "driftsansvar",
                           "n_trinn5_20_21", "n_trinn6_20_21", "n_trinn7_20_21"),
             trim_ws = TRUE) %>%
  filter(if_any(.cols = matches("n_trinn"), .fns =  ~.x > 0)) %>% # Keep rows if at least some students on grades 5, 6 OR 7.
  mutate(gsiid = as.integer(gsiid))                               # Convert gsiid from character to integer

dat_gsi %>% # Control that there are no/few duplicates
  select(school, municipality) %>%
  filter(duplicated(.))
# This last school we could perhaps fix manually.




### Data obtained from (URL): https://www.survey-xact.no/analysis?analysisid=1787152
### Internal path to folder with meta-information (questionnaire form,
### sources of instruments, application form for retrieving data, etc.) about the data:
### 2_Forberedelser_datainnsamling/04 Spørreundersøkelse/Målgruppe1/1-Hovedgjennomføring #1/
### Survey to teachers in elementary school 2020

dat_survey_raw <-
  read_surveyxact(
    filepath = paths$dat_survey_raw) %>%
  mutate(across(.cols = where(~{is.character(.x) | is.factor(.x)}), .fns = ~trimws(.x))) %>%
  dplyr::filter(!skole %in% c("a", "NTNU")) %>%                                        # Keep only if school is not "a" or "NTNU"
  mutate(skole = case_when(skole == "Hegra skole" ~ "Hegra barneskole",
                           skole == "Utvorda oppvekstsenter" ~ "Utvorda skole",
                           skole == "Rosmælen skole" ~ "Rosmælen skole og barnehage",
                           skole == "Bud barne- og ungdomsskole" ~ "Bud barne- og ungdomsskule",
                           skole == "Skjelstadmark skole" ~ "Skjelstadmark oppvekstsenter skole",
                           TRUE ~ skole),
         resp_status = case_when(statoverall_1==1 ~ "1-Not invited",
                                 statoverall_2==1 ~ "2-Not responded",
                                 statoverall_3==1 ~ "3-Partial response",
                                 statoverall_4==1 ~ "4-Completed",
                                 statoverall_5==1 ~ "5-Excused (unknown reason)",
                                 skole %in% c("a", "NTNU") ~ "9-Not in population"))

val_labels(dat_survey_raw)
# Some labels look weird - because we added page breaks in SurveyXact value labels

val_labels(dat_survey_raw) <-                                                   # Replace existing value labels for all columns
  val_labels(dat_survey_raw) %>%                                                # Take all the value labels for all columns..
  map(.,                                                                        # For each column's value labels
      ~if(length(.x)>0) set_names(.x, gsub("\\r|\\n", " ", names(.x)))) %>%     # If labels exist, replace line shifts/page breaks with space in labels (names(.x)) and return the entire vector.
  map(.,                                                                        # For each column's value labels
      ~if(length(.x)>0) set_names(.x, gsub("[[:space:]]{2,}", " ", names(.x)))) # If labels exist, replace double spaces with single space


#########################################################################################################
#### Join dat_gsi and dat_school_survey to dat_survey_raw, dropping schools not present in the latter. #
#########################################################################################################

## First check how well the datasets match each other. Should only be 4 Swedish schools not matching.
anti_join(x = dat_survey_raw, y = dat_gsi, by=c("skole" = "school")) %>%        # return all rows from dat_survey_raw without a match in dat_gsi.
  distinct(skole) %>%
  summarize(n_distinct(skole, na.rm = T))                                       # All but 4 Swedish schools match


export(x = dat_survey_raw, file = here(paths$dat, "dat_survey_raw.xlsx"))
export(x = dat_survey, file = here(paths$dat, "dat_survey.xlsx"))

