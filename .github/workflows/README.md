# GitHub Actions Setup

## Apex Tests Workflow

### Purpose
Runs Apex tests to ensure code quality without the overhead of full CI/CD.

### When it runs:
1. **Manual trigger** - Run anytime via GitHub Actions UI
2. **On push to main** - Only when Apex classes/triggers change
3. **Weekly** - Every Friday at 5 PM (sprint end)

### Setup Required:

1. **Get your Salesforce Auth URL**:
   ```bash
   sf org display --target-org lending-poc --verbose --json
   ```
   Look for the `sfdxAuthUrl` field.

2. **Add to GitHub Secrets**:
   - Go to Settings → Secrets → Actions
   - Add new secret: `SFDX_AUTH_URL`
   - Paste the auth URL value

### Manual Run:
1. Go to Actions tab
2. Select "Apex Tests" workflow
3. Click "Run workflow"

### What it does:
- ✅ Deploys latest code to org
- ✅ Runs all Apex tests
- ✅ Checks code coverage (fails if < 75%)
- ✅ Reports results

### Why minimal CI?
- It's a prototype with one org
- Working mostly on main branch
- Manual deployments give more control
- Can add more automation later if needed

### Future Options (if needed):
- Add UI tests workflow (Playwright)
- Add pull request validation
- Add deployment gates
- Add notifications (Slack/email)