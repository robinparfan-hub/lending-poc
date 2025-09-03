# Server-Side Apex Architecture Plan for Week 3
**Date Created**: September 3, 2025  
**Purpose**: Define the server-side Apex services needed to support LWC components and UI functionality  
**Approach**: Mock data initially, easily switchable to real API endpoints

## Overview
This document outlines the comprehensive set of Apex services that will power our Lightning Web Components with hardcoded responses initially, but architected to easily switch to real API endpoints later.

## Core Services to Build (10 Apex Classes + Test Classes)

### 1. CreditEvaluationService
**Purpose**: Handle all credit-related evaluations and scoring

**Methods**:
- `evaluateCreditScore(String applicantId)` - Returns credit score evaluation
- `getCreditReport(String applicationId)` - Retrieves full credit report
- `calculateCreditRisk(Decimal score, String loanType)` - Calculates risk level

**Mock Behavior**:
- Returns hardcoded credit scores (650-850 range)
- Simulates different credit bureau responses (Equifax, Experian, TransUnion)
- Provides realistic credit history patterns

**Future Integration**: 
- Equifax API
- Experian API
- TransUnion API

### 2. IncomeVerificationService
**Purpose**: Verify and validate income sources

**Methods**:
- `verifyIncome(String applicantId)` - Verifies all income sources
- `calculateDebtToIncome(String applicationId)` - Calculates DTI ratio
- `validateEmployment(String employerName, String applicantId)` - Validates employment

**Mock Behavior**:
- Returns hardcoded verification status (Verified/Unverified/Pending)
- Calculates realistic DTI ratios based on application data
- Mock employer verification responses with delays

**Future Integration**:
- Plaid API for bank verification
- The Work Number API
- IRS income verification

### 3. IdentityVerificationService
**Purpose**: Verify applicant identity and check for fraud

**Methods**:
- `verifyIdentity(String applicantId)` - Performs identity verification
- `checkFraud(Map<String, Object> applicantData)` - Fraud detection
- `validateSSN(String encryptedSSN)` - SSN validation

**Mock Behavior**:
- Returns hardcoded identity confidence scores (0-100)
- Mock KYC/AML check responses
- Simulated fraud patterns for testing

**Future Integration**:
- LexisNexis identity verification
- Jumio or Onfido for document verification
- SSA database validation

### 4. DecisionEngineService (Main Orchestrator)
**Purpose**: Central decision-making engine that orchestrates all evaluations

**Methods**:
- `evaluateApplication(String applicationId)` - Main evaluation method
- `generateDecision(Map<String, Object> evaluationResults)` - Creates final decision
- `calculateApprovalAmount(Decimal requested, Map<String, Object> riskFactors)` - Determines approved amount

**Mock Behavior**:
- Orchestrates calls to all other services
- Implements business rules for approval/denial/partial approval
- Returns comprehensive decision with reason codes

**Business Rules**:
- Credit score thresholds by loan type
- DTI ratio limits
- Income requirements
- Risk-based pricing

### 5. DocumentProcessingService
**Purpose**: Process and validate uploaded documents

**Methods**:
- `processDocument(String documentId)` - Process uploaded document
- `extractData(String documentType, Blob documentContent)` - Extract data from document
- `validateDocument(String documentId, String documentType)` - Validate document authenticity

**Mock Behavior**:
- Returns hardcoded OCR/extraction results
- Mock document verification statuses
- Simulated processing delays (2-5 seconds)

**Future Integration**:
- AWS Textract or Google Document AI
- Adobe Document Services
- Custom OCR solutions

### 6. RiskAssessmentService
**Purpose**: Assess risk and determine pricing

**Methods**:
- `calculateRiskScore(String applicationId)` - Calculate application risk score
- `determinePricing(Decimal riskScore, String loanType)` - Determine interest rates
- `assessPortfolioRisk()` - Portfolio-level risk assessment

**Mock Behavior**:
- Returns risk scores (1-100 scale)
- Provides recommended interest rates based on risk tiers
- Mock portfolio risk metrics

**Risk Factors**:
- Credit score weight: 35%
- DTI ratio weight: 25%
- Employment stability: 20%
- Loan purpose: 20%

