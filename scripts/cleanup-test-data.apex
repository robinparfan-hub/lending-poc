/**
 * Script to clean up test loan data
 * 
 * Usage in Anonymous Apex:
 * 1. To delete all test data (be careful!):
 *    CleanupTestData.deleteAllTestData();
 * 
 * 2. To delete specific loan application and related data:
 *    CleanupTestData.deleteByApplicationId('a00xx000000000');
 * 
 * 3. To delete by applicant email:
 *    CleanupTestData.deleteByApplicantEmail('test@example.com');
 * 
 * 4. To delete applications created in last N hours:
 *    CleanupTestData.deleteRecentApplications(24);
 */
public class CleanupTestData {
    
    /**
     * Delete all test data - USE WITH CAUTION
     */
    public static void deleteAllTestData() {
        System.debug('Starting cleanup of ALL test data...');
        
        // First delete Decisions (child records)
        List<Decision__c> decisions = [SELECT Id FROM Decision__c];
        if (!decisions.isEmpty()) {
            delete decisions;
            System.debug('Deleted ' + decisions.size() + ' Decision records');
        }
        
        // Then delete Loan Applications
        List<Loan_Application__c> applications = [SELECT Id FROM Loan_Application__c];
        if (!applications.isEmpty()) {
            delete applications;
            System.debug('Deleted ' + applications.size() + ' Loan Application records');
        }
        
        // Finally delete Applicant Profiles
        List<Applicant_Profile__c> profiles = [SELECT Id FROM Applicant_Profile__c];
        if (!profiles.isEmpty()) {
            delete profiles;
            System.debug('Deleted ' + profiles.size() + ' Applicant Profile records');
        }
        
        System.debug('Cleanup completed');
    }
    
    /**
     * Delete specific loan application and all related data
     */
    public static void deleteByApplicationId(String applicationId) {
        System.debug('Deleting data for Application ID: ' + applicationId);
        
        // Get the application and related applicant
        List<Loan_Application__c> apps = [
            SELECT Id, Applicant_Profile__c 
            FROM Loan_Application__c 
            WHERE Id = :applicationId
        ];
        
        if (apps.isEmpty()) {
            System.debug('No application found with ID: ' + applicationId);
            return;
        }
        
        Loan_Application__c app = apps[0];
        Id applicantProfileId = app.Applicant_Profile__c;
        
        // Delete related Decisions first
        List<Decision__c> decisions = [
            SELECT Id 
            FROM Decision__c 
            WHERE Loan_Application__c = :applicationId
        ];
        if (!decisions.isEmpty()) {
            delete decisions;
            System.debug('Deleted ' + decisions.size() + ' Decision records');
        }
        
        // Delete the Loan Application
        delete app;
        System.debug('Deleted Loan Application: ' + applicationId);
        
        // Check if applicant has other applications
        if (applicantProfileId != null) {
            Integer otherApps = [
                SELECT COUNT() 
                FROM Loan_Application__c 
                WHERE Applicant_Profile__c = :applicantProfileId
            ];
            
            if (otherApps == 0) {
                // No other applications, safe to delete profile
                delete new Applicant_Profile__c(Id = applicantProfileId);
                System.debug('Deleted Applicant Profile: ' + applicantProfileId);
            } else {
                System.debug('Applicant Profile has ' + otherApps + ' other applications, not deleting');
            }
        }
        
        System.debug('Cleanup completed for Application: ' + applicationId);
    }
    
    /**
     * Delete all data for a specific applicant by email
     */
    public static void deleteByApplicantEmail(String email) {
        System.debug('Deleting data for applicant email: ' + email);
        
        // Find applicant profile
        List<Applicant_Profile__c> profiles = [
            SELECT Id 
            FROM Applicant_Profile__c 
            WHERE Email__c = :email
        ];
        
        if (profiles.isEmpty()) {
            System.debug('No applicant found with email: ' + email);
            return;
        }
        
        Id profileId = profiles[0].Id;
        
        // Find all loan applications for this applicant
        List<Loan_Application__c> apps = [
            SELECT Id 
            FROM Loan_Application__c 
            WHERE Applicant_Profile__c = :profileId
        ];
        
        Set<Id> appIds = new Set<Id>();
        for (Loan_Application__c app : apps) {
            appIds.add(app.Id);
        }
        
        // Delete all related Decisions
        List<Decision__c> decisions = [
            SELECT Id 
            FROM Decision__c 
            WHERE Loan_Application__c IN :appIds
        ];
        if (!decisions.isEmpty()) {
            delete decisions;
            System.debug('Deleted ' + decisions.size() + ' Decision records');
        }
        
        // Delete all Loan Applications
        if (!apps.isEmpty()) {
            delete apps;
            System.debug('Deleted ' + apps.size() + ' Loan Application records');
        }
        
        // Delete Applicant Profile
        delete profiles[0];
        System.debug('Deleted Applicant Profile for: ' + email);
        
        System.debug('Cleanup completed for email: ' + email);
    }
    
