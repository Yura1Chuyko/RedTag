trigger ProjectTrigger on Project__c (after update) {
    if (Trigger.isAfter && Trigger.isUpdate) {
        ProjectTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
    }
}