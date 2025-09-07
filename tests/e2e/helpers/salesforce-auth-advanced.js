const { expect } = require('@playwright/test');
const readline = require('readline');
const { execSync } = require('child_process');

class SalesforceAuthAdvanced {
  constructor(page) {
    this.page = page;
    this.baseUrl = process.env.SALESFORCE_URL || 'https://orgfarm-99db23b830-dev-ed.develop.my.salesforce.com';
    this.username = process.env.SALESFORCE_USERNAME || 'robinjosephparfan691@agentforce.com';
  }

  /**
   * Option 1: Use existing Salesforce CLI session
   * This uses your already authenticated Salesforce CLI session
   */
  async loginWithSfdxSession() {
    console.log('🔐 Using Salesforce CLI session for authentication');
    
    try {
      // Get the access token from SFDX, suppressing warnings to stderr
      const authInfo = execSync('sf org display --target-org lending-poc --json 2>/dev/null', { 
        encoding: 'utf8'
      });
      
      // Parse the JSON output
      const auth = JSON.parse(authInfo);
      
      if (auth.status !== 0) {
        throw new Error('Failed to get auth info from Salesforce CLI');
      }
      
      const accessToken = auth.result.accessToken;
      const instanceUrl = auth.result.instanceUrl;
      
      // Use the frontdoor.jsp URL to login with session ID
      const frontdoorUrl = `${instanceUrl}/secur/frontdoor.jsp?sid=${accessToken}&retURL=/lightning`;
      
      console.log('🔑 Logging in with Salesforce CLI session');
      await this.page.goto(frontdoorUrl);
      
      // Wait for Lightning Experience to load
      await this.page.waitForURL('**/lightning/**', { 
        timeout: 30000,
        waitUntil: 'networkidle' 
      });
      
      // Verify login
      const appLauncher = this.page.locator('.slds-icon-waffle');
      await expect(appLauncher).toBeVisible({ timeout: 10000 });
      
      console.log('✅ Successfully logged in using Salesforce CLI session');
      return true;
      
    } catch (error) {
      console.error('❌ Failed to use Salesforce CLI session:', error.message);
      console.log('💡 Make sure you are logged in with: sf org login web --alias lending-poc');
      return false;
    }
  }

