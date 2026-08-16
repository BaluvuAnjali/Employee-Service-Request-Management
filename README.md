### ***Employee Service Request Management***



***An end-to-end SAP ABAP project for managing employee requests for IT equipment such as laptops, monitors, keyboards, mice, headsets and other materials.***



***The project covers request creation, business validation, duplicate request prevention, request status tracking, status history, CDS-based data modelling, OData V4 service exposure and Fiori Elements-based request monitoring.***





#### ***About the Project***



***In an organization, employees may need to request IT equipment or replacement materials. If these requests are handled manually, it can become difficult to track their status, identify duplicate requests and monitor the overall request lifecycle.***



***I developed this project to model that process inside SAP using ABAP.***



***The application stores employee request information in custom SAP database tables and processes the request through different stages.***



***The request lifecycle is:***



***Submitted → Validated → Processing → Fulfilled***



***The application also maintains a separate status history so that previous status changes can be viewed later.***





#### ***Project Highlights***



* ***Employee IT equipment request management***
* ***Request creation using ABAP***
* ***Automatic Request ID generation***
* ***Employee and material validation***
* ***Duplicate active-request prevention***
* ***Request priority handling***
* ***Required-date validation***
* ***Request status management***
* ***Complete status history***
* ***Reusable ABAP business logic***
* ***ABAP monitoring reports***
* ***CDS Views***
* ***OData V4 service exposure***
* ***Fiori Elements request overview***
* ***Fiori Elements status history***
* ***Test programs for different scenarios***
* ***Git and GitHub version control***



#### ***Request Workflow***



***The overall application flow is:***



&#x20;               ***Employee Request***

&#x20;                      ***|***

&#x20;                      ***v***

&#x20;               ***Input Validation***

&#x20;                      ***|***

&#x20;                      ***v***

&#x20;                ***Duplicate Check***

&#x20;                      ***|***

&#x20;             ***+--------+--------+***

&#x20;             ***|                 |***

&#x20;         ***Duplicate          No Duplicate***

&#x20;             ***|                 |***

&#x20;             ***v                 v***

&#x20;       ***Request Blocked    Request Created***

&#x20;                               ***|***

&#x20;                               ***v***

&#x20;                          ***Submitted***

&#x20;                               ***|***

&#x20;                               ***v***

&#x20;                          ***Validated***

&#x20;                               ***|***

&#x20;                               ***v***

&#x20;                          ***Processing***

&#x20;                               ***|***

&#x20;                               ***v***

&#x20;                          ***Fulfilled***



***The request status history is maintained separately so that the complete lifecycle can be monitored.***



***Example:***



***Request 100004***



***Submitted***

&#x20;   ***|***

&#x20;   ***v***

***Validated***

&#x20;   ***|***

&#x20;   ***v***

***Processing***

&#x20;   ***|***

&#x20;   ***v***

***Fulfilled***





#### ***Request Creation***



***A request can be created with the following information:***



***Employee ID***

***Request type***

***Priority***

***Material ID***

***Quantity***

***Reason***

***Required date***



***The system generates a unique Request ID and stores the request information in the relevant SAP tables.***





###### ***Example Request***



***Request ID      : 100005***

***Employee ID     : E9999***

***Request Type    : N***

***Priority        : N***

***Material ID     : HEADSET-001***

***Quantity        : 1***

***Reason          : NEW HEADSET REQUIRED***

***Request Date    : 15.08.2026***

***Required Date   : 20.08.2026***

***Status          : Submitted***

***Status Sequence : 0010***

***Changed By      : NAX\_1501231***



***After successful creation, the request becomes available for monitoring through the Fiori Elements interface.***



#### ***Duplicate Request Prevention***



***One of the main business validations implemented in the project is duplicate request prevention.***



***Before creating a request, the system checks whether the same employee already has an active request for the same material.***



***The following statuses are considered active:***



***Submitted***

***Validated***

***Processing***



***If an active request already exists, the new request is blocked.***



###### ***Example***



***Employee ID : E9999***

***Material ID : HEADSET-001***



***Existing Request : 100005***



***Result:***

***Duplicate active request detected***

***Request creation blocked***



***The ABAP program displays:***



***Duplicate active request already exists: 100005***



***This prevents an employee from unnecessarily creating multiple active requests for the same material.***





#### ***Request Status Tracking***





***The project maintains request status separately from the main request information.***



