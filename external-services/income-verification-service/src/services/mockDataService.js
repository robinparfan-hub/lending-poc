const logger = require('../utils/logger');

class MockDataService {
  constructor() {
    this.employerPatterns = {
      tech: { minIncome: 100000, maxIncome: 150000, verified: true, employmentType: 'full-time' },
      bank: { minIncome: 80000, maxIncome: 120000, verified: true, employmentType: 'full-time' },
      retail: { minIncome: 40000, maxIncome: 60000, verified: true, employmentType: 'full-time' },
      restaurant: { minIncome: 25000, maxIncome: 40000, verified: true, employmentType: 'full-time' },
      test: { minIncome: 0, maxIncome: 0, verified: false, employmentType: 'unknown' }
    };
  }

  /**
   * Generate income verification data based on employer patterns
   */
  async generateIncomeVerification(employmentInfo, bankAccounts) {
    const { employerName, position, statedIncome, startDate } = employmentInfo;
    
    // Determine employer pattern
    const pattern = this.getEmployerPattern(employerName);
    
    // Generate verification ID
    const verificationId = `INC-VER-${new Date().getFullYear()}-${String(Math.floor(Math.random() * 10000)).padStart(5, '0')}`;
    
    // Calculate verified income based on pattern
    let verifiedAnnual, verificationStatus, employmentVerified, confidenceScore;
    
    if (pattern.verified) {
      // Generate income within the pattern range
      const baseIncome = pattern.minIncome + Math.random() * (pattern.maxIncome - pattern.minIncome);
      
      // Add some variance based on position
      const positionMultiplier = this.getPositionMultiplier(position);
      verifiedAnnual = Math.floor(baseIncome * positionMultiplier);
      
      // Check discrepancy with stated income
      const discrepancyPercent = Math.abs((verifiedAnnual - statedIncome) / statedIncome * 100);
      
      if (discrepancyPercent < 5) {
        verificationStatus = 'verified';
        confidenceScore = 95 + Math.random() * 5;
      } else if (discrepancyPercent < 15) {
        verificationStatus = 'verified_with_discrepancy';
        confidenceScore = 75 + Math.random() * 20;
      } else {
        verificationStatus = 'needs_review';
        confidenceScore = 50 + Math.random() * 25;
      }
      
      employmentVerified = true;
    } else {
      verifiedAnnual = 0;
      verificationStatus = 'unverifiable';
      employmentVerified = false;
      confidenceScore = 0;
    }
    
    // Generate income sources
    const sources = this.generateIncomeSources(verifiedAnnual, employerName, bankAccounts);
    
    logger.debug(`Generated income verification for ${employerName}: $${verifiedAnnual} (${verificationStatus})`);
    
    return {
      verificationId,
      verificationStatus,
      verifiedIncome: {
        annual: verifiedAnnual,
        monthly: Math.floor(verifiedAnnual / 12),
        sources
      },
      employmentVerified,
      confidenceScore: Math.floor(confidenceScore),
      discrepancyNotes: this.generateDiscrepancyNotes(statedIncome, verifiedAnnual, verificationStatus),
      employmentDetails: {
        employer: employerName,
        position,
        employmentType: pattern.employmentType,
        startDate: startDate || this.generateEmploymentStartDate(),
        yearsEmployed: this.calculateYearsEmployed(startDate)
      },
      verificationMethod: pattern.verified ? 'The Work Number' : 'Unable to verify',
      lastUpdated: new Date().toISOString()
    };
  }

  /**
   * Generate employment check data
   */
  generateEmploymentCheck(employerName, employeeName) {
    const pattern = this.getEmployerPattern(employerName);
    
    if (!pattern.verified) {
      return {
        employed: false,
        employmentStatus: 'unverifiable',
        verificationSource: 'unable_to_verify',
        verificationDate: new Date().toISOString(),
        message: 'Unable to verify employment with this employer'
      };
    }
    
    // Mock employment verification
    const employed = !employeeName.toLowerCase().includes('former');
    const startDate = this.generateEmploymentStartDate();
    
    return {
      employed,
      employmentStatus: employed ? pattern.employmentType : 'terminated',
      startDate,
      position: this.generatePosition(employerName),
      verificationSource: 'employer-direct',
      verificationDate: new Date().toISOString(),
      employmentLength: this.calculateYearsEmployed(startDate),
      eligibleForRehire: employed ? null : Math.random() > 0.3
    };
  }

