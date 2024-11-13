##%######################################################%##
#                                                          #
####       CREATE BASIC DATASETS FOR FUTURE STEPS       ####
####         STARTING FROM THE STUDY POPULATION         ####
#                                                          #
##%######################################################%##

for (subpop in subpopulations_non_empty) {
  print(subpop)
  
  # Load study population, vaccines and covariates
  load(paste0(diroutput,"D4_study_population", suffix[[subpop]],".RData"))
  study_population <- get(paste0("D4_study_population", suffix[[subpop]]))
  rm(list = paste0("D4_study_population", suffix[[subpop]]))
  
  setnames(study_population, "study_entry_date", "start_followup_study")
  
  # Merge study_population with D3_persons to get sex, date of birth and date
  load(paste0(dirtemp, "D3_PERSONS.RData"))
  D3_PERSONS <- D3_PERSONS[, .(person_id, sex_at_instance_creation, birth_date, death_date)]
  setnames(D3_PERSONS, c("sex_at_instance_creation", "birth_date", "death_date"),
           c("sex", "date_of_birth", "date_of_death"))
  
  study_population_persons <- merge(study_population, D3_PERSONS, all.x = T, by = "person_id")

  # Save dataset for total study population
  nameobject <- paste0("D3_Total_study_population", suffix[[subpop]])
  assign(nameobject, study_population_persons)
  save(nameobject, file = paste0(dirtemp, nameobject, ".RData"), list = nameobject)
  rm(list = nameobject)
  
  # 
  # ### Calculation of df for monthly countpersontime (row by dose)
  # # Rename the dataset
  # pop_monthly <- pop_vaccines_persons
  # 
  # # Calculate exit of followup of each vaccination
  # study_exit_name <- paste0("study_exit_date_vax_", seq_len(max_number_doses - 1))
  # date_vax_name <- paste0("date_vax_", seq_len(max_number_doses - 1) + 1)
  # 
  # pop_monthly[, study_exit_date_vax_0 := fifelse(is.na(date_vax_1), study_exit_date, date_vax_1 - 1)]
  # 
  # for (i in seq_len(max_number_doses - 1)) {
  #   study_exit_name <- paste0("study_exit_date_vax_", i)
  #   date_vax_current_name <- paste0("date_vax_", i)
  #   date_vax_future_name <- paste0("date_vax_", i + 1)
  #   pop_monthly[!is.na(get(date_vax_current_name)),
  #              (study_exit_name) := fifelse(is.na(get(date_vax_future_name)),
  #                                           study_exit_date, get(date_vax_future_name) - 1)]
  # }
  # 
  # study_exit_name <- paste0("study_exit_date_vax_", max_number_doses)
  # date_vax_name <- paste0("date_vax_", max_number_doses)
  # pop_monthly[!is.na(get(date_vax_name)), (study_exit_name) := study_exit_date]
  # 
  # # The entry of followup for each vaccination is the date of vaccination so let's just change names
  # setnames(pop_monthly, paste0("date_vax_", seq_len(max_number_doses)),
  #          paste0("study_entry_date_vax_", seq_len(max_number_doses)))
  # setnames(pop_monthly, "start_followup_study", "study_entry_date_vax_0")
  # 
  # # Remove the study exit date, spell start date and date of death
  # pop_monthly[, c("spell_start_date", "study_exit_date", "date_of_death") := NULL]
  # 
  # # Add type_vax for unvaccinated as a placeholder
  # pop_monthly[, type_vax_0 := "Omae Wa Mou Shindeiru"]
  # 
  # # From wide to long. One row for each vaccination
  # colA = paste("study_entry_date_vax", 0:max_number_doses, sep = "_")
  # colB = paste("study_exit_date_vax", 0:max_number_doses, sep = "_")
  # colC = paste("type_vax", 0:max_number_doses, sep = "_")
  # 
  # pop_monthly <- data.table::melt(pop_monthly, measure = list(colA, colB, colC),
  #                                 variable.name = "dose", variable.factor = F,
  #                                 value.name = c("start_date_of_period", "end_date_of_period", "type_vax"),
  #                                 na.rm = T)
  # 
  # # Dose needs to be rescaled by 1
  # pop_monthly[, dose := as.character(as.integer(dose) - 1)]
  # 
  # # Transform the placeholder for unvaccinated time to missing
  # pop_monthly[dose == "0", type_vax := NA_character_]
  # 
  # # Load the covid episodes
  # load(paste0(dirtemp, "D3_covid_episodes", suffix[[subpop]], ".RData"))
  # covid_episodes <- get(paste0("D3_covid_episodes", suffix[[subpop]]))
  # rm(list = paste0("D3_covid_episodes", suffix[[subpop]]))
  # 
  # covid_episodes <- covid_episodes[date >= start_COVID_diagnosis_date, ]
  # 
  # # Select only the first diagnosis for each person
  # covid_episodes <- covid_episodes[covid_episodes[,.I[which.min(date)], by = c("person_id")]$V1]
  # 
  # # Merge population and covid episodes
  # pop_monthly_covid <- merge(pop_monthly, covid_episodes, all.x = T, by = "person_id")
  # 
  # # Create COVID19 variable and split periods with the covid diagnosis
  # # pop_monthly_covid <- divide_period_per_event(pop_monthly_covid, "date", "start_date_of_period", "end_date_of_period")
  # 
  # # Save dataset for monthly countpersontime
  # nameobject <- paste0("D3_study_population_by_dose", suffix[[subpop]])
  # assign(nameobject, pop_monthly)
  # save(nameobject, file = paste0(dirtemp, nameobject, ".RData"), list = nameobject)
  # rm(list = nameobject)
  # 
  # ### Calculation of df for weekly countpersontime (row by dose/week)
  # # Rename the dataset remove unvaccinated
  # pop_weekly <- pop_monthly[dose != "0", ]
  # 
  # # Creation of the four weeks study_entry and study_exit for each row
  # vector_periods <- c(7, 14, 21, 28)
  # effective_starts <- c(0, head(vector_periods, -1))
  # 
  # start_date_of_period_names <- paste0("start_date_of_period_", effective_starts)
  # end_date_of_period_names <- paste0("end_date_of_period_", vector_periods)
  # pop_weekly <- pop_weekly[, (start_date_of_period_names) := lapply(effective_starts, `+`, start_date_of_period)]
  # pop_weekly <- pop_weekly[, (end_date_of_period_names) := lapply(vector_periods - 1, `+`, start_date_of_period)]
  # setnames(pop_weekly, c("start_date_of_period", "end_date_of_period"),
  #          c("orig_start_date_of_period", "orig_end_date_of_period"))
  # 
  # # From wide to long. One row for each week of a single vaccination
  # pop_weekly <- data.table::melt(pop_weekly, measure = list(start_date_of_period_names, end_date_of_period_names),
  #                                variable.name = "period", variable.factor = F,
  #                                value.name = c("start_date_of_period", "end_date_of_period"))
  # 
  # # Rename periods to characters (0-6, 7-13, ...)
  # pop_weekly[.(period = as.character(seq_along(vector_periods)),
  #              to = paste(effective_starts, vector_periods - 1, sep = "-")), on = "period", period := i.to]
  # 
  # # Remove weeks with entry after the exit of the person for that cohort (new vax or exit of study)
  # pop_weekly <- pop_weekly[end_date_of_period <= orig_end_date_of_period, ]
  # 
  # # Censor incomplete weeks
  # pop_weekly <- pop_weekly[end_date_of_period > orig_end_date_of_period, end_date_of_period := orig_end_date_of_period]
  # 
  # # Keep only columns needed for the countpersontime
  # pop_weekly <- pop_weekly[, .(person_id, sex, date_of_birth, dose, type_vax, period,
  #                              start_date_of_period, end_date_of_period)]
  # 
  # # Save dataset for weekly countpersontime
  # nameobject <- paste0("D3_study_population_by_window_and_dose", suffix[[subpop]])
  # assign(nameobject, pop_weekly)
  # save(nameobject, file = paste0(dirtemp, nameobject, ".RData"), list = nameobject)
  # rm(list = nameobject)
}
