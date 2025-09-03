const { test, expect } = require('@playwright/test');

test.describe('Salesforce Login', () => {
  test('should login to Salesforce successfully', async ({ page }) => {
    // Navigate to Salesforce login page
    await page.goto('/');
    
    // Wait for the login page to load
    await page.waitForSelector('#username', { timeout: 10000 });
    
    // Enter username
    await page.fill('#username', process.env.SALESFORCE_USERNAME || 'robinjosephparfan691@agentforce.com');
    
    // Enter password with security token
    // Salesforce requires: password + security_token for API/untrusted network access
    const password = process.env.SALESFORCE_PASSWORD || 'YOUR_PASSWORD_HERE';
    const securityToken = process.env.SALESFORCE_SECURITY_TOKEN || '';
    const fullPassword = password + securityToken;
    
    await page.fill('#password', fullPassword);
    
    // Click the Login button
    await page.click('#Login');
    
    // Wait for successful login - Salesforce typically redirects to lightning experience
    // or classic UI after successful login
    await page.waitForURL('**/lightning/**', { 
      timeout: 30000,
      waitUntil: 'networkidle' 
    });
    
    // Verify we're logged in by checking for common Salesforce elements
    // This could be the app launcher, user profile menu, or other UI elements
    const appLauncher = page.locator('.slds-icon-waffle');
    await expect(appLauncher).toBeVisible({ timeout: 10000 });
    
    // Optional: Take a screenshot of successful login
    await page.screenshot({ path: 'test-results/login-success.png' });
    
    console.log('✅ Successfully logged into Salesforce');
  });

  test('should handle invalid credentials', async ({ page }) => {
    // Navigate to Salesforce login page
    await page.goto('/');
    
    // Wait for the login page to load
    await page.waitForSelector('#username', { timeout: 10000 });
    
    // Enter invalid credentials
    await page.fill('#username', 'invalid@example.com');
    await page.fill('#password', 'wrongpassword');
    
    // Click the Login button
    await page.click('#Login');
    
    // Check for error message
    const errorMessage = page.locator('#error, .loginError');
    await expect(errorMessage).toBeVisible({ timeout: 5000 });
    
    // Verify error text contains expected message
    const errorText = await errorMessage.textContent();
    expect(errorText).toContain('Please check your username and password');
    
    console.log('✅ Invalid credentials handled correctly');
  });
});