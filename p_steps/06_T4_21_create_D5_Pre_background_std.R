##%######################################################%##
#                                                          #
####       CALCULATE BACKGROUND STRANDARDIZED IRS       ####
#                                                          #
##%######################################################%##

for (subpop in subpopulations_non_empty) {  
  print(subpop)
  
  df_to_cycle <- paste0(c("D4_events_point_prevalence_aggregated", "D4_events_period_prevalence_aggregated"), suffix[[subpop]])
  df_export_to_cycle <- c("D5_Pre_point_background_std", "D5_Pre_period_background_std")
  for (i in seq_along(df_to_cycle)) {
    print(df_to_cycle[[i]])
    
    load(paste0(diroutput, df_to_cycle[[i]] ,".RData"))
    persontime_windows <- get(df_to_cycle[[i]])
    rm(list = df_to_cycle[[i]])
    
    if (df_to_cycle[[i]] == paste0("D4_persontime_background_aggregated", suffix[[subpop]])) {
      colstokeep <- c('COVID19','year')
      persontime_windows <- persontime_windows[Ageband != "total" & sex == 'total' & year %in% c("2019","2020"),]
      persontime_windows <- persontime_windows[year == "2019",stratum_bkr := 1]
      persontime_windows <- persontime_windows[year == "2020" & COVID19 == 0 ,stratum_bkr := 2]
      persontime_windows <- persontime_windows[year == "2020"  & COVID19 == 1,stratum_bkr := 3]
    } else {
      colstokeep <- c('year')
      persontime_windows <- persontime_windows[Ageband != "total" & sex == 'total',]
      persontime_windows <- persontime_windows[, stratum_bkr := year]
    }
    if (df_to_cycle[[i]] == paste0("D4_events_point_prevalence_aggregated", suffix[[subpop]])){
      mp <- 100000
    } else {
      mp <- 36525000
    }
    
    for (ev in c(OUTCOME_variables, "DEATH")) {
      name_count <- paste0("num_", if (i == 1) "point_" else "period_", ev)
      name_pt <- paste0("denominator", if (i == 1) "_point" else "_period")
      suppressMessages(
        my_results_CVM <- dsr(data = persontime_windows,
                              event = get(name_count),
                              fu = get(name_pt),
                              subgroup = stratum_bkr,
                              Ageband,
                              refdata = pop.eustat,
                              method = "normal",
                              sig = 0.95,
                              mp = mp, # 100,000 * 365.25
                              decimals = 1)
      )
      my_results_CVM <- my_results_CVM[,c(1,7,8,9) ]
      colnames(my_results_CVM) <- c('stratum_bkr',paste0(c("Pre_std_", "lb_std_", "ub_std_"), ev))
      my_results_CVM <- as.data.table(my_results_CVM)
      
      if (df_to_cycle[[i]] == paste0("D4_persontime_background_aggregated", suffix[[subpop]])) {
        my_results_CVM <- my_results_CVM[stratum_bkr == 1, COVID19 := 0   ]
        my_results_CVM <- my_results_CVM[stratum_bkr == 1, year := '2019'  ]
        my_results_CVM <- my_results_CVM[stratum_bkr == 2, COVID19 := 0   ]
        my_results_CVM <- my_results_CVM[stratum_bkr == 2, year := '2020'  ]
        my_results_CVM <- my_results_CVM[stratum_bkr == 3, COVID19 := 1   ]
        my_results_CVM <- my_results_CVM[stratum_bkr == 3, year := '2020'  ]
        persontime_windows <- merge(persontime_windows,my_results_CVM,by = c('COVID19','year','stratum_bkr'))
      } else {
        persontime_windows <- merge(persontime_windows,my_results_CVM,by = c('stratum_bkr'))
      }
      
      colstokeep <- c(colstokeep,paste0(c("Pre_std_", "lb_std_", "ub_std_"), ev))
    }
    persontime_windows <- persontime_windows[,..colstokeep]
    # persontime_windows <- persontime_windows[,-stratum_bkr]
    persontime_windows <- unique(persontime_windows)
    
    nameoutput <- df_export_to_cycle[[i]]
    assign(nameoutput, persontime_windows)
    save(nameoutput, file = paste0(dirD4D5subpop[[subpop]], nameoutput, ".RData"), list = nameoutput)
    
    fwrite(get(nameoutput), file = paste0(dirD4D5subpop[[subpop]], nameoutput, ".csv"))
    
  }
}

# data <- D4_persontime_background_aggregated_HOSP[Ageband != "total" & sex == 'total' & year == "2019/2020",]
# 
# my_results_CVM <- dsr(data = data,
#                       event = B_COAGDIS_AESI_b,
#                       fu = Persontime_B_COAGDIS_AESI,
#                       subgroup = COVID19,
#                       Ageband,
#                       refdata = pop.eustat,
#                       method = "gamma",
#                       sig = 0.95,
#                       mp = 36525000, # 100,000 * 365.25
#                       decimals = 2)