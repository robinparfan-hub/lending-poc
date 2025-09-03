// Quick test script to verify SFDX authentication
const { execSync } = require('child_process');

console.log('Testing SF CLI authentication...\n');

try {
  // Get auth info from SF CLI
  const authInfo = execSync('sf org display --target-org lending-poc --json', { 
    encoding: 'utf8'
  });
  
  console.log('Raw output length:', authInfo.length);
  console.log('First 200 chars:', authInfo.substring(0, 200));
  
  // Parse JSON
  const auth = JSON.parse(authInfo);
  
  if (auth.status === 0 && auth.result.accessToken) {
    console.log('\n✅ SF CLI Authentication successful!');
    console.log('Username:', auth.result.username);
    console.log('Instance URL:', auth.result.instanceUrl);
    console.log('Access Token:', auth.result.accessToken.substring(0, 20) + '...');
    
    // Build frontdoor URL
    const frontdoorUrl = `${auth.result.instanceUrl}/secur/frontdoor.jsp?sid=${auth.result.accessToken}&retURL=/lightning`;
    console.log('\n🔗 Frontdoor URL (for automatic login):');
    console.log(frontdoorUrl);
    
  } else {
    console.log('❌ SF CLI not authenticated');
  }
  
} catch (error) {
  console.error('❌ Error:', error.message);
  console.log('\nPlease run: sf org login web --alias lending-poc');
}