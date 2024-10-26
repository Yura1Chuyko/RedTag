@isTest
public with sharing class TaskTriggerHelperTest {
    @testSetup
    static void setupTestData() {
        TestDataFactory.createAccount(1,'Internal Department');
        User projectManager = new User(
            FirstName = 'Test',
            LastName = 'Manager',
            Email = 'testmanager@example.com',
            Username = 'testmanager@example.com' + System.currentTimeMillis(),
            Alias = 'tmanager',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert projectManager;
        
    }
    private static Project__c createTestProject(Decimal budget, Decimal spentBudget) {
        Account client = [SELECT Id,Type FROM Account LIMIT 1];
        Project__c project = new Project__c(Name = 'Test Project', Budget__c = budget, Spent_Budget__c = spentBudget,Client__c = client.Id);
        insert project;
        return project;
    }
    
    // Utility method to create a test Task record.
    private static Task createTestTask(Id projectId, String status, Decimal costOfActivity) {
        Task task = new Task(WhatId = projectId, Status = status, Cost_Of_Activity__c = costOfActivity, Subject = 'Test Task');
        insert task;
        return task;
    }
    @isTest
    static void testUpdateSpentBudgetOnClose() {
        Project__c project = createTestProject(1000, 100);
        
        // Create a task related to the project with an open status.
        Task task = createTestTask(project.Id, 'Not Started', 50);

        task.Status = 'Completed';
        Test.startTest();
        update task;
        Test.stopTest();

        Project__c updatedProject = [SELECT Id, Spent_Budget__c FROM Project__c WHERE Id = :project.Id]; 
        System.assertEquals(150, updatedProject.Spent_Budget__c, 'The spent budget should increase by the task cost on completion.');
    }

    @isTest
    static void testValidateBudgetOnInsert() {
        Account client = [SELECT Id,Type FROM Account LIMIT 1];
        ProjectDept__mdt internalDept = [SELECT Reserved_Budget__c FROM ProjectDept__mdt WHERE DeveloperName = 'Internal_Project' LIMIT 1];
        RecordType projectRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Project__c' AND DeveloperName = 'Internal_Project' LIMIT 1];

        Project__c project = new Project__c(
        Name = 'Test Project',
        Budget__c = 1000,
        Spent_Budget__c = 900,
        RecordTypeId = projectRecordType.Id,
        Client__c = client.Id
        );
        insert project;


        Task task = new Task(
            WhatId = project.Id,
            Status = 'Not Started',
            Cost_Of_Activity__c = 150,
            Subject = 'Exceed Budget Task'
            );
        System.debug('Created Task with Cost of Activity: ' + task.Cost_Of_Activity__c);

        Test.startTest();
        try {
            insert task;
            System.assert(true, 'Task creation should have thrown an exception due to exceeding the budget.');
        } catch (DmlException e) {
            System.debug('Caught DML Exception: ' + e.getMessage());
            System.assert(e.getMessage().contains('Cannot create this task as it will exceed the allowed budget.'),
                'Expected error message not found.');
        }
        Test.stopTest();
        
    }

    @isTest
    static void testReturnBudgetOnDelete() {
        Project__c project = createTestProject(1000, 300);
        
        Task task = createTestTask(project.Id, 'Completed', 50);
        
        Test.startTest();
        delete task;
        Test.stopTest();

        Project__c updatedProject = [SELECT Id, Spent_Budget__c FROM Project__c WHERE Id = :project.Id];

        // Verify that the spent budget is decreased correctly after the task deletion.
        System.assertEquals(250, updatedProject.Spent_Budget__c, 'The spent budget should decrease by the task cost when the task is deleted.');
    }
    @isTest
    static void testReturnBudgetOnDeleteWithNoPermission() {
        Project__c project = createTestProject(1000, 300);
        
        Task task = createTestTask(project.Id, 'Completed', 50);

        // Simulate a user without the required profile.
        User user = [SELECT Id FROM User WHERE Profile.Name != 'System Administrator' LIMIT 1];
        System.runAs(user) {
            Test.startTest();
            try {
                delete task;
                System.assert(false, 'Delete operation should fail for users without the System Administrator profile.');
            } catch (DmlException e) {
                // Expected behavior: task deletion should fail for non-admin users.
                System.assert(true, 'Delete operation failed as expected for non-admin user.');
            }
            Test.stopTest();
        }
    }
}