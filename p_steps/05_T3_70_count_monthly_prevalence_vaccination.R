##%######################################################%##
#                                                          #
#### COUNT VACCINATION PREVALENCE  ####
#                                                          #
##%######################################################%##

if (TEST == "Y"){
  subpopulations_non_empty <- "HOSP"
  subpop <- 'HOSP'
  # suffix[[subpop]] <- ""
  # dirtemp <- paste0(thisdir,"/i_input_synthetic/test_D4_monthly_prevalence_vaccination/")
  # diroutput <- dirtemp
  list_of_cohorts_for_coverage <- "adolescence"
  cohortname <- list_of_cohorts_for_coverage[1]
}

#############
# define auxiliary function that will be used in the step to aggregate individual prevalence for a list of indicators in a cohort

aggregate_prevalent_individual <- function(Dataset = NULL, Cohort, Indicators_cohort){ 
  key_variables <- c("person_id", "timeframe")
  setorderv(Dataset, c(key_variables))
  Dataset <- Dataset[, month_fup := seq_along(.I), by = "person_id" ]
  setnames(Dataset, "in_population", "NFUP_month")    
  listvar = "NFUP_month"
  for (ind in Indicators_cohort){
    setnames(Dataset, paste0("prev_", ind), "current")    
    Dataset[, lag := shift(current, type = "lag", fill = 0), by = person_id]
    Dataset[, past := ifelse(lag == 1 | cumsum(lag) > 0, 1, 0), by = person_id]
    Dataset[, lag := NULL]
    Vacc_observed_month = paste0("Vacc_observed_month", ind)
    Vacc_observed_before_month = paste0("Vacc_observed_before_month", ind)
    setnames(Dataset, "current",(Vacc_observed_month))    
    setnames(Dataset, "past",(Vacc_observed_before_month))
    listvar = c(listvar,Vacc_observed_month, Vacc_observed_before_month)
  }
  # aggregate
  Dataset <- Dataset[, paste0("sum_",listvar) := lapply(.SD, sum), by = .(month_fup, cohort_label), .SDcols = listvar]
  # rm(prevalent)
  tokeep <- c("month_fup","cohort_label",paste0("sum_",listvar))
  Dataset <- unique(Dataset[,..tokeep])
  #clean
  setorderv(Dataset, c("cohort_label","month_fup"))
  Dataset <- Dataset[, NFUP := sum_NFUP_month[1], by = "cohort_label"]
  return(Dataset)
}

print("COUNT vaccination prevalence")

