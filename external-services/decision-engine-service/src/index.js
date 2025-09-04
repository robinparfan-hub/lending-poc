require('dotenv').config();
const express = require('express');
const cors = require('cors');

// Create Express app
const app = express();
const PORT = process.env.PORT || 3006;

// Middleware
app.use(cors());
app.use(express.json());

// Mock data scenarios matching Apex MockDataFactory exactly
const SCENARIOS = {
  APPROVED_EXCELLENT_CREDIT: {
    creditScore: 780,
    creditGrade: 'A',
    riskLevel: 'LOW',
    decision: 'APPROVED',
    approvedAmount: 50000,
    interestRate: 5.99,
    term: 60,
    monthlyPayment: 966.64,
    reasonCodes: ['EXCELLENT_CREDIT', 'LOW_RISK'],
    conditions: [],
    denialReasons: []
  },
  APPROVED_GOOD_CREDIT: {
    creditScore: 720,
    creditGrade: 'B', 
    riskLevel: 'MEDIUM',
    decision: 'APPROVED',
    approvedAmount: 35000,
    interestRate: 8.99,
    term: 60,
    monthlyPayment: 730.17,
    reasonCodes: ['GOOD_CREDIT', 'ACCEPTABLE_RISK'],
    conditions: [],
    denialReasons: []
  },
  APPROVED_WITH_CONDITIONS: {
    creditScore: 680,
    creditGrade: 'C',
    riskLevel: 'MEDIUM',
    decision: 'APPROVED_WITH_CONDITIONS',
    approvedAmount: 25000,
    interestRate: 12.99,
    term: 48,
    monthlyPayment: 667.67,
    reasonCodes: ['FAIR_CREDIT', 'CONDITIONAL_APPROVAL'],
    conditions: ['Proof of income required', 'Verification of employment'],
    denialReasons: []
  },
  DENIED_LOW_CREDIT: {
    creditScore: 580,
    creditGrade: 'E',
    riskLevel: 'HIGH',
    decision: 'DENIED',
    approvedAmount: 0,
    interestRate: 0,
    term: 0,
    monthlyPayment: 0,
    reasonCodes: ['LOW_CREDIT_SCORE', 'HIGH_RISK'],
    conditions: [],
    denialReasons: ['Credit score below minimum threshold', 'Poor payment history']
  },
  DENIED_HIGH_DTI: {
    creditScore: 650,
    creditGrade: 'D',
    riskLevel: 'MEDIUM_HIGH',
    decision: 'DENIED',
    approvedAmount: 0,
    interestRate: 0,
    term: 0,
    monthlyPayment: 0,
    reasonCodes: ['HIGH_DTI_RATIO', 'INSUFFICIENT_INCOME'],
    conditions: [],
    denialReasons: ['Debt-to-income ratio exceeds 45%', 'Insufficient disposable income']
  },
  DENIED_INSUFFICIENT_INCOME: {
    creditScore: 650,
    creditGrade: 'D',
    riskLevel: 'MEDIUM_HIGH',
    decision: 'DENIED',
    approvedAmount: 0,
    interestRate: 0,
    term: 0,
    monthlyPayment: 0,
    reasonCodes: ['INSUFFICIENT_INCOME', 'UNVERIFIABLE_INCOME'],
    conditions: [],
    denialReasons: ['Income cannot be verified', 'Income below minimum threshold']
  },
  PENDING_DOCUMENT_REVIEW: {
    creditScore: 680,
    creditGrade: 'C',
    riskLevel: 'MEDIUM',
    decision: 'PENDING_REVIEW',
    approvedAmount: 0,
    interestRate: 0,
    term: 0,
    monthlyPayment: 0,
    reasonCodes: ['MANUAL_REVIEW_REQUIRED'],
    conditions: [],
    denialReasons: [],
    pendingItems: ['Income verification', 'Employment verification', 'Bank statements']
  },
  ERROR_SCENARIO: {
    error: true,
    message: 'Decision engine temporarily unavailable',
    errorCode: 'DECISION_ENGINE_ERROR'
  }
};

/**
 * Determine scenario based on applicationId (matching Apex logic)
 */
function determineScenario(applicationId) {
  if (!applicationId) {
    return SCENARIOS.APPROVED_GOOD_CREDIT; // Default scenario
  }
  
  // Use simple hash of application ID to consistently return same scenario
  // This matches the Apex MockDataFactory logic
  let hash = 0;
  for (let i = 0; i < applicationId.length; i++) {
    const char = applicationId.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32bit integer
  }
  
  const scenarioIndex = Math.abs(hash) % 8;
  const scenarioKeys = Object.keys(SCENARIOS);
  return SCENARIOS[scenarioKeys[scenarioIndex]];
}

/**
 * Health check endpoint
 */
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'decision-engine-service',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
    mockMode: true
  });
});

/**
 * Main endpoint - matches root for simplicity
 */
