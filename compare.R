# Install gfdata trials branch
remove.packages("gfdata")
remotes::install_github("pbs-assess/gfdata", ref = "trials")

# Get survey sets 
s1 <- gfdata::get_survey_sets("044", ssid = c(39, 40))
s2 <- gfdata::get_survey_sets2("044", ssid = c(39, 40))

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

# Do NAs account for row difference? Nope (yes with shared columns only below)
nrow(s1 |> tidyr::drop_na()) # 1265
nrow(s2 |> tidyr::drop_na()) # 1

# Select shared columns (in order) and usability_code == 1
s1s <- s1 |> dplyr::select(intersect(s1c, s2c))
s2s <- s2 |> 
  dplyr::filter(usability_code == 1) |>
  dplyr::select(intersect(s1c, s2c))

# Do colnames now match?
all.equal(colnames(s1s), colnames(s2s)) # TRUE (good start :P )

# How many rows?
nrow(s1s) # 1266
nrow(s2s) # 1271

# Do attributes match?
attributes(s1s)
attributes(s2s) # Bunch of extras: $out.attrs$dimnames$fishing_event_id

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

# Same column values? Mostly: NAs in s2f$depth_m
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

# Which ones?
which(is.na(s2f$depth_m)) # 521 524 525 527 536

# What are the fishing event ids?
s2f$fishing_event_id[which(is.na(s2f$depth_m))]

# What does s1f have there?
s1f$depth_m[which(is.na(s2f$depth_m))] # 58 83 78 67 61

# Why does s2f have NAs where s1f has positive values?
# TBD

# What extra rows were in s2?
ids <- setdiff(s2s$fishing_event_id, s1s$fishing_event_id)
rows <- which(s2$fishing_event_id %in% ids)
tibble::view(s2[rows,])

# Would dropping NAs have helped? Yes - remaining difference is depth_m
nrow(s1s |> tidyr::drop_na()) # 1265
nrow(s2s |> tidyr::drop_na()) # 1260

# Which values are NA in s1s? (fishing event ids)
setdiff(s1s$fishing_event_id, tidyr::drop_na(s1s)$fishing_event_id)
# 5151636

# Which values are NA in s2s? (fishing event ids)
setdiff(s2s$fishing_event_id, tidyr::drop_na(s2s)$fishing_event_id)
# 1131552 1507010 1507016 1945203 1945230 2845593 
# 2845587 2845602 2845590 2845591 5151636

# Conclusions:
# Looking only at shared columns...
# - s1s and s2s share one row with an NA values: 
# --- fishing event id: 5151636
# - s2s has 5 rows with NA values for depth where s1s has positive depths:
# --- fishing event id: 2845587 2845590 2845591 2845593 2845602
# - s2s has 5 additional rows with NA values and do not appear in s1s:
# --- fishing event id: 1131552 1507010 1507016 1945203 1945230 

# To be continued ;)


# Rough
hist(s1f$depth_m - s2f$depth_m) # Wow! Different!


extra_ids <- c(1131552, 1507010, 1507016, 1945203, 1945230)

extra_rows <- s2s |> dplyr::filter(fishing_event_id %in% extra_ids)

tibble::view(extra_rows)

wrong_rows <- s1s |> dplyr::filter(fishing_event_id %in% extra_ids)

saveRDS(extra_rows, here::here("extra-rows2.rds"))


# Philina scatterplot originals with left_join
s2sub <- select(s2, fishing_event_id, depth_m) |> rename(depth_m2 = depth_m)
test <- left_join(s1, s2sub)
plot(test$depth_m, test$depth_m2)




# Scratch below here


s1f |> dplyr::pull(colnames(s1f)[i])



# Do any rows differ?
d <- s1f |> dplyr::bind_rows(s2f) |> dplyr::distinct()
nrow(d)



# Which rows differ?
d <- s1 |> dplyr::bind_rows(s2) |> dplyr::distinct()
nrow(d) # 2978



all.equal(s1s, s2s)



ll <- gfdata::get_ll_hook_data("044", ssid = c(39, 40))

# How many columns?
ncol(s1) # 29
ncol(s2) # 55
ncol(ll) # 13

# What columns?
s1c <- colnames(s1)
s2c <- colnames(s2)
llc <- colnames(ll)

# What columns in common?
intersect(s1c, s2c) # ...
intersect(s2c, llc) # ...
intersect(llc, s1c) # ...

intersect(s1c, intersect(s2c, llc))

# What columns different?
setdiff(s1c, s2c) # "survey_desc" "hook_count"
setdiff(s2c, s1c) # ...

setdiff(s2c, llc) # ...
setdiff(llc, s2c) # "survey"   "ssid"                 "depth" 
                  # "soaktime" "count_target_species" "count_non_target_species"

setdiff(llc, s1c) # ...
setdiff(s1c, llc) # ...

# How many rows?
nrow(s1) # 1266
nrow(s2) # 1712
nrow(ll) # 1292


