/**
 * @description Test class for DecisionEngineService
 * @author Lending POC Team
 * @date 2025-09-03
 */
@IsTest
private class DecisionEngineServiceTest {
    
    @IsTest
    static void testEvaluateApplicationSuccess() {
        String testApplicationId = 'APP-001';
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.evaluateApplicationById(testApplicationId);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
        Assert.isTrue(response.data.containsKey('decision'), 'Should contain decision');
        Assert.isTrue(response.data.containsKey('reasonCodes'), 'Should contain reason codes');
        Assert.isTrue(response.data.containsKey('processedDate'), 'Should contain processed date');
        Assert.isTrue(response.data.containsKey('expirationDate'), 'Should contain expiration date');
        
        // Verify decision is valid
        String decision = (String)response.data.get('decision');
        Set<String> validDecisions = new Set<String>{
            'APPROVED', 'APPROVED_WITH_CONDITIONS', 'DENIED', 'PENDING_REVIEW'
        };
        Assert.isTrue(validDecisions.contains(decision), 'Decision should be valid: ' + decision);
    }
    
    @IsTest
    static void testEvaluateApplicationWithRequest() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicationId', 'APP-002');
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.evaluateApplication(request);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
    }
    
    @IsTest
    static void testEvaluateApplicationApprovalScenario() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicationId', 'APP-APPROVAL');
        request.setParameter('scenario', 'APPROVED_EXCELLENT_CREDIT');
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.evaluateApplication(request);
        Test.stopTest();
        
        // Verify approval response
        Assert.areEqual(true, response.success, 'Response should be successful');
        String decision = (String)response.data.get('decision');
        Assert.areEqual('APPROVED', decision, 'Should be approved for excellent credit');
        
        Decimal approvedAmount = (Decimal)response.data.get('approvedAmount');
        Assert.isTrue(approvedAmount > 0, 'Should have approved amount');
        
        Decimal interestRate = (Decimal)response.data.get('interestRate');
        Assert.isTrue(interestRate > 0, 'Should have interest rate');
        
        Integer term = (Integer)response.data.get('term');
        Assert.isTrue(term > 0, 'Should have loan term');
        
        Decimal monthlyPayment = (Decimal)response.data.get('monthlyPayment');
        Assert.isTrue(monthlyPayment > 0, 'Should have monthly payment calculated');
    }
    
    @IsTest
    static void testEvaluateApplicationDenialScenario() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicationId', 'APP-DENIAL');
        request.setParameter('scenario', 'DENIED_LOW_CREDIT');
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.evaluateApplication(request);
        Test.stopTest();
        
        // Verify denial response
        Assert.areEqual(true, response.success, 'Response should be successful');
        String decision = (String)response.data.get('decision');
        Assert.areEqual('DENIED', decision, 'Should be denied for low credit');
        
        Decimal approvedAmount = (Decimal)response.data.get('approvedAmount');
        Assert.areEqual(0, approvedAmount, 'Denied application should have zero approved amount');
        
        List<String> denialReasons = (List<String>)response.data.get('denialReasons');
        Assert.isTrue(denialReasons != null && denialReasons.size() > 0, 'Should have denial reasons');
    }
    
    @IsTest
    static void testEvaluateApplicationConditionalScenario() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicationId', 'APP-CONDITIONAL');
        request.setParameter('scenario', 'APPROVED_WITH_CONDITIONS');
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.evaluateApplication(request);
        Test.stopTest();
        
        // Verify conditional approval response
        Assert.areEqual(true, response.success, 'Response should be successful');
        String decision = (String)response.data.get('decision');
        Assert.areEqual('APPROVED_WITH_CONDITIONS', decision, 'Should be conditionally approved');
        
        List<String> conditions = (List<String>)response.data.get('conditions');
        Assert.isTrue(conditions != null && conditions.size() > 0, 'Should have conditions listed');
    }
    
    @IsTest
    static void testEvaluateApplicationPendingScenario() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicationId', 'APP-PENDING');
        request.setParameter('scenario', 'PENDING_DOCUMENT_REVIEW');
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.evaluateApplication(request);
        Test.stopTest();
        
        // Verify pending review response
        Assert.areEqual(true, response.success, 'Response should be successful');
        String decision = (String)response.data.get('decision');
        Assert.areEqual('PENDING_REVIEW', decision, 'Should be pending review');
        
        List<String> pendingItems = (List<String>)response.data.get('pendingItems');
        Assert.isTrue(pendingItems != null && pendingItems.size() > 0, 'Should have pending items listed');
    }
    
    @IsTest
    static void testEvaluateApplicationErrorScenario() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicationId', 'APP-ERROR');
        request.setParameter('scenario', 'ERROR_SCENARIO');
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.evaluateApplication(request);
        Test.stopTest();
        
        // Verify error handling
        Assert.areEqual(false, response.success, 'Error scenario should not be successful');
        Assert.isNotNull(response.errorCode, 'Should have error code');
    }
    
    @IsTest
    static void testEvaluateApplicationInvalidInput() {
        Test.startTest();
        ServiceResponse nullResponse = DecisionEngineService.evaluateApplicationById((String)null);
        ServiceResponse blankResponse = DecisionEngineService.evaluateApplicationById('');
        ServiceResponse nullRequestResponse = DecisionEngineService.evaluateApplication((ServiceRequest)null);
        Test.stopTest();
        
        // Verify validation errors
        Assert.areEqual(false, nullResponse.success, 'Should reject null application ID');
        Assert.areEqual('VALIDATION_ERROR', nullResponse.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, blankResponse.success, 'Should reject blank application ID');
        Assert.areEqual('VALIDATION_ERROR', blankResponse.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, nullRequestResponse.success, 'Should reject null request');
        Assert.areEqual('VALIDATION_ERROR', nullRequestResponse.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testGenerateDecisionSuccess() {
        Map<String, Object> evaluationResults = new Map<String, Object>();
        Map<String, Object> creditData = new Map<String, Object>{
            'creditScore' => 750,
            'riskLevel' => 'LOW'
        };
        evaluationResults.put('creditEvaluation', creditData);
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.generateDecisionByResults(evaluationResults);
        Test.stopTest();
        
        // Verify successful decision generation
        Assert.areEqual(true, response.success, 'Response should be successful');
        String decision = (String)response.data.get('decision');
        Assert.areEqual('APPROVED', decision, 'Should approve excellent credit');
        Assert.isTrue((Decimal)response.data.get('approvedAmount') > 0, 'Should have approved amount');
    }
    
    @IsTest
    static void testGenerateDecisionWithRequest() {
        Map<String, Object> evaluationResults = new Map<String, Object>();
        Map<String, Object> creditData = new Map<String, Object>{
            'creditScore' => 650,
            'riskLevel' => 'MEDIUM'
        };
        evaluationResults.put('creditEvaluation', creditData);
        
        ServiceRequest request = new ServiceRequest();
        request.setParameter('evaluationResults', evaluationResults);
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.generateDecision(request);
        Test.stopTest();
        
        // Verify decision based on fair credit
        Assert.areEqual(true, response.success, 'Response should be successful');
        String decision = (String)response.data.get('decision');
        Assert.areEqual('APPROVED_WITH_CONDITIONS', decision, 'Should conditionally approve fair credit');
    }
    
    @IsTest
    static void testGenerateDecisionBusinessRules() {
        Test.startTest();
        
        // Test excellent credit (>= 750)
        Map<String, Object> excellentCredit = new Map<String, Object>{
            'creditEvaluation' => new Map<String, Object>{'creditScore' => 780, 'riskLevel' => 'LOW'}
        };
        ServiceResponse excellentResponse = DecisionEngineService.generateDecisionByResults(excellentCredit);
        Assert.areEqual('APPROVED', excellentResponse.data.get('decision'), 'Excellent credit should be approved');
        Assert.areEqual(50000, excellentResponse.data.get('approvedAmount'), 'Should get maximum amount');
        Assert.areEqual(5.99, excellentResponse.data.get('interestRate'), 'Should get best rate');
        
        // Test good credit (680-749)
        Map<String, Object> goodCredit = new Map<String, Object>{
            'creditEvaluation' => new Map<String, Object>{'creditScore' => 720, 'riskLevel' => 'MEDIUM'}
        };
        ServiceResponse goodResponse = DecisionEngineService.generateDecisionByResults(goodCredit);
        Assert.areEqual('APPROVED', goodResponse.data.get('decision'), 'Good credit should be approved');
        Assert.areEqual(35000, goodResponse.data.get('approvedAmount'), 'Should get moderate amount');
        Assert.areEqual(8.99, goodResponse.data.get('interestRate'), 'Should get standard rate');
        
        // Test fair credit (620-679)
        Map<String, Object> fairCredit = new Map<String, Object>{
            'creditEvaluation' => new Map<String, Object>{'creditScore' => 650, 'riskLevel' => 'MEDIUM_HIGH'}
        };
        ServiceResponse fairResponse = DecisionEngineService.generateDecisionByResults(fairCredit);
        Assert.areEqual('APPROVED_WITH_CONDITIONS', fairResponse.data.get('decision'), 'Fair credit should be conditional');
        Assert.areEqual(25000, fairResponse.data.get('approvedAmount'), 'Should get reduced amount');
        Assert.areEqual(12.99, fairResponse.data.get('interestRate'), 'Should get higher rate');
        
        // Test poor credit (< 620)
        Map<String, Object> poorCredit = new Map<String, Object>{
            'creditEvaluation' => new Map<String, Object>{'creditScore' => 580, 'riskLevel' => 'HIGH'}
        };
        ServiceResponse poorResponse = DecisionEngineService.generateDecisionByResults(poorCredit);
        Assert.areEqual('DENIED', poorResponse.data.get('decision'), 'Poor credit should be denied');
        Assert.areEqual(0, poorResponse.data.get('approvedAmount'), 'Should get zero amount');
        
        Test.stopTest();
    }
    
    @IsTest
    static void testGenerateDecisionInvalidInput() {
        Test.startTest();
        ServiceResponse nullResponse = DecisionEngineService.generateDecisionByResults((Map<String, Object>)null);
        ServiceResponse emptyResponse = DecisionEngineService.generateDecisionByResults(new Map<String, Object>());
        ServiceResponse nullRequestResponse = DecisionEngineService.generateDecision((ServiceRequest)null);
        Test.stopTest();
        
        // Verify validation errors
        Assert.areEqual(false, nullResponse.success, 'Should reject null evaluation results');
        Assert.areEqual('VALIDATION_ERROR', nullResponse.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, emptyResponse.success, 'Should reject empty evaluation results');
        Assert.areEqual('VALIDATION_ERROR', emptyResponse.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, nullRequestResponse.success, 'Should reject null request');
        Assert.areEqual('VALIDATION_ERROR', nullRequestResponse.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testGenerateDecisionMissingCreditData() {
        Map<String, Object> evaluationResults = new Map<String, Object>{
            'someOtherData' => 'value'
        };
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.generateDecisionByResults(evaluationResults);
        Test.stopTest();
        
        // Should deny when credit evaluation is missing
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual('DENIED', response.data.get('decision'), 'Should deny when credit data missing');
    }
    
    @IsTest
    static void testCalculateApprovalAmountSuccess() {
        Decimal requestedAmount = 30000;
        Map<String, Object> riskFactors = new Map<String, Object>{
            'riskLevel' => 'MEDIUM'
        };
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.calculateApprovalAmountByParams(requestedAmount, riskFactors);
        Test.stopTest();
        
        // Verify successful calculation
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual(requestedAmount, response.data.get('requestedAmount'), 'Should contain requested amount');
        Assert.areEqual(riskFactors, response.data.get('riskFactors'), 'Should contain risk factors');
        Assert.isTrue(response.data.containsKey('approvedAmount'), 'Should contain approved amount');
        Assert.isTrue(response.data.containsKey('approvalRatio'), 'Should contain approval ratio');
        
        // For medium risk, should approve requested amount up to limit
        Decimal approvedAmount = (Decimal)response.data.get('approvedAmount');
        Assert.areEqual(30000, approvedAmount, 'Should approve full amount for medium risk within limit');
    }
    
    @IsTest
    static void testCalculateApprovalAmountRiskLevels() {
        Decimal requestedAmount = 60000; // Higher than some limits
        
        Test.startTest();
        Map<String, Object> lowRiskFactors = new Map<String, Object>{'riskLevel' => 'LOW'};
        ServiceResponse lowRiskResponse = DecisionEngineService.calculateApprovalAmountByParams(requestedAmount, lowRiskFactors);
        
        Map<String, Object> mediumRiskFactors = new Map<String, Object>{'riskLevel' => 'MEDIUM'};
        ServiceResponse mediumRiskResponse = DecisionEngineService.calculateApprovalAmountByParams(requestedAmount, mediumRiskFactors);
        
        Map<String, Object> highRiskFactors = new Map<String, Object>{'riskLevel' => 'HIGH'};
        ServiceResponse highRiskResponse = DecisionEngineService.calculateApprovalAmountByParams(requestedAmount, highRiskFactors);
        Test.stopTest();
        
        // Verify risk-based approval amounts
        Decimal lowRiskAmount = (Decimal)lowRiskResponse.data.get('approvedAmount');
        Decimal mediumRiskAmount = (Decimal)mediumRiskResponse.data.get('approvedAmount');
        Decimal highRiskAmount = (Decimal)highRiskResponse.data.get('approvedAmount');
        
        Assert.areEqual(60000, lowRiskAmount, 'Low risk should get full amount (within 100k limit)');
        Assert.areEqual(50000, mediumRiskAmount, 'Medium risk should be limited to 50k');
        Assert.areEqual(0, highRiskAmount, 'High risk should be denied');
    }
    
    @IsTest
    static void testCalculateApprovalAmountWithRequest() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('requestedAmount', 40000);
        request.setParameter('riskFactors', new Map<String, Object>{'riskLevel' => 'MEDIUM_HIGH'});
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.calculateApprovalAmount(request);
        Test.stopTest();
        
        // Verify successful calculation
        Assert.areEqual(true, response.success, 'Response should be successful');
        Decimal approvedAmount = (Decimal)response.data.get('approvedAmount');
        Assert.areEqual(25000, approvedAmount, 'Medium-high risk should be limited to 25k');
    }
    
    @IsTest
    static void testCalculateApprovalAmountInvalidInput() {
        Test.startTest();
        ServiceResponse negAmountResponse = DecisionEngineService.calculateApprovalAmountByParams(-1000, new Map<String, Object>());
        ServiceResponse zeroAmountResponse = DecisionEngineService.calculateApprovalAmountByParams(0, new Map<String, Object>());
        ServiceResponse nullRiskResponse = DecisionEngineService.calculateApprovalAmountByParams(25000, null);
        ServiceResponse nullRequestResponse = DecisionEngineService.calculateApprovalAmount((ServiceRequest)null);
        Test.stopTest();
        
        // Verify validation errors
        Assert.areEqual(false, negAmountResponse.success, 'Should reject negative amount');
        Assert.areEqual('VALIDATION_ERROR', negAmountResponse.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, zeroAmountResponse.success, 'Should reject zero amount');
        Assert.areEqual('VALIDATION_ERROR', zeroAmountResponse.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, nullRiskResponse.success, 'Should reject null risk factors');
        Assert.areEqual('VALIDATION_ERROR', nullRiskResponse.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, nullRequestResponse.success, 'Should reject null request');
        Assert.areEqual('VALIDATION_ERROR', nullRequestResponse.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testApplicationConsistency() {
        String testApplicationId = 'CONSISTENT-APP';
        
        Test.startTest();
        ServiceResponse response1 = DecisionEngineService.evaluateApplicationById(testApplicationId);
        ServiceResponse response2 = DecisionEngineService.evaluateApplicationById(testApplicationId);
        Test.stopTest();
        
        // Same application should return consistent results
        Assert.areEqual(response1.data.get('decision'), response2.data.get('decision'),
                      'Same application should return consistent decision');
        Assert.areEqual(response1.data.get('approvedAmount'), response2.data.get('approvedAmount'),
                      'Same application should return consistent approved amount');
    }
    
    @IsTest
    static void testExpirationDate() {
        String testApplicationId = 'APP-EXPIRATION';
        
        Test.startTest();
        ServiceResponse response = DecisionEngineService.evaluateApplicationById(testApplicationId);
        Test.stopTest();
        
        // Verify expiration date is set
        DateTime expirationDate = (DateTime)response.data.get('expirationDate');
        DateTime processedDate = (DateTime)response.data.get('processedDate');
        Assert.isNotNull(expirationDate, 'Should have expiration date');
        Assert.isNotNull(processedDate, 'Should have processed date');
        Assert.isTrue(expirationDate > processedDate, 'Expiration should be after processed date');
        
        // Should expire in 30 days
        Long daysDifference = expirationDate.date().daysBetween(processedDate.date());
        Assert.areEqual(30, Math.abs(daysDifference), 'Should expire in 30 days');
    }
}