### 7. LoanCalculatorService
**Purpose**: Perform loan calculations (no mocking needed - pure calculations)

**Methods**:
- `calculateMonthlyPayment(Decimal principal, Decimal rate, Integer months)` - Monthly payment
- `generateAmortization(String loanId)` - Full amortization schedule
- `calculateAPR(Decimal principal, Decimal rate, Decimal fees)` - Annual percentage rate

**Real Calculations**:
- Standard amortization formulas
- APR calculations including fees
- Early payoff calculations

### 8. ApplicationService
**Purpose**: Manage loan application lifecycle

**Methods**:
- `submitApplication(Map<String, Object> applicationData)` - Submit new application
- `updateStatus(String applicationId, String newStatus)` - Update application status
- `getApplicationDetails(String applicationId)` - Retrieve full application details

**Features**:
- CRUD operations for loan applications
- Status management and workflow triggers
- Application data validation
- Audit trail maintenance

### 9. NotificationService
**Purpose**: Handle all notification types

**Methods**:
- `sendEmailNotification(String templateId, Map<String, Object> mergeFields)` - Send email
- `sendSMSNotification(String phoneNumber, String message)` - Send SMS
- `createInAppAlert(String userId, String message, String severity)` - In-app notifications

**Mock Behavior**:
- Returns success responses immediately
- Logs notification attempts
- Mock delivery confirmations

**Future Integration**:
- SendGrid or AWS SES for email
- Twilio for SMS
- Salesforce Platform Events for real-time notifications

### 10. AnalyticsService
**Purpose**: Provide analytics and reporting data

**Methods**:
- `getPortfolioMetrics()` - Portfolio-level metrics
- `calculateApprovalRate(Date startDate, Date endDate)` - Approval rate calculations
- `generateExecutiveDashboard()` - Executive dashboard data

**Metrics Provided**:
- Application volume trends
- Approval/denial rates
- Average processing time
- Portfolio risk distribution
- Revenue projections

## Implementation Details

### Service Architecture Pattern
Each service will follow this standardized pattern:

```apex
public with sharing class [ServiceName] {
    // Configuration for easy switching between mock and real data
    private static Boolean USE_MOCK_DATA = true;
    private static final String SERVICE_NAME = '[ServiceName]';
    
    @AuraEnabled(cacheable=true)
    public static ServiceResponse methodName(ServiceRequest request) {
        try {
            // Input validation
            validateRequest(request);
            
            // Log service call
            logServiceCall(SERVICE_NAME, 'methodName', request);
            
            // Execute business logic
            if (USE_MOCK_DATA) {
                return getMockResponse(request);
            } else {
                return getAPIResponse(request);
            }
        } catch (ServiceException e) {
            return createErrorResponse(e.getMessage(), e.getErrorCode());
        } catch (Exception e) {
            return createErrorResponse('Unexpected error occurred', 'UNKNOWN_ERROR');
        }
    }
    
    private static ServiceResponse getMockResponse(ServiceRequest request) {
        // Mock implementation
        return MockDataFactory.generateResponse(SERVICE_NAME, request);
    }
    
    private static ServiceResponse getAPIResponse(ServiceRequest request) {
        // Real API implementation (future)
        throw new ServiceException('API integration not yet implemented', 'NOT_IMPLEMENTED');
    }
}
```

### Response Classes Structure

#### Base Classes
```apex
// ServiceRequest.cls
public class ServiceRequest {
    @AuraEnabled public String requestId;
    @AuraEnabled public Map<String, Object> parameters;
    @AuraEnabled public String userId;
    @AuraEnabled public DateTime timestamp;
}

// ServiceResponse.cls
public class ServiceResponse {
    @AuraEnabled public Boolean success;
    @AuraEnabled public String message;
    @AuraEnabled public Map<String, Object> data;
    @AuraEnabled public List<String> errors;
    @AuraEnabled public String responseId;
    @AuraEnabled public DateTime timestamp;
}
```

#### Specific Response Types
- CreditEvaluationResponse
- IncomeVerificationResponse
- IdentityVerificationResponse
- DecisionResponse
- DocumentProcessingResponse
- RiskAssessmentResponse
- LoanCalculationResponse
- ApplicationResponse
- NotificationResponse
- AnalyticsResponse

