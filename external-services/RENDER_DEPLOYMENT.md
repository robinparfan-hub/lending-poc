# Render Deployment Guide

## Quick Test: Hello World Service

✅ **Local Test Complete**: The hello-world-service is working at http://localhost:3000

## Step-by-Step Render Deployment

### 1. Push to GitHub (if not done yet)
```bash
git add external-services/hello-world-service/
git commit -m "Add hello world service for Render testing"
git push origin main
```

### 2. Sign up for Render
- Go to [render.com](https://render.com)
- Click "Get Started for Free"
- Choose "Continue with GitHub"
- Authorize Render to access your repository

### 3. Create Your First Service
- Click "New +" → "Web Service"
- Connect your `lending-poc` repository
- Configure the service:

**Service Settings:**
- **Name**: `hello-world-service`
- **Root Directory**: `external-services/hello-world-service`
- **Environment**: `Node`
- **Build Command**: `npm install` (auto-detected)
- **Start Command**: `npm start` (auto-detected)

**Environment Variables:**
- `NODE_ENV` = `production`

### 4. Deploy & Test
- Click "Create Web Service"
- Wait 2-3 minutes for build & deployment
- You'll get a URL like: `https://hello-world-service-abc123.onrender.com`

**Test endpoints:**
- `GET /` - Main hello message
- `GET /health` - Health check
- `GET /api/hello?name=YourName` - Personalized greeting

### 5. Next Steps: Deploy Real Services
Once hello-world works, deploy each microservice:

**Credit Bureau Service:**
- Root Directory: `external-services/credit-bureau-service`
- Environment Variables:
  - `NODE_ENV=production`
  - `MOCK_MODE=true`
  - `API_KEY=your_secure_api_key_here`

**Income Verification Service:**
- Root Directory: `external-services/income-verification-service`
- Same environment variables as above

**Identity Verification Service:**
- Root Directory: `external-services/identity-verification-service`
- Same environment variables as above

**Document Processing Service:**
- Root Directory: `external-services/document-processing-service`
- Same environment variables as above

**Notification Service:**
- Root Directory: `external-services/notification-service`
- Same environment variables as above

## Pro Tips

### Free Tier Limitations
- Services spin down after 15 minutes of inactivity
- Cold start takes ~10-30 seconds
- For production, upgrade to paid plan ($7/month per service)

### Environment Variables
- Set different `API_KEY` for each service in production
- Keep `MOCK_MODE=true` for now (switch to false when integrating real APIs)
- Add `CORS_ORIGIN=https://your-salesforce-domain.my.salesforce.com` for production

### Monitoring
- Check logs in Render dashboard
- Use `/health` endpoints for monitoring
- Set up uptime monitoring if needed

## Render URLs (After Deployment)
You'll get URLs like:
- Hello World: `https://hello-world-service-xyz.onrender.com`
- Credit Bureau: `https://credit-bureau-service-xyz.onrender.com`
- Income Verification: `https://income-verification-service-xyz.onrender.com`
- Identity Verification: `https://identity-verification-service-xyz.onrender.com`
- Document Processing: `https://document-processing-service-xyz.onrender.com`
- Notification: `https://notification-service-xyz.onrender.com`

These URLs are what you'll use in your Salesforce Named Credentials!

## Troubleshooting

**Build Fails?**
- Check that `package.json` exists in the root directory
- Ensure Node.js version is specified in `engines`

**Service Won't Start?**
- Check that `PORT` environment variable is used (Render sets this)
- Look at the build logs in Render dashboard

**Can't Access Service?**
- Make sure service is not sleeping (free tier limitation)
- Check CORS settings if accessing from browser

## Next: Salesforce Integration
Once deployed, update your Salesforce Named Credentials with the Render URLs!