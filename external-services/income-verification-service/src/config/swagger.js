const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Income Verification Service API',
      version: '1.0.0',
      description: 'Mock income and employment verification service for lending POC',
      contact: {
        name: 'Lending POC Team',
        email: 'team@lending-poc.com'
      }
    },
    servers: [
      {
        url: `http://localhost:${process.env.PORT || 3002}`,
        description: 'Development server'
      },
      {
        url: 'https://api.lending-poc.aws.com',
        description: 'Production server (AWS)'
      },
      {
        url: 'https://lending-poc-api.azurewebsites.net',
        description: 'Production server (Azure)'
      }
    ],
    components: {
      securitySchemes: {
        ApiKeyAuth: {
          type: 'apiKey',
          in: 'header',
          name: 'X-API-Key'
        }
      },
      schemas: {
        IncomeVerificationRequest: {
          type: 'object',
          required: ['applicantId', 'employmentInfo'],
          properties: {
            applicantId: {
              type: 'string',
              example: 'APP-123'
            },
            employmentInfo: {
              type: 'object',
              required: ['employerName', 'position', 'statedIncome'],
              properties: {
                employerName: {
                  type: 'string',
                  example: 'Tech Company Inc'
                },
                position: {
                  type: 'string',
                  example: 'Software Engineer'
                },
                startDate: {
                  type: 'string',
                  format: 'date',
                  example: '2020-01-15'
                },
                statedIncome: {
                  type: 'number',
                  example: 120000
                }
              }
            },
            bankAccounts: {
              type: 'array',
              items: {
                type: 'object',
                properties: {
                  accountNumber: {
                    type: 'string',
                    example: '****1234'
                  },
                  bankName: {
                    type: 'string',
                    example: 'Chase'
                  },
                  accountType: {
                    type: 'string',
                    enum: ['checking', 'savings'],
                    example: 'checking'
                  }
                }
              }
            },
            consentToken: {
              type: 'string',
              example: 'PLAID-CONSENT-TOKEN'
            }
          }
        },
        EmploymentCheckRequest: {
          type: 'object',
          required: ['employerName', 'employeeName'],
          properties: {
            employerName: {
              type: 'string',
              example: 'Tech Company Inc'
            },
            employeeName: {
              type: 'string',
              example: 'John Doe'
            },
            employeeSSN: {
              type: 'string',
              pattern: '^\\*{3}-\\*{2}-\\d{4}$',
              example: '***-**-6789'
            }
          }
        },
        DTICalculationRequest: {
          type: 'object',
          required: ['monthlyIncome', 'monthlyDebts'],
          properties: {
            monthlyIncome: {
              type: 'number',
              example: 9875
            },
            monthlyDebts: {
              type: 'object',
              properties: {
                mortgage: { type: 'number', example: 2000 },
                autoLoan: { type: 'number', example: 450 },
                creditCards: { type: 'number', example: 300 },
                studentLoans: { type: 'number', example: 250 },
                otherDebts: { type: 'number', example: 100 }
              }
            }
          }
        },
        IncomeVerificationResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean' },
            data: {
              type: 'object',
              properties: {
                verificationId: { type: 'string' },
                verificationStatus: { type: 'string' },
                verifiedIncome: {
                  type: 'object',
                  properties: {
                    annual: { type: 'number' },
                    monthly: { type: 'number' },
                    sources: { type: 'array' }
                  }
                },
                employmentVerified: { type: 'boolean' },
                confidenceScore: { type: 'number' },
                discrepancyNotes: { type: 'string' }
              }
            }
          }
        },
        ErrorResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean', example: false },
            message: { type: 'string' },
            errors: { type: 'array', items: { type: 'string' } },
            errorCode: { type: 'string' }
          }
        }
      }
    },
    security: [{
      ApiKeyAuth: []
    }]
  },
  apis: ['./src/routes/*.js']
};

module.exports = swaggerJsdoc(options);