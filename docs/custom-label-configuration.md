# Custom Label Configuration Guide

## Overview
The lending platform uses Custom Labels for runtime configuration, allowing you to change system behavior without modifying code or redeploying.

## How to Access Custom Labels

### In Salesforce Setup:
1. Go to **Setup** → **Custom Labels**
2. Find and edit any label value
3. Changes take effect immediately (no deployment needed!)

### Via VS Code:
Edit `/force-app/main/default/labels/CustomLabels.labels-meta.xml`

## Available Configuration Labels

### 🔧 Core Configuration

#### `Use_Mock_Data`
- **Current Value**: `true`
- **Purpose**: Toggle between mock data and real API calls
- **Values**: 
  - `true` - Use hardcoded mock responses (for demos/testing)
  - `false` - Use real API integrations (when implemented)
- **Used By**: All service classes

**To switch to production APIs:**
1. Setup → Custom Labels → Use_Mock_Data → Edit
2. Change value from `true` to `false`
3. Save

#### `Mock_Response_Delay_Ms`
- **Current Value**: `500`
- **Purpose**: Simulate API latency in milliseconds
- **Values**: 0-5000 (recommended)
- **Used By**: MockDataFactory
- **Note**: Set to `0` for instant responses during demos

#### `Enable_Service_Debug_Logging`
- **Current Value**: `true`
- **Purpose**: Enable detailed debug logs for troubleshooting
- **Values**: `true` or `false`
- **Used By**: All service classes

### 📊 Business Rules Configuration

#### `Min_Credit_Score`
- **Current Value**: `620`
- **Purpose**: Minimum credit score required for loan approval
- **Used By**: DecisionEngineService
- **Impact**: Applications below this score are automatically denied

#### `Max_DTI_Ratio`
- **Current Value**: `45`
- **Purpose**: Maximum debt-to-income ratio allowed (percentage)
- **Used By**: DecisionEngineService
- **Impact**: Applications exceeding this ratio may be denied

#### `Max_Loan_Amount`
- **Current Value**: `100000`
- **Purpose**: Maximum loan amount the system can approve
- **Used By**: DecisionEngineService, LoanCalculatorService
- **Impact**: Caps the maximum approval amount

#### `Default_Credit_Bureau`
- **Current Value**: `Experian`
- **Purpose**: Default credit bureau for evaluations
- **Options**: `Experian`, `Equifax`, `TransUnion`
- **Used By**: CreditEvaluationService

## Usage Examples

### Scenario 1: Demo Mode (Current Setup)
```
Use_Mock_Data = true
Mock_Response_Delay_Ms = 500
```
- Returns consistent, predictable data
- 500ms delay simulates real API response time
- Perfect for demos and testing

### Scenario 2: Fast Testing Mode
```
Use_Mock_Data = true
Mock_Response_Delay_Ms = 0
```
- Instant responses for rapid testing
- Still using mock data

### Scenario 3: Production Mode
```
Use_Mock_Data = false
Mock_Response_Delay_Ms = 0
Enable_Service_Debug_Logging = false
```
- Uses real API endpoints
- No artificial delays
- Minimal logging for performance

### Scenario 4: Strict Credit Requirements
```
Min_Credit_Score = 700
Max_DTI_Ratio = 35
Max_Loan_Amount = 50000
```
- More conservative lending criteria
- Higher credit score requirement
- Lower DTI tolerance
- Reduced maximum loan amount

## Impact on Services

### When `Use_Mock_Data` = true:
- **CreditEvaluationService**: Returns hardcoded credit scores based on applicantId
- **DecisionEngineService**: Uses mock scenarios for consistent decisions
- **LoanCalculatorService**: Still performs real calculations
- **MockDataFactory**: Generates all responses with optional delay

### When `Use_Mock_Data` = false:
- Services will call `getAPIResponse()` methods (to be implemented)
- Real external API endpoints will be used
- Response times will depend on actual API performance
- Error handling becomes critical

## Testing Different Scenarios

To test various approval scenarios while `Use_Mock_Data = true`, use these applicationIds:

1. **Excellent Credit Approval**: 
   - ApplicationId: `APP-001` or contains "EXCEL"
   - Result: Approved with best rates

2. **Good Credit Approval**:
   - ApplicationId: `APP-002` or contains "GOOD"
   - Result: Approved with standard rates

3. **Conditional Approval**:
   - ApplicationId: `APP-003` or contains "CONDITION"
   - Result: Approved with conditions

4. **Credit Denial**:
   - ApplicationId: `APP-004` or contains "LOWCREDIT"
   - Result: Denied due to low credit

5. **High DTI Denial**:
   - ApplicationId: `APP-005` or contains "DTI"
   - Result: Denied due to high debt-to-income

## Best Practices

1. **Change One Label at a Time**: Test impact before changing multiple labels
2. **Document Changes**: Keep track of label value changes
3. **Test After Changes**: Always test the application after modifying labels
4. **Production Caution**: Be very careful changing business rule labels in production
5. **Monitor Performance**: Watch system performance when adjusting delays

## Troubleshooting

### Changes Not Taking Effect?
- Custom Labels are cached for performance
- Try refreshing the page or logging out/in
- In extreme cases, clear Salesforce cache

### Getting Errors After Changes?
- Check that numeric labels contain valid numbers only
- Ensure boolean labels are exactly `true` or `false`
- Review debug logs if `Enable_Service_Debug_Logging = true`

### Mock Data Not Working?
- Verify `Use_Mock_Data = true`
- Check that MockDataFactory class is deployed
- Ensure all service classes are using the latest version

## Future Enhancements

As the system evolves, more Custom Labels can be added for:
- API endpoint URLs
- Timeout values
- Retry attempts
- Feature flags
- A/B testing configurations
- Regional settings

---

*By using Custom Labels, the lending platform becomes highly configurable without code changes, making it easy to adapt to different business requirements and testing scenarios.*