***Each status history record stores information such as:***



* ***Request ID***
* ***Status***
* ***Status date***
* ***Status sequence***
* ***Changed by***
* ***Comments***



###### ***Example Status History***



***Request ID : 100004***



***0010  Submitted***

&#x20;     ***↓***

***2000  Validated***

&#x20;     ***↓***

***2010  Processing***

&#x20;     ***↓***

***2020  Fulfilled***



***Example comments stored in the status history include:***



***Request submitted by employee***

***Request validated successfully***

***Request is being processed***

***Request fulfilled successfully***



***This allows the request lifecycle to be audited and monitored.***





#### ***SAP Database Layer***



***The project uses custom database tables to separate request information into logical areas.***



##### ***Database Tables***



###### ***SAP Object	Purpose***

***----------------------------------------------------------------------------------------***

***ZESR\_HDR	     Stores request header information***

***ZESR\_ITEM	     Stores request material, quantity and reason information***

***ZESR\_STATUS	     Stores request status history***

***ZESR\_FULLFILL	     Stores request fulfillment information***





###### ***Header Table***



***ZESR\_HDR***



***Stores information such as:***



* ***Request ID***
* ***Employee ID***
* ***Request type***
* ***Priority***
* ***Current status***
* ***Request date***
* ***Required date***



###### ***Item Table***



***ZESR\_ITEM***



***Stores request item information such as:***



* ***Request ID***
* ***Material ID***
* ***Quantity***
* ***Reason***



###### ***Status Table***



***ZESR\_STATUS***



***Stores:***



* ***Request ID***
* ***Status***
* ***Status sequence***
* ***Status date***
* ***Changed user***
* ***Comments***



###### ***Fulfillment Table***



***ZESR\_FULLFILL***



***Stores fulfillment-related information for completed requests.***



#### ***ABAP Dictionary Objects***



***The project contains custom Data Elements and Domains.***



###### ***Data Elements***



* ***ZESR\_DE\_EMP***
* ***ZESR\_DE\_PRIORITY***
* ***ZESR\_DE\_QTY***
* ***ZESR\_DE\_REASON***
* ***ZESR\_DE\_REQID***
* ***ZESR\_DE\_RTYPE***
* ***ZESR\_DE\_STATUS***



###### ***Domains***



* ***ZESR\_D\_EMP***
* ***ZESR\_D\_PRIORITY***
* ***ZESR\_D\_QTY***
* ***ZESR\_D\_REASON***
* ***ZESR\_D\_REQID***
* ***ZESR\_D\_RTYPE***
* ***ZESR\_D\_STATUS***



###### ***Structure***

***ZESR\_S\_OUTPUT***



***Purpose:***



***ESR Report Output Structure***



###### ***Table Type***

***ZESR\_T\_OUTPUT***



***Purpose:***



***ESR Output Table Type***



***These objects demonstrate the use of the ABAP Dictionary for defining reusable data structures and database-related types.***





#### ***ABAP Business Logic***



***The project contains a reusable ABAP class:***



***ZCL\_ESR\_REQUEST***



***The class contains request-related business logic.***



***One important operation implemented through the class is duplicate request validation.***



***The class is used to separate business logic from individual test or report programs.***



***Conceptually:***



***ABAP Program***

&#x20;    ***|***

&#x20;    ***v***

***ZCL\_ESR\_REQUEST***

&#x20;    ***|***

&#x20;    ***v***

***Business Validation***

&#x20;    ***|***

&#x20;    ***v***

***Database Check***



***This makes the validation logic reusable from different programs.***







#### ***Main ABAP Programs***





***The main application programs are:***



###### ***Program	                Purpose***

***-----------------------------------------------------------------------------***

***ZESR\_CREATE\_REQUEST	Creates a new employee service request***

***ZESR\_STATUS\_UPDATE	Updates request status***

***ZESR\_ALV\_REQUEST	Displays request information using ALV***

***ZESR\_ALV\_MONITOR	Monitors requests***

***ZESR\_STATUS\_HISTORY	Displays request status history***

***ZESR\_REQUEST\_DASHBOARD	Provides request management/monitoring output***



***Additional programs were created for testing different parts of the application.***





#### ***Test Programs***



***The repository contains test programs used during development and validation.***



