# Install gfdata trials branch
remove.packages("gfdata")
remotes::install_github("pbs-assess/gfdata", ref = "trials")

# Get survey sets 
s1 <- gfdata::get_survey_sets("044", ssid = c(39, 40))
s2 <- gfdata::get_survey_sets2("044", ssid = c(39, 40))

# Point 0: get_survey_sets2() outputs extra text to console:
# Joining with `by = join_by(skate_id, FE_MAJOR_LEVEL_ID, YEAR, TRIP_ID, SURVEY_ID, SURVEY_SERIES_ID)`
# Joining with `by = join_by(FE_MAJOR_LEVEL_ID, YEAR, TRIP_ID, SURVEY_ID, SURVEY_SERIES_ID)`
# Adding missing grouping variables: `SURVEY_ID`
# Joining with `by = join_by(fishing_event_id, FE_MAJOR_LEVEL_ID, SURVEY_ID, YEAR)`
# Joining with `by = join_by(fishing_event_id, fe_major_level_id, trip_id, survey_id, survey_series_id, trip_year)`
# Joining with `by = join_by(fishing_event_id)`
# Joining with `by = join_by(fishing_event_id, species_code, fe_major_level_id, trip_id, survey_id, survey_series_id)`

# How many columns?
ncol(s1) # 29
ncol(s2) # 55

# What columns?
s1c <- colnames(s1)
s2c <- colnames(s2)

# What columns in common?
intersect(s1c, s2c) # ...

# What columns different?
setdiff(s1c, s2c) # "survey_desc" "hook_count"
setdiff(s2c, s1c) # ...

# How many rows?
nrow(s1) # 1266
nrow(s2) # 1712

# Does usability account for row difference? Nearly: 5 more to explain
table(s2$usability_code) 
#    0    1 
#  441 1271 

# Select shared columns (in order) and usability_code == 1
s1s <- s1 |> dplyr::select(intersect(s1c, s2c))
s2s <- s2 |> 
  dplyr::filter(usability_code == 1) |>
  dplyr::select(intersect(s1c, s2c))

# How many rows?
nrow(s1s) # 1266
nrow(s2s) # 1271

# Do NAs account for row difference? 
nrow(s1s |> tidyr::drop_na()) # 1265
nrow(s2s |> tidyr::drop_na()) # 1265

# Point 1: after filtering for usability, among the shared columns 
# s1 has one NA value while s2 has six.

# Do colnames now match?
all.equal(colnames(s1s), colnames(s2s)) # TRUE (good start :P )

# Do attributes match?
attributes(s1s)
attributes(s2s) 

# Point 2: get_survey_samples2() gives extra attributes 
# $out.attrs$dimnames$fishing_event_id

# Are fishing event ids unique? Yes
length(unique(s1s$fishing_event_id)) # 1266
length(unique(s2s$fishing_event_id)) # 1271

# How many shared fishing event ids?
sfs <- intersect(s1s$fishing_event_id, s2s$fishing_event_id)
length(sfs) # 1266 

# Same data for shared fishing event ids?
s1f <- s1s |> 
  dplyr::filter(fishing_event_id %in% sfs) |>
  dplyr::arrange(fishing_event_id)
s2f <- s2s |> 
  dplyr::filter(fishing_event_id %in% sfs) |>
  dplyr::arrange(fishing_event_id)

# How many rows? Equal now (good)
nrow(s1f) # 1266
nrow(s2f) # 1266

# Same fishing event ids? Yes (good)
all.equal(s1f$fishing_event_id, s2f$fishing_event_id) # TRUE

# Same column values? Yes
for (i in seq_along(colnames(s1f))) {
  # Print logical
  cat(
    all.equal(
      s1f |> dplyr::pull(colnames(s1f)[i]),
      s2f |> dplyr::pull(colnames(s2f)[i])
    )
  )
  # Print colnames 
  cat(
    ": ",
    colnames(s1f)[i],
    " ",
    colnames(s2f)[i],
    "\n"
  )
}

# What additional usable fishing event ids did s2s contain?
sfe <- setdiff(s2s$fishing_event_id, s1s$fishing_event_id)
sfe # 1131552 1507016 1507010 1945203 1945230

# What additional rows did s2s contain?
s2e <- s2s |> 
  dplyr::filter(fishing_event_id %in% sfe)
tibble::view(s2e)

# Anything special about these five? Column grouping_code all NA
s2e$grouping_code

# Are these the only rows with grouping_code NA? Yes
s2s$fishing_event_id[which(is.na(s2s$grouping_code))]
# 1131552 1507016 1507010 1945203 1945230

# Are these the same rows? Yes
all.equal(sfe, s2s$fishing_event_id[which(is.na(s2s$grouping_code))])

# Point 3: s2s contains five extra rows that have grouping_code NA

# One shared NA to account for...
sfna <- setdiff(s1s$fishing_event_id, tidyr::drop_na(s1s)$fishing_event_id)
sfna # 5151636
s1na <- s1s[which(s1s$fishing_event_id == sfna),]
s2na <- s2s[which(s2s$fishing_event_id == sfna),]
tibble::view(s1na)
tibble::view(s2na)

# Point 4: s1s and s2s contain one shared NA in time_retrieved


