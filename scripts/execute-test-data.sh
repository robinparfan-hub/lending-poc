#!/bin/bash

# Execute test data creation script in Salesforce org
echo "Creating test data for Lending POC Alpha Demo..."
echo "================================================"

# Execute the Apex script to create test data
sf apex run --file scripts/create-test-data.apex --target-org lending-poc

echo ""
echo "Test data creation complete!"
echo "================================================"
echo ""
echo "You can now:"
echo "1. Open the org: sf org open --target-org lending-poc"
echo "2. Navigate to the Lending Console app"
echo "3. Review the test data in each object tab"
echo ""
echo "Test Data Summary:"
echo "- 5 Applicant Profiles (various employment statuses)"
echo "- 6 Income Sources (verified and unverified)"
echo "- 6 Loan Applications (different statuses: Submitted, Under Review, Approved, Rejected, Funded)"
echo "- 5 Credit Reports (scores ranging from 580 to 820)"
echo "- 3 Decisions (2 approvals, 1 rejection)"
echo "- 2 Active Loans (for approved applications)"
echo "- 5 Documents (various types and statuses)"