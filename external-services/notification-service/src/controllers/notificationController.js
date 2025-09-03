const logger = require('../utils/logger');
const mockDataService = require('../services/mockDataService');
const { v4: uuidv4 } = require('uuid');

// In-memory storage for notifications (in production, use database/queue)
const notifications = new Map();
const notificationHistory = [];

/**
 * Send email notification
 */
const sendEmail = async (req, res, next) => {
  try {
    const { to, cc, bcc, subject, body, html, templateId, templateData, priority, attachments } = req.body;
    
    const notificationId = uuidv4();
    
    // Mock sending email
    const result = await mockDataService.sendEmail({
      to,
      cc,
      bcc,
      subject,
      body,
      html,
      templateId,
      templateData,
      priority: priority || 'normal',
      attachments
    });
    
    // Store notification record
    const notification = {
      id: notificationId,
      type: 'email',
      recipient: to,
      subject,
      status: result.status,
      priority: priority || 'normal',
      createdAt: new Date().toISOString(),
      deliveredAt: result.status === 'delivered' ? new Date().toISOString() : null,
      metadata: {
        messageId: result.messageId,
        provider: 'mock_smtp'
      }
    };
    
    notifications.set(notificationId, notification);
    notificationHistory.push(notification);
    
    logger.info(`Email sent: ${notificationId} to ${to}`);
    
    res.json({
      success: true,
      data: {
        notificationId,
        status: result.status,
        messageId: result.messageId,
        deliveryTime: result.deliveryTime
      }
    });
  } catch (error) {
    logger.error('Send email error:', error);
    next(error);
  }
};

/**
 * Send SMS notification
 */
const sendSMS = async (req, res, next) => {
  try {
    const { to, message, priority } = req.body;
    
    const notificationId = uuidv4();
    
    // Mock sending SMS
    const result = await mockDataService.sendSMS({
      to,
      message,
      priority: priority || 'normal'
    });
    
    // Store notification record
    const notification = {
      id: notificationId,
      type: 'sms',
      recipient: to,
      message,
      status: result.status,
      priority: priority || 'normal',
      createdAt: new Date().toISOString(),
      deliveredAt: result.status === 'delivered' ? new Date().toISOString() : null,
      metadata: {
        messageId: result.messageId,
        provider: 'mock_sms',
        segments: result.segments
      }
    };
    
    notifications.set(notificationId, notification);
    notificationHistory.push(notification);
    
    logger.info(`SMS sent: ${notificationId} to ${to}`);
    
    res.json({
      success: true,
      data: {
        notificationId,
        status: result.status,
        messageId: result.messageId,
        segments: result.segments,
        deliveryTime: result.deliveryTime
      }
    });
  } catch (error) {
    logger.error('Send SMS error:', error);
    next(error);
  }
};

/**
 * Send push notification
 */
const sendPush = async (req, res, next) => {
  try {
    const { userId, deviceToken, title, message, data, badge, sound, priority } = req.body;
    
    const notificationId = uuidv4();
    
    // Mock sending push notification
    const result = await mockDataService.sendPush({
      userId,
      deviceToken,
      title,
      message,
      data,
      badge,
      sound,
      priority: priority || 'normal'
    });
    
    // Store notification record
    const notification = {
      id: notificationId,
      type: 'push',
      recipient: userId,
      title,
      message,
      status: result.status,
      priority: priority || 'normal',
      createdAt: new Date().toISOString(),
      deliveredAt: result.status === 'delivered' ? new Date().toISOString() : null,
      metadata: {
        messageId: result.messageId,
        provider: result.provider,
        platform: result.platform
      }
    };
    
    notifications.set(notificationId, notification);
    notificationHistory.push(notification);
    
    logger.info(`Push notification sent: ${notificationId} to user ${userId}`);
    
    res.json({
      success: true,
      data: {
        notificationId,
        status: result.status,
        messageId: result.messageId,
        platform: result.platform,
        deliveryTime: result.deliveryTime
      }
    });
  } catch (error) {
    logger.error('Send push error:', error);
    next(error);
  }
};

