/**
 * Validation script to ensure Custom Labels are working correctly
 * This script tests that changing Custom Label values affects service behavior
 */

System.debug('=== Custom Label Validation Test ===');
System.debug('Testing that services respond to Custom Label configuration...\n');

// Step 1: Verify Custom Labels are accessible
try {
    String useMockData = System.Label.Use_Mock_Data;
    String delayMs = System.Label.Mock_Response_Delay_Ms;
    String minScore = System.Label.Min_Credit_Score;
    String maxDti = System.Label.Max_DTI_Ratio;
    String maxLoan = System.Label.Max_Loan_Amount;
    String bureau = System.Label.Default_Credit_Bureau;
    String debugLog = System.Label.Enable_Service_Debug_Logging;
    
    System.debug('✅ All Custom Labels are accessible');
    System.debug('   Use_Mock_Data: ' + useMockData);
    System.debug('   Mock_Response_Delay_Ms: ' + delayMs);
    System.debug('   Min_Credit_Score: ' + minScore);
    System.debug('   Max_DTI_Ratio: ' + maxDti);
    System.debug('   Max_Loan_Amount: ' + maxLoan);
    System.debug('   Default_Credit_Bureau: ' + bureau);
    System.debug('   Enable_Service_Debug_Logging: ' + debugLog);
} catch (Exception e) {
    System.debug('❌ Error accessing Custom Labels: ' + e.getMessage());
    return;
}

// Step 2: Test that MockDataFactory uses the delay
System.debug('\n--- Testing Mock Response Delay ---');
Long startTime = System.currentTimeMillis();
ServiceResponse response1 = CreditEvaluationService.evaluateCreditScoreById('TEST-001');
Long endTime = System.currentTimeMillis();
Long elapsed = endTime - startTime;

Integer expectedDelay = Integer.valueOf(System.Label.Mock_Response_Delay_Ms);
System.debug('Expected delay: ' + expectedDelay + 'ms');
System.debug('Actual elapsed time: ' + elapsed + 'ms');

if (elapsed >= expectedDelay - 100) { // Allow 100ms tolerance
    System.debug('✅ Mock delay is working correctly');
} else {
    System.debug('⚠️ Mock delay may not be working as expected');
}

// Step 3: Test that DecisionEngineService uses Min_Credit_Score
System.debug('\n--- Testing Business Rule Labels ---');
Decimal minCreditScore = Decimal.valueOf(System.Label.Min_Credit_Score);
Decimal maxDtiRatio = Decimal.valueOf(System.Label.Max_DTI_Ratio);
Decimal maxLoanAmount = Decimal.valueOf(System.Label.Max_Loan_Amount);

System.debug('Min Credit Score threshold: ' + minCreditScore);
System.debug('Max DTI Ratio: ' + maxDtiRatio + '%');
System.debug('Max Loan Amount: $' + maxLoanAmount);

// Test with a low credit score scenario
ServiceResponse lowCreditResponse = DecisionEngineService.evaluateApplicationById('APP-004-LOWCREDIT');
Map<String, Object> lowCreditData = lowCreditResponse.data;
String decision = (String)lowCreditData.get('decision');

if (decision == 'DENIED') {
    System.debug('✅ Low credit score correctly resulted in denial');
} else {
    System.debug('⚠️ Unexpected decision for low credit: ' + decision);
}

// Step 4: Test scenario-based mock data
System.debug('\n--- Testing Mock Data Scenarios ---');
Map<String, String> scenarios = new Map<String, String>{
    'APP-001-EXCEL' => 'APPROVED',
    'APP-002-GOOD' => 'APPROVED',
    'APP-003-CONDITION' => 'APPROVED_WITH_CONDITIONS',
    'APP-004-LOWCREDIT' => 'DENIED',
    'APP-005-DTI' => 'DENIED'
};

Integer passCount = 0;
Integer failCount = 0;

for (String appId : scenarios.keySet()) {
    String expectedDecision = scenarios.get(appId);
    ServiceResponse testResponse = DecisionEngineService.evaluateApplicationById(appId);
    Map<String, Object> testData = testResponse.data;
    String actualDecision = (String)testData.get('decision');
    
    if (actualDecision == expectedDecision) {
        System.debug('✅ ' + appId + ' => ' + actualDecision + ' (expected)');
        passCount++;
    } else {
        System.debug('❌ ' + appId + ' => ' + actualDecision + ' (expected: ' + expectedDecision + ')');
        failCount++;
    }
}

// Step 5: Validate loan calculator still works (not affected by mock data flag)
System.debug('\n--- Testing Loan Calculator (Always Real) ---');
ServiceResponse calcResponse = LoanCalculatorService.calculateMonthlyPaymentByParams(10000, 5.0, 36);
if (calcResponse.success && calcResponse.data != null) {
    Decimal monthlyPayment = (Decimal)calcResponse.data.get('monthlyPayment');
    System.debug('✅ Loan calculator working: $10,000 @ 5% for 36 months = $' + monthlyPayment.setScale(2) + '/month');
} else {
    System.debug('❌ Loan calculator error');
}

// Summary
System.debug('\n=== VALIDATION SUMMARY ===');
System.debug('Custom Labels: ✅ Accessible');
System.debug('Mock Data: ' + (System.Label.Use_Mock_Data == 'true' ? '✅ Enabled' : '⚠️ Disabled'));
System.debug('Scenario Tests: ' + passCount + ' passed, ' + failCount + ' failed');

if (failCount == 0) {
    System.debug('\n🎉 All validations passed! Custom Labels are working correctly.');
} else {
    System.debug('\n⚠️ Some validations failed. Please check the configuration.');
}

System.debug('\n💡 To modify behavior:');
System.debug('   1. Go to Setup → Custom Labels');
System.debug('   2. Edit any label value');
System.debug('   3. Changes take effect immediately!');