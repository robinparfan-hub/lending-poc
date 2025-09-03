/**
 * @description Test class for LoanApplicationController
 * @author Lending POC Team
 * @date 2025-09-03
 */
@isTest
public class LoanApplicationControllerTest {
    
    @testSetup
    static void setupTestData() {
        // Create test applicant profile
        Applicant_Profile__c profile = new Applicant_Profile__c(
            Name = 'Test Applicant',
            Email__c = 'test@example.com',
            Phone__c = '5550100000',
            Total_Income__c = 75000,
            Employment_Status__c = 'Employed',
            Date_of_Birth__c = Date.newInstance(1985, 6, 15),
            SSN_Encrypted__c = 'XXX-XX-1234'
        );
        insert profile;
        
        // Create test loan application
        Loan_Application__c app = new Loan_Application__c(
            Applicant_Profile__c = profile.Id,
            Amount_Requested__c = 25000,
            Purpose__c = 'Home Improvement',
            Term_Months__c = 60,
            Status__c = 'Draft',
            Application_Date__c = Date.today()
        );
        insert app;
        
        // Create test decision
        Decision__c decision = new Decision__c(
            Loan_Application__c = app.Id,
            Outcome__c = 'Approved',
            Approved_Amount__c = 25000,
            Approved_Rate__c = 6.99,
            Decision_Type__c = 'Automated',
            Decision_Date__c = DateTime.now(),
            Reason_Codes__c = 'EXCELLENT_CREDIT'
        );
        insert decision;
    }
    
    @isTest
    static void testGetApplicationData() {
        // Get test application
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = LoanApplicationController.getApplicationData(app.Id);
        Test.stopTest();
        
        System.assertNotEquals(null, result, 'Result should not be null');
        System.assertEquals(true, result.get('hasAccess'), 'User should have access');
        System.assertNotEquals(null, result.get('application'), 'Application should be returned');
        
        Map<String, Object> appData = (Map<String, Object>)result.get('application');
        System.assertEquals('Draft', appData.get('Status__c'), 'Status should be Draft');
        System.assertEquals(25000, appData.get('Amount_Requested__c'), 'Amount should match');
    }
    
    @isTest
    static void testGetApplicationDataNoAccess() {
        Test.startTest();
        Map<String, Object> result = LoanApplicationController.getApplicationData('a00000000000000');
        Test.stopTest();
        
        System.assertEquals(false, result.get('hasAccess'), 'User should not have access');
        System.assertNotEquals(null, result.get('error'), 'Error message should be present');
    }
    
    @isTest
    static void testGetApplicationDataNull() {
        Test.startTest();
        Map<String, Object> result = LoanApplicationController.getApplicationData(null);
        Test.stopTest();
        
        System.assertEquals(true, result.get('hasAccess'), 'Should allow null ID');
        System.assertEquals(null, result.get('application'), 'Application should be null');
    }
    
    @isTest
    static void testSaveApplicationNew() {
        Map<String, Object> applicationData = new Map<String, Object>{
            'Amount_Requested__c' => 30000,
            'Purpose__c' => 'Debt Consolidation',
            'Term_Months__c' => 48,
            'Status__c' => 'Draft',
            'applicant' => new Map<String, Object>{
                'Name' => 'New Applicant',
                'Email__c' => 'new@example.com',
                'Phone__c' => '5550200000',
                'Total_Income__c' => 65000,
                'Employment_Status__c' => 'Self-Employed',
                'Date_of_Birth__c' => Date.newInstance(1990, 3, 20),
                'SSN_Encrypted__c' => 'XXX-XX-5678'
            }
        };
        
        Test.startTest();
        String appId = LoanApplicationController.saveApplication(applicationData);
        Test.stopTest();
        
        System.assertNotEquals(null, appId, 'Application ID should be returned');
        
        Loan_Application__c app = [SELECT Id, Amount_Requested__c, Purpose__c, Status__c 
                                   FROM Loan_Application__c WHERE Id = :appId];
        System.assertEquals(30000, app.Amount_Requested__c, 'Amount should match');
        System.assertEquals('Debt Consolidation', app.Purpose__c, 'Purpose should match');
        System.assertEquals('Draft', app.Status__c, 'Status should be Draft');
    }
    
