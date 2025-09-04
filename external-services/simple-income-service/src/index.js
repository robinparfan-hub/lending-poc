require('dotenv').config();
const express = require('express');
const cors = require('cors');

// Create Express app
const app = express();
const PORT = process.env.PORT || 3007;

// Middleware
app.use(cors());
app.use(express.json());

// Mock income data based on applicationId
const INCOME_PROFILES = {
  HIGH: {
    annualIncome: 85000,
    monthlyIncome: 7083,
    employmentStatus: 'EMPLOYED',
    employmentType: 'FULL_TIME',
    employer: 'TechCorp Inc.',
    jobTitle: 'Senior Software Engineer',
    employmentYears: 5,
    verificationStatus: 'VERIFIED',
    verificationMethod: 'DIRECT_DEPOSIT',
    debtToIncomeRatio: 28.5,
    monthlyDebtPayments: 2019,
    disposableIncome: 5064
  },
  MEDIUM: {
    annualIncome: 65000,
    monthlyIncome: 5417,
    employmentStatus: 'EMPLOYED',
    employmentType: 'FULL_TIME',
    employer: 'Marketing Solutions LLC',
    jobTitle: 'Marketing Manager',
    employmentYears: 3,
    verificationStatus: 'VERIFIED',
    verificationMethod: 'PAY_STUB',
    debtToIncomeRatio: 35.2,
    monthlyDebtPayments: 1907,
    disposableIncome: 3510
  },
  LOW: {
    annualIncome: 45000,
    monthlyIncome: 3750,
    employmentStatus: 'EMPLOYED',
    employmentType: 'PART_TIME',
    employer: 'Retail Store',
    jobTitle: 'Sales Associate',
    employmentYears: 1,
    verificationStatus: 'PENDING',
    verificationMethod: 'BANK_STATEMENT',
    debtToIncomeRatio: 48.5,
    monthlyDebtPayments: 1819,
    disposableIncome: 1931
  },
  UNVERIFIABLE: {
    annualIncome: 0,
    monthlyIncome: 0,
    employmentStatus: 'UNEMPLOYED',
    employmentType: null,
    employer: null,
    jobTitle: null,
    employmentYears: 0,
    verificationStatus: 'FAILED',
    verificationMethod: null,
    debtToIncomeRatio: 0,
    monthlyDebtPayments: 0,
    disposableIncome: 0,
    errors: ['Unable to verify income', 'No employment records found']
  }
};

/**
 * Determine income profile based on applicationId
 */
function determineIncomeProfile(applicationId) {
  if (!applicationId) {
    return INCOME_PROFILES.MEDIUM;
  }
  
  // Use simple hash to determine profile
  let hash = 0;
  for (let i = 0; i < applicationId.length; i++) {
    const char = applicationId.charCodeAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash;
  }
  
  const index = Math.abs(hash) % 4;
  const profiles = ['HIGH', 'MEDIUM', 'LOW', 'UNVERIFIABLE'];
  return INCOME_PROFILES[profiles[index]];
}

/**
 * Health check
 */
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'simple-income-service',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

/**
 * Service info
 */
app.get('/', (req, res) => {
  res.json({
    service: 'Simple Income Verification Service',
    version: '1.0.0',
    status: 'running',
    endpoints: [
      'GET /health',
      'POST /api/v1/verify-income',
      'POST /api/v1/employment-verification',
      'POST /api/v1/calculate-dti'
    ]
  });
});

/**
 * Verify income - main endpoint
 */
app.post('/api/v1/verify-income', (req, res) => {
  const { applicationId, ssn } = req.body;
  
  console.log(`Verifying income for application: ${applicationId || ssn}`);
  
  const profile = determineIncomeProfile(applicationId || ssn);
  
  // Check for unverifiable scenario
  if (profile.errors) {
    return res.json({
      success: false,
      message: 'Income verification failed',
      errors: profile.errors,
      errorCode: 'INCOME_VERIFICATION_FAILED'
    });
  }
  
  res.json({
    success: true,
    data: {
      annualIncome: profile.annualIncome,
      monthlyIncome: profile.monthlyIncome,
      verificationStatus: profile.verificationStatus,
      verificationMethod: profile.verificationMethod,
      verificationDate: new Date().toISOString(),
      incomeSource: {
        type: 'EMPLOYMENT',
        employer: profile.employer,
        jobTitle: profile.jobTitle,
        employmentType: profile.employmentType,
        startDate: new Date(Date.now() - profile.employmentYears * 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
      },
      financialSummary: {
        monthlyIncome: profile.monthlyIncome,
        monthlyDebtPayments: profile.monthlyDebtPayments,
        disposableIncome: profile.disposableIncome,
        debtToIncomeRatio: profile.debtToIncomeRatio
      }
    },
    metadata: {
      requestId: `INC-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date().toISOString(),
      processingTime: Math.floor(Math.random() * 300) + 100
    }
  });
});

/**
 * Employment verification
 */
app.post('/api/v1/employment-verification', (req, res) => {
  const { applicationId, employerName } = req.body;
  
  const profile = determineIncomeProfile(applicationId);
  
  if (profile.employmentStatus === 'UNEMPLOYED') {
    return res.json({
      success: false,
      message: 'Employment verification failed',
      errorCode: 'EMPLOYMENT_NOT_FOUND'
    });
  }
  
  res.json({
    success: true,
    data: {
      employmentStatus: profile.employmentStatus,
      employer: profile.employer,
      jobTitle: profile.jobTitle,
      employmentType: profile.employmentType,
      employmentYears: profile.employmentYears,
      verificationStatus: 'VERIFIED',
      verificationDate: new Date().toISOString()
    },
    metadata: {
      requestId: `EMP-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
      timestamp: new Date().toISOString()
    }
  });
});

/**
 * Calculate debt-to-income ratio
 */
app.post('/api/v1/calculate-dti', (req, res) => {
  const { monthlyIncome, monthlyDebtPayments } = req.body;
  
  if (!monthlyIncome || monthlyIncome === 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid monthly income',
      errorCode: 'INVALID_INCOME'
    });
  }
  
  const dtiRatio = (monthlyDebtPayments / monthlyIncome * 100).toFixed(2);
  const disposableIncome = monthlyIncome - monthlyDebtPayments;
  
  res.json({
    success: true,
    data: {
      monthlyIncome,
      monthlyDebtPayments,
      debtToIncomeRatio: parseFloat(dtiRatio),
      disposableIncome,
      riskLevel: dtiRatio < 30 ? 'LOW' : dtiRatio < 40 ? 'MEDIUM' : dtiRatio < 50 ? 'HIGH' : 'VERY_HIGH',
      recommendation: dtiRatio < 43 ? 'ACCEPTABLE' : 'EXCEEDS_THRESHOLD'
    },
    metadata: {
      requestId: `DTI-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`,
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
  console.log(`💰 Simple Income Service running on port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log(`🔧 Mock Mode: Enabled`);
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