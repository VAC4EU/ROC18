# the output of this step are several lists and lists of lists to be used by CreateConceptsetDatasets

# concept_set_domains
# level 1 name of the conceptset (including in the name whether it is narrow or possible)
# level 2 domain

# concept_set_codes_our_study,
# level 1 name of the conceptset (including in the name whether it is narrow or possible)
# level 2 coding system
# level 3 list of codes incuded in that conceptset for that coding system

# concept_set_codes_our_study_excl
# level 1 name of the conceptset (including in the name whether it is narrow or possible)
# level 2 coding system
# level 3 list of codes to be excluded from that conceptset for that coding system

# the lists of all conceptsets 
# concept_sets_of_our_study

# input: the list of variable names associated to the algorithms, created by carlos


### IN CASE A CONCEPT IS TOO BIG IN A DAP
datasource_needing_split_conceptsets <- c("CPRD", "TEST", "ARS")
CONCEPTSETS_to_be_split <- if(thisdatasource %in% datasource_needing_split_conceptsets) c("DP_COVCARDIOCEREBROVAS") else c()
numbers_split <- c(15)

# File_SAFETY_VAC_BRIDGE is the name of the input file (also used in 06_variable_lists)
File_SAFETY_VAC_BRIDGE <- paste0(thisdir,"/p_parameters/archive_parameters/SAFETY-VAC_O1_BRIDGE_01May24.xlsx")

#  OUT_codelist: it is the dataframe containing the codelist itself (temporary: it is removed later)
OUT_codelist <- fread(paste0(thisdir,"/p_parameters/archive_parameters/20240431_V2_ALL_full_codelist_at_20240502.csv"))
OUT_codelist <- OUT_codelist[, .(coding_system, code, type, tags, event_abbreviation, system)]
OUT_codelist <- OUT_codelist[, Varname := paste(system, event_abbreviation, type, sep = "_")]

# VAR_list: it is the list of variable names
VAR_list <- as.data.table(readxl::read_excel(File_SAFETY_VAC_BRIDGE, sheet = "Variables"))
if (thisdatasource == "DANREG") {
  VAR_list <- VAR_list[Varname != "I_INFLUENZA_COV", ]
}
VAR_list <- VAR_list[rowSums(VAR_list[, c("AESI", "COV", "Algorithm", "Algorithm_input")]) > 0]
# TODO remove in next release?
VAR_list <- VAR_list[Varname %not in% c("Im_TRANSPLANTRECIPIENT_COV", "TP_TRANSPLANTRECIPIENT_COV"), ]
VAR_list <- VAR_list[!(Algorithm & !Algorithm_input), .(Varname)]
VAR_list[, Varname := trimws(Varname)]
OUT_codelist <- merge(unique(VAR_list), unique(OUT_codelist), all.x = T, by = "Varname")
rm(VAR_list)

# cleaning the codelist
OUT_codelist <- OUT_codelist[code != "" & !is.na(code), ][, event_abbreviation := toupper(event_abbreviation)]
OUT_codelist <- OUT_codelist[tags == "??", tags := "possible"]
# OUT_codelist <- OUT_codelist[tags != ""][tags == "possbie", tags := "possible"]

# Add vocabulary free_text
OUT_codelist <- rbindlist(list(OUT_codelist, copy(OUT_codelist)[coding_system == "Free_text", coding_system := "free_text"]))

# concept_set_codes_our_study: codelist in the format to be used by CreateConceptsetDatasets
concept_set_codes_our_study <- df_to_list_of_list(OUT_codelist[tags != "exclude", ], codying_system_recode = "auto", type_col = "type")

concept_set_codes_our_nar <- df_to_list_of_list(OUT_codelist[tags == "narrow", ], codying_system_recode = "auto", type_col = "type")
concept_set_codes_our_pos_nar <- df_to_list_of_list(OUT_codelist[tags == "possible", ][, tags := "narrow"], codying_system_recode = "auto", type_col = "type")

concept_set_codes_our_pos <- df_to_list_of_list(OUT_codelist[tags == "possible", ], codying_system_recode = "auto", type_col = "type")
concept_set_codes_our_nar_pos <- df_to_list_of_list(OUT_codelist[tags == "narrow", ][, tags := "possible"], codying_system_recode = "auto", type_col = "type")

concept_set_codes_our_excl <- df_to_list_of_list(OUT_codelist[tags == "exclude", ], codying_system_recode = "auto", type_col = "type")