  /**
   * Generate bank statements
   */
  generateBankStatements(accountId) {
    if (!accountId || accountId === 'invalid') {
      return null;
    }
    
    const months = 3; // Generate 3 months of statements
    const statements = [];
    
    for (let i = 0; i < months; i++) {
      const date = new Date();
      date.setMonth(date.getMonth() - i);
      
      const deposits = this.generateMonthlyDeposits();
      const withdrawals = this.generateMonthlyWithdrawals();
      const openingBalance = 5000 + Math.random() * 10000;
      const closingBalance = openingBalance + deposits.total - withdrawals.total;
      
      statements.push({
        month: date.toISOString().substring(0, 7),
        accountId,
        openingBalance: Math.floor(openingBalance),
        closingBalance: Math.floor(closingBalance),
        deposits,
        withdrawals,
        averageDailyBalance: Math.floor((openingBalance + closingBalance) / 2),
        lowestBalance: Math.floor(Math.min(openingBalance, closingBalance) * 0.8),
        highestBalance: Math.floor(Math.max(openingBalance, closingBalance) * 1.1)
      });
    }
    
    return {
      accountId,
      accountType: 'checking',
      bankName: this.generateBankName(accountId),
      statements: statements.reverse(), // Return in chronological order
      summary: {
        averageMonthlyDeposits: Math.floor(statements.reduce((sum, s) => sum + s.deposits.total, 0) / months),
        averageBalance: Math.floor(statements.reduce((sum, s) => sum + s.averageDailyBalance, 0) / months),
        consistentIncome: true
      }
    };
  }

  // Helper methods
  
  getEmployerPattern(employerName) {
    const lowerName = employerName.toLowerCase();
    
    if (lowerName.includes('test')) return this.employerPatterns.test;
    if (lowerName.includes('tech') || lowerName.includes('software')) return this.employerPatterns.tech;
    if (lowerName.includes('bank') || lowerName.includes('financial')) return this.employerPatterns.bank;
    if (lowerName.includes('retail') || lowerName.includes('store')) return this.employerPatterns.retail;
    if (lowerName.includes('restaurant') || lowerName.includes('food')) return this.employerPatterns.restaurant;
    
    // Default pattern
    return { minIncome: 50000, maxIncome: 80000, verified: true, employmentType: 'full-time' };
  }
  
  getPositionMultiplier(position) {
    const lowerPosition = position.toLowerCase();
    
    if (lowerPosition.includes('senior') || lowerPosition.includes('lead')) return 1.3;
    if (lowerPosition.includes('manager') || lowerPosition.includes('director')) return 1.5;
    if (lowerPosition.includes('vp') || lowerPosition.includes('president')) return 2.0;
    if (lowerPosition.includes('junior') || lowerPosition.includes('entry')) return 0.7;
    if (lowerPosition.includes('intern')) return 0.3;
    
    return 1.0;
  }
  
  generateIncomeSources(annualIncome, employerName, bankAccounts) {
    const sources = [];
    
    // Primary employment income
    const employmentIncome = Math.floor(annualIncome * 0.9); // 90% from employment
    sources.push({
      type: 'employment',
      amount: employmentIncome,
      verified: true,
      source: 'The Work Number',
      employer: employerName,
      frequency: 'monthly'
    });
    
    // Add other income sources
    if (annualIncome > 0) {
      const otherIncome = annualIncome - employmentIncome;
      if (otherIncome > 0) {
        sources.push({
          type: 'other',
          amount: otherIncome,
          verified: true,
          source: '1099 Income',
          description: 'Freelance/Contract Work',
          frequency: 'variable'
        });
      }
    }
    
    // Add bank verification if accounts provided
    if (bankAccounts && bankAccounts.length > 0) {
      sources.push({
        type: 'bank_verification',
        amount: annualIncome,
        verified: true,
        source: 'Bank Statements',
        accountCount: bankAccounts.length,
        frequency: 'monthly'
      });
    }
    
    return sources;
  }
  
