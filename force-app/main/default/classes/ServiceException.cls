/**
 * @description Custom exception class for service operations
 * @author Lending POC Team
 * @date 2025-09-03
 */
public class ServiceException extends Exception {
    /**
     * @description Error code for categorizing the exception
     */
    public String errorCode { get; set; }
    
    /**
     * @description Additional context data for the exception
     */
    public Map<String, Object> contextData { get; set; }
    
    /**
     * @description Constructor with message and error code
     * @param message Exception message
     * @param errorCode Error code
     */
    public ServiceException(String message, String errorCode) {
        this(message);
        this.errorCode = errorCode;
    }
    
    /**
     * @description Constructor with message, error code, and context
     * @param message Exception message
     * @param errorCode Error code
     * @param contextData Additional context data
     */
    public ServiceException(String message, String errorCode, Map<String, Object> contextData) {
        this(message, errorCode);
        this.contextData = contextData;
    }
    
    /**
     * @description Get the error code, defaulting if null
     * @return String Error code
     */
    public String getErrorCode() {
        return String.isNotBlank(this.errorCode) ? this.errorCode : 'UNKNOWN_ERROR';
    }
    
    /**
     * @description Get context data, initializing if null
     * @return Map<String, Object> Context data
     */
    public Map<String, Object> getContextData() {
        if (this.contextData == null) {
            this.contextData = new Map<String, Object>();
        }
        return this.contextData;
    }
    
    /**
     * @description Standard error codes
     */
    public static final String VALIDATION_ERROR = 'VALIDATION_ERROR';
    public static final String NOT_FOUND = 'NOT_FOUND';
    public static final String UNAUTHORIZED = 'UNAUTHORIZED';
    public static final String INTEGRATION_ERROR = 'INTEGRATION_ERROR';
    public static final String BUSINESS_RULE_VIOLATION = 'BUSINESS_RULE_VIOLATION';
    public static final String SYSTEM_ERROR = 'SYSTEM_ERROR';
    public static final String NOT_IMPLEMENTED = 'NOT_IMPLEMENTED';
}