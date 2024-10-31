public class CaseBatch implements Database.Batchable<SObject> {
    private Set<Id> caseIds;
    
    public CaseBatch(Set<Id> caseIds) {
        this.caseIds = caseIds;
    }
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id FROM Case WHERE Id IN :caseIds]);
    }
    
    public void execute(Database.BatchableContext bc, List<Case> scope) {
        for (Case c : scope) {
            c.Status = 'Batch Processed'; 
        }
        update scope;
    }
    
    public void finish(Database.BatchableContext bc) {
        System.debug('Batch Process Completed.');
    }
}
