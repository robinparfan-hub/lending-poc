const { test, expect } = require('@playwright/test');
const { execSync } = require('child_process');

test.describe('Salesforce SFDX Login', () => {
  
  test('Login using SF CLI session - automatic, no password needed', async ({ page }) => {
    console.log('🔐 Getting Salesforce CLI session...');
    
    let accessToken, instanceUrl;
    
    try {
      // Get auth info from SF CLI  
      const authInfo = execSync('/usr/local/bin/sf org display --target-org lending-poc --json', { 
        encoding: 'utf8',
        stdio: ['pipe', 'pipe', 'ignore'], // Ignore stderr
        env: { ...process.env, FORCE_COLOR: '0', NO_COLOR: '1' } // Try to disable colors
      });
      
      console.log('Got response, length:', authInfo.length);
      
      // Strip ANSI color codes from the output
      const cleanedInfo = authInfo.replace(/\x1b\[[0-9;]*m/g, '');
      console.log('Cleaned response length:', cleanedInfo.length);
      
      // Parse the cleaned JSON
      const auth = JSON.parse(cleanedInfo);
      
      if (auth.status !== 0 || !auth.result.accessToken) {
        throw new Error('SF CLI not authenticated');
      }
      
      accessToken = auth.result.accessToken;
      instanceUrl = auth.result.instanceUrl;
      
      console.log('✅ Got access token from SF CLI');
      console.log('📧 Username:', auth.result.username);
      console.log('🌐 Instance:', instanceUrl);
      
    } catch (error) {
      console.error('❌ Failed to get SF CLI session:', error.message);
      console.log('Please run: sf org login web --alias lending-poc');
      test.skip();
      return;
    }
    
    // Use frontdoor.jsp to login with the access token
    // This bypasses the login form completely!
    const frontdoorUrl = `${instanceUrl}/secur/frontdoor.jsp?sid=${accessToken}&retURL=/lightning`;
    
    console.log('🚀 Logging in automatically (no password needed)...');
    await page.goto(frontdoorUrl);
    
    // Wait for Lightning Experience to load (don't wait for network to be idle - Lightning keeps polling)
    await page.waitForURL('**/lightning/**', { 
      timeout: 30000
    });
    
    console.log('✅ Successfully logged into Salesforce!');
    
    // Verify we're logged in by checking for the app launcher
    const appLauncher = page.locator('.slds-icon-waffle');
    await expect(appLauncher).toBeVisible({ timeout: 10000 });
    
    // Navigate to Accounts to prove we're logged in
    await page.goto(`${instanceUrl}/lightning/o/Account/list`);
    
    // Wait for the Accounts page to load (domcontentloaded is enough for Lightning)
    await page.waitForLoadState('domcontentloaded');
    
    // Take a screenshot as proof
    await page.screenshot({ 
      path: 'test-results/sfdx-login-success.png',
      fullPage: false 
    });
    
    console.log('📸 Screenshot saved: test-results/sfdx-login-success.png');
    console.log('🎉 Test complete - logged in without password!');
  });
});