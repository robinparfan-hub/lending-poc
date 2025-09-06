/**
 * @description Main decision engine orchestrating all loan evaluations
 * @author Lending POC Team
 * @date 2025-09-03
 */
public with sharing class DecisionEngineService {
    
    // Configuration from Custom Labels for runtime control
    private static Boolean USE_MOCK_DATA {
        get {
            if (USE_MOCK_DATA == null) {
                // Use ServiceConfigurationHelper for service-specific settings
                USE_MOCK_DATA = ServiceConfigurationHelper.shouldUseMockData('DecisionEngine');
            }
            return USE_MOCK_DATA;
        }
        set;
    }
    private static final String SERVICE_NAME = 'DecisionEngineService';
    
    // Business rule thresholds (some from Custom Labels for runtime configuration)
    private static final Decimal MIN_CREDIT_SCORE_EXCELLENT = 750;
    private static final Decimal MIN_CREDIT_SCORE_GOOD = 680;
    private static final Decimal MIN_CREDIT_SCORE_FAIR = Decimal.valueOf(System.Label.Min_Credit_Score);
    private static final Decimal MAX_DTI_RATIO = Decimal.valueOf(System.Label.Max_DTI_Ratio);
    private static final Decimal MIN_ANNUAL_INCOME = 30000;
    private static final Decimal MAX_LOAN_AMOUNT = Decimal.valueOf(System.Label.Max_Loan_Amount);
    
    /**
     * @description Main method to evaluate a loan application
     * @param applicationId ID of the loan application
     * @return ServiceResponse Comprehensive decision result
     */
    @AuraEnabled(cacheable=false)
    public static ServiceResponse evaluateApplicationById(String applicationId) {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('applicationId', applicationId);
        return evaluateApplication(request);
    }
    
    /**
     * @description Main method to evaluate a loan application (full request)
     * @param request Service request containing application information
     * @return ServiceResponse Comprehensive decision result
     */
    @AuraEnabled(cacheable=false)
    public static ServiceResponse evaluateApplication(ServiceRequest request) {
        try {
            // Input validation
            validateEvaluationRequest(request);
            
            // Log service call
            System.debug('DecisionEngineService.evaluateApplication called with request: ' + request);
            
            // Execute orchestrated evaluation
            if (USE_MOCK_DATA) {
                return getMockDecisionResponse(request);
            } else {
                return getAPIDecisionResponse(request);
            }
            
        } catch (ServiceException e) {
            return ServiceResponse.createError(e.getMessage(), e.getErrorCode());
        } catch (Exception e) {
            System.debug('Unexpected error in evaluateApplication: ' + e.getMessage());
            return ServiceResponse.createError('Application evaluation failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Generate final decision based on evaluation results
     * @param evaluationResults Map containing all evaluation data
     * @return ServiceResponse Decision result
     */
    @AuraEnabled(cacheable=false)
    public static ServiceResponse generateDecisionByResults(Map<String, Object> evaluationResults) {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('evaluationResults', evaluationResults);
        return generateDecision(request);
    }
    
    /**
     * @description Generate final decision based on evaluation results (full request)
     * @param request Service request containing evaluation results
     * @return ServiceResponse Decision result
     */
    @AuraEnabled(cacheable=false)
    public static ServiceResponse generateDecision(ServiceRequest request) {
        try {
            // Input validation
            validateDecisionRequest(request);
            
            // Log service call
            System.debug('DecisionEngineService.generateDecision called with request: ' + request);
            
            Map<String, Object> evaluationResults = (Map<String, Object>)request.getParameter('evaluationResults');
            
            // Apply business rules to generate decision
            DecisionResult decision = applyBusinessRules(evaluationResults);
            
            Map<String, Object> data = new Map<String, Object>();
            data.put('decision', decision.decision);
            data.put('approvedAmount', decision.approvedAmount);
            data.put('interestRate', decision.interestRate);
            data.put('term', decision.term);
            data.put('monthlyPayment', decision.monthlyPayment);
            data.put('reasonCodes', decision.reasonCodes);
            data.put('conditions', decision.conditions);
            data.put('denialReasons', decision.denialReasons);
            data.put('processedDate', DateTime.now());
            data.put('expirationDate', DateTime.now().addDays(30));
            
            return ServiceResponse.createSuccess(data);
            
        } catch (ServiceException e) {
            return ServiceResponse.createError(e.getMessage(), e.getErrorCode());
        } catch (Exception e) {
            System.debug('Unexpected error in generateDecision: ' + e.getMessage());
            return ServiceResponse.createError('Decision generation failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Calculate approved amount based on requested amount and risk factors
     * @param requestedAmount Amount requested by applicant
     * @param riskFactors Map containing risk evaluation data
     * @return ServiceResponse Approved amount calculation
     */
    @AuraEnabled(cacheable=false)
    public static ServiceResponse calculateApprovalAmountByParams(Decimal requestedAmount, Map<String, Object> riskFactors) {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('requestedAmount', requestedAmount);
        request.setParameter('riskFactors', riskFactors);
        return calculateApprovalAmount(request);
    }
    
    /**
     * @description Calculate approved amount based on risk factors (full request)
     * @param request Service request containing requested amount and risk factors
     * @return ServiceResponse Approved amount calculation
     */
    @AuraEnabled(cacheable=false)
    public static ServiceResponse calculateApprovalAmount(ServiceRequest request) {
        try {
            // Input validation
            validateApprovalAmountRequest(request);
            
            // Log service call
            System.debug('DecisionEngineService.calculateApprovalAmount called with request: ' + request);
            
            Decimal requestedAmount = (Decimal)request.getParameter('requestedAmount');
            Map<String, Object> riskFactors = (Map<String, Object>)request.getParameter('riskFactors');
            
            // Calculate approved amount based on risk factors
            Decimal approvedAmount = determineApprovedAmount(requestedAmount, riskFactors);
            
            Map<String, Object> data = new Map<String, Object>();
            data.put('requestedAmount', requestedAmount);
            data.put('approvedAmount', approvedAmount);
            data.put('approvalRatio', approvedAmount / requestedAmount * 100);
            data.put('riskFactors', riskFactors);
            
            return ServiceResponse.createSuccess(data);
            
        } catch (ServiceException e) {
            return ServiceResponse.createError(e.getMessage(), e.getErrorCode());
        } catch (Exception e) {
            System.debug('Unexpected error in calculateApprovalAmount: ' + e.getMessage());
            return ServiceResponse.createError('Approval amount calculation failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Validate evaluation request parameters
     * @param request Service request to validate
     */
    private static void validateEvaluationRequest(ServiceRequest request) {
        if (request == null) {
            throw new ServiceException('Request cannot be null', ServiceException.VALIDATION_ERROR);
        }
        
        String applicationId = request.getStringParameter('applicationId');
        if (String.isBlank(applicationId)) {
            throw new ServiceException('Application ID is required', ServiceException.VALIDATION_ERROR);
        }
    }
    
    /**
     * @description Validate decision request parameters
     * @param request Service request to validate
     */
    private static void validateDecisionRequest(ServiceRequest request) {
        if (request == null) {
            throw new ServiceException('Request cannot be null', ServiceException.VALIDATION_ERROR);
        }
        
        Map<String, Object> evaluationResults = (Map<String, Object>)request.getParameter('evaluationResults');
        if (evaluationResults == null || evaluationResults.isEmpty()) {
            throw new ServiceException('Evaluation results are required', ServiceException.VALIDATION_ERROR);
        }
    }
    
    /**
     * @description Validate approval amount request parameters
     * @param request Service request to validate
     */
    private static void validateApprovalAmountRequest(ServiceRequest request) {
        if (request == null) {
            throw new ServiceException('Request cannot be null', ServiceException.VALIDATION_ERROR);
        }
        
        Decimal requestedAmount = (Decimal)request.getParameter('requestedAmount');
        if (requestedAmount == null || requestedAmount <= 0) {
            throw new ServiceException('Valid requested amount is required', ServiceException.VALIDATION_ERROR);
        }
        
        Map<String, Object> riskFactors = (Map<String, Object>)request.getParameter('riskFactors');
        if (riskFactors == null) {
            throw new ServiceException('Risk factors are required', ServiceException.VALIDATION_ERROR);
        }
    }
    
    /**
     * @description Get mock decision response using orchestrated services
     * @param request Service request
     * @return ServiceResponse Mock decision response
     */
    private static ServiceResponse getMockDecisionResponse(ServiceRequest request) {
        // In mock mode, use MockDataFactory for consistent responses
        return MockDataFactory.generateResponse(SERVICE_NAME, request);
    }
    
    /**
     * @description Get real API decision response by orchestrating all services
     * @param request Service request
     * @return ServiceResponse API decision response
     */
    private static ServiceResponse getAPIDecisionResponse(ServiceRequest request) {
        try {
            String applicationId = request.getStringParameter('applicationId');
            
            // Check if ML is enabled for Decision Engine
            if (ServiceConfigurationHelper.isMLEnabledForDecisionEngine()) {
                return getMLDecisionResponse(applicationId);
            }
            
            // Otherwise use the original orchestration approach
            Map<String, Object> evaluationResults = new Map<String, Object>();
            
            // Step 1: Get credit evaluation
            ServiceResponse creditResponse = CreditEvaluationService.evaluateCreditScoreById(applicationId);
            if (!creditResponse.success) {
                return creditResponse; // Return error if credit evaluation failed
            }
            evaluationResults.put('creditEvaluation', creditResponse.data);
            
            // Step 2: Get additional evaluations (will be implemented in Phase 2)
            // ServiceResponse incomeResponse = IncomeVerificationService.verifyIncome(applicationId);
            // ServiceResponse riskResponse = RiskAssessmentService.calculateRiskScore(applicationId);
            
            // Step 3: Generate final decision
            ServiceRequest decisionRequest = new ServiceRequest();
            decisionRequest.setParameter('evaluationResults', evaluationResults);
            return generateDecision(decisionRequest);
            
        } catch (Exception e) {
            System.debug('Error in orchestrated evaluation: ' + e.getMessage());
            return ServiceResponse.createError('Orchestrated evaluation failed', ServiceException.INTEGRATION_ERROR);
        }
    }
    
    /**
     * @description Get ML-enhanced decision response
     * @param applicationId The loan application ID
     * @return ServiceResponse ML decision response
     */
    private static ServiceResponse getMLDecisionResponse(String applicationId) {
        try {
            // Get application data
            Loan_Application__c app = [
                SELECT Id, Amount_Requested__c, Purpose__c, Term_Months__c,
                       Applicant_Profile__r.Total_Income__c,
                       Applicant_Profile__r.Employment_Status__c
                FROM Loan_Application__c
                WHERE Id = :applicationId
                LIMIT 1
            ];
            
            // Get credit score (mock for now, would come from credit bureau)
            Decimal creditScore = 720; // Default mock credit score
            ServiceResponse creditResponse = CreditEvaluationService.evaluateCreditScoreById(applicationId);
            if (creditResponse.success && creditResponse.data != null) {
                Object scoreObj = creditResponse.data.get('creditScore');
                if (scoreObj != null) {
                    creditScore = (Decimal)scoreObj;
                }
            }
            
            // Calculate DTI ratio (simplified)
            Decimal annualIncome = app.Applicant_Profile__r.Total_Income__c != null ? 
                app.Applicant_Profile__r.Total_Income__c : 50000;
            Decimal monthlyIncome = annualIncome / 12;
            Decimal estimatedMonthlyDebts = monthlyIncome * 0.35; // Estimate 35% DTI
            Decimal dtiRatio = (estimatedMonthlyDebts / monthlyIncome) * 100;
            
            // Call ML endpoint
            ServiceResponse mlResponse = HttpCalloutService.callDecisionEngineML(
                applicationId,
                creditScore,
                annualIncome,
                app.Amount_Requested__c,
                app.Purpose__c,
                app.Applicant_Profile__r.Employment_Status__c,
                24, // Default employment length in months
                dtiRatio,
                0, // Previous defaults
                Integer.valueOf(app.Term_Months__c)
            );
            
            return mlResponse;
            
        } catch (Exception e) {
            System.debug('Error in ML decision evaluation: ' + e.getMessage());
            // Fall back to mock if ML fails
            return getMockDecisionResponse(new ServiceRequest());
        }
    }
    
    /**
     * @description Apply business rules to generate decision
     * @param evaluationResults All evaluation data
     * @return DecisionResult Decision result
     */
    private static DecisionResult applyBusinessRules(Map<String, Object> evaluationResults) {
        DecisionResult result = new DecisionResult();
        
        // Extract credit evaluation data (mock structure for now)
        Map<String, Object> creditData = (Map<String, Object>)evaluationResults.get('creditEvaluation');
        if (creditData == null) {
            result.decision = 'DENIED';
            result.denialReasons.add('Credit evaluation missing');
            return result;
        }
        
        Decimal creditScore = (Decimal)creditData.get('creditScore');
        String riskLevel = (String)creditData.get('riskLevel');
        
        // Apply credit score rules
        if (creditScore >= MIN_CREDIT_SCORE_EXCELLENT) {
            result.decision = 'APPROVED';
            result.approvedAmount = 50000;
            result.interestRate = 5.99;
            result.term = 60;
            result.reasonCodes.add('EXCELLENT_CREDIT');
        } else if (creditScore >= MIN_CREDIT_SCORE_GOOD) {
            result.decision = 'APPROVED';
            result.approvedAmount = 35000;
            result.interestRate = 8.99;
            result.term = 60;
            result.reasonCodes.add('GOOD_CREDIT');
        } else if (creditScore >= MIN_CREDIT_SCORE_FAIR) {
            result.decision = 'APPROVED_WITH_CONDITIONS';
            result.approvedAmount = 25000;
            result.interestRate = 12.99;
            result.term = 48;
            result.reasonCodes.add('FAIR_CREDIT');
            result.conditions.add('Proof of income required');
            result.conditions.add('Employment verification required');
        } else {
            result.decision = 'DENIED';
            result.approvedAmount = 0;
            result.reasonCodes.add('LOW_CREDIT_SCORE');
            result.denialReasons.add('Credit score below minimum threshold');
        }
        
        // Calculate monthly payment if approved
        if (result.approvedAmount > 0) {
            ServiceResponse paymentResponse = LoanCalculatorService.calculateMonthlyPaymentByParams(
                result.approvedAmount, result.interestRate, result.term
            );
            if (paymentResponse.success) {
                result.monthlyPayment = (Decimal)paymentResponse.data.get('monthlyPayment');
            }
        }
        
        return result;
    }
    
    /**
     * @description Determine approved amount based on risk factors
     * @param requestedAmount Amount requested by applicant
     * @param riskFactors Risk evaluation data
     * @return Decimal Approved amount
     */
    private static Decimal determineApprovedAmount(Decimal requestedAmount, Map<String, Object> riskFactors) {
        // Simple risk-based approval logic
        String riskLevel = (String)riskFactors.get('riskLevel');
        
        Decimal maxAmount = 0;
        switch on riskLevel {
            when 'LOW' {
                maxAmount = 100000;
            }
            when 'MEDIUM' {
                maxAmount = 50000;
            }
            when 'MEDIUM_HIGH' {
                maxAmount = 25000;
            }
            when 'HIGH' {
                maxAmount = 0; // Denied
            }
            when else {
                maxAmount = 25000; // Default to conservative amount
            }
        }
        
        return Math.min(requestedAmount, maxAmount);
    }
    
    /**
     * @description Inner class to hold decision results
     */
    private class DecisionResult {
        public String decision = '';
        public Decimal approvedAmount = 0;
        public Decimal interestRate = 0;
        public Integer term = 0;
        public Decimal monthlyPayment = 0;
        public List<String> reasonCodes = new List<String>();
        public List<String> conditions = new List<String>();
        public List<String> denialReasons = new List<String>();
    }
}