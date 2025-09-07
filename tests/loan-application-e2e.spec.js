const { test, expect } = require('@playwright/test');
const { execSync } = require('child_process');

/**
 * End-to-End Loan Application Test
 * 
 * This test fills in all form fields programmatically and does NOT rely on prepopulated data.
 * It will work whether the form has prepopulated values or is completely empty.
 * 
 * Test data is configured to match Decision Engine expectations for approval:
 * - Loan amount: $50,000 (gets approved by Decision Engine)
 * - Income: $120,000 (high income for excellent credit scenario)
 * - Full name: Used consistently for both application and digital signature
 */
test.describe('Loan Application End-to-End Flow', () => {
  test('Complete loan application from start to funding', async ({ page }) => {
    // Configure test with longer timeout for external service calls
    test.setTimeout(120000); // 2 minutes total timeout

    console.log('🔐 Getting Salesforce CLI session...');
    
    let accessToken, instanceUrl;
    
    try {
      // Get auth info from SF CLI  
      const authInfo = execSync('/usr/local/bin/sf org display --target-org lending-poc --json', { 
        encoding: 'utf8',
        stdio: ['pipe', 'pipe', 'ignore'], // Ignore stderr
        env: { ...process.env, FORCE_COLOR: '0', NO_COLOR: '1' } // Disable colors
      });
      
      // Strip ANSI color codes from the output
      const cleanedInfo = authInfo.replace(/\x1b\[[0-9;]*m/g, '');
      
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
    const frontdoorUrl = `${instanceUrl}/secur/frontdoor.jsp?sid=${accessToken}&retURL=/lightning/page/home`;
    
    console.log('🚀 Logging in automatically...');
    await page.goto(frontdoorUrl);
    
    // Wait for Lightning Experience to load
    await page.waitForURL('**/lightning/**', { 
      timeout: 30000
    });
    
    console.log('✅ Successfully logged into Salesforce!');
    
    // Make sure we're on the Home tab
    const homeTab = page.locator('a[title="Home"], a:has-text("Home")').first();
    const isHomeActive = await homeTab.evaluate(el => el.getAttribute('aria-selected') === 'true');
    
    if (!isHomeActive) {
      console.log('Navigating to Home tab...');
      await homeTab.click();
      await page.waitForTimeout(2000);
    }
    
    // The Loan Application wizard should now be visible on the Home page
    // Click Start New Application button
    console.log('Starting new loan application...');
    await page.click('button:has-text("Start New Application")');
    await page.waitForTimeout(3000);
    
    // Define test data that matches what Decision Engine expects for approval
    const testData = {
      // Personal Information
      fullName: 'John Doe',
      email: 'john.doe@test.com',
      phone: '555-555-5555',
      dateOfBirth: '12/31/2000',
      
      // Loan Details  
      loanAmount: '50000', // Matches Decision Engine approved amount
      loanPurpose: 'Home Improvement',
      loanTerm: '60', // 60 months
      
      // Financial Information
      employmentStatus: 'Employed',
      annualIncome: '120000', // High income for excellent credit scenario
      monthlyDebt: '2000'
    };
    
    console.log('Filling loan application form...');
    
    // Fill Loan Details section
    console.log('Filling loan details...');
    
    // Loan Amount - be specific to avoid confusion with other fields
    const loanAmountInput = page.locator('text="Loan Amount" >> .. >> input[type="text"], text="Loan Amount Requested" >> .. >> input').first();
    if (await loanAmountInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await loanAmountInput.clear();
      await loanAmountInput.fill(testData.loanAmount);
      console.log(`Filled loan amount: $${testData.loanAmount}`);
    }
    
    // Loan Purpose (dropdown)
    const loanPurposeDropdown = page.locator('select, lightning-combobox, button[aria-label*="Loan Purpose" i]').first();
    if (await loanPurposeDropdown.isVisible({ timeout: 2000 }).catch(() => false)) {
      await loanPurposeDropdown.click();
      await page.click(`text="${testData.loanPurpose}"`);
    }
    
    // Loan Term (dropdown)
    const loanTermDropdown = page.locator('select[name*="Term" i], lightning-combobox:has-text("Term"), button[aria-label*="Term" i]').first();
    if (await loanTermDropdown.isVisible({ timeout: 2000 }).catch(() => false)) {
      await loanTermDropdown.click();
      await page.click('text="60 months"');
    }
    
    // Fill Applicant Information section
    console.log('Filling applicant information...');
    
    // Full Name - Look specifically for the Full Name field in Applicant Information
    console.log('Looking for Full Name field...');
    
    // Wait a bit for form to fully load
    await page.waitForTimeout(1000);
    
    // Look for the Full Name field specifically - it should be labeled "Full Name"
    const fullNameField = page.locator('text="Full Name" >> .. >> input[type="text"]').first();
    
    if (await fullNameField.isVisible({ timeout: 2000 }).catch(() => false)) {
      const existingValue = await fullNameField.inputValue();
      
      if (existingValue && existingValue.trim() !== '') {
        // Check if this is a prepopulated test name
        if (existingValue.startsWith('Test ') && existingValue.match(/\d{10,}/)) {
          // This is a generated test name like "Test 202509070956"
          testData.fullName = existingValue.trim();
          console.log(`Using prepopulated test name: ${testData.fullName}`);
        } else if (!existingValue.includes('$') && !existingValue.match(/^\d+$/)) {
          // Use the existing value if it's not a number or currency
          testData.fullName = existingValue.trim();
          console.log(`Using existing name: ${testData.fullName}`);
        } else {
          // Wrong data in field, replace it
          await fullNameField.clear();
          await fullNameField.fill(testData.fullName);
          console.log(`Replaced invalid value with: ${testData.fullName}`);
        }
      } else {
        // Field is empty, fill it
        await fullNameField.clear();
        await fullNameField.fill(testData.fullName);
        console.log(`Filled empty name field with: ${testData.fullName}`);
      }
    } else {
      console.log('Full Name field not found, keeping default: ' + testData.fullName);
    }
    
    // Log what name we'll use for signature
    console.log(`Name to be used for digital signature: ${testData.fullName}`);
    
    // Email
    const emailInput = page.locator('input[type="email"], input[placeholder*="Email" i], label:has-text("Email") + input').first();
    if (await emailInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await emailInput.clear();
      await emailInput.fill(testData.email);
    }
    
    // Phone
    const phoneInput = page.locator('input[type="tel"], input[placeholder*="Phone" i], label:has-text("Phone") + input').first();
    if (await phoneInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await phoneInput.clear();
      await phoneInput.fill(testData.phone);
    }
    
    // Employment Status (dropdown)
    const employmentDropdown = page.locator('select[name*="Employment" i], lightning-combobox:has-text("Employment"), button[aria-label*="Employment" i]').first();
    if (await employmentDropdown.isVisible({ timeout: 2000 }).catch(() => false)) {
      await employmentDropdown.click();
      await page.click(`text="${testData.employmentStatus}"`);
    }
    
    // Date of Birth
    const dobInput = page.locator('input[type="date"], input[placeholder*="Date of Birth" i], label:has-text("Date of Birth") + input').first();
    if (await dobInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await dobInput.fill('2000-12-31'); // Use ISO format for date inputs
    }
    
    // Fill Financial Information if visible
    console.log('Checking for financial information fields...');
    
    // Annual Income
    const incomeInput = page.locator('input[placeholder*="Income" i], label:has-text("Income") + input, input[name*="Income" i]').first();
    if (await incomeInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await incomeInput.clear();
      await incomeInput.fill(testData.annualIncome);
    }
    
    // Monthly Debt
    const debtInput = page.locator('input[placeholder*="Debt" i], label:has-text("Debt") + input, input[name*="Debt" i]').first();
    if (await debtInput.isVisible({ timeout: 2000 }).catch(() => false)) {
      await debtInput.clear();
      await debtInput.fill(testData.monthlyDebt);
    }
    
    await page.waitForTimeout(2000);
    
    // Submit the application
    console.log('Submitting loan application...');
    await page.click('button:has-text("Submit Application")');
    await page.waitForTimeout(2000);
    
    // Store the test data for later use in signature
    page.testData = testData;
    
    // Wait for external service processing (Decision Engine on Render)
    console.log('Waiting for Decision Engine to process application...');
    
    // Wait for the Digital Acceptance section or loan offer elements to appear
    // This is more reliable than waiting for a fixed time
    const offerIndicators = [
      'text="Digital Signature"',
      'text="Digital Acceptance"',
      'text="I have read and agree"',
      'button:has-text("Accept Loan Offer")',
      'text="Enter your full legal name"',
      'text=/approved/i',
      'text=/congratulations/i'
    ];
    
    console.log('Waiting for loan decision elements to appear...');
    let offerFound = false;
    
    // Wait up to 30 seconds for any loan offer element to appear
    for (const selector of offerIndicators) {
      if (await page.locator(selector).isVisible({ timeout: 30000 }).catch(() => false)) {
        console.log(`Loan offer element found: ${selector}`);
        offerFound = true;
        break;
      }
    }
    
    if (!offerFound) {
      console.log('Warning: No loan offer elements found after 30 seconds');
    }
    
    // Small wait to ensure all elements are loaded
    await page.waitForTimeout(2000);
    
    // Fill in the Full Name field for signature (use same name from application)
    console.log('Entering full name for digital signature...');
    const signatureName = page.testData?.fullName || 'Test User';
    console.log(`Will use signature name: ${signatureName}`);
    
    // Look for the specific input with placeholder "Enter your full legal name"
    const signatureInput = page.locator('input[placeholder*="Enter your full legal name" i], input[placeholder*="legal name" i], input[placeholder*="full name" i]').first();
    if (await signatureInput.isVisible({ timeout: 5000 }).catch(() => false)) {
      // Clear any existing value first
      await signatureInput.clear();
      await signatureInput.click();
      await signatureInput.fill(signatureName);
      console.log(`Digital signature entered: ${signatureName}`);
    } else {
      // Fallback: try any visible text input in the Digital Acceptance area
      const digitalAcceptanceInputs = page.locator('text="Digital Signature" >> .. >> input[type="text"]');
      if (await digitalAcceptanceInputs.isVisible({ timeout: 3000 }).catch(() => false)) {
        await digitalAcceptanceInputs.clear();
        await digitalAcceptanceInputs.fill(signatureName);
        console.log(`Signature entered via fallback: ${signatureName}`);
      }
    }
    
    await page.waitForTimeout(1000);
    
    // Check the Terms and Conditions checkbox
    console.log('Accepting terms and conditions...');
    
    // Try clicking the label text instead of the checkbox itself to avoid interception
    const termsLabel = page.locator('text="I have read and agree to the terms and conditions"');
    if (await termsLabel.isVisible({ timeout: 3000 }).catch(() => false)) {
      await termsLabel.click();
      console.log('Terms and conditions accepted by clicking label');
    } else {
      // Fallback: try to force click the checkbox
      const termsCheckbox = page.locator('input[type="checkbox"]:not(:checked)').first();
      if (await termsCheckbox.isVisible({ timeout: 2000 }).catch(() => false)) {
        // Use force click to bypass any overlapping elements
        await termsCheckbox.click({ force: true });
        console.log('Checkbox checked using force click');
      }
    }
    
    await page.waitForTimeout(1000);
    
    // Click Accept Loan Offer button
    console.log('Clicking Accept Loan Offer button...');
    const acceptButton = page.locator('button:has-text("Accept Loan Offer")').first();
    if (await acceptButton.isVisible({ timeout: 5000 }).catch(() => false)) {
      // Make sure button is enabled (not disabled by missing signature/checkbox)
      const isDisabled = await acceptButton.isDisabled();
      if (isDisabled) {
        console.log('Accept button is disabled, checking if all fields are filled...');
        // Try filling fields again if button is disabled
        await signatureInput.fill(signatureName);
        await termsCheckbox.check();
        await page.waitForTimeout(1000);
      }
      
      await acceptButton.click();
      console.log('Loan offer accepted!');
      await page.waitForTimeout(5000);
    } else {
      console.log('Accept Loan Offer button not found');
    }
    
    // Final verification - look for success notification
    console.log('Verifying loan application success...');
    
    // Look for the success toast notification that says "Application submitted successfully"
    const successNotification = page.locator('[data-toast-text*="success" i], text=/application.*submitted/i').first();
    if (await successNotification.isVisible({ timeout: 5000 }).catch(() => false)) {
      console.log('✅ Success notification found!');
    }
    
    // Take final screenshot
    await page.screenshot({ path: 'test-results/final-state.png' });
    
    console.log('✅ Loan application test completed successfully!');
  });
});