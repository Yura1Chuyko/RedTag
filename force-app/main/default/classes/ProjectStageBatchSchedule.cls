global with sharing class ProjectStageBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        Id batchId = Database.executeBatch(new ProjectStageBatch());
    }
}