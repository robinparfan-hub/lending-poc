const { test, expect } = require('@playwright/test');
const { SalesforceAuthAdvanced } = require('./helpers/salesforce-auth-advanced');

test.describe('Salesforce Authentication Options', () => {
  let auth;

  test.beforeEach(async ({ page }) => {
    auth = new SalesforceAuthAdvanced(page);
  });

  /**
   * RECOMMENDED: Use Salesforce CLI session
   * No password needed - uses your existing SF CLI login
   */
  test('Method 1: Use Salesforce CLI session (recommended)', async ({ page }) => {
    // This uses your existing Salesforce CLI authentication
    // Run 'sf org login web --alias lending-poc' first
    const success = await auth.loginWithSfdxSession();
    
    if (success) {
      // Verify we're on the home page
      const appLauncher = page.locator('.slds-icon-waffle');
      await expect(appLauncher).toBeVisible();
      
      console.log('✅ Successfully authenticated using SF CLI');
    } else {
      console.log('⚠️ SF CLI not authenticated. Run: sf org login web --alias lending-poc');
    }
  });

  /**
   * Use stored browser session
   * Reuses cookies from previous successful login
   */
  test('Method 2: Use stored session', async ({ page }) => {
    // First tries to use stored session
    // Falls back to SF CLI if session expired
    const success = await auth.login({ method: 'auto' });
    
    expect(success).toBe(true);
    
    // Verify we're logged in
    const appLauncher = page.locator('.slds-icon-waffle');
    await expect(appLauncher).toBeVisible();
  });

  /**
   * Manual browser login
   * Opens browser and waits for you to login manually
   */
  test('Method 3: Manual login in browser', async ({ page }) => {
    // This will open the browser and wait for you to login manually
    // Useful for development and debugging
    const success = await auth.loginManually(60000); // 60 second timeout
    
    expect(success).toBe(true);
    
    // Session is automatically saved for future use
  });

  /**
   * OAuth with Connected App
   * For CI/CD environments
   */
  test.skip('Method 4: OAuth with Connected App', async ({ page }) => {
    // Requires setting up a Connected App in Salesforce
    // Set these environment variables:
    // SALESFORCE_CLIENT_ID
    // SALESFORCE_CLIENT_SECRET  
    // SALESFORCE_REFRESH_TOKEN
    
    const success = await auth.loginWithOAuth(
      process.env.SALESFORCE_CLIENT_ID,
      process.env.SALESFORCE_CLIENT_SECRET,
      process.env.SALESFORCE_REFRESH_TOKEN
    );
    
    expect(success).toBe(true);
  });

  /**
   * Interactive password prompt
   * Prompts for password at runtime
   */
  test.skip('Method 5: Interactive password prompt', async ({ page }) => {
    // This will prompt for password in the terminal
    // Password is not stored anywhere
    const success = await auth.loginWithPrompt();
    
    expect(success).toBe(true);
  });

  /**
   * Smart auto-login
   * Tries multiple methods automatically
   */
  test('Smart auto-login (tries multiple methods)', async ({ page }) => {
    // Tries in order:
    // 1. Stored session (if exists)
    // 2. Salesforce CLI session
    // 3. Interactive prompt (if running interactively)
    
    const success = await auth.login({ 
      method: 'auto',
      saveSession: true 
    });
    
    expect(success).toBe(true);
    
    // Do your testing here
    await page.goto(`${auth.baseUrl}/lightning/o/Account/list`);
    const pageHeader = page.locator('h1');
    await expect(pageHeader).toContainText('Accounts', { timeout: 10000 });
  });
});