public with sharing class TaskTriggerHandler {
   public static void onBeforeInsert(List<Task> triggerNew) {
      TaskTriggerHelper.validateBudgetOnInsert(triggerNew);
   }
   public static void onAfterUpdate(List<Task> triggerNew, Map<Id, Task> triggerOldMap) {
      TaskTriggerHelper.updateSpentBudgetOnClose(triggerNew, triggerOldMap);
   }
   public static void onAfterDelete(List<Task> triggerOld) {
      TaskTriggerHelper.returnBudgetOnDelete(triggerOld);
   }
}