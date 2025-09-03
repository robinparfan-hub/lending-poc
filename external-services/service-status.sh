#!/bin/bash

# Service Status Check Script
echo "==================================="
echo "External Services Status Check"
echo "==================================="
echo ""

# Define services
declare -A services=(
    ["Credit Bureau Service"]="http://localhost:3001/health"
    ["Income Verification Service"]="http://localhost:3002/health"
    ["Identity Verification Service"]="http://localhost:3003/health"
    ["Document Processing Service"]="http://localhost:3004/health"
    ["Notification Service"]="http://localhost:3005/health"
)

# Check each service
for name in "Credit Bureau Service" "Income Verification Service" "Identity Verification Service" "Document Processing Service" "Notification Service"; do
    url="${services[$name]}"
    echo -n "Checking $name... "
    
    if response=$(curl -s -f "$url" 2>/dev/null); then
        status=$(echo "$response" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
        version=$(echo "$response" | grep -o '"version":"[^"]*"' | cut -d'"' -f4)
        echo "✓ RUNNING (status: $status, version: $version)"
    else
        echo "✗ NOT RUNNING"
    fi
done

echo ""
echo "==================================="
echo "API Documentation URLs:"
echo "==================================="
echo "Credit Bureau:          http://localhost:3001/api-docs"
echo "Income Verification:    http://localhost:3002/api-docs"
echo "Identity Verification:  http://localhost:3003/api-docs"
echo "Document Processing:    http://localhost:3004/api-docs"
echo "Notification:          http://localhost:3005/api-docs"
echo ""