    /**
     * Delete recent test applications (useful for cleaning up after testing)
     */
    public static void deleteRecentApplications(Integer hoursAgo) {
        DateTime cutoff = DateTime.now().addHours(-hoursAgo);
        System.debug('Deleting applications created after: ' + cutoff);
        
        // Find recent applications
        List<Loan_Application__c> apps = [
            SELECT Id, Applicant_Profile__c, CreatedDate
            FROM Loan_Application__c 
            WHERE CreatedDate > :cutoff
            ORDER BY CreatedDate DESC
        ];
        
        if (apps.isEmpty()) {
            System.debug('No applications found in the last ' + hoursAgo + ' hours');
            return;
        }
        
        Set<Id> appIds = new Set<Id>();
        Set<Id> profileIds = new Set<Id>();
        
        for (Loan_Application__c app : apps) {
            appIds.add(app.Id);
            if (app.Applicant_Profile__c != null) {
                profileIds.add(app.Applicant_Profile__c);
            }
        }
        
        // Delete related Decisions
        List<Decision__c> decisions = [
            SELECT Id 
            FROM Decision__c 
            WHERE Loan_Application__c IN :appIds
        ];
        if (!decisions.isEmpty()) {
            delete decisions;
            System.debug('Deleted ' + decisions.size() + ' Decision records');
        }
        
        // Delete Loan Applications
        delete apps;
        System.debug('Deleted ' + apps.size() + ' recent Loan Applications');
        
        // Check which profiles can be deleted (no other applications)
        for (Id profileId : profileIds) {
            Integer otherApps = [
                SELECT COUNT() 
                FROM Loan_Application__c 
                WHERE Applicant_Profile__c = :profileId
            ];
            
            if (otherApps == 0) {
                delete new Applicant_Profile__c(Id = profileId);
                System.debug('Deleted orphaned Applicant Profile: ' + profileId);
            }
        }
        
        System.debug('Cleanup completed for recent applications');
    }
    
    /**
     * Dry run - just show what would be deleted
     */
    public static void previewCleanup() {
        Integer decisionCount = [SELECT COUNT() FROM Decision__c];
        Integer applicationCount = [SELECT COUNT() FROM Loan_Application__c];
        Integer profileCount = [SELECT COUNT() FROM Applicant_Profile__c];
        
        System.debug('===== CLEANUP PREVIEW =====');
        System.debug('Decision records: ' + decisionCount);
        System.debug('Loan Application records: ' + applicationCount);
        System.debug('Applicant Profile records: ' + profileCount);
        System.debug('===========================');
        
        // Show recent applications
        List<Loan_Application__c> recentApps = [
            SELECT Id, Name, Status__c, CreatedDate, 
                   Applicant_Profile__r.Name, Applicant_Profile__r.Email__c
            FROM Loan_Application__c
            ORDER BY CreatedDate DESC
            LIMIT 5
        ];
        
        System.debug('Recent Applications:');
        for (Loan_Application__c app : recentApps) {
            System.debug('  - ' + app.Name + ' (' + app.Status__c + ') - ' + 
                        app.Applicant_Profile__r.Name + ' - ' + 
                        app.CreatedDate.format());
        }
    }
}

// Example usage commands (run these in Anonymous Apex):
// CleanupTestData.previewCleanup();  // See what would be deleted
// CleanupTestData.deleteRecentApplications(1);  // Delete last hour's data
// CleanupTestData.deleteByApplicantEmail('test@example.com');  // Delete by email
// CleanupTestData.deleteByApplicationId('a00xx000000000');  // Delete specific app
// CleanupTestData.deleteAllTestData();  // Delete everything (careful!)