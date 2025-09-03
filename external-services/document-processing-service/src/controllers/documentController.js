const logger = require('../utils/logger');
const mockDataService = require('../services/mockDataService');
const { v4: uuidv4 } = require('uuid');

// In-memory storage for documents (in production, use database)
const documents = new Map();

/**
 * Upload a document for processing
 */
const uploadDocument = async (req, res, next) => {
  try {
    const { documentType, fileName, fileSize, mimeType, content, metadata } = req.body;
    
    // Generate document ID
    const documentId = uuidv4();
    
    // Store document metadata
    const documentRecord = {
      id: documentId,
      documentType,
      fileName,
      fileSize: fileSize || Buffer.from(content, 'base64').length,
      mimeType: mimeType || 'application/pdf',
      status: 'uploaded',
      uploadedAt: new Date().toISOString(),
      metadata,
      processingSteps: {
        uploaded: true,
        extracted: false,
        validated: false
      }
    };
    
    documents.set(documentId, documentRecord);
    
    // Simulate async processing
    setTimeout(() => {
      const doc = documents.get(documentId);
      if (doc) {
        doc.status = 'ready_for_extraction';
        documents.set(documentId, doc);
      }
    }, 2000);
    
    logger.info(`Document uploaded: ${documentId}`);
    
    res.json({
      success: true,
      data: {
        documentId,
        status: 'uploaded',
        message: 'Document uploaded successfully',
        processingTime: '2-3 seconds',
        nextStep: 'extract-text'
      }
    });
  } catch (error) {
    logger.error('Upload document error:', error);
    next(error);
  }
};

/**
 * Extract text/data from document
 */
const extractText = async (req, res, next) => {
  try {
    const { documentId, extractionType = 'structured' } = req.body;
    
    const document = documents.get(documentId);
    
    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found',
        errorCode: 'DOCUMENT_NOT_FOUND'
      });
    }
    
    if (document.status === 'uploaded') {
      return res.status(400).json({
        success: false,
        message: 'Document still being processed. Please wait.',
        errorCode: 'PROCESSING_IN_PROGRESS'
      });
    }
    
    // Generate mock extracted data based on document type
    const extractedData = await mockDataService.generateExtractedData(
      document.documentType,
      extractionType
    );
    
    // Update document record
    document.extractedData = extractedData;
    document.processingSteps.extracted = true;
    document.status = 'extracted';
    document.extractedAt = new Date().toISOString();
    documents.set(documentId, document);
    
    logger.info(`Text extracted from document: ${documentId}`);
    
    res.json({
      success: true,
      data: {
        documentId,
        extractionType,
        extractedData,
        confidence: extractedData.confidence || 0.95,
        status: 'extracted'
      }
    });
  } catch (error) {
    logger.error('Extract text error:', error);
    next(error);
  }
};

/**
 * Get document processing status
 */
const getDocumentStatus = async (req, res, next) => {
  try {
    const { documentId } = req.params;
    
    const document = documents.get(documentId);
    
    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found',
        errorCode: 'DOCUMENT_NOT_FOUND'
      });
    }
    
    res.json({
      success: true,
      data: {
        documentId: document.id,
        status: document.status,
        documentType: document.documentType,
        fileName: document.fileName,
        uploadedAt: document.uploadedAt,
        extractedAt: document.extractedAt,
        validatedAt: document.validatedAt,
        processingSteps: document.processingSteps,
        validationResult: document.validationResult
      }
    });
  } catch (error) {
    logger.error('Get document status error:', error);
    next(error);
  }
};

/**
 * Validate document authenticity
 */
const validateDocument = async (req, res, next) => {
  try {
    const { documentId, documentType } = req.body;
    
    const document = documents.get(documentId);
    
    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found',
        errorCode: 'DOCUMENT_NOT_FOUND'
      });
    }
    
    // Generate mock validation result
    const validationResult = await mockDataService.validateDocument(
      documentType,
      document.fileName
    );
    
    // Update document record
    document.validationResult = validationResult;
    document.processingSteps.validated = true;
    document.status = validationResult.isValid ? 'validated' : 'validation_failed';
    document.validatedAt = new Date().toISOString();
    documents.set(documentId, document);
    
    logger.info(`Document validated: ${documentId}`);
    
    res.json({
      success: true,
      data: {
        documentId,
        validationResult,
        status: document.status
      }
    });
  } catch (error) {
    logger.error('Validate document error:', error);
    next(error);
  }
};

module.exports = {
  uploadDocument,
  extractText,
  getDocumentStatus,
  validateDocument
};