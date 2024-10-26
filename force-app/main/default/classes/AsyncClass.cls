public class AsyncClass {
    
    // Method to call the batch class
    public static void callBatch(Set<Id> caseIds) {
        CaseBatch batch = new CaseBatch(caseIds);
        Database.executeBatch(batch, 50);
    }
    
    @future
    public static void callFuture(Set<Id> caseIds) {
        List<Case> casesToUpdate = [SELECT Id, Status FROM Case WHERE Id IN :caseIds];
        for (Case c : casesToUpdate) {
            c.Status = 'Future Processed'; 
        }
        update casesToUpdate;
    }
    
    public static void callQueueable(Set<Id> caseIds) {
        System.enqueueJob(new CaseQueueable(caseIds));
    }
    
    public class CaseQueueable implements Queueable {
        private Set<Id> caseIds;
        
        public CaseQueueable(Set<Id> caseIds) {
            this.caseIds = caseIds;
        }
        
        public void execute(QueueableContext context) {
            List<Case> casesToUpdate = [SELECT Id, Status FROM Case WHERE Id IN :caseIds];
            for (Case c : casesToUpdate) {
                c.Status = 'Queueable Processed';
            }
            update casesToUpdate;
        }
    }
}
