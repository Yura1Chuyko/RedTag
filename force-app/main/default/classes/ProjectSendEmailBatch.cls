global class ProjectSendEmailBatch implements Database.Batchable<SObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator([
            SELECT Id, Name, Due_Date__c, Stage__c, Project_Manager__r.Name, Owner.Name, RecordType.Name,RecordType.DeveloperName
            FROM Project__c
            WHERE Due_Date__c < :Date.today()
        ]);
    }

    global void execute(Database.BatchableContext BC, List<Project__c> scope) {
    
        ProjectUtils.sendOverdueProjectsEmail(scope);
    }

    global void finish(Database.BatchableContext BC) {
        System.debug('Monthly overdue projects email batch job completed.');
    }
}
    