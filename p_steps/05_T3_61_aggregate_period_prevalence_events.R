##%######################################################%##
#                                                          #
####          AGGREGATE DATASETS TO ADD TOTALS          ####
####            FOR SOME STRATA AND CLEANING            ####
#                                                          #
##%######################################################%##

for (subpop in subpopulations_non_empty) {  
  print(subpop)
  
  load(paste0(diroutput, "D4_count_events_period_prevalence", suffix[[subpop]], ".RData"))
  PR_yearly <- get(paste0("D4_count_events_period_prevalence", suffix[[subpop]]))
  rm(list = paste0("D4_count_events_period_prevalence", suffix[[subpop]]))
  
  # Find the columns for counts and PT
  cols_to_sums <- names(PR_yearly)[grepl("^prev_", names(PR_yearly))]
  
  # Sums by sex to get data for both sexes together
  # Sums by Ageband to get data for all ages
  assigned_levels <- vector(mode="list")
  assigned_levels[["Ageband"]] <- c("Ageband")
  assigned_levels[["sex"]] <- c("sex")
  assigned_levels[["timeframe"]] <- c("timeframe")
  
  PR_yearly <- Cube(input = PR_yearly,
                    dimensions = c("Ageband","person_id","timeframe"),
                    levels = assigned_levels, computetotal = c("Ageband", "sex"),
                    measures = cols_to_sums
  )
  
  setnames(PR_yearly, c("Ageband_LabelValue", "sex_LabelValue", "timeframe_LabelValue"),
           c("Ageband", "sex", "timeframe"))
  
  PR_yearly[sex_LevelOrder == 99, sex := "total"]
  PR_yearly[Ageband_LevelOrder == 99, Ageband := "total"]
  PR_yearly[, c("Ageband_LevelOrder", "sex_LevelOrder", "timeframe_LevelOrder") := NULL]
  
  cols_to_change_name <- names(PR_yearly)[grepl("_sum$", names(PR_yearly))]
  setnames(PR_yearly, cols_to_change_name, gsub("_sum$", "", cols_to_change_name))
  
  cols_to_change_name <- names(PR_yearly)[grepl("^prev_", names(PR_yearly))]
  setnames(PR_yearly, cols_to_change_name, gsub("^prev_", "num_period_", cols_to_change_name))
  
  PR_yearly[, year := as.character(year(as.Date(substr(timeframe, 1, 10))))]
  PR_yearly[, timeframe := NULL]
  
  load(paste0(diroutput, "D4_counts_persontime_yearly_aggregated", suffix[[subpop]], ".RData"))
  PT_monthly <- get(paste0("D4_counts_persontime_yearly_aggregated", suffix[[subpop]]))
  rm(list = paste0("D4_counts_persontime_yearly_aggregated", suffix[[subpop]]))
  
  PR_yearly <- merge(PR_yearly, PT_monthly[, .(sex, Ageband, year, denominator_period = Persontime)],
                     all = T, by = c("sex", "Ageband", "year"))
  
  setcolorder(PR_yearly, c("sex", "Ageband", "year", "denominator_period"))
  
  nameoutput <- paste0("D4_events_period_prevalence_aggregated", suffix[[subpop]])
  assign(nameoutput, PR_yearly)
  save(nameoutput, file = paste0(diroutput, nameoutput, ".RData"), list = nameoutput)
}



