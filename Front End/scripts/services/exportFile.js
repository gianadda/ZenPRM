'use strict'

angular.module('App.Services')
    .service('exportFileService', ['$filter','$global', function($filter,$global) {

        this.exportTicketsToCSV = function(tickets, categories) {

            // setup the initial fields for export
            var fields  = ["Ident", "ToDoInitiatorType", "ToDoType", "ToDoStatus","Regarding","Assignee","Title","Desc1","AddDateTime","StartDate", "DueDate", "EditDateTime"];
            var categoriesForExport = [];

            // now loop through each ticket and move the tags to the parent level
            angular.forEach(tickets, function(value,key) {

                angular.forEach(value.Tags, function(innerValue, innerKey) {

                    // setup an array of all the categories that are assigned to the exported tickets
                    if (categoriesForExport.indexOf(innerValue.Name1) == -1){

                        categoriesForExport.push(innerValue.Name1);

                    };

                    value[innerValue.Name1] = 'Yes';

                }); // ticket.Tags loop

            }); // tickets loop

            // then pushed the sorted array back into the fields to export
            fields = fields.concat($filter('orderBy')(categoriesForExport));

            // load the parent data into the CSV
            var data = Papa.unparse({
                        fields: fields,
                        data: tickets
                    });

            //swap out header names
            data = data.replace('Ident','Ticket Number');
            data = data.replace('ToDoInitiatorType','Initiator');
            data = data.replace('ToDoType','Type');
            data = data.replace('ToDoStatus','Status');
            data = data.replace('Regarding','Resource');
            data = data.replace('Desc1','Description');
            data = data.replace('StartDate','Start Date');
            data = data.replace('DueDate','Due Date');
            data = data.replace('AddDateTime','Add Date');
            data = data.replace('EditDateTime','Edit/Closed Date');

            var blob = new Blob([data], { type: "application/csv;charset=utf-8;" });

            var date = new Date(Date.now());
            var fileName = 'Tickets_' + String(date.getFullYear()) + (((date.getMonth() + 1)<10) ? String("0"+(date.getMonth() + 1)) : String((date.getMonth() + 1))) + (((date.getDate())<10) ? String("0"+date.getDate()) : String(date.getDate())) + '.csv';
            saveAs(blob, fileName);

        };

  }]);