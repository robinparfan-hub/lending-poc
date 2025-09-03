const logger = require('../utils/logger');

/**
 * Generate mock extracted data based on document type
 */
const generateExtractedData = async (documentType, extractionType) => {
  logger.info(`Generating mock extracted data for ${documentType} (${extractionType})`);
  
  // Simulate processing delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  switch (documentType) {
    case 'bank_statement':
      return generateBankStatementData();
    
    case 'pay_stub':
      return generatePayStubData();
    
    case 'tax_return':
      return generateTaxReturnData();
    
    case 'drivers_license':
      return generateDriversLicenseData();
    
    case 'utility_bill':
      return generateUtilityBillData();
    
    default:
      return generateGenericData(extractionType);
  }
};

/**
 * Generate bank statement data
 */
const generateBankStatementData = () => {
  const accountNumber = Math.random().toString().slice(2, 12);
  const balance = Math.floor(Math.random() * 50000) + 5000;
  
  return {
    documentType: 'bank_statement',
    confidence: 0.96,
    extractedFields: {
      accountNumber: `****${accountNumber.slice(-4)}`,
      accountHolder: 'John Doe',
      bankName: 'First National Bank',
      statementPeriod: {
        start: '2024-12-01',
        end: '2024-12-31'
      },
      currentBalance: balance,
      averageBalance: balance * 0.85,
      transactions: {
        deposits: Math.floor(Math.random() * 10) + 5,
        withdrawals: Math.floor(Math.random() * 20) + 10,
        totalDeposits: balance * 1.5,
        totalWithdrawals: balance * 0.65
      }
    }
  };
};

/**
 * Generate pay stub data
 */
const generatePayStubData = () => {
  const grossPay = Math.floor(Math.random() * 5000) + 3000;
  const taxes = grossPay * 0.25;
  const deductions = grossPay * 0.08;
  
  return {
    documentType: 'pay_stub',
    confidence: 0.94,
    extractedFields: {
      employeeName: 'Jane Smith',
      employeeId: 'EMP' + Math.random().toString().slice(2, 8),
      employerName: 'Tech Solutions Inc',
      payPeriod: {
        start: '2024-12-01',
        end: '2024-12-15'
      },
      earnings: {
        regular: grossPay,
        overtime: grossPay * 0.1,
        gross: grossPay * 1.1
      },
      deductions: {
        federalTax: taxes * 0.6,
        stateTax: taxes * 0.3,
        socialSecurity: taxes * 0.1,
        medicare: deductions * 0.3,
        retirement: deductions * 0.7
      },
      netPay: grossPay * 1.1 - taxes - deductions,
      ytdEarnings: grossPay * 24
    }
  };
};

/**
 * Generate tax return data
 */
const generateTaxReturnData = () => {
  const agi = Math.floor(Math.random() * 100000) + 50000;
  
  return {
    documentType: 'tax_return',
    confidence: 0.93,
    extractedFields: {
      taxYear: '2023',
      filingStatus: 'Single',
      taxpayerName: 'Robert Johnson',
      ssn: '***-**-6789',
      income: {
        wages: agi * 0.85,
        interest: agi * 0.02,
        dividends: agi * 0.03,
        capitalGains: agi * 0.1,
        adjustedGrossIncome: agi
      },
      deductions: {
        standard: 13850,
        itemized: 0
      },
      taxableIncome: agi - 13850,
      taxWithheld: agi * 0.22,
      refundAmount: agi * 0.02
    }
  };
};

/**
 * Generate drivers license data
 */
const generateDriversLicenseData = () => {
  return {
    documentType: 'drivers_license',
    confidence: 0.98,
    extractedFields: {
      licenseNumber: 'D' + Math.random().toString().slice(2, 10),
      fullName: 'Michael Anderson',
      dateOfBirth: '1985-06-15',
      address: {
        street: '123 Main Street',
        city: 'Springfield',
        state: 'IL',
        zip: '62701'
      },
      issueDate: '2022-03-10',
      expirationDate: '2030-06-15',
      class: 'D',
      restrictions: 'None',
      endorsements: 'None',
      sex: 'M',
      height: '5-10',
      weight: '180',
      eyeColor: 'BRN',
      hairColor: 'BRN'
    }
  };
};

