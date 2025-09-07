// Insert full policy document
Policy_Document__c decisionEnginePolicy = new Policy_Document__c();

decisionEnginePolicy.Title__c = 'Decision Engine Service Policy & ML Model Documentation';
decisionEnginePolicy.Category__c = 'Decision Engine';
decisionEnginePolicy.Keywords__c = 'decision, approval, ML model, logistic regression, risk factors, probability, scoring, denial';
decisionEnginePolicy.Summary__c = 'ML model using logistic regression for loan decisions with risk-based categories (APPROVED, APPROVED_WITH_CONDITIONS, PENDING_REVIEW, DENIED). Includes feature engineering, decision thresholds, interest rate calculations, and regulatory compliance guidelines.';

// Core policy content
decisionEnginePolicy.Content__c = 'DECISION ENGINE SERVICE POLICY - VERSION 1.0\n\n' +
'EXECUTIVE SUMMARY:\n' +
'The Decision Engine Service employs a sophisticated Machine Learning model based on logistic regression to make loan approval decisions. This document details the model decision-making process, risk factors, and business rules.\n\n' +
'DECISION CATEGORIES:\n' +
'1. APPROVED (Probability >= 75%) - Full approval, competitive rates\n' +
'2. APPROVED_WITH_CONDITIONS (Probability 50-74%) - Conditional approval, higher rates, reduced amounts\n' +
'3. PENDING_REVIEW (Probability 30-49%) - Manual review required\n' +
'4. DENIED (Probability < 30%) - Automatic denial\n\n' +
'CORE RISK FACTORS AND WEIGHTS:\n' +
'- Credit Score: Weight 5.2 (Highest impact) - Normalized (score-300)/550\n' +
'- Previous Defaults: Weight -6.0 (Severe negative impact) - Binary 0 or 1\n' +
'- Debt-to-Income Ratio: Weight -2.5 (High negative impact) - Capped at 60%\n' +
'- Loan-to-Income Ratio: Weight -1.8 (High negative impact)\n' +
'- Employment Stability: Weight 1.5 (Medium positive impact) - Years/10\n' +
'- Term Risk: Weight -0.8 (Medium negative impact) - Term/84 months\n' +
'- Loan Amount: Weight -0.5 (Low negative impact) - Amount/100000\n\n' +
'MODEL EQUATION:\n' +
'Logit = 0.5 + (5.2 × CreditScore) + (-1.8 × LTI) + (-2.5 × DTI) + (1.5 × Employment) + (-6.0 × Defaults) + (-0.5 × LoanSize) + (-0.8 × TermRisk)\n' +
'Approval Probability = 1 ÷ (1 + e^(-Logit))\n\n' +
'APPROVAL THRESHOLDS BY RISK LEVEL:\n' +
'- Low Risk (Prob >= 75%): 100% of requested amount, rates 5.5%-9.0%, no conditions\n' +
'- Medium Risk (50-74%): 80% of requested amount, rates 8.0%-12.5%, income/employment verification required\n' +
'- Medium-High Risk (30-49%): Manual review required, rates 12.0%-18.0%, comprehensive review\n' +
'- High Risk (<30%): Denied, multiple risk factors present\n\n' +
'CREDIT SCORE IMPACT BANDS:\n' +
'- Excellent (750+): Premium rates, full approval likelihood\n' +
'- Good (700-749): Standard rates, high approval likelihood\n' +
'- Fair (650-699): Higher rates, conditional approvals common\n' +
'- Poor (600-649): Significant restrictions, manual review required\n' +
'- Very Poor (<600): Typically denied unless exceptional circumstances\n\n' +
'INTEREST RATE CALCULATION:\n' +
'Final Rate = Base Rate (5.5%) + Risk Premium\n' +
'Risk Premium = (1 - Approval Probability) × 15%\n' +
'Higher risk scores result in higher interest rate premiums\n\n' +
'COMMON DENIAL REASON CODES:\n' +
'- LOW_CREDIT_SCORE: Credit score below acceptable threshold\n' +
'- HIGH_DTI_RATIO: Debt-to-income ratio exceeds 43% guideline\n' +
'- INSUFFICIENT_INCOME: Income insufficient for loan amount\n' +
'- UNVERIFIABLE_INCOME: Cannot verify stated income\n' +
'- EXCESSIVE_LOAN_AMOUNT: Loan amount too high relative to income\n' +
'- UNSTABLE_EMPLOYMENT: Employment history less than minimum requirement\n\n' +
'KEY DECISION SCENARIOS:\n' +
'HIGH APPROVAL (85% Probability): 780 credit score, $75K income, $25K loan, 5 years employment, 25% DTI\n' +
'CONDITIONAL (65% Probability): 690 credit score, $50K income, $20K loan, 18 months employment, 38% DTI\n' +
'MANUAL REVIEW (35% Probability): 640 credit score, $45K income, $30K loan, 6 months employment, 41% DTI\n' +
'DENIAL (15% Probability): 580 credit score, $35K income, $25K loan, recent default, 48% DTI\n\n' +
'REGULATORY COMPLIANCE:\n' +
'- Equal Credit Opportunity Act (ECOA): Model excludes protected class variables\n' +
'- Fair Credit Reporting Act (FCRA): Credit decisions based on authorized bureau data\n' +
'- Truth in Lending Act (TILA): Rate calculations include all applicable fees\n\n' +
'TROUBLESHOOTING COMMON QUESTIONS:\n' +
'Q: Why was application denied despite good income?\n' +
'A: Check credit score (most common), DTI ratio accuracy, previous defaults, employment stability\n\n' +
'Q: Why is interest rate high?\n' +
'A: Rates = Base Rate + Risk Premium based on approval probability. Lower probability = higher premium\n\n' +
'Q: Why lower approval amount than requested?\n' +
'A: APPROVED_WITH_CONDITIONS decisions approve 80% of requested amount for risk management\n\n' +
'MODEL PERFORMANCE METRICS:\n' +
'- Precision: 92% accurate prediction of loan performance\n' +
'- Recall: 88% successful identification of good loans\n' +
'- False Positive Rate: 8% (approved loans that default)\n' +
'- False Negative Rate: 12% (denied loans that would have performed)\n\n' +
'This policy serves as the authoritative reference for all decision engine operations and loan approval processes.';

try {
    insert decisionEnginePolicy;
    System.debug('SUCCESS: Full policy document inserted with ID: ' + decisionEnginePolicy.Id);
    
    // Query to verify
    Policy_Document__c inserted = [SELECT Id, Name, Title__c, Category__c FROM Policy_Document__c WHERE Id = :decisionEnginePolicy.Id];
    System.debug('Inserted record: ' + inserted.Name + ' - ' + inserted.Title__c);
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('ERROR TYPE: ' + e.getTypeName());
}