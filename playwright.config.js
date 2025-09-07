const { defineConfig, devices } = require('@playwright/test');

module.exports = defineConfig({
  testDir: './tests',
  timeout: 120000, // 2 minutes per test
  expect: {
    timeout: 30000 // 30 seconds for assertions
  },
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: 0,
  workers: 1,
  reporter: 'list',
  use: {
    // Run in headed mode
    headless: false,
    
    // Base URL
    baseURL: 'https://orgfarm-99db23b830-dev-ed.develop.lightning.force.com',
    
    // Collect trace on failure
    trace: 'on-first-retry',
    
    // Screenshot on failure
    screenshot: 'only-on-failure',
    
    // Video recording
    video: 'retain-on-failure',
    
    // Viewport size
    viewport: { width: 1920, height: 1080 },
    
    // Slow down actions for visibility
    slowMo: 500,
    
    // Accept downloads
    acceptDownloads: true,
  },

  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] },
    },
  ],

  outputDir: 'test-results/',
});