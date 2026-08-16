### ***Employee Service Request Management***



#### ***About the Project***



***Employee Service Request Management is an SAP ABAP project that I developed to manage employee requests for IT-related materials such as laptops, monitors, keyboards, headsets, and other equipment.***



***The main idea behind this project is to provide one place where employee requests can be created, tracked, and monitored instead of handling every request manually.***



***I also wanted the project to cover both the backend ABAP development and the user-facing side using CDS, OData V4, and Fiori Elements.***



#### ***What the Application Does***



***An employee request contains information such as:***



***Employee ID***

***Request type***

***Priority***

***Material***

***Quantity***

***Reason***

***Required date***



***When a request is created, the system assigns a unique Request ID and stores the request details.***



***The request then goes through different statuses such as:***



***Submitted → Validated → Processing → Fulfilled***



***The system also keeps the complete status history so that the progress of a request can be checked later.***



### ***Main Features***



##### ***Request Creation***



***A request can be created with the required employee, material, quantity, priority, reason, and required date.***



***For example:***



***Request ID    : 100005***

***Employee ID   : E9999***

***Material      : HEADSET-001***

***Quantity      : 1***

***Priority      : N***

***Status        : Submitted***



##### ***Duplicate Request Validation***



***One of the important validations I implemented is duplicate request checking.***



***Before creating a request, the system checks whether the same employee already has an active request for the same material.***



***If an active request exists, the new request is blocked.***



***Example:***



***Duplicate active request already exists: 100005***



***This was implemented because an employee should not be able to create multiple active requests for the same material unnecessarily.***



##### ***Request Status Tracking***



***The request status is maintained separately in the status history table.***



***For example:***



***100004***

***Submitted***

&#x20;   ***↓***

***Validated***

&#x20;   ***↓***

***Processing***

&#x20;   ***↓***

***Fulfilled***



***Each status change stores information such as the date, sequence number, user, and comments.***



##### ***Request Monitoring***



***I created ABAP reports for viewing and monitoring the requests and their status history.***



***The project also exposes the request information through CDS and OData so that it can be displayed using Fiori Elements.***



#### ***SAP Objects Used***



##### ***Database Tables***



***Object	         Purpose***

***--------------------------------------------------***

***ZESR\_HDR	Stores request header information***

***ZESR\_ITEM	Stores material and quantity information***

***ZESR\_STATUS	Stores request status history***

***ZESR\_FULLFILL	Stores fulfillment information***





##### ***CDS Views***



***Object	         Purpose***

***--------------------------------------***

***ZESR\_C\_REQUEST	 Request overview***

***ZESR\_C\_STATUS	 Request status history***



##### ***Service Objects***



***Object	    Purpose***

***----------------------------------------***

***ZESR\_SD	    Service Definition***

***ZESR\_SB	    OData V4 UI Service Binding***



#### ***ABAP Class***



***ZCL\_ESR\_REQUEST***



***This class contains the request-related business logic, including duplicate request validation.***



##### ***Main Programs***



* ***ZESR\_CREATE\_REQUEST***
* ***ZESR\_STATUS\_UPDATE***
* ***ZESR\_ALV\_REQUEST***
* ***ZESR\_ALV\_MONITOR***
* ***ZESR\_STATUS\_HISTORY***
* ***ZESR\_REQUEST\_DASHBOARD***



***I also created separate test programs while developing and testing the different parts of the application.***



### ***How the Project Works***



##### ***The overall flow of the project is:***



***Employee Request***

&#x20;      ***↓***

***Request Validation***

&#x20;      ***↓***

***Duplicate Check***

&#x20;      ***↓***

***Request Created***

&#x20;      ***↓***

***Status History***

&#x20;      ***↓***

***CDS Views***

&#x20;      ***↓***

***OData V4 Service***

&#x20;      ***↓***

***Fiori Elements***



***The backend data is maintained in SAP tables, while CDS views provide the data needed by the service layer and Fiori interface.***



### ***Fiori Elements Interface***



##### ***I created an OData V4 UI service using:***



***Service Definition : ZESR\_SD***

***Service Binding    : ZESR\_SB***

***Binding Type        : OData V4 - UI***



#### ***The Fiori Elements preview provides two important views:***



###### ***Request Overview***



***This displays the available requests along with details such as:***



* ***Request ID***
* ***Employee***
* ***Request type***
* ***Priority***
* ***Status***
* ***Material***
* ***Quantity***
* ***Reason***
* ***Request date***
* ***Required date***



##### ***Status History***



***This displays the history of status changes for requests.***



***It includes information such as:***



* ***Request ID***
* ***Status***
* ***Status date***
* ***Status sequence***
* ***Status text***
* ***Changed by***
* ***Comments***



### ***Project Structure***



***Employee-Service-Request-Management***

***│***

***├── abap***

***│   ├── classes***

***│   ├── cds***

***│   ├── programs***

***│   └── services***

***│***

***├── database***

***│***

***├── docs***

***│***

***├── screenshots***

***│***

***└── test***



***The abap folder contains the main ABAP, CDS and service-related source files.***



***The database folder contains documentation related to the database tables.***



***The test folder contains the programs that I used to test different parts of the application.***



***The screenshots folder contains screenshots of the working SAP development environment and Fiori Elements application.***



### ***Screenshots***



***The repository contains screenshots showing:***



* ***SAP ADT project structure***
* ***ABAP programs and objects***
* ***Fiori request overview***
* ***Fiori status history***
* ***Request creation output***
* ***Duplicate request validation***



***These screenshots show the project working in the SAP environment.***



#### ***Technologies Used***



* ***SAP ABAP***
* ***ABAP Dictionary***
* ***Eclipse ADT***
* ***CDS Views***
* ***OData V4***
* ***Fiori Elements***
* ***SAP Database***
* ***Git***
* ***GitHub***



##### ***What I Learned From This Project***



***While developing this project, I worked with different parts of SAP ABAP development instead of focusing only on reports.***



***Some of the main things I practiced were:***



* ***Creating and using ABAP Dictionary objects***
* ***Working with database tables***
* ***Writing ABAP programs***
* ***Creating reusable business logic using an ABAP class***
* ***Performing validations and database operations***
* ***Maintaining status history***
* ***Creating CDS views***
* ***Exposing CDS data through OData V4***
* ***Creating a Fiori Elements service binding***
* ***Testing the application using real request data***
* ***Using Git and GitHub to maintain the project***



***This project helped me understand how the different layers of an SAP application connect with each other.***



#### ***Project Status***



***The core backend functionality, request validation, status tracking, CDS views, OData service, and Fiori Elements preview have been implemented and tested.***



***The project is being maintained as a learning and portfolio project to demonstrate my practical SAP ABAP development experience.***



### ***Author***



***Anjali Baluvu***



***B.Tech — Artificial Intelligence \& Machine Learning***



***SAP ABAP Project***

