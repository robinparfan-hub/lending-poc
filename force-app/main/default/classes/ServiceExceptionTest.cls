/**
 * @description Test class for ServiceException
 * @author Lending POC Team
 * @date 2025-09-03
 */
@IsTest
private class ServiceExceptionTest {
    
    @IsTest
    static void testConstructorWithMessageAndErrorCode() {
        String testMessage = 'Test exception message';
        String testErrorCode = 'TEST_ERROR';
        
        Test.startTest();
        ServiceException ex = new ServiceException(testMessage, testErrorCode);
        Test.stopTest();
        
        // Verify exception properties
        Assert.areEqual(testMessage, ex.getMessage(), 'Exception message should match');
        Assert.areEqual(testErrorCode, ex.errorCode, 'Error code should be set');
        Assert.areEqual(testErrorCode, ex.getErrorCode(), 'getErrorCode should return set value');
    }
    
    @IsTest
    static void testConstructorWithMessageErrorCodeAndContext() {
        String testMessage = 'Test exception with context';
        String testErrorCode = 'TEST_ERROR_WITH_CONTEXT';
        Map<String, Object> testContext = new Map<String, Object>{
            'applicationId' => 'APP-001',
            'userId' => UserInfo.getUserId(),
            'timestamp' => DateTime.now()
        };
        
        Test.startTest();
        ServiceException ex = new ServiceException(testMessage, testErrorCode, testContext);
        Test.stopTest();
        
        // Verify exception properties with context
        Assert.areEqual(testMessage, ex.getMessage(), 'Exception message should match');
        Assert.areEqual(testErrorCode, ex.errorCode, 'Error code should be set');
        Assert.areEqual(testContext, ex.contextData, 'Context data should be set');
        Assert.areEqual(testContext, ex.getContextData(), 'getContextData should return set value');
    }
    
    @IsTest
    static void testGetErrorCodeWithNullValue() {
        String testMessage = 'Test exception';
        
        Test.startTest();
        ServiceException ex = new ServiceException(testMessage);
        ex.errorCode = null; // Explicitly set to null
        String errorCode = ex.getErrorCode();
        Test.stopTest();
        
        // Verify default error code is returned
        Assert.areEqual('UNKNOWN_ERROR', errorCode, 'Should return default error code for null value');
    }
    
    @IsTest
    static void testGetErrorCodeWithBlankValue() {
        String testMessage = 'Test exception';
        
        Test.startTest();
        ServiceException ex = new ServiceException(testMessage);
        ex.errorCode = ''; // Set to blank
        String errorCode = ex.getErrorCode();
        Test.stopTest();
        
        // Verify default error code is returned
        Assert.areEqual('UNKNOWN_ERROR', errorCode, 'Should return default error code for blank value');
    }
    
    @IsTest
    static void testGetContextDataWithNullValue() {
        String testMessage = 'Test exception';
        String testErrorCode = 'TEST_ERROR';
        
        Test.startTest();
        ServiceException ex = new ServiceException(testMessage, testErrorCode);
        ex.contextData = null; // Explicitly set to null
        Map<String, Object> contextData = ex.getContextData();
        Test.stopTest();
        
        // Verify empty context data is returned and initialized
        Assert.isNotNull(contextData, 'Context data should not be null');
        Assert.areEqual(0, contextData.size(), 'Context data should be empty map');
        Assert.areEqual(contextData, ex.contextData, 'Context data should be initialized on the exception');
    }
    
    @IsTest
    static void testGetContextDataWithExistingValue() {
        String testMessage = 'Test exception';
        String testErrorCode = 'TEST_ERROR';
        Map<String, Object> originalContext = new Map<String, Object>{
            'key1' => 'value1'
        };
        
        Test.startTest();
        ServiceException ex = new ServiceException(testMessage, testErrorCode, originalContext);
        Map<String, Object> contextData = ex.getContextData();
        Test.stopTest();
        
        // Verify existing context data is returned
        Assert.areEqual(originalContext, contextData, 'Should return original context data');
        Assert.areEqual(1, contextData.size(), 'Context data should have correct size');
    }
    
