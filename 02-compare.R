# Install gfdata trials branch
remove.packages("gfdata")
remotes::install_github("pbs-assess/gfdata", ref = "trials")

# Get survey sets 
h1 <- gfdata::get_ll_hook_data("044", ssid = c(39, 40))
s2 <- gfdata::get_survey_sets2("044", ssid = c(39, 40))

# How many columns?
ncol(h1) # 13
ncol(s2) # 55

# What columns?
h1c <- colnames(h1)
s2c <- colnames(s2)

# What columns in common?
intersect(h1c, s2c) # ...
# "fishing_event_id"  "year"              "major"             "count_bait_only"  
# "count_empty_hooks" "count_bent_broken" "areagrp" 

# What columns in h1 but not in s2?
h1e <- setdiff(h1c, s2c)
h1e
# "survey"                   "ssid"                     "depth"                   
# "soaktime"                 "count_target_species"     "count_non_target_species"

# Any columns similar with similar names?
# h1:                        s2:                        equal (see below):
# survey                     ...                        ...
# ssid                       survey_series_id           yes
# depth                      depth_m                    yes
# soaktime                   duration_min               yes
# count_target_species       catch_count                similar but outliers
# count_non_target_species   ...                        ...

# How many rows?
nrow(h1) # 1292
nrow(s2) # 1712

# Does usability account for row difference? Nearly: 21 discrepancy to explain
table(s2$usability_code) 
#    0    1 
#  441 1271

# Are fishing event ids unique? Yes
length(unique(h1$fishing_event_id)) # 1292
length(unique(s2$fishing_event_id)) # 1712

# What fishing event ids in common?
fes <- intersect(h1$fishing_event_id, s2$fishing_event_id) |> sort()
length(fes) # 1271

# Which rows of s2 had usability_code 1?
s2u <- s2 |> 
  dplyr::filter(usability_code == 1) |>
  dplyr::arrange(fishing_event_id)

# Are the fishing event ids in common the same ones with usability code 1? Yes
all.equal(fes, s2u$fishing_event_id) # TRUE

# Which rows of h1 have the shared fishing event ids?
h1u <- h1 |> 
  dplyr::filter(fishing_event_id %in% fes) |>
  dplyr::arrange(fishing_event_id)

# Same number of rows now? Yes
nrow(h1u) # 1271
nrow(s2u) # 1271

# Same fishing event ids in same order? Yes
all.equal(h1u$fishing_event_id, s2u$fishing_event_id) # TRUE

# Point 1: h1 had 21 extra rows after s2 was subset for usability_code == 1

# Equal for all shared columns? Yes
for (i in seq_along(intersect(h1c, s2c))) {
  # Print logical
  cat(
    all.equal(
      h1u |> dplyr::pull(intersect(h1c, s2c)[i]),
      s2u |> dplyr::pull(intersect(h1c, s2c)[i])
    )
  )
  # Print colnames 
  cat(
    ": ",
    intersect(h1c, s2c)[i],
    "\n"
  )
}
# TRUE:  fishing_event_id 
# TRUE:  year 
# TRUE:  major 
# TRUE:  count_bait_only 
# TRUE:  count_empty_hooks 
# TRUE:  count_bent_broken 
# TRUE:  areagrp 

# Point 2: h1 and s2 agreed for shared columns and shared fishing event ids

# Equal for similar sounding columns?
all.equal(h1u$ssid, s2u$survey_series_id) # TRUE
all.equal(h1u$depth, s2u$depth_m) # TRUE
all.equal(h1u$soaktime, s2u$duration_min) # TRUE
all.equal(h1u$count_target_species, s2u$catch_count) # FALSE
# Plot
plot(h1u$count_target_species, s2u$catch_count)

# Point 3: catch_count (s2) is similar to count_target_species (h1) but not exact

# What columns should be equal?

# Why did h1 have 21 additional fishing event ids?
fhx <- setdiff(h1$fishing_event_id, fes)
h1x <- h1 |> dplyr::filter(fishing_event_id %in% fhx)
tibble::view(h1x)
# Were the 21 extra rows in s2 but not usable?
nrow(s2 |> dplyr::filter(fishing_event_id %in% fhx)) # 0

# Point 4: the 21 extra rows in h1 did not correspond to unusable rows in s2