/**
 * Send batch notifications
 */
const sendBatch = async (req, res, next) => {
  try {
    const { notifications: batchNotifications } = req.body;
    
    const batchId = uuidv4();
    const results = [];
    
    for (const notification of batchNotifications) {
      const notificationId = uuidv4();
      let result;
      
      switch (notification.type) {
        case 'email':
          result = await mockDataService.sendEmail(notification.payload);
          break;
        case 'sms':
          result = await mockDataService.sendSMS(notification.payload);
          break;
        case 'push':
          result = await mockDataService.sendPush(notification.payload);
          break;
        default:
          result = { status: 'failed', error: 'Unknown notification type' };
      }
      
      results.push({
        notificationId,
        type: notification.type,
        status: result.status,
        messageId: result.messageId
      });
      
      // Store each notification
      const notificationRecord = {
        id: notificationId,
        batchId,
        type: notification.type,
        status: result.status,
        payload: notification.payload,
        createdAt: new Date().toISOString()
      };
      
      notifications.set(notificationId, notificationRecord);
      notificationHistory.push(notificationRecord);
    }
    
    logger.info(`Batch notifications sent: ${batchId} (${results.length} items)`);
    
    res.json({
      success: true,
      data: {
        batchId,
        totalCount: batchNotifications.length,
        successCount: results.filter(r => r.status === 'delivered').length,
        failedCount: results.filter(r => r.status === 'failed').length,
        results
      }
    });
  } catch (error) {
    logger.error('Send batch error:', error);
    next(error);
  }
};

/**
 * Get notification status
 */
const getNotificationStatus = async (req, res, next) => {
  try {
    const { notificationId } = req.params;
    
    const notification = notifications.get(notificationId);
    
    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found',
        errorCode: 'NOTIFICATION_NOT_FOUND'
      });
    }
    
    // Simulate status updates
    if (notification.status === 'sent' && Math.random() > 0.3) {
      notification.status = 'delivered';
      notification.deliveredAt = new Date().toISOString();
      notifications.set(notificationId, notification);
    }
    
    res.json({
      success: true,
      data: {
        id: notification.id,
        type: notification.type,
        status: notification.status,
        recipient: notification.recipient,
        createdAt: notification.createdAt,
        deliveredAt: notification.deliveredAt,
        metadata: notification.metadata
      }
    });
  } catch (error) {
    logger.error('Get notification status error:', error);
    next(error);
  }
};

/**
 * Get notification history
 */
const getNotificationHistory = async (req, res, next) => {
  try {
    const { userId, type, status, from, to, limit = 20 } = req.query;
    
    let filtered = [...notificationHistory];
    
    // Apply filters
    if (userId) {
      filtered = filtered.filter(n => n.recipient === userId);
    }
    if (type) {
      filtered = filtered.filter(n => n.type === type);
    }
    if (status) {
      filtered = filtered.filter(n => n.status === status);
    }
    if (from) {
      const fromDate = new Date(from);
      filtered = filtered.filter(n => new Date(n.createdAt) >= fromDate);
    }
    if (to) {
      const toDate = new Date(to);
      filtered = filtered.filter(n => new Date(n.createdAt) <= toDate);
    }
    
    // Sort by date (newest first) and apply limit
    filtered.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
    const results = filtered.slice(0, parseInt(limit));
    
    res.json({
      success: true,
      data: {
        totalCount: filtered.length,
        returnedCount: results.length,
        notifications: results
      }
    });
  } catch (error) {
    logger.error('Get notification history error:', error);
    next(error);
  }
};

/**
 * Get available templates
 */
const getTemplates = async (req, res, next) => {
  try {
    const { type } = req.query;
    
    const templates = await mockDataService.getTemplates(type);
    
    res.json({
      success: true,
      data: {
        templates
      }
    });
  } catch (error) {
    logger.error('Get templates error:', error);
    next(error);
  }
};

module.exports = {
  sendEmail,
  sendSMS,
  sendPush,
  sendBatch,
  getNotificationStatus,
  getNotificationHistory,
  getTemplates
};