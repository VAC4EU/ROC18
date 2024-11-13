##%######################################################%##
#                                                          #
####   COUNT PERSON-TIME AT RISK AND NUMBER OF EVENTS   ####
####    FOR OUTCOMES/NCOS FOR UNVACCINATED BY MONTH     ####
#                                                          #
##%######################################################%##

# Copy of step 05_30 irrespective by dose and monthly

print("COUNT PERSON TIME for background")

for (subpop in subpopulations_non_empty) {  
  print(subpop)
  
  load(paste0(dirTD, "D3_TD_events_complete", suffix[[subpop]], ".RData"))
  load(paste0(dirtemp, "D3_Total_study_population", suffix[[subpop]], ".RData"))
  
  TD_events <- get(paste0("D3_TD_events_complete", suffix[[subpop]]))
  study_population <- get(paste0("D3_Total_study_population", suffix[[subpop]]))
  
  rm(list = paste0("D3_TD_events_complete", suffix[[subpop]]))
  rm(list = paste0("D3_Total_study_population", suffix[[subpop]]))
  
  setnames(study_population, c("start_followup_study", "study_exit_date", "date_of_birth"),
           c("start_date_of_period", "end_date_of_period", "birth_date"))
  study_population <- study_population[, .(person_id, start_date_of_period, end_date_of_period, sex, birth_date)]
  
  TD_events[, lagged_end := shift(date_end), by = c("person_id", "variable")]
  TD_events[!is.na(lagged_end) & interval(lagged_end, date) %/% years(1) == 0, date := ceiling_date(date)]
  TD_events[, lagged_end := NULL]
  
  max_exit <- study_population[, ceiling_date(max(end_date_of_period), 'year') %m-% days(1)]
  
  n_batches <- ceiling(nrow(study_population) / batch_size_countprevalence)
  study_population[, pop_batch := rep_len(1:n_batches, nrow(study_population))]
  
  study_population <- split(study_population, by = "pop_batch")
  
  for (pop_batch_df in study_population) {
    vars_to_add <- data.table(person_id = pop_batch_df[start_date_of_period == pop_batch_df[, min(start_date_of_period)]][1, person_id],
                              date = ymd(99991231), date_end = ymd(99991231),
                              variable = c(OUTCOME_variables, recurrent_OUTCOME_variables, "DEATH"))
    TD_events <- rbind(TD_events, vars_to_add)
  }
  
  rep_td_events <- if (thisdatasource %in% c("BIFAP", "CPRD")) 2 else 1
  
  test <- TD_events[, .(variable = unique(variable), pop_batch = rep_len(1:rep_td_events, length(unique(variable))))]
  TD_events <- TD_events[test, on = "variable"]
  
  TD_events <- split(TD_events, by = "pop_batch")
  
  not_recurrent_OUTCOME_variables <- setdiff(c(OUTCOME_variables, "DEATH"), recurrent_OUTCOME_variables)
  
  print("not recurrent")
  
  persontime_monthly_not_recurrent <- lapply(study_population, function(x) {
    
    for (i in 1:length(TD_events)) {
      single_prev <- CountPrevalence(
        Dataset_events = TD_events[[i]],
        Dataset_cohort = x,
        UoO_id = "person_id",
        Start_study_time = gsub('-', '', as.character(study_start)),
        End_study_time = gsub('-', '', as.character(max_exit)),
        Type_prevalence = "period",
        Start_date = "start_date_of_period",
        End_date = "end_date_of_period",
        Birth_date = "birth_date",
        Strata = c("sex"),
        Name_condition = "variable",
        Date_condition = "date",
        Date_end_condition = "date_end",
        Age_bands = Agebands_countpersontime,
        Increment_period = "year",
        Conditions = intersect(not_recurrent_OUTCOME_variables, test[pop_batch == i, variable]),
        Unit_of_age = "year",
        include_remaning_ages = T,
        Aggregate = T,
        drop_not_in_population = T
      )
      
      if (i == 1) {
        mult_prev <- single_prev
      } else {
        mult_prev <- single_prev[mult_prev, on = c("timeframe", "sex", "Ageband", "in_population")]
      }
    }
    
    return(mult_prev)
    
  })
  
  persontime_monthly_not_recurrent <- rbindlist(persontime_monthly_not_recurrent, fill = T)
  
  setnafill(persontime_monthly_not_recurrent, fill = 0,
            cols = intersect(paste0("prev_", c(OUTCOME_variables, recurrent_OUTCOME_variables, "DEATH")),
                             colnames(persontime_monthly_not_recurrent)))
  
  persontime_monthly_not_recurrent <- persontime_monthly_not_recurrent[, lapply(.SD, sum, na.rm=TRUE),
                                                                       by = c("timeframe", "Ageband", "sex")]
  
  cols_to_add <- setdiff(paste0("prev_", c(OUTCOME_variables, recurrent_OUTCOME_variables, "DEATH")),
                         colnames(persontime_monthly_not_recurrent))
  persontime_monthly_not_recurrent[, (cols_to_add) := 0]
  
  persontime_monthly_not_recurrent[, "in_population" := NULL]
  
  # print("recurrent")
  # 
  # persontime_monthly_recurrent <- CountPrevalence(
  #   Dataset_events = TD_events,
  #   Dataset_cohort = study_population,
  #   UoO_id = "person_id",
  #   Start_study_time = gsub('-', '', as.character(study_start)),
  #   End_study_time = gsub('-', '', as.character(max_exit)),
  #   Type_prevalence = "period",
  #   Start_date = "start_date_of_period",
  #   End_date = "end_date_of_period",
  #   Birth_date = "birth_date",
  #   Strata = c("sex"),
  #   Name_condition = "variable",
  #   Date_condition = "date",
  #   Date_end_condition = "date_end",
  #   Age_bands = Agebands_countpersontime,
  #   Increment_period = "month",
  #   Conditions = recurrent_OUTCOME_variables,
  #   Unit_of_age = "year",
  #   include_remaning_ages = T,
  #   Aggregate = T
  # )
  # 
  # persontime_monthly_recurrent[, c("start_date_of_period", "end_date_of_period", "in_population") := NULL]
  # 
  # persontime_monthly_not_recurrent <- persontime_monthly_not_recurrent[, .SD,
  #                                                                      .SDcols = unique(names(
  #                                                                        persontime_monthly_not_recurrent))]
  # 
  # persontime_monthly_recurrent <- persontime_monthly_recurrent[, .SD,
  #                                                              .SDcols = unique(names(persontime_monthly_recurrent))]
  # 
  # print("Merging")
  # 
  # persontime_monthly <- merge(persontime_monthly_not_recurrent, persontime_monthly_recurrent,
  #                             by = c("person_id", "sex", "timeframe", "Ageband"))

  print("Saving")

  nameoutput <- paste0("D4_count_events_period_prevalence", suffix[[subpop]])
  assign(nameoutput, persontime_monthly_not_recurrent)
  save(nameoutput, file = paste0(diroutput, nameoutput, ".RData"), list = nameoutput)
}
