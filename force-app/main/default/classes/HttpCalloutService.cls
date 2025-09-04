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
    
    /**
     * @description Configuration for external service endpoints
     * Note: In production, use Named Credentials or Custom Settings
     */
    public class EndpointConfig {
        // For POC, hardcode Render URLs here after deployment
        // In production, use Named Credentials
        public static final String DECISION_ENGINE_BASE = 'https://decision-engine-service.onrender.com';
        public static final String INCOME_SERVICE_BASE = 'https://simple-income-service.onrender.com';
        
        // Endpoint paths
        public static final String EVALUATE_APPLICATION = '/api/v1/evaluate-application';
        public static final String CREDIT_SCORE = '/api/v1/credit-score';
        public static final String VERIFY_INCOME = '/api/v1/verify-income';
        public static final String CALCULATE_DTI = '/api/v1/calculate-dti';
        public static final String HEALTH = '/health';
    }
    
    /**
     * @description Call Decision Engine service
     * @param applicationId The loan application ID
     * @return ServiceResponse The decision response
     */
    @future(callout=true)
    public static void callDecisionEngineAsync(String applicationId) {
        String endpoint = EndpointConfig.DECISION_ENGINE_BASE + EndpointConfig.EVALUATE_APPLICATION;
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
        String endpoint = EndpointConfig.INCOME_SERVICE_BASE + EndpointConfig.VERIFY_INCOME;
        Map<String, Object> requestBody = new Map<String, Object>{
            'applicationId' => applicationId
        };
        
        return post(endpoint, requestBody);
    }
}