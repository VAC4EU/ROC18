#'CreateItemsetDatasets
#'
#'#'Authors: Olga Paoletti, Davide Messina
#'

#'Version 05 
#'17/05/2022
#' improve after new parametrization of the parameter EAVtables 
#'
#'Version 04 
#'19/01/2022
#'
#' The function CreateItemsetDatasets inspects a set of input tables af data and creates a group of datasets, each corresponding to a item set. Each dataset contains the records of the input tables that match the corresponding item set and is named out of it. 
#'
#'
#' @param EAVtables a 2-level list specifying, tables in a Entity-Attribute-Value structure; each table is listed with the name of two columns: the one contaning attributes and the one containing values
#' @param	datevar (optional): a 2-level list containing, for each input table of data, the name(s) of the column(s) containing dates (only if extension="csv"), to be saved as dates in the output
#' @param	dateformat (optional): a string containing the format of the dates in the input tables of data (only if -datevar- is indicated); the string must be in one of the following:	YYYYDDMM
#' @param rename_col (optional) a list containing the 2-level lists to rename (for istance, id and date)
#' @param	numericvar (optional): a 2-level list containing, for each input table of data, the name(s) of the column(s) containing numbers (only if extension="csv"), to be saved as a number in the output
#' @param study_variable_names (list of strings): list of the study variables of interest
#' @param	itemset (3-level list of lists): this is a list specifying which itemsets are to be retrieved for a study variable: the list has 3 levels:study variable (string): must be one of the strings in the list -study_variable_names-,	table to be queried (string): specified the name of the input table of data where the attributes must be searched for,	attribute to be selected (list of strings): attributes to be matched in the table; it can be a single column, or multiple columns
#' @param addtabcol a logical parameter, by default set to TRUE: if so, the columns "Table_cdm" and "Col" are added to the output, indicating respectively from which original table and column the code is taken.
#' @param verbose a logical parameter, by default set to FALSE. If it is TRUE additional intermediate output datasets will be shown in the R environment
#' @param discard_from_environment a logical parameter, by default set to FALSE: if so the itemsets datasets are saved in the R environment
#' @param dirinput (optional) the directory where the input tables of data are stored. If not provided the working directory is considered.
#' @param diroutput (optional) the directory where the output concept sets datasets will be saved. If not provided the working directory is considered.
#' @param extension the extension of the input tables of data (csv and dta are supported)
#'
#' @details
#'
#' @seealso 
#' 
CreateItemsetDatasets <- function(EAVtables,datevar,dateformat, rename_col,numericvar,
                                  study_variable_names,itemset,
                                  addtabcol=T, verbose=F,                                                                discard_from_environment=F,
                                  dirinput,diroutput,extension) {
  if (!require("haven")) install.packages("haven")
  library(haven)
  if (!require("stringr")) install.packages("stringr")
  library(stringr)
  if (!require("purrr")) install.packages("purrr") #flatten
  library(purrr)
  if (!require("readr")) install.packages("readr")
  library(readr)
  if (!require("data.table")) install.packages("data.table")
  library(data.table)
  if (!require("lubridate")) install.packages("lubridate")
  library(lubridate)
  
  if (missing(diroutput)) diroutput<-getwd()
  #Check that output folder exist otherwise create it
  
  suppressWarnings( if (!(file.exists(diroutput))){
    dir.create(file.path( diroutput))
  })
  
  #adapt the EAVtables parameter structure to the old one
  for (t in 1:length(EAVtables)){
    if (length(unlist(EAVtables[[t]]))==2) {
      message("New parameter specification")
      new_parameter<-c(names(EAVtables)[[t]],unlist(EAVtables[[t]]))
      EAVtables[[t]]<-list(as.list(new_parameter))
    }
    else if(length(unlist(EAVtables[[t]]))==3){
      message("Old parameter specification")
    }else{
      stop("The number of elements listed in each last level of the EAVtables parameters must be 2 or 3")
    }
  }
  

  
  for (p in 1:length(EAVtables)){
    for (df2 in EAVtables[[p]][[1]][[1]]){
      print(paste0("I'm analysing table ",df2))
      if (missing(dirinput)) dirinput<-getwd()
      if (extension == "dta") {
        used_df <- as.data.table(read_dta(paste0(dirinput,"/",df2,".",extension)))
      } else if (extension == "csv") {
        options(readr.num_columns = 0)
        used_df <- fread(paste0(dirinput,"/",df2,".",extension),colClasses = list( character="person_id"))
      }
      else if (extension == "RData") {
        assign('used_df', get(load(paste0(dirinput,"/",df2,".",extension))))
      }
      
      if (!missing(dateformat)){
        for (n in 1:length(datevar[[df2]])) {
          if(str_count(dateformat, "m")==3 |str_count(dateformat, "M")==3) {
            used_df[,datevar[[df2]][[n]]]<-as.Date(used_df[,get(datevar[[df2]][[n]])],"%d%b%Y")
          } else if (substring(dateformat, 1,1)=="Y" | substring(dateformat, 1,1)=="y" ) {
            used_df[,datevar[[df2]][[n]]]<-ymd(used_df[,get(datevar[[df2]][[n]])])
          }else if (substring(dateformat, 1,1)=="D" | substring(dateformat, 1,1)=="d" ) {
            used_df[,datevar[[df2]][[n]]]<-dmy(used_df[,get(datevar[[df2]][[n]])])
          }
        }
      }
      
      if (!missing(numericvar)){
        used_df[,(numericvar[[df2]]):= lapply(.SD, as.numeric), .SDcols = numericvar[[df2]]]
        if (all(sapply(used_df[,get(numericvar[[df2]])], class) == "numeric"))
          print(paste0(numericvar[[df2]], " are all numeric"))
      }
      
      if(!missing(rename_col)){
        ###################RENAME THE COLUMNS ID AND DATE
        for (elem in names(rename_col)) {
          data <- rename_col[[elem]]
          if (data[[df2]] %in% names(used_df)) {
            data.table::setnames(used_df, data[[df2]], elem)
          }
        }
      }
      
      
      
      used_df[, General:=0]
      #used_df0<-as.data.table(data.frame(matrix(ncol = 0, nrow = 0)))
      #for each table search for pair in the specified columns
      if (length(c)!=0) {
        for (study_var in study_variable_names) {
          if (df2 %in% names(itemset[[study_var]])) {
            print(paste(df2, "in study variable",study_var))
            used_dfAEV<-data.table()             
            for (i in 1:length(itemset[[study_var]][[df2]])) {
              if (length(itemset[[study_var]][[df2]])!=0) {
                if (length(itemset[[study_var]][[df2]][[1]])==2){
                  used_df<-used_df[get(EAVtables[[p]][[1]][[2]])==itemset[[study_var]][[df2]][[i]][[1]] & get(EAVtables[[p]][[1]][[3]])==itemset[[study_var]][[df2]][[i]][[2]],c("Filter",paste0("Col_",study_var)):= list(1,list(c(itemset[[study_var]][[df2]][[i]][[1]],itemset[[study_var]][[df2]][[i]][[2]])))]
                }else{ 
                  #print(length(itemset[[study_var]][[df2]][[1]]))
                  used_df<-used_df[get(EAVtables[[p]][[1]][[2]])==itemset[[study_var]][[df2]][[i]][[1]],c("Filter",paste0("Col_",study_var)):= list(1,list(c(itemset[[study_var]][[df2]][[i]][[1]])))]
                }
              }
            }
            
            if ("Filter" %in% colnames(used_df)) {
              used_df[Filter == 1,General:=1]
              Newfilter1 <- paste0("Filter_",study_var)
              setnames(used_df,old = "Filter",new = Newfilter1)
            }
            
            

            empty_df <- used_df[0,]
            empty_df<-empty_df[, .SD, .SDcols = !patterns("^Col_|^Filter|^General")]
            
            #keep only the rows that have matched AVpair
            filtered_df <- used_df[General == 1,][,Table_cdm:=df2]
            
            
            if (verbose == F) {
              #if (nrow(filtered_df) != 0) {
              assign(paste0("FILTERED","_",df2),filtered_df)
              #}
            }else{
              #if (nrow(filtered_df) != 0)
              assign(paste0("FILTERED","_",df2),filtered_df,envir = parent.frame())
            }
            
            #split the dataset with respect to the study_var
            for (study_var in study_variable_names) {
              if (df2 %in% names(itemset[[study_var]])) {
                if (paste0("Filter_",study_var) %in% colnames(filtered_df)) {
                  setnames(filtered_df,unique(names(filtered_df[,grepl(paste0("\\b","Filter_",study_var,"\\b"),colnames(filtered_df)), with = F])),"Filter")
                  filtered_df2 <- filtered_df[Filter == 1,] [,"General":=NULL]
                  filtered_df2 <- filtered_df2[,!grep("^Filter",names(filtered_df2)),with = F]
                  
                  if (paste0("Col_",study_var) %in% colnames(filtered_df2)) {
                    setnames(filtered_df2,unique(names(filtered_df2[,grepl(paste0("\\b","Col_",study_var,"\\b"),colnames(filtered_df2)), with = F])),"AVpair")
                    filtered_df2 <- filtered_df2[,!grep("^Col_",names(filtered_df2)),with = F]
                  }
                  Newfilter2 <- paste0("Filter_",study_var)
                  setnames(filtered_df,old = "Filter",new = Newfilter2)
                  
                  if (verbose == F) {
                    #if (nrow(filtered_df2) != 0)
                    assign(paste0(study_var,"_",df2),filtered_df2)
                  }else{#if (nrow(filtered_df2) != 0)
                    assign(paste0(study_var,"_",df2),filtered_df2,envir = parent.frame())
                  }
                }
              }
            }
          }
        }
      }
    }
  }
      
      ###########append all the datasets related to the same study_var
  
      for (study_var in study_variable_names) {
        export_df <- as.data.table(data.frame(matrix(ncol = 0, nrow = 0)))
        for (p in 1:length(EAVtables)){
          for (df2 in EAVtables[[p]][[1]][[1]]){
        if (length(itemset)!=0) { #length(itemset)!=0
          if ( df2 %in% names(itemset[[study_var]])) {

                if (exists(paste0(study_var,"_",df2))){
                  temp <- eval(parse(text = paste0(study_var,"_",df2)))
                  if(nrow(temp)!=0){
                    export_df = suppressWarnings(rbind(export_df, temp, fill = T))
                  }
            }
            
        }
        #   else{
        #   export_df <- used_df[,-"General"]
        #   assign(study_var, export_df, envir = parent.frame())
        #   save(study_var, file = paste0(diroutput,"/",study_var,".RData"),list = study_var)
        # }
        }
            
}
          if(nrow(export_df)==0) {export_df <- empty_df}
          if (addtabcol == F) {export_df<-export_df[,c("Table_cdm","AVpair"):=NULL]}
          if (discard_from_environment==T) {
            assign(study_var, export_df)
          }else{
            assign(study_var, export_df, envir = parent.frame())}
          save(study_var, file = paste0(diroutput,"/",study_var,".RData"),list = study_var)
        }
        
      print(paste(study_var, "datasets saved in",diroutput))
  }

}