  /**
   * Option 2: OAuth Web Server Flow (for CI/CD)
   * Uses OAuth with Connected App
   */
  async loginWithOAuth(clientId, clientSecret, refreshToken) {
    console.log('🔐 Using OAuth for authentication');
    
    try {
      // Exchange refresh token for access token
      const tokenUrl = `${this.baseUrl}/services/oauth2/token`;
      
      const response = await fetch(tokenUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          grant_type: 'refresh_token',
          client_id: clientId,
          client_secret: clientSecret,
          refresh_token: refreshToken,
        }),
      });
      
      const data = await response.json();
      
      if (!data.access_token) {
        throw new Error('Failed to get access token');
      }
      
      // Use frontdoor.jsp to login with the access token
      const frontdoorUrl = `${data.instance_url}/secur/frontdoor.jsp?sid=${data.access_token}&retURL=/lightning`;
      
      await this.page.goto(frontdoorUrl);
      await this.page.waitForURL('**/lightning/**', { 
        timeout: 30000,
        waitUntil: 'networkidle' 
      });
      
      console.log('✅ Successfully logged in using OAuth');
      return true;
      
    } catch (error) {
      console.error('❌ OAuth login failed:', error.message);
      return false;
    }
  }

  /**
   * Option 3: Interactive password prompt
   * Prompts for password at runtime (doesn't store it)
   */
  async loginWithPrompt() {
    console.log('🔐 Interactive login - password will be prompted');
    
    const password = await this.promptForPassword();
    const securityToken = process.env.SALESFORCE_SECURITY_TOKEN || '';
    
    // Navigate to login page
    await this.page.goto(this.baseUrl);
    await this.page.waitForSelector('#username', { timeout: 10000 });
    
    // Enter credentials
    await this.page.fill('#username', this.username);
    await this.page.fill('#password', password + securityToken);
    
    // Submit
    await this.page.click('#Login');
    
    // Wait for successful login
    await this.page.waitForURL('**/lightning/**', { 
      timeout: 30000,
      waitUntil: 'networkidle' 
    });
    
    const appLauncher = this.page.locator('.slds-icon-waffle');
    await expect(appLauncher).toBeVisible({ timeout: 10000 });
    
    console.log('✅ Successfully logged in');
    return true;
  }

  /**
   * Option 4: Use existing browser session
   * Reuses cookies from a previous session
   */
  async loginWithStoredSession(sessionFile = 'tests/e2e/.session.json') {
    console.log('🔐 Attempting to use stored session');
    
    const fs = require('fs');
    
    try {
      if (fs.existsSync(sessionFile)) {
        // Load stored cookies
        const cookies = JSON.parse(fs.readFileSync(sessionFile, 'utf8'));
        await this.page.context().addCookies(cookies);
        
        // Navigate to Lightning
        await this.page.goto(`${this.baseUrl}/lightning`);
        
        // Check if we're logged in
        try {
          const appLauncher = this.page.locator('.slds-icon-waffle');
          await appLauncher.waitFor({ timeout: 5000 });
          console.log('✅ Successfully logged in using stored session');
          return true;
        } catch {
          console.log('⚠️ Stored session expired, need to re-authenticate');
          return false;
        }
      } else {
        console.log('⚠️ No stored session found');
        return false;
      }
    } catch (error) {
      console.error('❌ Failed to use stored session:', error.message);
      return false;
    }
  }

  /**
   * Save current session for reuse
   */
  async saveSession(sessionFile = 'tests/e2e/.session.json') {
    const fs = require('fs');
    const cookies = await this.page.context().cookies();
    fs.writeFileSync(sessionFile, JSON.stringify(cookies, null, 2));
    console.log('💾 Session saved for future use');
  }

  /**
   * Option 5: Manual browser authentication
   * Opens browser and waits for manual login
   */
  async loginManually(timeout = 120000) {
    console.log('🔐 Manual login mode');
    console.log('👤 Please login manually in the browser window');
    console.log(`⏱️  You have ${timeout / 1000} seconds to complete login`);
    
    // Navigate to login page
    await this.page.goto(this.baseUrl);
    
    // Wait for user to manually login
    try {
      await this.page.waitForURL('**/lightning/**', { 
        timeout: timeout,
        waitUntil: 'networkidle' 
      });
      
      console.log('✅ Manual login successful');
      
      // Optionally save the session
      await this.saveSession();
      
      return true;
    } catch (error) {
      console.error('❌ Manual login timed out');
      return false;
    }
  }

  /**
   * Smart login - tries multiple methods in order
   */
  async login(options = {}) {
    const { 
      method = 'auto',
      saveSession = true 
    } = options;
    
    let success = false;
    
    // Try methods in order of preference
    const methods = {
      auto: ['session', 'sfdx', 'prompt'],
      sfdx: ['sfdx'],
      oauth: ['oauth'],
      prompt: ['prompt'],
      manual: ['manual'],
      session: ['session']
    };
    
    const methodsToTry = methods[method] || methods.auto;
    
    for (const authMethod of methodsToTry) {
      console.log(`\n🔄 Trying authentication method: ${authMethod}`);
      
      switch (authMethod) {
        case 'session':
          success = await this.loginWithStoredSession();
          break;
          
        case 'sfdx':
          success = await this.loginWithSfdxSession();
          break;
          
        case 'oauth':
          if (process.env.SALESFORCE_CLIENT_ID && process.env.SALESFORCE_REFRESH_TOKEN) {
            success = await this.loginWithOAuth(
              process.env.SALESFORCE_CLIENT_ID,
              process.env.SALESFORCE_CLIENT_SECRET,
              process.env.SALESFORCE_REFRESH_TOKEN
            );
          }
          break;
          
        case 'prompt':
          success = await this.loginWithPrompt();
          break;
          
        case 'manual':
          success = await this.loginManually();
          break;
      }
      
      if (success) {
        if (saveSession && authMethod !== 'session') {
          await this.saveSession();
        }
        break;
      }
    }
    
    if (!success) {
      throw new Error('All authentication methods failed');
    }
    
    return success;
  }

  /**
   * Helper to prompt for password
   */
  promptForPassword() {
    return new Promise((resolve) => {
      const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout,
      });
      
      // Hide password input
      rl.stdoutMuted = true;
      rl.question(`Enter password for ${this.username}: `, (password) => {
        rl.close();
        console.log(''); // New line after password
        resolve(password);
      });
      
      rl._writeToOutput = function _writeToOutput(stringToWrite) {
        if (rl.stdoutMuted) {
          rl.output.write("*");
        } else {
          rl.output.write(stringToWrite);
        }
      };
    });
  }
}

module.exports = { SalesforceAuthAdvanced };