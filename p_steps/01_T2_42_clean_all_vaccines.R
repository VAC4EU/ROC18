##%######################################################%##
#                                                          #
#### CREATE EXCLUSION CRITERIA FOR VACCINATION RECORDS     #
#### (ALL VACCINES EXCEPT COVID)                        ####
#                                                          #
##%######################################################%##



if (TEST == "Y"){
  dirconceptsets <- paste0(thisdir,"/i_input_synthetic/test_D3_clean_all_vaccines/")
  dirtemp <- dirconceptsets
  VACCOID_list <- "DIP_HEB_HIB_PER_POL_TET"
  concepts_vacco_id[["DIP_HEB_HIB_PER_POL_TET"]] <- c("DIP_HEB_HIB_PER_POL_TETVXTYPE","DIP_HEB_HIB_PER_POL_TETATC")
}


All_vaccines <- data.table()
for (vac in VACCOID_list){ 
  #remove covid vaccines (treated separately)
  if (vac != "COV"){
    for (concept in concepts_vacco_id[[vac]]){
      print(concept)
      if (file.exists(paste0(dirconceptsets, concept,".RData"))) {   
        load(paste0(dirconceptsets, concept,".RData"))
        temp <- get(concept)[,concept_vacco_id := concept]
        temp <- temp[,vacco_id := vac]
        All_vaccines <- rbind(All_vaccines,temp, fill = TRUE)
        
        rm(temp, list = c(concept))
        }
      }
    }
  }

