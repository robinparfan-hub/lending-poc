const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');
const mockDataService = require('../services/mockDataService');

class IncomeController {
  /**
   * Verify income from multiple sources
   */
  async verifyIncome(req, res, next) {
    try {
      const startTime = Date.now();
      const requestId = uuidv4();
      
      logger.info(`Income verification request received - RequestID: ${requestId}`);
      
      const { applicantId, employmentInfo, bankAccounts, consentToken } = req.body;
      
      // Simulate processing delay
      if (process.env.MOCK_MODE === 'true') {
        await new Promise(resolve => setTimeout(resolve, Math.random() * 1500 + 500));
      }
      
      // Get mock or real data
      const verificationData = process.env.MOCK_MODE === 'true' 
        ? await mockDataService.generateIncomeVerification(employmentInfo, bankAccounts)
        : await this.fetchRealIncomeVerification(applicantId, employmentInfo, bankAccounts, consentToken);
      
      const processingTime = Date.now() - startTime;
      
      const response = {
        success: true,
        data: verificationData,
        metadata: {
          requestId,
          timestamp: new Date().toISOString(),
          processingTime
        }
      };
      
      logger.info(`Income verification completed - RequestID: ${requestId}, Status: ${verificationData.verificationStatus}`);
      
      res.json(response);
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Check employment status
   */
  async checkEmployment(req, res, next) {
    try {
      const { employerName, employeeName, employeeSSN } = req.body;
      
      logger.info(`Employment check request for ${employeeName} at ${employerName}`);
      
      // Simulate processing delay
      if (process.env.MOCK_MODE === 'true') {
        await new Promise(resolve => setTimeout(resolve, Math.random() * 1000 + 500));
      }
      
      const employmentData = process.env.MOCK_MODE === 'true'
        ? mockDataService.generateEmploymentCheck(employerName, employeeName)
        : await this.fetchRealEmploymentCheck(employerName, employeeName, employeeSSN);
      
      res.json({
        success: true,
        data: employmentData,
        metadata: {
          requestId: uuidv4(),
          timestamp: new Date().toISOString()
        }
      });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Calculate debt-to-income ratio
   */
  async calculateDTI(req, res, next) {
    try {
      const { monthlyIncome, monthlyDebts } = req.body;
      
      logger.info(`DTI calculation request - Income: $${monthlyIncome}`);
      
      // Calculate total monthly debt
      const totalMonthlyDebt = Object.values(monthlyDebts).reduce((sum, debt) => {
        return sum + (parseFloat(debt) || 0);
      }, 0);
      
      // Calculate DTI ratio
      const dtiRatio = monthlyIncome > 0 
        ? ((totalMonthlyDebt / monthlyIncome) * 100).toFixed(2)
        : 0;
      
      // Determine classification
      let classification;
      if (dtiRatio <= 36) {
        classification = 'excellent';
      } else if (dtiRatio <= 43) {
        classification = 'good';
      } else if (dtiRatio <= 50) {
        classification = 'fair';
      } else {
        classification = 'poor';
      }
      
      // Calculate maximum affordable loan payment (28% rule for housing)
      const maxLoanPayment = Math.floor(monthlyIncome * 0.28 - (monthlyDebts.mortgage || 0));
      
      res.json({
        success: true,
        data: {
          dtiRatio: parseFloat(dtiRatio),
          totalMonthlyDebt,
          totalMonthlyIncome: monthlyIncome,
          classification,
          maxLoanPayment: Math.max(0, maxLoanPayment),
          breakdown: {
            mortgage: monthlyDebts.mortgage || 0,
            autoLoan: monthlyDebts.autoLoan || 0,
            creditCards: monthlyDebts.creditCards || 0,
            studentLoans: monthlyDebts.studentLoans || 0,
            otherDebts: monthlyDebts.otherDebts || 0
          }
        },
        metadata: {
          requestId: uuidv4(),
          timestamp: new Date().toISOString()
        }
      });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Get bank statements
   */
  async getBankStatements(req, res, next) {
    try {
      const { accountId } = req.params;
      
      logger.info(`Bank statements request for account: ${accountId}`);
      
      // Simulate processing delay
      if (process.env.MOCK_MODE === 'true') {
        await new Promise(resolve => setTimeout(resolve, Math.random() * 500 + 200));
      }
      
      const statements = process.env.MOCK_MODE === 'true'
        ? mockDataService.generateBankStatements(accountId)
        : await this.fetchRealBankStatements(accountId);
      
      if (!statements) {
        return res.status(404).json({
          success: false,
          message: 'Bank account not found',
          errorCode: 'NOT_FOUND'
        });
      }
      
      res.json({
        success: true,
        data: statements,
        metadata: {
          requestId: uuidv4(),
          timestamp: new Date().toISOString()
        }
      });
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Analyze income patterns using statistical methods
   * Detects anomalies and calculates income stability score
   */
  async analyzeIncomePattern(req, res, next) {
    try {
      const startTime = Date.now();
      const requestId = uuidv4();
      
      logger.info(`Income pattern analysis request - RequestID: ${requestId}`);
      
      const { 
        monthlyIncomes,  // Array of last 12 months income
        depositPatterns, // Array of deposit counts per month
        employmentMonths,
        incomeSource,
        expectedIncome
      } = req.body;
      
      // Validate input
      if (!monthlyIncomes || !Array.isArray(monthlyIncomes) || monthlyIncomes.length < 3) {
        return res.status(400).json({
          success: false,
          message: 'At least 3 months of income data required',
          errorCode: 'INSUFFICIENT_DATA'
        });
      }
      
      // Calculate statistical metrics
      const incomeStats = this.calculateStatistics(monthlyIncomes);
      const depositStats = depositPatterns ? this.calculateStatistics(depositPatterns) : null;
      
      // Z-score based anomaly detection
      const anomalies = [];
      const zScores = monthlyIncomes.map((income, index) => {
        const zScore = (income - incomeStats.mean) / (incomeStats.stdDev || 1);
        
        // Flag anomalies (z-score > 2.5 or < -2.5)
        if (Math.abs(zScore) > 2.5) {
          anomalies.push({
            month: index + 1,
            income,
            zScore: parseFloat(zScore.toFixed(2)),
            type: zScore > 0 ? 'SPIKE' : 'DROP',
            severity: Math.abs(zScore) > 3.5 ? 'HIGH' : 'MEDIUM'
          });
        }
        
        return zScore;
      });
      
      // Calculate income stability score (0-100)
      const stabilityFactors = {
        consistency: Math.max(0, 100 - (incomeStats.coefficientOfVariation * 100)),
        trend: this.calculateTrendScore(monthlyIncomes),
        anomalyPenalty: Math.max(0, 100 - (anomalies.length * 15)),
        employmentBonus: Math.min(20, (employmentMonths || 0) / 6 * 20)
      };
      
      const stabilityScore = Math.round(
        (stabilityFactors.consistency * 0.4) +
        (stabilityFactors.trend * 0.2) +
        (stabilityFactors.anomalyPenalty * 0.3) +
        (stabilityFactors.employmentBonus * 0.1)
      );
      
      // Fraud risk indicators
      const fraudIndicators = [];
      
      // Check for sudden income increases
      const recentAvg = monthlyIncomes.slice(-3).reduce((a, b) => a + b, 0) / 3;
      const historicalAvg = monthlyIncomes.slice(0, -3).reduce((a, b) => a + b, 0) / (monthlyIncomes.length - 3);
      if (recentAvg > historicalAvg * 2) {
        fraudIndicators.push({
          type: 'SUDDEN_INCREASE',
          severity: 'HIGH',
          description: 'Recent income more than doubled compared to history'
        });
      }
      
      // Check for round number patterns (potential fabrication)
      const roundNumbers = monthlyIncomes.filter(income => income % 1000 === 0).length;
      if (roundNumbers > monthlyIncomes.length * 0.7) {
        fraudIndicators.push({
          type: 'ROUND_NUMBERS',
          severity: 'MEDIUM',
          description: 'Suspicious pattern of round numbers in income'
        });
      }
      
      // Check deposit frequency anomalies
      if (depositPatterns && depositStats) {
        const irregularDeposits = depositPatterns.filter(count => 
          Math.abs((count - depositStats.mean) / depositStats.stdDev) > 2
        ).length;
        
        if (irregularDeposits > depositPatterns.length * 0.3) {
          fraudIndicators.push({
            type: 'IRREGULAR_DEPOSITS',
            severity: 'MEDIUM',
            description: 'Inconsistent deposit patterns detected'
          });
        }
      }
      
      // Income verification confidence
      let verificationConfidence = 'HIGH';
      if (fraudIndicators.length > 0 || anomalies.length > 2) {
        verificationConfidence = 'MEDIUM';
      }
      if (fraudIndicators.filter(f => f.severity === 'HIGH').length > 0) {
        verificationConfidence = 'LOW';
      }
      
      // Generate insights
      const insights = [];
      if (incomeStats.trend > 0.1) {
        insights.push('Positive income growth trend detected');
      } else if (incomeStats.trend < -0.1) {
        insights.push('Declining income trend detected');
      }
      
      if (incomeStats.coefficientOfVariation < 0.15) {
        insights.push('Very stable income pattern');
      } else if (incomeStats.coefficientOfVariation > 0.35) {
        insights.push('Highly variable income pattern');
      }
      
      const processingTime = Date.now() - startTime;
      
      const response = {
        success: true,
        data: {
          stabilityScore,
          verificationConfidence,
          statistics: {
            meanIncome: parseFloat(incomeStats.mean.toFixed(2)),
            medianIncome: parseFloat(incomeStats.median.toFixed(2)),
            stdDeviation: parseFloat(incomeStats.stdDev.toFixed(2)),
            coefficientOfVariation: parseFloat(incomeStats.coefficientOfVariation.toFixed(3)),
            trend: incomeStats.trend > 0 ? 'INCREASING' : incomeStats.trend < -0.05 ? 'DECREASING' : 'STABLE',
            trendStrength: Math.abs(incomeStats.trend)
          },
          anomalies,
          fraudIndicators,
          stabilityFactors,
          insights,
          recommendation: stabilityScore >= 70 ? 'APPROVE' : 
                         stabilityScore >= 50 ? 'REVIEW' : 'CAUTION',
          analysisDate: new Date().toISOString()
        },
        metadata: {
          requestId,
          timestamp: new Date().toISOString(),
          processingTime,
          dataPoints: monthlyIncomes.length,
          modelVersion: 'StatisticalAnalysis_v1'
        }
      };
      
      logger.info(`Income pattern analysis completed - RequestID: ${requestId}, Score: ${stabilityScore}`);
      
      res.json(response);
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Calculate statistical metrics for an array of numbers
   */
  calculateStatistics(data) {
    const n = data.length;
    const mean = data.reduce((sum, val) => sum + val, 0) / n;
    
    // Calculate median
    const sorted = [...data].sort((a, b) => a - b);
    const median = n % 2 === 0 
      ? (sorted[n/2 - 1] + sorted[n/2]) / 2 
      : sorted[Math.floor(n/2)];
    
    // Calculate standard deviation
    const variance = data.reduce((sum, val) => sum + Math.pow(val - mean, 2), 0) / n;
    const stdDev = Math.sqrt(variance);
    
    // Coefficient of variation (normalized measure of dispersion)
    const coefficientOfVariation = mean !== 0 ? stdDev / mean : 0;
    
    // Calculate trend (simple linear regression slope)
    const xMean = (n - 1) / 2;
    const xySum = data.reduce((sum, val, i) => sum + (i * val), 0);
    const xSum = (n * (n - 1)) / 2;
    const ySum = data.reduce((sum, val) => sum + val, 0);
    const x2Sum = (n * (n - 1) * (2 * n - 1)) / 6;
    
    const trend = (n * xySum - xSum * ySum) / (n * x2Sum - xSum * xSum);
    
    return {
      mean,
      median,
      stdDev,
      coefficientOfVariation,
      trend
    };
  }
  
  /**
   * Calculate trend score based on income progression
   */
  calculateTrendScore(incomes) {
    if (incomes.length < 2) return 50;
    
    // Compare first half average to second half average
    const midpoint = Math.floor(incomes.length / 2);
    const firstHalf = incomes.slice(0, midpoint);
    const secondHalf = incomes.slice(midpoint);
    
    const firstAvg = firstHalf.reduce((a, b) => a + b, 0) / firstHalf.length;
    const secondAvg = secondHalf.reduce((a, b) => a + b, 0) / secondHalf.length;
    
    const changePercent = ((secondAvg - firstAvg) / firstAvg) * 100;
    
    // Convert to 0-100 score
    if (changePercent > 20) return 100;
    if (changePercent > 10) return 85;
    if (changePercent > 0) return 70;
    if (changePercent > -10) return 50;
    if (changePercent > -20) return 30;
    return 10;
  }
  
  // Private methods for real API calls (to be implemented)
  async fetchRealIncomeVerification(applicantId, employmentInfo, bankAccounts, consentToken) {
    throw new Error('Real income verification API not yet implemented');
  }
  
  async fetchRealEmploymentCheck(employerName, employeeName, employeeSSN) {
    throw new Error('Real employment verification API not yet implemented');
  }
  
  async fetchRealBankStatements(accountId) {
    throw new Error('Real bank statements API not yet implemented');
  }
}

module.exports = new IncomeController();