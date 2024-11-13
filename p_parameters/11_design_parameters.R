manufacturer_in_study <- covid_vaccines_ConcePTION_CDM_vocabulary[covid_vaccines_ConcePTION_CDM_vocabulary %in%
                                                                    c("pfizer", "moderna", "astrazeneca", "janssen", "novavax")]
manufacturer_in_study <- c(manufacturer_in_study, "unk")

max_number_doses <- 4

# for debugging purpose set a predefined subpop (it does not affect the script results)
subpop <- subpopulations_non_empty[1]

datasources_SCRI_SCCS_COHORT <- c("TEST", "ARS", "BIFAP", "FISABIO", "SIDIAP", "CPRD")

#################################################
# properties of cohorts where coverage is computed

list_of_cohort_types_for_coverage <- c("birth12", "birth24",  "birth15", "adolescence" ,  "covid_vacc","seasonal")

cohort_for_coverage_labels <- list()
years_in_study_birth <- as.list(2016:2023)
years_in_study <- as.list(2017:2023)
cohort_for_coverage_labels[["birth12"]] <- as.character(years_in_study_birth)
cohort_for_coverage_labels[["birth24"]] <- as.character(years_in_study_birth)[-length(years_in_study_birth)]
cohort_for_coverage_labels[["birth15"]] <- cohort_for_coverage_labels[["birth24"]]
cohort_for_coverage_labels[["adolescence"]] <- as.character(as.numeric(years_in_study) - 9)
cohort_for_coverage_labels[["covid_vacc"]] <- "2020"
cohort_for_coverage_labels[["seasonal"]] <- as.character(years_in_study)

# each person belongs to one single cohort for each type, except in the case of seasonal cohort

list_of_cohorts_for_coverage <- subset(list_of_cohort_types_for_coverage, list_of_cohort_types_for_coverage != "seasonal")
type_of_cohort <- list()
for (cohort in list_of_cohorts_for_coverage){
  type_of_cohort[[cohort]] <- cohort
}
for(season in cohort_for_coverage_labels[["seasonal"]]){
  cohort_to_add <- paste0("seasonal",season)
  list_of_cohorts_for_coverage <- c(list_of_cohorts_for_coverage,cohort_to_add)
  type_of_cohort[[cohort_to_add]] <- "seasonal"
}
# monthly increment is calendar for few cohorts, and from birthdate or a birthday for all the others
month_increment <- list()
for (cohort in list_of_cohorts_for_coverage){
  month_increment[[cohort]] <- "from birthday or birthdate"
}
month_increment[["covid_vacc"]] <- "calendar month"
for(season in cohort_for_coverage_labels[["seasonal"]]){
  cohort_to_add <- paste0("seasonal",season)
  month_increment[[cohort_to_add]] <- "calendar month"
  }
# months for cohorts starting from birthdate
month_fup_cohort <- list()
month_fup_cohort[['birth12']] <- (1:11)
month_fup_cohort[['birth15']] <- (1:14)
month_fup_cohort[['birth24']] <- (1:23)
month_fup_cohort[['adolescence']] <- (109:191)


# cohort date entry and cohort date exit
cohort_date_entry <- list()
cohort_date_entry[["birth12"]] <- "birth_date"
cohort_date_entry[["birth24"]] <- "birth_date"
cohort_date_entry[["birth15"]] <- "birth_date"
cohort_date_entry[["adolescence"]] <- "9th birthday"
cohort_date_entry[["covid_vacc"]] <- "1st december 2020"
cohort_date_entry[["seasonal2017"]] <- "1st september"
cohort_date_entry[["seasonal2018"]] <- "1st september"
cohort_date_entry[["seasonal2019"]] <- "1st september"
cohort_date_entry[["seasonal2020"]] <- "1st september"
cohort_date_entry[["seasonal2021"]] <- "1st september"
cohort_date_entry[["seasonal2022"]] <- "1st september"
cohort_date_entry[["seasonal2023"]] <- "1st september"

cohort_date_exit <- list()
cohort_date_exit[["birth12"]] <- "x months old"
cohort_date_exit[["birth24"]] <- "x months old"
cohort_date_exit[["birth15"]] <- "x months old"
cohort_date_exit[["adolescence"]] <- "16th birthday"
cohort_date_exit[["covid_vacc"]] <- "study exit"
cohort_date_exit[["seasonal2017"]] <- "30 april"
cohort_date_exit[["seasonal2018"]] <- "30 april"
cohort_date_exit[["seasonal2019"]] <- "30 april"
cohort_date_exit[["seasonal2020"]] <- "30 april"
cohort_date_exit[["seasonal2021"]] <- "30 april"
cohort_date_exit[["seasonal2022"]] <- "30 april"
cohort_date_exit[["seasonal2023"]] <- "30 april"
