/**
 * @description Test class for ServiceResponse
 * @author Lending POC Team
 * @date 2025-09-03
 */
@IsTest
private class ServiceResponseTest {
    
    @IsTest
    static void testDefaultConstructor() {
        Test.startTest();
        ServiceResponse response = new ServiceResponse();
        Test.stopTest();
        
        // Verify default values
        Assert.areEqual(true, response.success, 'Response should be successful by default');
        Assert.areEqual('Operation completed successfully', response.message, 'Default message should be set');
        Assert.isNotNull(response.data, 'Data should be initialized');
        Assert.isNotNull(response.errors, 'Errors list should be initialized');
        Assert.isNotNull(response.responseId, 'Response ID should be generated');
        Assert.isTrue(response.responseId.startsWith('RES-'), 'Response ID should have RES- prefix');
        Assert.isNotNull(response.timestamp, 'Timestamp should be set');
        Assert.isNull(response.errorCode, 'Error code should be null for success');
    }
    
    @IsTest
    static void testConstructorWithData() {
        Map<String, Object> testData = new Map<String, Object>{
            'creditScore' => 750,
            'decision' => 'APPROVED'
        };
        
        Test.startTest();
        ServiceResponse response = new ServiceResponse(testData);
        Test.stopTest();
        
        // Verify data is set
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual(testData, response.data, 'Data should match constructor input');
    }
    
    @IsTest
    static void testConstructorWithNullData() {
        Test.startTest();
        ServiceResponse response = new ServiceResponse(null);
        Test.stopTest();
        
        // Verify null data is handled
        Assert.isNotNull(response.data, 'Data should be initialized even with null input');
        Assert.areEqual(0, response.data.size(), 'Data map should be empty');
    }
    
    @IsTest
    static void testErrorConstructor() {
        String errorMessage = 'Test error message';
        String errorCode = 'TEST_ERROR';
        
        Test.startTest();
        ServiceResponse response = new ServiceResponse(errorMessage, errorCode);
        Test.stopTest();
        
        // Verify error response
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.areEqual(errorMessage, response.message, 'Error message should be set');
        Assert.areEqual(errorCode, response.errorCode, 'Error code should be set');
        Assert.areEqual(1, response.errors.size(), 'Errors list should contain one error');
        Assert.areEqual(errorMessage, response.errors[0], 'First error should match message');
    }
    
    @IsTest
    static void testErrorConstructorWithBlankMessage() {
        Test.startTest();
        ServiceResponse response = new ServiceResponse('', 'TEST_ERROR');
        Test.stopTest();
        
        // Verify blank message handling
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.areEqual(0, response.errors.size(), 'No errors should be added for blank message');
    }
    
    @IsTest
    static void testAddData() {
        ServiceResponse response = new ServiceResponse();
        
        Test.startTest();
        response.addData('key1', 'value1');
        response.addData('key2', 123);
        Test.stopTest();
        
        // Verify data addition
        Assert.areEqual('value1', response.data.get('key1'), 'String data should be added');
        Assert.areEqual(123, response.data.get('key2'), 'Numeric data should be added');
        Assert.areEqual(2, response.data.size(), 'Data map should have correct size');
    }
    
    @IsTest
    static void testAddDataWithNullDataMap() {
        ServiceResponse response = new ServiceResponse();
        response.data = null; // Force null state
        
        Test.startTest();
        response.addData('testKey', 'testValue');
        Test.stopTest();
        
        // Verify null data map is handled
        Assert.isNotNull(response.data, 'Data map should be initialized');
        Assert.areEqual('testValue', response.data.get('testKey'), 'Data should be added');
    }
    
    @IsTest
    static void testAddError() {
        ServiceResponse response = new ServiceResponse();
        
        Test.startTest();
        response.addError('First error');
        response.addError('Second error');
        response.addError(''); // Blank error
        response.addError(null); // Null error
        Test.stopTest();
        
        // Verify error addition
        Assert.areEqual(false, response.success, 'Response should become unsuccessful when errors are added');
        Assert.areEqual(2, response.errors.size(), 'Only non-blank errors should be added');
        Assert.areEqual('First error', response.errors[0], 'First error should be preserved');
        Assert.areEqual('Second error', response.errors[1], 'Second error should be preserved');
    }
    