    @IsTest
    static void testStandardErrorCodeConstants() {
        Test.startTest();
        // Test that all standard error code constants are defined and have expected values
        String validationError = ServiceException.VALIDATION_ERROR;
        String notFound = ServiceException.NOT_FOUND;
        String unauthorized = ServiceException.UNAUTHORIZED;
        String integrationError = ServiceException.INTEGRATION_ERROR;
        String businessRuleViolation = ServiceException.BUSINESS_RULE_VIOLATION;
        String systemError = ServiceException.SYSTEM_ERROR;
        String notImplemented = ServiceException.NOT_IMPLEMENTED;
        Test.stopTest();
        
        // Verify constants are defined correctly
        Assert.areEqual('VALIDATION_ERROR', validationError, 'Validation error constant should be correct');
        Assert.areEqual('NOT_FOUND', notFound, 'Not found constant should be correct');
        Assert.areEqual('UNAUTHORIZED', unauthorized, 'Unauthorized constant should be correct');
        Assert.areEqual('INTEGRATION_ERROR', integrationError, 'Integration error constant should be correct');
        Assert.areEqual('BUSINESS_RULE_VIOLATION', businessRuleViolation, 'Business rule violation constant should be correct');
        Assert.areEqual('SYSTEM_ERROR', systemError, 'System error constant should be correct');
        Assert.areEqual('NOT_IMPLEMENTED', notImplemented, 'Not implemented constant should be correct');
    }
    
    @IsTest
    static void testExceptionInheritance() {
        String testMessage = 'Test inheritance';
        String testErrorCode = 'INHERITANCE_TEST';
        
        Test.startTest();
        ServiceException ex = new ServiceException(testMessage, testErrorCode);
        // ServiceException extends Exception - verify it was created successfully
        Test.stopTest();
        
        // Verify exception properties
        Assert.isNotNull(ex, 'ServiceException should be created');
        Assert.areEqual(testMessage, ex.getMessage(), 'Message should match');
        Assert.areEqual(testErrorCode, ex.getErrorCode(), 'Error code should match');
    }
    
    @IsTest
    static void testExceptionThrowing() {
        String testMessage = 'This should be thrown';
        String testErrorCode = 'THROW_TEST';
        Boolean exceptionThrown = false;
        String caughtMessage = '';
        String caughtErrorCode = '';
        
        Test.startTest();
        try {
            throw new ServiceException(testMessage, testErrorCode);
        } catch (ServiceException ex) {
            exceptionThrown = true;
            caughtMessage = ex.getMessage();
            caughtErrorCode = ex.getErrorCode();
        }
        Test.stopTest();
        
        // Verify exception can be thrown and caught
        Assert.areEqual(true, exceptionThrown, 'Exception should be thrown');
        Assert.areEqual(testMessage, caughtMessage, 'Caught message should match');
        Assert.areEqual(testErrorCode, caughtErrorCode, 'Caught error code should match');
    }
    
    @IsTest
    static void testExceptionWithNullContext() {
        String testMessage = 'Test null context';
        String testErrorCode = 'NULL_CONTEXT_TEST';
        
        Test.startTest();
        ServiceException ex = new ServiceException(testMessage, testErrorCode, null);
        Test.stopTest();
        
        // Verify null context is handled
        Assert.areEqual(testMessage, ex.getMessage(), 'Message should be set');
        Assert.areEqual(testErrorCode, ex.errorCode, 'Error code should be set');
        Assert.isNull(ex.contextData, 'Context data should be null initially');
        
        // Test getContextData initializes the map
        Map<String, Object> contextData = ex.getContextData();
        Assert.isNotNull(contextData, 'Context data should be initialized by getter');
        Assert.areEqual(0, contextData.size(), 'Context data should be empty');
    }
}