  generateDiscrepancyNotes(statedIncome, verifiedIncome, status) {
    if (status === 'unverifiable') {
      return 'Unable to verify income with provided information';
    }
    
    const difference = verifiedIncome - statedIncome;
    const percentDiff = Math.abs(difference / statedIncome * 100);
    
    if (percentDiff < 2) {
      return 'Stated income matches verified income';
    } else if (percentDiff < 10) {
      return `Stated income within ${percentDiff.toFixed(1)}% of verified amount`;
    } else if (difference > 0) {
      return `Verified income is ${percentDiff.toFixed(1)}% higher than stated`;
    } else {
      return `Verified income is ${percentDiff.toFixed(1)}% lower than stated`;
    }
  }
  
  generateEmploymentStartDate() {
    const yearsAgo = Math.floor(Math.random() * 10) + 1;
    const date = new Date();
    date.setFullYear(date.getFullYear() - yearsAgo);
    date.setMonth(Math.floor(Math.random() * 12));
    return date.toISOString().split('T')[0];
  }
  
  calculateYearsEmployed(startDate) {
    if (!startDate) return 0;
    
    const start = new Date(startDate);
    const now = new Date();
    const years = (now - start) / (365.25 * 24 * 60 * 60 * 1000);
    
    return Math.floor(years * 10) / 10; // Round to 1 decimal
  }
  
  generatePosition(employerName) {
    const lowerName = employerName.toLowerCase();
    
    if (lowerName.includes('tech')) {
      const positions = ['Software Engineer', 'Product Manager', 'Data Analyst', 'DevOps Engineer'];
      return positions[Math.floor(Math.random() * positions.length)];
    }
    if (lowerName.includes('bank')) {
      const positions = ['Loan Officer', 'Financial Analyst', 'Branch Manager', 'Teller'];
      return positions[Math.floor(Math.random() * positions.length)];
    }
    
    return 'Associate';
  }
  
  generateBankName(accountId) {
    const banks = ['Chase', 'Bank of America', 'Wells Fargo', 'Citi', 'US Bank'];
    const index = parseInt(accountId.replace(/\D/g, '').slice(-1)) % banks.length;
    return banks[index];
  }
  
  generateMonthlyDeposits() {
    const count = 4 + Math.floor(Math.random() * 8); // 4-12 deposits
    const transactions = [];
    let total = 0;
    
    // Payroll deposits (2 per month)
    for (let i = 0; i < 2; i++) {
      const amount = 3000 + Math.random() * 2000;
      transactions.push({
        type: 'payroll',
        amount: Math.floor(amount),
        description: 'Direct Deposit - Payroll'
      });
      total += amount;
    }
    
    // Other deposits
    for (let i = 2; i < count; i++) {
      const amount = 50 + Math.random() * 500;
      transactions.push({
        type: 'deposit',
        amount: Math.floor(amount),
        description: 'Deposit'
      });
      total += amount;
    }
    
    return {
      count,
      total: Math.floor(total),
      transactions
    };
  }
  
  generateMonthlyWithdrawals() {
    const count = 15 + Math.floor(Math.random() * 20); // 15-35 withdrawals
    const transactions = [];
    let total = 0;
    
    // Fixed expenses
    const fixedExpenses = [
      { description: 'Mortgage/Rent', amount: 1500 + Math.random() * 1000 },
      { description: 'Auto Loan', amount: 300 + Math.random() * 300 },
      { description: 'Insurance', amount: 100 + Math.random() * 200 },
      { description: 'Utilities', amount: 100 + Math.random() * 150 }
    ];
    
    fixedExpenses.forEach(expense => {
      transactions.push({
        type: 'withdrawal',
        amount: Math.floor(expense.amount),
        description: expense.description
      });
      total += expense.amount;
    });
    
    // Variable expenses
    for (let i = fixedExpenses.length; i < count; i++) {
      const amount = 20 + Math.random() * 200;
      transactions.push({
        type: 'withdrawal',
        amount: Math.floor(amount),
        description: 'Purchase'
      });
      total += amount;
    }
    
    return {
      count,
      total: Math.floor(total),
      transactions: transactions.slice(0, 10) // Return only first 10 for brevity
    };
  }
}

module.exports = new MockDataService();