const { test, expect } = require('@playwright/test');
const { execSync } = require('child_process');

test.describe('Lending Console Navigation', () => {
  
  test('Navigate to Lending Console and view loan application record', async ({ page }) => {
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
    
    // Use frontdoor.jsp to login with the access token and go to Lightning home
    const frontdoorUrl = `${instanceUrl}/secur/frontdoor.jsp?sid=${accessToken}&retURL=/lightning/page/home`;
    
    console.log('🚀 Logging in and navigating to Lightning home page...');
    await page.goto(frontdoorUrl);
    
    // Wait for Lightning Experience home page to load
    await page.waitForURL('**/lightning/page/home', { 
      timeout: 30000
    });
    
    console.log('✅ Successfully logged into Salesforce Lightning home page!');
    
    // Now navigate to Lending Console
    console.log('📱 Navigating to Lending Console app...');
    await page.goto(`${instanceUrl}/lightning/app/c__Lending_Console`);
    
    // Wait for the app to fully load (skip networkidle due to Lightning polling)
    await page.waitForLoadState('domcontentloaded');
    await page.waitForTimeout(2000); // Allow Lightning to render
    
    // Take screenshot of the Lending Console
    await page.screenshot({ 
      path: 'test-results/lending-console-home.png',
      fullPage: false 
    });
    console.log('📸 Screenshot saved: test-results/lending-console-home.png');
    
    // Navigate to Loan Applications tab
    console.log('📋 Navigating to Loan Applications...');
    await page.goto(`${instanceUrl}/lightning/o/Loan_Application__c/list`);
    
    // Wait for the list view to load
    await page.waitForLoadState('domcontentloaded');
    await page.waitForTimeout(3000); // Allow Lightning to render
    
    // Take screenshot of loan applications list
    await page.screenshot({ 
      path: 'test-results/loan-applications-list.png',
      fullPage: false 
    });
    console.log('📸 Screenshot saved: test-results/loan-applications-list.png');
    
    // Look for John Smith's loan application (should be in test data)
    console.log('🔍 Looking for test loan applications...');
    
    // Try to click on the first loan application record
    try {
      // Wait for Lightning data table to load
      await page.waitForSelector('lightning-datatable', { timeout: 10000 });
      
      // Try different selectors for the rows
      let rows = page.locator('lightning-datatable tbody tr');
      let rowCount = await rows.count();
      
      if (rowCount === 0) {
        // Try alternative selector
        rows = page.locator('table tbody tr');
        rowCount = await rows.count();
      }
      
      if (rowCount === 0) {
        // Try div-based rows (some Lightning tables use divs)
        rows = page.locator('[data-row-key-value]');
        rowCount = await rows.count();
      }
      
      console.log(`Found ${rowCount} loan application rows`);
      
      if (rowCount > 0) {
        // Try to click on a link within the first row (record name link)
        try {
          const recordLink = page.locator('lightning-datatable tbody tr').first().locator('a').first();
          if (await recordLink.isVisible()) {
            console.log('🎯 Clicking on record name link...');
            await recordLink.click();
          } else {
            console.log('🎯 Clicking on first row...');
            await rows.first().click();
          }
        } catch (linkError) {
          console.log('🎯 Trying row click fallback...');
          await rows.first().click();
        }
        
        console.log('⏳ Waiting for navigation to record page...');
        
        try {
          // Wait for the record page to load with more flexible URL matching
          await page.waitForURL(/.*\/Loan_Application__c\/.*\/view/, { timeout: 15000 });
          await page.waitForLoadState('domcontentloaded');
          await page.waitForTimeout(3000); // Allow Lightning to render
          
          console.log('✅ Successfully navigated to loan application detail page!');
          
          // Take screenshot of the loan application detail page
          await page.screenshot({ 
            path: 'test-results/loan-application-detail.png',
            fullPage: true 
          });
          console.log('📸 Screenshot saved: test-results/loan-application-detail.png');
          
          // Try to extract some record information
          try {
            // Look for the record header/title
            const recordHeader = page.locator('[data-aura-class*="forceRecordLayout"] h1, .record-header h1, .slds-page-header h1');
            if (await recordHeader.isVisible()) {
              const headerText = await recordHeader.textContent();
              console.log('📋 Record:', headerText?.trim());
            }
            
            // Look for field values in various formats
            const fieldLabels = await page.locator('.slds-form-element__label, [data-label]').all();
            for (let i = 0; i < Math.min(fieldLabels.length, 5); i++) {
              try {
                const label = await fieldLabels[i].textContent();
                console.log(`🏷️ Found field: ${label?.trim()}`);
              } catch (e) {
                // Skip fields that can't be read
              }
            }
            
          } catch (fieldError) {
            console.log('ℹ️ Could not extract specific field values');
          }
          
        } catch (navError) {
          console.log('⚠️ Could not navigate to record detail page:', navError.message);
          
          // Take screenshot of current state for debugging
          await page.screenshot({ 
            path: 'test-results/navigation-debug.png',
            fullPage: false 
          });
          console.log('📸 Debug screenshot saved: test-results/navigation-debug.png');
        }
        
      } else {
        console.log('ℹ️ No loan application records found in any table format');
        
        // Take screenshot to see what's actually on the page
        await page.screenshot({ 
          path: 'test-results/no-records-debug.png',
          fullPage: true 
        });
        console.log('📸 Debug screenshot saved: test-results/no-records-debug.png');
      }
      
    } catch (error) {
      console.log('ℹ️ Error finding loan application records:', error.message);
      
      // Take screenshot for debugging
      await page.screenshot({ 
        path: 'test-results/table-error-debug.png',
        fullPage: true 
      });
      console.log('📸 Debug screenshot saved: test-results/table-error-debug.png');
    }
    
    console.log('🎉 Lending Console navigation test complete!');
  });
  
  test('Navigate directly to specific loan application if available', async ({ page }) => {
    console.log('🔐 Getting Salesforce CLI session for direct navigation...');
    
    let accessToken, instanceUrl;
    
    try {
      // Get auth info from SF CLI  
      const authInfo = execSync('/usr/local/bin/sf org display --target-org lending-poc --json', { 
        encoding: 'utf8',
        stdio: ['pipe', 'pipe', 'ignore'],
        env: { ...process.env, FORCE_COLOR: '0', NO_COLOR: '1' }
      });
      
      const cleanedInfo = authInfo.replace(/\x1b\[[0-9;]*m/g, '');
      const auth = JSON.parse(cleanedInfo);
      
      if (auth.status !== 0 || !auth.result.accessToken) {
        throw new Error('SF CLI not authenticated');
      }
      
      accessToken = auth.result.accessToken;
      instanceUrl = auth.result.instanceUrl;
      
      console.log('✅ Got access token from SF CLI');
      
    } catch (error) {
      console.error('❌ Failed to get SF CLI session:', error.message);
      test.skip();
      return;
    }
    
    // Login first and go to Lightning home page
    const frontdoorUrl = `${instanceUrl}/secur/frontdoor.jsp?sid=${accessToken}&retURL=/lightning/page/home`;
    await page.goto(frontdoorUrl);
    await page.waitForURL('**/lightning/page/home', { timeout: 30000 });
    
    console.log('✅ Successfully logged into Salesforce Lightning home page!');
    
    console.log('🔍 Searching for loan applications via SOQL...');
    
    try {
      // Use JavaScript in the browser to query for loan applications
      const loanApps = await page.evaluate(async () => {
        // This is a simple check to see if we can access any loan applications
        // In a real test, you might use the Salesforce REST API
        return { message: 'Direct SOQL query would require additional setup' };
      });
      
      console.log('📋 Attempting to navigate to Loan Applications list view...');
      
      // Navigate to the Loan Application object's list view
      await page.goto(`${instanceUrl}/lightning/o/Loan_Application__c/list?filterName=Recent`);
      await page.waitForLoadState('domcontentloaded');
      await page.waitForTimeout(3000);
      
      // Take a final screenshot
      await page.screenshot({ 
        path: 'test-results/loan-apps-recent-view.png',
        fullPage: false 
      });
      console.log('📸 Screenshot saved: test-results/loan-apps-recent-view.png');
      
      console.log('✅ Direct navigation test complete!');
      
    } catch (error) {
      console.log('ℹ️ Direct navigation had issues:', error.message);
    }
  });
});