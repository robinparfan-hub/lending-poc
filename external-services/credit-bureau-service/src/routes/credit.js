const express = require('express');
const router = express.Router();
const { body, param, validationResult } = require('express-validator');
const creditController = require('../controllers/creditController');

// Validation middleware
const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(err => err.msg),
      errorCode: 'VALIDATION_ERROR'
    });
  }
  next();
};

/**
 * @swagger
 * /api/v1/credit-check:
 *   post:
 *     summary: Perform a comprehensive credit check
 *     tags: [Credit]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/CreditCheckRequest'
 *     responses:
 *       200:
 *         description: Credit check successful
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/CreditCheckResponse'
 *       400:
 *         description: Validation error
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/ErrorResponse'
 *       401:
 *         description: Unauthorized
 *       429:
 *         description: Rate limit exceeded
 */
router.post('/credit-check', [
  body('ssn')
    .matches(/^\d{3}-\d{2}-\d{4}$/)
    .withMessage('SSN must be in format XXX-XX-XXXX'),
  body('firstName')
    .notEmpty()
    .withMessage('First name is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('First name must be between 2 and 50 characters'),
  body('lastName')
    .notEmpty()
    .withMessage('Last name is required')
    .isLength({ min: 2, max: 50 })
    .withMessage('Last name must be between 2 and 50 characters'),
  body('dateOfBirth')
    .isISO8601()
    .withMessage('Date of birth must be a valid date')
    .custom(value => {
      const age = new Date().getFullYear() - new Date(value).getFullYear();
      if (age < 18 || age > 120) {
        throw new Error('Applicant must be between 18 and 120 years old');
      }
      return true;
    }),
  body('address.street').optional().isString(),
  body('address.city').optional().isString(),
  body('address.state').optional().isLength({ min: 2, max: 2 }),
  body('address.zipCode').optional().matches(/^\d{5}(-\d{4})?$/),
  validate
], creditController.performCreditCheck);

/**
 * @swagger
 * /api/v1/credit-report/{reportId}:
 *   get:
 *     summary: Retrieve a full credit report
 *     tags: [Credit]
 *     parameters:
 *       - in: path
 *         name: reportId
 *         required: true
 *         schema:
 *           type: string
 *         description: The credit report ID
 *     responses:
 *       200:
 *         description: Credit report retrieved successfully
 *       404:
 *         description: Report not found
 */
router.get('/credit-report/:reportId', [
  param('reportId')
    .notEmpty()
    .withMessage('Report ID is required')
    .matches(/^CR-\d{4}-\d{2}-\d{2}-\d{3}$/)
    .withMessage('Invalid report ID format'),
  validate
], creditController.getCreditReport);

/**
 * @swagger
 * /api/v1/credit-score:
 *   post:
 *     summary: Get just the credit score (lightweight)
 *     tags: [Credit]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - ssn
 *             properties:
 *               ssn:
 *                 type: string
 *                 pattern: '^\d{3}-\d{2}-\d{4}$'
 *                 example: '123-45-6789'
 *     responses:
 *       200:
 *         description: Credit score retrieved successfully
 */
router.post('/credit-score', [
  body('ssn')
    .matches(/^\d{3}-\d{2}-\d{4}$/)
    .withMessage('SSN must be in format XXX-XX-XXXX'),
  validate
], creditController.getCreditScore);

/**
 * @swagger
 * /api/v1/credit-history/{ssn}:
 *   get:
 *     summary: Get credit history for an SSN
 *     tags: [Credit]
 *     parameters:
 *       - in: path
 *         name: ssn
 *         required: true
 *         schema:
 *           type: string
 *         description: Social Security Number
 *     responses:
 *       200:
 *         description: Credit history retrieved successfully
 */
router.get('/credit-history/:ssn', [
  param('ssn')
    .matches(/^\d{3}-\d{2}-\d{4}$/)
    .withMessage('SSN must be in format XXX-XX-XXXX'),
  validate
], creditController.getCreditHistory);

module.exports = router;