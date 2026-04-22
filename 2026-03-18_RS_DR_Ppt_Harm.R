# IMPORTANT: Turn on the outline for navigating through this program.
# Press the grey button in the upper right of the editor pan with 5 
# offset dark-grey lines to show/hide the outline. 

# Program Information: ----
# This program pulls data from the Resource Sharing database and creates a new
# data request. If a data request is complete, information about the data shared
# is put back into the Resource Sharing database. The participant records for 
# anyone included in the data is also updated with their Project ID to track which
# participants have been in published papers and projects. 

# Clear Environment
rm(list=ls())

# Update and import the Data Request REDcap database?
update_DataRequest_REDCap = F
import_DataRequest_REDCap = F

# Update and import the Resource Sharing REDcap database?
update_ResShare_REDCap = F
import_ResShare_REDCap = F

# Update and import the ADRC UDS4 REDcap database?
update_UDS4_REDCap = F
import_UDS4_REDCap = F

# Enter EITHER a REDCap data request ID (dr_id) to obtain the data request
# name from REDCap or directly enter the data request name below
dr_id = 1574
data_request_name = NULL

# Packages and Pathways: ----

# Load Packages:
library(tidyverse)
library(redcapAPI)
library(writexl)
library(readxl)
library(janitor)
if ("plyr" %in% (.packages())){detach("package:plyr")}
if ("reshape" %in% (.packages())){detach("package:reshape")}

# Determine if the current machine running this program is a mac or a pc
# Identify the one drive and the Mesulam Share Point 
# location on the current machine to output files. 

# Windows:
if (Sys.info()[['sysname']]=="Windows"){
  netid = Sys.info()["user"]
  # identify the one drive path for the above user:
  od_loc = paste("C:/Users/",netid,"/OneDrive - Northwestern University/", sep="")
}
# Mac:
if (Sys.info()[['sysname']]=="Darwin"){
  netid = Sys.info()["user"]
  # identify the one drive path for the above identified user:
  od_loc = paste("/Users/",netid,"/OneDrive - Northwestern University/", sep="")
}

setwd(od_loc)

# Read in REDCap Token information saved on OneDrive to access REDCap API
# Add SOP Saved on Share Point: 
source(paste(od_loc, "redcap_api_info.R", sep=""))

#___________________________________________

# File locations:----

# If a dr_id, is provided, grab the filename of the
# current project to create the data request folder in the 
# Data Request Share Point Folder. 

if (!is.null(dr_id)){
  # Specify static parameters for REDCap API pull:
  formData <- list("token" = dr_token,
                   content='record',
                   format='csv',
                   type='flat',
                   'records[0]'=dr_id,
                   returnFormat='csv')
  # List all fields, forms, and events to be pulled from REDCap:
  fields = c("record_id", "rqst_file_name", "rqst_collab_app_id")
  forms = NULL
  events = NULL
  # Add fields, forms, events to the "formData" parameters list. 
  load_fields_forms_events(fields, forms, events)
  # Pull Data According to the parameters of "formData"
  response <- httr::POST(url, body = formData, encode = "form")
  dr_filename <- httr::content(response, col_types = cols(.default = "c"))
  
  data_request_name = dr_filename$rqst_file_name[1]
}

# Based on the file name, create the below locations to be used
# through out the R script for inputting and outputting data files

data_rqst_loc = paste(od_loc, "MC Data Management/Data Requests/", sep="")
request_loc = paste(data_rqst_loc,data_request_name, "/", sep="")
resshare_data_loc = paste(request_loc,data_request_name, "_Data/", sep="")
program_loc = paste(request_loc, "Program/", sep="")
input_loc = paste(program_loc, "Input/", sep="")
output_loc = paste(program_loc, "Output/", sep="")
datafreeze_loc = paste(output_loc, "DataFreeze/", sep="")
ripple_loc = paste(od_loc, "MC Data Management/Ripple/Ripple Data Exports/",
                   sep="")
