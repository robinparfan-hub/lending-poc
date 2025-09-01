const { test, chromium } = require('@playwright/test');

test('Navigate to Google and wait', async () => {
  // Launch Chrome browser
  const browser = await chromium.launch({
    headless: false // Set to true if you want to run in headless mode
  });
  
  // Create a new page
  const page = await browser.newPage();
  
  // Navigate to Google
  await page.goto('https://www.google.com');
  
  // Wait for 5 seconds
  await page.waitForTimeout(5000);
  
  // Close the browser
  await browser.close();
});