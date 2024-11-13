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

dirmacro <- paste0(thisdir,"/../../p_macro/")
source(paste0(dirmacro,"Cube.R"))


# load data

load(paste0(thisdir, "/temp.RData"))

# show that c("month_fup", "age") are a primary key
print(nrow(temp))
print(uniqueN(temp, by = c("month_fup", "age")))

# set the parameters for the Cube function
Agebands_cube = c(0, 2, 5, 12, 18, 30, 40, 50, 60, 70, 80)
Agebands_large = c(0, 5, 18, 60, Inf)
Agebands_large_labels = c("0-4","5-17","18-59","60+")
names(Agebands_large) <- Agebands_large_labels

dimensions = c("age","month_fup")
assigned_levels <- vector(mode="list")
assigned_levels[["age"]] <- c("ageband","ageband_large")
assigned_levels[["month_fup"]] <- c("month_fup")
assigned_rule <- vector(mode="list")
assigned_rule[["age"]][["ageband"]] <- list("split_in_bands","age",Agebands_cube)
assigned_rule[["age"]][["ageband_large"]] <- list("split_in_bands","age",Agebands_large)
rule_from_numeric_to_categorical = assigned_rule

listcleanvarnames <- c("Vacc_observed_monthCoronavirus1","Vacc_observed_before_monthCoronavirus1","NFUP_month","NFUP")

aggregated <- Cube(input = temp,
                   dimensions = c("age"),
                   levels = assigned_levels,
                   measures = listcleanvarnames,
                   computetotal = c("age"),
                   rule_from_numeric_to_categorical = assigned_rule 
)


# the result is not as expected: c("month_fup_LabelValue", "age_LabelValue", "age_LevelOrder") are not a primaty key
print(nrow(aggregated))
print(uniqueN(aggregated, by = c("month_fup_LabelValue","month_fup_LevelOrder", "age_LabelValue", "age_LevelOrder")))


