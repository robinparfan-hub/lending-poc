const logger = require('../utils/logger');

class MockDataService {
  /**
   * Generate identity verification based on name patterns
   */
  async generateIdentityVerification(firstName, lastName, ssn, dateOfBirth) {
    const verificationId = `IDV-${new Date().getFullYear()}-${String(Math.floor(Math.random() * 100000)).padStart(6, '0')}`;
    
    // Determine verification outcome based on name
    let status, confidenceScore, riskScore, kycStatus, amlStatus, requiresManualReview;
    const riskFactors = [];
    
    const lowerFirst = firstName.toLowerCase();
    const lowerLast = lastName.toLowerCase();
    
    // Test scenarios based on name
    if (lowerFirst === 'test' || lowerFirst === 'fail') {
      // Fails verification
      status = 'failed';
      confidenceScore = 20 + Math.random() * 30;
      riskScore = 70 + Math.random() * 30;
      kycStatus = 'failed';
      amlStatus = 'flagged';
      requiresManualReview = true;
      riskFactors.push(
        { type: 'identity', description: 'Unable to verify identity', severity: 'high' },
        { type: 'document', description: 'Document verification failed', severity: 'high' }
      );
    } else if (lowerLast === 'fraud' || lowerLast === 'alert') {
      // Triggers fraud alert
      status = 'fraud_alert';
      confidenceScore = 10 + Math.random() * 20;
      riskScore = 90 + Math.random() * 10;
      kycStatus = 'failed';
      amlStatus = 'flagged';
      requiresManualReview = true;
      riskFactors.push(
        { type: 'fraud', description: 'Potential fraud indicators detected', severity: 'critical' },
        { type: 'watchlist', description: 'Name matches watchlist', severity: 'high' },
        { type: 'velocity', description: 'Multiple applications detected', severity: 'medium' }
      );
    } else if (lowerFirst === 'john' && lowerLast === 'doe') {
      // Passes all checks perfectly
      status = 'verified';
      confidenceScore = 95 + Math.random() * 5;
      riskScore = 5 + Math.random() * 10;
      kycStatus = 'passed';
      amlStatus = 'clear';
      requiresManualReview = false;
    } else {
      // Random verification based on name hash
      const nameHash = this.hashCode(firstName + lastName);
      const outcome = nameHash % 100;
      
      if (outcome < 70) {
        // 70% pass
        status = 'verified';
        confidenceScore = 75 + Math.random() * 25;
        riskScore = 10 + Math.random() * 30;
        kycStatus = 'passed';
        amlStatus = 'clear';
        requiresManualReview = false;
      } else if (outcome < 90) {
        // 20% need review
        status = 'review_required';
        confidenceScore = 50 + Math.random() * 25;
        riskScore = 40 + Math.random() * 30;
        kycStatus = 'review';
        amlStatus = 'review';
        requiresManualReview = true;
        riskFactors.push(
          { type: 'verification', description: 'Additional verification needed', severity: 'medium' }
        );
      } else {
        // 10% fail
        status = 'failed';
        confidenceScore = 20 + Math.random() * 30;
        riskScore = 60 + Math.random() * 40;
        kycStatus = 'failed';
        amlStatus = 'flagged';
        requiresManualReview = true;
        riskFactors.push(
          { type: 'identity', description: 'Identity mismatch detected', severity: 'high' }
        );
      }
    }
    
    // Generate checks object
    const checks = {
      ssnValid: status !== 'failed' && status !== 'fraud_alert',
      addressValid: Math.random() > 0.1,
      phoneValid: Math.random() > 0.2,
      emailValid: Math.random() > 0.15,
      documentValid: status === 'verified' || (status === 'review_required' && Math.random() > 0.5),
      watchlistClear: status !== 'fraud_alert',
      pepCheck: false, // Politically Exposed Person
      sanctionsCheck: status === 'fraud_alert'
    };
    
    logger.debug(`Generated identity verification for ${firstName} ${lastName}: ${status}`);
    
    return {
      verificationId,
      status,
      confidenceScore: Math.floor(confidenceScore),
      riskScore: Math.floor(riskScore),
      kycStatus,
      amlStatus,
      checks,
      riskFactors,
      requiresManualReview,
      verificationMethod: 'LexisNexis',
      verificationDate: new Date().toISOString(),
      personalInfo: {
        name: `${firstName} ${lastName}`,
        ssn: `***-**-${ssn.slice(-4)}`,
        dateOfBirth: dateOfBirth,
        ageVerified: this.calculateAge(dateOfBirth) >= 18
      }
    };
  }
  
