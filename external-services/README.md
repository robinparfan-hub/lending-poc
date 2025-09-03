# External Microservices for Lending POC

## Overview
This directory contains five independent Node.js/Express microservices that provide external data and processing capabilities for the Salesforce Lending POC application. Each service is designed to be containerizable, scalable, and easily replaceable with production APIs or ML/AI models.

## Architecture

### Service Ports & Status
| Service | Port | Description | Status |
|---------|------|-------------|--------|
| Credit Bureau Service | 3001 | Credit scoring and reports | ✅ Complete |
| Income Verification Service | 3002 | Income and employment verification | ✅ Complete |
| Identity Verification Service | 3003 | KYC and fraud detection | ✅ Complete |
| Document Processing Service | 3004 | Document upload, OCR and validation | ✅ Complete |
| Notification Service | 3005 | Email, SMS and push notifications | ✅ Complete |

### Technology Stack
- **Runtime**: Node.js 18+
- **Framework**: Express.js
- **Documentation**: Swagger/OpenAPI
- **Security**: API Key authentication, Rate limiting, Helmet.js
- **Logging**: Winston
- **Validation**: express-validator
- **Containerization**: Docker (optional)
- **Deployment**: AWS ECS/Lambda or Azure Container Instances/Functions

## Quick Start

### Prerequisites
- Node.js 18+ installed
- npm or yarn package manager
- Docker (optional, for containerized deployment)

### Installation & Running

#### Start All Services (Without Docker)
```bash
# Install dependencies for all services
for service in credit-bureau-service income-verification-service identity-verification-service document-processing-service notification-service; do
  cd $service && npm install && cd ..
done

# Start all services (each in a separate terminal)
cd credit-bureau-service && npm start
cd income-verification-service && npm start  
cd identity-verification-service && npm start
cd document-processing-service && npm start
cd notification-service && npm start
```

#### Check Service Status
```bash
# Check all services are running
curl http://localhost:3001/health
curl http://localhost:3002/health
curl http://localhost:3003/health
curl http://localhost:3004/health
curl http://localhost:3005/health
```

### API Documentation
Each service provides interactive Swagger documentation:
- Credit Bureau: http://localhost:3001/api-docs
- Income Verification: http://localhost:3002/api-docs
- Identity Verification: http://localhost:3003/api-docs
- Document Processing: http://localhost:3004/api-docs
- Notification: http://localhost:3005/api-docs

## API Contracts

See [API_CONTRACTS.md](./API_CONTRACTS.md) for detailed API documentation including:
- Endpoint specifications
- Request/response formats
- Mock data scenarios
- Error codes

## Services Detail

### 1. Credit Bureau Service (Port 3001)
Provides credit scoring and credit report functionality.

**Key Endpoints:**
- `POST /api/v1/credit-check` - Get credit score and report
- `POST /api/v1/credit-report` - Get detailed credit report
- `GET /api/v1/credit-history/{ssn}` - Get credit history

**Mock Data Patterns:**
- SSN ending 0000-2499: Excellent credit (750-850)
- SSN ending 2500-4999: Good credit (650-749)
- SSN ending 5000-7499: Fair credit (550-649)
- SSN ending 7500-9999: Poor credit (350-549)

### 2. Income Verification Service (Port 3002)
Verifies employment and income information.

**Key Endpoints:**
- `POST /api/v1/verify-income` - Verify income and employment
- `POST /api/v1/verify-employment` - Verify employment only
- `POST /api/v1/calculate-dti` - Calculate debt-to-income ratio

**Mock Data Patterns:**
- Employer containing "tech": High income ($100k-$150k)
- Employer containing "retail": Medium income ($30k-$50k)
- Employer containing "startup": Variable income ($40k-$80k)
- Employer containing "test": Verification fails

### 3. Identity Verification Service (Port 3003)
Performs KYC checks and identity verification.

**Key Endpoints:**
- `POST /api/v1/verify-identity` - Verify identity (KYC)
- `POST /api/v1/fraud-check` - Check for fraud indicators
- `POST /api/v1/watchlist-check` - Check against watchlists

**Mock Data Patterns:**
- FirstName "Test": Verification fails
- LastName "Fraud": Triggers fraud alert
- Name "John Doe": Passes verification
- SSN ending "0000": Triggers watchlist hit

### 4. Document Processing Service (Port 3004)
Handles document upload, OCR, and validation.

**Key Endpoints:**
- `POST /api/v1/upload-document` - Upload document
- `POST /api/v1/extract-text` - Extract text/data from document
- `GET /api/v1/document-status/{id}` - Check processing status
- `POST /api/v1/validate-document` - Validate document authenticity

