/**
 * @description Factory class for generating mock data responses for testing
 * @author Lending POC Team
 * @date 2025-09-03
 */
public class MockDataFactory {
    
    // Configuration from Custom Labels
    private static Integer MOCK_DELAY_MS {
        get {
            if (MOCK_DELAY_MS == null) {
                MOCK_DELAY_MS = Integer.valueOf(System.Label.Mock_Response_Delay_Ms);
            }
            return MOCK_DELAY_MS;
        }
        set;
    }
    
    /**
     * @description Scenario types for testing different approval outcomes
     */
    public enum Scenario {
        APPROVED_EXCELLENT_CREDIT,
        APPROVED_GOOD_CREDIT,
        APPROVED_WITH_CONDITIONS,
        DENIED_LOW_CREDIT,
        DENIED_HIGH_DTI,
        DENIED_INSUFFICIENT_INCOME,
        PENDING_DOCUMENT_REVIEW,
        ERROR_SCENARIO
    }
    
    /**
     * @description Generate appropriate mock response based on service and request
     * @param serviceName Name of the service requesting data
     * @param request Service request containing parameters
     * @return ServiceResponse Mock response data
     */
    public static ServiceResponse generateResponse(String serviceName, ServiceRequest request) {
        try {
            // Simulate API delay if configured
            simulateDelay();
            
            Scenario scenario = determineScenario(request);
            
            switch on serviceName {
                when 'CreditEvaluationService' {
                    return generateCreditEvaluationResponse(scenario, request);
                }
                when 'DecisionEngineService' {
                    return generateDecisionResponse(scenario, request);
                }
                when 'LoanCalculatorService' {
                    return generateLoanCalculationResponse(scenario, request);
                }
                when else {
                    return ServiceResponse.createError('Unknown service: ' + serviceName, 'UNKNOWN_SERVICE');
                }
            }
        } catch (Exception e) {
            return ServiceResponse.createError('Mock data generation failed: ' + e.getMessage(), 'MOCK_ERROR');
        }
    }
    
    /**
     * @description Determine scenario based on request parameters
     * @param request Service request
     * @return Scenario Determined scenario
     */
    private static Scenario determineScenario(ServiceRequest request) {
        // Check for explicit scenario in parameters
        String scenarioParam = request.getStringParameter('scenario');
        if (String.isNotBlank(scenarioParam)) {
            try {
                return Scenario.valueOf(scenarioParam.toUpperCase());
            } catch (Exception e) {
                // Invalid scenario, use default logic
            }
        }
        
        // Determine scenario based on application data
        String applicationId = request.getStringParameter('applicationId');
        if (String.isBlank(applicationId)) {
            return Scenario.APPROVED_GOOD_CREDIT; // Default scenario
        }
        
        // Use hash of application ID to consistently return same scenario
        Integer hash = Math.abs(applicationId.hashCode());
        Integer scenarioIndex = Math.mod(hash, 8);
        
        List<Scenario> scenarios = new List<Scenario>{
            Scenario.APPROVED_EXCELLENT_CREDIT,
            Scenario.APPROVED_GOOD_CREDIT,
            Scenario.APPROVED_WITH_CONDITIONS,
            Scenario.DENIED_LOW_CREDIT,
            Scenario.DENIED_HIGH_DTI,
            Scenario.DENIED_INSUFFICIENT_INCOME,
            Scenario.PENDING_DOCUMENT_REVIEW,
            Scenario.ERROR_SCENARIO
        };
        
        return scenarios[scenarioIndex];
    }
    