    @isTest
    static void testSaveApplicationUpdate() {
        Loan_Application__c existingApp = [SELECT Id FROM Loan_Application__c LIMIT 1];
        
        Map<String, Object> applicationData = new Map<String, Object>{
            'Id' => existingApp.Id,
            'Amount_Requested__c' => 35000,
            'Purpose__c' => 'Business',
            'Term_Months__c' => 48,
            'Status__c' => 'Submitted'
        };
        
        Test.startTest();
        String appId = LoanApplicationController.saveApplication(applicationData);
        Test.stopTest();
        
        System.assertEquals(existingApp.Id, appId, 'Same application ID should be returned');
        
        Loan_Application__c app = [SELECT Id, Amount_Requested__c, Purpose__c, Status__c 
                                   FROM Loan_Application__c WHERE Id = :appId];
        System.assertEquals(35000, app.Amount_Requested__c, 'Amount should be updated');
        System.assertEquals('Business', app.Purpose__c, 'Purpose should be updated');
        // Status gets changed by decision engine during Test.stopTest()
        System.assertEquals('Declined', app.Status__c, 'Status should be Declined by decision engine');
    }
    
    @isTest
    static void testSaveApplicationValidationError() {
        Map<String, Object> applicationData = new Map<String, Object>{
            'Status__c' => 'Submitted'
            // Missing required fields
        };
        
        Test.startTest();
        try {
            LoanApplicationController.saveApplication(applicationData);
            System.assert(false, 'Should have thrown validation error');
        } catch (LoanApplicationException e) {
            System.assert(e.getMessage().contains('required'), 'Error should mention required fields');
        }
        Test.stopTest();
    }
    
    @isTest
    static void testAcceptLoanOffer() {
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = LoanApplicationController.acceptLoanOffer(app.Id, 'base64signature');
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'), 'Should return success');
        System.assertEquals(app.Id, result.get('applicationId'), 'Should return application ID');
        
        Loan_Application__c updatedApp = [SELECT Status__c FROM Loan_Application__c WHERE Id = :app.Id];
        System.assertEquals('Funded', updatedApp.Status__c, 'Status should be Funded');
    }
    
    @isTest
    static void testAcceptLoanOfferNoApproval() {
        // Create application without approval
        Applicant_Profile__c profile = [SELECT Id FROM Applicant_Profile__c LIMIT 1];
        Loan_Application__c app = new Loan_Application__c(
            Applicant_Profile__c = profile.Id,
            Amount_Requested__c = 15000,
            Purpose__c = 'Other',
            Term_Months__c = 36,
            Status__c = 'Draft',
            Application_Date__c = Date.today()
        );
        insert app;
        
        Test.startTest();
        try {
            LoanApplicationController.acceptLoanOffer(app.Id, 'signature');
            System.assert(false, 'Should have thrown error');
        } catch (LoanApplicationException e) {
            System.debug('Actual error message: ' + e.getMessage());
            System.assert(e.getMessage().contains('No approved offer available for acceptance'), 'Error should mention no approval. Actual: ' + e.getMessage());
        }
        Test.stopTest();
    }
    
    @isTest
    static void testDeclineLoanOffer() {
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c LIMIT 1];
        
        Test.startTest();
        Map<String, Object> result = LoanApplicationController.declineLoanOffer(app.Id, 'Changed my mind');
        Test.stopTest();
        
        System.assertEquals(true, result.get('success'), 'Should return success');
        System.assertEquals(app.Id, result.get('applicationId'), 'Should return application ID');
        
        Loan_Application__c updatedApp = [SELECT Status__c FROM Loan_Application__c WHERE Id = :app.Id];
        System.assertEquals('Cancelled', updatedApp.Status__c, 'Status should be Cancelled');
        
        List<Task> tasks = [SELECT Id, Subject, Description FROM Task WHERE WhatId = :app.Id];
        System.assertEquals(1, tasks.size(), 'Task should be created');
        System.assert(tasks[0].Description.contains('Changed my mind'), 'Task should contain reason');
    }
    
    @isTest
    static void testEvaluateApplicationAsync() {
        Loan_Application__c app = [SELECT Id FROM Loan_Application__c LIMIT 1];
        
        // Update to submitted to trigger evaluation
        Map<String, Object> applicationData = new Map<String, Object>{
            'Id' => app.Id,
            'Status__c' => 'Submitted',
            'Amount_Requested__c' => 25000,
            'Purpose__c' => 'Home Improvement',
            'Term_Months__c' => 60
        };
        
        Test.startTest();
        LoanApplicationController.saveApplication(applicationData);
        Test.stopTest();
        
        // Future method would have executed during Test.stopTest()
        // Decision engine would have processed the application
        Loan_Application__c updatedApp = [SELECT Status__c FROM Loan_Application__c WHERE Id = :app.Id];
        // Since no credit evaluation data exists, application gets declined
        System.assertEquals('Declined', updatedApp.Status__c, 'Status should be Declined by decision engine');
    }
}