concept_set_codes_our_study_excl <- list()
for (concept in names(concept_set_codes_our_nar)) {
  for (vocabulary in names(concept_set_codes_our_nar[[concept]])) {
    if (vocabulary == "SNOMED") {
      child_possible <- intersect(concept_set_codes_our_pos_nar[[concept]][[vocabulary]],
                                  concept_set_codes_our_nar[[concept]][[vocabulary]])
    } else {
      child_possible <- setdiff(setdiff(concept_set_codes_our_pos_nar[[concept]][[vocabulary]],
                                        CompareListsOfCodes(concept_set_codes_our_nar[[concept]][[vocabulary]],
                                                            concept_set_codes_our_pos_nar[[concept]][[vocabulary]])),
                                concept_set_codes_our_nar[[concept]][[vocabulary]])
    }
    
    
    concept_set_codes_our_study_excl[[concept]][[vocabulary]] <- c(child_possible,
                                                                   concept_set_codes_our_excl[[concept]][[vocabulary]])
    if (length(concept_set_codes_our_study_excl[[concept]][[vocabulary]]) == 0) {
      concept_set_codes_our_study_excl[[concept]][[vocabulary]] <- NULL
    }
  }
}

for (concept in names(concept_set_codes_our_pos)) {
  for (vocabulary in names(concept_set_codes_our_pos[[concept]])) {
    
    if (vocabulary == "SNOMED") {
      next
    } else {
      child_narrow <- setdiff(concept_set_codes_our_nar_pos[[concept]][[vocabulary]],
                              CompareListsOfCodes(concept_set_codes_our_nar_pos[[concept]][[vocabulary]],
                                                  concept_set_codes_our_pos[[concept]][[vocabulary]]))
      child_narrow <- c(child_narrow, intersect(concept_set_codes_our_nar_pos[[concept]][[vocabulary]],
                                                concept_set_codes_our_pos[[concept]][[vocabulary]]))
    }
    
    concept_set_codes_our_study_excl[[concept]][[vocabulary]] <- c(child_narrow, concept_set_codes_our_excl[[concept]][[vocabulary]])
    if (length(concept_set_codes_our_study_excl[[concept]][[vocabulary]]) == 0) {
      concept_set_codes_our_study_excl[[concept]][[vocabulary]] <- NULL
    }
  }
}

# concept_set_codes_our_study_excl <- df_to_list_of_list(OUT_codelist[tags == "narrow", ][, tags := "possible"],codying_system_recode = "auto", type_col = "type")
rm(OUT_codelist)

# concept_set_domains: domain of each conceptset, to be used in CreateConceptsetDatasets
concept_set_domains <- vector(mode="list")
for (concept in names(concept_set_codes_our_study)) {
  concept_set_domains[[concept]] = "Diagnosis"
}

# DRUG_codelist: temporary dataset including the codelist of drug
DRUG_codelist <- as.data.table(readxl::read_excel(File_SAFETY_VAC_BRIDGE, sheet = "DrugProxies",.name_repair = ~ vctrs::vec_as_names(..., repair = "universal", quiet = TRUE)))

DRUG_codelist <- DRUG_codelist[, ATC.codes := strsplit(ATC.codes, ",")]

DRUG_codelist_list <- df_to_list_of_list(DRUG_codelist, code_col = "ATC.codes", concepts_col = "Drug_proxie",codying_system_col = F, codying_system_recode = "auto")

# add to the list of conceptset those of domain Medicines
concept_set_codes_our_study <- c(concept_set_codes_our_study, DRUG_codelist_list)

for (concept in names(DRUG_codelist_list)) {
  concept_set_domains[[concept]] = "Medicines"
}
rm(DRUG_codelist_list)

