# Test Data Prepopulation - Removal Instructions

## Purpose
Test data prepopulation was added to speed up manual testing by automatically filling in loan application form fields with test data.

## What Was Added

### File Modified
`/force-app/main/default/lwc/loanApplicationStage/loanApplicationStage.js`

### Prepopulated Values
- **Loan Amount**: $20,000
- **Loan Purpose**: Home Improvement
- **Loan Term**: 24 months
- **Full Name**: Test YYYYMMDDHHmm (timestamp-based)
- **Email**: YYYYMMDDHHmm@test.com (timestamp-based)
- **Date of Birth**: 12/31/2000
- **Employment Status**: Employed
- **Phone**: 555-555-5555

### Timestamp Format
- Format: YYYYMMDDHHmm (e.g., 202509071430 for Sept 7, 2025 at 2:30 PM)
- This ensures unique test data for each application created

## How to Remove Test Prepopulation

### Option 1: Remove Completely (Recommended for Production)

1. Open `/force-app/main/default/lwc/loanApplicationStage/loanApplicationStage.js`

2. Delete the entire `prepopulateTestData()` method (lines 62-91)

3. Remove the call to `prepopulateTestData()` in `connectedCallback()`:
   - Delete lines 54-58:
   ```javascript
   // TEST PREPOPULATION - REMOVE FOR PRODUCTION
   // Only prepopulate if this is a new application (draft stage with no existing data)
   if (this.isDraftStage && !this.localApplicationData.Amount_Requested__c) {
       this.prepopulateTestData();
   }
   ```

### Option 2: Disable Temporarily

If you want to keep the code but disable it temporarily, comment out the call in `connectedCallback()`:

```javascript
// TEST PREPOPULATION - REMOVE FOR PRODUCTION
// Only prepopulate if this is a new application (draft stage with no existing data)
// if (this.isDraftStage && !this.localApplicationData.Amount_Requested__c) {
//     this.prepopulateTestData();
// }
```

## Identifying Test Data in the System

All test applications created with this prepopulation will have:
- Applicant names starting with "Test " followed by a timestamp
- Email addresses in the format YYYYMMDDHHmm@test.com

To find and clean up test data, you can query:
```sql
SELECT Id, Name, Email__c FROM Applicant_Profile__c 
WHERE Name LIKE 'Test %' 
AND Email__c LIKE '%@test.com'
```

## Deploy Changes

After removing the test prepopulation:

```bash
sf project deploy start --target-org lending-poc
```

## Notes
- This prepopulation only affects NEW applications (draft stage with no existing data)
- Existing applications are not affected
- The prepopulation helps create unique test data for each application during testing