    /**
     * @description Generate mock credit evaluation response
     * @param scenario Test scenario
     * @param request Service request
     * @return ServiceResponse Credit evaluation response
     */
    private static ServiceResponse generateCreditEvaluationResponse(Scenario scenario, ServiceRequest request) {
        Map<String, Object> data = new Map<String, Object>();
        
        switch on scenario {
            when APPROVED_EXCELLENT_CREDIT {
                data.put('creditScore', 780);
                data.put('creditGrade', 'A');
                data.put('riskLevel', 'LOW');
                data.put('bureau', 'Experian');
                data.put('scoreDate', Date.today());
                data.put('factors', new List<String>{'Excellent payment history', 'Low credit utilization', 'Long credit history'});
            }
            when APPROVED_GOOD_CREDIT {
                data.put('creditScore', 720);
                data.put('creditGrade', 'B');
                data.put('riskLevel', 'MEDIUM');
                data.put('bureau', 'TransUnion');
                data.put('scoreDate', Date.today());
                data.put('factors', new List<String>{'Good payment history', 'Moderate credit utilization'});
            }
            when APPROVED_WITH_CONDITIONS, PENDING_DOCUMENT_REVIEW {
                data.put('creditScore', 680);
                data.put('creditGrade', 'C');
                data.put('riskLevel', 'MEDIUM');
                data.put('bureau', 'Equifax');
                data.put('scoreDate', Date.today());
                data.put('factors', new List<String>{'Fair payment history', 'Some recent inquiries'});
            }
            when DENIED_LOW_CREDIT {
                data.put('creditScore', 580);
                data.put('creditGrade', 'E');
                data.put('riskLevel', 'HIGH');
                data.put('bureau', 'Experian');
                data.put('scoreDate', Date.today());
                data.put('factors', new List<String>{'Poor payment history', 'High credit utilization', 'Recent delinquencies'});
            }
            when DENIED_HIGH_DTI, DENIED_INSUFFICIENT_INCOME {
                data.put('creditScore', 650);
                data.put('creditGrade', 'D');
                data.put('riskLevel', 'MEDIUM_HIGH');
                data.put('bureau', 'TransUnion');
                data.put('scoreDate', Date.today());
                data.put('factors', new List<String>{'Fair payment history', 'High debt balances'});
            }
            when ERROR_SCENARIO {
                return ServiceResponse.createError('Unable to retrieve credit score', 'CREDIT_BUREAU_ERROR');
            }
        }
        
        return ServiceResponse.createSuccess(data);
    }
    
    /**
     * @description Generate mock decision engine response
     * @param scenario Test scenario
     * @param request Service request
     * @return ServiceResponse Decision response
     */
    private static ServiceResponse generateDecisionResponse(Scenario scenario, ServiceRequest request) {
        Map<String, Object> data = new Map<String, Object>();
        
        switch on scenario {
            when APPROVED_EXCELLENT_CREDIT {
                data.put('decision', 'APPROVED');
                data.put('approvedAmount', 50000);
                data.put('interestRate', 5.99);
                data.put('term', 60);
                data.put('monthlyPayment', 966.64);
                data.put('reasonCodes', new List<String>{'EXCELLENT_CREDIT', 'LOW_RISK'});
                data.put('conditions', new List<String>());
            }
            when APPROVED_GOOD_CREDIT {
                data.put('decision', 'APPROVED');
                data.put('approvedAmount', 35000);
                data.put('interestRate', 8.99);
                data.put('term', 60);
                data.put('monthlyPayment', 730.17);
                data.put('reasonCodes', new List<String>{'GOOD_CREDIT', 'ACCEPTABLE_RISK'});
                data.put('conditions', new List<String>());
            }
            when APPROVED_WITH_CONDITIONS {
                data.put('decision', 'APPROVED_WITH_CONDITIONS');
                data.put('approvedAmount', 25000);
                data.put('interestRate', 12.99);
                data.put('term', 48);
                data.put('monthlyPayment', 667.67);
                data.put('reasonCodes', new List<String>{'FAIR_CREDIT', 'CONDITIONAL_APPROVAL'});
                data.put('conditions', new List<String>{'Proof of income required', 'Verification of employment'});
            }
            when DENIED_LOW_CREDIT {
                data.put('decision', 'DENIED');
                data.put('approvedAmount', 0);
                data.put('reasonCodes', new List<String>{'LOW_CREDIT_SCORE', 'HIGH_RISK'});
                data.put('denialReasons', new List<String>{'Credit score below minimum threshold', 'Poor payment history'});
            }
            when DENIED_HIGH_DTI {
                data.put('decision', 'DENIED');
                data.put('approvedAmount', 0);
                data.put('reasonCodes', new List<String>{'HIGH_DTI_RATIO', 'INSUFFICIENT_INCOME'});
                data.put('denialReasons', new List<String>{'Debt-to-income ratio exceeds 45%', 'Insufficient disposable income'});
            }
            when DENIED_INSUFFICIENT_INCOME {
                data.put('decision', 'DENIED');
                data.put('approvedAmount', 0);
                data.put('reasonCodes', new List<String>{'INSUFFICIENT_INCOME', 'UNVERIFIABLE_INCOME'});
                data.put('denialReasons', new List<String>{'Income cannot be verified', 'Income below minimum threshold'});
            }
            when PENDING_DOCUMENT_REVIEW {
                data.put('decision', 'PENDING_REVIEW');
                data.put('approvedAmount', 0);
                data.put('reasonCodes', new List<String>{'MANUAL_REVIEW_REQUIRED'});
                data.put('pendingItems', new List<String>{'Income verification', 'Employment verification', 'Bank statements'});
            }
            when ERROR_SCENARIO {
                return ServiceResponse.createError('Decision engine temporarily unavailable', 'DECISION_ENGINE_ERROR');
            }
        }
        
        data.put('processedDate', DateTime.now());
        data.put('expirationDate', DateTime.now().addDays(30));
        
        return ServiceResponse.createSuccess(data);
    }
    
