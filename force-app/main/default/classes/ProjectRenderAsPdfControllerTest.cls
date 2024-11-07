@IsTest
public class ProjectRenderAsPdfControllerTest {
    @IsTest
    static void testProjectRenderAsPdfController() {
        User testUser = new User(
            Alias = 'testuser',
            Email = 'testuser@example.com',
            LastName = 'us',
            Username = 'tesuser535353@gmail.com',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;

        TestDataFactory.createAccount(1, 'Internal Department');
        Account client = [SELECT Id FROM Account LIMIT 1];

        Project__c testProject = new Project__c(Name = 'Test Project', Client__c = client.Id,Budget__c = 3000,Spent_Budget__c = 1000,Project_Manager__c = testUser.Id);
        insert testProject;

        Task task1 = new Task(Subject = 'Test Task 1', WhatId = testProject.Id, Status = 'Not Started', Cost_Of_Activity__c = 1000);
        insert new List<Task> { task1 };

        ApexPages.StandardController stdController = new ApexPages.StandardController(testProject);
        
        Test.startTest();
        ProjectRenderAsPdfController controller = new ProjectRenderAsPdfController(stdController);
        Test.stopTest();

        System.assertNotEquals(null, controller.project, 'Project should be populated.');
        System.assertEquals(testProject.Id, controller.project.Id, 'Project ID should match.');
        System.assertNotEquals(null, controller.projectFields, 'Project fields map should not be null.');
        
        // Ensure that the Project_Manager__r.Name field is populated in projectFields
        System.assert(controller.projectFields.containsKey('Project_Manager__c'), 'Project Manager Name should be included.');
        System.assertNotEquals(null, controller.projectFields.get('Project_Manager__c'), 'Project Manager Name should not be null.');
    }
}
