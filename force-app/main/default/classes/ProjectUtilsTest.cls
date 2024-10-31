    @isTest
    public class ProjectUtilsTest {
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
        static void testProjectStageOnHold() {
            Project__c pastDueProject = TestDataFactory.createTestProjectForStage(Date.today().addDays(-5), 'In Progress');
            Project__c futureDueProject = TestDataFactory.createTestProjectForStage(Date.today().addDays(5), 'In Progress');
            
            List<Project__c> projects = new List<Project__c>{ pastDueProject, futureDueProject };
            
            Test.startTest();
            Database.executeBatch(new ProjectStageBatch());
            ProjectUtils.projectStageOnHold(projects);
            
            Test.stopTest();
            System.debug(pastDueProject);
            
            System.assertEquals('On Hold', pastDueProject.Stage__c, 'The project with a past due date should be On Hold.');
            
            System.assertEquals('In Progress', futureDueProject.Stage__c, 'The project with a future due date should remain In Progress.');
        }
    
        @isTest
        static void testSendOverdueProjectsEmail() {
        RecordType internalRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Project__c' AND DeveloperName = 'Internal_Project' LIMIT 1];
        User projectManager = [SELECT Id, Email FROM User WHERE IsActive = true LIMIT 1];
            // Create test data: One internal overdue project and one client overdue project.
            Account client = [SELECT Id,Type FROM Account LIMIT 1];
            Project__c overdueProject = new Project__c(
                Name = 'Test Overdue Project',
                Due_Date__c = Date.today().addDays(-10), // Set past due date
                Stage__c = 'In Progress',
                Project_Manager__c = projectManager.Id,
                RecordTypeId = internalRecordType.Id,
                Client__c = client.Id
            );
            insert overdueProject;
            List<Project__c> overdueProjects = new List<Project__c>{overdueProject};

            List<Group> groups = [SELECT Id,Name FROM Group WHERE Type = 'Queue' LIMIT 1];
            System.debug(groups);
            List<GroupMember> members= [SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :groups];
            System.debug('members: ' + members);
            Group internalQueue = [SELECT Id FROM Group WHERE DeveloperName = 'Internal_queue' AND Type = 'Queue' LIMIT 1];
            GroupMember queueMember = [SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :internalQueue.Id AND UserOrGroupId = :projectManager.Id];
            
        Test.startTest();
        Database.executeBatch(new ProjectSendEmailBatch());
        ProjectUtils.sendOverdueProjectsEmail(overdueProjects);
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(1, invocations, 'An email should have been sent for the overdue project.');
           
    }
    
    @isTest
    static void testSendOverdueProjectsEmailEmpty() {
        Test.startTest();
        ProjectUtils.sendOverdueProjectsEmail(new List<Project__c>());
        Integer invocations = Limits.getEmailInvocations();
        Test.stopTest();

        System.assertEquals(0, invocations, 'An email shouldn`t be sent');
    }
}
    