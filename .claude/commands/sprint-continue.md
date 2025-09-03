# Continue Sprint - Week 2

## Next Task: Create Salesforce Objects

### Current Focus: LoanApplication Object

Let's create the core Salesforce objects for the lending platform. Starting with the LoanApplication object.

#### Object: LoanApplication__c
**Fields to create:**
- Applicant__c (Lookup to Account)
- Loan_Amount__c (Currency)
- Loan_Term_Months__c (Number)
- Interest_Rate__c (Percent)
- Application_Status__c (Picklist: Draft, Submitted, Under Review, Approved, Rejected, Funded)
- Application_Date__c (Date)
- Decision_Date__c (Date)
- Monthly_Payment__c (Currency, Formula)
- Total_Interest__c (Currency, Formula)
- Credit_Score__c (Number)
- Debt_to_Income_Ratio__c (Percent)
- Loan_Purpose__c (Picklist: Home Purchase, Auto, Personal, Business, Debt Consolidation)
- Employment_Status__c (Picklist: Employed, Self-Employed, Retired, Student)
- Annual_Income__c (Currency)

### Implementation Steps:
1. Create the custom object in Salesforce Setup
2. Add all fields with appropriate data types
3. Set up field-level security
4. Create validation rules
5. Build page layouts
6. Create Lightning record pages

### Command to deploy:
```bash
sf project deploy start --target-org lending-poc --source-dir force-app/main/default/objects/LoanApplication__c
```

Ready to proceed? This task will establish the foundation for our lending application workflow.