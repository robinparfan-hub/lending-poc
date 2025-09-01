# Consumer Lending Platform - Data Model Design

## 1. Data Model Overview

The Consumer Lending Platform data model is designed to support the complete loan lifecycle while maintaining data integrity, enabling efficient reporting, and ensuring regulatory compliance. The model follows Salesforce best practices for scalability and performance.

## 2. Entity Relationship Diagram

```
                            ┌─────────────────┐
                            │    Account      │
                            │  (Individual/   │
                            │   Business)     │
                            └────────┬────────┘
                                     │ 1
                                     │
                                     │ M
                            ┌────────▼────────┐
                            │    Contact      │
                            │  (Applicant)    │
                            └────────┬────────┘
                                     │ 1
                    ┌────────────────┼────────────────┐
                    │ M              │ M              │ M
            ┌───────▼──────┐ ┌──────▼──────┐ ┌──────▼──────┐
            │ Loan         │ │ Income      │ │ Credit      │
            │ Application  │ │ Source      │ │ Report      │
            └───────┬──────┘ └─────────────┘ └─────────────┘
                    │ 1
       ┌────────────┼────────────┬────────────┬────────────┐
       │ M          │ M          │ M          │ M          │ 1
┌──────▼─────┐ ┌───▼────┐ ┌────▼────┐ ┌────▼────┐ ┌────▼────┐
│Verification│ │Document│ │ Task    │ │Decision │ │  Loan   │
└────────────┘ └────────┘ └─────────┘ └─────────┘ └─────┬───┘
                                                          │ 1
                                                          │
                                                          │ M
                                                   ┌──────▼──────┐
                                                   │  Payment    │
                                                   └─────────────┘
```

## 3. Core Objects

### 3.1 Loan_Application__c
**Purpose**: Central object tracking loan applications through the origination process

| Field Name | API Name | Type | Required | Description |
|------------|----------|------|----------|-------------|
| Application Number | Name | Auto Number | Yes | Unique identifier (APP-{0000000}) |
| Primary Applicant | Primary_Applicant__c | Lookup(Contact) | Yes | Main borrower |
| Co-Applicant | Co_Applicant__c | Lookup(Contact) | No | Co-borrower if applicable |
| Application Date | Application_Date__c | DateTime | Yes | When application was started |
| Loan Purpose | Loan_Purpose__c | Picklist | Yes | Debt consolidation, Home improvement, etc. |
| Requested Amount | Requested_Amount__c | Currency | Yes | Amount borrower is requesting |
| Requested Term | Requested_Term__c | Number | Yes | Loan term in months |
| Application Status | Status__c | Picklist | Yes | Draft, Submitted, In Review, etc. |
| Stage | Stage__c | Picklist | Yes | Intake, Verification, Underwriting, etc. |
| Channel | Channel__c | Picklist | Yes | Online, Branch, Phone, Partner |
| Source Campaign | Source_Campaign__c | Lookup(Campaign) | No | Marketing campaign source |
| Assigned To | Assigned_To__c | Lookup(User) | No | Loan officer/processor |
| Property State | Property_State__c | Picklist | Yes | State for compliance |
| IP Address | IP_Address__c | Text(15) | No | For fraud detection |
| Device Fingerprint | Device_Fingerprint__c | Text(255) | No | For fraud detection |
| Submission Date | Submission_Date__c | DateTime | No | When formally submitted |
| Decision Date | Decision_Date__c | DateTime | No | When decision was made |
| Funding Date | Funding_Date__c | DateTime | No | When loan was funded |
| Decline Reasons | Decline_Reasons__c | Multi-Select | No | If declined, why |
| External ID | External_ID__c | Text(255) | No | ID from external system |

**Validation Rules**:
- Requested_Amount must be between $1,000 and $100,000
- Requested_Term must be between 12 and 84 months
- Co_Applicant cannot be same as Primary_Applicant
- Submission_Date cannot be before Application_Date

**Workflows/Process Builder**:
- Auto-assign based on round-robin or capacity
- Send notifications on status changes
- Calculate days in stage
- Trigger verification processes

### 3.2 Applicant_Profile__c
**Purpose**: Detailed information about loan applicants

