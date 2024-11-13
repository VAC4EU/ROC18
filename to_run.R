#-------------------------------
# SAFETY-VAC script script 

# authors: Rosa Gini, Davide Messina

# v 1.0.9 - 10 May 2024
# Removed I_INFLUENZA_COV for DANREG
# Improved and fixed masking (especially DANREG and SIDIAP)
# Bugfix related to datasource name
# Censor correct time for FISABIO

# v 1.0.8 - 3 May 2024
# Fix in case of one the vaccine concept is missing
# IRs/Prev to one decimal place

# v 1.0.7 - 2 May 2024
# Covariates now last 365 days
# Removed exclusion criteria regarding vaccinations
# Restricted createconceptsetdataset for this version
# Fixed bug in retrieval o vaccines by removing duplicates
# Stratified HPV by gender
# Updated vaccine mapping table
# Increased robustness of countprevalence procedure
# Updated variable metadata and codelist

# v 1.0.6 - 15 April 2024
# Improved covid vaccines retrieval

# v 1.0.5 - 15 April 2024
# Fixed count of vaccination in cohorts
# Fixed metadata indicators for vaccination

# v 1.0.4 - 13 April 2024
# Splitted prevalence computation further for some DAPs
# Rewrite of final table 3: robust and a little bit faster
# Fixed bug in CountPrevalence

# v 1.0.3 - 12 April 2024
# Added ICD9CMP as coding system vocabulary
# Rewrite of final table 3: more robust but slower

# v 1.0.2 - 9 April 2024
# Mask small counts

# v 1.0.1 - 8 April 2024
# Decrease RAM usage for covariate TDs
# Calculate coverage in cohorts

# v 1.0.0 - 6 April 2024
# Fixed period prevalence calculation timeframe
# Fixed calculation of IRs and period prevalence
# Fixed labels in attrition diagram
# Completed table 3

# v 1.0.0 - 6 April 2024
# Fixed period prevalence calculation timeframe
# Fixed calculation of IRs and period prevalence
# Fixed labels in attrition diagram
# Completed table 3

# v 0.9.9 - 5 April 2024
# Shorter to_run
# Study start in 2016
# Fix check of newborn censoring in their cohorts
# Change IR label to Pre for prevalence
# Correct saving of std prevalence for events
# Table 3 characteristic of cohorts
# Change saving of flowchart doses of all vaccines
# Fixed codelist for inconsistent tagging

# v 0.9.1 - 4 April 2024
# Hotfix for batch_size_covid_vacc parameter

# v 0.9.0 - 4 April 2024
# Test release, based on CVM Readiness 3.3.1 https://github.com/VAC4EU/CVM/commit/fd09476a0fcb1a0f07f808ab09c6cbc6b11925a9
# to be used in one datasource to test performance and semantics


rm(list=ls(all.names=TRUE))

#set the directory where the file is saved as the working directory
if (!require("rstudioapi")) install.packages("rstudioapi")
thisdir <- setwd(dirname(rstudioapi::getSourceEditorContext()$path))
thisdir <- setwd(dirname(rstudioapi::getSourceEditorContext()$path))

##%######################################################%##
#                                                          #
####                     PARAMETERS                     ####
#                                                          #
##%######################################################%##

source(paste0(thisdir,"/p_parameters/01_parameters_program.R"))
source(paste0(thisdir,"/p_parameters/02_parameters_CDM.R"))
source(paste0(thisdir,"/p_parameters/03_concept_sets.R"))
source(paste0(thisdir,"/p_parameters/04_itemsets.R"))
source(paste0(thisdir,"/p_parameters/05_subpopulations_restricting_meanings.R"))
source(paste0(thisdir,"/p_parameters/06_variable_lists.R"))
source(paste0(thisdir,"/p_parameters/07_algorithms.R"))
source(paste0(thisdir,"/p_parameters/11_design_parameters.R"))
source(paste0(thisdir,"/p_parameters/99_saving_all_parameters.R"))


