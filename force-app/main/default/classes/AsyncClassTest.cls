@isTest
public class AsyncClassTest {
    
    // Helper method to set up test data
    private static Set<Id> setupTestData() {
        List<Case> testCases = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            testCases.add(new Case(
                Subject = 'Test Case ' + i,
                Status = 'New'
            ));
        }
        insert testCases;

        Set<Id> caseIds = new Set<Id>();
        for (Case caseRecord : testCases) {
            caseIds.add(caseRecord.Id);
        }
        return caseIds;
    }
    
    @isTest
    static void testCallBatch() {
        Set<Id> caseIds = setupTestData();
        
        Test.startTest();
        // Call the batch method
        AsyncClass.callBatch(caseIds);
        Test.stopTest();

        // Verify cases have been updated by the batch process
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Id IN :caseIds];
        for (Case caseRecord : cases) {
            System.assertEquals('Batch Processed', caseRecord.Status, 'Case status should be updated by batch');
        }
    }
    
    @isTest
    static void testCallFuture() {
        Set<Id> caseIds = setupTestData();
        
        Test.startTest();
        // Call the future method
        AsyncClass.callFuture(caseIds);
        Test.stopTest();
        
        // Verify cases have been updated by the future method
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Id IN :caseIds];
        for (Case caseRecord : cases) {
            System.assertEquals('Future Processed', caseRecord.Status, 'Case status should be updated by future method');
        }
    }
    
    @isTest
    static void testCallQueueable() {
        Set<Id> caseIds = setupTestData();
        
        Test.startTest();
        // Call the queueable method
        AsyncClass.callQueueable(caseIds);
        Test.stopTest();

        // Verify cases have been updated by the queueable method
        List<Case> cases = [SELECT Id, Status FROM Case WHERE Id IN :caseIds];
        for (Case caseRecord : cases) {
            System.assertEquals('Queueable Processed', caseRecord.Status, 'Case status should be updated by queueable process');
        }
    }
}