    @IsTest
    static void testAddErrorWithNullErrorsList() {
        ServiceResponse response = new ServiceResponse();
        response.errors = null; // Force null state
        
        Test.startTest();
        response.addError('Test error');
        Test.stopTest();
        
        // Verify null errors list is handled
        Assert.isNotNull(response.errors, 'Errors list should be initialized');
        Assert.areEqual(1, response.errors.size(), 'Error should be added');
        Assert.areEqual('Test error', response.errors[0], 'Error message should be correct');
    }
    
    @IsTest
    static void testCreateSuccessWithData() {
        Map<String, Object> testData = new Map<String, Object>{
            'result' => 'success'
        };
        
        Test.startTest();
        ServiceResponse response = ServiceResponse.createSuccess(testData);
        Test.stopTest();
        
        // Verify success response creation
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual(testData, response.data, 'Data should be set');
    }
    
    @IsTest
    static void testCreateSuccessWithMessage() {
        String successMessage = 'Operation completed successfully';
        
        Test.startTest();
        ServiceResponse response = ServiceResponse.createSuccess(successMessage);
        Test.stopTest();
        
        // Verify success response with message
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual(successMessage, response.message, 'Message should be set');
    }
    
    @IsTest
    static void testCreateError() {
        String errorMessage = 'Test error';
        String errorCode = 'TEST_ERROR';
        
        Test.startTest();
        ServiceResponse response = ServiceResponse.createError(errorMessage, errorCode);
        Test.stopTest();
        
        // Verify error response creation
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.areEqual(errorMessage, response.message, 'Error message should be set');
        Assert.areEqual(errorCode, response.errorCode, 'Error code should be set');
    }
    
    @IsTest
    static void testCreateErrorWithMultipleMessages() {
        List<String> errorMessages = new List<String>{'Error 1', 'Error 2', 'Error 3'};
        String errorCode = 'MULTIPLE_ERRORS';
        
        Test.startTest();
        ServiceResponse response = ServiceResponse.createError(errorMessages, errorCode);
        Test.stopTest();
        
        // Verify multiple errors response
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.areEqual('Error 1', response.message, 'Main message should be first error');
        Assert.areEqual(errorCode, response.errorCode, 'Error code should be set');
        Assert.areEqual(3, response.errors.size(), 'All errors should be included');
    }
    
    @IsTest
    static void testCreateErrorWithEmptyMessages() {
        List<String> errorMessages = new List<String>();
        String errorCode = 'NO_ERRORS';
        
        Test.startTest();
        ServiceResponse response = ServiceResponse.createError(errorMessages, errorCode);
        Test.stopTest();
        
        // Verify empty errors handling
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.areEqual(errorCode, response.errorCode, 'Error code should be set');
        Assert.areEqual(0, response.errors.size(), 'Errors list should be empty');
    }
    
    @IsTest
    static void testCreateErrorWithNullMessages() {
        Test.startTest();
        ServiceResponse response = ServiceResponse.createError((List<String>)null, 'NULL_ERRORS');
        Test.stopTest();
        
        // Verify null errors handling
        Assert.areEqual(false, response.success, 'Response should not be successful');
        Assert.isNotNull(response.errors, 'Errors list should be initialized');
        Assert.areEqual(0, response.errors.size(), 'Errors list should be empty');
    }
    
    @IsTest
    static void testResponseIdGeneration() {
        Test.startTest();
        ServiceResponse response1 = new ServiceResponse();
        ServiceResponse response2 = new ServiceResponse();
        Test.stopTest();
        
        // Verify unique response IDs
        Assert.areNotEqual(response1.responseId, response2.responseId, 'Response IDs should be unique');
        Assert.isTrue(response1.responseId.startsWith('RES-'), 'Response ID should have proper format');
        Assert.isTrue(response2.responseId.startsWith('RES-'), 'Response ID should have proper format');
    }
}