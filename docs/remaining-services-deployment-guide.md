# Deployment Guide for Remaining External Services

## Services to Deploy
1. **decision-engine-service** - Loan approval decision logic
2. **simple-income-service** - Income verification service

---

## 1. Decision Engine Service Deployment

### Step 1: Prepare the Service
```bash
cd external-services/decision-engine-service
npm install
npm test  # Verify everything works locally
```

### Step 2: Test Locally (Optional)
```bash
npm start
# In another terminal:
curl -X POST http://localhost:3002/api/v1/evaluate-application \
  -H "Content-Type: application/json" \
  -H "x-api-key: test_key_development_2025" \
  -d '{"applicationId": "APP-123"}'
```

### Step 3: Deploy to Render
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click "New +" → "Web Service"
3. Connect to your Git repository (or use "Deploy from a Git URL")
4. Configure the service:
   - **Name**: `decision-engine-service`
   - **Environment**: Node
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free tier is fine for POC

5. Add Environment Variables:
   - `NODE_ENV`: `production`
   - `PORT`: (Render sets this automatically)
   - `API_KEY`: `test_key_development_2025`

6. Click "Create Web Service"
7. Wait for deployment (usually 2-5 minutes)
8. Note your service URL (will be like: https://decision-engine-service-xxxx.onrender.com)

### Step 4: Test Deployed Service
```bash
# Replace with your actual Render URL
DECISION_ENGINE_URL="https://decision-engine-service-xxxx.onrender.com"

# Test health endpoint
curl $DECISION_ENGINE_URL/health

# Test evaluate application
curl -X POST $DECISION_ENGINE_URL/api/v1/evaluate-application \
  -H "Content-Type: application/json" \
  -H "x-api-key: test_key_development_2025" \
  -d '{"applicationId": "APP-TEST-001"}'
```

---

## 2. Simple Income Service Deployment

### Step 1: Prepare the Service
```bash
cd external-services/simple-income-service
npm install
npm test  # Verify everything works locally
```

### Step 2: Test Locally (Optional)
```bash
npm start
# In another terminal:
curl -X POST http://localhost:3003/api/v1/verify-income \
  -H "Content-Type: application/json" \
  -H "x-api-key: test_key_development_2025" \
  -d '{"applicationId": "APP-456"}'
```

### Step 3: Deploy to Render
1. Go to [Render Dashboard](https://dashboard.render.com)
2. Click "New +" → "Web Service"
3. Connect to your Git repository (or use "Deploy from a Git URL")
4. Configure the service:
   - **Name**: `simple-income-service`
   - **Environment**: Node
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Plan**: Free tier

5. Add Environment Variables:
   - `NODE_ENV`: `production`
   - `PORT`: (Render sets automatically)
   - `API_KEY`: `test_key_development_2025`

6. Click "Create Web Service"
7. Wait for deployment
8. Note your service URL (will be like: https://simple-income-service-xxxx.onrender.com)

### Step 4: Test Deployed Service
```bash
# Replace with your actual Render URL
INCOME_SERVICE_URL="https://simple-income-service-xxxx.onrender.com"

# Test health endpoint
curl $INCOME_SERVICE_URL/health

# Test verify income
curl -X POST $INCOME_SERVICE_URL/api/v1/verify-income \
  -H "Content-Type: application/json" \
  -H "x-api-key: test_key_development_2025" \
  -d '{"applicationId": "APP-TEST-002"}'

# Test calculate DTI
curl -X POST $INCOME_SERVICE_URL/api/v1/calculate-dti \
  -H "Content-Type: application/json" \
  -H "x-api-key: test_key_development_2025" \
  -d '{"monthlyIncome": 8000, "monthlyDebt": 2400}'
```

---

## 3. Update Salesforce Integration

### After deploying each service, update the HttpCalloutService.cls:

```apex
// Update these with your actual Render URLs
private static final String CREDIT_BUREAU_BASE = 'callout:Credit_Bureau_Service';  // ✅ Already done
private static final String DECISION_ENGINE_BASE = 'callout:Decision_Engine_Service';  // TODO
private static final String INCOME_SERVICE_BASE = 'callout:Income_Service';  // TODO
```

### Create Named Credentials for Each Service:

#### For Decision Engine:
1. Go to Salesforce Setup → Named Credentials
2. Click "New Named Credential"
3. Configure:
   - **Label**: Decision Engine Service
   - **Name**: Decision_Engine_Service
   - **URL**: https://decision-engine-service-xxxx.onrender.com (your actual URL)
   - **Identity Type**: Anonymous
   - **Authentication Protocol**: No Authentication
4. Save

#### For Income Service:
1. Go to Salesforce Setup → Named Credentials
2. Click "New Named Credential"
3. Configure:
   - **Label**: Income Service
   - **Name**: Income_Service
   - **URL**: https://simple-income-service-xxxx.onrender.com (your actual URL)
   - **Identity Type**: Anonymous
   - **Authentication Protocol**: No Authentication
4. Save

---

## 4. Test End-to-End Integration

### Execute Anonymous in Salesforce Developer Console:
```apex
// Test Decision Engine
String endpoint = 'callout:Decision_Engine_Service/api/v1/evaluate-application';
Map<String, Object> requestBody = new Map<String, Object>{
    'applicationId' => 'APP-TEST-SALESFORCE'
};
ServiceResponse decisionResponse = HttpCalloutService.post(endpoint, requestBody);
System.debug('Decision Response: ' + JSON.serialize(decisionResponse));

// Test Income Service
ServiceResponse incomeResponse = HttpCalloutService.verifyIncome('APP-TEST-SALESFORCE');
System.debug('Income Response: ' + JSON.serialize(incomeResponse));
```

---

## 5. Monitoring Your Services

### On Render Dashboard:
- Check service logs for any errors
- Monitor service status (should show "Live")
- Review metrics (requests, response times)

### Service URLs to Remember:
- **Health Check**: `[SERVICE_URL]/health`
- **Logs**: Available in Render dashboard for each service
- **Metrics**: Basic metrics available in free tier

---

## Troubleshooting Tips

### If deployment fails:
1. Check build logs in Render dashboard
2. Verify `package.json` has correct start script
3. Ensure all dependencies are in `package.json`

### If API calls fail:
1. Check API key in environment variables
2. Verify Named Credential URL is correct
3. Check service logs in Render dashboard
4. Test with curl first, then from Salesforce

### Common Issues:
- **503 Service Unavailable**: Service might be sleeping (free tier), wait 30 seconds
- **401 Unauthorized**: Check API key
- **404 Not Found**: Check endpoint path
- **Network Error**: Verify Named Credential configuration

---

## Next Steps After All Services Deployed

1. Update HttpCalloutService.cls with all Named Credential references
2. Create comprehensive test in Execute Anonymous
3. Wire up services to actual Loan Application workflow
4. Test complete loan application flow with external validations
5. Document the complete architecture

---

## Quick Reference - All Service Endpoints

### Credit Bureau (✅ Deployed)
- Base: https://lending-poc.onrender.com
- Health: /health
- Credit Check: /api/v1/credit-check
- Credit Score: /api/v1/credit-score

### Decision Engine (To Deploy)
- Base: [YOUR_URL]
- Health: /health
- Evaluate: /api/v1/evaluate-application

### Income Service (To Deploy)
- Base: [YOUR_URL]
- Health: /health
- Verify Income: /api/v1/verify-income
- Calculate DTI: /api/v1/calculate-dti