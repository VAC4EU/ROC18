##%######################################################%##
#                                                          #
####  COMPUTE SPELLS OF CONTINUOUS OBSERVATION PERIODS  ####
#                                                          #
##%######################################################%##


print("COMPUTE SPELLS OF TIME FROM OBSERVATION_PERIODS")

# import input datasets
OBSERVATION_PERIODS <- data.table()
for (file in files_ConcePTION_CDM_tables[["OBSERVATION_PERIODS"]]) {
  temp <- fread(paste0(dirinput, file, ".csv"), colClasses = list(character = "person_id"))
  OBSERVATION_PERIODS <- rbind(OBSERVATION_PERIODS, temp, fill = T)
  rm(temp)
}

if (thisdatasource == "FISABIO") {
  OBSERVATION_PERIODS[, op_start_date := pmax(ymd(op_start_date), censor_date)]
}

if (this_datasource_has_subpopulations == FALSE) {
  
  OBSERVATION_PERIODS <- OBSERVATION_PERIODS[,op_meaning:="all"]
  D3_output_spells_category <- CreateSpells(
    dataset = OBSERVATION_PERIODS,
    id = "person_id" ,
    start_date = "op_start_date",
    end_date = "op_end_date",
    category ="op_meaning",
    replace_missing_end_date = study_end,
    gap_allowed = days
  )
  
  D3_output_spells_category <- as.data.table(D3_output_spells_category)
  setkeyv(
    D3_output_spells_category,
    c("person_id", "entry_spell_category", "exit_spell_category", "num_spell", "op_meaning")
  )
  
  save(D3_output_spells_category,file = paste0(dirtemp,"D3_output_spells_category.RData"))
}

empty_spells <- OBSERVATION_PERIODS[1,.(person_id)]
empty_spells <- empty_spells[,op_meaning := "test"]
empty_spells <- empty_spells[,entry_spell_category := ymd('20010101')]
empty_spells <- empty_spells[,exit_spell_category := ymd('20010101')]
empty_spells <- empty_spells[,num_spell := 1]
empty_spells <- empty_spells[op_meaning!="test",]