for (subpop in subpopulations_non_empty) {  
  print(subpop)
  
  #########################################
  # load data
  
  load(paste0(dirtemp, "D3_all_vaccines_curated.RData"))
  load(paste0(dirtemp, "D3_study_population_target_cohorts", suffix[[subpop]], ".RData"))
  
  vaccines_labelled <- get("D3_all_vaccines_curated")
  study_population <- get(paste0("D3_study_population_target_cohorts", suffix[[subpop]]))
  
  rm(list = "D3_all_vaccines_curated")
  rm(list = paste0("D3_study_population_target_cohorts", suffix[[subpop]]))

  #########################################
  # associate indicators to vaccines and doses; indicator_list and the other parameters are assigned in 06_variable_list
  
   vaccines_labelled <- vaccines_labelled[, indicator := root_indicator]
  
  for (ind in root_indicator_list){ 
    if (all(!is.na(root_indicator_dose[[ind]]) )){
      vaccines_labelled <- vaccines_labelled[root_indicator == ind, indicator := paste0(root_indicator,as.character(dose_curated))]
    }
  }
  for (ind in indicator_list){ 
    vaccines_labelled <- vaccines_labelled[ indicator == ind, tokeep := 1]
  }
  vaccines_labelled <- vaccines_labelled[ tokeep == 1, ]
  # add artificial events for those indicators that are not in the actual data, for them to appear in the final dataset
  missing_indicators <- setdiff(indicator_list, vaccines_labelled[, unique(indicator)])
  if (length(missing_indicators) > 0) {
  vars_to_add <- data.table(person_id = study_population[1, person_id], date_curated = ymd(99991231),indicator = missing_indicators)
  vaccines_labelled <- rbind(vaccines_labelled, vars_to_add, fill = TRUE)
  }
  #########################################
  # compute prevalence in each cohort
  
  for (cohortname in list_of_cohorts_for_coverage){
    print("")
    print("*********************************************************")
    print(paste0("Calculating D4_monthly_prevalence_vaccination_",cohortname, suffix[[subpop]]))
    
    # list of indicators to be computed in this cohort
    indicators_cohort <- vector(mode = "character", length = 0)
    for (ind in indicator_list){
      if (type_of_cohort[[cohortname]] %in% indicator_types_of_cohort[[ind]][[1]]){
        indicators_cohort <- c(indicators_cohort, ind)
      }
    }
    
    # restrict the study population to the cohort
    is_in_cohort <- paste0("is_in_",cohortname)
    cohort_entry_date_cohort <- paste0("cohort_entry_date_",cohortname)
    cohort_exit_date_cohort <- paste0("cohort_exit_date_",cohortname)
    is_censored_in_cohort <- paste0("is_censored_in_",cohortname)
    listvartokeep <- c("person_id","birth_date","birthyear",is_in_cohort,cohort_entry_date_cohort,cohort_exit_date_cohort,is_censored_in_cohort)
    if (cohortname == "adolescence"){
      listvartokeep <- c(listvartokeep,"sex")
      }
    cohort <- study_population[get(is_in_cohort) == 1,..listvartokeep]
    if (nrow(cohort) > 0){
      
      # Define new names for the cohort variables
      new_names <- setNames(
        c(
          "cohort_entry_date",
          "cohort_exit_date",
          "is_in",
          "is_censored"
        ),
        c(
          paste0("cohort_entry_date_", cohortname),
          paste0("cohort_exit_date_", cohortname),
          paste0("is_in_", cohortname),
          paste0("is_censored_in_", cohortname)
        )
      )
      # Rename the variables 
      setnames(cohort, old = names(new_names), new = new_names)
     
      ######################################
      # case of cohorts that start at birth
      # for cohorts that start at birth or on a birthday, months in the cohort are months from birth/birthday. we need to define the variables storing start and end of each monthly period, and store the periods in a format accepted by CountPrevalence
      if (month_increment[[cohortname]] == "from birthday or birthdate"){
        setnames(cohort, old = "birthyear", new = "cohort_label")
        if (cohortname == "adolescence"){
          cohort <- cohort[,cohort_label := paste(cohort_label,sex) ]
          cohort <- cohort[,sex := NULL ]
        }
        periods_of_time_prev <- list() 
        first_element_next_pair <- "cohort_entry_date"
        for (i in month_fup_cohort[[cohortname]]) {
          end_month_var <- paste0("end_month", i)
          cohort[, (end_month_var) := pmin(get_date_for_month(birth_date, i) - 1,cohort_exit_date)]
          month_var <- paste0("start_month", i + 1)
          periods_of_time_prev <- c(periods_of_time_prev, list(list(first_element_next_pair, end_month_var)))
          
          cohort[, (month_var) := fifelse(get(first_element_next_pair) < get(end_month_var),
                                          pmin(get_date_for_month(birth_date, i),cohort_exit_date), NA_Date_)]
          first_element_next_pair <- month_var
        }
        
        periods_of_time_prev <- c(periods_of_time_prev, list(list(first_element_next_pair, "cohort_exit_date")))
        
        # run CountPrevalence 
        prevalent_individual = CountPrevalence(Dataset_cohort = cohort,
                                               Dataset_events = vaccines_labelled,
                                               UoO_id = c("person_id"),
                                               key = c("person_id"),
                                               Type_prevalence = "of use",
                                               Periods_of_time = periods_of_time_prev,
                                               Start_date = "cohort_entry_date",
                                               End_date = "cohort_exit_date",
                                               Start_study_time = "20180101",
                                               End_study_time = "20231231",
                                               Name_condition = "indicator",
                                               Date_condition = "date_curated",
                                               Conditions = indicators_cohort,
                                               Strata = c("cohort_label"),
                                               Aggregate = FALSE
        )
        
        cols_to_change <- intersect(indicators_cohort, colnames(prevalent_individual))
        if (length(cols_to_change) > 0) {
          setnames(prevalent_individual, cols_to_change, paste0("prev_", cols_to_change))
        }
        prevalent <- aggregate_prevalent_individual(
          Dataset = prevalent_individual,
          Cohort = cohortname,
          Indicators_cohort = indicators_cohort
        )
        rm(prevalent_individual)
      }
  
      ######################################
      # case of seasonal cohorts
      if (month_increment[[cohortname]] == "calendar month" & type_of_cohort[[cohortname]] == "seasonal"){
        cohort <- cohort[,cohort_label := substr(cohortname, nchar(cohortname) - 3, nchar(cohortname))]
        # run CountPrevalence 
        prevalent_individual = CountPrevalence(Dataset_cohort = cohort,
                                               Dataset_events = vaccines_labelled,
                                               UoO_id = c("person_id"),
                                               key = c("person_id"),
                                               Type_prevalence = "of use",
                                               Increment_period = "month",
                                               Start_date = "cohort_entry_date",
                                               End_date = "cohort_exit_date",
                                               Start_study_time = "20180101",
                                               End_study_time = "20231231",
                                               Name_condition = "indicator",
                                               Date_condition = "date_curated",
                                               Conditions = indicators_cohort,
                                               Strata = c("cohort_label"),
                                               Aggregate = FALSE,
                                               drop_not_in_population = TRUE
        )
        
        cols_to_change <- intersect(indicators_cohort, colnames(prevalent_individual))
        if (length(cols_to_change) > 0) {
          setnames(prevalent_individual, cols_to_change, paste0("prev_", cols_to_change))
        }
        prevalent <- aggregate_prevalent_individual(
          Dataset = prevalent_individual,
          Cohort = cohortname,
          Indicators_cohort = indicators_cohort
        )
        rm(prevalent_individual)
      }
      
      ######################################
      # case of covid
      if (month_increment[[cohortname]] == "calendar month" & type_of_cohort[[cohortname]] == "covid_vacc"){ 
        setnames(cohort, old = "birthyear", new = "cohort_label")
        batch_size_covid_vacc <- 1000000
        
        #the computation for covid is split into batches
        n_batches <- ceiling(nrow(cohort) / batch_size_covid_vacc)
        cohort[, pop_batch := rep_len(1:n_batches, nrow(cohort))]
        
        cohort <- split(cohort, by = "pop_batch")
        prevalent <- data.table()
        
        for (pop_batch in cohort) {
          # run CountPrevalence 
          prevalent_individual = CountPrevalence(Dataset_cohort = pop_batch,
                                                 Dataset_events = vaccines_labelled,
                                                 UoO_id = c("person_id"),
                                                 key = c("person_id"),
                                                 Type_prevalence = "of use",
                                                 Increment_period = "month",
                                                 Start_date = "cohort_entry_date",
                                                 End_date = "cohort_exit_date",
                                                 Start_study_time = "20180101",
                                                 End_study_time = "20231231",
                                                 Name_condition = "indicator",
                                                 Date_condition = "date_curated",
                                                 Conditions = indicators_cohort,
                                                 Strata = c("cohort_label"),
                                                 Aggregate = FALSE,
                                                 drop_not_in_population = TRUE
          )
          
          cols_to_change <- intersect(indicators_cohort, colnames(prevalent_individual))
          if (length(cols_to_change) > 0) {
            setnames(prevalent_individual, cols_to_change, paste0("prev_", cols_to_change))
          }
          prevalent_batch <- aggregate_prevalent_individual(
            Dataset = prevalent_individual,
            Cohort = cohortname,
            Indicators_cohort = indicators_cohort
          )
          rm(prevalent_individual)
          prevalent <- rbind(prevalent,prevalent_batch, fill = TRUE)
          rm(prevalent_batch)
        }
      listvar <- c()
      for (ind in indicators_cohort){
          Vacc_observed_month = paste0("sum_","Vacc_observed_month", ind)
          Vacc_observed_before_month = paste0("sum_","Vacc_observed_before_month", ind)
          listvar = c(listvar,Vacc_observed_month, Vacc_observed_before_month)
      }
      listvar <- c(listvar,"sum_NFUP_month")
      prevalent <- prevalent[, (listvar) := lapply(.SD, sum), by = .(month_fup, cohort_label), .SDcols = listvar]
      tokeep <- c("month_fup","cohort_label",listvar)
      prevalent <- unique(prevalent[,..tokeep])
      #clean
      setorderv(prevalent, c("cohort_label","month_fup"))
      prevalent <- prevalent[, NFUP := sum_NFUP_month[1], by = "cohort_label"]
      }
      
      # indicator	type_of_cohort	cohort_label	month	ageband	NFUP	NFUP_month	FU_proportion_month	Vacc_observed_before_month	Vacc_observed_month	Vacc_IPW_month	IPW_month	PP_month
      
      prevalent <- prevalent[, type_of_cohort := type_of_cohort[[cohortname]]]
      print(paste0("Saving D4_monthly_prevalence_vaccination_",cohortname, suffix[[subpop]]))
  
      nameoutput<-paste0("D4_monthly_prevalence_vaccination_",cohortname, suffix[[subpop]])
      assign(nameoutput, prevalent)
      save(nameoutput, file = paste0(dirtemp, nameoutput, ".RData"), list = nameoutput)
      # temporary for test release
      
      # fwrite(get(nameoutput), file = paste0(dirD4D5subpop[[subpop]], nameoutput, ".csv"))
    }
  }

}
