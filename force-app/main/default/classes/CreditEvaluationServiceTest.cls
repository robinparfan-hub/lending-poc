/**
 * @description Test class for CreditEvaluationService
 * @author Lending POC Team
 * @date 2025-09-03
 */
@IsTest
private class CreditEvaluationServiceTest {
    
    @IsTest
    static void testEvaluateCreditScoreSuccess() {
        String testApplicantId = 'APPLICANT-001';
        
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.evaluateCreditScoreById(testApplicantId);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
        Assert.isTrue(response.data.containsKey('creditScore'), 'Should contain credit score');
        Assert.isTrue(response.data.containsKey('creditGrade'), 'Should contain credit grade');
        Assert.isTrue(response.data.containsKey('riskLevel'), 'Should contain risk level');
        Assert.isTrue(response.data.containsKey('bureau'), 'Should contain bureau');
        
        // Verify credit score is in valid range
        Decimal creditScore = (Decimal)response.data.get('creditScore');
        Assert.isTrue(creditScore >= 300 && creditScore <= 850, 'Credit score should be in valid range');
    }
    
    @IsTest
    static void testEvaluateCreditScoreWithRequest() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicantId', 'APPLICANT-002');
        
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.evaluateCreditScore(request);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
    }
    
    @IsTest
    static void testEvaluateCreditScoreNullApplicantId() {
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.evaluateCreditScoreById((String)null);
        Test.stopTest();
        
        // Verify validation error
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.areEqual('VALIDATION_ERROR', response.errorCode, 'Should return validation error');
        Assert.isTrue(response.message.contains('Applicant ID'), 'Error message should mention applicant ID');
    }
    
    @IsTest
    static void testEvaluateCreditScoreBlankApplicantId() {
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.evaluateCreditScoreById('');
        Test.stopTest();
        
        // Verify validation error
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.areEqual('VALIDATION_ERROR', response.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testEvaluateCreditScoreNullRequest() {
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.evaluateCreditScore((ServiceRequest)null);
        Test.stopTest();
        
        // Verify validation error
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.areEqual('VALIDATION_ERROR', response.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testGetCreditReportSuccess() {
        String testApplicationId = 'APP-001';
        
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.getCreditReportById(testApplicationId);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
        Assert.isTrue(response.data.containsKey('creditScore'), 'Should contain credit score');
        Assert.isTrue(response.data.containsKey('reportId'), 'Should contain report ID');
        Assert.isTrue(response.data.containsKey('tradelines'), 'Should contain tradelines');
        Assert.isTrue(response.data.containsKey('inquiries'), 'Should contain inquiries');
    }
    
    @IsTest
    static void testGetCreditReportWithRequest() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicationId', 'APP-002');
        
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.getCreditReport(request);
        Test.stopTest();
        
        // Verify successful response with enhanced data
        Assert.areEqual(true, response.success, 'Response should be successful');
        List<Object> tradelines = (List<Object>)response.data.get('tradelines');
        Assert.isNotNull(tradelines, 'Should have tradelines');
        Assert.isTrue(tradelines.size() > 0, 'Should have at least one tradeline');
        
        List<Object> inquiries = (List<Object>)response.data.get('inquiries');
        Assert.isNotNull(inquiries, 'Should have inquiries');
    }
    
    @IsTest
    static void testGetCreditReportNullApplicationId() {
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.getCreditReportById((String)null);
        Test.stopTest();
        
        // Verify validation error
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.areEqual('VALIDATION_ERROR', response.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testCalculateCreditRiskSuccess() {
        Decimal testCreditScore = 720;
        String testLoanType = 'Personal';
        
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.calculateCreditRiskByParams(testCreditScore, testLoanType);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
        Assert.areEqual(testCreditScore, response.data.get('creditScore'), 'Should contain original credit score');
        Assert.areEqual(testLoanType, response.data.get('loanType'), 'Should contain loan type');
        Assert.isTrue(response.data.containsKey('riskLevel'), 'Should contain risk level');
        Assert.isTrue(response.data.containsKey('riskPercentage'), 'Should contain risk percentage');
        Assert.isTrue(response.data.containsKey('rateAdjustment'), 'Should contain rate adjustment');
    }
    
    @IsTest
    static void testCalculateCreditRiskLowRisk() {
        Decimal excellentCreditScore = 780;
        String loanType = 'Auto';
        
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.calculateCreditRiskByParams(excellentCreditScore, loanType);
        Test.stopTest();
        
        // Verify low risk calculation
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual('LOW', response.data.get('riskLevel'), 'Should be low risk for excellent credit');
        Assert.areEqual(-0.5, response.data.get('rateAdjustment'), 'Should have rate discount for low risk');
    }
    
    @IsTest
    static void testCalculateCreditRiskHighRisk() {
        Decimal lowCreditScore = 580;
        String loanType = 'Personal';
        
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.calculateCreditRiskByParams(lowCreditScore, loanType);
        Test.stopTest();
        
        // Verify high risk calculation
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual('HIGH', response.data.get('riskLevel'), 'Should be high risk for low credit');
        Assert.areEqual(3.0, response.data.get('rateAdjustment'), 'Should have rate premium for high risk');
    }
    
    @IsTest
    static void testCalculateCreditRiskMediumRisk() {
        Decimal mediumCreditScore = 720;
        String loanType = 'Auto';
        
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.calculateCreditRiskByParams(mediumCreditScore, loanType);
        Test.stopTest();
        
        // Verify medium risk calculation
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual('MEDIUM', response.data.get('riskLevel'), 'Should be medium risk');
        Assert.areEqual(0.0, response.data.get('rateAdjustment'), 'Should have no rate adjustment for medium risk');
    }
    
    @IsTest
    static void testCalculateCreditRiskMediumHighRisk() {
        Decimal fairCreditScore = 680;
        String loanType = 'Personal';
        
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.calculateCreditRiskByParams(fairCreditScore, loanType);
        Test.stopTest();
        
        // Verify medium-high risk calculation
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual('MEDIUM_HIGH', response.data.get('riskLevel'), 'Should be medium-high risk');
        Assert.areEqual(1.0, response.data.get('rateAdjustment'), 'Should have rate premium for medium-high risk');
    }
    
    @IsTest
    static void testCalculateCreditRiskLoanTypeAdjustment() {
        Decimal creditScore = 700;
        
        Test.startTest();
        ServiceResponse personalResponse = CreditEvaluationService.calculateCreditRiskByParams(creditScore, 'Personal');
        ServiceResponse autoResponse = CreditEvaluationService.calculateCreditRiskByParams(creditScore, 'Auto');
        ServiceResponse mortgageResponse = CreditEvaluationService.calculateCreditRiskByParams(creditScore, 'Mortgage');
        Test.stopTest();
        
        // Verify loan type affects risk calculation
        Decimal personalRisk = (Decimal)personalResponse.data.get('riskPercentage');
        Decimal autoRisk = (Decimal)autoResponse.data.get('riskPercentage');
        Decimal mortgageRisk = (Decimal)mortgageResponse.data.get('riskPercentage');
        
        Assert.isTrue(personalRisk > autoRisk, 'Personal loan should have higher risk than auto loan');
        Assert.isTrue(autoRisk > mortgageRisk, 'Auto loan should have higher risk than mortgage');
    }
    
    @IsTest
    static void testCalculateCreditRiskInvalidCreditScore() {
        Test.startTest();
        ServiceResponse lowResponse = CreditEvaluationService.calculateCreditRiskByParams(250, 'Personal'); // Too low
        ServiceResponse highResponse = CreditEvaluationService.calculateCreditRiskByParams(900, 'Personal'); // Too high
        ServiceResponse nullResponse = CreditEvaluationService.calculateCreditRiskByParams(null, 'Personal'); // Null
        Test.stopTest();
        
        // Verify validation errors
        Assert.areEqual(false, lowResponse.success, 'Should reject credit score below 300');
        Assert.areEqual('VALIDATION_ERROR', lowResponse.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, highResponse.success, 'Should reject credit score above 850');
        Assert.areEqual('VALIDATION_ERROR', highResponse.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, nullResponse.success, 'Should reject null credit score');
        Assert.areEqual('VALIDATION_ERROR', nullResponse.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testCalculateCreditRiskInvalidLoanType() {
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.calculateCreditRiskByParams(720, null);
        Test.stopTest();
        
        // Verify validation error
        Assert.areEqual(false, response.success, 'Should reject null loan type');
        Assert.areEqual('VALIDATION_ERROR', response.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testCalculateCreditRiskWithRequest() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('creditScore', 720);
        request.setParameter('loanType', 'Auto');
        
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.calculateCreditRisk(request);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual('MEDIUM', response.data.get('riskLevel'), 'Should calculate correct risk level');
    }
    
    @IsTest
    static void testScenarioConsistency() {
        String testApplicantId = 'CONSISTENT-APPLICANT';
        
        Test.startTest();
        ServiceResponse response1 = CreditEvaluationService.evaluateCreditScoreById(testApplicantId);
        ServiceResponse response2 = CreditEvaluationService.evaluateCreditScoreById(testApplicantId);
        Test.stopTest();
        
        // Same applicant should return consistent results
        Assert.areEqual(response1.data.get('creditScore'), response2.data.get('creditScore'),
                      'Same applicant should return consistent credit score');
        Assert.areEqual(response1.data.get('riskLevel'), response2.data.get('riskLevel'),
                      'Same applicant should return consistent risk level');
    }
    
    @IsTest
    static void testErrorScenario() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicantId', 'ERROR-APPLICANT');
        request.setParameter('scenario', 'ERROR_SCENARIO');
        
        Test.startTest();
        ServiceResponse response = CreditEvaluationService.evaluateCreditScore(request);
        Test.stopTest();
        
        // Verify error scenario handling
        Assert.areEqual(false, response.success, 'Error scenario should not be successful');
        Assert.areEqual('CREDIT_BUREAU_ERROR', response.errorCode, 'Should return credit bureau error');
    }
    
    @IsTest
    static void testRiskLevelBoundaries() {
        Test.startTest();
        ServiceResponse lowRisk = CreditEvaluationService.calculateCreditRiskByParams(750, 'Auto');    // Exactly 750
        ServiceResponse mediumRisk = CreditEvaluationService.calculateCreditRiskByParams(749, 'Auto');  // Just below 750
        ServiceResponse mediumHigh = CreditEvaluationService.calculateCreditRiskByParams(650, 'Auto');  // Exactly 650
        ServiceResponse highRisk = CreditEvaluationService.calculateCreditRiskByParams(649, 'Auto');    // Just below 650
        Test.stopTest();
        
        // Verify risk level boundaries
        Assert.areEqual('LOW', lowRisk.data.get('riskLevel'), 'Score of 750 should be LOW risk');
        Assert.areEqual('MEDIUM', mediumRisk.data.get('riskLevel'), 'Score of 749 should be MEDIUM risk');
        Assert.areEqual('MEDIUM_HIGH', mediumHigh.data.get('riskLevel'), 'Score of 650 should be MEDIUM_HIGH risk');
        Assert.areEqual('HIGH', highRisk.data.get('riskLevel'), 'Score of 649 should be HIGH risk');
    }
}