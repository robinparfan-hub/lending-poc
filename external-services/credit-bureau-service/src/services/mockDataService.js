const logger = require('../utils/logger');

class MockDataService {
  constructor() {
    this.bureaus = ['Equifax', 'Experian', 'TransUnion'];
    this.riskFactors = [
      { code: '01', description: 'Length of credit history' },
      { code: '02', description: 'Payment history' },
      { code: '03', description: 'Credit utilization ratio' },
      { code: '04', description: 'Types of credit in use' },
      { code: '05', description: 'New credit accounts' },
      { code: '06', description: 'Total accounts' },
      { code: '07', description: 'Hard inquiries' },
      { code: '08', description: 'Too many inquiries' },
      { code: '09', description: 'Derogatory marks' },
      { code: '10', description: 'Public records' }
    ];
  }

  /**
   * Generate a credit score based on SSN (deterministic)
   */
  generateCreditScore(ssn) {
    const lastFour = parseInt(ssn.slice(-4));
    let score, riskLevel, bureau;
    
    // Deterministic scoring based on SSN last 4 digits
    if (lastFour < 2500) {
      // Excellent credit (750-850)
      score = 750 + Math.floor((lastFour / 2500) * 100);
      riskLevel = 'low';
    } else if (lastFour < 5000) {
      // Good credit (650-749)
      score = 650 + Math.floor(((lastFour - 2500) / 2500) * 99);
      riskLevel = 'medium';
    } else if (lastFour < 7500) {
      // Fair credit (550-649)
      score = 550 + Math.floor(((lastFour - 5000) / 2500) * 99);
      riskLevel = 'medium-high';
    } else {
      // Poor credit (300-549)
      score = 300 + Math.floor(((lastFour - 7500) / 2500) * 249);
      riskLevel = 'high';
    }
    
    // Select bureau based on last digit
    bureau = this.bureaus[lastFour % 3];
    
    logger.debug(`Generated credit score ${score} for SSN ending in ${ssn.slice(-4)}`);
    
    return {
      score,
      riskLevel,
      bureau
    };
  }

  /**
   * Generate a comprehensive credit report
   */
  async generateCreditReport(ssn, firstName, lastName) {
    const scoreData = this.generateCreditScore(ssn);
    const lastFour = parseInt(ssn.slice(-4));
    
    // Generate report ID
    const today = new Date();
    const reportId = `CR-${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}-${String(lastFour % 1000).padStart(3, '0')}`;
    
    // Calculate derived values based on score
    const creditAccounts = Math.floor(scoreData.score / 50) + 3;
    const totalDebt = scoreData.riskLevel === 'low' 
      ? 15000 + (lastFour * 10)
      : scoreData.riskLevel === 'medium'
      ? 35000 + (lastFour * 15)
      : scoreData.riskLevel === 'medium-high'
      ? 55000 + (lastFour * 20)
      : 75000 + (lastFour * 25);
    
    const monthlyPayments = Math.floor(totalDebt / 60);
    const delinquencies = scoreData.score > 700 ? 0 : scoreData.score > 600 ? 1 : scoreData.score > 500 ? 3 : 5;
    const publicRecords = scoreData.score > 650 ? 0 : scoreData.score > 550 ? 1 : 2;
    const creditUtilization = scoreData.score > 750 ? 15 + (lastFour % 15) : scoreData.score > 650 ? 30 + (lastFour % 20) : 50 + (lastFour % 30);
    
    // Select risk factors based on score
    const factors = this.selectRiskFactors(scoreData.score);
    
    return {
      creditScore: scoreData.score,
      scoreRange: {
        min: 300,
        max: 850
      },
      riskLevel: scoreData.riskLevel,
      bureau: scoreData.bureau,
      reportId,
      factors,
      creditAccounts,
      totalDebt,
      monthlyPayments,
      delinquencies,
      publicRecords,
      creditUtilization,
      // Additional detailed information
      personalInfo: {
        name: `${firstName} ${lastName}`,
        ssn: `***-**-${ssn.slice(-4)}`,
        dateOfBirth: '****-**-**',
        currentAddress: 'On file'
      },
      summary: {
        oldestAccount: this.generateAccountAge(scoreData.score),
        averageAccountAge: this.generateAverageAge(scoreData.score),
        totalCreditLimit: Math.floor(totalDebt * 2.5),
        totalBalance: totalDebt,
        onTimePayments: scoreData.score > 650 ? '98%' : scoreData.score > 550 ? '85%' : '72%'
      }
    };
  }

  /**
   * Get a detailed credit report by ID
   */
  async getDetailedCreditReport(reportId) {
    // Parse the report ID to get consistent data
    const matches = reportId.match(/CR-(\d{4})-(\d{2})-(\d{2})-(\d{3})/);
    if (!matches) {
      return null;
    }
    
    const [, year, month, day, sequence] = matches;
    const mockSsn = `123-45-${String(6000 + parseInt(sequence)).padStart(4, '0')}`;
    
    // Generate consistent report based on the ID
    const baseReport = await this.generateCreditReport(mockSsn, 'John', 'Doe');
    
    // Add detailed account information
    const accounts = this.generateAccountDetails(baseReport.creditScore, baseReport.creditAccounts);
    const inquiries = this.generateInquiries(baseReport.creditScore);
    
    return {
      ...baseReport,
      reportId,
      generatedDate: `${year}-${month}-${day}T10:00:00Z`,
      creditAccounts: accounts,
      inquiries,
      publicRecords: this.generatePublicRecords(baseReport.publicRecords),
      disputedAccounts: [],
      consumerStatement: null
    };
  }

