global with sharing class ProjectSendEmailBatchSchedule implements Schedulable  {
    global void execute(SchedulableContext sc) {
        Id batchId = Database.executeBatch(new ProjectSendEmailBatch());
    }
}