* ***ZESR\_TEST\_CREATE***
* ***ZESR\_TEST\_DATA***
* ***ZESR\_TEST\_DETAILS***
* ***ZESR\_TEST\_DUPLICATE***
* ***ZESR\_TEST\_FULFILL***
* ***ZESR\_TEST\_ITEM\_INSERT***
* ***ZESR\_TEST\_PROCESS***
* ***ZESR\_TEST\_STATUS***
* ***ZESR\_TEST\_VALIDATE***



***These programs were used to test different stages of request processing.***





#### ***CDS Views***



***The project uses CDS Views to provide structured data for the service layer and Fiori Elements interface.***



###### ***Request Overview CDS***



***ZESR\_C\_REQUEST***



***Purpose:***



***ESR Request Overview***



***This CDS view combines request-related information for monitoring.***



***It exposes information such as:***



* ***Request ID***
* ***Employee ID***
* ***Request type***
* ***Priority***
* ***Status***
* ***Material***
* ***Quantity***
* ***Reason***
* ***Request date***
* ***Required date***



###### ***Status History CDS***

***ZESR\_C\_STATUS***



***Purpose:***



***ESR Request Status History***



***This CDS view provides the status history information required for monitoring.***





#### ***OData V4 Service***



***The project exposes the CDS-based application data through an OData V4 service.***



###### ***Service Definition***



***ZESR\_SD***



***Purpose:***



***ESR Request Management Service***



###### ***Service Binding***



***ZESR\_SB***



***Binding type:***



***OData V4 - UI***



***The service binding provides the Fiori Elements interface used for request monitoring.***





#### ***Fiori Elements Interface***



***The project uses Fiori Elements to provide a user-facing monitoring interface.***



***The Fiori Elements preview contains two main areas.***



###### ***Request Overview***



***The Request Overview displays:***



***Request ID***

***Employee ID***

***Request type***

***Priority***

***Status***

***Material ID***

***Quantity***

***Reason***

***Request date***

***Required date***



***Example requests tested in the system include:***



***100004***

***Employee : E9999***

***Material : MONITOR-001***

***Status   : Fulfilled***



***and***



***100005***

***Employee : E9999***

***Material : HEADSET-001***

***Status   : Submitted***





#### ***Status History***



***The Status History view displays the historical changes for requests.***



***Information includes:***



* ***Changed by***
* ***Comments***
* ***Request ID***
* ***Status***
* ***Status date***
* ***Status sequence***
* ***Status text***



***Example:***



***100001***



***Submitted***

&#x20;   ***|***

&#x20;   ***v***

***Validated***

&#x20;   ***|***

&#x20;   ***v***

***Processing***



***Another completed request:***



***100004***



***Submitted***

&#x20;   ***|***

&#x20;   ***v***

***Validated***

&#x20;   ***|***

&#x20;   ***v***

***Processing***

&#x20;   ***|***

&#x20;   ***v***

***Fulfilled***





#### ***Application Architecture***



***The project follows a layered SAP application approach.***



***+--------------------------------------+***

***|          Fiori Elements UI           |***

***+-------------------+------------------+***

&#x20;                   ***|***

&#x20;                   ***v***

***+--------------------------------------+***

***|           OData V4 Service           |***

***|              ZESR\_SB                 |***

***+-------------------+------------------+***

&#x20;                   ***|***

&#x20;                   ***v***

***+--------------------------------------+***

***|          Service Definition          |***

***|              ZESR\_SD                 |***

***+-------------------+------------------+***

&#x20;                   ***|***

&#x20;                   ***v***

***+--------------------------------------+***

***|             CDS Views                |***

***|      ZESR\_C\_REQUEST / STATUS         |***

***+-------------------+------------------+***

&#x20;                   ***|***

&#x20;                   ***v***

***+--------------------------------------+***

***|          ABAP Business Logic         |***

***|          ZCL\_ESR\_REQUEST             |***

***+-------------------+------------------+***

&#x20;                   ***|***

&#x20;                   ***v***

***+--------------------------------------+***

***|          SAP Database Tables         |***

***| ZESR\_HDR / ZESR\_ITEM / ZESR\_STATUS  |***

***|            ZESR\_FULLFILL             |***

***+-------------------------------------***





#### ***End-to-End Application Flow***



***Employee***

&#x20;  ***|***

&#x20;  ***v***

***Request Details***

&#x20;  ***|***

&#x20;  ***v***

***ZESR\_CREATE\_REQUEST***

&#x20;  ***|***

