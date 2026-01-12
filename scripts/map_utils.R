# ============================================================
# Map utilities for HLD Life Expectancy Visualizations
# Provides ISO3 country codes for Plotly choropleth maps
# ============================================================

library(tidyverse)
library(rnaturalearth)
library(countrycode)

# ---------------------------
# Preload world geographic data
# ---------------------------
world_sf_cached <- rnaturalearth::ne_countries(scale = "medium", returnclass = "sf") %>%
  filter(continent != "Antarctica") %>%
  mutate(iso_a3 = as.character(iso_a3))

# Create a simplified admin map for fallback matching
world_admin_map_cached <- world_sf_cached %>%
  st_drop_geometry() %>%
  mutate(
    admin_up      = ifelse(!is.na(admin), toupper(str_trim(admin)), NA_character_),
    name_up       = ifelse(!is.na(name), toupper(str_trim(name)), NA_character_),
    name_long_up  = ifelse(!is.na(name_long), toupper(str_trim(name_long)), NA_character_),
    iso_a3_world  = toupper(as.character(iso_a3))
  ) %>%
  select(admin_up, name_up, name_long_up, iso_a3_world) %>%
  distinct()

# Manual mapping for tricky cases
manual_map_country <- c(
  "FRANCE" = "FRA",
  "KOSOVO" = "XKX",
  "INDIAN OCEAN TERRITORIES" = "IOT",
  "BRITISH INDIAN OCEAN TERRITORY" = "IOT",
  "ASHMORE AND CARTIER ISLANDS" = "AUS",
  "SIACHEN GLACIER" = "IND"
)

# ---------------------------
# Function: Map country names to ISO3 codes
# ---------------------------
map_countries_to_iso3 <- function(country_vec) {
  ct_trim <- toupper(str_trim(as.character(country_vec)))
  iso <- rep(NA_character_, length(ct_trim))
  
  # Detect ISO3-like strings
  is_iso_like <- str_detect(ct_trim, "^[A-Z]{3}$")
  if (any(is_iso_like)) iso[is_iso_like] <- toupper(countrycode(ct_trim[is_iso_like], origin = "iso3c", destination = "iso3c", warn = FALSE))
  
  # Attempt country name mapping
  missing_idx <- which(is.na(iso))
  if (length(missing_idx) > 0) {
    iso[missing_idx] <- toupper(countrycode(ct_trim[missing_idx], origin = "country.name", destination = "iso3c", warn = FALSE))
  }
  
  # Fallback: match against admin map
  for (col in c("admin_up", "name_up", "name_long_up")) {
    need_idx <- which(is.na(iso))
    if (length(need_idx) == 0) break
    tmp <- tibble(Country_trim = ct_trim[need_idx]) %>%
      left_join(world_admin_map_cached, by = c("Country_trim" = col)) %>%
      pull(iso_a3_world)
    iso[need_idx] <- toupper(as.character(tmp))
  }
  
  # Fallback: manual map
  need_idx <- which(is.na(iso))
  if (length(need_idx) > 0) {
    for (i in need_idx) {
      if (!is.null(manual_map_country[[ct_trim[i]]])) iso[i] <- manual_map_country[[ct_trim[i]]]
    }
  }
  
  iso <- ifelse(is.na(iso), NA_character_, toupper(str_trim(as.character(iso))))
  return(iso)
}