funct_loc = paste(od_loc, "MC Data Management/R Functions/",
                  sep="")
nacc_loc = paste(od_loc, "MC Data Management/NACC Data/",
                   sep="")

# If a data request folder does not already exist for this project, 
# create one. 

# Create Request Folders
if (file.exists(request_loc)) {
  cat("The folder already exists")
} else {
  dir.create(request_loc)
  dir.create(program_loc)
  dir.create(input_loc)
  dir.create(output_loc)
  dir.create(datafreeze_loc)
  if (!is.na(dr_filename$rqst_collab_app_id[1])) {
    dir.create(resshare_data_loc)
  }
}



# Raw Data ----

# API Pull: 

# Read in data from REDCap through the API. Tokens obtained from
# reading in the tokens from redcap_api_info

## UDS4 ----

# Specify static parameters for REDCap API pull:
formData <- list("token" = uds4_token,
                 content='record',
                 format='csv',
                 type='flat',
                 csvDelimiter='',
                 rawOrLabel='raw',
                 rawOrLabelHeaders='raw',
                 exportCheckboxLabel='false',
                 exportSurveyFields='true',
                 exportDataAccessGroups='false',
                 returnFormat='csv'
)
# List all fields, forms, and events to be pulled from REDCap:
fields = c("global_id","resshare_project_ids")
forms = NULL
events = "tracking_arm_1"
# Add fields, forms, events to the "formData" parameters list. 
load_fields_forms_events(fields, forms, events)
# Pull Data According to the parameters of "formData"
response <- httr::POST(url, body = formData, encode = "form")
redcap_uds4 <- httr::content(response, col_types = cols(.default = "c"))

# save a copy of the raw REDCap data used in the request:
# write.csv(redcap_uds4, paste0(datafreeze_loc, "REDCapUDS4_Raw_DataFreeze",Sys.Date(),".csv"), 
#           row.names = F)

## ResShare RC ----

# Data Dictionary 
formData <- list("token"=resshare_token,
                 content='metadata',
                 format='csv',
                 returnFormat='csv'
)
response <- httr::POST(url, body = formData, encode = "form")
dict_resshare <- httr::content(response, col_types = cols(.default = "c")) 

# Specify static parameters for REDCap API pull:
formData <- list("token" = resshare_token,
                 content='record',
                 format='csv',
                 type='flat',
                 csvDelimiter='',
                 rawOrLabel='raw',
                 rawOrLabelHeaders='raw',
                 exportCheckboxLabel='false',
                 exportSurveyFields='true',
                 exportDataAccessGroups='false',
                 returnFormat='csv'
)
# List all fields, forms, and events to be pulled from REDCap:
fields = c("id", "exec_dec", "exec_dec_date", "study_contact", "lead", "lead_email",
           "study_contact_email", "pi", "cnadc_collaborator_name", "affiliates", 
           "study_description", "cnadc_resources", "data_needed", 
           "pi_sig", "pi_sig_date", "decision_letter_complete", "study_status",
           dict_resshare$field_name[dict_resshare$form_name=="data_sent"])
forms = NULL
events = NULL
# Add fields, forms, events to the "formData" parameters list. 
load_fields_forms_events(fields, forms, events)
# Pull Data According to the parameters of "formData"
response <- httr::POST(url, body = formData, encode = "form")
redcap_resshare <- httr::content(response, col_types = cols(.default = "c"))

# save a copy of the raw REDCap data used in the request:
# write.csv(redcap_resshare, paste0(datafreeze_loc, "REDCapResShare_Raw_DataFreeze",Sys.Date(),".csv"), 
#           row.names = F)


## Data Requests RC ----

# Data Dictionary 
formData <- list("token"=dr_token,
                 content='metadata',
                 format='csv',
                 returnFormat='csv'
)
response <- httr::POST(url, body = formData, encode = "form")
dict_dr <- httr::content(response, col_types = cols(.default = "c")) 

