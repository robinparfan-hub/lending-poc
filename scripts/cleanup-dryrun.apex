// Test Data Cleanup DRY RUN Script for Lending POC
// This script shows what test data would be deleted WITHOUT actually deleting it
// Execute this in Anonymous Apex or Developer Console

// Define test email patterns to identify test data
Set<String> testEmails = new Set<String>{
    'john.smith@example.com',
    'sarah.johnson@example.com', 
    'michael.davis@example.com',
    'emily.wilson@example.com',
    'robert.martinez@example.com'
};

System.debug('=== Lending POC Test Data Cleanup - DRY RUN MODE ===');
System.debug('⚠️  DRY RUN: No data will be deleted. This is a preview only.');
System.debug('');

// Step 1: Get all test Applicant Profiles based on email
List<Applicant_Profile__c> testApplicants = [
    SELECT Id, Name, Email__c, CreatedDate
    FROM Applicant_Profile__c 
    WHERE Email__c IN :testEmails
];

if (testApplicants.isEmpty()) {
    System.debug('✅ No test data found in the org.');
    return;
}

System.debug('📊 Test Data Found:');
System.debug('==================');

// Collect applicant IDs for related record queries
Set<Id> applicantIds = new Set<Id>();
Map<Id, String> applicantNames = new Map<Id, String>();

System.debug('');
System.debug('Applicant Profiles (' + testApplicants.size() + '):');
for (Applicant_Profile__c app : testApplicants) {
    applicantIds.add(app.Id);
    applicantNames.put(app.Id, app.Name);
    System.debug('  • ' + app.Name + ' - ' + app.Email__c + ' (Created: ' + app.CreatedDate.format() + ')');
}

// Step 2: Get all related Income Sources
List<Income_Source__c> incomeSources = [
    SELECT Id, Employer_Name__c, Monthly_Amount__c, Applicant_Profile__c
    FROM Income_Source__c 
    WHERE Applicant_Profile__c IN :applicantIds
];

if (!incomeSources.isEmpty()) {
    System.debug('');
    System.debug('Income Sources (' + incomeSources.size() + '):');
    for (Income_Source__c inc : incomeSources) {
        System.debug('  • ' + inc.Employer_Name__c + ' - $' + inc.Monthly_Amount__c + 
                    ' (For: ' + applicantNames.get(inc.Applicant_Profile__c) + ')');
    }
}

// Step 3: Get all related Loan Applications
List<Loan_Application__c> testApplications = [
    SELECT Id, Name, Amount_Requested__c, Status__c, Purpose__c, Applicant_Profile__c
    FROM Loan_Application__c 
    WHERE Applicant_Profile__c IN :applicantIds
];

Set<Id> applicationIds = new Set<Id>();
Map<Id, String> applicationNames = new Map<Id, String>();

if (!testApplications.isEmpty()) {
    System.debug('');
    System.debug('Loan Applications (' + testApplications.size() + '):');
    for (Loan_Application__c app : testApplications) {
        applicationIds.add(app.Id);
        applicationNames.put(app.Id, app.Name);
        System.debug('  • ' + app.Name + ' - $' + app.Amount_Requested__c + 
                    ' (' + app.Purpose__c + ', Status: ' + app.Status__c + 
                    ', For: ' + applicantNames.get(app.Applicant_Profile__c) + ')');
    }
}

// Step 4: Get all related Credit Reports
if (!applicationIds.isEmpty()) {
    List<Credit_Report__c> creditReports = [
        SELECT Id, Name, Credit_Score__c, Bureau_Name__c, Loan_Application__c
        FROM Credit_Report__c 
        WHERE Loan_Application__c IN :applicationIds
    ];
    
    if (!creditReports.isEmpty()) {
        System.debug('');
        System.debug('Credit Reports (' + creditReports.size() + '):');
        for (Credit_Report__c cr : creditReports) {
            System.debug('  • Score: ' + cr.Credit_Score__c + ' from ' + cr.Bureau_Name__c + 
                        ' (App: ' + applicationNames.get(cr.Loan_Application__c) + ')');
        }
    }
}

// Step 5: Get all related Decisions
if (!applicationIds.isEmpty()) {
    List<Decision__c> decisions = [
        SELECT Id, Name, Decision_Type__c, Outcome__c, Loan_Application__c
        FROM Decision__c 
        WHERE Loan_Application__c IN :applicationIds
    ];
    
    if (!decisions.isEmpty()) {
        System.debug('');
        System.debug('Decisions (' + decisions.size() + '):');
        for (Decision__c dec : decisions) {
            System.debug('  • ' + dec.Decision_Type__c + ' - ' + dec.Outcome__c + 
                        ' (App: ' + applicationNames.get(dec.Loan_Application__c) + ')');
        }
    }
}

// Step 6: Get all related Loans
if (!applicationIds.isEmpty()) {
    List<Loan__c> loans = [
        SELECT Id, Name, Principal_Amount__c, Current_Balance__c, Loan_Application__c
        FROM Loan__c 
        WHERE Loan_Application__c IN :applicationIds
    ];
    
    if (!loans.isEmpty()) {
        System.debug('');
        System.debug('Active Loans (' + loans.size() + '):');
        for (Loan__c loan : loans) {
            System.debug('  • ' + loan.Name + ' - Principal: $' + loan.Principal_Amount__c + 
                        ', Balance: $' + loan.Current_Balance__c + 
                        ' (App: ' + applicationNames.get(loan.Loan_Application__c) + ')');
        }
    }
}

// Step 7: Get all related Documents
if (!applicationIds.isEmpty()) {
    List<Document__c> documents = [
        SELECT Id, File_Name__c, Document_Type__c, Status__c, Loan_Application__c
        FROM Document__c 
        WHERE Loan_Application__c IN :applicationIds
    ];
    
    if (!documents.isEmpty()) {
        System.debug('');
        System.debug('Documents (' + documents.size() + '):');
        for (Document__c doc : documents) {
            System.debug('  • ' + doc.File_Name__c + ' (' + doc.Document_Type__c + 
                        ', Status: ' + doc.Status__c + 
                        ', App: ' + applicationNames.get(doc.Loan_Application__c) + ')');
        }
    }
}

System.debug('');
System.debug('==================');
System.debug('⚠️  This is a DRY RUN - no data was deleted.');
System.debug('Run cleanup-test-data.apex to actually delete this data.');
System.debug('==================');