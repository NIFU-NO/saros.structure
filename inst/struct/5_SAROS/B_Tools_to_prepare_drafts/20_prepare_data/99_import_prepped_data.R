

dat <- 
  stringr::str_c(paths$file_analysisdata_cur, collapse="/") |> 
  haven::read_dta() |> 
  labelled::set_variable_labels(.strict = FALSE, 
                      .labels =   
                        stringr::str_c(paths$file_data_labels_cur, collapse="/") |> 
                        readxl::read_excel() |> 
                        dplyr::select(name, vallab_full)  |> 
                        dplyr::mutate(vallab_full = stringr::str_squish(vallab_full)) |> 
                        tibble::deframe() |> 
                        as.list()) |> 
  dplyr::mutate(across(everything(), ~labelled::to_factor(.x)))
labelled::lookfor(dat, details = T) |>  View()
rio::export(dat, here::here(stringr::str_c(paths$file_data_final_cur, collapse="/")))

parquet <-
  here::here(stringr::str_c(paths$file_analysisdata_cur, collapse="/")) |>
  rio::import(setclass = "tbl")
labelled::lookfor(dat, "s_601", details = T)
dplyr::count(dat, s_601)
# geo <-
#   here(paths$dir_base, "kartfiler", "gs.dta") |> 
#   import(file = ., setclass = "tbl")
# geo %>% filter(organisasj ==975290190)

library(sf)
library(ggplot2)

gml_gs <-
  here::here(paths$dir_map, "Befolkning_0000_Norge_25833_Grunnskoler_GML.gml") |> 
  sf::read_sf(stringsAsFactors = TRUE, as_tibble = TRUE) |> 
  dplyr::mutate(orgno = as.character(organisasjonsnummer)) |> 
  dplyr::slice_sample(n = 150)

json_kom <-
    here::here(paths$dir_map, "kommuner2021.json") |> #sf::st_layers()
    sf::read_sf(stringsAsFactors = TRUE, as_tibble = TRUE, layer="Kommuner2021")

json_fyl <-
  here::here(paths$dir_map, "fylker2021.json") |> #sf::st_layers()
  sf::read_sf(stringsAsFactors = TRUE, as_tibble = TRUE, layer="Fylker2021") |> 
  dplyr::mutate(d=Fylkesnavn %in% c("Agder", "Viken"))


ggplot2::ggplot() +
  ggplot2::theme_void() +
  ggplot2::geom_sf(data = json_fyl,
                   mapping = ggplot2::aes(fill=d)) +
  ggplot2::geom_sf(data = gml_gs)

dplyr::anti_join(dat, gml, by="orgno") |> 
  dplyr::filter(resp==1) |>  
  tibble::view()
