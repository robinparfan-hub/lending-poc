const express = require('express');
const router = express.Router();
const { body, param, validationResult } = require('express-validator');
const documentController = require('../controllers/documentController');

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
 * /api/v1/upload-document:
 *   post:
 *     summary: Upload a document for processing
 *     tags: [Document Processing]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [documentType, fileName, content]
 *             properties:
 *               documentType:
 *                 type: string
 *                 enum: [bank_statement, pay_stub, tax_return, drivers_license, utility_bill]
 *               fileName:
 *                 type: string
 *               fileSize:
 *                 type: number
 *               mimeType:
 *                 type: string
 *               content:
 *                 type: string
 *                 description: Base64 encoded document content
 *               metadata:
 *                 type: object
 *     responses:
 *       200:
 *         description: Document uploaded successfully
 */
router.post('/upload-document', [
  body('documentType')
    .isIn(['bank_statement', 'pay_stub', 'tax_return', 'drivers_license', 'utility_bill', 'other'])
    .withMessage('Invalid document type'),
  body('fileName').notEmpty().withMessage('File name is required'),
  body('content').notEmpty().withMessage('Document content is required'),
  body('mimeType').optional().isIn(['application/pdf', 'image/png', 'image/jpeg', 'image/jpg']),
  validate
], documentController.uploadDocument);

/**
 * @swagger
 * /api/v1/extract-text:
 *   post:
 *     summary: Extract text/data from document
 *     tags: [Document Processing]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [documentId]
 *             properties:
 *               documentId:
 *                 type: string
 *               extractionType:
 *                 type: string
 *                 enum: [text, structured, form]
 *     responses:
 *       200:
 *         description: Text extracted successfully
 */
router.post('/extract-text', [
  body('documentId').notEmpty().withMessage('Document ID is required'),
  body('extractionType')
    .optional()
    .isIn(['text', 'structured', 'form'])
    .withMessage('Invalid extraction type'),
  validate
], documentController.extractText);

/**
 * @swagger
 * /api/v1/document-status/{documentId}:
 *   get:
 *     summary: Check document processing status
 *     tags: [Document Processing]
 *     parameters:
 *       - in: path
 *         name: documentId
 *         required: true
 *         schema:
 *           type: string
 *         description: The document ID
 *     responses:
 *       200:
 *         description: Document status retrieved
 *       404:
 *         description: Document not found
 */
router.get('/document-status/:documentId', [
  param('documentId').notEmpty().withMessage('Document ID is required'),
  validate
], documentController.getDocumentStatus);

/**
 * @swagger
 * /api/v1/validate-document:
 *   post:
 *     summary: Validate document authenticity
 *     tags: [Document Processing]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [documentId, documentType]
 *             properties:
 *               documentId:
 *                 type: string
 *               documentType:
 *                 type: string
 *     responses:
 *       200:
 *         description: Document validation completed
 */
router.post('/validate-document', [
  body('documentId').notEmpty().withMessage('Document ID is required'),
  body('documentType').notEmpty().withMessage('Document type is required'),
  validate
], documentController.validateDocument);

module.exports = router;