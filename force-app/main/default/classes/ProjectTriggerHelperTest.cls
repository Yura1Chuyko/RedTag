@isTest
public class ProjectTriggerHelperTest {
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

    @isTest
    static void testStageChangeCreatesTasks() {
        User projectManager = [SELECT Id FROM User WHERE Alias = 'tmanager' LIMIT 1];
        Account client = [SELECT Id,Type FROM Account LIMIT 1];

        List<Task_Template__c> taskTemplates = new List<Task_Template__c>();
        for (Integer i = 1; i <= 3; i++) {
            taskTemplates.add(new Task_Template__c(
                Name = 'Template ' + i,
                Priority__c = 'High',
                Cost_Of_Activity__c = 100 * i,
                Stage__c = 'Preparation',
                Execution_Time__c = 5 * i 
            ));
        }
        insert taskTemplates;
        System.debug(taskTemplates);
        Project__c project = new Project__c(
            Name = 'Test Project',
            Budget__c = 10000,
            Stage__c = 'Initialization',
            Client__c = client.Id,
            Spent_Budget__c = 5000,
            Project_Manager__c = projectManager.Id
        );
        insert project;

        project.Stage__c = 'Preparation';
       
        Map<Id, Project__c> oldMap = new Map<Id, Project__c>();
        oldMap.put(project.Id, new Project__c(
            Id = project.Id,
            Stage__c = 'Initialization'
        ));

     
        Test.startTest();
        update project;
       // ProjectTriggerHandler.stageChange(new List<Project__c>{ project }, oldMap);
        Test.stopTest();
        System.debug('After call' + taskTemplates);
        
        List<Project__c> projects = [SELECT Id,Name FROM Project__c];
        System.debug(projects);
        List<Task> createdTasks = [SELECT Id, Subject, Priority, Cost_Of_Activity__c, ActivityDate,WhatId 
                                   FROM Task WHERE WhatId = :project.Id];
                                   System.debug(createdTasks);
        System.assertEquals(3, createdTasks.size(), 'Three tasks should be created.');
        for (Task task : createdTasks) {
            System.assertEquals('High', task.Priority, 'Task priority should be set correctly.');
            System.assertEquals(project.Id, task.WhatId, 'Task should be related to the correct project.');
            Assert.isNotNull(task.ActivityDate, 'Task should have an ActivityDate.');
        }
    }

    @isTest
    static void testSendBudgetExceedEmails() {
       
        User projectManager = [SELECT Id FROM User WHERE Alias = 'tmanager' LIMIT 1];
        Account client = [SELECT Id,Type FROM Account LIMIT 1];

        Project__c project = new Project__c(
            Name = 'Test Project Budget',
            Budget__c = 10000,
            Stage__c = 'Initialization',
            Client__c = client.Id,
            Spent_Budget__c = 5000,
            Project_Manager__c = projectManager.Id
        );
        insert project;

        project.Spent_Budget__c = 12000; 

        Map<Id, Project__c> oldMap = new Map<Id, Project__c>();
        oldMap.put(project.Id, project);

        Test.startTest();
        update project;
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations, 'One email should have been sent.');
    }
}