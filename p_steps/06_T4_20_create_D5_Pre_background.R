##%######################################################%##
#                                                          #
####              CALCULATE BACKGROUND IRS              ####
#                                                          #
##%######################################################%##

for (subpop in subpopulations_non_empty) {  
  print(subpop)
  
  df_to_cycle <- paste0(c("D4_events_point_prevalence_aggregated", "D4_events_period_prevalence_aggregated"), suffix[[subpop]])
  df_export_to_cycle <- c("D5_Pre_point_background", "D5_Pre_period_background")
  for (i in seq_along(df_to_cycle)) {
    print(df_to_cycle[[i]])
    
    load(paste0(diroutput, df_to_cycle[[i]] ,".RData"))
    persontime_windows <- get(df_to_cycle[[i]])
    rm(list = df_to_cycle[[i]])
    
    conversion_factor <- if (df_to_cycle[[i]] == paste0("D4_events_point_prevalence_aggregated", suffix[[subpop]])) 1 else 365.25
    
    for (ev in c(OUTCOME_variables, "DEATH")) {
      name_cols <- paste0(c("pre_", "lb_pre_", "ub_pre_"), if (i == 1) "point_" else "period_", ev)
      name_count <- paste0("num_", if (i == 1) "point_" else "period_", ev)
      name_pt <- paste0("denominator", if (i == 1) "_point" else "_period")
      persontime_windows[, (name_cols) := exactNormCI(persontime_windows, name_count, name_pt,
                                                      conversion_factor = conversion_factor)]
    }
    
    name_count <- paste0("num_", if (i == 1) "point_" else "period_", c(OUTCOME_variables, "DEATH"))
    persontime_windows[, (name_count) := lapply(.SD, as.character), .SDcols = name_count]
    persontime_windows[, (name_count) := lapply(.SD, function(x) fifelse(as.integer(x) < 5 & as.integer(x) > 0, "<5", x)),
                       .SDcols = name_count]
    
    name_pt <- paste0("denominator", if (i == 1) "_point" else "_period")
    if (thisdatasource == "DANREG") {
      persontime_windows[, (name_pt) := NULL]
    }
    
    nameoutput <- df_export_to_cycle[[i]]
    assign(nameoutput, persontime_windows)
    save(nameoutput, file = paste0(dirD4D5subpop[[subpop]], nameoutput, ".RData"), list = nameoutput)
    
    fwrite(get(nameoutput), file = paste0(dirD4D5subpop[[subpop]], nameoutput, ".csv"))
    
  }
}
