/**
 * @description HTTP Callout service for external API integration
 * @author Lending POC Team
 * @date 2025-09-04
 */
public with sharing class HttpCalloutService {
    
    // Timeout configuration
    private static final Integer DEFAULT_TIMEOUT = 30000; // 30 seconds
    
    /**
     * @description Make HTTP POST request to external service
     * @param endpoint The API endpoint URL
     * @param requestBody The request body as a Map
     * @return ServiceResponse The parsed response
     */
    public static ServiceResponse post(String endpoint, Map<String, Object> requestBody) {
        try {
            // Create HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/json');
            req.setHeader('x-api-key', 'test_key_development_2025'); // Add API key header
            req.setTimeout(DEFAULT_TIMEOUT);
            
            // Set request body
            if (requestBody != null) {
                req.setBody(JSON.serialize(requestBody));
            }
            
            // Log request (be careful not to log sensitive data in production)
            System.debug('Making HTTP POST to: ' + endpoint);
            
            // Send request
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Log response status
            System.debug('Response status: ' + res.getStatus() + ' (' + res.getStatusCode() + ')');
            
            // Parse response
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                
                // Check if response indicates success
                Boolean success = (Boolean) responseMap.get('success');
                if (success != null && success) {
                    return ServiceResponse.createSuccess(
                        (Map<String, Object>) responseMap.get('data')
                    );
                } else {
                    // Service returned an error response
                    String message = (String) responseMap.get('message');
                    String errorCode = (String) responseMap.get('errorCode');
                    return ServiceResponse.createError(
                        message != null ? message : 'Service error',
                        errorCode != null ? errorCode : 'SERVICE_ERROR'
                    );
                }
            } else {
                // HTTP error
                return ServiceResponse.createError(
                    'HTTP Error: ' + res.getStatus(),
                    'HTTP_' + res.getStatusCode()
                );
            }
            
        } catch (System.CalloutException e) {
            System.debug('Callout exception: ' + e.getMessage());
            return ServiceResponse.createError(
                'Callout failed: ' + e.getMessage(),
                'CALLOUT_EXCEPTION'
            );
        } catch (Exception e) {
            System.debug('Unexpected error in HTTP callout: ' + e.getMessage());
            return ServiceResponse.createError(
                'Unexpected error: ' + e.getMessage(),
                'SYSTEM_ERROR'
            );
        }
    }
    
    /**
     * @description Make HTTP GET request to external service
     * @param endpoint The API endpoint URL
     * @return ServiceResponse The parsed response
     */
    public static ServiceResponse get(String endpoint) {
        try {
            // Create HTTP request
            HttpRequest req = new HttpRequest();
            req.setEndpoint(endpoint);
            req.setMethod('GET');
            req.setHeader('x-api-key', 'test_key_development_2025'); // Add API key header
            req.setTimeout(DEFAULT_TIMEOUT);
            
            // Log request
            System.debug('Making HTTP GET to: ' + endpoint);
            
            // Send request
            Http http = new Http();
            HttpResponse res = http.send(req);
            
            // Log response status
            System.debug('Response status: ' + res.getStatus() + ' (' + res.getStatusCode() + ')');
            
            // Parse response
            if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                return ServiceResponse.createSuccess(responseMap);
            } else {
                return ServiceResponse.createError(
                    'HTTP Error: ' + res.getStatus(),
                    'HTTP_' + res.getStatusCode()
                );
            }
            
        } catch (System.CalloutException e) {
            System.debug('Callout exception: ' + e.getMessage());
            return ServiceResponse.createError(
                'Callout failed: ' + e.getMessage(),
                'CALLOUT_EXCEPTION'
            );
        } catch (Exception e) {
            System.debug('Unexpected error in HTTP callout: ' + e.getMessage());
            return ServiceResponse.createError(
                'Unexpected error: ' + e.getMessage(),
                'SYSTEM_ERROR'
            );
        }
    }
    
    /**
     * @description Check if external service is available
     * @param healthEndpoint The health check endpoint URL
     * @return Boolean True if service is healthy
     */
    public static Boolean checkHealth(String healthEndpoint) {
        try {
            ServiceResponse response = get(healthEndpoint);
            if (response.success) {
                Map<String, Object> data = response.data;
                String status = (String) data.get('status');
                return 'healthy'.equalsIgnoreCase(status);
            }
            return false;
        } catch (Exception e) {
            System.debug('Health check failed: ' + e.getMessage());
            return false;
        }
    }
    
    // Configuration for external service endpoints
    // Note: In production, use Named Credentials or Custom Settings
    
    // Use Named Credentials for secure API configuration
    private static final String CREDIT_BUREAU_BASE = 'callout:Credit_Bureau_Service';
    private static final String DECISION_ENGINE_BASE = 'callout:Decision_Engine_Service';
    private static final String INCOME_SERVICE_BASE = 'callout:Income_Service';
    
    // Endpoint paths
    private static final String EVALUATE_APPLICATION = '/api/v1/evaluate-application';
    private static final String CREDIT_SCORE = '/api/v1/credit-score';
    private static final String CREDIT_CHECK = '/api/v1/credit-check';
    private static final String VERIFY_INCOME = '/api/v1/verify-income';
    private static final String CALCULATE_DTI = '/api/v1/calculate-dti';
    private static final String HEALTH = '/health';
    
    /**
     * @description Call Decision Engine service
     * @param applicationId The loan application ID
     * @return ServiceResponse The decision response
     */
    @future(callout=true)
    public static void callDecisionEngineAsync(String applicationId) {
        String endpoint = DECISION_ENGINE_BASE + EVALUATE_APPLICATION;
        Map<String, Object> requestBody = new Map<String, Object>{
            'applicationId' => applicationId
        };
        
        ServiceResponse response = post(endpoint, requestBody);
        
        // Process response (update loan application record, etc.)
        if (response.success) {
            System.debug('Decision received: ' + JSON.serialize(response.data));
            // TODO: Update loan application with decision
        } else {
            System.debug('Decision engine error: ' + response.message);
        }
    }
    
    /**
     * @description Call Income Verification service
     * @param applicationId The loan application ID
     * @return ServiceResponse The income verification response
     */
    public static ServiceResponse verifyIncome(String applicationId) {
        String endpoint = INCOME_SERVICE_BASE + VERIFY_INCOME;
        Map<String, Object> requestBody = new Map<String, Object>{
            'applicationId' => applicationId
        };
        
        return post(endpoint, requestBody);
    }
    
    /**
     * @description Call Credit Bureau service for credit check
     * @param ssn Social Security Number
     * @param firstName First name
     * @param lastName Last name
     * @param dateOfBirth Date of birth
     * @return ServiceResponse The credit check response
     */
    public static ServiceResponse checkCredit(String ssn, String firstName, String lastName, String dateOfBirth) {
        String endpoint = CREDIT_BUREAU_BASE + CREDIT_CHECK;
        Map<String, Object> requestBody = new Map<String, Object>{
            'ssn' => ssn,
            'firstName' => firstName,
            'lastName' => lastName,
            'dateOfBirth' => dateOfBirth
        };
        
        return post(endpoint, requestBody);
    }
    
    /**
     * @description Call Credit Bureau service for credit score only
     * @param ssn Social Security Number
     * @return ServiceResponse The credit score response
     */
    public static ServiceResponse getCreditScore(String ssn) {
        String endpoint = CREDIT_BUREAU_BASE + CREDIT_SCORE;
        Map<String, Object> requestBody = new Map<String, Object>{
            'ssn' => ssn
        };
        
        return post(endpoint, requestBody);
    }
    
    /**
     * @description Test Credit Bureau service health
     * @return Boolean True if service is healthy
     */
    public static Boolean testCreditBureauHealth() {
        return checkHealth(CREDIT_BUREAU_BASE + HEALTH);
    }
    
    /**
     * @description Call ML-enhanced Decision Engine evaluation
     * @param applicationId The loan application ID
     * @param creditScore Credit score of the applicant
     * @param annualIncome Annual income of the applicant
     * @param loanAmount Requested loan amount
     * @param loanPurpose Purpose of the loan
     * @param employmentStatus Employment status
     * @param employmentLength Employment length in months
     * @param debtToIncomeRatio Current DTI ratio
     * @param previousDefaults Number of previous defaults
     * @param loanTermMonths Requested loan term in months
     * @return ServiceResponse The ML evaluation response
     */
    public static ServiceResponse callDecisionEngineML(
        String applicationId,
        Decimal creditScore,
        Decimal annualIncome,
        Decimal loanAmount,
        String loanPurpose,
        String employmentStatus,
        Integer employmentLength,
        Decimal debtToIncomeRatio,
        Integer previousDefaults,
        Integer loanTermMonths
    ) {
        String endpoint = DECISION_ENGINE_BASE + ServiceConfigurationHelper.getMLDecisionEngineEndpoint();
        
        Map<String, Object> requestBody = new Map<String, Object>{
            'applicantId' => applicationId,
            'creditScore' => creditScore,
            'annualIncome' => annualIncome,
            'loanAmount' => loanAmount,
            'loanPurpose' => loanPurpose,
            'employmentStatus' => employmentStatus,
            'employmentLength' => employmentLength,
            'debtToIncomeRatio' => debtToIncomeRatio,
            'previousDefaults' => previousDefaults,
            'loanTermMonths' => loanTermMonths
        };
        
        return post(endpoint, requestBody);
    }
    
    /**
     * @description Call ML Income Pattern Analysis service
     * @param monthlyIncomes Array of monthly income values
     * @param depositPatterns Array of deposit counts per month
     * @param employmentMonths Number of months employed
     * @param incomeSource Primary source of income
     * @param expectedIncome Expected/stated monthly income
     * @return ServiceResponse The income pattern analysis response
     */
    public static ServiceResponse callIncomePatternAnalysis(
        List<Decimal> monthlyIncomes,
        List<Integer> depositPatterns,
        Integer employmentMonths,
        String incomeSource,
        Decimal expectedIncome
    ) {
        String endpoint = INCOME_SERVICE_BASE + ServiceConfigurationHelper.getMLIncomePatternEndpoint();
        
        Map<String, Object> requestBody = new Map<String, Object>{
            'monthlyIncomes' => monthlyIncomes,
            'depositPatterns' => depositPatterns,
            'employmentMonths' => employmentMonths,
            'incomeSource' => incomeSource,
            'expectedIncome' => expectedIncome
        };
        
        return post(endpoint, requestBody);
    }
}