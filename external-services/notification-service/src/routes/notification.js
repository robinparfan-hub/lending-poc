const express = require('express');
const router = express.Router();
const { body, param, query, validationResult } = require('express-validator');
const notificationController = require('../controllers/notificationController');

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
 * /api/v1/send-email:
 *   post:
 *     summary: Send an email notification
 *     tags: [Email]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [to, subject, body]
 *             properties:
 *               to:
 *                 type: string
 *                 format: email
 *               cc:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: email
 *               bcc:
 *                 type: array
 *                 items:
 *                   type: string
 *                   format: email
 *               subject:
 *                 type: string
 *               body:
 *                 type: string
 *               html:
 *                 type: boolean
 *               templateId:
 *                 type: string
 *               templateData:
 *                 type: object
 *               priority:
 *                 type: string
 *                 enum: [high, normal, low]
 *               attachments:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     filename:
 *                       type: string
 *                     content:
 *                       type: string
 *                     contentType:
 *                       type: string
 *     responses:
 *       200:
 *         description: Email sent successfully
 */
router.post('/send-email', [
  body('to').isEmail().withMessage('Valid email address required'),
  body('cc').optional().isArray().withMessage('CC must be an array'),
  body('cc.*').optional().isEmail().withMessage('Invalid email in CC'),
  body('bcc').optional().isArray().withMessage('BCC must be an array'),
  body('bcc.*').optional().isEmail().withMessage('Invalid email in BCC'),
  body('subject').notEmpty().withMessage('Subject is required'),
  body('body').notEmpty().withMessage('Body is required'),
  body('html').optional().isBoolean(),
  body('priority').optional().isIn(['high', 'normal', 'low']),
  validate
], notificationController.sendEmail);

/**
 * @swagger
 * /api/v1/send-sms:
 *   post:
 *     summary: Send an SMS notification
 *     tags: [SMS]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [to, message]
 *             properties:
 *               to:
 *                 type: string
 *                 description: Phone number with country code
 *               message:
 *                 type: string
 *                 maxLength: 160
 *               priority:
 *                 type: string
 *                 enum: [high, normal, low]
 *     responses:
 *       200:
 *         description: SMS sent successfully
 */
router.post('/send-sms', [
  body('to')
    .matches(/^\+[1-9]\d{1,14}$/)
    .withMessage('Valid phone number with country code required'),
  body('message')
    .notEmpty()
    .withMessage('Message is required')
    .isLength({ max: 160 })
    .withMessage('Message must be 160 characters or less'),
  body('priority').optional().isIn(['high', 'normal', 'low']),
  validate
], notificationController.sendSMS);

/**
 * @swagger
 * /api/v1/send-push:
 *   post:
 *     summary: Send a push notification
 *     tags: [Push]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [userId, title, message]
 *             properties:
 *               userId:
 *                 type: string
 *               deviceToken:
 *                 type: string
 *               title:
 *                 type: string
 *               message:
 *                 type: string
 *               data:
 *                 type: object
 *               badge:
 *                 type: number
 *               sound:
 *                 type: string
 *               priority:
 *                 type: string
 *                 enum: [high, normal, low]
 *     responses:
 *       200:
 *         description: Push notification sent successfully
 */
router.post('/send-push', [
  body('userId').notEmpty().withMessage('User ID is required'),
  body('title').notEmpty().withMessage('Title is required'),
  body('message').notEmpty().withMessage('Message is required'),
  body('badge').optional().isInt({ min: 0 }),
  body('priority').optional().isIn(['high', 'normal', 'low']),
  validate
], notificationController.sendPush);

/**
 * @swagger
 * /api/v1/send-batch:
 *   post:
 *     summary: Send batch notifications
 *     tags: [Batch]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [notifications]
 *             properties:
 *               notifications:
 *                 type: array
 *                 items:
 *                   type: object
 *                   properties:
 *                     type:
 *                       type: string
 *                       enum: [email, sms, push]
 *                     payload:
 *                       type: object
 *     responses:
 *       200:
 *         description: Batch notifications queued
 */
router.post('/send-batch', [
  body('notifications').isArray({ min: 1, max: 100 }).withMessage('Notifications array required (1-100 items)'),
  body('notifications.*.type').isIn(['email', 'sms', 'push']).withMessage('Invalid notification type'),
  body('notifications.*.payload').notEmpty().withMessage('Payload required for each notification'),
  validate
], notificationController.sendBatch);

/**
 * @swagger
 * /api/v1/notification-status/{notificationId}:
 *   get:
 *     summary: Get notification status
 *     tags: [Status]
 *     parameters:
 *       - in: path
 *         name: notificationId
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Notification status retrieved
 *       404:
 *         description: Notification not found
 */
router.get('/notification-status/:notificationId', [
  param('notificationId').notEmpty().withMessage('Notification ID is required'),
  validate
], notificationController.getNotificationStatus);

/**
 * @swagger
 * /api/v1/notification-history:
 *   get:
 *     summary: Get notification history
 *     tags: [History]
 *     parameters:
 *       - in: query
 *         name: userId
 *         schema:
 *           type: string
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [email, sms, push]
 *       - in: query
 *         name: status
 *         schema:
 *           type: string
 *           enum: [sent, delivered, failed, pending]
 *       - in: query
 *         name: from
 *         schema:
 *           type: string
 *           format: date
 *       - in: query
 *         name: to
 *         schema:
 *           type: string
 *           format: date
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *           minimum: 1
 *           maximum: 100
 *           default: 20
 *     responses:
 *       200:
 *         description: Notification history retrieved
 */
router.get('/notification-history', [
  query('userId').optional().notEmpty(),
  query('type').optional().isIn(['email', 'sms', 'push']),
  query('status').optional().isIn(['sent', 'delivered', 'failed', 'pending']),
  query('from').optional().isISO8601(),
  query('to').optional().isISO8601(),
  query('limit').optional().isInt({ min: 1, max: 100 }),
  validate
], notificationController.getNotificationHistory);

/**
 * @swagger
 * /api/v1/templates:
 *   get:
 *     summary: Get available notification templates
 *     tags: [Templates]
 *     parameters:
 *       - in: query
 *         name: type
 *         schema:
 *           type: string
 *           enum: [email, sms, push]
 *     responses:
 *       200:
 *         description: Templates retrieved successfully
 */
router.get('/templates', [
  query('type').optional().isIn(['email', 'sms', 'push']),
  validate
], notificationController.getTemplates);

module.exports = router;