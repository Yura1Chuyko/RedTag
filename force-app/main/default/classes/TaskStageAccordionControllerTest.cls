@isTest
private class TaskStageAccordionControllerTest {


    @isTest
    static void testGetTasksGroupedByStage() {
        TestDataFactory.createAccount(1, 'Internal Department');
        Account client = [SELECT Id FROM Account LIMIT 1];
        // Create test Project__c records
        Project__c project1 = new Project__c(Name = 'Project 1', Stage__c = 'Initialization', Client__c = client.Id,Budget__c = 5000,Spent_Budget__c = 1000);
        Project__c project2 = new Project__c(Name = 'Project 2', Stage__c = 'Preparation', Client__c = client.Id,Budget__c = 5000,Spent_Budget__c = 1000);
        insert new List<Project__c>{project1, project2};
        
        // Create test Task records related to the projects
        Task task1 = new Task(Subject = 'Task 1', Status = 'Not Started',Cost_Of_Activity__c = 500, WhatId = project1.Id, ActivityDate = Date.today());
        Task task2 = new Task(Subject = 'Task 2', Status = 'Not Started',Cost_Of_Activity__c = 500, WhatId = project1.Id, ActivityDate = Date.today());
        Task task3 = new Task(Subject = 'Task 3', Status = 'In Progress',Cost_Of_Activity__c = 500, WhatId = project2.Id, ActivityDate = Date.today());
        insert new List<Task>{task1, task2, task3};
        
        // Test the getTasksGroupedByStage method
        Test.startTest();
        Map<String, List<Task>> result = TaskStageAccordionController.getTasksGroupedByStage();
        Test.stopTest();
        
        // Assert that the map has the correct number of stages and tasks
        System.assertEquals(2, result.size(), 'There should be 2 stages returned.');
        
        List<Task> stage1Tasks = result.get('Initialization');
        System.assertNotEquals(null, stage1Tasks, 'Tasks for Stage 1 should not be null.');
        System.assertEquals(2, stage1Tasks.size(), 'There should be 2 tasks in Stage 1.');
        
        List<Task> stage2Tasks = result.get('Preparation');
        System.assertNotEquals(null, stage2Tasks, 'Tasks for Stage 2 should not be null.');
        System.assertEquals(1, stage2Tasks.size(), 'There should be 1 task in Stage 2.');
    }

    @isTest
    static void testUpdateTasks() {
        TestDataFactory.createAccount(1, 'Internal Department');
        Account client = [SELECT Id FROM Account LIMIT 1];
        // Create test Project__c and Task records
        Project__c project = new Project__c(Name = 'Project 1', Stage__c = 'Initialization',Client__c = client.Id,Budget__c = 5000,Spent_Budget__c = 1000);
        insert project;
        
        Task task = new Task(Subject = 'Task 1', Status = 'Not Started',Cost_Of_Activity__c =500, WhatId = project.Id, ActivityDate = Date.today());
        insert task;
        
        // Modify the task's status
        task.Status = 'Completed';
        
        // Call updateTasks to update the task
        Test.startTest();
        TaskStageAccordionController.updateTasks(new List<Task>{task});
        Test.stopTest();
        
        // Retrieve the task and assert the status has been updated
        Task updatedTask = [SELECT Status FROM Task WHERE Id = :task.Id LIMIT 1];
        System.assertEquals('Completed', updatedTask.Status, 'The task status should be updated to Completed.');
    }
}