**Mock Data Patterns:**
- Filename containing "fake": Validation fails
- Filename containing "expired": Document expired
- Filename containing "suspicious": Quality warning
- Default: Valid document

### 5. Notification Service (Port 3005)
Sends email, SMS, and push notifications.

**Key Endpoints:**
- `POST /api/v1/send-email` - Send email
- `POST /api/v1/send-sms` - Send SMS
- `POST /api/v1/send-push` - Send push notification
- `POST /api/v1/send-batch` - Send batch notifications
- `GET /api/v1/templates` - Get notification templates

**Mock Data Patterns:**
- Email containing "fail": Delivery fails
- Email containing "delay": Delayed delivery
- Phone ending "0000": SMS fails
- UserID containing "inactive": Push fails

## Development

### Project Structure
```
service-name/
├── src/
│   ├── index.js           # Express server setup
│   ├── routes/            # API route definitions
│   ├── controllers/       # Request handlers
│   ├── services/         # Business logic & mock data
│   ├── middleware/       # Auth, rate limiting, etc.
│   ├── utils/           # Utilities (logger, etc.)
│   └── config/          # Configuration (swagger, etc.)
├── tests/               # Test files
├── package.json
├── .env                # Environment variables
└── .gitignore
```

### Adding ML/AI Capabilities
The architecture is designed for easy ML/AI integration:

1. **Replace Mock Services**: Swap `mockDataService.js` with ML service
2. **Async Ready**: All functions use async/await for API calls
3. **Environment Toggle**: Use `MOCK_MODE` to switch implementations
4. **Error Handling**: Built-in error handling for model failures

Example integration points:
- **Credit Bureau**: ML credit scoring models, fraud detection algorithms, RAG for regulatory compliance
- **Identity Verification**: Facial recognition, document authenticity ML, NLP for name matching
- **Document Processing**: Advanced OCR models, NLP for data extraction, RAG for template matching
- **Income Verification**: Income prediction models, employment stability scoring
- **Notification**: GenAI for message personalization, ML for send-time optimization

### Testing

#### Unit Tests
```bash
cd [service-name]
npm test
```

#### Integration Testing Example
```bash
# Test credit check
curl -X POST http://localhost:3001/api/v1/credit-check \
  -H "Content-Type: application/json" \
  -H "X-API-Key: test_key_development_2025" \
  -d '{
    "ssn": "123-45-6789",
    "firstName": "John",
    "lastName": "Doe",
    "dateOfBirth": "1985-05-15"
  }'
```

## Docker Support

### Build Images
```bash
docker build -t lending-poc/credit-bureau ./credit-bureau-service
docker build -t lending-poc/income-verification ./income-verification-service
docker build -t lending-poc/identity-verification ./identity-verification-service
docker build -t lending-poc/document-processing ./document-processing-service
docker build -t lending-poc/notification ./notification-service
```

### Run with Docker Compose
```bash
docker-compose up
```

## Production Deployment

### AWS Deployment
1. Build Docker images
2. Push to ECR
3. Deploy with ECS/Fargate or EKS
4. Configure API Gateway
5. Set production environment variables

### Azure Deployment
1. Build Docker images
2. Push to ACR
3. Deploy with Azure Container Instances or AKS
4. Configure API Management
5. Set production environment variables

## Configuration

### Environment Variables
Each service uses a `.env` file with these common settings:
```env
NODE_ENV=development
PORT=300X
SERVICE_NAME=service-name
MOCK_MODE=true
LOG_LEVEL=info
API_KEY=test_key_development_2025
RATE_LIMIT=100
CORS_ORIGIN=*
```

### Authentication
All API endpoints (except health checks) require an API key header:
```
X-API-Key: test_key_development_2025
```

## Monitoring & Logging
- All services use Winston for structured logging
- Logs include request IDs for tracing
- Health endpoints for monitoring: `/health`
- Metrics can be added via Prometheus/Grafana

## Security Considerations
- API key authentication (replace with OAuth2 in production)
- Rate limiting on all endpoints
- Helmet.js for security headers
- Input validation on all requests
- CORS configuration
- No sensitive data in logs

## Future Enhancements
- [ ] Add Redis for caching
- [ ] Implement circuit breakers
- [ ] Add message queue integration (RabbitMQ/SQS)
- [ ] Enhance monitoring/metrics
- [ ] Add OpenTelemetry tracing
- [ ] Implement webhook callbacks
- [ ] Add GraphQL endpoints
- [ ] Integrate real ML/AI models
- [ ] Add database persistence
- [ ] Implement OAuth2/JWT authentication

## Support
For issues or questions about these services, please refer to the main Lending POC documentation or contact the development team.