# API Contracts for External Services

## Base Configuration

### Base URLs
- **Local Development**: `http://localhost:{port}/api/v1`
- **AWS Production**: `https://api.lending-poc.aws.com/api/v1`
- **Azure Production**: `https://lending-poc-api.azurewebsites.net/api/v1`

### Common Headers
```http
Content-Type: application/json
Accept: application/json
X-API-Key: {api-key}  # Required in production
X-Request-ID: {uuid}  # Optional, for tracing
```

### Common Response Structure
```json
{
  "success": true|false,
  "data": { ... },
  "message": "Human readable message",
  "errors": ["error1", "error2"],
  "metadata": {
    "requestId": "uuid",
    "timestamp": "2025-09-03T10:00:00Z",
    "processingTime": 150
  }
}
```

## 1. Credit Bureau Service (Port 3001)

### POST /api/v1/credit-check
Perform a credit check for an applicant.

**Request:**
```json
{
  "ssn": "123-45-6789",
  "firstName": "John",
  "lastName": "Doe",
  "dateOfBirth": "1985-05-15",
  "address": {
    "street": "123 Main St",
    "city": "San Francisco",
    "state": "CA",
    "zipCode": "94105"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "creditScore": 750,
    "scoreRange": {
      "min": 300,
      "max": 850
    },
    "riskLevel": "low",
    "bureau": "Equifax",
    "reportId": "CR-2025-09-03-001",
    "factors": [
      {
        "code": "01",
        "description": "Length of credit history"
      },
      {
        "code": "08",
        "description": "Too many inquiries"
      }
    ],
    "creditAccounts": 12,
    "totalDebt": 45000,
    "monthlyPayments": 1200,
    "delinquencies": 0,
    "publicRecords": 0,
    "creditUtilization": 28
  }
}
```

### GET /api/v1/credit-report/{reportId}
Retrieve a full credit report.

**Response:**
```json
{
  "success": true,
  "data": {
    "reportId": "CR-2025-09-03-001",
    "generatedDate": "2025-09-03T10:00:00Z",
    "personalInfo": { ... },
    "creditSummary": { ... },
    "creditAccounts": [ ... ],
    "inquiries": [ ... ],
    "publicRecords": [ ... ]
  }
}
```

### POST /api/v1/credit-score
Get just the credit score (lighter weight than full check).

**Request:**
```json
{
  "ssn": "123-45-6789"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "score": 750,
    "bureau": "Experian",
    "asOfDate": "2025-09-03"
  }
}
```

## 2. Income Verification Service (Port 3002)

### POST /api/v1/verify-income
Verify income from multiple sources.

**Request:**
```json
{
  "applicantId": "APP-123",
  "employmentInfo": {
    "employerName": "Tech Company Inc",
    "position": "Software Engineer",
    "startDate": "2020-01-15",
    "statedIncome": 120000
  },
  "bankAccounts": [
    {
      "accountNumber": "****1234",
      "bankName": "Chase",
      "accountType": "checking"
    }
  ],
  "consentToken": "PLAID-CONSENT-TOKEN"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "verificationId": "INC-VER-2025-001",
    "verificationStatus": "verified",
    "verifiedIncome": {
      "annual": 118500,
      "monthly": 9875,
      "sources": [
        {
          "type": "employment",
          "amount": 110000,
          "verified": true,
          "source": "The Work Number"
        },
        {
          "type": "other",
          "amount": 8500,
          "verified": true,
          "source": "1099 Income"
        }
      ]
    },
    "employmentVerified": true,
    "confidenceScore": 95,
    "discrepancyNotes": "Stated income within 2% of verified"
  }
}
```

### POST /api/v1/employment-check
Verify employment status.

**Request:**
```json
{
  "employerName": "Tech Company Inc",
  "employeeName": "John Doe",
  "employeeSSN": "***-**-6789"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "employed": true,
    "employmentStatus": "full-time",
    "startDate": "2020-01-15",
    "position": "Software Engineer",
    "verificationSource": "employer-direct",
    "verificationDate": "2025-09-03"
  }
}
```

### POST /api/v1/calculate-dti
Calculate debt-to-income ratio.