| Field Name | API Name | Type | Required | Description |
|------------|----------|------|----------|-------------|
| Contact | Contact__c | Master-Detail(Contact) | Yes | Link to Contact record |
| SSN | SSN__c | Text(11) Encrypted | Yes | Social Security Number |
| Date of Birth | Date_of_Birth__c | Date | Yes | For age verification |
| Annual Income | Annual_Income__c | Currency | Yes | Stated annual income |
| Employment Status | Employment_Status__c | Picklist | Yes | Employed, Self-Employed, etc. |
| Employer Name | Employer_Name__c | Text(100) | No | Current employer |
| Employment Start Date | Employment_Start_Date__c | Date | No | Job start date |
| Years at Address | Years_at_Address__c | Number | Yes | Housing stability |
| Housing Status | Housing_Status__c | Picklist | Yes | Own, Rent, Other |
| Monthly Housing Payment | Monthly_Housing_Payment__c | Currency | Yes | Rent/mortgage |
| Phone Verified | Phone_Verified__c | Checkbox | No | Phone verification status |
| Email Verified | Email_Verified__c | Checkbox | No | Email verification status |
| Identity Verified | Identity_Verified__c | Checkbox | No | ID verification status |
| Bankruptcy History | Bankruptcy_History__c | Checkbox | No | Previous bankruptcy |
| Military Service | Military_Service__c | Picklist | No | Active, Veteran, None |
| Preferred Language | Preferred_Language__c | Picklist | No | Communication preference |

**Security**:
- Field-level encryption on SSN
- Restricted field access for PII
- Audit trail on all changes

### 3.3 Income_Source__c
**Purpose**: Track multiple income sources per applicant

| Field Name | API Name | Type | Required | Description |
|------------|----------|------|----------|-------------|
| Applicant | Applicant__c | Master-Detail(Contact) | Yes | Income owner |
| Income Type | Income_Type__c | Picklist | Yes | W2, 1099, Business, etc. |
| Source Name | Source_Name__c | Text(100) | Yes | Employer/source |
| Monthly Amount | Monthly_Amount__c | Currency | Yes | Monthly income |
| Annual Amount | Annual_Amount__c | Formula | Yes | Monthly * 12 |
| Start Date | Start_Date__c | Date | No | When income started |
| End Date | End_Date__c | Date | No | If income ended |
| Is Primary | Is_Primary__c | Checkbox | No | Primary income source |
| Verification Status | Verification_Status__c | Picklist | Yes | Unverified, Verified, Failed |
| Verification Method | Verification_Method__c | Picklist | No | Bank, Paystub, Tax Return |
| Verification Date | Verification_Date__c | DateTime | No | When verified |
| Documentation | Documentation__c | Files | No | Supporting documents |
| Confidence Score | Confidence_Score__c | Percent | No | Verification confidence |

### 3.4 Credit_Report__c
**Purpose**: Store credit bureau data and scores

| Field Name | API Name | Type | Required | Description |
|------------|----------|------|----------|-------------|
| Applicant | Applicant__c | Lookup(Contact) | Yes | Report subject |
| Loan Application | Loan_Application__c | Lookup | No | Related application |
| Bureau | Bureau__c | Picklist | Yes | Experian, Equifax, TransUnion |
| Pull Type | Pull_Type__c | Picklist | Yes | Soft, Hard |
| Pull Date | Pull_Date__c | DateTime | Yes | When pulled |
| FICO Score | FICO_Score__c | Number | Yes | Credit score |
| Score Model | Score_Model__c | Text(20) | Yes | FICO 8, VantageScore 3.0 |
| Total Debt | Total_Debt__c | Currency | No | Total outstanding debt |
| Monthly Debt Payment | Monthly_Debt_Payment__c | Currency | No | Total monthly obligations |
| Number of Accounts | Number_of_Accounts__c | Number | No | Open accounts |
| Oldest Account Age | Oldest_Account_Age__c | Number | No | In months |
| Recent Inquiries | Recent_Inquiries__c | Number | No | Last 6 months |
| Delinquencies | Delinquencies__c | Number | No | 30+ day late payments |
| Collections | Collections__c | Number | No | Accounts in collections |
| Bankruptcies | Bankruptcies__c | Number | No | Bankruptcy filings |
| Credit Utilization | Credit_Utilization__c | Percent | No | Credit usage ratio |
| Report JSON | Report_JSON__c | Long Text | No | Full report data |
| Report File | Report_File__c | Files | No | PDF report |

**Data Retention**:
- Soft pulls retained for 2 years
- Hard pulls retained for 7 years
- Automatic purge of old records

### 3.5 Verification__c
**Purpose**: Track all verification activities

