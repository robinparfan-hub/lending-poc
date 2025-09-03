const { v4: uuidv4 } = require('uuid');
const logger = require('../utils/logger');
const mockDataService = require('../services/mockDataService');

class CreditController {
  /**
   * Perform a comprehensive credit check
   */
  async performCreditCheck(req, res, next) {
    try {
      const startTime = Date.now();
      const requestId = uuidv4();
      
      logger.info(`Credit check request received - RequestID: ${requestId}`);
      
      const { ssn, firstName, lastName, dateOfBirth, address } = req.body;
      
      // Simulate processing delay
      if (process.env.MOCK_MODE === 'true') {
        await new Promise(resolve => setTimeout(resolve, Math.random() * 2000 + 500));
      }
      
      // Get mock or real data
      const creditData = process.env.MOCK_MODE === 'true' 
        ? await mockDataService.generateCreditReport(ssn, firstName, lastName)
        : await this.fetchRealCreditData(ssn, firstName, lastName, dateOfBirth, address);
      
      const processingTime = Date.now() - startTime;
      
      const response = {
        success: true,
        data: creditData,
        metadata: {
          requestId,
          timestamp: new Date().toISOString(),
          processingTime
        }
      };
      
      logger.info(`Credit check completed - RequestID: ${requestId}, Score: ${creditData.creditScore}`);
      
      res.json(response);
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Get a full credit report by ID
   */
  async getCreditReport(req, res, next) {
    try {
      const { reportId } = req.params;
      
      logger.info(`Credit report request - ReportID: ${reportId}`);
      
      // In mock mode, generate a detailed report
      if (process.env.MOCK_MODE === 'true') {
        const report = await mockDataService.getDetailedCreditReport(reportId);
        
        if (!report) {
          return res.status(404).json({
            success: false,
            message: 'Credit report not found',
            errorCode: 'NOT_FOUND'
          });
        }
        
        res.json({
          success: true,
          data: report,
          metadata: {
            requestId: uuidv4(),
            timestamp: new Date().toISOString()
          }
        });
      } else {
        // Real API implementation
        const report = await this.fetchRealCreditReport(reportId);
        res.json({
          success: true,
          data: report
        });
      }
    } catch (error) {
      next(error);
    }
  }
  
  /**
   * Get just the credit score (lightweight)
   */
  async getCreditScore(req, res, next) {
    try {
      const { ssn } = req.body;
      
      logger.info(`Credit score request for SSN ending in ${ssn.slice(-4)}`);
      
      const score = process.env.MOCK_MODE === 'true'
        ? mockDataService.generateCreditScore(ssn)
        : await this.fetchRealCreditScore(ssn);
      
      res.json({
        success: true,
        data: {
          score: score.score,
          bureau: score.bureau,
          asOfDate: new Date().toISOString().split('T')[0]
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
   * Get credit history
   */
  async getCreditHistory(req, res, next) {
    try {
      const { ssn } = req.params;
      
      logger.info(`Credit history request for SSN ending in ${ssn.slice(-4)}`);
      
      const history = process.env.MOCK_MODE === 'true'
        ? await mockDataService.generateCreditHistory(ssn)
        : await this.fetchRealCreditHistory(ssn);
      
      res.json({
        success: true,
        data: history,
        metadata: {
          requestId: uuidv4(),
          timestamp: new Date().toISOString()
        }
      });
    } catch (error) {
      next(error);
    }
  }
  
  // Private methods for real API calls (to be implemented)
  async fetchRealCreditData(ssn, firstName, lastName, dateOfBirth, address) {
    throw new Error('Real credit bureau API not yet implemented');
  }
  
  async fetchRealCreditReport(reportId) {
    throw new Error('Real credit bureau API not yet implemented');
  }
  
  async fetchRealCreditScore(ssn) {
    throw new Error('Real credit bureau API not yet implemented');
  }
  
  async fetchRealCreditHistory(ssn) {
    throw new Error('Real credit bureau API not yet implemented');
  }
}

module.exports = new CreditController();