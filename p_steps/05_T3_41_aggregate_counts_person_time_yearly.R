##%######################################################%##
#                                                          #
####          AGGREGATE DATASETS TO ADD TOTALS          ####
####            FOR SOME STRATA AND CLEANING            ####
#                                                          #
##%######################################################%##

for (subpop in subpopulations_non_empty) {  
  print(subpop)
  
  load(paste0(diroutput, "D4_counts_persontime_yearly", suffix[[subpop]], ".RData"))
  PT_year <- get(paste0("D4_counts_persontime_yearly", suffix[[subpop]]))
  rm(list = paste0("D4_counts_persontime_yearly", suffix[[subpop]]))
  
  # Find the columns for counts and PT
  cols_to_sums <- names(PT_year)[grepl("^Persontime|_b$", names(PT_year))]
  
  # Sums by sex to get data for both sexes together
  # Sums by Ageband to get data for all ages
  assigned_levels <- vector(mode="list")
  assigned_levels[["Ageband"]] <- c("Ageband")
  assigned_levels[["sex"]] <- c("sex")
  assigned_levels[["year"]] <- c("year")
  
  PT_year <- Cube(input = PT_year,
                  dimensions = c("Ageband","person_id","year"),
                  levels = assigned_levels, computetotal = c("Ageband", "sex"),
                  measures = cols_to_sums
  )
  
  setnames(PT_year, c("Ageband_LabelValue", "sex_LabelValue", "year_LabelValue"),
           c("Ageband", "sex", "year"))
  
  PT_year[sex_LevelOrder == 99, sex := "total"]
  PT_year[Ageband_LevelOrder == 99, Ageband := "total"]
  PT_year[, c("Ageband_LevelOrder", "sex_LevelOrder", "year_LevelOrder") := NULL]
  
  cols_to_change_name <- names(PT_year)[grepl("_sum$", names(PT_year))]
  setnames(PT_year, cols_to_change_name, gsub("_sum$", "", cols_to_change_name))
  
  setcolorder(PT_year, c("sex", "Ageband", "year"))
  
  nameoutput <- paste0("D4_counts_persontime_yearly_aggregated", suffix[[subpop]])
  assign(nameoutput, PT_year)
  save(nameoutput, file = paste0(diroutput, nameoutput, ".RData"), list = nameoutput)
}



