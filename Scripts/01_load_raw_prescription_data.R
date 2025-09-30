library(openxlsx)
library(httr)
library(jsonlite)
library(dplyr)
library(readxl)
library(writexl)
library(ggplot2)
library(lubridate)
library(readr)

# Note: dates covered: July 2024 - June 2025

# Cat 1: inhalers
# Cat 2: Anti-anxiety meds
# Cat 3: Anti-depressants


####################
########### INHALERS
####################


#Read in BNF code file
inhalers_df <- read_excel("Data/inhalers_list.xlsx") 

dates <- list('2024-07-01', '2024-08-01', '2024-09-01', '2024-10-01', '2024-11-01', '2024-12-01',
           '2025-01-01', '2025-02-01', '2025-03-01', '2025-04-01', '2025-05-01', '2025-06-01')

inhaler_codelist <- unique(inhalers_df$bnf_presentation_code)


full_inhaler_list <- list()


read_presc_function <- function(codes){
  
  full_list <- list()
  
  for (i in 1:length(codes)){
    
    minilist <- list()
    
    for (x in 1:length(dates)){
      
      single_df <- read_csv(paste0("https://openprescribing.net/api/1.0/spending_by_org/?org_type=practice&code=", codes[[i]], "&date=", dates[[x]],"&format=csv"),
                            col_types = list(ccg = col_character(),
                                             row_id = col_character(),
                                             row_name = col_character(),
                                             actual_cost = col_double(),
                                             items = col_double(),
                                             quantity = col_double(),
                                             setting = col_character(),
                                             date = col_date()
                            ))
      
      single_df$bnf_code <- codes[[i]]
      
      minilist <- append(minilist, list(single_df))
      
    }
    
    combined_df <- bind_rows(minilist)
    
    full_list <- append(full_list, list(combined_df))
    
  }
  
  return(full_list)
  
}
  
full_inhaler_list <- read_presc_function(codes = inhaler_codelist)

full_inhaler_df <- bind_rows(full_inhaler_list)

full_inhaler_df <- full_inhaler_df %>% select(!(X1:X8))


########################
########### ANTI ANXIETY
########################


#Read in BNF code file

full_antianx_list <- read_presc_function(codes = list('0401'))

antianx_df <- full_antianx_list[[1]]

############################
########### ANTI PSYCHOTICS
############################

#Read in BNF code file

full_antipsych_list <- read_presc_function(codes = list('0402'))

antipsych_df <- full_antipsych_list[[1]]

#############################
########### ANTI DEPRESSANTS
#############################

#Read in BNF code file

full_antidepress_list <- read_presc_function(codes = list('0403'))

antidepress_df <- full_antidepress_list[[1]]
