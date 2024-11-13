##%######################################################%##
#                                                          #
####              CALCULATE BACKGROUND IRS              ####
#                                                          #
##%######################################################%##

for (subpop in subpopulations_non_empty) {  
  print(subpop)
  
  df_to_cycle <- paste0(c("D4_counts_persontime_yearly_aggregated"), suffix[[subpop]])
  df_export_to_cycle <- c("D5_IR_yearly")
  for (i in seq_along(df_to_cycle)) {
    print(df_to_cycle[[i]])
    
    load(paste0(diroutput, df_to_cycle[[i]] ,".RData"))
    persontime_windows <- get(df_to_cycle[[i]])
    rm(list = df_to_cycle[[i]])
    
    for (ev in c(OUTCOME_variables, "DEATH")) {
      name_cols <- paste0(c("IR_", "lb_", "ub_"), ev)
      name_count <- paste0(ev,"_b")
      name_pt <- paste0("Persontime_",ev)
      persontime_windows[, (name_cols) := exactPoiCI(persontime_windows, name_count, name_pt)]
    }
    
    name_count <- paste0(c(OUTCOME_variables, "DEATH"), "_b")
    persontime_windows[, (name_count) := lapply(.SD, as.character), .SDcols = name_count]
    persontime_windows[, (name_count) := lapply(.SD, function(x) fifelse(as.integer(x) < 5 & as.integer(x) > 0, "<5", x)),
                       .SDcols = name_count]
    
    name_pt <- c("Persontime", paste0("Persontime_", c(OUTCOME_variables, "DEATH")))
    if (thisdatasource == "DANREG") {
      persontime_windows[, (name_pt) := NULL]
    }
    
    nameoutput <- df_export_to_cycle[[i]]
    assign(nameoutput, persontime_windows)
    save(nameoutput, file = paste0(dirD4D5subpop[[subpop]], nameoutput, ".RData"), list = nameoutput)
    
    fwrite(get(nameoutput), file = paste0(dirD4D5subpop[[subpop]], nameoutput, ".csv"))
    
  }
}
