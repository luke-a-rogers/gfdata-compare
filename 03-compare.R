# Install gfdata trials branch
remove.packages("gfdata")
remotes::install_github("pbs-assess/gfdata", ref = "trials")

# Check ssids
ssids <- gfdata::get_ssids() |> dplyr::rename_with(tolower)
tibble::view(ssids)
ssids |> dplyr::filter(survey_series_id %in% c(48, 76, 92, 93))

# survey_series_id survey_series_desc                                    survey_abbrev
# 48               Dogfish Gear/Timing Comparison Surveys                OTHER        
# 76               Strait of Georgia Dogfish Longline                    DOG          
# 92               Strait of Georgia Dogfish Longline (J-hook only)      DOG-J        
# 93               Strait of Georgia Dogfish Longline (Circle hook only) DOG-C 

# Compare to Lindsay notes
# SURVEY_SERIES_ID == 48) # 2004, 2019 survey since it was 2 different sets with different hooks
# SURVEY_SERIES_ID == 76) # 1986 onwards dogfish survey DROP THIS ONE
# SURVEY_SERIES_ID == 92) # 1986, 1989 survey
# SURVEY_SERIES_ID == 93) # 2005 onwards dogfish survey

# note 2004 comparison work had two gear types per set
# note 2019 comparison work dropped separate lines per gear type
# note 2022 comparison work had two gear types per set

# Get data
ids <- c(48, 76, 92, 93)
h1 <- gfdata::get_ll_hook_data("044", ssid = ids)
s1 <- gfdata::get_survey_sets("044",  ssid = ids)
s2 <- gfdata::get_survey_sets2("044", ssid = ids)

# How many rows?
nrow(h1) # 199
nrow(s1) # 96
nrow(s2) # 865

# How many columns?
ncol(h1) # 13
ncol(s1) # 29
ncol(s2) # 55

# What columns in common?
hsc <- intersect(colnames(h1), intersect(colnames(s1), colnames(s2)))
hsc
# "fishing_event_id" "year"

# Were fishing event ids unique?
length(unique(h1$fishing_event_id)) # 160 No
length(unique(s1$fishing_event_id)) #  57 No
length(unique(s2$fishing_event_id)) # 514 No

# What were the colnames?
colnames(h1) # Did not incclude sub level ids
colnames(s1) # Did not incclude sub level ids
colnames(s2) # Did not incclude sub level ids
