public with sharing class TestDataFactory {
    public static List<Account> createAccount(Integer numberOfAccounts, String Type) {
        List<Account> accounts = new List<Account>();
        for(Integer i=0; i<numberOfAccounts; i++) {
            Account acc = new Account();
            acc.Name = 'Thomas' + i;
            acc.Type = Type;
            accounts.add(acc);
        }
        insert accounts;
        return accounts;
    }

    public static Project__c createTestProjectForStage(Date dueDate, String initialStage) {
        Account client = [SELECT Id,Type FROM Account LIMIT 1];
        Project__c project = new Project__c(Name = 'Test Project', Due_Date__c = dueDate, Stage__c = initialStage, Client__c = client.Id);
        insert project;
        return project;
    }
    public static Project__c createTestProjectForSpentBudget(Decimal budget, Decimal spentBudget) {
        Account client = [SELECT Id,Type FROM Account LIMIT 1];
        Project__c project = new Project__c(Name = 'Test Project', Budget__c = budget, Spent_Budget__c = spentBudget,Client__c = client.Id);
        insert project;
        return project;
    }
    public static Task createTestTask(Id projectId, String status, Decimal costOfActivity) {
        Task task = new Task(WhatId = projectId, Status = status, Cost_Of_Activity__c = costOfActivity, Subject = 'Test Task');
        insert task;
        return task;
    }
    public static Task createTestTaskForUser(Id projectId, String status, Decimal costOfActivity, Id projectManagerId) {
        Task task = new Task(WhatId = projectId, Status = status, Cost_Of_Activity__c = costOfActivity, Subject = 'Test Task', OwnerId = projectManagerId);
        insert task;
        return task;
    }
}