    /**
     * @description Generate mock loan calculation response
     * @param scenario Test scenario  
     * @param request Service request
     * @return ServiceResponse Loan calculation response
     */
    private static ServiceResponse generateLoanCalculationResponse(Scenario scenario, ServiceRequest request) {
        // For loan calculator, we use real calculations, not mock data
        // But we'll return a sample response for testing
        Decimal principal = (Decimal)request.getParameter('principal');
        Decimal rate = (Decimal)request.getParameter('rate');
        Integer months = (Integer)request.getParameter('months');
        
        if (principal == null || rate == null || months == null) {
            return ServiceResponse.createError('Missing required parameters: principal, rate, months', 'VALIDATION_ERROR');
        }
        
        // This will be implemented in the actual LoanCalculatorService
        Map<String, Object> data = new Map<String, Object>();
        data.put('principal', principal);
        data.put('rate', rate);
        data.put('months', months);
        data.put('monthlyPayment', 0); // Will be calculated in actual service
        
        return ServiceResponse.createSuccess(data);
    }
    
    /**
     * @description Generate realistic applicant test data
     * @param scenario Test scenario
     * @return Map<String, Object> Applicant data
     */
    public static Map<String, Object> generateApplicantData(Scenario scenario) {
        Map<String, Object> applicant = new Map<String, Object>();
        
        switch on scenario {
            when APPROVED_EXCELLENT_CREDIT {
                applicant.put('firstName', 'Sarah');
                applicant.put('lastName', 'Johnson');
                applicant.put('email', 'sarah.johnson@example.com');
                applicant.put('phone', '555-0123');
                applicant.put('annualIncome', 85000);
                applicant.put('employmentType', 'Full-time');
                applicant.put('employmentYears', 5);
                applicant.put('monthlyDebtPayments', 1200);
            }
            when APPROVED_GOOD_CREDIT {
                applicant.put('firstName', 'Michael');
                applicant.put('lastName', 'Chen');
                applicant.put('email', 'michael.chen@example.com');
                applicant.put('phone', '555-0124');
                applicant.put('annualIncome', 65000);
                applicant.put('employmentType', 'Full-time');
                applicant.put('employmentYears', 3);
                applicant.put('monthlyDebtPayments', 1800);
            }
            when DENIED_LOW_CREDIT {
                applicant.put('firstName', 'David');
                applicant.put('lastName', 'Wilson');
                applicant.put('email', 'david.wilson@example.com');
                applicant.put('phone', '555-0125');
                applicant.put('annualIncome', 45000);
                applicant.put('employmentType', 'Part-time');
                applicant.put('employmentYears', 1);
                applicant.put('monthlyDebtPayments', 2500);
            }
        }
        
        return applicant;
    }
    
    /**
     * @description Simulate API response delay based on Custom Label configuration
     */
    private static void simulateDelay() {
        if (MOCK_DELAY_MS != null && MOCK_DELAY_MS > 0) {
            Long startTime = System.currentTimeMillis();
            Long endTime = startTime + MOCK_DELAY_MS;
            
            // Simple busy wait (not recommended for production, but OK for mock data)
            while (System.currentTimeMillis() < endTime) {
                // Wait
            }
        }
    }
}