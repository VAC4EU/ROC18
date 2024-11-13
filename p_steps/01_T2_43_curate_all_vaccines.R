##%######################################################%##
#                                                          #
####  APPLY EXCLUSION CRITERIA FOR VACCINATION RECORDS  ####
#                                                          #
##%######################################################%##


# input: D3_clean_all_vaccines
# output: Flowchart_QC_criteria, D3_all_vaccines_curated

load(paste0(dirtemp, "D3_clean_all_vaccines.RData"))

# Crate the flowchart and filter the record of the doses
D3_all_vaccines_curated <- CreateFlowChart(
  dataset = D3_clean_all_vaccines,
  listcriteria = c("duplicated_records","missing_date","distance_too_short","duplicated_records_final"),
  flowchartname = "Flowchart_criteria_for_all_vaccines")

# Save the flowchart
for (subpop in subpopulations_non_empty) {  
  fwrite(Flowchart_criteria_for_all_vaccines, paste0(direxpsubpop[[subpop]], "Flowchart_criteria_for_all_vaccines.csv"))
}

# Clean and save the final dataset 
D3_all_vaccines_curated <- D3_all_vaccines_curated[, .(person_id, date_curated, dose_curated, manufacturer_curated, vacco_id, root_indicator)]

# add the covid vaccines curated specifically
load(paste0(dirtemp, "D3_vaccines_curated.RData"))
D3_vaccines_curated <- D3_vaccines_curated[,vacco_id := "COV"]
D3_vaccines_curated <- D3_vaccines_curated[,root_indicator := "Coronavirus"]

D3_all_vaccines_curated <- rbind(D3_all_vaccines_curated,D3_vaccines_curated)

# Save
save(D3_all_vaccines_curated, file = paste0(dirtemp, "D3_all_vaccines_curated.RData"))

rm(D3_vaccines_curated, D3_all_vaccines_curated, D3_clean_all_vaccines, Flowchart_criteria_for_all_vaccines)