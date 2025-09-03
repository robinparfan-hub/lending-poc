const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const identityController = require('../controllers/identityController');

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
 * /api/v1/verify-identity:
 *   post:
 *     summary: Perform identity verification and KYC check
 *     tags: [Identity Verification]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [firstName, lastName, ssn, dateOfBirth]
 *             properties:
 *               firstName:
 *                 type: string
 *               lastName:
 *                 type: string
 *               ssn:
 *                 type: string
 *               dateOfBirth:
 *                 type: string
 *                 format: date
 *               phone:
 *                 type: string
 *               email:
 *                 type: string
 *               address:
 *                 type: object
 *     responses:
 *       200:
 *         description: Identity verification successful
 */
router.post('/verify-identity', [
  body('firstName').notEmpty().withMessage('First name is required'),
  body('lastName').notEmpty().withMessage('Last name is required'),
  body('ssn').matches(/^\d{3}-\d{2}-\d{4}$/).withMessage('SSN must be in format XXX-XX-XXXX'),
  body('dateOfBirth').isISO8601().withMessage('Valid date of birth required'),
  body('email').optional().isEmail().withMessage('Valid email required'),
  body('phone').optional().matches(/^\+?1?\d{10,14}$/).withMessage('Valid phone number required'),
  validate
], identityController.verifyIdentity);

/**
 * @swagger
 * /api/v1/fraud-detection:
 *   post:
 *     summary: Check for potential fraud indicators
 *     tags: [Identity Verification]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [applicationId]
 *             properties:
 *               applicationId:
 *                 type: string
 *               ipAddress:
 *                 type: string
 *               deviceFingerprint:
 *                 type: string
 *               applicantData:
 *                 type: object
 *     responses:
 *       200:
 *         description: Fraud check completed
 */
router.post('/fraud-detection', [
  body('applicationId').notEmpty().withMessage('Application ID is required'),
  body('ipAddress').optional().isIP().withMessage('Valid IP address required'),
  validate
], identityController.fraudDetection);

/**
 * @swagger
 * /api/v1/ssn-validation:
 *   post:
 *     summary: Validate SSN
 *     tags: [Identity Verification]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [ssn]
 *             properties:
 *               ssn:
 *                 type: string
 *     responses:
 *       200:
 *         description: SSN validation completed
 */
router.post('/ssn-validation', [
  body('ssn').matches(/^\d{3}-\d{2}-\d{4}$/).withMessage('SSN must be in format XXX-XX-XXXX'),
  validate
], identityController.validateSSN);

/**
 * @swagger
 * /api/v1/kyc-check:
 *   post:
 *     summary: Perform KYC (Know Your Customer) check
 *     tags: [Identity Verification]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *     responses:
 *       200:
 *         description: KYC check completed
 */
router.post('/kyc-check', [
  body('firstName').notEmpty().withMessage('First name is required'),
  body('lastName').notEmpty().withMessage('Last name is required'),
  validate
], identityController.kycCheck);

module.exports = router;