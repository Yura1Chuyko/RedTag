public with sharing class ProjectTriggerHandler {

    public static void onAfterUpdate(List<Project__c> triggerNew, Map<Id, Project__c> triggerOldMap) {
        ProjectTriggerHelper.onStageChangeCreateTasks(triggerNew, triggerOldMap);
        ProjectTriggerHelper.sendBudgetExceedEmails(triggerNew, triggerOldMap);
    }
    
}