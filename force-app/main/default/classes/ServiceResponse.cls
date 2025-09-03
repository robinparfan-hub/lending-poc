/**
 * @description Base response class for all service operations
 * @author Lending POC Team  
 * @date 2025-09-03
 */
public class ServiceResponse {
    /**
     * @description Indicates if the operation was successful
     */
    @AuraEnabled 
    public Boolean success { get; set; }
    
    /**
     * @description Human-readable message describing the result
     */
    @AuraEnabled 
    public String message { get; set; }
    
    /**
     * @description Data returned by the service operation
     */
    @AuraEnabled 
    public Map<String, Object> data { get; set; }
    
    /**
     * @description List of error messages if any
     */
    @AuraEnabled 
    public List<String> errors { get; set; }
    
    /**
     * @description Unique identifier for the response
     */
    @AuraEnabled 
    public String responseId { get; set; }
    
    /**
     * @description Timestamp when the response was created
     */
    @AuraEnabled 
    public DateTime timestamp { get; set; }
    
    /**
     * @description Error code for categorizing errors
     */
    @AuraEnabled 
    public String errorCode { get; set; }
    
    /**
     * @description Default constructor for successful response
     */
    public ServiceResponse() {
        this.success = true;
        this.message = 'Operation completed successfully';
        this.data = new Map<String, Object>();
        this.errors = new List<String>();
        this.responseId = generateResponseId();
        this.timestamp = DateTime.now();
        this.errorCode = null;
    }
    
    /**
     * @description Constructor with data
     * @param data Response data
     */
    public ServiceResponse(Map<String, Object> data) {
        this();
        this.data = data != null ? data : new Map<String, Object>();
    }
    
    /**
     * @description Constructor for error response
     * @param errorMessage Error message
     * @param errorCode Error code
     */
    public ServiceResponse(String errorMessage, String errorCode) {
        this();
        this.success = false;
        this.message = errorMessage;
        this.errorCode = errorCode;
        if (String.isNotBlank(errorMessage)) {
            this.errors.add(errorMessage);
        }
    }
    
    /**
     * @description Generate a unique response ID
     * @return String Unique response identifier
     */
    private String generateResponseId() {
        return 'RES-' + DateTime.now().format('yyyyMMddHHmmss') + '-' + 
               String.valueOf(Math.random()).substring(2, 8);
    }
    
    /**
     * @description Add data to the response
     * @param key Data key
     * @param value Data value
     */
    public void addData(String key, Object value) {
        if (data == null) {
            data = new Map<String, Object>();
        }
        data.put(key, value);
    }
    
    /**
     * @description Add an error message
     * @param error Error message to add
     */
    public void addError(String error) {
        if (errors == null) {
            errors = new List<String>();
        }
        if (String.isNotBlank(error)) {
            errors.add(error);
            this.success = false;
        }
    }
    
    /**
     * @description Create a success response with data
     * @param data Response data
     * @return ServiceResponse Success response
     */
    public static ServiceResponse createSuccess(Map<String, Object> data) {
        return new ServiceResponse(data);
    }
    
    /**
     * @description Create a success response with message
     * @param message Success message
     * @return ServiceResponse Success response
     */
    public static ServiceResponse createSuccess(String message) {
        ServiceResponse response = new ServiceResponse();
        response.message = message;
        return response;
    }
    
    /**
     * @description Create an error response
     * @param errorMessage Error message
     * @param errorCode Error code
     * @return ServiceResponse Error response
     */
    public static ServiceResponse createError(String errorMessage, String errorCode) {
        return new ServiceResponse(errorMessage, errorCode);
    }
    
    /**
     * @description Create an error response with multiple errors
     * @param errorMessages List of error messages
     * @param errorCode Error code
     * @return ServiceResponse Error response
     */
    public static ServiceResponse createError(List<String> errorMessages, String errorCode) {
        ServiceResponse response = new ServiceResponse();
        response.success = false;
        response.errorCode = errorCode;
        response.errors = errorMessages != null ? errorMessages : new List<String>();
        if (response.errors.size() > 0) {
            response.message = response.errors[0]; // Use first error as main message
        }
        return response;
    }
}