##%######################################################%##
#                                                          #
####                    MAIN SCRIPT                     ####
#                                                          #
##%######################################################%##

launch_step("p_steps/01_T2_10_create_persons.R")
launch_step("p_steps/01_T2_20_apply_CreateSpells.R")
launch_step("p_steps/01_T2_31_CreateConceptSetDatasets.R")
launch_step("p_steps/01_T2_32_CreateItemSetDatasets.R")
launch_step("p_steps/01_T2_33_CreatePromptSetDatasets.R")
launch_step("p_steps/01_T2_40_clean_vaccines.R")
launch_step("p_steps/01_T2_41_apply_criteria_for_doses.R")
launch_step("p_steps/01_T2_42_clean_all_vaccines.R")
launch_step("p_steps/01_T2_43_curate_all_vaccines.R")
launch_step("p_steps/01_T2_50_clean_spells.R")
launch_step("p_steps/01_T2_60_selection_criteria_from_PERSON_to_study_population.R")

launch_step("p_steps/02_T3_10_create_study_population.R")

launch_step("p_steps/03_T2_10_create_D3_outcomes_simple_algorithm.R")
launch_step("p_steps/03_T2_11_create_D3_outcomes_complex_algorithm.R")
launch_step("p_steps/03_T2_12_create_D3_event_outcomes_ALL.R")
# launch_step("p_steps/03_T2_20_create_D3_covid_episodes.R")
# launch_step("p_steps/03_T2_21_COVID_severity_hospitalised.R")
# launch_step("p_steps/03_T2_22_COVID_severity_ICU.R")
# launch_step("p_steps/03_T2_23_COVID_severity_DEATH.R")
# launch_step("p_steps/03_T2_24_TD_COVID_severity_levels.R")
# 
# launch_step("p_steps/03_T2_30_create_covariates.R")
launch_step("p_steps/03_T2_40_create_components.R")

launch_step("p_steps/04_T2_10_create_total_study_population.R")
# launch_step("p_steps/04_T2_20_SCRI.R")

### Calculation of Time Dependent variables
# launch_step("p_steps/04_T2_30_create_study_population_cohort.R")
launch_step("p_steps/04_T2_40_create_TD_datasets.R")
# launch_step("p_steps/04_T2_43_create_TD_covariates.R")
launch_step("p_steps/04_T2_44_create_TD_events.R")
launch_step("p_steps/04_T2_50_create_study_population_target_cohorts.R")

# launch_step("p_steps/05_T3_10_count_events_windows.R")
# launch_step("p_steps/05_T3_11_aggregate_events_windows.R")
# launch_step("p_steps/05_T3_20_create_person_time_monthly.R")
# launch_step("p_steps/05_T3_21_aggregate_person_time_monthly.R")
# launch_step("p_steps/05_T3_30_create_person_time_background.R")
# launch_step("p_steps/05_T3_31_aggregate_person_time_background.R")
launch_step("p_steps/05_T3_40_create_counts_person_time_yearly.R")
launch_step("p_steps/05_T3_41_aggregate_counts_person_time_yearly.R")
launch_step("p_steps/05_T3_50_count_point_prevalence_events.R")
launch_step("p_steps/05_T3_51_aggregate_point_prevalence_events.R")
launch_step("p_steps/05_T3_60_count_period_prevalence_events.R")
launch_step("p_steps/05_T3_61_aggregate_period_prevalence_events.R")
launch_step("p_steps/05_T3_70_count_monthly_prevalence_vaccination.R")

launch_step("p_steps/06_T4_10_create_D5_IR_background.R")
launch_step("p_steps/06_T4_11_create_D5_IR_background_std.R")
launch_step("p_steps/06_T4_20_create_D5_Pre_background.R")
launch_step("p_steps/06_T4_21_create_D5_Pre_background_std.R")
launch_step("p_steps/06_T4_50_calculate_cohort_coverage.R")

launch_step("p_steps/07_T5_10_final_tables.R")
