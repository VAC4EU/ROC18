##%######################################################%##
#                                                          #
#### EXTRACT FROM CDM TABLES ONE DATASET PER CONCEPTSET ####
####  CONTAINING ONLY RECORDS WITH A CODE OF INTEREST   ####
#                                                          #
##%######################################################%##

events_to_restrict <- c("E_GRAVES_AESI", "D_ULCERATIVECOLITIS_COV", "Im_SJOGRENS_COV", "D_GALLSTONES_COV",
"M_ARTPSORIATIC_COV", "C_AMI_AESI", "C_MI_COV")

events_to_restrict <- c(events_to_restrict, paste0(events_to_restrict, "_narrow"), paste0(events_to_restrict, "_possible"))

if (thisdatasource == "FALSE") {
  conceptsets_exact_matching <- intersect(events_to_restrict, conceptsets_exact_matching)
  conceptsets_children_matching <- intersect(events_to_restrict, conceptsets_children_matching)
}

print('RETRIEVE FROM CDM RECORDS CORRESPONDING TO CONCEPT SETS')

CreateConceptSetDatasets(concept_set_names = conceptsets_exact_matching,
                         dataset = ConcePTION_CDM_tables,
                         codvar = ConcePTION_CDM_codvar,
                         datevar = ConcePTION_CDM_datevar,
                         EAVtables = ConcePTION_CDM_EAV_tables,
                         EAVattributes = ConcePTION_CDM_EAV_attributes_this_datasource,
                         dateformat= "YYYYmmdd",
                         vocabulary = ConcePTION_CDM_coding_system_cols,
                         rename_col = list(person_id = person_id, date = date,
                                           meaning_renamed = meaning_renamed),
                         concept_set_domains = concept_set_domains,
                         concept_set_codes =	concept_set_codes_our_study,
                         concept_set_codes_excl = concept_set_codes_our_study_excl,
                         discard_from_environment = T,
                         dirinput = dirinput,
                         diroutput = dirconceptsets,
                         extension = c("csv"),
                         vocabularies_with_dot_wildcard = c("READ"),
                         vocabularies_with_exact_search_not_dot = c("Free_text", "ICD10CM", "ICD10GM", "ICD10", "ICD9CM",
                                                                    "ICD9", "ICPC", "ICPC2P", "SNOMED", "MEDCODEID"))

CreateConceptSetDatasets(concept_set_names = conceptsets_children_matching,
                         dataset = ConcePTION_CDM_tables,
                         codvar = ConcePTION_CDM_codvar,
                         datevar = ConcePTION_CDM_datevar,
                         EAVtables = ConcePTION_CDM_EAV_tables,
                         EAVattributes = ConcePTION_CDM_EAV_attributes_this_datasource,
                         dateformat= "YYYYmmdd",
                         vocabulary = ConcePTION_CDM_coding_system_cols,
                         rename_col = list(person_id = person_id, date = date,
                                           meaning_renamed = meaning_renamed),
                         concept_set_domains = concept_set_domains,
                         concept_set_codes =	concept_set_codes_our_study,
                         concept_set_codes_excl = concept_set_codes_our_study_excl,
                         discard_from_environment = T,
                         dirinput = dirinput,
                         diroutput = dirconceptsets,
                         extension = c("csv"),
                         vocabularies_with_dot_wildcard = c("READ"),
                         vocabularies_with_exact_search = c("Free_text"))