if (nrow(All_vaccines) > 0) {
  # Recode, create variables and keep only useful ones
  
  All_vaccines[, vx_record_date := ymd(vx_record_date)]
  All_vaccines[, vx_manufacturer := tolower(as.character(vx_manufacturer))]
  All_vaccines[!str_detect(vx_dose, "^[1-9]$"), vx_dose := 0]
  All_vaccines[, vx_dose := as.integer(vx_dose)]
  All_vaccines[, date_curated := fifelse(!is.na(date), date, vx_record_date)]
  All_vaccines[, manufacturer_curated := vx_manufacturer]
  All_vaccines[manufacturer_curated %not in% covid_vaccines_ConcePTION_CDM_vocabulary, manufacturer_curated := "unk"]
  
  key_variables <- c("person_id", "date", "vx_record_date", "vx_dose",
                     "vx_manufacturer", "date_curated", "manufacturer_curated",        "concept_vacco_id","vacco_id")
  All_vaccines <- All_vaccines[, ..key_variables]
  
  #########################################
  # associate indicators to vaccines; indicator_list and the other parameters are assigned in 06_variable_list
  
  All_vaccines <- All_vaccines[, root_indicator := ""]
  All_vaccines_with_indicators <- All_vaccines[0]
  #  All_vaccines <- All_vaccines[grepl("DIP", vacco_id) & grepl("PER", vacco_id) & grepl("TET", vacco_id) , indicator := "DPT"]
  for (ind in root_indicator_list){
    condition_list <- vector(mode = "character", length = 0)
    for (vac in root_indicator_vacco_ids[[ind]]){
      condition_list <- c(condition_list,paste0('grepl(','\"',vac,'\"',',vacco_id)') )
    }
    # if (!is.null(indicator_dose[[ind]]) ){
    #   condition_list <- c(condition_list,paste0('dose_curated == ',indicator_dose[[ind]]) )
    # }
    condition <- paste(condition_list, collapse = " & ")
    All_vaccines <- All_vaccines[eval(parse(text = condition)), root_indicator := ind]
    All_vaccines_with_indicators <- rbind(All_vaccines_with_indicators, All_vaccines[root_indicator == ind,])
  }
  rm(All_vaccines)
  
  ### Start with exclusion criteria
  # Duplicated record: this removes all records that have same variables except the concept_vacco_id, which may be different if the same record is retrieved both with VXTYPE and ATC, or if the same vaccination is stored on the same day both in data banks ETL'ed to VACCINES and in databanks ETL'ed to MEDICINES 
  key_variables_new <- setdiff(names(All_vaccines_with_indicators), 'concept_vacco_id')
  
  setkeyv(All_vaccines_with_indicators, key_variables_new)
  All_vaccines_with_indicators[, duplicated_records := fifelse(rowidv(All_vaccines_with_indicators, key_variables_new) != 1, 1, 0)]
  All_vaccines_with_indicators[, removed_row := duplicated_records]
  
  
  # Missing date
  All_vaccines_with_indicators[removed_row == 0, missing_date := fifelse(is.na(date_curated), 1, 0)]
  All_vaccines_with_indicators[, removed_row := rowSums(.SD, na.rm = T), .SDcols = c("removed_row", "missing_date")]
  
  ### Distance between doses 
  key_variables <- c("person_id","root_indicator", "date_curated")
  setorderv(All_vaccines_with_indicators, c(key_variables))
  
  days30 <- days(30)
  All_vaccines_with_indicators[removed_row == 0, shifted_date := date_curated]
  All_vaccines_with_indicators[removed_row == 0, shifted_date := fifelse(date <= shift(shifted_date, fill = date[1]) + days30,
                                                         shift(shifted_date, fill = date[1]),
                                                         date), by = .(person_id, root_indicator)]
  
  All_vaccines_with_indicators <- All_vaccines_with_indicators[shifted_date != date_curated, distance_too_short := 1]
  All_vaccines_with_indicators <- All_vaccines_with_indicators[distance_too_short == 1, removed_row := 1]
  All_vaccines_with_indicators[, shifted_date := NULL]
  
  
  # Duplicated record
  key_variables_new <- names(All_vaccines_with_indicators)
  setkeyv(All_vaccines_with_indicators, key_variables_new)
  All_vaccines_with_indicators[, duplicated_records_final := fifelse(rowidv(All_vaccines_with_indicators, key_variables) != 1, 1, 0)]
  All_vaccines_with_indicators[duplicated_records_final == 1, removed_row := 1]
  
  # Imputation of doses in chronological order
  All_vaccines_with_indicators <- All_vaccines_with_indicators[removed_row == 0, dose_curated := rowid(person_id, root_indicator)]
  All_vaccines_with_indicators <- All_vaccines_with_indicators[removed_row == 0, imputed_dose := dose_curated != vx_dose]

}else{
  rm(All_vaccines)
  All_vaccines_with_indicators <- data.table(
    person_id = character(0),
    date = as.Date(integer(0)),
    vx_record_date = as.Date(integer(0)),
    vx_dose = integer(0),
    vx_manufacturer = character(0),
    date_curated = as.Date(integer(0)),
    dose_curated = integer(0),
    manufacturer_curated = character(0),
    vacco_id = character(0),
    concept_vacco_id = character(0),
    root_indicator = character(0),
    imputed_dose = integer(0),
    duplicated_records = integer(0),
    missing_date = integer(0),
    distance_too_short = integer(0),
    duplicated_records_final = integer(0),
    removed_row = integer(0)
  )
}

# Clean dataset
D3_clean_all_vaccines <- All_vaccines_with_indicators[, .(person_id, date, vx_record_date, vx_dose, vx_manufacturer, date_curated,
                                                          dose_curated, manufacturer_curated, imputed_dose, duplicated_records,
                                                          missing_date, distance_too_short, duplicated_records_final, removed_row)]
D3_clean_all_vaccines <- All_vaccines_with_indicators

# Imputation of missing values
for (i in names(D3_clean_all_vaccines)){
  D3_clean_all_vaccines[is.na(get(i)), (i) := 0]
}

# Saving
save(D3_clean_all_vaccines, file = paste0(dirtemp, "D3_clean_all_vaccines.RData"))
if (TEST == "Y"){
  fwrite(D3_clean_all_vaccines,paste0(dirtemp, "D3_clean_all_vaccines.csv"))
}
rm(All_vaccines_with_indicators, D3_clean_all_vaccines)
