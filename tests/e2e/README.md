# Salesforce E2E Tests with Playwright

## Setup

1. **Install Playwright browsers** (if not already installed):
   ```bash
   npm run playwright:install
   ```

2. **Configure credentials**:
   - Copy `.env.example` to `.env` in the project root
   - Update `SALESFORCE_PASSWORD` with your actual password
   - Update `SALESFORCE_SECURITY_TOKEN` with your security token
   - The system automatically combines: PASSWORD + SECURITY_TOKEN for login

3. **Test the login**:
   ```bash
   # Run just the login test
   npm run test:e2e:login
   
   # Run with visible browser (non-headless)
   npm run test:e2e:headed
   ```

## Available Test Commands

- `npm run test:e2e` - Run all E2E tests
- `npm run test:e2e:ui` - Open Playwright UI mode
- `npm run test:e2e:debug` - Run tests in debug mode
- `npm run test:e2e:headed` - Run tests with visible browser
- `npm run test:e2e:login` - Run only the login test

## Test Structure

```
tests/e2e/
├── README.md                    # This file
├── salesforce-login.spec.js     # Basic login test
├── example-with-helper.spec.js  # Example using the auth helper
└── helpers/
    └── salesforce-auth.js       # Reusable authentication helper
```

## Using the Auth Helper in Your Tests

```javascript
const { test } = require('@playwright/test');
const { SalesforceAuth } = require('./helpers/salesforce-auth');

test('Your test name', async ({ page }) => {
  const auth = new SalesforceAuth(page);
  
  // Login to Salesforce
  await auth.login();
  
  // Your test logic here
  // ...
  
  // Optional: Logout
  await auth.logout();
});
```

## Helper Methods Available

- `login(options)` - Login to Salesforce
- `logout()` - Logout from Salesforce
- `isLoggedIn()` - Check if currently logged in
- `navigateToApp(appName)` - Navigate to a specific app
- `navigateToObjectList(objectName)` - Navigate to object list view
- `handleVerificationCode(code)` - Handle 2FA if required

## Environment Variables

- `SALESFORCE_USERNAME` - Your Salesforce username
- `SALESFORCE_PASSWORD` - Your Salesforce password (without security token)
- `SALESFORCE_SECURITY_TOKEN` - Your security token (will be appended to password)
- `SALESFORCE_URL` - Your Salesforce instance URL

**Note**: The login process automatically combines PASSWORD + SECURITY_TOKEN. You don't need to manually append them.

## Troubleshooting

### Login Fails
- Verify your password is correct (don't include the security token in the password field)
- Ensure your security token is set in `SALESFORCE_SECURITY_TOKEN`
- The system automatically appends the security token to your password
- Ensure the org URL is correct
- Check if IP restrictions are blocking access
- To get a new security token: Setup → My Personal Information → Reset Security Token

### Timeouts
- Increase timeout in playwright.config.js if your org is slow
- Check your internet connection
- Verify the org is accessible

### Element Not Found
- Salesforce UI can vary between orgs
- Check if you're using Lightning Experience vs Classic
- Inspect the actual selectors in your org

## Notes

- Tests are configured to take screenshots on failure
- Test results and artifacts are saved in `test-results/`
- The config uses your org URL: https://orgfarm-99db23b830-dev-ed.develop.my.salesforce.com
- Default user: robinjosephparfan691@agentforce.com