| Field Name | API Name | Type | Required | Description |
|------------|----------|------|----------|-------------|
| Loan Application | Loan_Application__c | Master-Detail | Yes | Parent application |
| Verification Type | Verification_Type__c | Picklist | Yes | Identity, Income, Employment, etc. |
| Status | Status__c | Picklist | Yes | Pending, In Progress, Completed, Failed |
| Provider | Provider__c | Picklist | No | Jumio, Plaid, etc. |
| Request Date | Request_Date__c | DateTime | Yes | When initiated |
| Response Date | Response_Date__c | DateTime | No | When completed |
| Result | Result__c | Picklist | No | Pass, Fail, Manual Review |
| Confidence Score | Confidence_Score__c | Percent | No | Provider confidence |
| Raw Response | Raw_Response__c | Long Text | No | Provider response |
| Failure Reason | Failure_Reason__c | Text(255) | No | If failed, why |
| Retry Count | Retry_Count__c | Number | No | Number of attempts |
| Manual Override | Manual_Override__c | Checkbox | No | If manually approved |
| Override Reason | Override_Reason__c | Text(255) | No | Justification |
| Override By | Override_By__c | Lookup(User) | No | Who overrode |

### 3.6 Decision__c
**Purpose**: Capture underwriting decisions

| Field Name | API Name | Type | Required | Description |
|------------|----------|------|----------|-------------|
| Loan Application | Loan_Application__c | Lookup | Yes | Application decided |
| Decision Type | Decision_Type__c | Picklist | Yes | Auto, Manual, Override |
| Decision | Decision__c | Picklist | Yes | Approved, Declined, Counteroffer |
| Decision Date | Decision_Date__c | DateTime | Yes | When decided |
| Decided By | Decided_By__c | Lookup(User) | No | For manual decisions |
| Approved Amount | Approved_Amount__c | Currency | No | If approved |
| Approved Term | Approved_Term__c | Number | No | In months |
| Interest Rate | Interest_Rate__c | Percent | No | APR |
| Monthly Payment | Monthly_Payment__c | Currency | No | Calculated payment |
| Risk Tier | Risk_Tier__c | Picklist | No | A, B, C, D, E |
| Risk Score | Risk_Score__c | Number | No | Internal score |
| Decline Reasons | Decline_Reasons__c | Multi-Select | No | Adverse action reasons |
| Conditions | Conditions__c | Long Text | No | Approval conditions |
| Rules Evaluated | Rules_Evaluated__c | Long Text | No | Decision logic |
| Offer Expiration | Offer_Expiration__c | Date | No | When offer expires |
| Offer Accepted | Offer_Accepted__c | Checkbox | No | If borrower accepted |

### 3.7 Loan__c
**Purpose**: Funded loan records

| Field Name | API Name | Type | Required | Description |
|------------|----------|------|----------|-------------|
| Loan Number | Name | Auto Number | Yes | Unique ID (LN-{0000000}) |
| Account | Account__c | Lookup | Yes | Borrower account |
| Primary Borrower | Primary_Borrower__c | Lookup(Contact) | Yes | Main borrower |
| Co-Borrower | Co_Borrower__c | Lookup(Contact) | No | If applicable |
| Loan Application | Loan_Application__c | Lookup | Yes | Origin application |
| Original Amount | Original_Amount__c | Currency | Yes | Funded amount |
| Current Balance | Current_Balance__c | Currency | Yes | Outstanding balance |
| Interest Rate | Interest_Rate__c | Percent | Yes | Current APR |
| Term | Term__c | Number | Yes | In months |
| Monthly Payment | Monthly_Payment__c | Currency | Yes | Regular payment |
| Origination Date | Origination_Date__c | Date | Yes | Funding date |
| First Payment Date | First_Payment_Date__c | Date | Yes | First due date |
| Maturity Date | Maturity_Date__c | Date | Yes | Final payment date |
| Status | Status__c | Picklist | Yes | Current, Delinquent, Paid Off, Charged Off |
| Days Past Due | Days_Past_Due__c | Number | No | If delinquent |
| Last Payment Date | Last_Payment_Date__c | Date | No | Most recent payment |
| Last Payment Amount | Last_Payment_Amount__c | Currency | No | Most recent amount |
| Total Paid | Total_Paid__c | Roll-Up Summary | No | Sum of payments |
| Next Payment Date | Next_Payment_Date__c | Formula | No | Calculated |
| Autopay Enrolled | Autopay_Enrolled__c | Checkbox | No | Autopay status |

### 3.8 Payment__c
**Purpose**: Track all loan payments

