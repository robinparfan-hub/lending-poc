// Test Data Creation Script for Lending POC Alpha Demo
// Execute this in Anonymous Apex or Developer Console

// Create Applicant Profiles
List<Applicant_Profile__c> applicants = new List<Applicant_Profile__c>();

Applicant_Profile__c applicant1 = new Applicant_Profile__c(
    Name = 'John Smith',
    Email__c = 'john.smith@example.com',
    Phone__c = '5550000101',
    Date_of_Birth__c = Date.newInstance(1985, 3, 15),
    Address__c = '123 Main Street, San Francisco, CA 94105',
    Employment_Status__c = 'Employed',
    SSN_Encrypted__c = '***-**-1234'
);
applicants.add(applicant1);

Applicant_Profile__c applicant2 = new Applicant_Profile__c(
    Name = 'Sarah Johnson',
    Email__c = 'sarah.johnson@example.com',
    Phone__c = '5550000102',
    Date_of_Birth__c = Date.newInstance(1990, 7, 22),
    Address__c = '456 Oak Avenue, San Francisco, CA 94107',
    Employment_Status__c = 'Self-Employed',
    SSN_Encrypted__c = '***-**-5678'
);
applicants.add(applicant2);

Applicant_Profile__c applicant3 = new Applicant_Profile__c(
    Name = 'Michael Davis',
    Email__c = 'michael.davis@example.com',
    Phone__c = '5550000103',
    Date_of_Birth__c = Date.newInstance(1978, 11, 8),
    Address__c = '789 Pine Street, San Francisco, CA 94109',
    Employment_Status__c = 'Employed',
    SSN_Encrypted__c = '***-**-9012'
);
applicants.add(applicant3);

Applicant_Profile__c applicant4 = new Applicant_Profile__c(
    Name = 'Emily Wilson',
    Email__c = 'emily.wilson@example.com',
    Phone__c = '5550000104',
    Date_of_Birth__c = Date.newInstance(1995, 1, 30),
    Address__c = '321 Elm Boulevard, San Francisco, CA 94110',
    Employment_Status__c = 'Employed',
    SSN_Encrypted__c = '***-**-3456'
);
applicants.add(applicant4);

Applicant_Profile__c applicant5 = new Applicant_Profile__c(
    Name = 'Robert Martinez',
    Email__c = 'robert.martinez@example.com',
    Phone__c = '5550000105',
    Date_of_Birth__c = Date.newInstance(1982, 5, 18),
    Address__c = '654 Maple Drive, San Francisco, CA 94112',
    Employment_Status__c = 'Retired',
    SSN_Encrypted__c = '***-**-7890'
);
applicants.add(applicant5);

insert applicants;

// Create Income Sources for applicants
List<Income_Source__c> incomeSources = new List<Income_Source__c>();

Income_Source__c income1 = new Income_Source__c(
    Applicant_Profile__c = applicant1.Id,
    Employer_Name__c = 'Tech Corp Inc.',
    Monthly_Amount__c = 8500,
    Type__c = 'Employment',
    Frequency__c = 'Monthly',
    Is_Verified__c = true,
    Verification_Date__c = Date.today().addDays(-8)
);
incomeSources.add(income1);

Income_Source__c income2 = new Income_Source__c(
    Applicant_Profile__c = applicant2.Id,
    Employer_Name__c = 'Johnson Consulting LLC',
    Monthly_Amount__c = 12000,
    Type__c = 'Self-Employment',
    Frequency__c = 'Monthly',
    Is_Verified__c = true,
    Verification_Date__c = Date.today().addDays(-3)
);
incomeSources.add(income2);

Income_Source__c income3 = new Income_Source__c(
    Applicant_Profile__c = applicant3.Id,
    Employer_Name__c = 'Financial Services Co.',
    Monthly_Amount__c = 9500,
    Type__c = 'Employment',
    Frequency__c = 'Monthly',
    Is_Verified__c = true,
    Verification_Date__c = Date.today().addDays(-2)
);
incomeSources.add(income3);

Income_Source__c income4 = new Income_Source__c(
    Applicant_Profile__c = applicant3.Id,
    Employer_Name__c = 'Investment Portfolio',
    Monthly_Amount__c = 2000,
    Type__c = 'Investment',
    Frequency__c = 'Monthly',
    Is_Verified__c = true,
    Verification_Date__c = Date.today().addDays(-2)
);
incomeSources.add(income4);