if (this_datasource_has_subpopulations == TRUE){
  # for each op_meaning_set, create the dataset of the corresponding spells
  output_spells_category_meaning_set <- vector(mode="list")
  for (op_meaning_set in op_meaning_sets[[thisdatasource]]){
    periods_op_meaning_set <- OBSERVATION_PERIODS
    cond_op_meaning_set <- ""
    for (op_meaning in op_meanings_list_per_set[[thisdatasource]][[op_meaning_set]]){
      if (cond_op_meaning_set=="") {cond_op_meaning_set = paste0("op_meaning=='",op_meaning,"'")
      }else{
        cond_op_meaning_set=paste0(cond_op_meaning_set, " | op_meaning=='",op_meaning,"'")
      }
    }
    periods_op_meaning_set <- periods_op_meaning_set[eval(parse(text = cond_op_meaning_set)),]
    periods_op_meaning_set <- periods_op_meaning_set[,op_meaning:= op_meaning_set]
    print(paste0("COMPUTE SPELLS OF TIME FOR ",op_meaning_set,": ",cond_op_meaning_set))
    output_spells_op_meaning_set <- CreateSpells(
      dataset=periods_op_meaning_set,
      id="person_id" ,
      start_date = "op_start_date",
      end_date = "op_end_date",
      category ="op_meaning",
      replace_missing_end_date = study_end,
      gap_allowed = days
    )
    if (nrow(output_spells_op_meaning_set)>0){
      output_spells_op_meaning_set<-as.data.table(output_spells_op_meaning_set)
      setkeyv(
        output_spells_op_meaning_set,
        c("person_id", "entry_spell_category", "exit_spell_category", "num_spell", "op_meaning")
      )
    }else{
      output_spells_op_meaning_set <- empty_spells
    }
    output_spells_category_meaning_set[[op_meaning_set]] <- output_spells_op_meaning_set
  }
  save(output_spells_category_meaning_set,file=paste0(dirtemp,"output_spells_category_meaning_set.RData"))
  
  # creates spells of overlapping op_meaning sets
  load(paste0(dirtemp,"output_spells_category_meaning_set.RData"))
  for (subpop in subpopulations_non_empty){
    op_meaning_sets_in_subpop <- op_meaning_sets_in_subpopulations[[thisdatasource]][[subpop]]
    if (length(op_meaning_sets_in_subpop)>1){
      runninglen = 1
      while (runninglen < length(op_meaning_sets_in_subpop)) {
        op_meaning_set_first = op_meaning_sets_in_subpop[1]
        if (runninglen > 1){
          for (j in 2:runninglen) {
            print(j)
            op_meaning_set_first = paste0(op_meaning_set_first,'_',op_meaning_sets_in_subpop[j])
          }
        }
        op_meaning_set_second = op_meaning_sets_in_subpop[runninglen+1]
        overlap_op_meaning_sets <- paste0(op_meaning_set_first,'_',op_meaning_set_second)
        # compute spells overlap corresponding to overlap_op_meaning_sets, unless it has been already computed
        if (!(overlap_op_meaning_sets %in% names(output_spells_category_meaning_set))){
          print(paste0("COMPUTE SPELLS OF TIME FOR ",overlap_op_meaning_sets))
          inputfirst <- output_spells_category_meaning_set[[op_meaning_set_first]]
          inputsecond <- output_spells_category_meaning_set[[op_meaning_set_second]]
          # check whether one of the two composing input files is empty (if so, the overlap is also empty), otherwise use CreateSpells again
          if(nrow(inputfirst)==0 | nrow(inputsecond)==0){
            output_spells_category_meaning_set[[overlap_op_meaning_sets]] <- empty_spells
          }else{
            input_observation_periods_overlap <- as.data.table(rbind(inputfirst,inputsecond,fill = T))
            temp <- CreateSpells(
              dataset=input_observation_periods_overlap,
              id="person_id" ,
              start_date = "entry_spell_category",
              end_date = "exit_spell_category",
              category = "op_meaning",
              gap_allowed = days,
              overlap = T,
              dataset_overlap = "overlap",
              replace_missing_end_date = study_end,
              only_overlaps = T
            )
            output_spells_category_meaning_set[[overlap_op_meaning_sets]] <- get("overlap")
          }
        }
        runninglen = runninglen + 1
      }
      
    }
  }
  save(output_spells_category_meaning_set,file=paste0(dirtemp,"output_spells_category_meaning_set.RData"))
}

# if the datasource has subpopulations, assign to each subpopulation its spells
if (this_datasource_has_subpopulations == TRUE){
  load(paste0(dirtemp,"output_spells_category_meaning_set.RData"))
  D3_output_spells_category <- vector(mode="list")
  for (subpop in subpopulations_non_empty){
    print(subpop)
    op_meaning_sets_in_subpop <- op_meaning_sets_in_subpopulations[[thisdatasource]][[subpop]]
    print(op_meaning_sets_in_subpop)
    print(length(op_meaning_sets_in_subpop))
    if (length(op_meaning_sets_in_subpop)==1){
      D3_output_spells_category[[subpop]] <- output_spells_category_meaning_set[[op_meaning_sets_in_subpop]]
    }
    if (length(op_meaning_sets_in_subpop)>1){
      concat_op_meaning_sets_in_subpop = op_meaning_sets_in_subpop[1]
      for (j in 2:length(op_meaning_sets_in_subpop)){
        concat_op_meaning_sets_in_subpop = paste0(concat_op_meaning_sets_in_subpop,'_',op_meaning_sets_in_subpop[j])
      }
      D3_output_spells_category[[subpop]] <- output_spells_category_meaning_set[[concat_op_meaning_sets_in_subpop]]
    }
  }
  save(D3_output_spells_category,file=paste0(dirtemp,"D3_output_spells_category.RData"))
}
