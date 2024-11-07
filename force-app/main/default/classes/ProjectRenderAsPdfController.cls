
public class ProjectRenderAsPdfController {
    public Project__c project { get; private set; }
    public List<Task> relatedTasks { get; private set; }
    public Map<String, Object> projectFields { get; private set; }

    public ProjectRenderAsPdfController(ApexPages.StandardController controller) {
        Id projectId = (Id)controller.getId();
        
        // Collect fields for Project__c from field set
        List<String> projectFieldPaths = new List<String>();
        Schema.FieldSet projectFieldSet = Schema.SObjectType.Project__c.fieldSets.PDF_ProjectFields;
        for (Schema.FieldSetMember f : projectFieldSet.getFields()) {
            projectFieldPaths.add(f.getFieldPath());
        }
        
        // Query Project with dynamic fields
        String projectQuery = 'SELECT ' + String.join(projectFieldPaths, ', ') + ' FROM Project__c WHERE Id = :projectId LIMIT 1';
        project = Database.query(projectQuery);
        
        // Store project fields in a map for easy retrieval in Visualforce
        projectFields = new Map<String, Object>();
        for (String field : projectFieldPaths) {
            projectFields.put(field, project.get(field));
        }
        
        // Collect Task fields from field set
        List<String> taskFieldPaths = new List<String>();
        Schema.FieldSet taskFieldSet = Schema.SObjectType.Task.fieldSets.PDF_TaskFields;
        for (Schema.FieldSetMember f : taskFieldSet.getFields()) {
            taskFieldPaths.add(f.getFieldPath());
        }
        
        // Query related Tasks with dynamic fields
        String taskQuery = 'SELECT ' + String.join(taskFieldPaths, ', ') + ' FROM Task WHERE WhatId = :projectId';
        relatedTasks = Database.query(taskQuery);
    }
}
