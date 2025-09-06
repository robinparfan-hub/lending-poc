/**
 * @description Utility class for cleaning up test loan application data
 * @author Claude
 */
public with sharing class CleanupTestData {
    
    /**
     * @description Delete all applications for a specific applicant email
     * @param email The applicant's email address
     */
    public static void deleteByApplicantEmail(String email) {
        if (String.isBlank(email)) {
            System.debug('Email is required');
            return;
        }
        
        try {
            // Find all applications for this email
            List<Loan_Application__c> applications = [
                SELECT Id, Applicant_Profile__c
                FROM Loan_Application__c
                WHERE Applicant_Profile__r.Email__c = :email
            ];
            
            if (!applications.isEmpty()) {
                // Collect unique applicant profile IDs
                Set<Id> profileIds = new Set<Id>();
                Set<Id> applicationIds = new Set<Id>();
                for (Loan_Application__c app : applications) {
                    applicationIds.add(app.Id);
                    if (app.Applicant_Profile__c != null) {
                        profileIds.add(app.Applicant_Profile__c);
                    }
                }
                
                // Delete related decisions first
                List<Decision__c> decisions = [
                    SELECT Id FROM Decision__c 
                    WHERE Loan_Application__c IN :applicationIds
                ];
                if (!decisions.isEmpty()) {
                    delete decisions;
                    System.debug('Deleted ' + decisions.size() + ' related decisions');
                }
                
                // Now delete applications
                delete applications;
                System.debug('Deleted ' + applications.size() + ' applications for email: ' + email);
                
                // Now delete orphaned applicant profiles
                // Check if profiles are truly orphaned (no remaining applications)
                if (!profileIds.isEmpty()) {
                    List<Applicant_Profile__c> profilesToDelete = [
                        SELECT Id 
                        FROM Applicant_Profile__c 
                        WHERE Id IN :profileIds
                        AND Id NOT IN (SELECT Applicant_Profile__c FROM Loan_Application__c WHERE Applicant_Profile__c != null)
                    ];
                    if (!profilesToDelete.isEmpty()) {
                        delete profilesToDelete;
                        System.debug('Deleted ' + profilesToDelete.size() + ' orphaned applicant profiles');
                    }
                }
            } else {
                System.debug('No applications found for email: ' + email);
            }
        } catch (Exception e) {
            System.debug('Error deleting data: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Delete a specific application by ID
     * @param applicationId The loan application ID
     */
    public static void deleteByApplicationId(String applicationId) {
        if (String.isBlank(applicationId)) {
            System.debug('Application ID is required');
            return;
        }
        
        try {
            List<Loan_Application__c> applications = [
                SELECT Id, Applicant_Profile__c
                FROM Loan_Application__c
                WHERE Id = :applicationId
                LIMIT 1
            ];
            
            if (!applications.isEmpty()) {
                Id profileId = applications[0].Applicant_Profile__c;
                Id appId = applications[0].Id;
                
                // Delete related decisions first
                List<Decision__c> decisions = [
                    SELECT Id FROM Decision__c 
                    WHERE Loan_Application__c = :appId
                ];
                if (!decisions.isEmpty()) {
                    delete decisions;
                    System.debug('Deleted ' + decisions.size() + ' related decisions');
                }
                
                // Now delete application
                delete applications[0];
                System.debug('Deleted application: ' + applicationId);
                
                // Delete orphaned profile if no other applications reference it
                if (profileId != null) {
                    List<Loan_Application__c> otherApps = [
                        SELECT Id FROM Loan_Application__c 
                        WHERE Applicant_Profile__c = :profileId
                        AND Id != :applicationId
                    ];
                    if (otherApps.isEmpty()) {
                        delete [SELECT Id FROM Applicant_Profile__c WHERE Id = :profileId];
                        System.debug('Deleted orphaned applicant profile: ' + profileId);
                    }
                }
            } else {
                System.debug('Application not found: ' + applicationId);
            }
        } catch (Exception e) {
            System.debug('Error deleting application: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Delete all applications created in the last N hours
     * @param hours Number of hours to look back
     */
    public static void deleteRecentApplications(Integer hours) {
        if (hours == null || hours <= 0) {
            System.debug('Hours must be a positive number');
            return;
        }
        
        DateTime cutoffTime = DateTime.now().addHours(-hours);
        
        try {
            List<Loan_Application__c> applications = [
                SELECT Id, Applicant_Profile__c
                FROM Loan_Application__c
                WHERE CreatedDate >= :cutoffTime
            ];
            
            if (!applications.isEmpty()) {
                // Collect unique applicant profile IDs
                Set<Id> profileIds = new Set<Id>();
                Set<Id> applicationIds = new Set<Id>();
                for (Loan_Application__c app : applications) {
                    applicationIds.add(app.Id);
                    if (app.Applicant_Profile__c != null) {
                        profileIds.add(app.Applicant_Profile__c);
                    }
                }
                
                // Delete related decisions first
                List<Decision__c> decisions = [
                    SELECT Id FROM Decision__c 
                    WHERE Loan_Application__c IN :applicationIds
                ];
                if (!decisions.isEmpty()) {
                    delete decisions;
                    System.debug('Deleted ' + decisions.size() + ' related decisions');
                }
                
                // Now delete applications
                delete applications;
                System.debug('Deleted ' + applications.size() + ' applications created in the last ' + hours + ' hours');
                
                // Delete orphaned profiles
                if (!profileIds.isEmpty()) {
                    List<Applicant_Profile__c> profilesToDelete = [
                        SELECT Id 
                        FROM Applicant_Profile__c 
                        WHERE Id IN :profileIds
                        AND Id NOT IN (SELECT Applicant_Profile__c FROM Loan_Application__c WHERE Applicant_Profile__c != null)
                    ];
                    if (!profilesToDelete.isEmpty()) {
                        delete profilesToDelete;
                        System.debug('Deleted ' + profilesToDelete.size() + ' orphaned applicant profiles');
                    }
                }
            } else {
                System.debug('No recent applications found');
            }
        } catch (Exception e) {
            System.debug('Error deleting recent applications: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Delete all test applications (with 'test' in email)
     */
    public static void deleteAllTestApplications() {
        try {
            List<Loan_Application__c> applications = [
                SELECT Id, Applicant_Profile__c
                FROM Loan_Application__c
                WHERE Applicant_Profile__r.Email__c LIKE '%test%'
            ];
            
            if (!applications.isEmpty()) {
                // Collect unique applicant profile IDs
                Set<Id> profileIds = new Set<Id>();
                Set<Id> applicationIds = new Set<Id>();
                for (Loan_Application__c app : applications) {
                    applicationIds.add(app.Id);
                    if (app.Applicant_Profile__c != null) {
                        profileIds.add(app.Applicant_Profile__c);
                    }
                }
                
                // Delete related decisions first
                List<Decision__c> decisions = [
                    SELECT Id FROM Decision__c 
                    WHERE Loan_Application__c IN :applicationIds
                ];
                if (!decisions.isEmpty()) {
                    delete decisions;
                    System.debug('Deleted ' + decisions.size() + ' related decisions');
                }
                
                // Now delete applications
                delete applications;
                System.debug('Deleted ' + applications.size() + ' test applications');
                
                // Delete orphaned profiles
                if (!profileIds.isEmpty()) {
                    List<Applicant_Profile__c> profilesToDelete = [
                        SELECT Id 
                        FROM Applicant_Profile__c 
                        WHERE Id IN :profileIds
                        AND Id NOT IN (SELECT Applicant_Profile__c FROM Loan_Application__c WHERE Applicant_Profile__c != null)
                    ];
                    if (!profilesToDelete.isEmpty()) {
                        delete profilesToDelete;
                        System.debug('Deleted ' + profilesToDelete.size() + ' orphaned test applicant profiles');
                    }
                }
            } else {
                System.debug('No test applications found');
            }
        } catch (Exception e) {
            System.debug('Error deleting test applications: ' + e.getMessage());
            throw e;
        }
    }
    
    /**
     * @description Get statistics about current loan applications
     */
    public static void getApplicationStats() {
        try {
            Integer totalApps = [SELECT COUNT() FROM Loan_Application__c];
            Integer totalProfiles = [SELECT COUNT() FROM Applicant_Profile__c];
            Integer totalDecisions = [SELECT COUNT() FROM Decision__c];
            
            System.debug('=== Application Statistics ===');
            System.debug('Total Applications: ' + totalApps);
            System.debug('Total Applicant Profiles: ' + totalProfiles);
            System.debug('Total Decisions: ' + totalDecisions);
            
            // Status breakdown
            List<AggregateResult> statusBreakdown = [
                SELECT Status__c, COUNT(Id) cnt
                FROM Loan_Application__c
                GROUP BY Status__c
            ];
            
            System.debug('=== Status Breakdown ===');
            for (AggregateResult ar : statusBreakdown) {
                System.debug(ar.get('Status__c') + ': ' + ar.get('cnt'));
            }
        } catch (Exception e) {
            System.debug('Error getting stats: ' + e.getMessage());
        }
    }
}