  /**
   * Generate fraud detection results
   */
  generateFraudDetection(applicationId, applicantData) {
    // Generate fraud score based on application ID pattern
    const idHash = this.hashCode(applicationId);
    let fraudScore, fraudRisk, recommendedAction, requiresReview;
    const indicators = [];
    
    if (applicationId.includes('FRAUD')) {
      // Test case for fraud
      fraudScore = 80 + Math.random() * 20;
      fraudRisk = 'high';
      recommendedAction = 'deny';
      requiresReview = true;
      indicators.push(
        { type: 'pattern', description: 'Suspicious application pattern detected', severity: 'high' },
        { type: 'velocity', description: 'Multiple applications from same device', severity: 'high' }
      );
    } else if (idHash % 100 < 80) {
      // 80% low risk
      fraudScore = 5 + Math.random() * 25;
      fraudRisk = 'low';
      recommendedAction = 'proceed';
      requiresReview = false;
    } else if (idHash % 100 < 95) {
      // 15% medium risk
      fraudScore = 30 + Math.random() * 30;
      fraudRisk = 'medium';
      recommendedAction = 'review';
      requiresReview = true;
      indicators.push(
        { type: 'velocity', description: 'Recent application activity detected', severity: 'low' }
      );
    } else {
      // 5% high risk
      fraudScore = 60 + Math.random() * 40;
      fraudRisk = 'high';
      recommendedAction = 'deny';
      requiresReview = true;
      indicators.push(
        { type: 'identity', description: 'Identity inconsistencies detected', severity: 'high' },
        { type: 'behavioral', description: 'Unusual application behavior', severity: 'medium' }
      );
    }
    
    return {
      fraudScore: Math.floor(fraudScore),
      fraudRisk,
      indicators,
      recommendedAction,
      requiresReview,
      applicationId,
      analysisDate: new Date().toISOString(),
      fraudModel: 'ML-Model-v2.1',
      confidenceLevel: Math.floor(80 + Math.random() * 20)
    };
  }
  
  /**
   * Validate SSN
   */
  validateSSN(ssn) {
    // Mock SSN validation logic
    const ssnDigits = ssn.replace(/-/g, '');
    
    // Check for invalid patterns
    const isValid = !(/^000|^666|^9/.test(ssnDigits) || ssnDigits === '123456789');
    
    // Check if SSN is issued (based on random for demo)
    const isIssued = isValid && Math.random() > 0.05;
    
    // Generate state of issue (mock)
    const states = ['CA', 'NY', 'TX', 'FL', 'IL', 'PA', 'OH', 'GA', 'NC', 'MI'];
    const stateOfIssue = isIssued ? states[parseInt(ssnDigits[0]) % states.length] : null;
    
    // Estimate issue date range (mock)
    const issueYearEstimate = isIssued 
      ? `${1950 + parseInt(ssnDigits.substring(3, 5))} - ${1952 + parseInt(ssnDigits.substring(3, 5))}`
      : null;
    
    return {
      ssn: `***-**-${ssn.slice(-4)}`,
      valid: isValid,
      issued: isIssued,
      stateOfIssue,
      issueYearEstimate,
      deceased: false,
      fraudAlert: !isValid || Math.random() < 0.02,
      verificationSource: 'SSA Database',
      verificationDate: new Date().toISOString()
    };
  }
  
  /**
   * Generate KYC check results
   */
  generateKYCCheck(firstName, lastName) {
    const name = `${firstName} ${lastName}`;
    const nameHash = this.hashCode(name);
    
    // Determine KYC outcome
    let status, riskLevel, requiresDocuments;
    const verifications = {
      identity: false,
      address: false,
      employment: false,
      income: false
    };
    
    if (firstName.toLowerCase() === 'test') {
      status = 'failed';
      riskLevel = 'high';
      requiresDocuments = true;
    } else if (lastName.toLowerCase() === 'fraud') {
      status = 'flagged';
      riskLevel = 'critical';
      requiresDocuments = true;
    } else if (nameHash % 100 < 75) {
      // 75% pass
      status = 'passed';
      riskLevel = 'low';
      requiresDocuments = false;
      verifications.identity = true;
      verifications.address = true;
      verifications.employment = Math.random() > 0.2;
      verifications.income = Math.random() > 0.3;
    } else if (nameHash % 100 < 90) {
      // 15% need documents
      status = 'pending_documents';
      riskLevel = 'medium';
      requiresDocuments = true;
      verifications.identity = Math.random() > 0.3;
      verifications.address = Math.random() > 0.4;
    } else {
      // 10% fail
      status = 'failed';
      riskLevel = 'high';
      requiresDocuments = true;
    }
    
    const requiredDocuments = requiresDocuments ? [
      'Government-issued ID',
      'Proof of address (utility bill or bank statement)',
      'Income verification (pay stubs or tax returns)'
    ] : [];
    
    return {
      applicantName: name,
      status,
      riskLevel,
      verifications,
      requiresDocuments,
      requiredDocuments,
      kycDate: new Date().toISOString(),
      expiryDate: new Date(Date.now() + 365 * 24 * 60 * 60 * 1000).toISOString(),
      complianceChecks: {
        pep: false,
        sanctions: status === 'flagged',
        adverseMedia: false,
        criminalRecord: false
      }
    };
  }
  
  // Utility methods
  
  hashCode(str) {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      const char = str.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return Math.abs(hash);
  }
  
  calculateAge(dateOfBirth) {
    const today = new Date();
    const birthDate = new Date(dateOfBirth);
    let age = today.getFullYear() - birthDate.getFullYear();
    const monthDiff = today.getMonth() - birthDate.getMonth();
    
    if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < birthDate.getDate())) {
      age--;
    }
    
    return age;
  }
}

module.exports = new MockDataService();