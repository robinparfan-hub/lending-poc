/**
 * @description Base request class for all service operations
 * @author Lending POC Team
 * @date 2025-09-03
 */
public class ServiceRequest {
    /**
     * @description Unique identifier for the request
     */
    @AuraEnabled 
    public String requestId { get; set; }
    
    /**
     * @description Parameters for the service operation
     */
    @AuraEnabled 
    public Map<String, Object> parameters { get; set; }
    
    /**
     * @description User ID making the request
     */
    @AuraEnabled 
    public String userId { get; set; }
    
    /**
     * @description Timestamp when the request was created
     */
    @AuraEnabled 
    public DateTime timestamp { get; set; }
    
    /**
     * @description Default constructor
     */
    public ServiceRequest() {
        this.requestId = generateRequestId();
        this.parameters = new Map<String, Object>();
        this.userId = UserInfo.getUserId();
        this.timestamp = DateTime.now();
    }
    
    /**
     * @description Constructor with parameters
     * @param parameters Map of parameters for the service
     */
    public ServiceRequest(Map<String, Object> parameters) {
        this();
        this.parameters = parameters != null ? parameters : new Map<String, Object>();
    }
    
    /**
     * @description Generate a unique request ID
     * @return String Unique request identifier
     */
    private String generateRequestId() {
        return 'REQ-' + DateTime.now().format('yyyyMMddHHmmss') + '-' + 
               String.valueOf(Math.random()).substring(2, 8);
    }
    
    /**
     * @description Get a parameter value with type casting
     * @param key Parameter key
     * @return Object Parameter value
     */
    public Object getParameter(String key) {
        return parameters != null ? parameters.get(key) : null;
    }
    
    /**
     * @description Get a string parameter value
     * @param key Parameter key
     * @return String Parameter value as string
     */
    public String getStringParameter(String key) {
        Object value = getParameter(key);
        return value != null ? String.valueOf(value) : null;
    }
    
    /**
     * @description Set a parameter value
     * @param key Parameter key
     * @param value Parameter value
     */
    public void setParameter(String key, Object value) {
        if (parameters == null) {
            parameters = new Map<String, Object>();
        }
        parameters.put(key, value);
    }
}