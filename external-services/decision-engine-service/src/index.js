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
  
  // TEMPORARY: Always return APPROVED for testing the full wizard flow
  // TODO: Remove this override after testing
  console.log('DEBUG: Overriding scenario to APPROVED_EXCELLENT_CREDIT for testing');
  return SCENARIOS.APPROVED_EXCELLENT_CREDIT;
  
  // Original logic (commented out for testing)
  /*
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
  */
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
 * ML-Enhanced Loan Evaluation Endpoint
 * Uses logistic regression-style scoring for realistic loan decisions
 */
app.post('/api/v1/ml-evaluate', (req, res) => {
  const { 
    applicationId,
    creditScore,
    annualIncome,
    loanAmount,
    loanTerm,
    employmentYears,
    dtiRatio,
    previousDefaults,
    loanPurpose
  } = req.body;
  
  console.log(`ML Evaluation for application: ${applicationId}`);
  
  // Validate required fields
  if (!creditScore || !annualIncome || !loanAmount) {
    return res.status(400).json({
      success: false,
      message: 'Missing required fields: creditScore, annualIncome, loanAmount',
      errorCode: 'VALIDATION_ERROR'
    });
  }
  
  // Feature engineering and normalization
  const features = {
    creditScoreNorm: Math.min(Math.max((creditScore - 300) / 550, 0), 1), // Normalize 300-850 to 0-1
    loanToIncomeRatio: loanAmount / annualIncome,
    dtiRatioNorm: Math.min((dtiRatio || 0.3) / 0.6, 1), // Cap at 60% DTI
    employmentStability: Math.min((employmentYears || 2) / 10, 1), // Normalize to 10 years max
    hasDefaults: previousDefaults ? 1 : 0,
    loanAmountNorm: Math.min(loanAmount / 100000, 1), // Normalize to 100k max
    termRisk: (loanTerm || 60) / 84 // Longer terms = higher risk
  };
  
  // Logistic regression coefficients (mimicking a trained model)
  // These weights are based on typical lending industry standards
  const weights = {
    intercept: 0.5,        // Adjusted for better baseline
    creditScore: 5.2,      // Highest weight - most important factor
    loanToIncome: -1.8,    // Negative - higher ratio = lower approval
    dtiRatio: -2.5,        // Negative - higher DTI = lower approval
    employment: 1.5,       // Positive - more years = better
    defaults: -6.0,        // Strong negative for previous defaults
    loanAmount: -0.5,      // Slight negative for larger loans
    termRisk: -0.8         // Negative for longer terms
  };
  
  // Calculate logit (linear combination)
  const logit = weights.intercept +
    weights.creditScore * features.creditScoreNorm +
    weights.loanToIncome * features.loanToIncomeRatio +
    weights.dtiRatio * features.dtiRatioNorm +
    weights.employment * features.employmentStability +
    weights.defaults * features.hasDefaults +
    weights.loanAmount * features.loanAmountNorm +
    weights.termRisk * features.termRisk;
  
  // Apply sigmoid function to get probability
  const approvalProbability = 1 / (1 + Math.exp(-logit));
  
  // Decision thresholds
  let decision, approvedAmount, riskLevel;
  if (approvalProbability >= 0.75) {
    decision = 'APPROVED';
    approvedAmount = loanAmount;
    riskLevel = 'LOW';
  } else if (approvalProbability >= 0.5) {
    decision = 'APPROVED_WITH_CONDITIONS';
    approvedAmount = Math.round(loanAmount * 0.8); // Approve 80% of requested
    riskLevel = 'MEDIUM';
  } else if (approvalProbability >= 0.3) {
    decision = 'PENDING_REVIEW';
    approvedAmount = 0;
    riskLevel = 'MEDIUM_HIGH';
  } else {
    decision = 'DENIED';
    approvedAmount = 0;
    riskLevel = 'HIGH';
  }
  
  // Calculate interest rate based on risk (Prime rate + risk premium)
  const baseRate = 5.5; // Current prime rate approximation
  const riskPremium = (1 - approvalProbability) * 15; // Up to 15% additional for high risk
  const interestRate = parseFloat((baseRate + riskPremium).toFixed(2));
  
  // Calculate monthly payment if approved
  let monthlyPayment = 0;
  if (approvedAmount > 0) {
    const monthlyRate = interestRate / 100 / 12;
    const months = loanTerm || 60;
    monthlyPayment = approvedAmount * (monthlyRate * Math.pow(1 + monthlyRate, months)) / 
                     (Math.pow(1 + monthlyRate, months) - 1);
  }
  
  // Generate detailed risk factors
  const riskFactors = [];
  if (features.creditScoreNorm < 0.5) riskFactors.push('Below average credit score');
  if (features.loanToIncomeRatio > 0.4) riskFactors.push('High loan-to-income ratio');
  if (features.dtiRatioNorm > 0.6) riskFactors.push('Elevated debt-to-income ratio');
  if (features.employmentStability < 0.2) riskFactors.push('Limited employment history');
  if (features.hasDefaults) riskFactors.push('Previous loan defaults');
  
  // Generate positive factors
  const positiveFactors = [];
  if (features.creditScoreNorm >= 0.7) positiveFactors.push('Strong credit history');
  if (features.loanToIncomeRatio <= 0.2) positiveFactors.push('Conservative loan amount');
  if (features.dtiRatioNorm <= 0.3) positiveFactors.push('Low debt burden');
  if (features.employmentStability >= 0.5) positiveFactors.push('Stable employment');
  
  // Build ML-enhanced response
  const response = {
    success: true,
    data: {
      decision,
      approvalProbability: parseFloat((approvalProbability * 100).toFixed(2)),
      approvedAmount,
      interestRate,
      term: loanTerm || 60,
      monthlyPayment: parseFloat(monthlyPayment.toFixed(2)),
      riskLevel,
      riskScore: parseFloat(((1 - approvalProbability) * 100).toFixed(2)),
      creditEvaluation: {
        creditScore,
        creditGrade: creditScore >= 750 ? 'A' : creditScore >= 700 ? 'B' : 
                     creditScore >= 650 ? 'C' : creditScore >= 600 ? 'D' : 'E',
        bureau: 'ML-Enhanced Evaluation',
        scoreDate: new Date().toISOString().split('T')[0]
      },
      mlInsights: {
        model: 'LogisticRegression_v1',
        features: features,
        weights: weights,
        logitScore: parseFloat(logit.toFixed(4)),
        riskFactors,
        positiveFactors,
        confidenceScore: parseFloat((Math.abs(approvalProbability - 0.5) * 2 * 100).toFixed(2))
      },
      conditions: decision === 'APPROVED_WITH_CONDITIONS' ? 
        ['Income verification required', 'Employment verification required'] : [],
      denialReasons: decision === 'DENIED' ? riskFactors : [],
      processedDate: new Date().toISOString(),
      expirationDate: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString()
    },
    metadata: {
      requestId: `ML-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date().toISOString(),
      processingTime: Math.floor(Math.random() * 100) + 50,
      modelVersion: '1.0.0'
    }
  };
  
  res.json(response);
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