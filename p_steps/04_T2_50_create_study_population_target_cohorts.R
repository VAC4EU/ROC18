
for (subpop in subpopulations_non_empty) {  
  load(paste0(dirtemp, "D3_Total_study_population", suffix[[subpop]], ".RData"))
  study_population <- get(paste0("D3_Total_study_population", suffix[[subpop]]))
  rm(list = paste0("D3_Total_study_population", suffix[[subpop]]))
  
  study_population[, c("date_of_death") := NULL]
  setnames(study_population, c("start_followup_study", "date_of_birth"), c("study_entry_date", "birth_date"))
  
  study_population[, birthyear := year(birth_date)]
  
  all_cohorts <- list()
  
  for (cohort_subtype in list_of_cohorts_for_coverage) {
    
    cohort_pop <- copy(study_population)
    if (cohort_date_entry[[cohort_subtype]] == "birth_date") {
      cohort_pop <- cohort_pop[between(birth_date, study_entry_date, study_exit_date), ]
      cohort_pop[, cohort_entry_date := birth_date]
    } else if (cohort_date_entry[[cohort_subtype]] == "9th birthday") {
      cohort_pop <- cohort_pop[between(birth_date %m+% years(9), study_entry_date, study_exit_date), ]
      cohort_pop[, cohort_entry_date := birth_date  %m+% years(9)]
    } else if (cohort_date_entry[[cohort_subtype]] == "1st december 2020") {
      firstdec2020 <- ymd(20201201)
      cohort_pop <- cohort_pop[between(firstdec2020, study_entry_date, study_exit_date), ]
      cohort_pop[, cohort_entry_date := firstdec2020]
    } else if (cohort_date_entry[[cohort_subtype]] == "1st september") {
      seasonal_year <- as.integer(regmatches(cohort_subtype, regexpr("[0-9]+", cohort_subtype)))
      sep1 <- ymd(paste0(seasonal_year, "0901"))
      april30 <- ymd(paste0(seasonal_year + 1, "0430"))
      cohort_pop <- copy(study_population)[between(sep1, study_entry_date, study_exit_date), ]
      cohort_pop[, cohort_entry_date := sep1]
    } else {
      stop("option not implemented")
    }
    
    cohort_pop[, cohort_name := cohort_subtype]
    
    if (cohort_date_exit[[cohort_subtype]] == "x months old") {
      month_exit <- as.integer(regmatches(cohort_subtype, regexpr("[0-9]+", cohort_subtype)))
      cohort_pop[, cohort_exit_date := pmin(get_date_for_month(birth_date, month_exit) - 1, study_exit_date)]
      cohort_pop[, is_censored_in := fifelse(cohort_exit_date < get_date_for_month(birth_date, month_exit) - 1, 1, 0)]
    } else if (cohort_date_exit[[cohort_subtype]] == "16th birthday") {
      cohort_pop[, cohort_exit_date := pmin(birth_date %m+% years(16) - 1, study_exit_date)]
      cohort_pop[, is_censored_in := fifelse(cohort_exit_date < birth_date %m+% years(16) - 1, 1, 0)]
    } else if (cohort_date_exit[[cohort_subtype]] == "study exit") {
      cohort_pop[, cohort_exit_date := study_exit_date]
      cohort_pop[, is_censored_in := fifelse(cohort_exit_date < study_exit_date, 1, 0)]
    } else if (cohort_date_exit[[cohort_subtype]] == "30 april") {
      cohort_pop[, cohort_exit_date := pmin(study_exit_date, april30)]
      cohort_pop[, is_censored_in := fifelse(cohort_exit_date < april30, 1, 0)]
    } else {
      stop("option not implemented")
    }
    
    all_cohorts <- append(all_cohorts, list(cohort_pop))
  }
  
  cohort_pop <- rbindlist(all_cohorts)
  cohort_pop <- cohort_pop[, .(person_id, sex, spell_start_date, study_entry_date, study_exit_date, birth_date, birthyear,
                               cohort_name, cohort_entry_date, cohort_exit_date, is_censored_in)][, is_in := 1]
  cohort_pop <- dcast(cohort_pop, person_id + sex + spell_start_date + study_entry_date +
                        study_exit_date + birth_date + birthyear ~ cohort_name,
                      value.var = c("is_in", "cohort_entry_date", "cohort_exit_date", "is_censored_in"))
  
  full_column_names <- do.call(paste0, expand.grid(c("is_in_", "cohort_entry_date_", "cohort_exit_date_", "is_censored_in_"),
                                                   list_of_cohorts_for_coverage))
  cols_to_add <- setdiff(full_column_names, colnames(cohort_pop))
  cohort_pop[, (cols_to_add) := NA]
  
  # Save dataset for total study population
  nameobject <- paste0("D3_study_population_target_cohorts", suffix[[subpop]])
  assign(nameobject, cohort_pop)
  save(nameobject, file = paste0(dirtemp, nameobject, ".RData"), list = nameobject)
  rm(list = nameobject)
}