### Mock Data Strategy

#### MockDataFactory Class
```apex
public class MockDataFactory {
    // Scenario types for testing
    public enum Scenario {
        APPROVED_EXCELLENT_CREDIT,
        APPROVED_GOOD_CREDIT,
        APPROVED_WITH_CONDITIONS,
        DENIED_LOW_CREDIT,
        DENIED_HIGH_DTI,
        DENIED_INSUFFICIENT_INCOME,
        PENDING_DOCUMENT_REVIEW,
        ERROR_SCENARIO
    }
    
    public static ServiceResponse generateResponse(String serviceName, ServiceRequest request) {
        // Generate appropriate mock response based on service and scenario
    }
}
```

#### Mock Data Scenarios
1. **Happy Path** - Excellent credit (750+), low DTI, verified income
2. **Marginal Approval** - Good credit (680-749), moderate DTI
3. **Conditional Approval** - Requires additional documentation
4. **Denial - Credit** - Low credit score (<650)
5. **Denial - DTI** - High debt-to-income ratio (>45%)
6. **Denial - Income** - Insufficient or unverifiable income
7. **Pending Review** - Manual underwriting required
8. **System Error** - For error handling testing

### File Structure
```
force-app/main/default/classes/
├── services/
│   ├── CreditEvaluationService.cls
│   ├── CreditEvaluationService.cls-meta.xml
│   ├── IncomeVerificationService.cls
│   ├── IncomeVerificationService.cls-meta.xml
│   ├── IdentityVerificationService.cls
│   ├── IdentityVerificationService.cls-meta.xml
│   ├── DecisionEngineService.cls
│   ├── DecisionEngineService.cls-meta.xml
│   ├── DocumentProcessingService.cls
│   ├── DocumentProcessingService.cls-meta.xml
│   ├── RiskAssessmentService.cls
│   ├── RiskAssessmentService.cls-meta.xml
│   ├── LoanCalculatorService.cls
│   ├── LoanCalculatorService.cls-meta.xml
│   ├── ApplicationService.cls
│   ├── ApplicationService.cls-meta.xml
│   ├── NotificationService.cls
│   ├── NotificationService.cls-meta.xml
│   ├── AnalyticsService.cls
│   └── AnalyticsService.cls-meta.xml
├── models/
│   ├── ServiceRequest.cls
│   ├── ServiceRequest.cls-meta.xml
│   ├── ServiceResponse.cls
│   ├── ServiceResponse.cls-meta.xml
│   ├── CreditEvaluationResponse.cls
│   ├── IncomeVerificationResponse.cls
│   ├── IdentityVerificationResponse.cls
│   ├── DecisionResponse.cls
│   ├── DocumentProcessingResponse.cls
│   ├── RiskAssessmentResponse.cls
│   ├── LoanCalculationResponse.cls
│   ├── ApplicationResponse.cls
│   ├── NotificationResponse.cls
│   └── AnalyticsResponse.cls
├── utils/
│   ├── MockDataFactory.cls
│   ├── MockDataFactory.cls-meta.xml
│   ├── ServiceException.cls
│   ├── ServiceException.cls-meta.xml
│   ├── ServiceLogger.cls
│   └── ServiceLogger.cls-meta.xml
└── tests/
    ├── CreditEvaluationServiceTest.cls
    ├── IncomeVerificationServiceTest.cls
    ├── IdentityVerificationServiceTest.cls
    ├── DecisionEngineServiceTest.cls
    ├── DocumentProcessingServiceTest.cls
    ├── RiskAssessmentServiceTest.cls
    ├── LoanCalculatorServiceTest.cls
    ├── ApplicationServiceTest.cls
    ├── NotificationServiceTest.cls
    └── AnalyticsServiceTest.cls
```

## Testing Strategy

### Unit Tests
Each service will have comprehensive test coverage including:
- Positive test cases (happy path)
- Negative test cases (validation errors, exceptions)
- Edge cases (boundary values, null inputs)
- Mock data scenarios
- Error handling

