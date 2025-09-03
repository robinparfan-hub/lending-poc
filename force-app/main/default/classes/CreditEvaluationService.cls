/**
 * @description Service for handling credit evaluations and scoring
 * @author Lending POC Team
 * @date 2025-09-03
 */
public with sharing class CreditEvaluationService {
    
    // Configuration from Custom Labels for runtime control
    private static Boolean USE_MOCK_DATA {
        get {
            if (USE_MOCK_DATA == null) {
                String labelValue = System.Label.Use_Mock_Data;
                USE_MOCK_DATA = (labelValue != null && labelValue.equalsIgnoreCase('true'));
            }
            return USE_MOCK_DATA;
        }
        set;
    }
    private static final String SERVICE_NAME = 'CreditEvaluationService';
    
    /**
     * @description Evaluate credit score for an applicant
     * @param applicantId ID of the applicant
     * @return ServiceResponse Credit evaluation result
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse evaluateCreditScoreById(String applicantId) {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicantId', applicantId);
        return evaluateCreditScore(request);
    }
    
    /**
     * @description Evaluate credit score for an applicant (full request)
     * @param request Service request containing applicant information
     * @return ServiceResponse Credit evaluation result
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse evaluateCreditScore(ServiceRequest request) {
        try {
            // Input validation
            validateCreditScoreRequest(request);
            
            // Log service call
            System.debug('CreditEvaluationService.evaluateCreditScore called with request: ' + request);
            
            // Execute business logic
            if (USE_MOCK_DATA) {
                return getMockCreditResponse(request);
            } else {
                return getAPICreditResponse(request);
            }
        } catch (ServiceException e) {
            return ServiceResponse.createError(e.getMessage(), e.getErrorCode());
        } catch (Exception e) {
            System.debug('Unexpected error in evaluateCreditScore: ' + e.getMessage());
            return ServiceResponse.createError('Credit evaluation failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Get full credit report for an application
     * @param applicationId ID of the loan application
     * @return ServiceResponse Credit report data
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse getCreditReportById(String applicationId) {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicationId', applicationId);
        return getCreditReport(request);
    }
    
    /**
     * @description Get full credit report for an application (full request)
     * @param request Service request containing application information
     * @return ServiceResponse Credit report data
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse getCreditReport(ServiceRequest request) {
        try {
            // Input validation
            validateCreditReportRequest(request);
            
            // Log service call
            System.debug('CreditEvaluationService.getCreditReport called with request: ' + request);
            
            // Execute business logic
            if (USE_MOCK_DATA) {
                return getMockCreditReportResponse(request);
            } else {
                return getAPICreditReportResponse(request);
            }
        } catch (ServiceException e) {
            return ServiceResponse.createError(e.getMessage(), e.getErrorCode());
        } catch (Exception e) {
            System.debug('Unexpected error in getCreditReport: ' + e.getMessage());
            return ServiceResponse.createError('Credit report retrieval failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Calculate credit risk level based on score and loan type
     * @param creditScore Credit score value
     * @param loanType Type of loan being requested
     * @return ServiceResponse Risk calculation result
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse calculateCreditRiskByParams(Decimal creditScore, String loanType) {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('creditScore', creditScore);
        request.setParameter('loanType', loanType);
        return calculateCreditRisk(request);
    }
    
    /**
     * @description Calculate credit risk level (full request)
     * @param request Service request containing credit score and loan type
     * @return ServiceResponse Risk calculation result
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse calculateCreditRisk(ServiceRequest request) {
        try {
            // Input validation
            validateRiskCalculationRequest(request);
            
            // Log service call
            System.debug('CreditEvaluationService.calculateCreditRisk called with request: ' + request);
            
            // Calculate risk based on credit score (real calculation, not mock)
            Decimal creditScore = (Decimal)request.getParameter('creditScore');
            String loanType = request.getStringParameter('loanType');
            
            Map<String, Object> data = new Map<String, Object>();
            data.put('creditScore', creditScore);
            data.put('loanType', loanType);
            
            // Determine risk level based on credit score
            String riskLevel = determineRiskLevel(creditScore);
            data.put('riskLevel', riskLevel);
            
            // Calculate risk percentage
            Decimal riskPercentage = calculateRiskPercentage(creditScore, loanType);
            data.put('riskPercentage', riskPercentage);
            
            // Determine recommended interest rate adjustment
            Decimal rateAdjustment = calculateRateAdjustment(riskLevel);
            data.put('rateAdjustment', rateAdjustment);
            
            return ServiceResponse.createSuccess(data);
            
        } catch (ServiceException e) {
            return ServiceResponse.createError(e.getMessage(), e.getErrorCode());
        } catch (Exception e) {
            System.debug('Unexpected error in calculateCreditRisk: ' + e.getMessage());
            return ServiceResponse.createError('Risk calculation failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Validate credit score request parameters
     * @param request Service request to validate
     */
    private static void validateCreditScoreRequest(ServiceRequest request) {
        if (request == null) {
            throw new ServiceException('Request cannot be null', ServiceException.VALIDATION_ERROR);
        }
        
        String applicantId = request.getStringParameter('applicantId');
        if (String.isBlank(applicantId)) {
            throw new ServiceException('Applicant ID is required', ServiceException.VALIDATION_ERROR);
        }
    }
    
    /**
     * @description Validate credit report request parameters
     * @param request Service request to validate
     */
    private static void validateCreditReportRequest(ServiceRequest request) {
        if (request == null) {
            throw new ServiceException('Request cannot be null', ServiceException.VALIDATION_ERROR);
        }
        
        String applicationId = request.getStringParameter('applicationId');
        if (String.isBlank(applicationId)) {
            throw new ServiceException('Application ID is required', ServiceException.VALIDATION_ERROR);
        }
    }
    
    /**
     * @description Validate risk calculation request parameters
     * @param request Service request to validate
     */
    private static void validateRiskCalculationRequest(ServiceRequest request) {
        if (request == null) {
            throw new ServiceException('Request cannot be null', ServiceException.VALIDATION_ERROR);
        }
        
        Decimal creditScore = (Decimal)request.getParameter('creditScore');
        if (creditScore == null || creditScore < 300 || creditScore > 850) {
            throw new ServiceException('Valid credit score (300-850) is required', ServiceException.VALIDATION_ERROR);
        }
        
        String loanType = request.getStringParameter('loanType');
        if (String.isBlank(loanType)) {
            throw new ServiceException('Loan type is required', ServiceException.VALIDATION_ERROR);
        }
    }
    
    /**
     * @description Get mock credit evaluation response
     * @param request Service request
     * @return ServiceResponse Mock response
     */
    private static ServiceResponse getMockCreditResponse(ServiceRequest request) {
        return MockDataFactory.generateResponse(SERVICE_NAME, request);
    }
    
    /**
     * @description Get mock credit report response
     * @param request Service request
     * @return ServiceResponse Mock credit report
     */
    private static ServiceResponse getMockCreditReportResponse(ServiceRequest request) {
        // Generate enhanced credit report data
        ServiceResponse baseResponse = MockDataFactory.generateResponse(SERVICE_NAME, request);
        
        if (baseResponse.success) {
            // Add additional credit report details
            baseResponse.addData('reportId', 'CR-' + DateTime.now().format('yyyyMMddHHmmss'));
            baseResponse.addData('reportDate', Date.today());
            baseResponse.addData('tradelines', generateMockTradelines());
            baseResponse.addData('inquiries', generateMockInquiries());
            baseResponse.addData('publicRecords', new List<Object>());
        }
        
        return baseResponse;
    }
    
    /**
     * @description Generate mock tradeline data
     * @return List<Object> Mock tradelines
     */
    private static List<Object> generateMockTradelines() {
        List<Object> tradelines = new List<Object>();
        
        Map<String, Object> creditCard = new Map<String, Object>();
        creditCard.put('creditorName', 'Chase Bank');
        creditCard.put('accountType', 'Credit Card');
        creditCard.put('balance', 2500);
        creditCard.put('limit', 10000);
        creditCard.put('paymentHistory', 'Current');
        creditCard.put('dateOpened', Date.today().addYears(-3));
        tradelines.add(creditCard);
        
        Map<String, Object> autoLoan = new Map<String, Object>();
        autoLoan.put('creditorName', 'Ford Motor Credit');
        autoLoan.put('accountType', 'Auto Loan');
        autoLoan.put('balance', 15000);
        autoLoan.put('originalAmount', 25000);
        autoLoan.put('paymentHistory', 'Current');
        autoLoan.put('dateOpened', Date.today().addYears(-2));
        tradelines.add(autoLoan);
        
        return tradelines;
    }
    
    /**
     * @description Generate mock inquiry data
     * @return List<Object> Mock inquiries
     */
    private static List<Object> generateMockInquiries() {
        List<Object> inquiries = new List<Object>();
        
        Map<String, Object> inquiry = new Map<String, Object>();
        inquiry.put('creditorName', 'Bank of America');
        inquiry.put('inquiryType', 'Hard');
        inquiry.put('inquiryDate', Date.today().addMonths(-2));
        inquiry.put('purpose', 'Credit Card');
        inquiries.add(inquiry);
        
        return inquiries;
    }
    
    /**
     * @description Get API-based credit evaluation response (future implementation)
     * @param request Service request
     * @return ServiceResponse API response
     */
    private static ServiceResponse getAPICreditResponse(ServiceRequest request) {
        throw new ServiceException('Credit bureau API integration not yet implemented', ServiceException.NOT_IMPLEMENTED);
    }
    
    /**
     * @description Get API-based credit report response (future implementation)
     * @param request Service request
     * @return ServiceResponse API response
     */
    private static ServiceResponse getAPICreditReportResponse(ServiceRequest request) {
        throw new ServiceException('Credit bureau API integration not yet implemented', ServiceException.NOT_IMPLEMENTED);
    }
    
    /**
     * @description Determine risk level based on credit score
     * @param creditScore Credit score
     * @return String Risk level
     */
    private static String determineRiskLevel(Decimal creditScore) {
        if (creditScore >= 750) {
            return 'LOW';
        } else if (creditScore >= 700) {
            return 'MEDIUM';
        } else if (creditScore >= 650) {
            return 'MEDIUM_HIGH';
        } else {
            return 'HIGH';
        }
    }
    
    /**
     * @description Calculate risk percentage based on credit score and loan type
     * @param creditScore Credit score
     * @param loanType Loan type
     * @return Decimal Risk percentage
     */
    private static Decimal calculateRiskPercentage(Decimal creditScore, String loanType) {
        // Base risk calculation
        Decimal baseRisk = 100 - ((creditScore - 300) / 550 * 100);
        
        // Loan type adjustment
        Decimal loanTypeMultiplier = 1.0;
        if (loanType == 'Personal') {
            loanTypeMultiplier = 1.2; // Higher risk for unsecured loans
        } else if (loanType == 'Auto') {
            loanTypeMultiplier = 0.8; // Lower risk for secured loans
        } else if (loanType == 'Mortgage') {
            loanTypeMultiplier = 0.6; // Lowest risk for mortgages
        }
        
        return (baseRisk * loanTypeMultiplier).setScale(2);
    }
    
    /**
     * @description Calculate interest rate adjustment based on risk level
     * @param riskLevel Risk level
     * @return Decimal Rate adjustment percentage
     */
    private static Decimal calculateRateAdjustment(String riskLevel) {
        switch on riskLevel {
            when 'LOW' {
                return -0.5; // 0.5% discount for low risk
            }
            when 'MEDIUM' {
                return 0.0; // Base rate
            }
            when 'MEDIUM_HIGH' {
                return 1.0; // 1% premium
            }
            when 'HIGH' {
                return 3.0; // 3% premium for high risk
            }
            when else {
                return 0.0;
            }
        }
    }
}