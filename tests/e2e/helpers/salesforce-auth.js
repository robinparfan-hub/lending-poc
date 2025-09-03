const { expect } = require('@playwright/test');

class SalesforceAuth {
  constructor(page) {
    this.page = page;
    this.username = process.env.SALESFORCE_USERNAME || 'robinjosephparfan691@agentforce.com';
    
    // Combine password with security token if provided
    const password = process.env.SALESFORCE_PASSWORD || 'YOUR_PASSWORD_HERE';
    const securityToken = process.env.SALESFORCE_SECURITY_TOKEN || '';
    this.password = password + securityToken;
    
    this.baseUrl = process.env.SALESFORCE_URL || 'https://orgfarm-99db23b830-dev-ed.develop.my.salesforce.com';
  }

  /**
   * Login to Salesforce
   * @param {Object} options - Login options
   * @param {string} options.username - Override default username
   * @param {string} options.password - Override default password
   * @param {boolean} options.waitForLightning - Wait for Lightning Experience to load (default: true)
   * @returns {Promise<void>}
   */
  async login(options = {}) {
    const { 
      username = this.username, 
      password = this.password,
      waitForLightning = true 
    } = options;

    console.log(`🔐 Logging into Salesforce as ${username}`);

    // Navigate to login page if not already there
    if (!this.page.url().includes('/login')) {
      await this.page.goto(this.baseUrl);
    }

    // Wait for login form
    await this.page.waitForSelector('#username', { timeout: 10000 });

    // Fill in credentials
    await this.page.fill('#username', username);
    await this.page.fill('#password', password);

    // Submit form
    await this.page.click('#Login');

    if (waitForLightning) {
      // Wait for Lightning Experience to load
      await this.waitForLightningExperience();
    } else {
      // Wait for any successful redirect
      await this.page.waitForURL((url) => !url.href.includes('/login'), {
        timeout: 30000,
        waitUntil: 'networkidle'
      });
    }

    console.log('✅ Successfully logged into Salesforce');
  }

  /**
   * Wait for Lightning Experience to fully load
   */
  async waitForLightningExperience() {
    // Wait for URL to contain lightning
    await this.page.waitForURL('**/lightning/**', { 
      timeout: 30000,
      waitUntil: 'networkidle' 
    });

    // Wait for app launcher to be visible
    const appLauncher = this.page.locator('.slds-icon-waffle');
    await expect(appLauncher).toBeVisible({ timeout: 10000 });
  }

  /**
   * Logout from Salesforce
   */
  async logout() {
    console.log('🔓 Logging out of Salesforce');

    // Click on user profile menu
    const userProfile = this.page.locator('.profileTrigger, .slds-avatar');
    await userProfile.click();

    // Click logout
    const logoutLink = this.page.locator('a[href*="/secur/logout.jsp"], text="Log Out"');
    await logoutLink.click();

    // Wait for redirect to login page
    await this.page.waitForURL('**/login/**', { timeout: 10000 });

    console.log('✅ Successfully logged out');
  }

  /**
   * Check if currently logged in
   * @returns {Promise<boolean>}
   */
  async isLoggedIn() {
    try {
      // Check if we're on a lightning page
      if (this.page.url().includes('/lightning/')) {
        // Try to find the app launcher
        const appLauncher = this.page.locator('.slds-icon-waffle');
        await appLauncher.waitFor({ timeout: 3000 });
        return true;
      }
      return false;
    } catch {
      return false;
    }
  }

  /**
   * Navigate to a specific Salesforce app
   * @param {string} appName - Name of the app to navigate to
   */
  async navigateToApp(appName) {
    console.log(`📱 Navigating to ${appName} app`);

    // Click app launcher
    const appLauncher = this.page.locator('.slds-icon-waffle');
    await appLauncher.click();

    // Wait for app launcher modal
    await this.page.waitForSelector('.slds-app-launcher__content', { timeout: 5000 });

    // Search for and click on the app
    const searchBox = this.page.locator('input[placeholder*="Search"]');
    await searchBox.fill(appName);

    const appTile = this.page.locator(`.slds-app-launcher__tile-body:has-text("${appName}")`);
    await appTile.click();

    // Wait for navigation
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Navigate to a specific object's list view
   * @param {string} objectName - Name of the object (e.g., 'Accounts', 'Contacts')
   */
  async navigateToObjectList(objectName) {
    console.log(`📋 Navigating to ${objectName} list view`);

    // Use the URL pattern for object list views
    await this.page.goto(`${this.baseUrl}/lightning/o/${objectName}/list`);
    await this.page.waitForLoadState('networkidle');
  }

  /**
   * Handle Salesforce verification code if prompted
   * @param {string} code - Verification code
   */
  async handleVerificationCode(code) {
    // Check if verification is required
    const verificationInput = this.page.locator('#verification_code, input[name="code"]');
    
    if (await verificationInput.isVisible()) {
      console.log('📧 Entering verification code');
      await verificationInput.fill(code);
      
      const verifyButton = this.page.locator('button:has-text("Verify"), input[value="Verify"]');
      await verifyButton.click();
      
      await this.waitForLightningExperience();
    }
  }
}

module.exports = { SalesforceAuth };