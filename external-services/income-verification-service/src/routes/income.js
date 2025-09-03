const express = require('express');
const router = express.Router();
const { body, validationResult } = require('express-validator');
const incomeController = require('../controllers/incomeController');

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
 * /api/v1/verify-income:
 *   post:
 *     summary: Verify income from multiple sources
 *     tags: [Income Verification]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/IncomeVerificationRequest'
 *     responses:
 *       200:
 *         description: Income verification successful
 *         content:
 *           application/json:
 *             schema:
 *               $ref: '#/components/schemas/IncomeVerificationResponse'
 *       400:
 *         description: Validation error
 *       401:
 *         description: Unauthorized
 *       429:
 *         description: Rate limit exceeded
 */
router.post('/verify-income', [
  body('applicantId')
    .notEmpty()
    .withMessage('Applicant ID is required'),
  body('employmentInfo.employerName')
    .notEmpty()
    .withMessage('Employer name is required'),
  body('employmentInfo.position')
    .notEmpty()
    .withMessage('Position is required'),
  body('employmentInfo.statedIncome')
    .isNumeric()
    .withMessage('Stated income must be a number')
    .isFloat({ min: 0 })
    .withMessage('Stated income must be positive'),
  body('employmentInfo.startDate')
    .optional()
    .isISO8601()
    .withMessage('Start date must be a valid date'),
  body('bankAccounts')
    .optional()
    .isArray()
    .withMessage('Bank accounts must be an array'),
  validate
], incomeController.verifyIncome);

/**
 * @swagger
 * /api/v1/employment-check:
 *   post:
 *     summary: Verify employment status
 *     tags: [Income Verification]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/EmploymentCheckRequest'
 *     responses:
 *       200:
 *         description: Employment verification successful
 *       400:
 *         description: Validation error
 */
router.post('/employment-check', [
  body('employerName')
    .notEmpty()
    .withMessage('Employer name is required'),
  body('employeeName')
    .notEmpty()
    .withMessage('Employee name is required'),
  body('employeeSSN')
    .optional()
    .matches(/^\*{3}-\*{2}-\d{4}$/)
    .withMessage('SSN must be partially masked (***-**-XXXX)'),
  validate
], incomeController.checkEmployment);

/**
 * @swagger
 * /api/v1/calculate-dti:
 *   post:
 *     summary: Calculate debt-to-income ratio
 *     tags: [Income Verification]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             $ref: '#/components/schemas/DTICalculationRequest'
 *     responses:
 *       200:
 *         description: DTI calculation successful
 *       400:
 *         description: Validation error
 */
router.post('/calculate-dti', [
  body('monthlyIncome')
    .isNumeric()
    .withMessage('Monthly income must be a number')
    .isFloat({ min: 0 })
    .withMessage('Monthly income must be positive'),
  body('monthlyDebts')
    .isObject()
    .withMessage('Monthly debts must be an object'),
  body('monthlyDebts.mortgage')
    .optional()
    .isNumeric()
    .withMessage('Mortgage must be a number'),
  body('monthlyDebts.autoLoan')
    .optional()
    .isNumeric()
    .withMessage('Auto loan must be a number'),
  body('monthlyDebts.creditCards')
    .optional()
    .isNumeric()
    .withMessage('Credit cards must be a number'),
  body('monthlyDebts.studentLoans')
    .optional()
    .isNumeric()
    .withMessage('Student loans must be a number'),
  body('monthlyDebts.otherDebts')
    .optional()
    .isNumeric()
    .withMessage('Other debts must be a number'),
  validate
], incomeController.calculateDTI);

/**
 * @swagger
 * /api/v1/bank-statements/{accountId}:
 *   get:
 *     summary: Retrieve bank statements for income verification
 *     tags: [Income Verification]
 *     parameters:
 *       - in: path
 *         name: accountId
 *         required: true
 *         schema:
 *           type: string
 *         description: The bank account ID
 *     responses:
 *       200:
 *         description: Bank statements retrieved successfully
 *       404:
 *         description: Account not found
 */
router.get('/bank-statements/:accountId', incomeController.getBankStatements);

module.exports = router;