@isTest
public class TaskTemplateEditControllerTest {
    
    @isTest
    static void testGetFieldSetFields() {
        Task_Template__c taskTemplate = new Task_Template__c(
            Name = 'Sample Task Template',
            Priority__c = 'Low',
            Stage__c = 'Preparation',
            Execution_Time__c = 10,
            Cost_Of_Activity__c = 3000
        );
        insert taskTemplate;

        Test.startTest();
        List<String> fieldSetFields = TaskTemplateEditController.getFieldSetFields('Task_Template__c', 'Fields_To_Edit');
        Test.stopTest();
        
        System.assertNotEquals(null, fieldSetFields, 'Field names should not be null');
        System.assert(!fieldSetFields.isEmpty(), 'Field names list should not be empty');
        
        System.assert(fieldSetFields.contains('Execution_Time__c'), 'Field set should contain ExpectedField1__c');
        System.assert(fieldSetFields.contains('Stage__c'), 'Field set should contain ExpectedField2__c');
    }
}
