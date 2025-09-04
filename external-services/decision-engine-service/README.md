# Decision Engine Service

This service provides loan decision evaluation matching the Salesforce Apex MockDataFactory exactly.

## Features

- Returns consistent mock data based on applicationId hash
- Matches all Apex scenarios (APPROVED_EXCELLENT_CREDIT, APPROVED_GOOD_CREDIT, etc.)
- Ready for Render deployment
- Simple REST API with no authentication required for POC

## Endpoints

- `GET /` - Service information
- `GET /health` - Health check
- `POST /api/v1/evaluate-application` - Main decision endpoint
- `POST /api/v1/credit-score` - Credit score only
- `POST /api/v1/calculate-payment` - Payment calculator

## Local Development

```bash
npm install
npm start
```

## Test Requests

```bash
# Evaluate application
curl -X POST http://localhost:3006/api/v1/evaluate-application \
  -H "Content-Type: application/json" \
  -d '{"applicationId": "APP-001"}'

# Get credit score
curl -X POST http://localhost:3006/api/v1/credit-score \
  -H "Content-Type: application/json" \
  -d '{"applicationId": "APP-001"}'

# Calculate payment
curl -X POST http://localhost:3006/api/v1/calculate-payment \
  -H "Content-Type: application/json" \
  -d '{"principal": 25000, "rate": 8.99, "months": 60}'
```

## Deployment to Render

1. Push to GitHub
2. Create new Web Service on Render
3. Settings:
   - Root Directory: `external-services/decision-engine-service`
   - Build Command: `npm install`
   - Start Command: `npm start`
4. Environment Variables:
   - `NODE_ENV=production`
   - `API_KEY=test_key_development_2025`

## Response Format

All responses follow Salesforce ServiceResponse format:

```json
{
  "success": true,
  "data": {
    "decision": "APPROVED",
    "approvedAmount": 35000,
    "interestRate": 8.99,
    "creditScore": 720,
    // ... additional fields
  },
  "metadata": {
    "requestId": "REQ-123...",
    "timestamp": "2025-09-04T10:00:00Z"
  }
}
```