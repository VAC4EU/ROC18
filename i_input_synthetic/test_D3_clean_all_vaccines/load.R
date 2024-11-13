rm(list=ls(all.names=TRUE))

#set the directory where the script is saved as the working directory
if (!require("rstudioapi")) install.packages("rstudioapi")
thisdir <- setwd(dirname(rstudioapi::getSourceEditorContext()$path))
thisdir <- setwd(dirname(rstudioapi::getSourceEditorContext()$path))

# load packages
if (!require("data.table")) install.packages("data.table")
library(data.table)
if (!require("lubridate")) install.packages("lubridate")
library(lubridate)

# list datasets

listdatasets <- c("DIP_HEB_HIB_PER_POL_TETVXTYPE","DIP_HEB_HIB_PER_POL_TETATC")


# load datasets

listdates <- list()
listdates[["DIP_HEB_HIB_PER_POL_TETVXTYPE"]] <- c("vx_record_date","date")
listdates[["DIP_HEB_HIB_PER_POL_TETATC"]] <- c("vx_record_date","date")



for (namedataset in listdatasets){
  data <- fread(paste0(thisdir, "/", namedataset, ".csv") )
  data[, (listdates[[namedataset]]) := lapply(.SD, lubridate::ymd), .SDcols = listdates[[namedataset]]]
  assign(namedataset,data)
  save(data, file = paste0(thisdir, "/", namedataset,".RData"), list = namedataset)
}

