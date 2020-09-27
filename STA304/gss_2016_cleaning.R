

# CLEANING CODE FROM ROHAN ALEXANDER SLIGHTLY MODIFIED #
# THANK YOU TO ROHAN ALEXANDER FOR THIS CODE #


library(tidyverse)
library(janitor)

data <- read.csv("work_survey2.csv")  # data file from CHASS
labels_raw <- read_file("labels2.txt") # variable labels

labels_raw_tibble <- as_tibble(str_split(labels_raw, ";")[[1]]) %>% 
  filter(row_number()!=1) %>% 
  mutate(value = str_remove(value, "\nlabel define ")) %>% 
  mutate(value = str_replace(value, "[ ]{2,}", "XXX")) %>% 
  mutate(splits = str_split(value, "XXX")) %>% 
  rowwise() %>% 
  mutate(variable_name = splits[1], cases = splits[2]) %>% 
  mutate(variable_name = str_remove(variable_name, "\r")) %>%
  mutate(cases = str_replace_all(cases, "\n [ ]{2,}", "")) %>% 
  select(variable_name, cases) %>% 
  drop_na()
label_raw_tibble <- labels_raw_tibble %>% 
  mutate(splits = str_split(cases, "[ ]{0,}\"[ ]{0,}"))
add_cw_text <- function(x, y){
  if(!is.na(as.numeric(x))){
    x_new <- paste0(y, "==", x,"~")
  }
  else{
    x_new <- paste0("\"",x,"\",")
  }
  return(x_new)
}


cw_statements <- label_raw_tibble %>% 
  rowwise() %>% 
  mutate(splits_with_cw_text = list(modify(splits, add_cw_text, y = variable_name))) %>% 
  mutate(cw_statement = paste(splits_with_cw_text, collapse = "")) %>% 
  mutate(cw_statement = paste0("case_when(", cw_statement,"TRUE~\"NA\")")) %>% 
  mutate(cw_statement = str_replace(cw_statement, ",\"\",",",")) %>% 
  select(variable_name, cw_statement)

# selecting variables 
work_data <- data %>% select(agegr10, sex, prv, vismin, famincg2, mar_110, etu_01, etu_02gr, etu_03, etu_04) %>% mutate_at(vars(agegr10:etu_04), .funs = funs(ifelse(.>=96, NA, .))) %>% mutate_at(vars(agegr10:etu_04), .funs = funs(eval(parse(text = cw_statements %>% filter(variable_name==deparse(substitute(.))) %>% select(cw_statement) %>% pull()))))

# renaming variables

work_data  <-  work_data %>% 
  clean_names() %>% 
  rename(age_group = agegr10, sex = sex, province = prv, family_income = famincg2,  visibile_minority = vismin, main_activity = mar_110, likely_future_edu = etu_01, desired_future_edu = etu_02gr, obstacles = etu_03, obstacles_future_edu = etu_04)                                                   

work_data <- work_data %>% mutate_at(vars(age_group:obstacles_future_edu), .funs = funs(ifelse(.=="Valid skip"|.=="Refusal"|.=="Not stated", "NA", .))) 


student_data <- work_data %>% filter(main_activity == "Going to school") # focusing on students

# grouping the non-college programs together
student_data <- student_data %>% mutate(likely_future_edu =  ifelse(likely_future_edu == "Non-college trade certificate or registered apprenticeship" | likely_future_edu == "Private business school or commercial school - certificat..." | likely_future_edu == "Non-college business/commercial/trade certificate or dip...", "Non-college/Private/Commercial Certificate/Diploma", likely_future_edu))%>% mutate(desired_future_edu =  ifelse(desired_future_edu == "Non-college trade certificate or registered apprenticeship" | desired_future_edu == "Private business school or commercial school - certificat..." | desired_future_edu == "Non-college business/commercial/trade certificate or dip...", "Non-college/Private/Commercial Certificate/Diploma", desired_future_edu)) %>% mutate(likely_future_edu = str_replace(likely_future_edu, "Other - Specify", "Other")) %>%  mutate(desired_future_edu =  str_replace(desired_future_edu, "Other - Specify", "Other"))

write_csv(student_data, "student_data.csv")