Income_Source__c income5 = new Income_Source__c(
    Applicant_Profile__c = applicant4.Id,
    Employer_Name__c = 'Healthcare Systems Inc.',
    Monthly_Amount__c = 6000,
    Type__c = 'Employment',
    Frequency__c = 'Monthly',
    Is_Verified__c = false
);
incomeSources.add(income5);

Income_Source__c income6 = new Income_Source__c(
    Applicant_Profile__c = applicant5.Id,
    Employer_Name__c = 'Pension Fund',
    Monthly_Amount__c = 4500,
    Type__c = 'Retirement',
    Frequency__c = 'Monthly',
    Is_Verified__c = true,
    Verification_Date__c = Date.today().addDays(-20)
);
incomeSources.add(income6);

insert incomeSources;

// Create Loan Applications
List<Loan_Application__c> applications = new List<Loan_Application__c>();

// Application 1 - Approved Personal Loan
Loan_Application__c app1 = new Loan_Application__c(
    Applicant_Profile__c = applicant1.Id,
    Amount_Requested__c = 25000,
    Term_Months__c = 36,
    Interest_Rate__c = 7.5,
    Purpose__c = 'Home Improvement',
    Status__c = 'Approved',
    Application_Date__c = Date.today().addDays(-10)
);
applications.add(app1);

// Application 2 - Under Review Auto Loan
Loan_Application__c app2 = new Loan_Application__c(
    Applicant_Profile__c = applicant2.Id,
    Amount_Requested__c = 45000,
    Term_Months__c = 60,
    Interest_Rate__c = 5.9,
    Purpose__c = 'Auto Purchase',
    Status__c = 'Under Review',
    Application_Date__c = Date.today().addDays(-3)
);
applications.add(app2);

// Application 3 - Submitted Business Loan
Loan_Application__c app3 = new Loan_Application__c(
    Applicant_Profile__c = applicant3.Id,
    Amount_Requested__c = 85000,
    Term_Months__c = 60,
    Interest_Rate__c = 8.9,
    Purpose__c = 'Business Expansion',
    Status__c = 'Submitted',
    Application_Date__c = Date.today().addDays(-1)
);
applications.add(app3);

// Application 4 - Rejected Personal Loan
Loan_Application__c app4 = new Loan_Application__c(
    Applicant_Profile__c = applicant4.Id,
    Amount_Requested__c = 50000,
    Term_Months__c = 48,
    Interest_Rate__c = 12.5,
    Purpose__c = 'Debt Consolidation',
    Status__c = 'Declined',
    Application_Date__c = Date.today().addDays(-15)
);
applications.add(app4);

// Application 5 - Funded Mortgage
Loan_Application__c app5 = new Loan_Application__c(
    Applicant_Profile__c = applicant5.Id,
    Amount_Requested__c = 95000,
    Term_Months__c = 60,
    Interest_Rate__c = 4.5,
    Purpose__c = 'Home Purchase',
    Status__c = 'Funded',
    Application_Date__c = Date.today().addDays(-30)
);
applications.add(app5);

// Application 6 - Submitted (awaiting documents)
Loan_Application__c app6 = new Loan_Application__c(
    Applicant_Profile__c = applicant1.Id,
    Amount_Requested__c = 15000,
    Term_Months__c = 24,
    Interest_Rate__c = 9.5,
    Purpose__c = 'Medical Expenses',
    Status__c = 'Submitted',
    Application_Date__c = Date.today().addDays(-5)
);
applications.add(app6);

insert applications;

// Create Credit Reports
List<Credit_Report__c> creditReports = new List<Credit_Report__c>();

Credit_Report__c credit1 = new Credit_Report__c(
    Loan_Application__c = app1.Id,
    Credit_Score__c = 750,
    Report_Date__c = Date.today().addDays(-8),
    Bureau_Name__c = 'Equifax'
);
creditReports.add(credit1);

Credit_Report__c credit2 = new Credit_Report__c(
    Loan_Application__c = app2.Id,
    Credit_Score__c = 680,
    Report_Date__c = Date.today().addDays(-2),
    Bureau_Name__c = 'Experian'
);
creditReports.add(credit2);

Credit_Report__c credit3 = new Credit_Report__c(
    Loan_Application__c = app3.Id,
    Credit_Score__c = 820,
    Report_Date__c = Date.today().addDays(-1),
    Bureau_Name__c = 'TransUnion'
);
creditReports.add(credit3);

Credit_Report__c credit4 = new Credit_Report__c(
    Loan_Application__c = app4.Id,
    Credit_Score__c = 580,
    Report_Date__c = Date.today().addDays(-14),
    Bureau_Name__c = 'Equifax'
);
creditReports.add(credit4);

