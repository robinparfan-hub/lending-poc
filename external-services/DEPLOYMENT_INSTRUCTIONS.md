# External Services Deployment Instructions

## Services Ready for Deployment

We have created two new services that match your Salesforce Apex mock data exactly:

### 1. Decision Engine Service
- **Location**: `external-services/decision-engine-service`
- **Purpose**: Loan decision evaluation matching Apex MockDataFactory
- **Port**: 3006 (locally), auto-assigned by Render

### 2. Simple Income Service
- **Location**: `external-services/simple-income-service`
- **Purpose**: Income verification with consistent mock profiles
- **Port**: 3007 (locally), auto-assigned by Render

## Step-by-Step Render Deployment

### Deploy Decision Engine Service

1. **Go to Render Dashboard**
   - Navigate to [render.com](https://render.com)
   - Click "New +" → "Web Service"

2. **Configure Service**
   - **Name**: `decision-engine-service`
   - **Repository**: Select your `lending-poc` repo
   - **Branch**: `main`
   - **Root Directory**: `external-services/decision-engine-service`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`

3. **Add Environment Variables**
   ```
   NODE_ENV = production
   API_KEY = test_key_development_2025
   ```

4. **Create Service**
   - Click "Create Web Service"
   - Wait for deployment (2-3 minutes)
   - Note the URL (e.g., `https://decision-engine-service-xyz.onrender.com`)

### Deploy Simple Income Service

1. **Create Another Service**
   - Click "New +" → "Web Service"

2. **Configure Service**
   - **Name**: `simple-income-service`
   - **Repository**: Select your `lending-poc` repo
   - **Branch**: `main`
   - **Root Directory**: `external-services/simple-income-service`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`

3. **Add Environment Variables**
   ```
   NODE_ENV = production
   ```

4. **Create Service**
   - Click "Create Web Service"
   - Wait for deployment
   - Note the URL (e.g., `https://simple-income-service-xyz.onrender.com`)

## Test Your Deployed Services

### Test Decision Engine
```bash
# Health check
curl https://decision-engine-service-xyz.onrender.com/health

# Evaluate application (replace xyz with your actual subdomain)
curl -X POST https://decision-engine-service-xyz.onrender.com/api/v1/evaluate-application \
  -H "Content-Type: application/json" \
  -d '{"applicationId": "TEST-123"}'
```

### Test Income Service
```bash
# Health check
curl https://simple-income-service-xyz.onrender.com/health

# Verify income
curl -X POST https://simple-income-service-xyz.onrender.com/api/v1/verify-income \
  -H "Content-Type: application/json" \
  -d '{"applicationId": "TEST-123"}'
```

## Expected Responses

Both services return data matching your Apex MockDataFactory:

### Decision Engine Scenarios
- **APP-001**: Returns DENIED_LOW_CREDIT (score 580)
- **TEST-123**: Returns APPROVED_GOOD_CREDIT (score 720, $35k approved)
- Different IDs return different scenarios consistently

### Income Profiles
- **HIGH**: $85k annual income, verified
- **MEDIUM**: $65k annual income, verified
- **LOW**: $45k annual income, pending
- **UNVERIFIABLE**: Unable to verify

## Next Steps

After deployment, you'll have these URLs:

1. **Decision Engine**: `https://decision-engine-service-[unique-id].onrender.com`
2. **Simple Income**: `https://simple-income-service-[unique-id].onrender.com`

### Configure Salesforce

1. **Create Named Credentials** in Salesforce:
   - Name: `DecisionEngine`
   - URL: Your decision engine Render URL
   - Authentication: None (for POC)

2. **Update Apex Classes** to use these endpoints when not in mock mode

## Important Notes

### Free Tier Limitations
- Services spin down after 15 minutes of inactivity
- First request after sleep takes 10-30 seconds (cold start)
- For production, consider upgrading to paid tier

### Data Consistency
- Services use applicationId hash for consistent responses
- Same applicationId always returns same scenario
- Matches Apex MockDataFactory behavior exactly

### Security
- Currently no authentication (POC mode)
- For production, add proper API key validation
- Consider adding rate limiting

## Troubleshooting

### Service Won't Start?
- Check Render logs for errors
- Verify Node version (requires 18+)
- Check environment variables

### Getting 404 Errors?
- Verify the endpoint path
- Check service is not sleeping (free tier)
- Test health endpoint first

### Response Doesn't Match Expected?
- Services use applicationId for scenario selection
- Try different applicationIds for different scenarios
- Check console logs in Render dashboard

## Support

If you need help:
1. Check Render logs for errors
2. Test locally first with `npm start`
3. Verify GitHub repo is pushed with latest changes
4. Check service status at `/health` endpoint

---
Created: September 4, 2025
Services match Salesforce Apex MockDataFactory exactly