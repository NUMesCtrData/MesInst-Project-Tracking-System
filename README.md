# MesInst-Project-Tracking-System
A structured, multi-layered system for tracking research projects across the Mesulam Institute, from initial request through execution and participant-level documentation.  This system integrates **REDCap databases** with **R-based automation pipelines** to ensure transparency, compliance, and efficient coordination across teams.

**Purpose & Benefits**

  This system is designed to balance administrative oversight with operational flexibility.
  
  Key goals:
    Accurate reporting: Ensures all resource usage is documented for NIH and sponsors
    Transparency: Makes project activity visible across teams
    Efficiency: Reduces duplicated effort and unnecessary participant burden
    Accountability: Tracks how Institute resources are used
    Scalability: Supports multiple concurrent projects and collaborators
    
  Important note:
    Logging a project takes less than 5 minutes and is intentionally lightweight to avoid slowing down research progress.
    
  Key Design Principles
    Centralized intake, decentralized execution
    Separation of high-level tracking vs. granular workflows
    Automation where possible (R pipelines)
    Participant-level traceability
    Compliance-first design without heavy administrative burden

**1. Primary Intake & Oversight Database (Mesulam Institute Resource Sharing & Project Tracking REDCap Database)**

    This is the entry point for all projects involving Institute resources.
    
    Core functions:
      Captures all new project requests
      Serves as the official record for reporting and oversight
      Enables administrative review and approval workflows
    
    Data collected:
      Project title
      Project Lead and Principal Investigator (PI)
      Project description
      Requested resources (data, biospecimens, imaging, participants, etc.)
      Funding source and IRB status (if applicable)
    
    Governance:
      Every submission undergoes a completeness check by the ADRC Clinical Core Manager
      Ensures projects meet institutional and sponsor requirements before proceeding


**2. Secondary Team-Specific Tracking Database (Data Requests REDCap Database)** 

    Once a project is approved or underway, responsibility shifts to operational teams (e.g., data, biospecimen, imaging teams).
    
    Purpose:
      To track execution-level details that are too granular for the primary database.
    
    Key capabilities:
      Logs task progress (data pulls, sample processing, file generation)
      Tracks file storage locations and data delivery outputs
      Documents timelines and internal workflows
      Maintains audit trails for reproducibility and accountability
    
    Why this layer matters:
      Separates high-level project oversight from day-to-day operations
      Allows each team to customize tracking based on their workflows
      Improves efficiency without cluttering the main database

   
**3. Integration Pipeline (Updates Resource Tracking, Data Requests, and UDS REDCap Databases)**

    A partially automated pipeline (built with R scripts) that has 3 functions:
      1. Creates a new team-specific project in the Data Requests database.
      2. Upon project completion, logs data file and data dictionary in the Mesulam Institute Resource Sharing & Project Tracking REDCap Database.
      3. Links project activity back to individual participant records.
    
    Impact:
      Creates a participant-level audit trail
      Supports downstream reporting, compliance, and longitudinal tracking
      Helps prevent overuse or duplication of participant data