app.get('/', (req, res) => {
  res.json({
    service: 'Decision Engine Service',
    version: '1.0.0',
    status: 'running',
    endpoints: [
      'GET /health',
      'POST /api/v1/evaluate-application',
      'POST /api/v1/credit-score',
      'POST /api/v1/calculate-payment'
    ]
  });
});

/**
 * Evaluate loan application - main decision endpoint
 * Matches Apex DecisionEngineService.evaluateApplication
 */
app.post('/api/v1/evaluate-application', (req, res) => {
  const { applicationId } = req.body;
  
  console.log(`Evaluating application: ${applicationId}`);
  
  // Get scenario based on applicationId
  const scenario = determineScenario(applicationId);
  
  // Check for error scenario
  if (scenario.error) {
    return res.status(500).json({
      success: false,
      message: scenario.message,
      errorCode: scenario.errorCode
    });
  }
  
  // Build response matching Salesforce ServiceResponse format
  const response = {
    success: true,
    data: {
      decision: scenario.decision,
      approvedAmount: scenario.approvedAmount,
      interestRate: scenario.interestRate,
      term: scenario.term,
      monthlyPayment: scenario.monthlyPayment,
      reasonCodes: scenario.reasonCodes,
      conditions: scenario.conditions,
      denialReasons: scenario.denialReasons,
      creditEvaluation: {
        creditScore: scenario.creditScore,
        creditGrade: scenario.creditGrade,
        riskLevel: scenario.riskLevel,
        bureau: 'Experian',
        scoreDate: new Date().toISOString().split('T')[0],
        factors: scenario.creditScore >= 750 
          ? ['Excellent payment history', 'Low credit utilization', 'Long credit history']
          : scenario.creditScore >= 680
          ? ['Good payment history', 'Moderate credit utilization']
          : ['Fair payment history', 'Some recent inquiries']
      },
      processedDate: new Date().toISOString(),
      expirationDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
    },
    metadata: {
      requestId: `REQ-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date().toISOString(),
      processingTime: Math.floor(Math.random() * 500) + 100
    }
  };
  
  // Add pending items if applicable
  if (scenario.pendingItems) {
    response.data.pendingItems = scenario.pendingItems;
  }
  
  res.json(response);
});

/**
 * Get credit score only
 * Matches Apex CreditEvaluationService.evaluateCreditScore
 */
app.post('/api/v1/credit-score', (req, res) => {
  const { applicationId, ssn } = req.body;
  
  // Use applicationId if provided, otherwise use SSN
  const identifier = applicationId || ssn;
  const scenario = determineScenario(identifier);
  
  if (scenario.error) {
    return res.status(500).json({
      success: false,
      message: 'Unable to retrieve credit score',
      errorCode: 'CREDIT_BUREAU_ERROR'
    });
  }
  
  res.json({
    success: true,
    data: {
      creditScore: scenario.creditScore,
      creditGrade: scenario.creditGrade,
      riskLevel: scenario.riskLevel,
      bureau: 'Experian',
      scoreDate: new Date().toISOString().split('T')[0],
      factors: scenario.creditScore >= 750 
        ? ['Excellent payment history', 'Low credit utilization', 'Long credit history']
        : scenario.creditScore >= 680
        ? ['Good payment history', 'Moderate credit utilization']
        : ['Fair payment history', 'Some recent inquiries']
    },
    metadata: {
      requestId: `CS-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date().toISOString()
    }
  });
});

/**
 * Calculate monthly payment
 * Matches Apex LoanCalculatorService.calculateMonthlyPayment
 */
app.post('/api/v1/calculate-payment', (req, res) => {
  const { principal, rate, months } = req.body;
  
  if (!principal || !rate || !months) {
    return res.status(400).json({
      success: false,
      message: 'Missing required parameters: principal, rate, months',
      errorCode: 'VALIDATION_ERROR'
    });
  }
  
  // Calculate monthly payment using standard amortization formula
  const monthlyRate = rate / 100 / 12;
  const payment = principal * (monthlyRate * Math.pow(1 + monthlyRate, months)) / 
                  (Math.pow(1 + monthlyRate, months) - 1);
  
  res.json({
    success: true,
    data: {
      principal,
      rate,
      months,
      monthlyPayment: parseFloat(payment.toFixed(2)),
      totalPayment: parseFloat((payment * months).toFixed(2)),
      totalInterest: parseFloat((payment * months - principal).toFixed(2))
    },
    metadata: {
      requestId: `CALC-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date().toISOString()
    }
  });
});

/**
 * 404 handler
 */
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found',
    path: req.path
  });
});

/**
 * Start server
 */
const server = app.listen(PORT, () => {
  console.log(`🚀 Decision Engine Service running on port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔧 Mock Mode: Enabled (matching Apex MockDataFactory)`);
  console.log(`⏰ Started at: ${new Date().toISOString()}`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
    process.exit(0);
  });
});

module.exports = app;