**Request:**
```json
{
  "monthlyIncome": 9875,
  "monthlyDebts": {
    "mortgage": 2000,
    "autoLoan": 450,
    "creditCards": 300,
    "studentLoans": 250,
    "otherDebts": 100
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "dtiRatio": 31.39,
    "totalMonthlyDebt": 3100,
    "totalMonthlyIncome": 9875,
    "classification": "good",
    "maxLoanPayment": 2856
  }
}
```

## 3. Identity Verification Service (Port 3003)

### POST /api/v1/verify-identity
Perform identity verification and KYC check.

**Request:**
```json
{
  "firstName": "John",
  "lastName": "Doe",
  "ssn": "123-45-6789",
  "dateOfBirth": "1985-05-15",
  "phone": "+1-415-555-0123",
  "email": "john.doe@email.com",
  "address": {
    "street": "123 Main St",
    "city": "San Francisco",
    "state": "CA",
    "zipCode": "94105"
  },
  "documents": {
    "driversLicense": "CA-DL-123456",
    "passport": "US-PASS-789012"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "verificationId": "IDV-2025-001",
    "status": "verified",
    "confidenceScore": 98,
    "riskScore": 15,
    "kycStatus": "passed",
    "amlStatus": "clear",
    "checks": {
      "ssnValid": true,
      "addressValid": true,
      "phoneValid": true,
      "emailValid": true,
      "documentValid": true,
      "watchlistClear": true,
      "pepCheck": false,
      "sanctionsCheck": false
    },
    "riskFactors": [],
    "requiresManualReview": false
  }
}
```

### POST /api/v1/fraud-detection
Check for potential fraud indicators.

**Request:**
```json
{
  "applicationId": "APP-123",
  "ipAddress": "192.168.1.1",
  "deviceFingerprint": "device-hash-123",
  "applicantData": { ... }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "fraudScore": 20,
    "fraudRisk": "low",
    "indicators": [
      {
        "type": "velocity",
        "description": "Multiple applications from same device",
        "severity": "low"
      }
    ],
    "recommendedAction": "proceed",
    "requiresReview": false
  }
}
```

## 4. Document Processing Service (Port 3004)

### POST /api/v1/upload-document
Upload a document for processing.

**Request:**
```json
{
  "documentType": "bank_statement",
  "fileName": "chase_statement_aug_2025.pdf",
  "fileSize": 245678,
  "mimeType": "application/pdf",
  "content": "base64_encoded_content",
  "metadata": {
    "applicationId": "APP-123",
    "uploadedBy": "john.doe@email.com"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "documentId": "DOC-2025-001",
    "status": "processing",
    "uploadedAt": "2025-09-03T10:00:00Z",
    "estimatedProcessingTime": 30,
    "validationStatus": "pending"
  }
}
```

### POST /api/v1/extract-text
Extract text/data from document.

**Request:**
```json
{
  "documentId": "DOC-2025-001",
  "extractionType": "structured"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "documentId": "DOC-2025-001",
    "extractedData": {
      "accountNumber": "****1234",
      "statementPeriod": {
        "start": "2025-08-01",
        "end": "2025-08-31"
      },
      "transactions": [ ... ],
      "balance": {
        "opening": 10000,
        "closing": 12000
      },
      "deposits": 15000,
      "withdrawals": 13000
    },
    "confidence": 95,
    "extractionMethod": "OCR"
  }
}
```

### GET /api/v1/document-status/{documentId}
Check document processing status.

**Response:**
```json
{
  "success": true,
  "data": {
    "documentId": "DOC-2025-001",
    "status": "completed",
    "processingSteps": [
      {
        "step": "upload",
        "status": "completed",
        "timestamp": "2025-09-03T10:00:00Z"
      },
      {
        "step": "validation",
        "status": "completed",
        "timestamp": "2025-09-03T10:00:10Z"
      },
      {
        "step": "extraction",
        "status": "completed",
        "timestamp": "2025-09-03T10:00:20Z"
      }
    ],
    "results": {
      "valid": true,
      "extracted": true,
      "errors": []
    }
  }
}
```

## 5. Notification Service (Port 3005)

### POST /api/v1/send-email
Send an email notification.

**Request:**
```json
{
  "to": ["john.doe@email.com"],
  "cc": [],
  "bcc": [],
  "subject": "Loan Application Update",
  "templateId": "loan-status-update",
  "templateData": {
    "firstName": "John",
    "applicationId": "APP-123",
    "status": "approved",
    "amount": 50000
  },
  "attachments": []
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "messageId": "MSG-EMAIL-2025-001",
    "status": "sent",
    "sentAt": "2025-09-03T10:00:00Z",
    "provider": "SendGrid"
  }
}
```

