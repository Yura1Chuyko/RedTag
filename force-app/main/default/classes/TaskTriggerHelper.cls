public with sharing class TaskTriggerHelper {
    // Update Spent Budget when a task is closed
    public static void updateSpentBudgetOnClose(List<Task> newTasks, Map<Id, Task> oldTaskMap) {
        
        Set<Id> projectIds = new Set<Id>();
        Map<Id, Decimal> projectBudgetUpdates = new Map<Id, Decimal>();
    
        for (Task newTask : newTasks) {
            Task oldTask = oldTaskMap.get(newTask.Id);
            if (newTask.Status == 'Completed' && oldTask.Status != 'Completed' && newTask.WhatId != null) {
                projectIds.add(newTask.WhatId);
    
                Decimal budgetIncrease = (newTask.Cost_Of_Activity__c != null) ? newTask.Cost_Of_Activity__c : 0;
                if (projectBudgetUpdates.containsKey(newTask.WhatId)) {
                    projectBudgetUpdates.put(newTask.WhatId, projectBudgetUpdates.get(newTask.WhatId) + budgetIncrease);
                } else {
                    projectBudgetUpdates.put(newTask.WhatId, budgetIncrease);
                }
            }
        }
    
            List<Project__c> projectsToUpdate = [SELECT Id, Spent_Budget__c FROM Project__c WHERE Id IN :projectIds];
            
            for (Project__c project : projectsToUpdate) {
                project.Spent_Budget__c = (project.Spent_Budget__c != null ? project.Spent_Budget__c : 0) + projectBudgetUpdates.get(project.Id);
            }
    
            try {
                if (!projectIds.isEmpty()) {
                update projectsToUpdate;
                System.debug('Projects updated with new spent budget.');
                }
            } catch (DmlException e) {
                System.debug('Error updating spent budget on projects: ' + e.getMessage());
            }
    }

    // Validate before insert: Check if task creation exceeds budget
    public static void validateBudgetOnInsert(List<Task> newTasks) {
        Map<Id, Project__c> projects = new Map<Id, Project__c>();
        for (Task task : newTasks) {
            if (task.WhatId != null) {
                projects.put(task.WhatId, null);
            }
        }

        if (!projects.isEmpty()) {
            projects.putAll([SELECT Id, Budget__c, Spent_Budget__c, RecordType.DeveloperName
                             FROM Project__c WHERE Id IN :projects.keySet()]);
        }

        for (Task task : newTasks) {
            if (task.WhatId != null && projects.containsKey(task.WhatId)) {
                Project__c project = projects.get(task.WhatId);
                if (ProjectDept__mdt.getInstance(project.RecordType.DeveloperName) != null) {
                    Decimal reservedBudget = ProjectDept__mdt.getInstance(project.RecordType.DeveloperName).Reserved_Budget__c;
                    
                    Decimal totalSpent = project.Spent_Budget__c + task.Cost_Of_Activity__c;
                    Decimal maxAllowedBudget = project.Budget__c + reservedBudget;

                    if (totalSpent > maxAllowedBudget) {
                        task.addError('Cannot create this task as it will exceed the allowed budget.');
                    }
                } else {
                    System.debug('No ProjectDept__mdt record found');
                }
            }
        }
    }

    // Return budget when a task is deleted
    public static void returnBudgetOnDelete(List<Task> oldTasks) { 
        Id profileSystemAdministrator = [SELECT Id FROM Profile WHERE PermissionsAuthorApex = true LIMIT 1].Id;

        if(UserInfo.getProfileId() != profileSystemAdministrator) {
            for(Task task : oldTasks) {
                task.addError('Only System Administrator can delete tasks!');
            }
        }

        if (UserInfo.getProfileId() == profileSystemAdministrator ) {
            Set<Id> projectIds = new Set<Id>();
            for (Task oldTask : oldTasks) {
                if (oldTask.WhatId != null && oldTask.WhatId.getSObjectType() == Project__c.SObjectType) {
                    projectIds.add((Id) oldTask.WhatId);
                }
            }
    
            Map<Id, Project__c> projectsToUpdate = new Map<Id, Project__c>(
                [SELECT Id, Spent_Budget__c FROM Project__c WHERE Id IN :projectIds]
            );
    
            for (Task oldTask : oldTasks) {
                if (oldTask.WhatId != null && oldTask.WhatId.getSObjectType() == Project__c.SObjectType) {
                    Id projectId = (Id) oldTask.WhatId;
                    Project__c project = projectsToUpdate.get(projectId);
                    if (project != null && oldTask.Cost_Of_Activity__c != null) {
                        project.Spent_Budget__c -= oldTask.Cost_Of_Activity__c;
                    }
                }
            }
    
            if (!projectsToUpdate.isEmpty()) {
                try {
                    update projectsToUpdate.values();
                    System.debug('Budget updated successfully');
                } catch(DmlException e) {
                    System.debug('Error updating budget on projects' + e.getMessage());
                }
                
            }
        }
    }
}