const { test, expect } = require('@playwright/test');
const { SalesforceAuth } = require('./helpers/salesforce-auth');

test.describe('Salesforce Tests with Login Helper', () => {
  let auth;

  test.beforeEach(async ({ page }) => {
    // Initialize the auth helper
    auth = new SalesforceAuth(page);
  });

  test('should login and navigate to Accounts', async ({ page }) => {
    // Login using the helper
    await auth.login();

    // Navigate to Accounts
    await auth.navigateToObjectList('Account');

    // Verify we're on the Accounts page
    const pageHeader = page.locator('h1, .slds-page-header__title');
    await expect(pageHeader).toContainText('Accounts', { timeout: 10000 });

    // Take a screenshot
    await page.screenshot({ path: 'test-results/accounts-page.png' });
  });

  test('should login and open app launcher', async ({ page }) => {
    // Login using the helper
    await auth.login();

    // Click on app launcher
    const appLauncher = page.locator('.slds-icon-waffle');
    await appLauncher.click();

    // Verify app launcher modal is open
    const appLauncherModal = page.locator('.slds-app-launcher__content');
    await expect(appLauncherModal).toBeVisible({ timeout: 5000 });

    // Look for some common apps
    const salesApp = page.locator('text="Sales"');
    await expect(salesApp).toBeVisible();
  });

  test('should check login status', async ({ page }) => {
    // Check if logged in (should be false initially)
    let isLoggedIn = await auth.isLoggedIn();
    expect(isLoggedIn).toBe(false);

    // Login
    await auth.login();

    // Check again (should be true now)
    isLoggedIn = await auth.isLoggedIn();
    expect(isLoggedIn).toBe(true);
  });

  test.afterEach(async ({ page }) => {
    // Optional: Logout after each test
    // Uncomment if you want to logout after each test
    // if (await auth.isLoggedIn()) {
    //   await auth.logout();
    // }
  });
});