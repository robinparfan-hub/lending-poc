const logger = require('../utils/logger');

const authentication = (req, res, next) => {
  // Skip auth for health endpoint
  if (req.path === '/health' || req.path === '/api-docs') {
    return next();
  }

  const apiKey = req.headers['x-api-key'];
  
  if (!apiKey) {
    logger.warn('Missing API key in request');
    return res.status(401).json({
      success: false,
      message: 'API key required',
      errorCode: 'MISSING_API_KEY'
    });
  }
  
  // In production, validate against real API keys
  if (process.env.MOCK_MODE === 'true') {
    // Accept any key in mock mode for testing
    if (apiKey !== process.env.API_KEY && !apiKey.startsWith('test_')) {
      logger.warn('Invalid API key attempted');
      return res.status(403).json({
        success: false,
        message: 'Invalid API key',
        errorCode: 'INVALID_API_KEY'
      });
    }
  }
  
  // Add user context from API key (in production, lookup from database)
  req.user = {
    apiKey: apiKey,
    clientId: 'mock_client_' + apiKey.slice(0, 8),
    permissions: ['send_email', 'send_sms', 'send_push']
  };
  
  next();
};

module.exports = authentication;