### Integration Tests
- DecisionEngineService integration with all dependent services
- End-to-end application flow testing
- Performance testing with bulk operations

### Test Data
- Use existing TestDataCreationTest patterns
- Create service-specific test data factories
- Maintain test data isolation

## API Documentation Format

Each service method will be documented with:
```apex
/**
 * @description Brief description of what the method does
 * @param paramName Description of parameter
 * @return Description of return value
 * @throws ServiceException Description of when exceptions are thrown
 * @example
 * ServiceRequest request = new ServiceRequest();
 * request.parameters = new Map<String, Object>{'applicationId' => 'APP-001'};
 * ServiceResponse response = ServiceName.methodName(request);
 */
```

## Error Handling

### Standard Error Codes
- `VALIDATION_ERROR` - Input validation failed
- `NOT_FOUND` - Resource not found
- `UNAUTHORIZED` - Authentication/authorization failed
- `INTEGRATION_ERROR` - External service error
- `BUSINESS_RULE_VIOLATION` - Business rule validation failed
- `SYSTEM_ERROR` - Unexpected system error
- `NOT_IMPLEMENTED` - Feature not yet implemented

### Error Response Format
```json
{
    "success": false,
    "message": "Human-readable error message",
    "errors": ["Detailed error 1", "Detailed error 2"],
    "errorCode": "VALIDATION_ERROR",
    "timestamp": "2025-09-03T10:00:00Z"
}
```

## Implementation Priority

### Phase 1 (Immediate - Day 1)
1. ServiceRequest/ServiceResponse models
2. MockDataFactory
3. DecisionEngineService (orchestrator)
4. CreditEvaluationService
5. LoanCalculatorService

### Phase 2 (Day 2)
6. IncomeVerificationService
7. RiskAssessmentService
8. ApplicationService

### Phase 3 (Day 3)
9. IdentityVerificationService
10. DocumentProcessingService
11. NotificationService
12. AnalyticsService

## Configuration Management

### Custom Settings
Create `Lending_Service_Config__c` custom setting to manage:
- `Use_Mock_Data__c` (Boolean) - Toggle mock/real data
- `API_Timeout__c` (Number) - API timeout in milliseconds
- `Enable_Debug_Logging__c` (Boolean) - Detailed logging
- `Mock_Response_Delay__c` (Number) - Simulated API delay

### Custom Metadata
Create `Integration_Endpoint__mdt` for managing API endpoints:
- Service_Name__c
- Endpoint_URL__c
- Authentication_Type__c
- API_Key__c (encrypted)

## Security Considerations

1. **Field-Level Security**: Respect FLS in all queries
2. **Sharing Rules**: Use `with sharing` keyword
3. **Input Validation**: Sanitize all inputs
4. **Encryption**: SSN and sensitive data encryption
5. **Audit Trail**: Log all service calls
6. **Rate Limiting**: Implement throttling for external APIs

## Performance Optimization

1. **Caching**: Use `@AuraEnabled(cacheable=true)` where appropriate
2. **Bulk Operations**: Design for bulk processing
3. **Async Processing**: Use Queueable for long-running operations
4. **Query Optimization**: Selective queries with indexes
5. **Governor Limits**: Monitor and respect all limits

## Future Enhancements

1. **Machine Learning Integration**: Einstein Discovery for risk scoring
2. **Real-time Events**: Platform Events for status updates
3. **Batch Processing**: Scheduled batch jobs for portfolio analysis
4. **Webhook Support**: Inbound webhooks for status updates
5. **API Rate Limiting**: Custom rate limiting implementation

## Success Metrics

- All services return responses within 3 seconds (mock data)
- 100% test coverage maintained
- Zero production errors in first week
- Seamless transition from mock to real APIs
- All LWC components successfully integrated

## Notes for Developers

1. **Consistency**: Follow the established patterns exactly
2. **Documentation**: Document all methods thoroughly
3. **Testing**: Write tests before implementation (TDD)
4. **Logging**: Use ServiceLogger for all operations
5. **Error Handling**: Never expose internal errors to UI
6. **Mock Data**: Make mock data realistic and varied

---
*This plan serves as the authoritative guide for Week 3 Apex development. All developers should reference this document when implementing services.*