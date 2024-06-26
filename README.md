# gfdata-compare

An RStudio project to compare specific functions on the trials branch.

- In scope: comparisons on trials branch
- In scope: check trials branch for DF survey hook comparison columns
- Out of scope: comparisons between master and trials branches

## Findings

### Inside HBLL - North Pacific Spiny Dogfish

- [x] Compare `get_survey_sets2()` (s2) to `get_survey_sets()` (s1)
  - get_survey_sets2() outputed extra text to console
  - s2 had extra 'attributes' 
  - s2 contained 441 extra rows with usability_code == 0 (by design?)
  - s2 and s1 shared one NA value in time_retrieved
  - s2 contained five extra rows, which have NAs in grouping_code
  - s2 and s1 were otherwise equal in all shared columns
- [X] Compare `get_survey_sets2()` (s2) to `get_ll_hook_data()` (h1)
  - h1 had 21 extra rows after s2 was subset for usability_code == 1
  - h1 and s2 agreed for shared columns and shared fishing event ids
  - catch_count (s2) was similar to count_target_species (h1) but not exact
  - the 21 extra rows in h1 did not correspond to unusable rows in s2

### Dogfish Survey - North Pacific Spiny Dogfish

- [x] Check `get_ll_hook_data()` (h1) for dogfish survey data
- [x] Check `get_survey_sets()` (s1) for dogfish survey data
- [x] Check `get_survey_sets2()` (s2) for dogfish survey data

  - none of the three returned hook comparison column fe_sub_level_id
  
### Jig Survey - Lingcod

- [x] Check whether functions return data
  - `get_ll_hook_data()`: empty tibble 0 rows
  - `get_survey_sets()`: Error: No survey set data for selected species.
  - `get_survey_sets2()`: tibble 2989 rows
  - `get_survery_samples()`: tibble 750 rows
- [x] Check apparent duplication of fishing event ids in `get_survey_sets2()`
  - there were 2989 rows but only 1572 unique fishing event ids
  - one fe id appeared as two ssids in two areas at the same time
  - suspect other fe ids may have been duplicated in similar manner
  - unclear whether duplication occured in database or in `get_survey_sets2()`
- [x] Check `get_survey_samples()` for illumination about duplication
  - specimens from investigated duplicated ssid appeared from one ssid/area
  - trip start date did not concur with set date from `get_survey_sets2()`

## Recommendations

  - Address s1 & s2 differences before merge trials to main
  - Address h1 & s2 differences before use s2 for hooks
  - Develop separate function for DF/HBLL pull including hook comparison
  - Investigate source of lingcod Jig Survey ssid/area duplication
  
