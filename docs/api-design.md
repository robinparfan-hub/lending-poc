# Consumer Lending Platform - API Design Specification

## 1. API Overview

The Consumer Lending Platform exposes a comprehensive set of RESTful APIs to enable integration with external systems, partners, and mobile applications. All APIs follow REST principles and return JSON responses.

### Base URLs
- **Production**: `https://api.lending-platform.com/v1`
- **Sandbox**: `https://sandbox-api.lending-platform.com/v1`
- **Development**: `https://dev-api.lending-platform.com/v1`

### API Versioning
- Version included in URL path (e.g., `/v1/`, `/v2/`)
- Backward compatibility maintained for 12 months
- Deprecation notices provided 6 months in advance

## 2. Authentication & Security

### 2.1 Authentication Methods

#### OAuth 2.0 (Primary)
```
Authorization Endpoint: /oauth/authorize
Token Endpoint: /oauth/token
Scopes: read:applications, write:applications, read:loans, write:payments
```

#### API Key (Legacy)
```
Header: X-API-Key: {api_key}
```

### 2.2 Security Headers
```http
X-Request-ID: {unique-request-id}
X-Client-ID: {client-application-id}
X-Correlation-ID: {correlation-id}
Content-Type: application/json
Accept: application/json
```

### 2.3 Rate Limiting
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
```

| Tier | Requests/Hour | Burst Limit |
|------|--------------|-------------|
| Basic | 1,000 | 50/minute |
| Standard | 10,000 | 200/minute |
| Premium | 100,000 | 1000/minute |

## 3. Core APIs

### 3.1 Application Management APIs

#### Create Loan Application
```http
POST /applications
```

**Request Body:**
```json
{
  "applicant": {
    "firstName": "John",
    "lastName": "Doe",
    "email": "john.doe@email.com",
    "phone": "+1234567890",
    "ssn": "123-45-6789",
    "dateOfBirth": "1980-01-15",
    "address": {
      "street": "123 Main St",
      "city": "San Francisco",
      "state": "CA",
      "zipCode": "94105"
    }
  },
  "loanDetails": {
    "purpose": "DEBT_CONSOLIDATION",
    "requestedAmount": 25000,
    "requestedTerm": 36
  },
  "employment": {
    "status": "EMPLOYED",
    "employerName": "Tech Corp",
    "annualIncome": 85000,
    "monthsAtJob": 24
  },
  "consent": {
    "creditCheck": true,
    "electronicCommunications": true,
    "privacyPolicy": true,
    "termsOfService": true
  }
}
```

**Response:**
```json
{
  "applicationId": "APP-2024001234",
  "status": "CREATED",
  "createdAt": "2024-01-15T10:30:00Z",
  "nextSteps": [
    {
      "action": "UPLOAD_DOCUMENTS",
      "required": true,
      "description": "Upload required verification documents"
    }
  ],
  "_links": {
    "self": "/applications/APP-2024001234",
    "documents": "/applications/APP-2024001234/documents",
    "status": "/applications/APP-2024001234/status"
  }
}
```

#### Get Application Status
```http
GET /applications/{applicationId}/status
```

**Response:**
```json
{
  "applicationId": "APP-2024001234",
  "currentStatus": "IN_REVIEW",
  "stage": "UNDERWRITING",
  "lastUpdated": "2024-01-15T14:30:00Z",
  "timeline": [
    {
      "stage": "APPLICATION_RECEIVED",
      "status": "COMPLETED",
      "timestamp": "2024-01-15T10:30:00Z"
    },
    {
      "stage": "IDENTITY_VERIFICATION",
      "status": "COMPLETED",
      "timestamp": "2024-01-15T11:00:00Z"
    },
    {
      "stage": "INCOME_VERIFICATION",
      "status": "COMPLETED",
      "timestamp": "2024-01-15T12:00:00Z"
    },
    {
      "stage": "UNDERWRITING",
      "status": "IN_PROGRESS",
      "timestamp": "2024-01-15T14:00:00Z"
    }
  ],
  "estimatedCompletion": "2024-01-15T16:00:00Z"
}
```

#### Update Application
```http
PATCH /applications/{applicationId}
```

**Request Body:**
```json
{
  "employment": {
    "annualIncome": 90000
  },
  "loanDetails": {
    "requestedAmount": 20000
  }
}
```

#### List Applications
```http
GET /applications?status=IN_REVIEW&limit=10&offset=0
```

**Response:**
```json
{
  "total": 45,
  "limit": 10,
  "offset": 0,
  "applications": [
    {
      "applicationId": "APP-2024001234",
      "applicantName": "John Doe",
      "requestedAmount": 25000,
      "status": "IN_REVIEW",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ],
  "_links": {
    "next": "/applications?status=IN_REVIEW&limit=10&offset=10",
    "prev": null
  }
}
```

### 3.2 Document Management APIs

#### Upload Document
```http
POST /applications/{applicationId}/documents
Content-Type: multipart/form-data
```

**Request:**
```
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="type"

DRIVERS_LICENSE
------WebKitFormBoundary7MA4YWxkTrZu0gW
Content-Disposition: form-data; name="file"; filename="license.pdf"
Content-Type: application/pdf

[Binary PDF Data]
------WebKitFormBoundary7MA4YWxkTrZu0gW--
```

**Response:**
```json
{
  "documentId": "DOC-789012",
  "type": "DRIVERS_LICENSE",
  "fileName": "license.pdf",
  "status": "PROCESSING",
  "uploadedAt": "2024-01-15T11:00:00Z",
  "processingResults": {
    "ocrStatus": "PENDING",
    "validationStatus": "PENDING"
  }
}
```

#### Get Document Status
```http
GET /documents/{documentId}
```

**Response:**
```json
{
  "documentId": "DOC-789012",
  "type": "DRIVERS_LICENSE",
  "status": "VERIFIED",
  "extractedData": {
    "name": "John Doe",
    "licenseNumber": "D1234567",
    "expirationDate": "2026-01-15",
    "state": "CA"
  },
  "verificationScore": 0.98
}
```

### 3.3 Verification APIs

#### Initiate Identity Verification
```http
POST /applications/{applicationId}/verifications/identity
```

**Request Body:**
```json
{
  "provider": "JUMIO",
  "documents": ["DOC-789012", "DOC-789013"],
  "consentGiven": true
}
```

**Response:**
```json
{
  "verificationId": "VER-456789",
  "status": "IN_PROGRESS",
  "provider": "JUMIO",
  "sessionUrl": "https://verification.jumio.com/session/abc123",
  "expiresAt": "2024-01-15T12:00:00Z"
}
```

#### Bank Account Verification (Plaid)
```http
POST /applications/{applicationId}/verifications/bank
```

**Request Body:**
```json
{
  "provider": "PLAID",
  "publicToken": "public-sandbox-xxx",
  "accountId": "account-xxx"
}
```

**Response:**
```json
{
  "verificationId": "VER-789012",
  "status": "COMPLETED",
  "accountDetails": {
    "institutionName": "Chase Bank",
    "accountType": "CHECKING",
    "lastFourDigits": "4567"
  },
  "incomeDetected": {
    "monthlyIncome": 7500,
    "incomeStreams": [
      {
        "name": "EMPLOYER DEPOSIT",
        "amount": 7000,
        "frequency": "MONTHLY"
      }
    ]
  }
}
```

### 3.4 Credit Check APIs

#### Initiate Credit Check
```http
POST /applications/{applicationId}/credit-check
```

**Request Body:**
```json
{
  "bureaus": ["EXPERIAN", "EQUIFAX", "TRANSUNION"],
  "type": "HARD_PULL",
  "purpose": "INDIVIDUAL_LOAN",
  "consentTimestamp": "2024-01-15T10:30:00Z"
}
```

**Response:**
```json
{
  "creditCheckId": "CC-234567",
  "status": "COMPLETED",
  "scores": {
    "EXPERIAN": {
      "score": 720,
      "model": "FICO_8"
    },
    "EQUIFAX": {
      "score": 715,
      "model": "FICO_8"
    },
    "TRANSUNION": {
      "score": 725,
      "model": "VANTAGE_3"
    }
  },
  "summary": {
    "totalDebt": 45000,
    "monthlyObligations": 1200,
    "delinquencies": 0,
    "creditUtilization": 0.35
  }
}
```

### 3.5 Decision APIs

#### Get Loan Decision
```http
GET /applications/{applicationId}/decision
```

**Response:**
```json
{
  "applicationId": "APP-2024001234",
  "decision": "APPROVED",
  "decidedAt": "2024-01-15T16:00:00Z",
  "offers": [
    {
      "offerId": "OFF-345678",
      "loanAmount": 25000,
      "term": 36,
      "interestRate": 7.99,
      "apr": 8.49,
      "monthlyPayment": 783.93,
      "originationFee": 500,
      "totalInterest": 3221.48,
      "totalPayment": 28221.48,
      "expiresAt": "2024-01-22T16:00:00Z"
    },
    {
      "offerId": "OFF-345679",
      "loanAmount": 25000,
      "term": 60,
      "interestRate": 8.99,
      "apr": 9.49,
      "monthlyPayment": 518.96,
      "originationFee": 500,
      "totalInterest": 6137.60,
      "totalPayment": 31137.60,
      "expiresAt": "2024-01-22T16:00:00Z"
    }
  ]
}
```

#### Accept Loan Offer
```http
POST /offers/{offerId}/accept
```

**Request Body:**
```json
{
  "disbursementAccount": {
    "accountNumber": "123456789",
    "routingNumber": "121000248",
    "accountType": "CHECKING",
    "accountHolderName": "John Doe"
  },
  "agreements": {
    "loanAgreement": true,
    "truthInLending": true,
    "eSignConsent": true,
    "timestamp": "2024-01-15T17:00:00Z"
  }
}
```

### 3.6 Loan Servicing APIs

#### Get Loan Details
```http
GET /loans/{loanId}
```

**Response:**
```json
{
  "loanId": "LN-567890",
  "accountNumber": "1234567890",
  "status": "CURRENT",
  "originalAmount": 25000,
  "currentBalance": 24216.07,
  "interestRate": 7.99,
  "monthlyPayment": 783.93,
  "nextPaymentDate": "2024-02-15",
  "nextPaymentAmount": 783.93,
  "paymentHistory": {
    "totalPayments": 1,
    "onTimePayments": 1,
    "latePayments": 0
  },
  "payoff": {
    "amount": 24216.07,
    "date": "2024-01-31",
    "perDiem": 5.47
  }
}
```

#### Make Payment
```http
POST /loans/{loanId}/payments
```

**Request Body:**
```json
{
  "amount": 783.93,
  "paymentDate": "2024-02-15",
  "paymentMethod": {
    "type": "ACH",
    "accountNumber": "123456789",
    "routingNumber": "121000248"
  }
}
```

**Response:**
```json
{
  "paymentId": "PMT-789012",
  "status": "SCHEDULED",
  "amount": 783.93,
  "scheduledDate": "2024-02-15",
  "confirmationNumber": "CNF-123456",
  "breakdown": {
    "principal": 650.00,
    "interest": 133.93,
    "fees": 0
  }
}
```

#### Get Payment History
```http
GET /loans/{loanId}/payments?limit=10
```

**Response:**
```json
{
  "total": 1,
  "payments": [
    {
      "paymentId": "PMT-789011",
      "date": "2024-01-15",
      "amount": 783.93,
      "status": "COMPLETED",
      "principal": 650.00,
      "interest": 133.93
    }
  ]
}
```

### 3.7 Webhook APIs

#### Webhook Events
```http
POST {client_webhook_url}
```

**Event Types:**
- `application.created`
- `application.updated`
- `application.approved`
- `application.declined`
- `document.uploaded`
- `verification.completed`
- `loan.funded`
- `payment.received`
- `payment.failed`

**Webhook Payload:**
```json
{
  "eventId": "evt_1234567890",
  "eventType": "application.approved",
  "timestamp": "2024-01-15T16:00:00Z",
  "data": {
    "applicationId": "APP-2024001234",
    "decision": "APPROVED",
    "offers": [...]
  },
  "signature": "sha256=xxxxx"
}
```

## 4. External Service Integrations

### 4.1 Credit Bureau APIs

#### Experian Connect
```yaml
Endpoint: https://api.experian.com/consumerservices/credit-profile/v2
Authentication: OAuth 2.0
Operations:
  - Credit Report Pull
  - FICO Score Retrieval
  - Fraud Shield Check
  - Income Estimator
```

#### Equifax API
```yaml
Endpoint: https://api.equifax.com/business/consumer-credit/v1
Authentication: API Key + Secret
Operations:
  - Credit Report
  - Risk Score
  - Verification Services
  - Bankruptcy Check
```

### 4.2 Banking Data Aggregation

#### Plaid Integration
```yaml
Endpoints:
  Auth: https://api.plaid.com/auth/get
  Accounts: https://api.plaid.com/accounts/get
  Transactions: https://api.plaid.com/transactions/get
  Income: https://api.plaid.com/income/verification/get
  Assets: https://api.plaid.com/assets/get

Webhooks:
  - INITIAL_UPDATE
  - HISTORICAL_UPDATE
  - TRANSACTIONS_REMOVED
  - ERROR
```

### 4.3 Identity Verification

#### Jumio Integration
```yaml
Endpoints:
  Initiate: https://api.jumio.com/api/v1/accounts
  Results: https://api.jumio.com/api/v1/accounts/{scanReference}
  
Workflow:
  1. Create verification session
  2. Redirect user to Jumio
  3. Receive callback webhook
  4. Retrieve verification results
```

### 4.4 Document Processing

#### OCR Service (Textract/Document AI)
```yaml
Operations:
  - Document Analysis
  - Table Extraction
  - Form Processing
  - Key-Value Extraction

Supported Documents:
  - Driver's License
  - Paystubs
  - Bank Statements
  - Tax Documents
  - Utility Bills
```

### 4.5 Payment Processing

#### ACH Processing
```yaml
Provider: Dwolla/Stripe
Operations:
  - Account Verification
  - Payment Initiation
  - Payment Status
  - Return Handling
  
Settlement: T+2 business days
```

## 5. Error Handling

### 5.1 Error Response Format
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request parameters",
    "details": [
      {
        "field": "applicant.ssn",
        "issue": "Invalid format",
        "location": "body"
      }
    ],
    "requestId": "req_1234567890",
    "timestamp": "2024-01-15T10:30:00Z"
  }
}
```

### 5.2 Error Codes

| Code | HTTP Status | Description |
|------|------------|-------------|
| VALIDATION_ERROR | 400 | Invalid request parameters |
| AUTHENTICATION_FAILED | 401 | Invalid credentials |
| INSUFFICIENT_PERMISSIONS | 403 | Lacks required permissions |
| RESOURCE_NOT_FOUND | 404 | Resource does not exist |
| DUPLICATE_REQUEST | 409 | Duplicate submission |
| RATE_LIMIT_EXCEEDED | 429 | Too many requests |
| INTERNAL_ERROR | 500 | Server error |
| SERVICE_UNAVAILABLE | 503 | Temporary unavailable |

## 6. API Testing

### 6.1 Test Environment
```yaml
Base URL: https://sandbox-api.lending-platform.com/v1
Test Credentials:
  Client ID: test_client_id
  Client Secret: test_client_secret
  
Test Data:
  SSNs that trigger specific responses:
    - 111-11-1111: Auto-approve
    - 222-22-2222: Auto-decline
    - 333-33-3333: Manual review
    - 444-44-4444: Verification failure
```

### 6.2 Postman Collection
```json
{
  "info": {
    "name": "Lending Platform API",
    "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json"
  },
  "item": [
    {
      "name": "Create Application",
      "request": {
        "method": "POST",
        "url": "{{baseUrl}}/applications",
        "body": {...}
      }
    }
  ]
}
```

## 7. SDK Support

### 7.1 Available SDKs
- **JavaScript/TypeScript**: `npm install @lending-platform/sdk`
- **Python**: `pip install lending-platform-sdk`
- **Java**: Maven dependency available
- **Ruby**: `gem install lending_platform`
- **.NET**: NuGet package available

### 7.2 SDK Example (JavaScript)
```javascript
const LendingPlatform = require('@lending-platform/sdk');

const client = new LendingPlatform({
  apiKey: 'your_api_key',
  environment: 'sandbox'
});

// Create application
const application = await client.applications.create({
  applicant: {
    firstName: 'John',
    lastName: 'Doe',
    email: 'john@example.com'
  },
  loanDetails: {
    requestedAmount: 25000,
    requestedTerm: 36
  }
});

// Check status
const status = await client.applications.getStatus(application.id);
```

## 8. API Governance

### 8.1 Versioning Policy
- Major versions for breaking changes
- Minor versions for new features
- Patch versions for bug fixes
- 12-month support for deprecated versions

### 8.2 Change Management
- Changes announced 30 days in advance
- Breaking changes require major version
- Deprecation notices in headers
- Migration guides provided

### 8.3 SLA Commitments
| Metric | Target |
|--------|--------|
| Availability | 99.9% |
| Response Time (p50) | <200ms |
| Response Time (p99) | <1000ms |
| Error Rate | <0.1% |

## 9. Monitoring & Analytics

### 9.1 API Metrics
- Request volume by endpoint
- Response time distribution
- Error rate by type
- Client usage patterns
- Geographic distribution

### 9.2 Health Check Endpoint
```http
GET /health
```

**Response:**
```json
{
  "status": "healthy",
  "version": "1.2.3",
  "timestamp": "2024-01-15T10:30:00Z",
  "dependencies": {
    "database": "healthy",
    "redis": "healthy",
    "plaid": "healthy",
    "experian": "healthy"
  }
}
```

## 10. Compliance & Security

### 10.1 Data Privacy
- PII encryption in transit and at rest
- Data retention per regulatory requirements
- Right to deletion (GDPR/CCPA)
- Audit logging for all access

### 10.2 Regulatory Compliance
- FCRA compliant credit checks
- ECOA fair lending compliance
- TILA disclosure requirements
- State lending law compliance

### 10.3 Security Best Practices
- TLS 1.3 minimum
- Certificate pinning for mobile
- OWASP Top 10 protection
- Regular penetration testing
- SOC 2 Type II certified