&#x20;  ***v***

***Validation***

&#x20;  ***|***

&#x20;  ***v***

***ZCL\_ESR\_REQUEST***

&#x20;  ***|***

&#x20;  ***v***

***Duplicate Check***

&#x20;  ***|***

&#x20;  ***+---- Duplicate ----> Request Blocked***

&#x20;  ***|***

&#x20;  ***+---- Valid --------> Request Created***

&#x20;                             ***|***

&#x20;                             ***v***

&#x20;                        ***ZESR\_HDR***

&#x20;                             ***|***

&#x20;                             ***v***

&#x20;                        ***ZESR\_ITEM***

&#x20;                             ***|***

&#x20;                             ***v***

&#x20;                       ***ZESR\_STATUS***

&#x20;                             ***|***

&#x20;                             ***v***

&#x20;                        ***CDS Views***

&#x20;                             ***|***

&#x20;                             ***v***

&#x20;                        ***OData V4***

&#x20;                             ***|***

&#x20;                             ***v***

&#x20;                      ***Fiori Elements***

&#x20;                             ***|***

&#x20;                             ***v***

&#x20;                      ***Request Monitor***





#### ***Screenshots and Evidence***



***The repository contains screenshots captured from the actual SAP development environment and Fiori Elements preview.***



###### ***1. ADT Project Architecture***



***Shows the SAP ADT project and the ZPKG\_ESR package containing the project objects.***



***File:***



***screenshots/01\_ADT\_Architecture.png.png***



###### ***2. ABAP Programs***



***Shows the ABAP programs created for request management and monitoring.***



***File:***



***screenshots/02\_ADT\_ABAP\_Programs.png.png***



###### ***3. Fiori Request Overview***



***Shows the Fiori Elements request monitoring interface.***



***File:***



***screenshots/03\_Fiori\_Request\_Overview.png***



###### ***4. Fiori Status History***



***Shows the request status history interface.***



***File:***



***screenshots/04\_Fiori\_Status\_History.png***



###### ***5. Request Creation Output***



***Shows the successful creation of an employee request.***



***Files:***



***screenshots/05\_Create\_Request\_Output1.png***

***screenshots/05\_Create\_Request\_Output2.png***



###### ***6. Duplicate Request Validation***



***Shows the system blocking an active duplicate request.***



***File:***



***screenshots/06\_Duplicate\_Request\_Validation.png***





#### ***Repository Structure***



