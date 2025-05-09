##%######################################################%##
#                                                          #
####          APPLY GENERAL EXCLUSION CRITERIA          ####
####             TO CREATE STUDY POPULATION             ####
#                                                          #
##%######################################################%##

print('FLOWCHART')

# USE THE FUNCTION CREATEFLOWCHART TO SELECT THE SUBJECTS IN POPULATION

for (subpop in subpopulations_non_empty){
  print(subpop)
  
  # Create flowchart for adults and save D4_study_population
  load(paste0(dirtemp,"D3_selection_criteria_from_PERSONS_to_study_population", suffix[[subpop]], ".RData"))
  selection_criteria <- get(paste0("D3_selection_criteria_from_PERSONS_to_study_population", suffix[[subpop]]))
  
  selected_population <- CreateFlowChart(
    dataset = selection_criteria,
    listcriteria = c("sex_or_birth_date_is_not_defined", "birth_date_absurd", "partial_date_of_death", "no_spells",
                     "all_spells_start_after_ending", "no_spell_overlapping_the_study_period",
                     "no_spell_longer_than_365_days"),
    flowchartname = paste0("Flowchart_exclusion_criteria", suffix[[subpop]]))
  
  fwrite(get(paste0("Flowchart_exclusion_criteria", suffix[[subpop]])),
         paste0(direxpsubpop[[subpop]], "Flowchart_exclusion_criteria.csv"))
  
  selected_population <- selected_population[, .(person_id, spell_start_date, study_entry_date, study_exit_date)]
  
  nameoutput <- paste0("D4_study_population", suffix[[subpop]])
  assign(nameoutput, selected_population)
  save(nameoutput, file = paste0(diroutput, nameoutput, ".RData"), list = nameoutput)
  rm(list = nameoutput)
}
