# Salesforce Data Library Setup Guide for Agentforce
**ML Services Policy Documentation | September 6, 2025**

## Overview

This guide provides step-by-step instructions for loading the ML Services Policy documents into Salesforce as Data Library resources for Agentforce. This will enable Agentforce to provide detailed explanations of loan decisions and ML model behavior to internal users.

---

## Files to Upload

### 1. Core Policy Documents
- **decision-engine-policy.md** - Decision Engine ML model documentation
- **income-verification-policy.md** - Income verification statistical analysis documentation  
- **ml-services-overview.md** - Comprehensive overview of both services

### 2. Document Descriptions
Each document serves a specific purpose for Agentforce:

| Document | Purpose | Key Information |
|----------|---------|-----------------|
| **Decision Engine Policy** | Explains loan approval/denial decisions | Logistic regression model, risk factors, rate calculations |
| **Income Verification Policy** | Explains income stability and fraud detection | Statistical analysis, anomaly detection, stability scoring |
| **ML Services Overview** | Master reference document | Cross-service integration, decision scenarios, troubleshooting |

---

## Step-by-Step Upload Process

### Step 1: Access Data Library in Salesforce Setup

1. **Log into Salesforce**
   - URL: https://orgfarm-99db23b830-dev-ed.develop.my.salesforce.com
   - Username: robinjosephparfan691@agentforce.com

2. **Navigate to Data Library**
   ```
   Setup → Feature Settings → Einstein → Data Library
   ```
   OR
   ```
   Setup → Search "Data Library" → Select "Data Library"
   ```

3. **Create New Data Library (if needed)**
   - Click "New Data Library" 
   - Name: "ML Lending Services Policy Library"
   - Description: "Policy documentation for ML-enhanced lending services"

### Step 2: Upload Policy Documents

#### Upload Decision Engine Policy
1. **Click "Add Files" or "Upload"**
2. **Select File**: `decision-engine-policy.md`
3. **Set Properties**:
   - **Name**: "Decision Engine Service Policy"
   - **Description**: "Complete ML model documentation for loan decision engine including logistic regression model, risk factors, and business rules"
   - **Tags**: `decision-engine, ml-model, loan-approval, risk-assessment, logistic-regression`
   - **Category**: Policy Documentation
   - **Access Level**: Internal Users

#### Upload Income Verification Policy  
1. **Click "Add Files" or "Upload"**
2. **Select File**: `income-verification-policy.md`
3. **Set Properties**:
   - **Name**: "Income Verification Service Policy" 
   - **Description**: "Statistical analysis model for income verification, fraud detection, and stability scoring using z-score anomaly detection"
   - **Tags**: `income-verification, fraud-detection, statistical-analysis, z-score, anomaly-detection`
   - **Category**: Policy Documentation
   - **Access Level**: Internal Users

#### Upload ML Services Overview
1. **Click "Add Files" or "Upload"**
2. **Select File**: `ml-services-overview.md` 
3. **Set Properties**:
   - **Name**: "ML Services Complete Policy Overview"
   - **Description**: "Master reference document covering integration between decision engine and income verification services with comprehensive decision scenarios"
   - **Tags**: `ml-overview, lending-policy, decision-scenarios, troubleshooting, agentforce-reference`
   - **Category**: Policy Documentation
   - **Access Level**: Internal Users

### Step 3: Configure Agentforce Access

#### Grant Agentforce Permission
1. **Navigate to Permission Sets**
   ```
   Setup → Users → Permission Sets
   ```

2. **Find Agentforce Permission Set**
   - Look for "Agentforce User" or similar permission set
   - If none exists, create new permission set for Agentforce access

3. **Grant Data Library Access**
   - Select the permission set
   - Go to "Object Settings" → "Data Library" 
   - Enable: Read, View All Records
   - Go to "Object Settings" → "Data Library File"
   - Enable: Read, View All Records

#### Assign Users to Permission Set
1. **Click "Manage Assignments"** on the permission set
2. **Add Users** who need access to policy documents
3. **Include Agentforce service user** (if applicable)

### Step 4: Create Knowledge Articles (Optional Enhancement)

For better Agentforce integration, consider creating Knowledge Articles that reference the Data Library files:

#### Create Knowledge Article Template
1. **Navigate to Knowledge Setup**
   ```
   Setup → Feature Settings → Knowledge → Knowledge Settings
   ```

2. **Create Article Type**: "ML Policy Documentation"
   - Fields: Title, Summary, Policy Type, Related Documents
   - Rich Text Area for key highlights

3. **Create Sample Articles**:
   - "Understanding Loan Denials" → References Decision Engine Policy
   - "Income Verification Process" → References Income Verification Policy
   - "ML Services Quick Reference" → References Overview Document

### Step 5: Test Agentforce Access

