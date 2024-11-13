rm(list=ls(all.names=TRUE))

#set the directory where the script is saved as the working directory
if (!require("rstudioapi")) install.packages("rstudioapi")
thisdir <- setwd(dirname(rstudioapi::getSourceEditorContext()$path))
thisdir <- setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# load packages
if (!require("data.table")) install.packages("data.table")
library(data.table)
if (!require("lubridate")) install.packages("lubridate")
library(lubridate)

# load datasets

listdates <- list()
listdates[["D3_all_vaccines_curated"]] <- "date_curated"
listdates[["D3_study_population_target_cohorts"]] <- c("spell_start_date","study_entry_date","study_exit_date","birth_date","cohort_entry_date_birth12","cohort_exit_date_birth12","cohort_entry_date_birth15","cohort_exit_date_birth15","cohort_entry_date_birth24","cohort_exit_date_birth24","cohort_entry_date_adolescence","cohort_exit_date_adolescence","is_in_covid_vacc","cohort_entry_date_covid_vacc","cohort_exit_date_covid_vacc","cohort_entry_date_seasonal2018","cohort_exit_date_seasonal2018","is_in_seasonal2019","cohort_entry_date_seasonal2019","cohort_exit_date_seasonal2019","is_censored_in_seasonal2019","cohort_entry_date_seasonal2020","cohort_exit_date_seasonal2020","cohort_entry_date_seasonal2021","cohort_exit_date_seasonal2021","cohort_entry_date_seasonal2022","cohort_exit_date_seasonal2022","cohort_entry_date_seasonal2023","cohort_exit_date_seasonal2023")

listdatasets <- c("D4_monthly_prevalence_vaccination_birth12")


for (namedataset in listdatasets){
  data <- fread(paste0(thisdir, "/", namedataset, ".csv") )
  if (!is.null(listdates[[namedataset]])){
    data[, (listdates[[namedataset]]) := lapply(.SD, lubridate::ymd), .SDcols = listdates[[namedataset]]]
  }
  assign(namedataset,data)
  save(data, file = paste0(thisdir, "/", namedataset,".RData"), list = namedataset)
}

