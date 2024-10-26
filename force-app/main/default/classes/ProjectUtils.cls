    public with sharing class ProjectUtils {
        public static void projectStageOnHold(List<Project__c> projects) {
            List<Project__c> updateStageProjects = new List<Project__c>();
            for (Project__c project : projects) {
                if (project.Due_Date__c < Date.today()) {
                    project.Stage__c = 'On Hold';
                    updateStageProjects.add(project);
                }
            }
            try {
                update updateStageProjects;
            } catch (DmlException e ) { 
                System.debug('Error updating projects: ' + e.getmessage());
            }
        }

    
        public static void sendOverdueProjectsEmail(List<Project__c> overdueProjects) {
            if (overdueProjects.isEmpty()) {
                System.debug('No overdue projects to send.');
                return;
            }
            String emailBody = 'Summary of Overdue Projects:\n\n';
            for (Project__c project : overdueProjects) {
                emailBody += 'Project Name: ' + project.Name + '\n';
                emailBody += 'Due Date: ' + project.Due_Date__c + '\n';
                emailBody += 'Stage: ' + project.Stage__c + '\n';
                emailBody += 'Project Manager: ' + project.Project_Manager__r.Name + '\n\n';
            }
            Set<String> queueNames = new Set<String>{'Client_queue','Intenal_queue'}; 
           
            Group queue = [SELECT Id FROM Group WHERE DeveloperName IN :queueNames AND Type = 'Queue' LIMIT 1];
            List<User> queueMembers = [SELECT Email FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :queue.Id)];
            
            List<String> emailAddresses = new List<String>();
            
            for (User user : queueMembers) {
                emailAddresses.add(user.Email);
            }
            if (!emailAddresses.isEmpty()) {
                sendEmail(emailAddresses, 'Monthly Overdue Projects Summary', emailBody);
            }
        }
    
        private static void sendEmail(List<String> emailAddresses, String subject, String body) {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setToAddresses(emailAddresses);
            email.setSubject(subject);
            email.setPlainTextBody(body);
            try {
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
                System.debug('Email sent to: ' + String.join(emailAddresses, ', '));
            } catch (Exception e) {
                System.debug('Error sending email: ' + e.getMessage());
            }
        }
        
}