# Specify static parameters for REDCap API pull:
formData <- list("token" = dr_token,
                 content='record',
                 format='csv',
                 type='flat',
                 csvDelimiter='',
                 rawOrLabel='raw',
                 rawOrLabelHeaders='raw',
                 exportCheckboxLabel='false',
                 exportSurveyFields='true',
                 exportDataAccessGroups='false',
                 returnFormat='csv'
)
# List all fields, forms, and events to be pulled from REDCap:
fields = c("record_id", "rqst_date", "rqst_name", "rqst_email", "rqst_involved",
           "rqst_type", "rqst_collab_app_id", "cnadc_resources", "study_description",
           "rqst_file_name", "rqst_folder_link", "sent_folder_link", "data_link", 
           "data_dict_link", "vars", "rqst_short_descript",
           "data_sent_date", "rqst_ovstatus", "data_request_complete")
forms = NULL
events = NULL
# Add fields, forms, events to the "formData" parameters list. 
load_fields_forms_events(fields, forms, events)
# Pull Data According to the parameters of "formData"
response <- httr::POST(url, body = formData, encode = "form")
redcap_dr <- httr::content(response, col_types = cols(.default = "c"))

# save a copy of the raw REDCap data used in the request:
# write.csv(redcap_dr, paste0(datafreeze_loc, "REDCapDataRequests_Raw_DataFreeze",Sys.Date(),".csv"), 
#           row.names = F)







# Begin Harmonization ----



## 1. Data Request Update ----

if(update_DataRequest_REDCap == T){
  
  import_rs_to_dr <- redcap_resshare %>%
    # Include ResShare Projects that are approved or approved with stipulations, 
    # and approval occurred on or after 02/01/26. 
    filter(exec_dec_date >= "2026-02-01" & exec_dec %in% c("app","stip")) %>%
    # Select the necessary columns and rename those that directly correspond
    # with a variable in the data request database. 
    select(id, exec_dec_date, lead, lead_email, study_contact, study_contact_email,
         cnadc_collaborator_name, pi, affiliates, cnadc_resources, 
         study_description, contains("data_needed")) %>%
    rename(rqst_collab_app_id=id,
           rqst_name=lead,
           rqst_email=lead_email) %>%
    # PI, CNADC Collaborator Name, and Affiliates will be pasted together for 
    # the data request database variable 'rqst_involved'. 
    mutate(pi = paste0("PI: ", pi)) %>%
    mutate(study_contact = paste0("Study Contact: ", study_contact)) %>%
    mutate(cnadc_collaborator_name = paste0("MesInst Collaborator: ", 
                                          cnadc_collaborator_name)) %>%
    unite(rqst_involved, pi, study_contact, cnadc_collaborator_name, affiliates, sep="\n", na.rm=T) %>%
    # All of these request types are 'ca' (Collaborative Application)
    mutate(rqst_type = "ca") %>%
    # Join the new ResShare projects with any existing data requests by the 
    # Data Request record_id and the ResShare rqst_collab_app_id. 
    left_join(redcap_dr[c("record_id", "rqst_date", "rqst_collab_app_id", 
                          "rqst_short_descript", "data_request_complete")]) %>%
    relocate(record_id, .before=rqst_collab_app_id) %>%
    ### Create record_id - New Data Requests ----
    # Generate record_id for new data requests - next number following the max 
    # record_id from the data request db data. 
    mutate(record_id = as.numeric(record_id)) %>%
    mutate(max_record_id = as.numeric(max(as.numeric(redcap_dr$record_id))), .after=record_id) %>%
    arrange(match(record_id, c(is.na(record_id), !is.na(record_id))), as.Date(rqst_date)) %>%
    mutate(record_id = case_when(
      is.na(record_id) ~ max_record_id + as.numeric(row_number()),
      T ~ record_id)) %>%
    # Assign rqst_date equal to exec_dec_date unless a date already exists. 
    mutate(rqst_date = case_when(
      is.na(rqst_date) ~ exec_dec_date,
      T ~ rqst_date)) %>%
    select(-max_record_id, -exec_dec_date) %>%
    # Prepare the rqst_short_descript with the ResShare Project ID. This will 
    # need to be updated manually in the data request database to finalize the filename.
    # Do not overwrite rqst_short_descript if it already exists. 
    mutate(rqst_short_descript = case_when(
      is.na(rqst_short_descript) ~ paste0("RS",sprintf("%04s",rqst_collab_app_id),"_[enter PI last name]"),
      T ~ rqst_short_descript)) %>%
    # If data_request_complete is blank, set it equal to '1' (Unverified). If the 
    # data request exists and data_request_complete is not blank, leave it alone. 
    mutate(data_request_complete = case_when(
      is.na(data_request_complete) ~ "1",
      T ~ data_request_complete))

  if(nrow(import_rs_to_dr)>0){
    
    # Lengthen the data and compare to the existing values in the data request. 
    # Export a file with any values that are being overwritten for record keeping. 
    new_dr_values_long <- import_rs_to_dr %>%
      pivot_longer(2:ncol(.), names_to = "dr_variable", values_to = "new_dr_value") %>%
      mutate_all(~as.character(.))
    
    existing_dr_values_long <- redcap_dr %>%
      pivot_longer(2:ncol(.), names_to = "dr_variable", values_to = "overwritten_dr_value") 
    
    overwritten_dr <- new_dr_values_long %>%
      left_join(existing_dr_values_long) %>%
      filter(new_dr_value != overwritten_dr_value)
    
    if(nrow(overwritten_dr)>0){
      write.csv(overwritten_dr, paste0(output_loc,Sys.Date(),"_Overwritten_DR.csv"), row.names = FALSE) 
    }
    
    # Export the file that will be imported into the Data Request REDCap database. 
    write.csv(import_rs_to_dr, paste0(output_loc,Sys.Date(),"_RS_to_DR_Import.csv"), row.names = FALSE) 
  }

### IMPORT [Data Request RC] ----
  if (import_DataRequest_REDCap==T){
    
    rcon <- redcapConnection(
      url='https://redcap.nubic.northwestern.edu/redcap/api/',
      token=dr_token) 
    
    if(nrow(import_rs_to_dr)>0){
      redcapAPI::importRecords(
        rcon,
        import_rs_to_dr,
        overwriteBehavior = c("normal"),
        returnContent = c("count"),
        returnData = FALSE,
        logfile = "")  
    }
  }
}

  




