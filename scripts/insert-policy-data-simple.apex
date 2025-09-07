// Simple version - Insert Decision Engine Policy record
Policy_Document__c decisionEnginePolicy = new Policy_Document__c();

decisionEnginePolicy.Title__c = 'Decision Engine Service Policy & ML Model Documentation';
decisionEnginePolicy.Category__c = 'Decision Engine';
decisionEnginePolicy.Version__c = 'Version 1.0';
decisionEnginePolicy.Keywords__c = 'decision, approval, ML model, logistic regression, risk factors, probability, scoring, denial';
decisionEnginePolicy.Summary__c = 'ML model using logistic regression for loan decisions with risk-based categories (APPROVED, APPROVED_WITH_CONDITIONS, PENDING_REVIEW, DENIED). Includes feature engineering, decision thresholds, interest rate calculations, and regulatory compliance guidelines.';

// Core policy content
decisionEnginePolicy.Content__c = 'DECISION ENGINE SERVICE POLICY\n\n' +
'DECISION CATEGORIES:\n' +
'1. APPROVED (Probability >= 75%)\n' +
'2. APPROVED_WITH_CONDITIONS (Probability 50-74%)\n' +
'3. PENDING_REVIEW (Probability 30-49%)\n' +
'4. DENIED (Probability < 30%)\n\n' +
'CORE RISK FACTORS:\n' +
'- Credit Score: Weight 5.2 (Highest impact)\n' +
'- Debt-to-Income Ratio: Weight -2.5 (High negative impact)\n' +
'- Previous Defaults: Weight -6.0 (Severe negative impact)\n' +
'- Loan-to-Income Ratio: Weight -1.8 (High negative impact)\n' +
'- Employment Stability: Weight 1.5 (Medium positive impact)\n' +
'- Loan Amount: Weight -0.5 (Low negative impact)\n' +
'- Term Risk: Weight -0.8 (Medium negative impact)\n\n' +
'APPROVAL THRESHOLDS:\n' +
'- Low Risk: 100% of requested amount, rates 5.5%-9.0%\n' +
'- Medium Risk: 80% of requested amount, rates 8.0%-12.5%\n' +
'- Medium-High Risk: Manual review required, rates 12.0%-18.0%\n' +
'- High Risk: Denied\n\n' +
'CREDIT SCORE BANDS:\n' +
'- Excellent (750+): Premium rates, full approval likelihood\n' +
'- Good (700-749): Standard rates, high approval likelihood\n' +
'- Fair (650-699): Higher rates, conditional approvals common\n' +
'- Poor (600-649): Significant restrictions, manual review\n' +
'- Very Poor (<600): Typically denied\n\n' +
'INTEREST RATE CALCULATION:\n' +
'Final Rate = Base Rate (5.5%) + Risk Premium\n' +
'Risk Premium = (1 - Approval Probability) × 15%\n\n' +
'COMMON DENIAL REASONS:\n' +
'- LOW_CREDIT_SCORE\n' +
'- HIGH_DTI_RATIO\n' +
'- INSUFFICIENT_INCOME\n' +
'- UNVERIFIABLE_INCOME\n' +
'- EXCESSIVE_LOAN_AMOUNT\n' +
'- UNSTABLE_EMPLOYMENT';

try {
    insert decisionEnginePolicy;
    System.debug('SUCCESS: Policy document inserted with ID: ' + decisionEnginePolicy.Id);
    
    // Query to verify
    Policy_Document__c inserted = [SELECT Id, Name, Title__c, Category__c FROM Policy_Document__c WHERE Id = :decisionEnginePolicy.Id];
    System.debug('Inserted record: ' + inserted.Name + ' - ' + inserted.Title__c);
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('ERROR TYPE: ' + e.getTypeName());
}