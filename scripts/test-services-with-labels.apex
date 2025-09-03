/**
 * Test script to demonstrate service usage with Custom Label configuration
 * Run this in Anonymous Apex to test the lending platform services
 */

// Test 1: Check current Custom Label values
System.debug('=== Current Custom Label Configuration ===');
System.debug('Use_Mock_Data: ' + System.Label.Use_Mock_Data);
System.debug('Mock_Response_Delay_Ms: ' + System.Label.Mock_Response_Delay_Ms);
System.debug('Min_Credit_Score: ' + System.Label.Min_Credit_Score);
System.debug('Max_DTI_Ratio: ' + System.Label.Max_DTI_Ratio);
System.debug('Max_Loan_Amount: ' + System.Label.Max_Loan_Amount);
System.debug('Default_Credit_Bureau: ' + System.Label.Default_Credit_Bureau);
System.debug('Enable_Service_Debug_Logging: ' + System.Label.Enable_Service_Debug_Logging);

// Test 2: Credit Evaluation Service
System.debug('\n=== Testing Credit Evaluation Service ===');
ServiceResponse creditResponse = CreditEvaluationService.evaluateCreditScoreById('APP-001-EXCEL');
System.debug('Credit Score Response: ' + JSON.serializePretty(creditResponse.data));
System.debug('Success: ' + creditResponse.success);

// Test 3: Decision Engine Service  
System.debug('\n=== Testing Decision Engine Service ===');
ServiceResponse decisionResponse = DecisionEngineService.evaluateApplicationById('APP-001-EXCEL');
System.debug('Decision Response: ' + JSON.serializePretty(decisionResponse.data));
System.debug('Success: ' + decisionResponse.success);

// Test 4: Loan Calculator Service
System.debug('\n=== Testing Loan Calculator Service ===');
ServiceResponse calcResponse = LoanCalculatorService.calculateMonthlyPaymentByParams(
    25000,  // principal
    7.5,    // annual rate
    60      // months
);
System.debug('Calculation Response: ' + JSON.serializePretty(calcResponse.data));
System.debug('Success: ' + calcResponse.success);

// Test 5: Different scenarios with MockDataFactory
System.debug('\n=== Testing Different Mock Scenarios ===');
String[] testApplicationIds = new String[]{
    'APP-001-EXCEL',       // Excellent credit
    'APP-002-GOOD',        // Good credit  
    'APP-003-CONDITION',   // Conditional approval
    'APP-004-LOWCREDIT',   // Low credit denial
    'APP-005-DTI'          // High DTI denial
};

for (String appId : testApplicationIds) {
    ServiceResponse response = DecisionEngineService.evaluateApplicationById(appId);
    Map<String, Object> data = response.data;
    System.debug('\nApplication ID: ' + appId);
    System.debug('Decision: ' + data.get('decision'));
    System.debug('Approved Amount: ' + data.get('approvedAmount'));
    System.debug('Interest Rate: ' + data.get('interestRate'));
    System.debug('Reason Codes: ' + data.get('reasonCodes'));
}

// Test 6: Risk calculation
System.debug('\n=== Testing Credit Risk Calculation ===');
ServiceResponse riskResponse = CreditEvaluationService.calculateCreditRiskByParams(
    720,        // credit score
    'Personal'  // loan type
);
System.debug('Risk Response: ' + JSON.serializePretty(riskResponse.data));

// Test 7: Early payoff calculation
System.debug('\n=== Testing Early Payoff Calculation ===');
ServiceResponse payoffResponse = LoanCalculatorService.calculateEarlyPayoffByParams(
    50000,  // principal
    8.5,    // annual rate
    60,     // total months
    12      // payments made
);
System.debug('Payoff Response: ' + JSON.serializePretty(payoffResponse.data));

System.debug('\n=== All Tests Complete ===');
System.debug('To change behavior, update Custom Labels in Setup → Custom Labels');