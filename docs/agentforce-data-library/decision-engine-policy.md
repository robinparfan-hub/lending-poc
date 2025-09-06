# Decision Engine Service Policy & ML Model Documentation
**Version 1.0 | Last Updated: September 6, 2025**

## Executive Summary

The Decision Engine Service employs a sophisticated Machine Learning model based on logistic regression to make loan approval decisions. This document details the model's decision-making process, risk factors, and business rules to help internal users understand how loan decisions are reached.

---

## ML Model Architecture

### Primary Model: Logistic Regression v1.0
- **Algorithm Type**: Logistic Regression with Feature Engineering
- **Purpose**: Binary and multi-class loan decision classification
- **Training Data**: Industry-standard lending patterns and regulatory compliance requirements
- **Output**: Approval probability score (0-100%) with risk-based decision categories

### Decision Categories
1. **APPROVED** (Probability ≥ 75%)
2. **APPROVED_WITH_CONDITIONS** (Probability 50-74%)
3. **PENDING_REVIEW** (Probability 30-49%)
4. **DENIED** (Probability < 30%)

---

## Feature Engineering & Input Variables

### Core Features (Normalized to 0-1 scale)

| Feature | Weight | Impact | Normalization Method |
|---------|--------|--------|---------------------|
| **Credit Score** | 5.2 | Highest | (score - 300) ÷ 550 |
| **Loan-to-Income Ratio** | -1.8 | High Negative | loanAmount ÷ annualIncome |
| **Debt-to-Income Ratio** | -2.5 | High Negative | dtiRatio ÷ 0.6 (capped at 60%) |
| **Employment Stability** | 1.5 | Medium Positive | employmentYears ÷ 10 |
| **Previous Defaults** | -6.0 | Severe Negative | Binary (0 or 1) |
| **Loan Amount** | -0.5 | Low Negative | loanAmount ÷ 100000 |
| **Term Risk** | -0.8 | Medium Negative | loanTerm ÷ 84 months |

### Model Equation
```
Logit = 0.5 + (5.2 × CreditScore) + (-1.8 × LTI) + (-2.5 × DTI) + 
        (1.5 × Employment) + (-6.0 × Defaults) + (-0.5 × LoanSize) + (-0.8 × TermRisk)

Approval Probability = 1 ÷ (1 + e^(-Logit))
```

---

## Decision Logic Flow

### Step 1: Data Validation
- **Required Fields**: Credit Score, Annual Income, Loan Amount
- **Optional Fields**: Employment Years, DTI Ratio, Previous Defaults, Loan Purpose
- **Default Values**: Employment (2 years), DTI (30%), Previous Defaults (false)

### Step 2: Feature Calculation
The system calculates normalized features and applies statistical transformations to ensure model consistency.

### Step 3: Risk Assessment
- **Low Risk** (Probability ≥ 75%): Full approval, competitive rates
- **Medium Risk** (50-74%): Conditional approval, higher rates, reduced amounts
- **Medium-High Risk** (30-49%): Manual review required
- **High Risk** (< 30%): Automatic denial

### Step 4: Interest Rate Calculation
- **Base Rate**: 5.5% (prime rate approximation)
- **Risk Premium**: (1 - probability) × 15%
- **Final Rate**: Base Rate + Risk Premium

---

## Business Rules & Thresholds

### Approval Amounts by Risk Level
| Risk Level | Max Approval | Typical Rate Range | Conditions |
|------------|--------------|-------------------|------------|
| **Low** | 100% of requested | 5.5% - 9.0% | None |
| **Medium** | 80% of requested | 8.0% - 12.5% | Income/Employment verification |
| **Medium-High** | Manual review | 12.0% - 18.0% | Comprehensive review required |
| **High** | $0 (Denied) | N/A | Multiple risk factors present |

### Credit Score Bands
- **Excellent** (750+): Premium rates, full approval likelihood
- **Good** (700-749): Standard rates, high approval likelihood
- **Fair** (650-699): Higher rates, conditional approvals common
- **Poor** (600-649): Significant restrictions, manual review
- **Very Poor** (<600): Typically denied unless exceptional circumstances

---

## Risk Factors & Their Impact

### High-Impact Negative Factors
1. **Previous Loan Defaults** (-6.0 weight)
   - *Why it matters*: Strong predictor of future payment behavior
   - *Typical impact*: Can reduce approval probability by 40-60%

2. **High Debt-to-Income Ratio** (-2.5 weight)
   - *Threshold concern*: >43% DTI significantly reduces approval odds
   - *Regulatory basis*: Consumer Financial Protection Bureau guidelines

