public with sharing class TaskStageAccordionController {

    @AuraEnabled(cacheable=true)
    public static Map<String, List<Task>> getTasksGroupedByStage() {
        // Query all projects with their IDs and stages
        Map<Id, String> projectStages = new Map<Id, String>();
        for (Project__c project : [SELECT Id, Stage__c FROM Project__c]) {
            projectStages.put(project.Id, project.Stage__c);
        }

        // Query all tasks related to those projects
        Map<String, List<Task>> stageToTasks = new Map<String, List<Task>>();
        for (Task task : [
            SELECT Id, Subject, Status, WhatId, ActivityDate
            FROM Task
            WHERE WhatId IN :projectStages.keySet()
        ]) {
            String stage = projectStages.get(task.WhatId);
            if (stage != null) {
                if (!stageToTasks.containsKey(stage)) {
                    stageToTasks.put(stage, new List<Task>());
                }
                stageToTasks.get(stage).add(task);
            }
        }
        return stageToTasks;
    }
    @AuraEnabled
    public static void updateTasks(List<Task> tasks) {
        update tasks;
    }
}