Credit_Report__c credit5 = new Credit_Report__c(
    Loan_Application__c = app5.Id,
    Credit_Score__c = 720,
    Report_Date__c = Date.today().addDays(-25),
    Bureau_Name__c = 'Experian'
);
creditReports.add(credit5);

insert creditReports;

// Create Decisions for some applications
List<Decision__c> decisions = new List<Decision__c>();

Decision__c decision1 = new Decision__c(
    Loan_Application__c = app1.Id,
    Decision_Type__c = 'Approval',
    Decision_Date__c = Date.today().addDays(-7),
    Outcome__c = 'Approved',
    Reason_Codes__c = 'Good credit score and stable income',
    Approved_Amount__c = 25000,
    Approved_Rate__c = 7.5
);
decisions.add(decision1);

Decision__c decision2 = new Decision__c(
    Loan_Application__c = app4.Id,
    Decision_Type__c = 'Rejection',
    Decision_Date__c = Date.today().addDays(-12),
    Outcome__c = 'Rejected',
    Reason_Codes__c = 'Insufficient credit score and high debt-to-income ratio'
);
decisions.add(decision2);

Decision__c decision3 = new Decision__c(
    Loan_Application__c = app5.Id,
    Decision_Type__c = 'Approval',
    Decision_Date__c = Date.today().addDays(-28),
    Outcome__c = 'Approved',
    Reason_Codes__c = 'Excellent credit history and substantial down payment',
    Approved_Amount__c = 95000,
    Approved_Rate__c = 4.5
);
decisions.add(decision3);

insert decisions;

// Create Loans for approved and funded applications
List<Loan__c> loans = new List<Loan__c>();

Loan__c loan1 = new Loan__c(
    Loan_Application__c = app1.Id,
    Principal_Amount__c = 25000,
    Current_Balance__c = 25000,
    Disbursement_Date__c = Date.today().addDays(-5),
    Maturity_Date__c = Date.today().addMonths(36),
    Payment_Schedule__c = 'Monthly'
);
loans.add(loan1);

Loan__c loan2 = new Loan__c(
    Loan_Application__c = app5.Id,
    Principal_Amount__c = 95000,
    Current_Balance__c = 93500,
    Disbursement_Date__c = Date.today().addDays(-25),
    Maturity_Date__c = Date.today().addMonths(360),
    Payment_Schedule__c = 'Monthly'
);
loans.add(loan2);

insert loans;

// Create Documents
List<Document__c> documents = new List<Document__c>();

Document__c doc1 = new Document__c(
    Loan_Application__c = app1.Id,
    Document_Type__c = 'Income Verification',
    File_Name__c = 'Pay_Stub_John_Smith.pdf',
    Status__c = 'Verified',
    Upload_Date__c = Date.today().addDays(-9)
);
documents.add(doc1);

Document__c doc2 = new Document__c(
    Loan_Application__c = app2.Id,
    Document_Type__c = 'Bank Statement',
    File_Name__c = 'Bank_Statement_Sarah_Johnson.pdf',
    Status__c = 'Under Review',
    Upload_Date__c = Date.today().addDays(-2)
);
documents.add(doc2);

Document__c doc3 = new Document__c(
    Loan_Application__c = app3.Id,
    Document_Type__c = 'Business License',
    File_Name__c = 'Business_Registration_Michael_Davis.pdf',
    Status__c = 'Submitted',
    Upload_Date__c = Date.today()
);
documents.add(doc3);

Document__c doc4 = new Document__c(
    Loan_Application__c = app5.Id,
    Document_Type__c = 'Property Appraisal',
    File_Name__c = 'Home_Appraisal_Report.pdf',
    Status__c = 'Verified',
    Upload_Date__c = Date.today().addDays(-26)
);
documents.add(doc4);

Document__c doc5 = new Document__c(
    Loan_Application__c = app6.Id,
    Document_Type__c = 'Medical Bills',
    File_Name__c = 'Hospital_Invoice.pdf',
    Status__c = 'Submitted',
    Upload_Date__c = Date.today().addDays(-4)
);
documents.add(doc5);

insert documents;

System.debug('Test data created successfully!');
System.debug('Created ' + applicants.size() + ' Applicant Profiles');
System.debug('Created ' + incomeSources.size() + ' Income Sources');
System.debug('Created ' + applications.size() + ' Loan Applications');
System.debug('Created ' + creditReports.size() + ' Credit Reports');
System.debug('Created ' + decisions.size() + ' Decisions');
System.debug('Created ' + loans.size() + ' Loans');
System.debug('Created ' + documents.size() + ' Documents');