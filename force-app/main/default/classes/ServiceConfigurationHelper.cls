/**
 * @description Helper class to manage service configuration and mock data settings
 * @author Lending POC Team
 * @date 2025-09-06
 */
public with sharing class ServiceConfigurationHelper {
    
    // Cache for label values to avoid repeated lookups
    private static Map<String, Boolean> mockDataSettings = new Map<String, Boolean>();
    private static Map<String, String> endpointSettings = new Map<String, String>();
    
    /**
     * @description Check if a specific service should use mock data
     * @param serviceName Name of the service (e.g., 'DecisionEngine', 'IncomeVerification')
     * @return Boolean True if mock data should be used
     */
    public static Boolean shouldUseMockData(String serviceName) {
        if (String.isBlank(serviceName)) {
            return getGlobalMockDataSetting();
        }
        
        // Check cache first
        String cacheKey = 'Use_Mock_' + serviceName;
        if (mockDataSettings.containsKey(cacheKey)) {
            return mockDataSettings.get(cacheKey);
        }
        
        Boolean useMock = false;
        
        // Check service-specific setting first
        if (serviceName.equalsIgnoreCase('DecisionEngine')) {
            String labelValue = System.Label.Use_Mock_Data_Decision_Engine;
            useMock = (labelValue != null && labelValue.equalsIgnoreCase('true'));
        } else if (serviceName.equalsIgnoreCase('IncomeVerification')) {
            String labelValue = System.Label.Use_Mock_Data_Income_Verification;
            useMock = (labelValue != null && labelValue.equalsIgnoreCase('true'));
        } else {
            // Fall back to global setting for other services
            useMock = getGlobalMockDataSetting();
        }
        
        // Cache the result
        mockDataSettings.put(cacheKey, useMock);
        return useMock;
    }
    
    /**
     * @description Get the global mock data setting
     * @return Boolean True if mock data should be used globally
     */
    public static Boolean getGlobalMockDataSetting() {
        String cacheKey = 'Use_Mock_Global';
        if (mockDataSettings.containsKey(cacheKey)) {
            return mockDataSettings.get(cacheKey);
        }
        
        String labelValue = System.Label.Use_Mock_Data;
        Boolean useMock = (labelValue != null && labelValue.equalsIgnoreCase('true'));
        mockDataSettings.put(cacheKey, useMock);
        return useMock;
    }
    
    /**
     * @description Get the ML endpoint for Decision Engine
     * @return String The endpoint path for ML evaluation
     */
    public static String getMLDecisionEngineEndpoint() {
        String cacheKey = 'ML_Decision_Endpoint';
        if (endpointSettings.containsKey(cacheKey)) {
            return endpointSettings.get(cacheKey);
        }
        
        String endpoint = System.Label.ML_Decision_Engine_Endpoint;
        if (String.isBlank(endpoint)) {
            endpoint = '/api/v1/ml-evaluate';
        }
        endpointSettings.put(cacheKey, endpoint);
        return endpoint;
    }
    
    /**
     * @description Get the ML endpoint for Income Pattern Analysis
     * @return String The endpoint path for income pattern analysis
     */
    public static String getMLIncomePatternEndpoint() {
        String cacheKey = 'ML_Income_Endpoint';
        if (endpointSettings.containsKey(cacheKey)) {
            return endpointSettings.get(cacheKey);
        }
        
        String endpoint = System.Label.ML_Income_Pattern_Endpoint;
        if (String.isBlank(endpoint)) {
            endpoint = '/api/v1/analyze-income-pattern';
        }
        endpointSettings.put(cacheKey, endpoint);
        return endpoint;
    }
    
    /**
     * @description Check if ML features are enabled for Decision Engine
     * @return Boolean True if ML features should be used
     */
    public static Boolean isMLEnabledForDecisionEngine() {
        // ML is enabled when NOT using mock data for this service
        return !shouldUseMockData('DecisionEngine');
    }
    
    /**
     * @description Check if ML features are enabled for Income Verification
     * @return Boolean True if ML features should be used
     */
    public static Boolean isMLEnabledForIncomeVerification() {
        // ML is enabled when NOT using mock data for this service
        return !shouldUseMockData('IncomeVerification');
    }
    
    /**
     * @description Clear the configuration cache (useful for testing)
     */
    @TestVisible
    private static void clearCache() {
        mockDataSettings.clear();
        endpointSettings.clear();
    }
    
    /**
     * @description Get configuration summary for debugging
     * @return Map<String, Object> Configuration summary
     */
    public static Map<String, Object> getConfigurationSummary() {
        Map<String, Object> summary = new Map<String, Object>();
        
        summary.put('globalMockData', getGlobalMockDataSetting());
        summary.put('decisionEngineMockData', shouldUseMockData('DecisionEngine'));
        summary.put('incomeVerificationMockData', shouldUseMockData('IncomeVerification'));
        summary.put('decisionEngineMLEnabled', isMLEnabledForDecisionEngine());
        summary.put('incomeVerificationMLEnabled', isMLEnabledForIncomeVerification());
        summary.put('mlDecisionEngineEndpoint', getMLDecisionEngineEndpoint());
        summary.put('mlIncomePatternEndpoint', getMLIncomePatternEndpoint());
        
        return summary;
    }
}