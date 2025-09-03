const express = require('express');
const router = express.Router();
const os = require('os');

/**
 * @swagger
 * /health:
 *   get:
 *     summary: Health check endpoint
 *     tags: [Health]
 *     security: []
 *     responses:
 *       200:
 *         description: Service is healthy
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 status:
 *                   type: string
 *                   example: healthy
 *                 service:
 *                   type: string
 *                   example: document-processing
 *                 version:
 *                   type: string
 *                   example: 1.0.0
 *                 uptime:
 *                   type: number
 *                   example: 3600
 *                 timestamp:
 *                   type: string
 *                   format: date-time
 */
router.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    service: 'document-processing',
    version: '1.0.0',
    uptime: process.uptime(),
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV,
    mockMode: process.env.MOCK_MODE === 'true'
  });
});

/**
 * @swagger
 * /metrics:
 *   get:
 *     summary: Service metrics endpoint
 *     tags: [Health]
 *     security: []
 *     responses:
 *       200:
 *         description: Service metrics
 */
router.get('/metrics', (req, res) => {
  const memUsage = process.memoryUsage();
  res.json({
    service: 'document-processing',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    memory: {
      rss: Math.round(memUsage.rss / 1024 / 1024) + ' MB',
      heapTotal: Math.round(memUsage.heapTotal / 1024 / 1024) + ' MB',
      heapUsed: Math.round(memUsage.heapUsed / 1024 / 1024) + ' MB',
      external: Math.round(memUsage.external / 1024 / 1024) + ' MB'
    },
    cpu: {
      usage: process.cpuUsage(),
      loadAverage: os.loadavg()
    },
    system: {
      platform: os.platform(),
      release: os.release(),
      totalMemory: Math.round(os.totalmem() / 1024 / 1024) + ' MB',
      freeMemory: Math.round(os.freemem() / 1024 / 1024) + ' MB'
    }
  });
});

module.exports = router;