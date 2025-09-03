#!/bin/bash

# Cleanup Script for Lending POC Test Data
# This script safely removes all test data from the Salesforce org

echo "================================================"
echo "     Lending POC Test Data Cleanup Tool"
echo "================================================"
echo ""
echo "This script will DELETE all test data from the org including:"
echo "  - 5 Applicant Profiles (John Smith, Sarah Johnson, etc.)"
echo "  - All related Income Sources"
echo "  - All related Loan Applications"
echo "  - All related Credit Reports"
echo "  - All related Decisions"
echo "  - All related Loans"
echo "  - All related Documents"
echo ""
echo "⚠️  WARNING: This action cannot be undone!"
echo ""

# Ask for confirmation
read -p "Are you sure you want to delete all test data? (yes/no): " confirmation

if [ "$confirmation" != "yes" ]; then
    echo ""
    echo "Cleanup cancelled. No data was deleted."
    exit 0
fi

echo ""
echo "Starting cleanup process..."
echo "================================================"

# Execute the Apex cleanup script
sf apex run --file scripts/cleanup-test-data.apex --target-org lending-poc

if [ $? -eq 0 ]; then
    echo ""
    echo "================================================"
    echo "✅ Test data cleanup completed successfully!"
    echo "================================================"
    echo ""
    echo "All test records have been removed from the org."
    echo ""
    echo "You can now:"
    echo "1. Run ./scripts/execute-test-data.sh to create fresh test data"
    echo "2. Open the org: sf org open --target-org lending-poc"
    echo ""
else
    echo ""
    echo "================================================"
    echo "❌ Error during cleanup!"
    echo "================================================"
    echo ""
    echo "The cleanup process encountered an error."
    echo "Please check the error messages above and try again."
    echo ""
fi