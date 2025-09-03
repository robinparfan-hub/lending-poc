#!/bin/bash

# Deploy Custom Labels to Salesforce org
echo "🚀 Deploying Custom Labels to lending-poc org..."
echo "================================================"

# Deploy only the Custom Labels metadata
echo "Deploying Custom Labels..."
sf project deploy start \
    --source-dir force-app/main/default/labels \
    --target-org lending-poc \
    --wait 10

# Check deployment status
if [ $? -eq 0 ]; then
    echo "✅ Custom Labels deployed successfully!"
    echo ""
    echo "📋 Next Steps:"
    echo "1. Go to Setup → Custom Labels in Salesforce"
    echo "2. Edit any label value to change system behavior"
    echo "3. No code changes or redeployment needed!"
    echo ""
    echo "🧪 To test the services with current label values:"
    echo "   sf apex run --target-org lending-poc --file scripts/test-services-with-labels.apex"
else
    echo "❌ Deployment failed. Check the error messages above."
    exit 1
fi