***Employee-Service-Request-Management/***

***|***

***+-- README.md***

***+-- .gitignore***

***|***

***+-- abap/***

***|   |***

***|   +-- classes/***

***|   |   |***

***|   |   +-- ZCL\_ESR\_REQUEST.abap***

***|   |***

***|   +-- cds/***

***|   |   |***

***|   |   +-- ZESR\_C\_REQUEST.ddls***

***|   |   +-- ZESR\_C\_STATUS.ddls***

***|   |***

***|   +-- programs/***

***|   |   |***

***|   |   +-- ZESR\_CREATE\_REQUEST.abap***

***|   |   +-- ZESR\_STATUS\_UPDATE.abap***

***|   |   +-- ZESR\_ALV\_REQUEST.abap***

***|   |   +-- ZESR\_ALV\_MONITOR.abap***

***|   |   +-- ZESR\_STATUS\_HISTORY.abap***

***|   |   +-- ZESR\_REQUEST\_DASHBOARD.abap***

***|   |***

***|   +-- services/***

***|       |***

***|       +-- ZESR\_SD.srvd***

***|       +-- TABLES.md***

***|***

***+-- database/***

***|   |***

***|   +-- TABLES.md***

***|***

***+-- screenshots/***

***|   |***

***|   +-- 01\_ADT\_Architecture.png.png***

***|   +-- 02\_ADT\_ABAP\_Programs.png.png***

***|   +-- 03\_Fiori\_Request\_Overview.png***

***|   +-- 04\_Fiori\_Status\_History.png***

***|   +-- 05\_Create\_Request\_Output1.png***

***|   +-- 05\_Create\_Request\_Output2.png***

***|   +-- 06\_Duplicate\_Request\_Validation.png***

***|***

***+-- test/***

&#x20;   ***|***

&#x20;   ***+-- ZESR\_TEST\_CREATE.abap***

&#x20;   ***+-- ZESR\_TEST\_DATA.abap***

&#x20;   ***+-- ZESR\_TEST\_DETAILS.abap***

&#x20;   ***+-- ZESR\_TEST\_DUPLICATE.abap***

&#x20;   ***+-- ZESR\_TEST\_FULFILL.abap***

&#x20;   ***+-- ZESR\_TEST\_ITEM\_INSERT.abap***

&#x20;   ***+-- ZESR\_TEST\_PROCESS.abap***

&#x20;   ***+-- ZESR\_TEST\_STATUS.abap***

&#x20;   ***+-- ZESR\_TEST\_VALIDATE.abap***





#### ***Testing Performed***



***The project was tested using different request scenarios.***



###### ***Successful Request Creation***



***Example:***



***Request ID      : 100005***

***Employee ID     : E9999***

***Material ID     : HEADSET-001***

***Quantity        : 1***

***Status          : Submitted***

***Status Sequence : 0010***



***The request was successfully stored in the database and appeared in the Fiori request overview.***



###### ***Duplicate Request Test***



***The duplicate validation was tested using an employee and material combination that already had an active request.***



***Example:***



***Employee ID : E9999***

***Material ID : HEADSET-001***

***Existing ID : 100005***



***Result:***



***Duplicate active request already exists: 100005***



***The new request was blocked.***



###### ***Status Processing Test***



***A request was tested through multiple status stages:***



***Submitted***

&#x20;   ***↓***

***Validated***

&#x20;   ***↓***

***Processing***

&#x20;   ***↓***

***Fulfilled***



***The status history was then verified through the Fiori Elements status history view.***





#### ***Technologies Used***



* ***SAP ABAP***
* ***ABAP Dictionary***
* ***Eclipse ADT***
* ***CDS Views***
* ***OData V4***
* ***Fiori Elements***
* ***SAP Database***
* ***ALV***
* ***Git***
* ***GitHub***





#### ***What I Learned***



***While developing this project, I worked with different layers of SAP ABAP development instead of focusing only on individual reports.***



***The main areas I practiced were:***



* ***ABAP programming***
* ***ABAP Dictionary development***
* ***Custom domains and data elements***
* ***Database table creation***
* ***Database operations using Open SQL***
* ***Input validation***
* ***Duplicate request validation***
* ***Reusable ABAP class design***
* ***Status management***
* ***Status history tracking***
* ***ALV reporting***
* ***CDS View development***
* ***OData V4 service exposure***
* ***Fiori Elements integration***
* ***Testing and debugging***
* ***Git version control***
* ***GitHub repository management***



***The project helped me understand how backend ABAP development connects with CDS, OData and Fiori Elements to form an end-to-end SAP application.***



#### 

#### ***Why This Project***

###### 

***I wanted to build a project that demonstrates more than basic ABAP reporting.***



***The project combines:***



***ABAP***

&#x20; ***+***

***ABAP Dictionary***

&#x20; ***+***

***Database Operations***

&#x20; ***+***

***Business Logic***

&#x20; ***+***

***CDS***

&#x20; ***+***

***OData V4***

&#x20; ***+***

***Fiori Elements***



***This allowed me to practice both backend development and the service/UI integration side of SAP.***





#### ***Future Enhancements***



***Possible future improvements include:***



* ***Fiori-based request creation form***
* ***Role-based access control***
* ***Employee-specific request filtering***
* ***Approval workflow***
* ***Email or SAP notifications***
* ***Improved fulfillment management***
* ***Fiori dashboard with analytical cards***
* ***Request priority-based monitoring***
* ***Administrative monitoring features***
* ***Enhanced error handling and user messages***



***These are planned enhancements and are not represented as completed features in the current version.***





#### ***Author***



***Anjali Baluvu***



***B.Tech - Artificial Intelligence \& Machine Learning***



***SAP ABAP Project***





#### ***Project Type***



###### ***Academic / Learning / Portfolio Project***



***This project was developed to gain practical experience in SAP ABAP development and understand how ABAP backend logic can be integrated with CDS, OData V4 and Fiori Elements.***





#### ***Repository Contents***



***The repository contains:***



* ***ABAP source programs***
* ***ABAP business logic class***
* ***CDS definitions***
* ***Service definition***
* ***Database documentation***
* ***Test programs***
* ***Screenshots***
* ***Project documentation***



***The repository is intended to demonstrate the development approach, application architecture and practical SAP ABAP skills used during the project.***

