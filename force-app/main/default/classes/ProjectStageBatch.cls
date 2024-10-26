global class ProjectStageBatch implements Database.Batchable<SObject> {
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
            return Database.getQueryLocator([
                SELECT Id, Stage__c, Due_Date__c FROM Project__c WHERE Due_Date__c < :Date.today()
            ]);
    }
        
    global void execute(Database.BatchableContext BC, List<Project__c> scope) {
        ProjectUtils.projectStageOnHold(scope);
    }
        
    global void finish(Database.BatchableContext BC) {
        System.debug('Batch job for updating projects completed.');
    }
}