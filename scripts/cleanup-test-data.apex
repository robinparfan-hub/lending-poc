// Test Data Cleanup Script for Lending POC
// This script removes all test data created by create-test-data.apex
// Execute this in Anonymous Apex or Developer Console

// Define test email patterns to identify test data
Set<String> testEmails = new Set<String>{
    'john.smith@example.com',
    'sarah.johnson@example.com', 
    'michael.davis@example.com',
    'emily.wilson@example.com',
    'robert.martinez@example.com'
};

// Track deletion counts
Integer documentsDeleted = 0;
Integer loansDeleted = 0;
Integer decisionsDeleted = 0;
Integer creditReportsDeleted = 0;
Integer applicationsDeleted = 0;
Integer incomeSourcesDeleted = 0;
Integer applicantsDeleted = 0;

try {
    // Start transaction for rollback capability
    Savepoint sp = Database.setSavepoint();
    
    System.debug('=== Starting Lending POC Test Data Cleanup ===');
    
    // Step 1: Get all test Applicant Profiles based on email
    List<Applicant_Profile__c> testApplicants = [
        SELECT Id, Name, Email__c 
        FROM Applicant_Profile__c 
        WHERE Email__c IN :testEmails
    ];
    
    if (testApplicants.isEmpty()) {
        System.debug('No test data found to delete.');
        return;
    }
    
    System.debug('Found ' + testApplicants.size() + ' test applicant profiles to delete');
    
    // Collect applicant IDs for related record queries
    Set<Id> applicantIds = new Set<Id>();
    for (Applicant_Profile__c app : testApplicants) {
        applicantIds.add(app.Id);
        System.debug('  - ' + app.Name + ' (' + app.Email__c + ')');
    }
    
    // Step 2: Get all related Loan Applications
    List<Loan_Application__c> testApplications = [
        SELECT Id, Name 
        FROM Loan_Application__c 
        WHERE Applicant_Profile__c IN :applicantIds
    ];
    
    Set<Id> applicationIds = new Set<Id>();
    for (Loan_Application__c app : testApplications) {
        applicationIds.add(app.Id);
    }
    
    System.debug('Found ' + testApplications.size() + ' loan applications to delete');
    
    // Step 3: Delete Documents (depends on Loan Applications)
    if (!applicationIds.isEmpty()) {
        List<Document__c> documents = [
            SELECT Id, File_Name__c 
            FROM Document__c 
            WHERE Loan_Application__c IN :applicationIds
        ];
        
        if (!documents.isEmpty()) {
            delete documents;
            documentsDeleted = documents.size();
            System.debug('Deleted ' + documentsDeleted + ' documents');
        }
    }
    
    // Step 4: Delete Loans (depends on Loan Applications)
    if (!applicationIds.isEmpty()) {
        List<Loan__c> loans = [
            SELECT Id, Name 
            FROM Loan__c 
            WHERE Loan_Application__c IN :applicationIds
        ];
        
        if (!loans.isEmpty()) {
            delete loans;
            loansDeleted = loans.size();
            System.debug('Deleted ' + loansDeleted + ' loans');
        }
    }
    
    // Step 5: Delete Decisions (depends on Loan Applications)
    if (!applicationIds.isEmpty()) {
        List<Decision__c> decisions = [
            SELECT Id, Name 
            FROM Decision__c 
            WHERE Loan_Application__c IN :applicationIds
        ];
        
        if (!decisions.isEmpty()) {
            delete decisions;
            decisionsDeleted = decisions.size();
            System.debug('Deleted ' + decisionsDeleted + ' decisions');
        }
    }
    
    // Step 6: Delete Credit Reports (depends on Loan Applications)
    if (!applicationIds.isEmpty()) {
        List<Credit_Report__c> creditReports = [
            SELECT Id, Name 
            FROM Credit_Report__c 
            WHERE Loan_Application__c IN :applicationIds
        ];
        
        if (!creditReports.isEmpty()) {
            delete creditReports;
            creditReportsDeleted = creditReports.size();
            System.debug('Deleted ' + creditReportsDeleted + ' credit reports');
        }
    }
    
    // Step 7: Delete Loan Applications (depends on Applicant Profiles)
    if (!testApplications.isEmpty()) {
        delete testApplications;
        applicationsDeleted = testApplications.size();
        System.debug('Deleted ' + applicationsDeleted + ' loan applications');
    }
    
    // Step 8: Delete Income Sources (depends on Applicant Profiles)
    if (!applicantIds.isEmpty()) {
        List<Income_Source__c> incomeSources = [
            SELECT Id, Employer_Name__c 
            FROM Income_Source__c 
            WHERE Applicant_Profile__c IN :applicantIds
        ];
        
        if (!incomeSources.isEmpty()) {
            delete incomeSources;
            incomeSourcesDeleted = incomeSources.size();
            System.debug('Deleted ' + incomeSourcesDeleted + ' income sources');
        }
    }
    
    // Step 9: Delete Applicant Profiles (root objects)
    if (!testApplicants.isEmpty()) {
        delete testApplicants;
        applicantsDeleted = testApplicants.size();
        System.debug('Deleted ' + applicantsDeleted + ' applicant profiles');
    }
    
    // Success - data has been deleted
    System.debug('=== Cleanup Summary ===');
    System.debug('Documents deleted: ' + documentsDeleted);
    System.debug('Loans deleted: ' + loansDeleted);
    System.debug('Decisions deleted: ' + decisionsDeleted);
    System.debug('Credit Reports deleted: ' + creditReportsDeleted);
    System.debug('Loan Applications deleted: ' + applicationsDeleted);
    System.debug('Income Sources deleted: ' + incomeSourcesDeleted);
    System.debug('Applicant Profiles deleted: ' + applicantsDeleted);
    System.debug('=== Test data cleanup completed successfully! ===');
    
} catch (Exception e) {
    System.debug('ERROR during cleanup: ' + e.getMessage());
    System.debug('Stack trace: ' + e.getStackTraceString());
    throw e; // Re-throw to ensure transaction rollback
}