/**
 * Generate utility bill data
 */
const generateUtilityBillData = () => {
  const amount = Math.floor(Math.random() * 200) + 50;
  
  return {
    documentType: 'utility_bill',
    confidence: 0.95,
    extractedFields: {
      accountNumber: Math.random().toString().slice(2, 12),
      customerName: 'Sarah Williams',
      serviceAddress: {
        street: '456 Oak Avenue',
        city: 'Portland',
        state: 'OR',
        zip: '97201'
      },
      billingPeriod: {
        start: '2024-11-01',
        end: '2024-11-30'
      },
      utility: 'Electric',
      provider: 'Pacific Power & Light',
      usage: {
        current: 850,
        previous: 780,
        units: 'kWh'
      },
      charges: {
        basic: 25.00,
        usage: amount - 25,
        taxes: amount * 0.08,
        total: amount * 1.08
      },
      dueDate: '2024-12-20'
    }
  };
};

/**
 * Generate generic extracted data
 */
const generateGenericData = (extractionType) => {
  if (extractionType === 'text') {
    return {
      documentType: 'generic',
      confidence: 0.90,
      extractedText: `Lorem ipsum dolor sit amet, consectetur adipiscing elit. 
        Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. 
        Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.`,
      wordCount: 42,
      language: 'en'
    };
  }
  
  return {
    documentType: 'generic',
    confidence: 0.88,
    extractedFields: {
      title: 'Document Title',
      date: new Date().toISOString().split('T')[0],
      author: 'Unknown',
      content: 'Extracted content from document',
      metadata: {
        pages: Math.floor(Math.random() * 10) + 1,
        format: 'PDF'
      }
    }
  };
};

/**
 * Validate document authenticity
 */
const validateDocument = async (documentType, fileName) => {
  logger.info(`Validating document: ${fileName} (${documentType})`);
  
  // Simulate processing delay
  await new Promise(resolve => setTimeout(resolve, 1000));
  
  // Mock validation logic based on filename patterns
  const lowerFileName = fileName.toLowerCase();
  
  // Test patterns for different validation results
  if (lowerFileName.includes('fake') || lowerFileName.includes('invalid')) {
    return {
      isValid: false,
      confidence: 0.15,
      issues: [
        {
          type: 'authenticity',
          severity: 'critical',
          description: 'Document appears to be altered or fabricated'
        },
        {
          type: 'metadata',
          severity: 'high',
          description: 'Metadata inconsistencies detected'
        }
      ],
      checks: {
        formatValid: false,
        metadataConsistent: false,
        signatureValid: false,
        tamperDetection: 'failed',
        ocrConfidence: 0.45
      }
    };
  }
  
  if (lowerFileName.includes('expired')) {
    return {
      isValid: false,
      confidence: 0.75,
      issues: [
        {
          type: 'expiration',
          severity: 'high',
          description: 'Document has expired'
        }
      ],
      checks: {
        formatValid: true,
        metadataConsistent: true,
        signatureValid: true,
        tamperDetection: 'passed',
        ocrConfidence: 0.92,
        expirationCheck: 'failed'
      }
    };
  }
  
  if (lowerFileName.includes('suspicious')) {
    return {
      isValid: true,
      confidence: 0.68,
      warnings: [
        {
          type: 'quality',
          severity: 'medium',
          description: 'Document quality is below optimal threshold'
        }
      ],
      checks: {
        formatValid: true,
        metadataConsistent: true,
        signatureValid: true,
        tamperDetection: 'warning',
        ocrConfidence: 0.78
      }
    };
  }
  
  // Default: valid document
  return {
    isValid: true,
    confidence: 0.94,
    checks: {
      formatValid: true,
      metadataConsistent: true,
      signatureValid: true,
      tamperDetection: 'passed',
      ocrConfidence: 0.96,
      documentAge: 'acceptable',
      qualityScore: 0.92
    },
    metadata: {
      verifiedAt: new Date().toISOString(),
      verificationMethod: 'automated',
      documentHash: 'sha256:' + Math.random().toString(36).substring(2, 15)
    }
  };
};

module.exports = {
  generateExtractedData,
  validateDocument
};