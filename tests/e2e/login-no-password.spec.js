const { test, expect } = require('@playwright/test');
const { SalesforceAuthAdvanced } = require('./helpers/salesforce-auth-advanced');

test.describe('Salesforce Login without Password', () => {
  
  /**
   * This test uses your Salesforce CLI session
   * No password needed!
   * 
   * Prerequisites:
   * 1. Make sure you're logged into Salesforce CLI:
   *    sf org login web --alias lending-poc
   * 
   * 2. Run this test:
   *    npm run test:e2e -- login-no-password.spec.js
   */
  test('Login using Salesforce CLI session', async ({ page }) => {
    const auth = new SalesforceAuthAdvanced(page);
    
    // Use the Salesforce CLI session
    const success = await auth.loginWithSfdxSession();
    
    if (!success) {
      console.log('\n❌ Not logged into Salesforce CLI');
      console.log('📝 Please run: sf org login web --alias lending-poc');
      console.log('   Then try this test again\n');
      test.skip();
      return;
    }
    
    // We're logged in! Let's verify and do something
    console.log('✅ Successfully logged in using SF CLI');
    
    // Navigate to Accounts
    await page.goto(`${auth.baseUrl}/lightning/o/Account/list`);
    
    // Verify we can see the Accounts page
    const pageHeader = page.locator('h1, .slds-page-header__title');
    await expect(pageHeader).toBeVisible({ timeout: 10000 });
    
    // Take a screenshot as proof
    await page.screenshot({ path: 'test-results/accounts-via-sfdx.png' });
    
    console.log('📸 Screenshot saved to test-results/accounts-via-sfdx.png');
  });

  /**
   * Alternative: Manual login
   * Opens browser and waits for you to login
   */
  test('Manual login (you login in the browser)', async ({ page }) => {
    const auth = new SalesforceAuthAdvanced(page);
    
    console.log('\n🌐 Opening Salesforce login page...');
    console.log('👤 Please login manually in the browser window');
    console.log('⏱️  You have 2 minutes to complete login\n');
    
    // Wait for manual login
    const success = await auth.loginManually(120000); // 2 minutes
    
    if (!success) {
      console.log('❌ Login timeout - please try again');
      return;
    }
    
    console.log('✅ Login successful!');
    
    // Navigate to a page to verify
    await page.goto(`${auth.baseUrl}/lightning/o/Contact/list`);
    
    const pageHeader = page.locator('h1, .slds-page-header__title');
    await expect(pageHeader).toBeVisible({ timeout: 10000 });
    
    console.log('✅ Successfully accessed Contacts page');
  });
});