## 2. Resource Sharing Update ----

if(update_DataRequest_REDCap == T){
  
  import_dr_to_rs <- redcap_dr %>%
    # Include Data Requests of type 'ca' that have an overall status of 'Complete'. 
    filter(rqst_type == "ca" & rqst_ovstatus == "Complete") %>%
    select(rqst_date, rqst_collab_app_id, record_id, rqst_folder_link, 
           sent_folder_link, data_link, data_sent_date, data_dict_link, vars) %>%
    rename(id=rqst_collab_app_id, dr_id=record_id) %>%
    mutate(global_ids=NA, vars=NA) %>%
    # If there are any Data Requests that are tied to multiple ResShare projects, 
    # lengthen the ids to get each one on a new row with all data attached. 
    separate(id, into=c("id1","id2","id3","id4"), sep=",") %>%
    pivot_longer(id1:id4, names_to="project_num", values_to="id") %>%
    filter(!is.na(id)) %>%
    relocate(id, .before=dr_id) %>%
    filter(rqst_date >= as.Date("2026-02-01")) %>%
    select(-project_num, -rqst_date)
  
  # Create a for-loop that goes through each Data Request folder and pulls the 
  # crosswalk file to get the global ids and resource sharing ids. 
  i = 1
  for (i in 1:nrow(import_dr_to_rs)){
    
    # Obtain the Data Request Folder filename.
    temp_dr_file_name <- redcap_dr$rqst_file_name[import_dr_to_rs$dr_id[i]==redcap_dr$record_id]
    temp_dr_file_name
    # Obtain the Data Request Folder filepath.
    temp_dr_filepath <- paste0(data_rqst_loc, temp_dr_file_name)
    temp_dr_filepath
    
    # List all files in the Data Request Folder
    temp_directory <- as.data.frame(table(list.files(temp_dr_filepath), dnn=list("filename")))
  
    # If there is a file with the name 'CW', open the file and obtain all global ids.
    if(any(str_detect(temp_directory$filename, "CW"))){
      
      temp_cw <- read.xlsx(paste0(temp_dr_filepath, "/", temp_directory$filename[str_detect(temp_directory$filename, "CW")]))                       
      
      temp_global_ids <- temp_cw %>%
        select(global_id) %>%
        distinct() 
      
      # Mutate the import_dr_to_rs dataframe and add all global ids from the crosswalk file. 
      import_dr_to_rs$global_ids[i] <- paste(temp_global_ids$global_id, collapse=", ")
    }
  }
  
  if(nrow(import_rs_to_dr)>0){
    
    # Lengthen the data and compare to the existing values in the resshare db. 
    # Export a file with any values that are being overwritten for record keeping. 
    new_rs_values_long <- import_dr_to_rs %>%
      pivot_longer(2:ncol(.), names_to = "rs_variable", values_to = "new_rs_value") %>%
      mutate_all(~as.character(.))
    
    existing_rs_values_long <- redcap_resshare %>%
      pivot_longer(2:ncol(.), names_to = "rs_variable", values_to = "overwritten_rs_value") 
    
    overwritten_rs <- new_rs_values_long %>%
      left_join(existing_rs_values_long) %>%
      filter(new_rs_value != overwritten_rs_value)
    
    if(nrow(overwritten_dr)>0){
      write.csv(overwritten_dr, paste0(output_loc,Sys.Date(),"_Overwritten_DR.csv"), row.names = FALSE) 
    }
    
    # Export the file that will be imported into the Resource Sharing REDCap database. 
    write.csv(import_dr_to_rs, paste0(output_loc,Sys.Date(),"_DR_to_RS_Import.csv"), row.names = FALSE) 
  }
  
  ### IMPORT [Resource Sharing RC] ----
  if (import_DataRequest_REDCap==T){
    
    rcon <- redcapConnection(
      url='https://redcap.nubic.northwestern.edu/redcap/api/',
      token=resshare_token) 
    
    if(nrow(import_rs_to_dr)>0){
      redcapAPI::importRecords(
        rcon,
        import_rs_to_dr,
        overwriteBehavior = c("normal"),
        returnContent = c("count"),
        returnData = FALSE,
        logfile = "")  
    }
  }
}
  