### POST /api/v1/send-sms
Send an SMS notification.

**Request:**
```json
{
  "to": "+1-415-555-0123",
  "message": "Your loan application APP-123 has been approved!",
  "scheduledFor": null
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "messageId": "MSG-SMS-2025-001",
    "status": "delivered",
    "sentAt": "2025-09-03T10:00:00Z",
    "provider": "Twilio",
    "cost": 0.01
  }
}
```

## Error Responses

All services use standard HTTP status codes and error format:

### 400 Bad Request
```json
{
  "success": false,
  "message": "Validation failed",
  "errors": [
    "SSN is required",
    "Invalid email format"
  ],
  "errorCode": "VALIDATION_ERROR"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Invalid API key",
  "errorCode": "UNAUTHORIZED"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Resource not found",
  "errorCode": "NOT_FOUND"
}
```

### 429 Too Many Requests
```json
{
  "success": false,
  "message": "Rate limit exceeded",
  "errorCode": "RATE_LIMIT_EXCEEDED",
  "retryAfter": 60
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Internal server error",
  "errorCode": "INTERNAL_ERROR",
  "requestId": "req-123-456"
}
```

## Mock Data Scenarios

### Credit Score Scenarios (Based on SSN last 4 digits)
- `0000-2499`: Excellent (750-850) - Auto-approve
- `2500-4999`: Good (650-749) - Approve with conditions
- `5000-7499`: Fair (550-649) - Manual review
- `7500-9999`: Poor (300-549) - Auto-decline

### Income Verification Scenarios (Based on employer name)
- Contains `"Tech"`: High income, verified
- Contains `"Bank"`: Medium-high income, verified
- Contains `"Retail"`: Medium income, verified
- Contains `"Test"`: Unverifiable income
- Others: Random verification status

### Identity Verification Scenarios (Based on name)
- First name `"Test"`: Fails verification
- Last name `"Fraud"`: Triggers fraud alert
- Name `"John Doe"`: Passes all checks
- Others: Random verification results

## Rate Limits

Default rate limits per API key:

| Service | Requests/Minute | Requests/Hour |
|---------|-----------------|---------------|
| Credit Bureau | 10 | 100 |
| Income Verification | 20 | 200 |
| Identity Verification | 20 | 200 |
| Document Processing | 50 | 500 |
| Notification | 100 | 1000 |

## Webhooks

Services can send webhook notifications for async operations:

### Webhook Registration
```json
POST /api/v1/webhook/register
{
  "url": "https://your-salesforce-instance.com/webhook/receiver",
  "events": ["document.processed", "verification.complete"],
  "secret": "webhook-secret-key"
}
```

### Webhook Payload Format
```json
{
  "event": "document.processed",
  "timestamp": "2025-09-03T10:00:00Z",
  "data": { ... },
  "signature": "hmac-sha256-signature"
}
```

## Testing

### Test API Keys
- Development: `test_key_development_2025`
- Staging: `test_key_staging_2025`
- Production: Contact admin for production keys

### Postman Collection
Import the Postman collection from `/external-services/postman/lending-poc-apis.json`

### cURL Examples

```bash
# Credit check
curl -X POST http://localhost:3001/api/v1/credit-check \
  -H "Content-Type: application/json" \
  -H "X-API-Key: test_key_development_2025" \
  -d '{
    "ssn": "123-45-6789",
    "firstName": "John",
    "lastName": "Doe",
    "dateOfBirth": "1985-05-15"
  }'

# Income verification
curl -X POST http://localhost:3002/api/v1/verify-income \
  -H "Content-Type: application/json" \
  -H "X-API-Key: test_key_development_2025" \
  -d '{
    "applicantId": "APP-123",
    "employmentInfo": {
      "employerName": "Tech Company Inc",
      "position": "Software Engineer",
      "statedIncome": 120000
    }
  }'
```

## Support

For API support or questions:
1. Check this documentation
2. Review service-specific README files
3. Check health endpoints: `GET /health`
4. Review logs in Docker: `docker-compose logs [service-name]`

---
*Last Updated: September 3, 2025*
*Version: 1.0.0*