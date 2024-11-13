##%######################################################%##
#                                                          #
#### COUNT VACCINATION PREVALENCE  ####
#                                                          #
##%######################################################%##

if (TEST == "Y"){
  subpopulations_non_empty <- "HOSP"
  suffix[[subpop]] <- ""
  dirtemp <- paste0(thisdir,"/i_input_synthetic/test_D5_vaccine_coverage_cohorts_Var/")
  diroutput <- dirtemp
  list_of_cohorts_for_coverage <- "birth24"
  subpop <- "HOSP"
  indicator_list <- "Varicella"
  cohortname <- list_of_cohorts_for_coverage[1]
  diroutput <- dirtemp
  dirD4D5subpop[[subpop]] <- dirtemp
}

#############


print("APPLY FORMULAS for vaccination coverage")

for (subpop in subpopulations_non_empty) {  
  print(subpop)
  
  #########################################
  # compute coverage in each cohort
  
  vaccoverage <- data.table()
  for (cohortname in list_of_cohorts_for_coverage){
    if (file.exists(paste0(dirtemp,"D4_monthly_prevalence_vaccination_",cohortname, suffix[[subpop]],".RData"))) { 
      load(paste0(dirtemp,"D4_monthly_prevalence_vaccination_",cohortname, suffix[[subpop]],".RData"))
      vaccoveragecohort <- get(paste0("D4_monthly_prevalence_vaccination_",cohortname, suffix[[subpop]]))
      # set the list of the names of variables
      indicators_cohort <- vector(mode = "character", length = 0)
      for (ind in indicator_list){
        if (type_of_cohort[[cohortname]] %in% indicator_types_of_cohort[[ind]][[1]]){
          indicators_cohort <- c(indicators_cohort, ind)
        }
      }  
      listvar <- c()
      for (ind in indicators_cohort){
        Vacc_observed_month = paste0("sum_","Vacc_observed_month", ind)
        Vacc_observed_before_month = paste0("sum_","Vacc_observed_before_month", ind)
        listvar = c(listvar,Vacc_observed_month, Vacc_observed_before_month)
      }
      setnames(vaccoveragecohort,"NFUP","sum_NFUP")
      listvar <- c(listvar,"sum_NFUP_month","sum_NFUP")
      listcleanvarnames <- gsub("sum_", "", listvar)
      setnames(vaccoveragecohort,listvar,listcleanvarnames)
      
      # covid is a special case: it needs aggregation per agebands first (calculated at two points in time: at entry and at exit from the cohort)
      if (type_of_cohort[[cohortname]] == "covid_vacc"){ 
        # Calculate age and ageband both in 2021 and during the year at end of study
        vaccoveragecohort[cohort_label <= 2021, age2021 := 2021 - cohort_label] 
        yearend <- 2023
        vaccoveragecohort[cohort_label <= yearend, age_at_end_of_study := yearend - cohort_label]
        
        # set the parameters for the Cube function
        list_of_dimensions = c("age","month_fup")
        assigned_levels <- vector(mode="list")
        assigned_levels[["age"]] <- c("ageband","ageband_large")
        assigned_levels[["month_fup"]] <- c("month_fup")
        assigned_rule <- vector(mode="list")
        assigned_rule[["age"]][["ageband"]] <- list("split_in_bands","age",Agebands_cube)
        assigned_rule[["age"]][["ageband_large"]] <- list("split_in_bands","age",Agebands_large)
        rule_from_numeric_to_categorical = assigned_rule
        
        for (typeage in c("2021","_at_end_of_study")){
          temp <- copy(vaccoveragecohort)
          setnames(temp,paste0("age",typeage),"age")
          temp <- temp[!is.na(age),]
          aggregated <- Cube(input = temp,
                             dimensions = list_of_dimensions,
                             levels = assigned_levels,
                             measures = listcleanvarnames,
                             computetotal = c("age"),
                             rule_from_numeric_to_categorical = assigned_rule #,
                             # summary_threshold = 100,
                             # order = assigned_order
          )
          aggregated <- aggregated[,cohort_label := paste0("age",typeage)]
          aggregated <- aggregated[age_LabelValue == "80-Inf", age_LabelValue := "80+"]
          aggregated <- aggregated[age_LabelValue == "60-Inf", age_LabelValue := "60+"]
          aggregated <- aggregated[,month_fup_LevelOrder := NULL]
          setnames(aggregated,"month_fup_LabelValue","month_fup")
          newnames <- gsub("_sum", "", grep("Vacc_observed_month|Vacc_observed_before_month|NFUP", names(aggregated), value = TRUE))
          setnames(aggregated,grep("Vacc_observed_month|Vacc_observed_before_month|NFUP", names(aggregated), value = TRUE),newnames)
          nameoutput <- paste0("age_aggregated_prevalence_age", typeage)
          assign(nameoutput, aggregated)
          }
        vaccoveragecohort <- rbind(age_aggregated_prevalence_age2021,age_aggregated_prevalence_age_at_end_of_study)
        vaccoveragecohort <- vaccoveragecohort[, type_of_cohort := type_of_cohort[[cohortname]]]
      } 
      
      # reshape the dataset so that the indicator name is in row
      idvarscohort = intersect(names(vaccoveragecohort),  c("type_of_cohort", "cohort_label","month_fup", "age_LabelValue", "age_LevelOrder", "NFUP_month", "NFUP"))
      indicators_in_the_data <- gsub("Vacc_observed_month", "", grep("Vacc_observed_month", names(vaccoveragecohort), value = TRUE))
      
      cols_to_convert <- names(vaccoveragecohort)[grepl(c("^Vacc_observed_month|^Vacc_observed_before"),
                                                        names(vaccoveragecohort))]
      vaccoveragecohort <- vaccoveragecohort[, (cols_to_convert) := lapply(.SD, as.integer), .SDcols = cols_to_convert]
      
      vaccoveragecohortmelt <- melt(vaccoveragecohort, 
                                id.vars = idvarscohort,
                                measure.vars = patterns("^Vacc_observed_month", "^Vacc_observed_before"),
                                variable.name = "indicator_num",
                                value.name = c("Vacc_observed_month", "Vacc_observed_before"))
      
      vaccoveragecohortmelt[, indicator := indicators_in_the_data[indicator_num]]
      
      # bind the dataset of this cohort to the datasets of the previous cohorts
      vaccoverage <- rbind(vaccoveragecohortmelt,vaccoverage, fill = T)
      ordervarscohorts <- intersect(c("type_of_cohort", "cohort_label","month_fup", "age_LabelValue", "age_LevelOrder", "NFUP_month", "NFUP", "indicator", "Vacc_observed_month", "Vacc_observed_before"),names(vaccoverage))
      vaccoverage <- vaccoverage[, ..ordervarscohorts]
     # setcolorder(vaccoverage, ordervarscohorts)
    }
  }
  stratum <- intersect(c("type_of_cohort", "cohort_label","indicator","age_LabelValue", "age_LevelOrder"),names(vaccoverage))
  sortvars <- c(stratum,"month_fup")
  setorderv(vaccoverage, c(sortvars))
  vaccoverage <- vaccoverage[,PP_month := (Vacc_observed_before + Vacc_observed_month)/NFUP_month]
  vaccoverage <- vaccoverage[,FU_proportion_month := NFUP_month/NFUP]
  vaccoverage <- vaccoverage[,Vacc_IPW_month := Vacc_observed_month/FU_proportion_month]
  vaccoverage <- vaccoverage[,cumVacc_IPW_month := cumsum(Vacc_IPW_month), by = stratum]
  vaccoverage <- vaccoverage[,IPW_month := cumVacc_IPW_month/NFUP]
  
  nameoutput <- paste0("D5_vaccine_coverage_cohorts", suffix[[subpop]])
  assign(nameoutput, vaccoverage)
  save(nameoutput, file = paste0(diroutput, nameoutput, ".RData"), list = nameoutput)
  
  vartokeep <- intersect(c("type_of_cohort","cohort_label","month_fup","age_LabelValue","age_LevelOrder","NFUP_month","NFUP","indicator","Vacc_observed_month","PP_month","IPW_month"),names(vaccoverage))
  maskedvaccoverage <- copy(vaccoverage)
  maskedvaccoverage <- maskedvaccoverage[,..vartokeep]
  maskedvaccoverage <- maskedvaccoverage[,PP_month := round(PP_month, 3)]
  maskedvaccoverage <- maskedvaccoverage[,IPW_month := round(IPW_month, 3)]
  maskedvaccoverage <- maskedvaccoverage[,NFUP_masked := as.character(NFUP)]
  maskedvaccoverage <- maskedvaccoverage[NFUP >0 & NFUP <5,NFUP_masked := "< 5"]
  maskedvaccoverage <- maskedvaccoverage[,NFUP := NULL]
  maskedvaccoverage <- maskedvaccoverage[,NFUP_month_masked := as.character(NFUP_month)]
  maskedvaccoverage <- maskedvaccoverage[NFUP_month >0 & NFUP_month <5, NFUP_month_masked := "< 5"]
  maskedvaccoverage <- maskedvaccoverage[,NFUP_month := NULL]
  maskedvaccoverage <- maskedvaccoverage[,Vacc_observed_month_masked := as.character(Vacc_observed_month)]
  maskedvaccoverage <- maskedvaccoverage[Vacc_observed_month >0 & Vacc_observed_month <5, Vacc_observed_month_masked := "< 5"]
  maskedvaccoverage <- maskedvaccoverage[,Vacc_observed_month := NULL]
  if (thisdatasource == "DANREG" ){
    maskedvaccoverage <- maskedvaccoverage[,Vacc_observed_month_masked := NULL]
    maskedvaccoverage <- maskedvaccoverage[,NFUP_masked := NULL]
    maskedvaccoverage <- maskedvaccoverage[,NFUP_month_masked := NULL]
    maskedvaccoverage <- maskedvaccoverage[type_of_cohort == "covid_vacc",]
  }
  assign(nameoutput, maskedvaccoverage)
  fwrite(get(nameoutput), file = paste0(dirD4D5subpop[[subpop]], nameoutput, ".csv"))

  

}