## 3. Participant Record (UDS4) Update ----

if(update_UDS4_REDCap == T){
  
  projects_uds4_ppts <- redcap_dr %>%
    # Include Data Requests of type 'ca' that have an overall status of 'Complete'. 
    filter(rqst_type == "ca" & rqst_ovstatus == "Complete") %>%
    select(rqst_collab_app_id, record_id, rqst_folder_link, sent_folder_link,
           data_link, data_sent_date) %>%
    rename(id=rqst_collab_app_id, dr_id=record_id) %>%
    # If there are any Data Requests that are tied to multiple ResShare projects, 
    # lengthen the ids to get each one on a new row with all data attached. 
    separate(id, into=c("id1","id2","id3","id4"), sep=",") %>%
    pivot_longer(id1:id4, names_to="project_num", values_to="id") %>%
    filter(!is.na(id)) %>%
    relocate(id, .before=dr_id) %>%
    select(-project_num) %>%
    left_join(redcap_resshare[c("id","study_status")]) %>%
    mutate(study_status = case_when(
      study_status == "actv" ~ "(Active)", 
      study_status == "comp" ~ "(Completed)",
      study_status == "exp" ~ "(Expired before completion)",
      study_status == "wthdr" ~ "(Withdrawn)",
      study_status == "pend" ~ "(Approved, pending PI signature)"))
  
  # Create a for-loop that goes through each Data Request folder and pulls the 
  # crosswalk file to get the global ids and resource sharing ids. 
  i = 1
  import_uds4_ppts_long <- NULL
  for (i in 1:nrow(projects_uds4_ppts)){
    
    # Obtain the ResShare study_status.
    temp_status <- projects_uds4_ppts$study_status[i]
    # Obtain the Data Request Folder filename.
    temp_dr_file_name <- redcap_dr$rqst_file_name[projects_uds4_ppts$dr_id[i]==redcap_dr$record_id]
    temp_dr_file_name
    # Obtain the Data Request Folder filepath.
    temp_dr_filepath <- paste0(data_rqst_loc, temp_dr_file_name)
    temp_dr_filepath
    
    # List all files in the Data Request Folder
    temp_directory <- as.data.frame(table(list.files(temp_dr_filepath), dnn=list("filename")))
    
    # If there is a file with the name 'CW', open the file and obtain all global ids.
    if(any(str_detect(temp_directory$filename, "CW"))){
      
      temp_cw <- read.xlsx(paste0(temp_dr_filepath, "/", temp_directory$filename[str_detect(temp_directory$filename, "CW")])) %>%
        mutate(study_status = temp_status)
      
      if(is.null(import_uds4_ppts_long)){
        import_uds4_ppts_long <- temp_cw
      }else{
        import_uds4_ppts_long <- import_uds4_ppts_long %>%
          full_join(temp_cw)
      }
    }
  }
  
  # After obtaining all crosswalk ids, prepare them for import. 
  import_uds4_ppts <- import_uds4_ppts_long %>%
    arrange(global_id, Project_ID) %>%
    group_by(global_id) %>%
    mutate(resshare_project_ids = paste(unique(Project_ID[!is.na(Project_ID)]), 
                                               unique(study_status[!is.na(study_status)]), collapse ="\n")) %>%
    select(global_id, resshare_project_ids) %>%
    distinct() %>%
    mutate(redcap_event_name = "tracking_arm_1", .after=global_id)
  
  if(nrow(import_uds4_ppts)>0){
    
    # Lengthen the data and compare to the existing values in the UDS4 database. 
    # Export a file with any values that are being overwritten for record keeping. 
    new_uds4_values_long <- import_uds4_ppts %>%
      pivot_longer(2:ncol(.), names_to = "uds4_variable", values_to = "new_uds4_value") %>%
      mutate_all(~as.character(.))
    
    existing_uds4_values_long <- redcap_uds4 %>%
      pivot_longer(2:ncol(.), names_to = "uds4_variable", values_to = "overwritten_uds4_value") 
    
    overwritten_uds4 <- new_uds4_values_long %>%
      left_join(existing_uds4_values_long) %>%
      filter(new_uds4_value != overwritten_uds4_value)
    
    if(nrow(overwritten_uds4)>0){
      write.csv(overwritten_uds4, paste0(output_loc,Sys.Date(),"_Overwritten_UDS4.csv"), row.names = FALSE) 
    }
    
    # Export the file that will be imported into the UDS4 REDCap database. 
    write.csv(import_uds4_ppts, paste0(output_loc,Sys.Date(),"_UDS4_Ppts_Import.csv"), row.names = FALSE) 
  }
  
  ### IMPORT [UDS4 RC] ----
  if (import_UDS4_REDCap==T){
    
    rcon <- redcapConnection(
      url='https://redcap.nubic.northwestern.edu/redcap/api/',
      token=uds4_token) 
    
    if(nrow(import_uds4_ppts)>0){
      redcapAPI::importRecords(
        rcon,
        import_uds4_ppts,
        overwriteBehavior = c("normal"),
        returnContent = c("count"),
        returnData = FALSE,
        logfile = "")  
    }
  }
}















