| Field Name | API Name | Type | Required | Description |
|------------|----------|------|----------|-------------|
| Payment Number | Name | Auto Number | Yes | Unique ID (PMT-{0000000}) |
| Loan | Loan__c | Master-Detail | Yes | Parent loan |
| Payment Date | Payment_Date__c | Date | Yes | When received |
| Due Date | Due_Date__c | Date | Yes | When due |
| Payment Amount | Payment_Amount__c | Currency | Yes | Total amount |
| Principal | Principal__c | Currency | Yes | Principal portion |
| Interest | Interest__c | Currency | Yes | Interest portion |
| Fees | Fees__c | Currency | No | Any fees |
| Payment Method | Payment_Method__c | Picklist | Yes | ACH, Card, Check |
| Payment Status | Payment_Status__c | Picklist | Yes | Pending, Completed, Failed, Reversed |
| Transaction ID | Transaction_ID__c | Text(100) | No | Processor ID |
| NSF Count | NSF_Count__c | Number | No | Failed attempts |
| Reversal Reason | Reversal_Reason__c | Text(255) | No | If reversed |

### 3.9 Document__c
**Purpose**: Manage all application documents

| Field Name | API Name | Type | Required | Description |
|------------|----------|------|----------|-------------|
| Document Name | Name | Text | Yes | Descriptive name |
| Loan Application | Loan_Application__c | Lookup | No | Related application |
| Document Type | Document_Type__c | Picklist | Yes | ID, Paystub, Bank Statement, etc. |
| Status | Status__c | Picklist | Yes | Pending, Received, Verified, Rejected |
| Upload Date | Upload_Date__c | DateTime | Yes | When uploaded |
| Uploaded By | Uploaded_By__c | Lookup(User) | Yes | Who uploaded |
| File | File__c | Files | Yes | Actual document |
| File Size | File_Size__c | Number | No | In KB |
| Expiration Date | Expiration_Date__c | Date | No | Document expiry |
| OCR Processed | OCR_Processed__c | Checkbox | No | If OCR completed |
| Extracted Data | Extracted_Data__c | Long Text | No | OCR results |
| Rejection Reason | Rejection_Reason__c | Text(255) | No | If rejected |

## 4. Supporting Objects

### 4.1 Task (Standard)
**Purpose**: Track application tasks and activities

**Custom Fields**:
- Task_Category__c (Picklist): Verification, Documentation, Review
- SLA_Date__c (DateTime): When task must be completed
- Escalated__c (Checkbox): If escalated
- Automation_Status__c (Picklist): Manual, Automated, Semi-Automated

### 4.2 Case (Standard)
**Purpose**: Customer service and support tickets

**Custom Fields**:
- Loan_Application__c (Lookup): Related application
- Loan__c (Lookup): Related loan
- Case_Category__c (Picklist): Application, Payment, Dispute
- Resolution_SLA__c (DateTime): Target resolution

### 4.3 Platform Events

#### Application_Status_Change__e
```
- Application_ID__c (Text)
- Old_Status__c (Text)
- New_Status__c (Text)
- Changed_By__c (Text)
- Change_Date__c (DateTime)
```

#### Verification_Complete__e
```
- Application_ID__c (Text)
- Verification_Type__c (Text)
- Result__c (Text)
- Provider__c (Text)
- Timestamp__c (DateTime)
```

#### Payment_Received__e
```
- Loan_ID__c (Text)
- Payment_Amount__c (Number)
- Payment_Date__c (DateTime)
- Payment_Method__c (Text)
```

## 5. Data Governance

### 5.1 Record Types

#### Loan_Application__c Record Types
- Personal Loan
- Auto Loan
- Home Improvement Loan
- Debt Consolidation Loan
- Small Business Loan

#### Contact Record Types
- Individual Borrower
- Business Owner
- Guarantor

### 5.2 Sharing Rules

| Object | Rule | Criteria | Share With | Access |
|--------|------|----------|------------|--------|
| Loan_Application__c | Branch Sharing | Branch = User Branch | Branch Users | Read/Write |
| Loan__c | Servicer Sharing | Status = Current | Servicing Team | Read/Write |
| Document__c | Processor Sharing | Owner = Queue | Processing Queue | Read/Write |
| Payment__c | Collections Sharing | Days Past Due > 0 | Collections Team | Read |

### 5.3 Field History Tracking

**Objects with History Tracking**:
- Loan_Application__c: All status and amount fields
- Loan__c: Balance, status, and payment fields
- Decision__c: All fields
- Payment__c: Status and amount fields