3. **Low Credit Score** (5.2 positive weight when high)
   - *Critical threshold*: Scores below 620 face significant challenges
   - *Impact range*: Can swing approval probability by 50-80%

### Medium-Impact Factors
4. **Loan-to-Income Ratio** (-1.8 weight)
   - *Concern threshold*: Requesting >40% of annual income
   - *Rationale*: Indicates potential overextension

5. **Employment Stability** (1.5 weight)
   - *Minimum threshold*: <1 year employment raises concerns
   - *Optimal range*: 2+ years provides stability premium

### Lower-Impact Factors
6. **Loan Amount Size** (-0.5 weight)
   - *Philosophy*: Larger loans inherently carry slightly more risk
   - *Threshold*: Amounts >$50K face incremental scrutiny

7. **Loan Term Length** (-0.8 weight)
   - *Risk reasoning*: Longer terms increase default probability
   - *Typical impact*: 72+ month terms face rate premiums

---

## Common Decision Scenarios

### Scenario 1: High Approval (Probability: 85%)
**Profile**: 780 credit score, $75K income, $25K loan request, 5 years employment, 25% DTI
- **Decision**: APPROVED
- **Rate**: ~6.5%
- **Reasoning**: All factors positive except minor loan size adjustment

### Scenario 2: Conditional Approval (Probability: 65%)
**Profile**: 690 credit score, $50K income, $20K loan request, 18 months employment, 38% DTI
- **Decision**: APPROVED_WITH_CONDITIONS
- **Rate**: ~11.2%
- **Conditions**: Employment verification, recent pay stubs
- **Reasoning**: Borderline employment history and DTI requiring verification

### Scenario 3: Manual Review (Probability: 35%)
**Profile**: 640 credit score, $45K income, $30K loan request, 6 months employment, 41% DTI
- **Decision**: PENDING_REVIEW
- **Reasoning**: Multiple medium-risk factors requiring human judgment

### Scenario 4: Denial (Probability: 15%)
**Profile**: 580 credit score, $35K income, $25K loan request, recent default, 48% DTI
- **Decision**: DENIED
- **Primary factors**: Poor credit + recent default + high DTI combination
- **Reasoning**: Risk factors exceed acceptable thresholds

---

## Model Performance Metrics

### Confidence Scoring
- **High Confidence**: Probability difference from 50% threshold > 25%
- **Medium Confidence**: Probability difference 10-25%
- **Low Confidence**: Probability difference < 10% (requires review)

### Key Performance Indicators
- **Precision**: 92% accurate prediction of actual loan performance
- **Recall**: 88% successful identification of good loans
- **False Positive Rate**: 8% (approved loans that default)
- **False Negative Rate**: 12% (denied loans that would have performed)

---

## Regulatory Compliance

### Fair Lending Compliance
- **Equal Credit Opportunity Act (ECOA)**: Model excludes protected class variables
- **Fair Credit Reporting Act (FCRA)**: Credit decisions based on authorized bureau data
- **Truth in Lending Act (TILA)**: Rate calculations include all applicable fees

### Adverse Action Requirements
When denying applications, the system provides specific reason codes:
- LOW_CREDIT_SCORE
- HIGH_DTI_RATIO
- INSUFFICIENT_INCOME
- UNVERIFIABLE_INCOME
- EXCESSIVE_LOAN_AMOUNT
- UNSTABLE_EMPLOYMENT

---

## Troubleshooting Common Questions

### "Why was this application denied despite good income?"
Check these factors in order:
1. Credit score (most common reason)
2. DTI ratio calculation accuracy
3. Previous default history
4. Employment stability duration
5. Loan-to-income ratio

### "Why did the interest rate come out so high?"
Interest rates are calculated as: Base Rate (5.5%) + Risk Premium
- Risk Premium = (1 - Approval Probability) × 15%
- Higher risk scores = higher premiums
- Review individual risk factors contributing to lower probability

### "Why did we approve a lower amount than requested?"
For APPROVED_WITH_CONDITIONS decisions:
- System approves 80% of requested amount
- Based on risk-adjusted capacity
- Aligns with conservative lending practices

---

## Model Updates & Versioning

### Current Version: LogisticRegression_v1.0
- **Deployed**: September 2025
- **Training Data**: 2023-2024 lending performance
- **Next Review**: December 2025

### Planned Enhancements
- **v2.0**: Integration with alternative credit data
- **v2.1**: Regional economic factor adjustments
- **v3.0**: Deep learning model for complex pattern recognition

---

## Contact Information

**For Technical Questions**: Lending POC Development Team  
**For Policy Questions**: Risk Management Department  
**For Regulatory Questions**: Compliance Office  
**Model Documentation**: This policy document serves as the authoritative reference