# splitting conceptsets if necessary
if (!is.null(CONCEPTSETS_to_be_split)) {
  
  # Select only concepts to be split
  list_CONCEPTSETS_to_be_split <- concept_set_codes_our_study[names(concept_set_codes_our_study) %in% CONCEPTSETS_to_be_split]
  
  # Remove the above mentioned concept from the general list
  concept_set_codes_our_study <- concept_set_codes_our_study[names(concept_set_codes_our_study) %not in% CONCEPTSETS_to_be_split]
  
  df_CONCEPTSETS_to_be_split <- list_of_list_to_df(list_CONCEPTSETS_to_be_split)
  df_CONCEPTSETS_to_be_split[, group := cut(seq_along(code), numbers_split, labels = FALSE),
                             by = c("coding_system", "event_abbreviation", "tags")]
  
  df_CONCEPTSETS_to_be_split_NA <- df_CONCEPTSETS_to_be_split[is.na(tags), ]
  df_CONCEPTSETS_to_be_split_not_NA <- df_CONCEPTSETS_to_be_split[!is.na(tags), ]
  df_CONCEPTSETS_to_be_split_NA <- df_CONCEPTSETS_to_be_split_NA[CJ(coding_system = coding_system,
                                                                    event_abbreviation = event_abbreviation, tags = tags,
                                                                    group = seq_len(numbers_split), unique = TRUE),
                                                                 on = .(coding_system, event_abbreviation, tags, group)]
  df_CONCEPTSETS_to_be_split_not_NA <- df_CONCEPTSETS_to_be_split_not_NA[CJ(coding_system = coding_system,
                                                                            event_abbreviation = event_abbreviation, tags = tags,
                                                                            group = seq_len(numbers_split), unique = TRUE),
                                                                         on = .(coding_system, event_abbreviation, tags, group)]
  df_CONCEPTSETS_to_be_split <- rbind(df_CONCEPTSETS_to_be_split_not_NA, df_CONCEPTSETS_to_be_split_NA)
  
  df_CONCEPTSETS_to_be_split[!is.na(tags), event_abbreviation := paste(event_abbreviation, tags, group, sep = "_")]
  df_CONCEPTSETS_to_be_split[is.na(tags), event_abbreviation := paste(event_abbreviation, group, sep = "_")]
  df_CONCEPTSETS_to_be_split[, c("group", "tags") := NULL]
  
  list_CONCEPTSETS_splitted <- lapply(split(df_CONCEPTSETS_to_be_split, by = "event_abbreviation", keep.by = F),
                                      split, by = "coding_system", keep.by = F)
  
  list_CONCEPTSETS_splitted <- lapply(list_CONCEPTSETS_splitted, sapply, unlist, use.names = F, simplify = F)
  
  concept_set_codes_our_study <- c(concept_set_codes_our_study, list_CONCEPTSETS_splitted)
  
  
  # Select only concepts to be split
  list_concept_set_domains_to_be_split <- concept_set_domains[names(concept_set_domains) %in% CONCEPTSETS_to_be_split]
  
  # Remove the above mentioned concept from the general list
  concept_set_domains <- concept_set_domains[names(concept_set_domains) %not in% CONCEPTSETS_to_be_split]
  
  df_concept_set_domains_to_be_split <- list()
  for (i in names(list_concept_set_domains_to_be_split)) {
    df_concept_set_domains_to_be_split <- append(df_concept_set_domains_to_be_split,
                                                 list(data.table(domain = list_concept_set_domains_to_be_split[[i]], concept = i)))
  }
  df_concept_set_domains_to_be_split <- data.table::rbindlist(df_concept_set_domains_to_be_split)
  
  df_concept_set_domains_to_be_split <- df_concept_set_domains_to_be_split[CJ(concept = concept,
                                                                              group = seq_len(numbers_split),
                                                                              unique = TRUE),
                                                                           on = .(concept)]
  df_concept_set_domains_to_be_split[, concept := paste(concept, group, sep = "_")]
  df_concept_set_domains_to_be_split <- df_concept_set_domains_to_be_split[, group := NULL]
  list_concept_set_domains_splitted <- lapply(split(df_concept_set_domains_to_be_split, by = "concept", keep.by = F),
                                              unlist, use.names = F)
  
  concept_set_domains <- c(concept_set_domains, list_concept_set_domains_splitted)
  
}

#--------------------------
# add manually conceptsets of other domains


# procedure for mechanical ventilation

concept_set_codes_our_study[["ICU_VENTILATION"]][["ICD9PROC"]] <- c("96.70","96.71","96.72")
concept_set_codes_our_study[["ICU_VENTILATION"]][["ICD10ES"]] <- c("5A19")
concept_set_domains[["ICU_VENTILATION"]] = "Procedures"


# results from covid test recorded with a code

concept_set_codes_our_study[["COVID_test_coded"]][["Veneto_lab_coding_system"]] <- c("91.12.1_0")
concept_set_domains[["COVID_test_coded"]] = "Results"

########################
# VACCINES
##########################

##################
# covid vaccines: manual assignement

concept_set_codes_our_study[["COVID_VACCINES"]][["ATC"]] <- c("J07BX03", "J07BN", "J07BN01", "J07BN02", "J07BN03", "J07BN04")
concept_set_domains[["COVID_VACCINES"]] = "VaccineATC"