### 5.4 Data Classification

| Classification | Description | Examples | Security |
|---------------|-------------|----------|----------|
| Restricted | PII and sensitive data | SSN, Bank Account | Encrypted, limited access |
| Confidential | Internal business data | Risk scores, margins | Role-based access |
| Internal | Operational data | Tasks, notes | Standard security |
| Public | Marketing data | Product info, rates | Broad access |

## 6. Reporting Objects

### 6.1 Custom Report Types

```
Loan Applications with Verifications
├── Loan_Application__c (Primary)
├── Verification__c
└── Decision__c

Loans with Payments
├── Loan__c (Primary)
├── Payment__c
└── Contact

Applicants with Income and Credit
├── Contact (Primary)
├── Income_Source__c
└── Credit_Report__c
```

### 6.2 Key Metrics

| Metric | Object | Formula |
|--------|--------|---------|
| Approval Rate | Decision__c | COUNT(Approved) / COUNT(All) |
| Average Loan Amount | Loan__c | AVG(Original_Amount__c) |
| Delinquency Rate | Loan__c | COUNT(Days_Past_Due > 0) / COUNT(Active) |
| Application Completion Rate | Loan_Application__c | COUNT(Submitted) / COUNT(Created) |
| Average Time to Decision | Loan_Application__c | AVG(Decision_Date - Submission_Date) |

## 7. Integration Considerations

### 7.1 External IDs

Each object has an External_ID__c field for integration with external systems:
- Must be unique
- Used for upsert operations
- Indexed for performance

### 7.2 API Considerations

**API Names**: All custom objects and fields use consistent API naming
**Batch Processing**: Bulk API for large data operations
**Real-time**: REST API for transactional operations
**Events**: Platform Events for near real-time integration

### 7.3 Data Migration

**Migration Strategy**:
1. Create staging objects for initial load
2. Validate and cleanse data
3. Map to target objects
4. Load in sequence respecting relationships
5. Verify data integrity

## 8. Performance Optimization

### 8.1 Indexing Strategy

**Standard Indexes**:
- All lookup fields
- External ID fields
- Unique fields

**Custom Indexes**:
- Loan_Application__c.Status__c
- Loan__c.Current_Balance__c
- Payment__c.Payment_Date__c
- Credit_Report__c.FICO_Score__c

### 8.2 Data Archival

| Object | Retention | Archive Strategy |
|--------|-----------|------------------|
| Loan_Application__c | 7 years | Archive after 2 years if not funded |
| Credit_Report__c | 7 years | Archive after report expiry |
| Document__c | 7 years | Move to cheaper storage after 1 year |
| Payment__c | 10 years | Archive completed loans after 2 years |

### 8.3 Large Data Volumes

**Strategies**:
- Skinny tables for frequently accessed fields
- Divisions for data isolation
- Platform Cache for reference data
- Async processing for bulk operations

## 9. Security Model

### 9.1 Object Permissions

| Profile | Loan Application | Loan | Payment | Credit Report |
|---------|-----------------|------|---------|---------------|
| Loan Officer | Create, Read, Edit | Read | Read | Read |
| Underwriter | Read, Edit | Create, Read, Edit | Read | Read |
| Servicer | Read | Read, Edit | Create, Read, Edit | No Access |
| Collections | Read | Read, Edit | Read, Edit | Read |
| Customer | Read (Own) | Read (Own) | Read (Own) | No Access |

### 9.2 Field-Level Security

**Restricted Fields** (encrypted and limited access):
- SSN__c
- Bank_Account_Number__c
- Credit_Card_Number__c
- Date_of_Birth__c

**Read-Only Fields** (formula or system):
- All formula fields
- System audit fields
- Roll-up summary fields

## 10. Compliance and Audit

### 10.1 Audit Requirements

- All PII access logged
- Decision changes tracked with justification
- Document retention per regulatory requirements
- Immutable audit trail for key events

### 10.2 Regulatory Fields

| Regulation | Required Fields | Object |
|------------|----------------|--------|
| HMDA | Property_State__c, Loan_Purpose__c | Loan_Application__c |
| FCRA | Adverse_Action_Reasons__c | Decision__c |
| ECOA | Decline_Reasons__c | Decision__c |
| TILA | APR__c, Finance_Charge__c | Loan__c |

### 10.3 Data Quality Rules

- Email format validation
- Phone number format validation
- SSN format validation (###-##-####)
- State abbreviation validation
- Zip code validation
- Amount range validation