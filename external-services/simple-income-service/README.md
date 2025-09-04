# Simple Income Verification Service

Simplified income verification service with consistent mock data for Salesforce integration.

## Features

- Returns consistent income profiles based on applicationId hash
- Four profiles: HIGH, MEDIUM, LOW, UNVERIFIABLE
- Simple REST API ready for Render deployment
- Matches Salesforce expected data format

## Endpoints

- `GET /` - Service information
- `GET /health` - Health check
- `POST /api/v1/verify-income` - Main income verification
- `POST /api/v1/employment-verification` - Employment verification
- `POST /api/v1/calculate-dti` - Debt-to-income calculation

## Local Development

```bash
npm install
npm start
```

## Test Requests

```bash
# Verify income
curl -X POST http://localhost:3007/api/v1/verify-income \
  -H "Content-Type: application/json" \
  -d '{"applicationId": "APP-001"}'

# Employment verification
curl -X POST http://localhost:3007/api/v1/employment-verification \
  -H "Content-Type: application/json" \
  -d '{"applicationId": "APP-001"}'

# Calculate DTI
curl -X POST http://localhost:3007/api/v1/calculate-dti \
  -H "Content-Type: application/json" \
  -d '{"monthlyIncome": 5000, "monthlyDebtPayments": 1500}'
```

## Deployment to Render

1. Push to GitHub
2. Create new Web Service on Render
3. Settings:
   - Root Directory: `external-services/simple-income-service`
   - Build Command: `npm install`
   - Start Command: `npm start`
4. Environment Variables:
   - `NODE_ENV=production`

## Income Profiles

- **HIGH**: $85k annual, verified, low DTI
- **MEDIUM**: $65k annual, verified, moderate DTI
- **LOW**: $45k annual, pending verification, high DTI
- **UNVERIFIABLE**: Unable to verify income