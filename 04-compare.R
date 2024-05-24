# Jig Survey (Lingcod)
remove.packages("gfdata")
remotes::install_github("pbs-assess/gfdata", ref = "trials")

# Get survey ssids
ssids <- gfdata::get_ssids() |>
  dplyr::rename_with(tolower)

# What colnames?
colnames(ssids)

# What rows?
jrows <- ssids |> 
  dplyr::filter(stringr::str_detect(survey_series_desc, "jig|Jig"))
jrows
# # A tibble: 6 × 3
# survey_series_id survey_series_desc           survey_abbrev
# <dbl>            <chr>                        <chr>        
# 82               Jig Survey - 4B Stat Area 12 OTHER        
# 83               Jig Survey - 4B Stat Area 13 OTHER        
# 84               Jig Survey - 4B Stat Area 15 OTHER        
# 85               Jig Survey - 4B Stat Area 16 OTHER        
# 86               Jig Survey - 4B Stat Area 18 OTHER        
# 87               Jig Survey - 4B Stat Area 19 OTHER

# What ssids?
jids <- jrows |> dplyr::pull(survey_series_id)
jids
# 82 83 84 85 86 87

# Point 0: Why do several jig survey fishing events appear doubled?
# - Suspect some fishing events appear in two different survey_series_id
# - Suspect date conflict for some fishing events

# Get data
h1 <- gfdata::get_ll_hook_data(species = "467", ssid = jids)
s1 <- gfdata::get_survey_sets(species = "467", ssid = jids)
# Error in gfdata::get_survey_sets(species = "467", ssid = jids) : 
#   No survey set data for selected species.
s2 <- gfdata::get_survey_sets2(species = "467", ssid = jids)
sa <- gfdata::get_survey_samples(species = "467", ssid = jids)

# How many rows?
nrow(h1) # 0
nrow(s2) # 2989
nrow(sa) # 750

# How many unique fishing event ids?
length(unique(s2$fishing_event_id)) # 1572

# Look at fishing event id: 271731 (chosen because caught 6 fish)
tibble::view(s2[which(s2$fishing_event_id == 271731),])

# What releavant fields?
s2 |>
  dplyr::select(
    fishing_event_id,
    species_code,
    survey_series_id,
    time_deployed,
    catch_count,
    survey_series_desc
  ) |>
  dplyr::filter(fishing_event_id == 271731)

# # A tibble: 2 × 6
# fishing_event_id species_code survey_series_id time_deployed       catch_count survey_series_desc          
# <dbl>            <chr>        <dbl>            <dttm>              <dbl>       <chr>                       
# 271731           467          82               1987-07-22 12:55:00 6 Jig       Survey - 4B Stat Area 12
# 271731           467          83               1987-07-22 12:55:00 6 Jig       Survey - 4B Stat Area 13

# Point 1: fishing event id 271731 appeared in two different ssids and statistical areas (12 & 13)
# - Other rows also appear doubled (2989 rows but only 1572 unique fishing event ids)

# Can we find some of the 6 fish among the samples?
tibble::view(sa[which(sa$fishing_event_id == 271731),])

# What releavant fields?
sa |>
  dplyr::select(
    fishing_event_id,
    species_code,
    survey_series_id,
    trip_start_date,
    survey_series_desc
  ) |>
  dplyr::filter(fishing_event_id == 271731)

# # A tibble: 5 × 5
# fishing_event_id species_code survey_series_id trip_start_date     survey_series_desc          
# <dbl>            <chr>        <dbl>            <dttm>              <chr>                       
# 271731           467          83               1987-06-02 00:00:00 Jig Survey - 4B Stat Area 13
# 271731           467          83               1987-06-02 00:00:00 Jig Survey - 4B Stat Area 13
# 271731           467          83               1987-06-02 00:00:00 Jig Survey - 4B Stat Area 13
# 271731           467          83               1987-06-02 00:00:00 Jig Survey - 4B Stat Area 13
# 271731           467          83               1987-06-02 00:00:00 Jig Survey - 4B Stat Area 13

# Point 2: specimens correspond to one of the ssid/area combinations but at a different date

