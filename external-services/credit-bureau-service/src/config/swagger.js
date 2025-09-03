const swaggerJsdoc = require('swagger-jsdoc');

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'Credit Bureau Service API',
      version: '1.0.0',
      description: 'Mock credit bureau service for lending POC',
      contact: {
        name: 'Lending POC Team',
        email: 'team@lending-poc.com'
      }
    },
    servers: [
      {
        url: `http://localhost:${process.env.PORT || 3001}`,
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
        CreditCheckRequest: {
          type: 'object',
          required: ['ssn', 'firstName', 'lastName', 'dateOfBirth'],
          properties: {
            ssn: {
              type: 'string',
              pattern: '^\\d{3}-\\d{2}-\\d{4}$',
              example: '123-45-6789'
            },
            firstName: {
              type: 'string',
              example: 'John'
            },
            lastName: {
              type: 'string',
              example: 'Doe'
            },
            dateOfBirth: {
              type: 'string',
              format: 'date',
              example: '1985-05-15'
            },
            address: {
              type: 'object',
              properties: {
                street: { type: 'string' },
                city: { type: 'string' },
                state: { type: 'string' },
                zipCode: { type: 'string' }
              }
            }
          }
        },
        CreditCheckResponse: {
          type: 'object',
          properties: {
            success: { type: 'boolean' },
            data: {
              type: 'object',
              properties: {
                creditScore: { type: 'number' },
                scoreRange: {
                  type: 'object',
                  properties: {
                    min: { type: 'number' },
                    max: { type: 'number' }
                  }
                },
                riskLevel: { type: 'string' },
                bureau: { type: 'string' },
                reportId: { type: 'string' },
                factors: { type: 'array' },
                creditAccounts: { type: 'number' },
                totalDebt: { type: 'number' },
                monthlyPayments: { type: 'number' },
                delinquencies: { type: 'number' },
                publicRecords: { type: 'number' },
                creditUtilization: { type: 'number' }
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