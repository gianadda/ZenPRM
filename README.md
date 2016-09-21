# ZenPRM
ZenPRM - Healthcare CRM extends beyond your four walls to include public datasets and industry information that helps you better measure and benchmark your organization.


 DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
                    Version 2, December 2004 

 Copyright (C) 2004 Sam Hocevar <sam@hocevar.net> 

 Everyone is permitted to copy and distribute verbatim or modified 
 copies of this license document, and changing it is allowed as long 
 as the name is changed. 

            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE 
   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION 

  0. You just DO WHAT THE FUCK YOU WANT TO.


# How to run the project

## Front End
CD into the FrontEnd Directory and Run the following commands to load the application:

```
npm install npm@2.7.4 -g
npm install --force
npm install bower -g
bower install
npm install gulp -g
gulp
```

## Database

- Create new MS-SQL Database
- Execute all scripts from the repository against the new database, in the following order
  - Tables
  - Views
  - Triggers
  - User Defined Types
  - User Defined Functions – GetIdent
  - User Defined Functions
  - Stored Procedures

## Web.API

- Load the Web.API project in Visual Studio.
- Add the DLLs found in the References folder to the bin of the WebAPI project (extract from the ZIP file).
- For your solution file, ensure you click the option "Enable NuGet Package Restore" (Right click solution file in Solution Explorer) to pull in the referenced NuGet packages.
- Setup the connection strings in the Web.Config files and run the application.

