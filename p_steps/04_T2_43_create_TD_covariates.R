##%######################################################%##
#                                                          #
####  CREATE TIME DEPENDENT DATASETS FOR ALL VARIABLE   ####
#### NEEDED IN COHORT ANALYSIS EXCEPT NUMBER_CONDITIONS ####
#                                                          #
##%######################################################%##


# pick the coresponding conceptset(s), make some cleaning (restriction to study population, restriction to study period, restiction to appopopriate meanings if necessary), make each record last 90 days (medications) or 365 days (diagnosis), merge all the time periods (using CreateSpells), store

# use variable_definition[[element]] to retrieve all the conceptsets asscoiated to one of the elements; see 3_30 for a similar thing
pregnancy_variables <- "PREGNANCY"
for (subpop in subpopulations_non_empty) {
  
  print(subpop)
  
  # Import the study population
  name_D4_study_population <- paste0("D4_study_population", suffix[[subpop]])
  load(paste0(diroutput, name_D4_study_population, ".RData"))
  study_population <- get(name_D4_study_population)[, .(person_id, study_exit_date)]
  rm(list = name_D4_study_population)
  
  TD_variables <- c(COV_variables, DP_variables, pregnancy_variables)
  
  complete_TD <- data.table::rbindlist(lapply(TD_variables, function(x){
    load(paste0(dirTD, "/D3_TD_", x, suffix[[subpop]], ".RData"))
    get(paste0("D3_TD_", x, suffix[[subpop]]))[, variable := x]
  }))
  
  complete_TD <- data.table::dcast(complete_TD, person_id + date ~ variable, value.var = "value_of_variable")
  data.table::setnafill(complete_TD, cols = TD_variables, type = "locf")
  
  data.table::setorder(complete_TD, person_id, date)
  single_day <- days(1)
  complete_TD[, date_end := data.table::shift(date, type = "lead"), by = "person_id"]
  complete_TD[, date_end := date_end - single_day]
  complete_TD <- merge(complete_TD, study_population[, .(person_id, study_exit_date)], all.x = T, by = "person_id")
  complete_TD <- complete_TD[is.na(date_end), date_end := study_exit_date][, study_exit_date := NULL]
  
  setcolorder(complete_TD, c("person_id", "date", "date_end"))
  
  # Export final dataset
  name_export_df <- paste0("D3_TD_covariates_complete", suffix[[subpop]])
  assign(name_export_df, complete_TD)
  save(name_export_df, file = paste0(dirTD, "/", name_export_df, ".RData"), list = name_export_df)
}
