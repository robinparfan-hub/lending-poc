# Test Data Creation Documentation

## Overview
The `scripts/create-test-data.apex` script creates comprehensive test data for the Lending POC Alpha Demo. This script populates all 7 custom objects with realistic data scenarios to demonstrate the full lending workflow.

## Data Structure

### Applicant Profiles (5 records)
- **John Smith** - Employed, excellent credit candidate
- **Sarah Johnson** - Self-employed consultant  
- **Michael Davis** - Employed with investment income
- **Emily Wilson** - Employed healthcare worker
- **Robert Martinez** - Retired with pension income

### Income Sources (6 records)
- Employment income ranging from $6,000-$12,000/month
- Self-employment income ($12,000/month)
- Investment income ($2,000/month)
- Retirement income ($4,500/month)
- Mix of verified and unverified income sources

### Loan Applications (6 records)
| Applicant | Amount | Term | Purpose | Status |
|-----------|--------|------|---------|--------|
| John Smith | $25,000 | 36 months | Home Improvement | Approved |
| Sarah Johnson | $45,000 | 60 months | Auto Purchase | Under Review |
| Michael Davis | $85,000 | 60 months | Business Expansion | Submitted |
| Emily Wilson | $50,000 | 48 months | Debt Consolidation | Declined |
| Robert Martinez | $95,000 | 60 months | Home Purchase | Funded |
| John Smith | $15,000 | 24 months | Medical Expenses | Submitted |

### Credit Reports (5 records)
- Credit scores ranging from 580-820
- Reports from all major bureaus (Equifax, Experian, TransUnion)
- Recent report dates (within last 30 days)

### Decisions (3 records)
- 2 Approval decisions with approved amounts and rates
- 1 Rejection decision with reason codes
- Realistic decision timelines

### Loans (2 records)
- Active loans for approved/funded applications
- Principal amounts: $25,000 and $95,000
- Current balances showing some payments made
- Monthly payment schedules

### Documents (5 records)
- Income verification documents (pay stubs, bank statements)
- Business registration documents
- Property appraisal reports
- Medical bills
- Various document statuses (Verified, Under Review, Submitted)

## Validation Rules Compliance

The test data adheres to all implemented validation rules:
- **Phone Numbers**: Exactly 10 digits (format: 5550000XXX)
- **Loan Amounts**: Between $1,000 and $100,000
- **Loan Terms**: Valid values only (12, 24, 36, 48, or 60 months)
- **Status Values**: Valid picklist values for Loan_Application__c.Status__c
  - Draft, Submitted, Under Review, Pending Documentation
  - In Underwriting, Approved, Declined, Funded, Cancelled

## Usage Scenarios

This test data supports the following demo scenarios:

1. **Complete Application Flow**: John Smith's approved home improvement loan
2. **Under Review Process**: Sarah Johnson's auto loan pending decision
3. **New Submission**: Michael Davis's business expansion application
4. **Declined Application**: Emily Wilson's debt consolidation (insufficient credit)
5. **Funded Loan**: Robert Martinez's completed home purchase
6. **Multiple Applications**: John Smith has both approved and pending applications

## Execution

To create test data:
```bash
sf apex run --file scripts/create-test-data.apex --target-org lending-poc
```

## Data Cleanup

Use the cleanup script to remove test data:
```bash
sf apex run --file scripts/cleanup-test-data.apex --target-org lending-poc
```

## Notes
- All SSN values are encrypted/masked (***-**-XXXX format)
- Email addresses use @example.com domain
- Addresses are realistic San Francisco locations
- Date ranges create realistic timeline scenarios
- Credit scores align with loan approval/denial outcomes