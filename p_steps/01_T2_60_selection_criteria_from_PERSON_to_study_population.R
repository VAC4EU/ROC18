##%######################################################%##
#                                                          #
####         CREATE GENERAL EXCLUSION CRITERIA          ####
#                                                          #
##%######################################################%##


print('CREATE EXCLUSION CRITERIA FOR STUDY POPULATION')

load(paste0(dirtemp, "D3_PERSONS.RData"))

### Create the criteria based on D3_PERSONS. They are the same for adults and children populations.
# Remove persons with sex or birth day missing (recoded to year 9999)
D3_sel_cri <- D3_PERSONS[, sex_or_birth_date_is_not_defined := fifelse(
  is.na(sex_at_instance_creation) | sex_at_instance_creation %in% c("U", "undetermined", "unknown") |
    year(birth_date) == 9999, 1, 0)]

# Remove persons with  partial date of death
D3_sel_cri[, partial_date_of_death := fifelse(!is.na(death_date) & year(death_date) == 9999, 1, 0)]

# Remove persons with absurd date of birth
D3_sel_cri[, birth_date_absurd := fifelse(year(birth_date) < 1900 | birth_date > instance_creation, 1, 0)]

# Clean dataset
D3_sel_cri <- D3_sel_cri[, .(person_id, sex_or_birth_date_is_not_defined, partial_date_of_death, birth_date_absurd)]

for (subpop in subpopulations_non_empty){
  print(subpop)
  
  ### Create the criteria based on D3_clean_spells. The following criteria are the same for adults and children populations.
  # Import D3_clean_spells
  load(paste0(dirtemp,"D3_clean_spells.RData"))
  if (this_datasource_has_subpopulations == T){
    D3_clean_spells <- D3_clean_spells[[subpop]]
  }
  D3_clean_spells <- D3_clean_spells[, .(person_id, entry_spell_category, exit_spell_category, starts_at_birth,
                                         starts_after_ending, no_overlap_study_period,
                                         less_than_365_days_and_not_starts_at_birth,
                                         is_the_study_spell)]
  
  # Creation of no_spells criteria
  D3_sel_cri <- D3_sel_cri[, no_spells := fifelse(person_id %in% unlist(unique(D3_clean_spells[, .(person_id)])), 0, 1)]
  
  # Creation of all_spells_start_after_ending criteria
  D3_clean_spells[, tot_spell_num := .N, by = person_id]
  D3_clean_spells[, tot_starts_after_ending := sum(starts_after_ending), by = person_id]
  D3_clean_spells[, all_spells_start_after_ending := fifelse(tot_starts_after_ending == tot_spell_num, 1, 0)]
  D3_clean_spells[, removed_row := starts_after_ending]
  D3_clean_spells[, c("starts_after_ending", "tot_starts_after_ending", "tot_spell_num") := NULL]
  
  # Creation of no_spell_overlapping_the_study_period criteria
  D3_clean_spells[removed_row == 0, tot_spell_num := .N, by = person_id]
  D3_clean_spells[removed_row == 0, tot_no_overlap_study_period := sum(no_overlap_study_period), by = person_id]
  D3_clean_spells[removed_row == 0, no_spell_overlapping_the_study_period := fifelse(
    tot_no_overlap_study_period == tot_spell_num, 1, 0)]
  D3_clean_spells[removed_row == 0, removed_row := rowSums(.SD), .SDcols = c("removed_row", "no_overlap_study_period")]
  D3_clean_spells[, c("no_overlap_study_period", "tot_no_overlap_study_period", "tot_spell_num") := NULL]
  
  # Creation of no_spell_longer_than_365_days. Keep other spells even if they are less than 365 days long
  D3_clean_spells[removed_row == 0, tot_spell_num := .N, by = person_id]
  D3_clean_spells[removed_row == 0, tot_365_days := sum(less_than_365_days_and_not_starts_at_birth), by = person_id]
  D3_clean_spells[removed_row == 0, no_spell_longer_than_365_days := fifelse(tot_365_days == tot_spell_num, 1, 0)]
  D3_clean_spells[removed_row == 0, removed_row := rowSums(.SD),
                  .SDcols = c("removed_row", "less_than_365_days_and_not_starts_at_birth")]
  D3_clean_spells[, c("less_than_365_days_and_not_starts_at_birth", "tot_365_days", "tot_spell_num", "removed_row") := NULL]
  
  # Keep only study spells chosen in 01_T2_50_clean_spells
  study_spells <- D3_clean_spells[is_the_study_spell == 1, ][, .(person_id, entry_spell_category, exit_spell_category,
                                                                 starts_at_birth)]
  
  # Keep only one row for each spell which syntethize the previously defined exclusion criteria
  D3_clean_spells <- unique(D3_clean_spells[, c("entry_spell_category", "exit_spell_category",
                                                "is_the_study_spell", "starts_at_birth") := NULL])
  for (i in names(D3_clean_spells)) D3_clean_spells[is.na(get(i)), (i) := 0]
  D3_clean_spells <- D3_clean_spells[, lapply(.SD, max), by = person_id]
  
  # Add spells exclusion criteria to the one for person. Keep only persons which have a spell
  D3_sel_cri_spells <- merge(D3_sel_cri, D3_clean_spells, all.x = T, by = "person_id")
  
  ### Add spells informations
  setorder(study_spells, person_id)
  
  study_spells <- unique(study_spells)
  
  D3_sel_cri_spells <- merge(D3_sel_cri_spells, study_spells, all.x = T, by = "person_id")
  D3_sel_cri_spells[, spell_start_date := pmax(entry_spell_category, start_lookback)]
  D3_sel_cri_spells[, study_entry_date := pmax(fifelse(as.logical(starts_at_birth),
                                                                spell_start_date, spell_start_date + 365),
                                                        study_start)]
  D3_sel_cri_spells[, study_exit_date := pmin(exit_spell_category, study_end)]
  D3_sel_cri_spells[, c("entry_spell_category", "exit_spell_category", "starts_at_birth") := NULL]
  D3_sel_cri_spells <- unique(D3_sel_cri_spells)
  
  # Saving exclusion criteria for populations
  nameoutput1 <- paste0("D3_selection_criteria_from_PERSONS_to_study_population", suffix[[subpop]])
  assign(nameoutput1, D3_sel_cri_spells)
  save(nameoutput1, file = paste0(dirtemp, nameoutput1, ".RData"), list = nameoutput1)
}