#############
# other vaccines: assignement using carlos' file (to be included in BRIDGE in the future)

VaccO_tokens <- c("COV","INF","RSV","MEN","HPV","RVV","PNE","VAR","MPX","TET","DIP","PER","POL","HIB","HEB","MEA","MUM","RUB","TUB","HEZ")

File_SAFETY_VAC_vaccines <- paste0(thisdir,"/p_parameters/archive_parameters/SAFETY-VAC_vaccines_30Apr24.xlsx")

# VACCOID_list: it is the list of all vacco_ids
VACCOID_data <- as.data.table(readxl::read_excel(File_SAFETY_VAC_vaccines, sheet = "vacco_ids"))
VACCOID_data <- VACCOID_data[, vacco_id := gsub("-", "_", vacco_id)]
VACCOID_list <- unique(unlist(VACCOID_data[,.(vacco_id)]))


# some vacco_ids are retrieved from atc, either form VACCINES or from MEDICINES, other are retrieved from type_vax in VACCINES

VACCOID_ATC_list <- unique(unlist(VACCOID_data[column_name == "vx_atc"  ,.(vacco_id)]))
VACCOID_MED_list <- unique(unlist(VACCOID_data[column_name == "medicinal_product_atc_code" ,.(vacco_id)]))
VACCOID_VXTYPE_list <- unique(unlist(VACCOID_data[column_name == "vx_type" ,.(vacco_id)]))

# create the concepts of each vacco_id
concepts_vacco_id <- list()
for (vacco_id in VACCOID_list){
  concepts_vacco_id[[vacco_id]] <- c()
  if (vacco_id %in% VACCOID_ATC_list){
    concepts_vacco_id[[vacco_id]] <- c(concepts_vacco_id[[vacco_id]], paste0(vacco_id,"ATC"))
  }
  if (vacco_id %in%  VACCOID_MED_list){
    concepts_vacco_id[[vacco_id]] <- c(concepts_vacco_id[[vacco_id]], paste0(vacco_id,"MED"))
  }
  if (vacco_id %in% VACCOID_VXTYPE_list){
    concepts_vacco_id[[vacco_id]] <- c(concepts_vacco_id[[vacco_id]], paste0(vacco_id,"VXTYPE"))
  }
}

# assign domains and codes to the concepts of each vacco_id
for (vac in VACCOID_ATC_list) {
  concept_set_domains[[paste0(vac,"ATC")]] = "VaccineATC"
  concept_set_codes_our_study[[paste0(vac,"ATC")]][["ATC"]] = unique(unlist(VACCOID_data[vacco_id == vac  & (column_name == "vx_atc" ),.(value)]))
}
for (vac in VACCOID_MED_list) {
  concept_set_domains[[paste0(vac,"MED")]] = "Medicines"
  concept_set_codes_our_study[[paste0(vac,"MED")]][["ATC"]] = unique(unlist(VACCOID_data[vacco_id == vac  & (column_name == "medicinal_product_atc_code"),.(value)]))
}
for (vac in VACCOID_VXTYPE_list) {
  concept_set_domains[[ paste0(vac,"VXTYPE")]] = "VaccineVxType"
  concept_set_codes_our_study[[paste0(vac,"VXTYPE")]][["VXTYPE"]] = unique(unlist(VACCOID_data[vacco_id == vac  & (column_name == "vx_type"),.(value)]))
  # print(vacco_id )
  # print(concept_set_codes_our_study[[paste0(vacco_id,"VXTYPE")]][["VXTYPE"]] )
}

# print(concept_set_codes_our_study[["DIP-PER-TETVXTYPE"]])

unlisted_concepts_vacco_id <- c()
for (vac in VACCOID_list){ 
  for (concept in concepts_vacco_id[[vac]]){
    unlisted_concepts_vacco_id <- c(unlisted_concepts_vacco_id,concept)
  }
}

#########################################
# DP_VACCINES

# This overwrite the automatic assignment of DP_VACCINES in variables spreadsheet
concept_set_codes_our_study[["DP_VACCINES"]][["ATC"]] <- c("J07")
concept_set_domains[["DP_VACCINES"]] = "VaccineATC"

concept_set_codes_our_study_excl[["DP_VACCINES"]] <- concept_set_codes_our_study[["COVID_VACCINES"]]


#--------------------------
# assign the names of the conceptsets
concept_sets_of_our_study <- names(concept_set_codes_our_study)

rm(concept)

