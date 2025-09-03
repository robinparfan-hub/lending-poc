const logger = require('../utils/logger');
const { v4: uuidv4 } = require('uuid');

/**
 * Mock email sending
 */
const sendEmail = async (data) => {
  const { to, subject, priority } = data;
  
  logger.info(`Mock sending email to ${to}: ${subject}`);
  
  // Simulate processing delay
  await new Promise(resolve => setTimeout(resolve, 500));
  
  // Deterministic failure based on email patterns
  const lowerEmail = to.toLowerCase();
  
  if (lowerEmail.includes('fail') || lowerEmail.includes('bounce')) {
    return {
      status: 'failed',
      error: 'Email bounced',
      messageId: uuidv4(),
      deliveryTime: null
    };
  }
  
  if (lowerEmail.includes('delay')) {
    return {
      status: 'pending',
      messageId: uuidv4(),
      deliveryTime: '5-10 minutes'
    };
  }
  
  // Default: successful delivery
  return {
    status: 'delivered',
    messageId: `msg_${uuidv4()}`,
    deliveryTime: '1-2 seconds',
    provider: 'mock_smtp',
    timestamp: new Date().toISOString()
  };
};

/**
 * Mock SMS sending
 */
const sendSMS = async (data) => {
  const { to, message } = data;
  
  logger.info(`Mock sending SMS to ${to}: ${message.substring(0, 50)}...`);
  
  // Simulate processing delay
  await new Promise(resolve => setTimeout(resolve, 300));
  
  // Calculate segments (160 chars per segment)
  const segments = Math.ceil(message.length / 160);
  
  // Deterministic failure based on phone patterns
  if (to.endsWith('0000')) {
    return {
      status: 'failed',
      error: 'Invalid phone number',
      messageId: uuidv4(),
      segments,
      deliveryTime: null
    };
  }
  
  if (to.endsWith('9999')) {
    return {
      status: 'failed',
      error: 'Carrier rejected message',
      messageId: uuidv4(),
      segments,
      deliveryTime: null
    };
  }
  
  // Default: successful delivery
  return {
    status: 'delivered',
    messageId: `sms_${uuidv4()}`,
    segments,
    deliveryTime: '1-3 seconds',
    provider: 'mock_sms',
    carrier: 'Mock Wireless',
    timestamp: new Date().toISOString()
  };
};

/**
 * Mock push notification sending
 */
const sendPush = async (data) => {
  const { userId, title, message, deviceToken } = data;
  
  logger.info(`Mock sending push to user ${userId}: ${title}`);
  
  // Simulate processing delay
  await new Promise(resolve => setTimeout(resolve, 200));
  
  // Determine platform based on device token pattern or random
  const platform = deviceToken ? 
    (deviceToken.startsWith('ios_') ? 'ios' : 'android') : 
    (Math.random() > 0.5 ? 'ios' : 'android');
  
  // Deterministic failure based on user ID patterns
  if (userId.includes('inactive')) {
    return {
      status: 'failed',
      error: 'User has no active devices',
      messageId: uuidv4(),
      platform,
      deliveryTime: null
    };
  }
  
  if (userId.includes('disabled')) {
    return {
      status: 'failed',
      error: 'Push notifications disabled',
      messageId: uuidv4(),
      platform,
      deliveryTime: null
    };
  }
  
  // Default: successful delivery
  return {
    status: 'delivered',
    messageId: `push_${uuidv4()}`,
    platform,
    provider: platform === 'ios' ? 'APNS' : 'FCM',
    deliveryTime: '0.5-1 seconds',
    timestamp: new Date().toISOString()
  };
};

/**
 * Get notification templates
 */
const getTemplates = async (type) => {
  logger.info(`Fetching templates for type: ${type || 'all'}`);
  
  const emailTemplates = [
    {
      id: 'welcome_email',
      name: 'Welcome Email',
      type: 'email',
      subject: 'Welcome to Lending POC',
      variables: ['firstName', 'lastName', 'accountNumber'],
      description: 'Sent when a new user registers'
    },
    {
      id: 'loan_approved',
      name: 'Loan Approved',
      type: 'email',
      subject: 'Your Loan Has Been Approved!',
      variables: ['firstName', 'loanAmount', 'interestRate', 'term'],
      description: 'Sent when a loan application is approved'
    },
    {
      id: 'loan_rejected',
      name: 'Loan Rejected',
      type: 'email',
      subject: 'Update on Your Loan Application',
      variables: ['firstName', 'reason', 'nextSteps'],
      description: 'Sent when a loan application is rejected'
    },
    {
      id: 'payment_reminder',
      name: 'Payment Reminder',
      type: 'email',
      subject: 'Payment Due Reminder',
      variables: ['firstName', 'amount', 'dueDate', 'paymentLink'],
      description: 'Sent before payment due date'
    },
    {
      id: 'document_request',
      name: 'Document Request',
      type: 'email',
      subject: 'Additional Documents Required',
      variables: ['firstName', 'documentList', 'deadline'],
      description: 'Sent when additional documents are needed'
    }
  ];
  
  const smsTemplates = [
    {
      id: 'verification_code',
      name: 'Verification Code',
      type: 'sms',
      template: 'Your verification code is {{code}}. Valid for 10 minutes.',
      variables: ['code'],
      description: 'SMS verification code'
    },
    {
      id: 'payment_received',
      name: 'Payment Received',
      type: 'sms',
      template: 'Payment of ${{amount}} received. New balance: ${{balance}}',
      variables: ['amount', 'balance'],
      description: 'Payment confirmation SMS'
    },
    {
      id: 'loan_status_update',
      name: 'Loan Status Update',
      type: 'sms',
      template: 'Your loan application status: {{status}}. Check app for details.',
      variables: ['status'],
      description: 'Loan status update SMS'
    }
  ];
  
  const pushTemplates = [
    {
      id: 'new_message',
      name: 'New Message',
      type: 'push',
      title: 'New Message',
      body: 'You have a new message from {{sender}}',
      variables: ['sender'],
      description: 'New message notification'
    },
    {
      id: 'loan_update',
      name: 'Loan Update',
      type: 'push',
      title: 'Loan Application Update',
      body: 'Your loan application status has been updated',
      variables: [],
      description: 'Loan status change notification'
    },
    {
      id: 'payment_due',
      name: 'Payment Due',
      type: 'push',
      title: 'Payment Due Soon',
      body: 'Payment of ${{amount}} due on {{date}}',
      variables: ['amount', 'date'],
      description: 'Payment reminder push notification'
    }
  ];
  
  // Filter templates based on type
  let templates = [];
  
  if (!type || type === 'email') {
    templates = templates.concat(emailTemplates);
  }
  if (!type || type === 'sms') {
    templates = templates.concat(smsTemplates);
  }
  if (!type || type === 'push') {
    templates = templates.concat(pushTemplates);
  }
  
  return templates;
};

module.exports = {
  sendEmail,
  sendSMS,
  sendPush,
  getTemplates
};