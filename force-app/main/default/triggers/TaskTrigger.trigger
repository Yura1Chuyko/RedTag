trigger TaskTrigger on Task (before insert, after update, after delete) {
        if (Trigger.isAfter && Trigger.isUpdate) {
            TaskTriggerHandler.onAfterUpdate(Trigger.new, Trigger.oldMap);
        }
    
        if (Trigger.isBefore && Trigger.isInsert) {
            TaskTriggerHandler.onBeforeInsert(Trigger.new);
        }
    
        if (Trigger.isAfter && Trigger.isDelete) {
            TaskTriggerHandler.onAfterDelete(Trigger.old);
        }
}