/**
 * @description Test class for MockDataFactory
 * @author Lending POC Team
 * @date 2025-09-03
 */
@IsTest
private class MockDataFactoryTest {
    
    @IsTest
    static void testGenerateResponseCreditEvaluationService() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicationId', 'APP-001');
        
        Test.startTest();
        ServiceResponse response = MockDataFactory.generateResponse('CreditEvaluationService', request);
        Test.stopTest();
        
        // Verify credit evaluation response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
        Assert.isTrue(response.data.containsKey('creditScore'), 'Response should contain credit score');
        Assert.isTrue(response.data.containsKey('creditGrade'), 'Response should contain credit grade');
        Assert.isTrue(response.data.containsKey('riskLevel'), 'Response should contain risk level');
    }
    
    @IsTest
    static void testGenerateResponseDecisionEngineService() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicationId', 'APP-002');
        
        Test.startTest();
        ServiceResponse response = MockDataFactory.generateResponse('DecisionEngineService', request);
        Test.stopTest();
        
        // Verify decision engine response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
        Assert.isTrue(response.data.containsKey('decision'), 'Response should contain decision');
        Assert.isTrue(response.data.containsKey('reasonCodes'), 'Response should contain reason codes');
    }
    
    @IsTest
    static void testGenerateResponseLoanCalculatorService() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('principal', 25000);
        request.setParameter('rate', 6.5);
        request.setParameter('months', 60);
        
        Test.startTest();
        ServiceResponse response = MockDataFactory.generateResponse('LoanCalculatorService', request);
        Test.stopTest();
        
        // Verify loan calculator response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
        Assert.areEqual(25000, response.data.get('principal'), 'Principal should match input');
    }
    
    @IsTest
    static void testGenerateResponseLoanCalculatorMissingParams() {
        ServiceRequest request = new ServiceRequest();
        // Missing required parameters
        
        Test.startTest();
        ServiceResponse response = MockDataFactory.generateResponse('LoanCalculatorService', request);
        Test.stopTest();
        
        // Verify validation error response
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.areEqual('VALIDATION_ERROR', response.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testGenerateResponseUnknownService() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicationId', 'APP-003');
        
        Test.startTest();
        ServiceResponse response = MockDataFactory.generateResponse('UnknownService', request);
        Test.stopTest();
        
        // Verify unknown service error
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.areEqual('UNKNOWN_SERVICE', response.errorCode, 'Should return unknown service error');
    }
    
    @IsTest
    static void testDetermineScenarioWithExplicitParameter() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('scenario', 'APPROVED_EXCELLENT_CREDIT');
        
        Test.startTest();
        ServiceResponse response = MockDataFactory.generateResponse('CreditEvaluationService', request);
        Test.stopTest();
        
        // Verify scenario is applied (should get excellent credit response)
        Assert.areEqual(true, response.success, 'Response should be successful');
        Decimal creditScore = (Decimal)response.data.get('creditScore');
        Assert.isTrue(creditScore >= 750, 'Credit score should indicate excellent credit');
    }
    
    @IsTest
    static void testDetermineScenarioWithInvalidParameter() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('scenario', 'INVALID_SCENARIO');
        
        Test.startTest();
        ServiceResponse response = MockDataFactory.generateResponse('CreditEvaluationService', request);
        Test.stopTest();
        
        // Should fall back to default behavior (no error)
        Assert.areEqual(true, response.success, 'Response should be successful even with invalid scenario');
    }
    
    @IsTest
    static void testScenarioConsistency() {
        ServiceRequest request1 = new ServiceRequest();
        request1.setParameter('applicationId', 'APP-CONSISTENT');
        
        ServiceRequest request2 = new ServiceRequest();
        request2.setParameter('applicationId', 'APP-CONSISTENT');
        
        Test.startTest();
        ServiceResponse response1 = MockDataFactory.generateResponse('CreditEvaluationService', request1);
        ServiceResponse response2 = MockDataFactory.generateResponse('CreditEvaluationService', request2);
        Test.stopTest();
        
        // Same application ID should return same scenario
        Assert.areEqual(response1.data.get('creditScore'), response2.data.get('creditScore'), 
                      'Same application should return consistent credit score');
    }
    
    @IsTest
    static void testAllCreditScenarios() {
        List<String> scenarios = new List<String>{
            'APPROVED_EXCELLENT_CREDIT',
            'APPROVED_GOOD_CREDIT',
            'APPROVED_WITH_CONDITIONS',
            'DENIED_LOW_CREDIT',
            'DENIED_HIGH_DTI',
            'DENIED_INSUFFICIENT_INCOME',
            'PENDING_DOCUMENT_REVIEW',
            'ERROR_SCENARIO'
        };
        
        Test.startTest();
        for (String scenario : scenarios) {
            ServiceRequest request = new ServiceRequest();
            request.setParameter('scenario', scenario);
            ServiceResponse response = MockDataFactory.generateResponse('CreditEvaluationService', request);
            
            if (scenario == 'ERROR_SCENARIO') {
                Assert.areEqual(false, response.success, 'Error scenario should not be successful');
            } else {
                Assert.areEqual(true, response.success, 'Non-error scenario should be successful: ' + scenario);
                Assert.isNotNull(response.data.get('creditScore'), 'Should have credit score for scenario: ' + scenario);
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testAllDecisionScenarios() {
        List<String> scenarios = new List<String>{
            'APPROVED_EXCELLENT_CREDIT',
            'APPROVED_GOOD_CREDIT',
            'APPROVED_WITH_CONDITIONS',
            'DENIED_LOW_CREDIT',
            'DENIED_HIGH_DTI',
            'DENIED_INSUFFICIENT_INCOME',
            'PENDING_DOCUMENT_REVIEW',
            'ERROR_SCENARIO'
        };
        
        Test.startTest();
        for (String scenario : scenarios) {
            ServiceRequest request = new ServiceRequest();
            request.setParameter('scenario', scenario);
            ServiceResponse response = MockDataFactory.generateResponse('DecisionEngineService', request);
            
            if (scenario == 'ERROR_SCENARIO') {
                Assert.areEqual(false, response.success, 'Error scenario should not be successful');
            } else {
                Assert.areEqual(true, response.success, 'Non-error scenario should be successful: ' + scenario);
                Assert.isNotNull(response.data.get('decision'), 'Should have decision for scenario: ' + scenario);
                
                String decision = (String)response.data.get('decision');
                if (scenario.startsWith('APPROVED')) {
                    Assert.isTrue(decision.startsWith('APPROVED'), 'Approved scenario should have approval decision');
                    Assert.isTrue((Decimal)response.data.get('approvedAmount') > 0, 'Should have approved amount');
                } else if (scenario.startsWith('DENIED')) {
                    Assert.areEqual('DENIED', decision, 'Denied scenario should have denial decision');
                    Assert.areEqual(0, response.data.get('approvedAmount'), 'Denied should have zero approved amount');
                } else if (scenario == 'PENDING_DOCUMENT_REVIEW') {
                    Assert.areEqual('PENDING_REVIEW', decision, 'Pending scenario should have pending decision');
                }
            }
        }
        Test.stopTest();
    }
    
    @IsTest
    static void testGenerateApplicantData() {
        Test.startTest();
        Map<String, Object> excellentApplicant = MockDataFactory.generateApplicantData(MockDataFactory.Scenario.APPROVED_EXCELLENT_CREDIT);
        Map<String, Object> goodApplicant = MockDataFactory.generateApplicantData(MockDataFactory.Scenario.APPROVED_GOOD_CREDIT);
        Map<String, Object> deniedApplicant = MockDataFactory.generateApplicantData(MockDataFactory.Scenario.DENIED_LOW_CREDIT);
        Test.stopTest();
        
        // Verify excellent credit applicant
        Assert.isNotNull(excellentApplicant.get('firstName'), 'Should have first name');
        Assert.isNotNull(excellentApplicant.get('annualIncome'), 'Should have annual income');
        Assert.areEqual(85000, excellentApplicant.get('annualIncome'), 'Excellent credit should have higher income');
        
        // Verify good credit applicant
        Assert.isNotNull(goodApplicant.get('firstName'), 'Should have first name');
        Assert.areEqual(65000, goodApplicant.get('annualIncome'), 'Good credit should have moderate income');
        
        // Verify denied applicant
        Assert.isNotNull(deniedApplicant.get('firstName'), 'Should have first name');
        Assert.areEqual(45000, deniedApplicant.get('annualIncome'), 'Denied applicant should have lower income');
    }
    
    @IsTest
    static void testExceptionHandling() {
        // Test with null service name
        ServiceRequest request = new ServiceRequest();
        
        Test.startTest();
        ServiceResponse response = MockDataFactory.generateResponse(null, request);
        Test.stopTest();
        
        // Should handle gracefully
        Assert.areEqual(false, response.success, 'Should handle null service name gracefully');
    }
    
    @IsTest
    static void testDetermineScenarioWithoutApplicationId() {
        ServiceRequest request = new ServiceRequest();
        // No applicationId parameter
        
        Test.startTest();
        ServiceResponse response = MockDataFactory.generateResponse('CreditEvaluationService', request);
        Test.stopTest();
        
        // Should use default scenario
        Assert.areEqual(true, response.success, 'Should handle missing applicationId gracefully');
    }
    
    @IsTest
    static void testScenarioDistribution() {
        Set<String> observedScenarios = new Set<String>();
        
        Test.startTest();
        // Test with different application IDs to see different scenarios
        for (Integer i = 0; i < 20; i++) {
            ServiceRequest request = new ServiceRequest();
            request.setParameter('applicationId', 'APP-' + i);
            ServiceResponse response = MockDataFactory.generateResponse('CreditEvaluationService', request);
            
            if (response.success) {
                Decimal creditScore = (Decimal)response.data.get('creditScore');
                String riskLevel = (String)response.data.get('riskLevel');
                observedScenarios.add(riskLevel);
            }
        }
        Test.stopTest();
        
        // Should have variety in scenarios
        Assert.isTrue(observedScenarios.size() > 1, 'Should generate variety of scenarios');
    }
}