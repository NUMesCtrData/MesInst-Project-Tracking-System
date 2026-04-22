# MesInst-Project-Tracking-System
A structured, multi-layered system for tracking research projects across the Mesulam Institute, from initial request through execution and participant-level documentation.  This system integrates **REDCap databases** with **R-based automation pipelines** to ensure transparency, compliance, and efficient coordination across teams.

🏗️ System Architecture

The workflow is built around three connected components, each serving a distinct purpose:

1. Primary Intake & Oversight Database

Name: Mesulam Institute Resource Sharing & Project Tracking REDCap Database

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
2. Secondary Team-Specific Tracking Databases

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
3. UDS REDCap Integration Pipeline

A partially automated pipeline (built with R scripts) links project activity back to individual participant records.

Function:

Transfers general information about participant inclusion in projects into their UDS (Uniform Data Set) REDCap records

What gets recorded:

Whether a participant’s data/samples were used in a project
Associated project identifiers or metadata

Impact:

Creates a participant-level audit trail
Supports downstream reporting, compliance, and longitudinal tracking
Helps prevent overuse or duplication of participant data
🔄 End-to-End Workflow
Project Initiation
Researcher submits a project in the primary REDCap database
Administrative Review
ADRC Clinical Core Manager verifies completeness and compliance
Project Execution
Relevant teams log detailed work in their respective tracking databases
Data Integration
R-based pipeline updates participant-level UDS records with project involvement
Ongoing Monitoring & Reporting
System supports NIH/sponsor reporting, internal audits, and coordination across teams
🎯 Purpose & Benefits

This system is designed to balance administrative oversight with operational flexibility.

Key goals:
Accurate reporting: Ensures all resource usage is documented for NIH and sponsors
Transparency: Makes project activity visible across teams
Efficiency: Reduces duplicated effort and unnecessary participant burden
Accountability: Tracks how Institute resources are used
Scalability: Supports multiple concurrent projects and collaborators
📝 Logging Requirements

Any project that could result in:

Manuscripts
Abstracts
Posters
Presentations
Grant applications

must be logged if it uses Mesulam Institute resources.

Important note:
Logging a project takes less than 5 minutes and is intentionally lightweight to avoid slowing down research progress.

🧩 Key Design Principles
Centralized intake, decentralized execution
Separation of high-level tracking vs. granular workflows
Automation where possible (R pipelines)
Participant-level traceability
Compliance-first design without heavy administrative burden
