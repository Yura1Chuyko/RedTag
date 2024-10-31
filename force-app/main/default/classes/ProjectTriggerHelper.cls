public with sharing class ProjectTriggerHelper {
    public static void onStageChangeCreateTasks(List<Project__c> newProjects, Map<Id, Project__c> oldProjectsMap) {
        List<Task> tasksToCreate = new List<Task>();
        Set<String> newStages = new Set<String>();
        for (Project__c newProject : newProjects) {
            Project__c oldProject = oldProjectsMap.get(newProject.Id);
            if (newProject.Stage__c != oldProject.Stage__c) {
                newStages.add(newProject.Stage__c);
            }
        }
        List<Task_Template__c> taskTemplates = [
            SELECT Name, Stage__c, Priority__c, Cost_Of_Activity__c, Execution_Time__c 
            FROM Task_Template__c 
            WHERE Stage__c IN :newStages
        ];
        Map<String, List<Task_Template__c>> stageToTaskTemplates = new  Map<String, List<Task_Template__c>>();
        for (Task_Template__c taskTemplate : taskTemplates) {
            if(!stageToTaskTemplates.containsKey(taskTemplate.Stage__c)) {
                stageToTaskTemplates.put(taskTemplate.Stage__c, new List<Task_Template__c>());
            }
            stageToTaskTemplates.get(taskTemplate.Stage__c).add(taskTemplate);

        }

        for (Project__c newProject : newProjects) {
            Project__c oldProject = oldProjectsMap.get(newProject.Id);
            if (newProject.Stage__c != oldProject.Stage__c) {
                List<Task_Template__c> taskTemplatesForCurrentProjectStage = stageToTaskTemplates.get(newProject.Stage__c);
                for (Task_Template__c taskTemplate: taskTemplatesForCurrentProjectStage) {
                    
                    Task newTask = new Task();
                    newTask.WhatId = newProject.Id;
                    if (String.isBlank(taskTemplate.Priority__c)) {
                        newTask.Priority = 'Low';
                    } else {
                        newTask.Priority = taskTemplate.Priority__c;
                    }
                    if (String.isBlank(newProject.Project_Manager__c)) {
                        newTask.OwnerId = UserInfo.getUserId();
                    } else {
                        newTask.OwnerId = newProject.Project_Manager__c;
                    }
                    newTask.Cost_Of_Activity__c = taskTemplate.Cost_Of_Activity__c;
                    newTask.Subject = taskTemplate.Name;
                    if (taskTemplate.Execution_Time__c != null) {
                        Integer dueDays = taskTemplate.Execution_Time__c.intValue();
                        newTask.ActivityDate = Date.Today().addDays(dueDays);
                    }
                    tasksToCreate.add(newTask);
                } 
                     
            }
            
        }
    
        // Insert tasks if any were created
        if (!tasksToCreate.isEmpty()) {
            try {
                insert tasksToCreate;
                System.debug('Tasks Created Successfully');
            } catch (DmlException e) {
                System.debug('Error creating tasks from templates: ' + e.getMessage());
            }
        } else {
            System.debug('No tasks to create.');
        }
    }
    
    
    public static void sendBudgetExceedEmails(List<Project__c> newProjects, Map<Id, Project__c> oldProjectsMap) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        EmailTemplate emailTemplate = [SELECT Id, Subject, Body, HtmlValue FROM EmailTemplate WHERE Name = 'Project_Budget_Exceed_Notification'];

        for (Project__c newProject : newProjects) {
            Project__c oldProject = oldProjectsMap.get(newProject.Id);
            
           
            if (newProject.Remaining_Budget__c < 0) {
                
                if (newProject.Project_Manager__c != null) {
                    Messaging.SingleEmailMessage email = Messaging.renderStoredEmailTemplate(emailTemplate.Id, newProject.OwnerId, newProject.Id);
                    email.setTargetObjectId(newProject.Project_Manager__c);
                    email.setTemplateId(emailTemplate.Id);
                    email.setWhatId(newProject.Id);
                    email.setSaveAsActivity(false);
                    
                    emails.add(email);
                }
            }
        }

        if (!emails.isEmpty()) {
            try {
                Messaging.sendEmail(emails);
                System.debug('Budget exceed emails sent successfully.');
            } catch (DmlException e) {
                System.debug('Error sending budget exceed emails: ' + e.getMessage());
            }
        }
    }
}