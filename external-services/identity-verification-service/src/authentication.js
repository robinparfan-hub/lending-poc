const logger = require('../utils/logger');

const authentication = (req, res, next) => {
  // Skip auth for health check and docs
  if (req.path === '/health' || req.path === '/metrics' || req.path.startsWith('/api-docs')) {
    return next();
  }

  // In mock mode, accept any API key
  if (process.env.MOCK_MODE === 'true') {
    const apiKey = req.headers['x-api-key'];
    if (!apiKey) {
      logger.warn('Missing API key in request');
      return res.status(401).json({
        success: false,
        message: 'API key is required',
        errorCode: 'MISSING_API_KEY'
      });
    }
    
    // Log the API key for debugging (remove in production)
    logger.debug(`Request authenticated with API key: ${apiKey.substring(0, 10)}...`);
    req.apiKey = apiKey;
    return next();
  }

  // Production authentication
  const apiKey = req.headers['x-api-key'];
  const validApiKeys = (process.env.VALID_API_KEYS || '').split(',');

  if (!apiKey || !validApiKeys.includes(apiKey)) {
    logger.warn(`Invalid API key attempt: ${apiKey ? apiKey.substring(0, 10) : 'none'}`);
    return res.status(401).json({
      success: false,
      message: 'Invalid API key',
      errorCode: 'UNAUTHORIZED'
    });
  }

  req.apiKey = apiKey;
  next();
};

module.exports = authentication;