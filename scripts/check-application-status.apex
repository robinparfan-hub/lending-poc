/**
 * Script to check loan application status and related decisions
 * Run this in Anonymous Apex to see the current state of your applications
 */

// Find the most recent application
List<Loan_Application__c> recentApps = [
    SELECT Id, Name, Status__c, Amount_Requested__c, Purpose__c,
           CreatedDate, LastModifiedDate,
           Applicant_Profile__r.Name, Applicant_Profile__r.Email__c,
           (SELECT Id, Outcome__c, Decision_Type__c, Decision_Date__c,
                   Approved_Amount__c, Approved_Rate__c, Reason_Codes__c
            FROM Decisions__r
            ORDER BY Decision_Date__c DESC)
    FROM Loan_Application__c
    ORDER BY CreatedDate DESC
    LIMIT 5
];

System.debug('===== RECENT LOAN APPLICATIONS =====');
for (Loan_Application__c app : recentApps) {
    System.debug('');
    System.debug('Application: ' + app.Name);
    System.debug('  Status: ' + app.Status__c);
    System.debug('  Amount: $' + app.Amount_Requested__c);
    System.debug('  Purpose: ' + app.Purpose__c);
    System.debug('  Applicant: ' + app.Applicant_Profile__r.Name + ' (' + app.Applicant_Profile__r.Email__c + ')');
    System.debug('  Created: ' + app.CreatedDate);
    System.debug('  Last Modified: ' + app.LastModifiedDate);
    
    if (!app.Decisions__r.isEmpty()) {
        System.debug('  --- Decisions ---');
        for (Decision__c dec : app.Decisions__r) {
            System.debug('    Decision ID: ' + dec.Id);
            System.debug('    Outcome: ' + dec.Outcome__c);
            System.debug('    Type: ' + dec.Decision_Type__c);
            System.debug('    Date: ' + dec.Decision_Date__c);
            System.debug('    Approved Amount: $' + dec.Approved_Amount__c);
            System.debug('    Rate: ' + dec.Approved_Rate__c + '%');
            System.debug('    Reason Codes: ' + dec.Reason_Codes__c);
        }
    } else {
        System.debug('  No decisions found');
    }
}

// Check if there are any async jobs pending
Integer pendingJobs = [SELECT COUNT() FROM AsyncApexJob 
                       WHERE Status IN ('Holding', 'Queued', 'Preparing', 'Processing')
                       AND ApexClass.Name = 'LoanApplicationController'];
System.debug('');
System.debug('Pending async jobs: ' + pendingJobs);