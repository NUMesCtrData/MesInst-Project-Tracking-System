**Resource Sharing, Data Request, UDS4 REDCap Database Harmonization (Integration Pipeline)**

This program pulls data from the Resource Sharing (RS), Data Request (DR), and UDS4 REDCap databases. The data is harmonized between the three databases and imported as needed. 

1.	Newly approved projects in the Resource Sharing will be added to the Data Request database with a new record_id. The approval date, researcher information, and general project details will be added to the new data request. For existing data requests, these fields will be updated without the essential fields being overwritten (the program will never overwrite record_id, rqst_date, rqst_short_descript, or data_request_complete status). 

2.	After completion of the Data Request, the information and data folder/file links of the project will be pulled and added to the Resource Sharing ‘Data Sent’ form. The program will locate the project Crosswalk file and add all participants to the global_ids field in the Resource Sharing database.

3.	After completion of the Data Request, the program will pull the study_status of the project from the Resource Sharing database and match it to the specific global_ids present in the crosswalk. Each participant’s record in the UDS4 database will be updated with their Project_ID and the study_status. This data will be uploaded to the resshare_project_ids field in the UDS4 database.

Requirements: 

•	You must have API access to the Resource Sharing, Data Request, and UDS4 REDCap databases to run this script. Alternatively, you can export the data from the three databases and read-in the raw files. 

Variable Crosswalk

The file below provides information on the fields required for the harmonization script. 

Variable Crosswalk.xlsx

1.	Obtain Raw Data (REDCap)
-	Use the REDCap API to pull the data from the Resource Sharing, Data Request, and UDS4 databases.
-	RS variables: "id", "exec_dec", "exec_dec_date", "study_contact", "lead", "lead_email", "study_contact_email", "pi", "cnadc_collaborator_name", "affiliates", "study_description", "cnadc_resources", "data_needed", "pi_sig", "pi_sig_date", "decision_letter_complete", "study_status", all variables from the ‘Data Sent' form
-	DR variables: "record_id", "rqst_date", "rqst_name", "rqst_email", "rqst_involved", "rqst_type", "rqst_collab_app_id", "cnadc_resources", "study_description", "rqst_file_name", "rqst_folder_link", "sent_folder_link", "data_link",  "data_dict_link", "vars", "rqst_short_descript", "data_sent_date", "rqst_ovstatus", "data_request_complete"
-	UDS4 variables: "global_id","resshare_project_ids"


2.	Resource Sharing to Data Request Import
- From the RS REDCap pull, filter the data to include projects that have an executive decision date on or after 2/1/2026 and an executive decision of approved or approved with stipulations. 
- Select the necessary variables that will be imported into the data request database and rename any variables with different names but equivalent meaning (refer to the Variable Crosswalk above).
- Collapse all persons associated with the project into a single variable ‘rqst_involved’. 
- Make the rqst_type = ‘ca’ for collaborative application. 
- Join the following variables from the DR REDCap: record_id, rqst_date, rqst_collab_app_id, rqst_short_descript, and data_request_complete. 
- If data exists in the DR REDCap, it will be pulled in. In the creation of new values for the above variables, no data will be overwritten if it already exists. 
- Create the record_id by taking the overall last record_id value from the DR dataframe. Add new values to the last record_id in order of exec_dec_date. 
- Ex: last record_id=1559. There are 3 new resshare projects, with the new record_ids will be 1560, 1561, and 1562 in order of exec_dec_date.
- Start a rqst_short_descript by using the following format:
- Ex: RS0123_[enter PI last name]
- This will be manually edited by the person working on pulling the data in the Data Request database to add the PI last name and any additional summary information for the pull. 
- Make the data_request_complete status equal to 1 (incomplete) if a status does not already exist.
- Lengthen all new and pre-existing data for the DR REDCap and compare. Export all overwritten values before importing the new data to the DR REDCap. 

3.	Data Request to Resource Sharing Import
- From the DR REDCap pull, filter the data to include projects with a rqst_type of ‘ca’ that have a rqst_ovstatus of ‘Complete’. 
- Select the necessary variables that will be imported into the RS database and rename any variables with different names but equivalent meaning (refer to the Variable Crosswalk above). 
- Create empty columns ‘global_ids’ and ‘vars’. 
- If any Data Requests are comprised of multiple Resource Sharing projects, separate the ids and create a new row for each id. 
- Filter the data to include Data Requests started on or after 2/1/2026. 
- Crosswalk extraction via For-loop:
- For each remaining project from the DR REDCap after completing the above steps, find the filename and filepath for the specific project. Pull the directory of the main Data Request Folder in SharePoint. 
- If a file exists that has the letters ‘CW’, open that file. This should be the crosswalk that lists all global_ids and their associated Project_ID. 
- Make a list of all global_ids in the crosswalk and add that list to the global_ids variable in the RS dataframe. 
- Lengthen all new and pre-existing data for the RS REDCap and compare. Export all overwritten values before importing the new data to the RS REDCap. 

4.	Resource Sharing Projects to UDS4 Participant Records Import
- From the DR REDCap pull, filter the data to include projects with a rqst_type of ‘ca’ that have a rqst_ovstatus of ‘Complete’. 
- Select the necessary variables that will be imported into the RS database and rename any variables with different names but equivalent meaning (refer to the Variable Crosswalk above). 
- Create empty columns ‘global_ids’ and ‘vars’. 
- If any Data Requests are comprised of multiple Resource Sharing projects, separate the ids and create a new row for each id. 
- For completed projects, join the id and study_status from the RS redcap data. 
- Crosswalk extraction via For-loop:
- For each remaining project from the DR REDCap after completing the above steps, find the filename and filepath for the specific project. Pull the directory of the main Data Request Folder in SharePoint. 
- If a file exists that has the letters ‘CW’, open that file. This should be the crosswalk that lists all global_ids and their associated Project_ID. 
- Create the dataframe import_uds4_ppts_long that joins together all crosswalks from all data requests, joining each one onto the others. 
- Collapse the Project_IDs and statuses of projects so that each global_id is one row with all information ready to be imported into a notes box in the UDS4 REDCap. 
- Lengthen all new and pre-existing data for the UDS4 REDCap and compare. Export all overwritten values before importing the new data to the UDS4 REDCap. 