#### Verify Data Library Integration
1. **Open Agentforce Console** (if available)
2. **Test Sample Queries**:
   - "Why was application ABC123 denied?"
   - "How does the system calculate interest rates?"
   - "What causes a low income stability score?"

3. **Check Response Quality**:
   - Agentforce should reference specific policy sections
   - Should provide accurate technical explanations
   - Should include relevant model details

---

## Agentforce Configuration

### Prompt Templates for Policy Documents

#### For Decision Engine Queries
```
When users ask about loan approvals/denials, reference the Decision Engine Service Policy document. Key areas to focus on:

- Logistic regression model with specific weights and features
- Risk level classifications (LOW/MEDIUM/MEDIUM_HIGH/HIGH)  
- Interest rate calculation formula: Base Rate + Risk Premium
- Business rules and thresholds table
- Common decision scenarios with examples

Always explain the primary factors that influenced the decision.
```

#### For Income Verification Queries
```
When users ask about income verification or stability scores, reference the Income Verification Service Policy document. Key areas:

- Z-score anomaly detection methodology
- Stability score calculation (0-100 scale with weighted factors)
- Fraud detection indicators and severity levels
- Statistical measures: mean, median, coefficient of variation
- Confidence levels (HIGH/MEDIUM/LOW) and their meanings

Provide specific explanations for score components.
```

### Common Question Mappings

| User Question | Reference Document | Key Sections |
|---------------|-------------------|--------------|
| "Why was this denied?" | Decision Engine Policy | Decision Logic Flow, Risk Factors, Decision Scenarios |
| "How is the interest rate calculated?" | Decision Engine Policy | Interest Rate Calculation, Risk Assessment |
| "What does stability score 67 mean?" | Income Verification Policy | Stability Score Calculation, Verification Confidence |
| "Why did we flag this as fraud?" | Income Verification Policy | Fraud Detection Algorithms, Common Scenarios |
| "How do both services work together?" | ML Services Overview | Service Integration, Cross-Service Decision Matrix |

---

## Maintenance & Updates

### Document Version Control
1. **Track Version Numbers** in document headers
2. **Update Modification Dates** when policies change
3. **Archive Previous Versions** for compliance
4. **Notify Stakeholders** of significant changes

### Regular Review Schedule
- **Monthly**: Performance metrics validation
- **Quarterly**: Policy accuracy review against actual outcomes
- **Annually**: Comprehensive model documentation update

### Update Process
1. **Modify Source Documents** in the `/docs/agentforce-data-library/` folder
2. **Re-upload to Data Library** with version increment
3. **Test Agentforce Responses** with updated information
4. **Archive Previous Versions** for audit trail

---

## Troubleshooting

### Common Issues & Solutions

#### "Agentforce can't access the documents"
**Solution**: Check permission sets and ensure Data Library read access is granted

#### "Responses are generic/not using policy data"
**Solution**: 
1. Verify documents are properly tagged
2. Check Agentforce prompt configuration
3. Test with specific policy-related queries

#### "Information seems outdated"
**Solution**:
1. Confirm latest document versions are uploaded
2. Check document modification dates
3. Clear any Agentforce caches if applicable

### Testing Checklist

Before going live, test these scenarios:

- [ ] **Approval Explanation**: "Why was John Smith's loan approved?"
- [ ] **Denial Reasoning**: "What caused the denial for application #12345?"
- [ ] **Rate Justification**: "How did we calculate 11.5% interest rate?"
- [ ] **Income Concerns**: "Why is the stability score only 45?"
- [ ] **Fraud Detection**: "What triggered the fraud review?"
- [ ] **General Policy**: "How does our ML decision engine work?"

---

## Expected Benefits

### For Internal Users
- **Faster Response Times**: Immediate access to detailed policy information
- **Consistent Explanations**: Standardized responses based on actual model logic
- **Better Customer Service**: Detailed explanations for loan decisions
- **Training Support**: New employees can quickly understand ML models

### For Agentforce
- **Rich Context**: Comprehensive policy data for accurate responses
- **Technical Depth**: Detailed model explanations for complex queries
- **Scenario Coverage**: Real-world examples for better user assistance
- **Regulatory Compliance**: Proper documentation for audit requirements

---

## Next Steps

1. **Upload Documents** following the step-by-step process above
2. **Configure Permissions** for appropriate user access
3. **Test Agentforce Integration** with sample queries
4. **Train Internal Users** on asking effective questions
5. **Monitor Usage** and refine based on feedback

### Success Metrics to Track
- **Response Accuracy**: % of correct Agentforce explanations
- **User Satisfaction**: Internal user feedback on explanation quality  
- **Query Resolution**: % of policy questions answered without escalation
- **Document Usage**: Most frequently referenced policy sections

---

## Contact Information

**For Setup Questions**: Salesforce Admin Team  
**For Policy Content**: Risk Management + Data Science Teams  
**For Agentforce Configuration**: AI/ML Implementation Team  
**For Document Updates**: Lending POC Development Team