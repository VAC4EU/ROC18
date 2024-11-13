#---------------------------------------------------------------------------
# create few lists, each containing names of variables of interest for different D3s

# input: the list of variable names associated to the algorithms, created by the PI: the name of the file was stored in File_SAFETY_VAC_BRIDGE in step 03_concept_sets

#output:
# VAR_codelist - dataset with instructions (also used in step 07)
# OUTCOME_variables - list of names of variables that are outcomes
# recurrent_OUTCOME_variables - subset of OUTCOME_variables inclusing only outcomes that are recurrent
# COV_variables_raw - list of names of variables that are covariates
# DP_variables - subset of COV_variables_raw including only drug proxies
# COV_variables - subset of COV_variables_raw including only diagnosis
# VACCINES_variable - name of the variable containing the vaccines

VAR_codelist <- readxl::read_excel(File_SAFETY_VAC_BRIDGE, sheet = "Variables")
VAR_codelist <- unique(as.data.table(VAR_codelist))

if (thisdatasource == "DANREG") {
  VAR_codelist <- VAR_codelist[Varname != "I_INFLUENZA_COV", ]
}

VAR_codelist <- unique(as.data.table(VAR_codelist))

# TODO remove before release?
VAR_codelist[, Varname := trimws(Varname)]
VAR_codelist <- VAR_codelist[Varname == "Ment_Insomnia_COV", Varname := "Ment_INSOMNIA_COV"]
# TODO remove in next release?
VAR_codelist <- VAR_codelist[Varname %not in% c("Im_TRANSPLANTRECIPIENT_COV", "TP_TRANSPLANTRECIPIENT_COV"), ]

# Create dictionary for final table to recode variable name
Dictionary_VARNAME_label <- VAR_codelist[(AESI) | (COV), .(Varname, Label)]

# Divide drug and diagnosis
DRUG_codelist <- VAR_codelist[(DP), ]
VAR_codelist <- VAR_codelist[!(DP), ]

# list of variable names of OUTCOMES
OUTCOME_variables <- c(VAR_codelist[(AESI), Varname], DRUG_codelist[(AESI), Varname])
# OUTCOME_variables <- OUTCOME_variables[OUTCOME_variables %in% SCRI_list_variables]

# list of variable names of COVARIATES
COV_variables_raw <- c(VAR_codelist[(COV), Varname], DRUG_codelist[(COV), Varname])

# TODO check recurrent events
recurrent_OUTCOME_variables <- c("Im_ANAPHYLAXIS_AESI")

# Creating DP_variables from COV manually
# list of variable names of DRUG_PROXIES
DP_variables <- COV_variables_raw[grepl("^DP_", COV_variables_raw)]

# list of variable names of COVARIATES without DRUG_PROXIES
COV_variables <- setdiff(COV_variables_raw, DP_variables) 

# TODO test if needed
# variables_of_our_study <- c(VAR_codelist[, Varname], DRUG_codelist[, Drug_proxie])
# auxiliary_variables <- c(VAR_codelist[(Algorithm_input) & !((COV) | (NEG) | (AESI)), Varname],
#                          DRUG_codelist[(Algorithm_input) & !((COV) | (AESI)), Drug_proxie])

###############################################
# VACCINES AND INDICATORS

# File_SAFETY-VAC_indicators is the name of the input file of the indicators 
  
  File_SAFETY_VAC_indicators <- paste0(thisdir,"/p_parameters/archive_parameters/SAFETY-VAC_indicators_30Apr24.xlsx")
  
  File_SAFETY_VAC_indicators <- as.data.table(readxl::read_excel(File_SAFETY_VAC_indicators))
  
  # Extract indicator_list and root_indicator_list
  indicator_list <- unique(File_SAFETY_VAC_indicators$indicator)
  root_indicator_list <- unique(File_SAFETY_VAC_indicators$root_indicator)
  
  # Initialize and populate all the properties of indicators
  root_indicator_vacco_ids <- list()
  root_indicator_dose <- list()
  indicator_name <- list()
  indicator_root_indicator <- list()
  indicator_vacco_ids <- list()
  indicator_types_of_cohort <- list()
  indicator_dose <- list()
  for (ind in root_indicator_list) { 
    root_indicator_vacco_ids[[ind]] <- unique(strsplit(unlist(File_SAFETY_VAC_indicators[root_indicator == ind, .(vacco_ids)])," "))
    root_indicator_dose[[ind]] <- unlist(File_SAFETY_VAC_indicators[root_indicator == ind, .(dose)], use.names = FALSE)
    }
  for (ind in indicator_list) {
    indicator_name[[ind]] <- unlist(File_SAFETY_VAC_indicators[indicator == ind, .(indicator_name)])
    indicator_root_indicator <- unique(strsplit(unlist(File_SAFETY_VAC_indicators[indicator == ind, .(root_indicator)])," "))
    indicator_vacco_ids[[ind]] <- unique(strsplit(unlist(File_SAFETY_VAC_indicators[indicator == ind, .(vacco_ids)])," "))
    indicator_types_of_cohort[[ind]] <- unique(strsplit(unlist(File_SAFETY_VAC_indicators[indicator == ind, .(types_of_cohort)])," "))
    indicator_dose[[ind]] <- unlist(File_SAFETY_VAC_indicators[indicator == ind, .(dose)])
  }

# Print the lists
# print(indicator_list)
# print(indicator_dose)
#print(indicator_vacco_ids)


# indicator_list = c("MCV1","DPT1","DPT2","Influenza")
# indicator_vacco_ids <- list()
# indicator_vacco_ids[["MCV1"]] <- "MEA"
# indicator_vacco_ids[["DPT1"]] <- c("DIP","PER","TET")
# indicator_vacco_ids[["DPT2"]] <- c("DIP","PER","TET")
# indicator_vacco_ids[["Influenza"]] <- "INF"
# indicator_dose <- list()
# indicator_dose[["MCV1"]] <- 1
# indicator_dose[["DPT1"]] <- 1
# indicator_dose[["DPT2"]] <- 2

# Variable for COVID_VACCINES
VACCINES_variable <- "COVID_VACCINES"