  /**
   * Generate credit history
   */
  async generateCreditHistory(ssn) {
    const scoreData = this.generateCreditScore(ssn);
    const months = 24; // 2 years of history
    const history = [];
    
    let currentScore = scoreData.score;
    const trend = scoreData.score > 650 ? 'improving' : scoreData.score > 550 ? 'stable' : 'declining';
    
    for (let i = 0; i < months; i++) {
      const monthsAgo = months - i;
      const date = new Date();
      date.setMonth(date.getMonth() - monthsAgo);
      
      // Adjust score based on trend
      if (trend === 'improving') {
        currentScore = Math.max(300, currentScore - Math.floor(Math.random() * 5));
      } else if (trend === 'declining') {
        currentScore = Math.min(850, currentScore + Math.floor(Math.random() * 5));
      } else {
        currentScore += Math.floor(Math.random() * 7) - 3;
      }
      
      history.push({
        date: date.toISOString().split('T')[0],
        score: Math.max(300, Math.min(850, currentScore)),
        bureau: this.bureaus[i % 3],
        events: this.generateHistoryEvents(i, scoreData.score)
      });
    }
    
    return {
      ssn: `***-**-${ssn.slice(-4)}`,
      history: history.reverse(),
      trend,
      averageScore: Math.floor(history.reduce((sum, h) => sum + h.score, 0) / history.length)
    };
  }

  // Helper methods
  
  selectRiskFactors(score) {
    const factorCount = score > 750 ? 2 : score > 650 ? 3 : score > 550 ? 4 : 5;
    const selectedFactors = [];
    
    if (score < 650) selectedFactors.push(this.riskFactors[1]); // Payment history
    if (score < 750) selectedFactors.push(this.riskFactors[2]); // Credit utilization
    if (score < 700) selectedFactors.push(this.riskFactors[0]); // Length of credit
    if (score < 600) selectedFactors.push(this.riskFactors[7]); // Too many inquiries
    if (score < 550) selectedFactors.push(this.riskFactors[8]); // Derogatory marks
    
    return selectedFactors.slice(0, factorCount);
  }
  
  generateAccountAge(score) {
    if (score > 750) return '12 years 3 months';
    if (score > 650) return '7 years 8 months';
    if (score > 550) return '3 years 2 months';
    return '1 year 6 months';
  }
  
  generateAverageAge(score) {
    if (score > 750) return '8 years 1 month';
    if (score > 650) return '5 years 4 months';
    if (score > 550) return '2 years 7 months';
    return '11 months';
  }
  
  generateAccountDetails(score, accountCount) {
    const accounts = [];
    const accountTypes = ['Credit Card', 'Auto Loan', 'Mortgage', 'Student Loan', 'Personal Loan'];
    const lenders = ['Chase', 'Bank of America', 'Wells Fargo', 'Capital One', 'Discover', 'American Express'];
    
    for (let i = 0; i < accountCount; i++) {
      const type = accountTypes[i % accountTypes.length];
      const lender = lenders[i % lenders.length];
      const isGood = score > 650 || i % 3 === 0;
      
      accounts.push({
        accountNumber: `****${String(1000 + i).padStart(4, '0')}`,
        type,
        lender,
        status: isGood ? 'Current' : i % 2 === 0 ? '30 days late' : '60 days late',
        balance: Math.floor(Math.random() * 10000) + 1000,
        limit: type === 'Credit Card' ? Math.floor(Math.random() * 15000) + 5000 : null,
        monthlyPayment: Math.floor(Math.random() * 500) + 100,
        openedDate: new Date(Date.now() - Math.random() * 10 * 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        lastPayment: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
      });
    }
    
    return accounts;
  }
  
  generateInquiries(score) {
    const inquiryCount = score > 750 ? 1 : score > 650 ? 2 : score > 550 ? 4 : 6;
    const inquiries = [];
    const companies = ['Rocket Mortgage', 'Carvana', 'SoFi', 'LendingClub', 'Prosper', 'Upstart'];
    
    for (let i = 0; i < inquiryCount; i++) {
      const daysAgo = Math.floor(Math.random() * 180) + 30;
      const date = new Date(Date.now() - daysAgo * 24 * 60 * 60 * 1000);
      
      inquiries.push({
        date: date.toISOString().split('T')[0],
        company: companies[i % companies.length],
        type: i % 2 === 0 ? 'Hard' : 'Soft',
        purpose: i % 3 === 0 ? 'Auto Loan' : i % 3 === 1 ? 'Credit Card' : 'Personal Loan'
      });
    }
    
    return inquiries;
  }
  
  generatePublicRecords(count) {
    if (count === 0) return [];
    
    const records = [];
    const types = ['Bankruptcy', 'Tax Lien', 'Civil Judgment'];
    
    for (let i = 0; i < count; i++) {
      records.push({
        type: types[i % types.length],
        filingDate: new Date(Date.now() - Math.random() * 5 * 365 * 24 * 60 * 60 * 1000).toISOString().split('T')[0],
        court: 'County Court',
        caseNumber: `CV-${String(Math.floor(Math.random() * 100000)).padStart(6, '0')}`,
        status: i % 2 === 0 ? 'Satisfied' : 'Open',
        amount: Math.floor(Math.random() * 50000) + 5000
      });
    }
    
    return records;
  }
  
  generateHistoryEvents(monthIndex, baseScore) {
    const events = [];
    
    // Generate events based on score and month
    if (monthIndex % 6 === 0) {
      events.push('Credit report pulled');
    }
    if (monthIndex % 4 === 0 && baseScore < 650) {
      events.push('Late payment reported');
    }
    if (monthIndex % 8 === 0) {
      events.push('New account opened');
    }
    if (monthIndex % 12 === 0 && baseScore > 700) {
      events.push('Credit limit increased');
    }
    
    return events;
  }
}

module.exports = new MockDataService();