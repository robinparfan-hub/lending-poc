/**
 * @description Test class for ServiceRequest
 * @author Lending POC Team
 * @date 2025-09-03
 */
@IsTest
private class ServiceRequestTest {
    
    @IsTest
    static void testDefaultConstructor() {
        Test.startTest();
        ServiceRequest request = new ServiceRequest();
        Test.stopTest();
        
        // Verify default values are set
        Assert.isNotNull(request.requestId, 'Request ID should be generated');
        Assert.isTrue(request.requestId.startsWith('REQ-'), 'Request ID should have REQ- prefix');
        Assert.isNotNull(request.parameters, 'Parameters should be initialized');
        Assert.areEqual(UserInfo.getUserId(), request.userId, 'User ID should be set to current user');
        Assert.isNotNull(request.timestamp, 'Timestamp should be set');
    }
    
    @IsTest
    static void testConstructorWithParameters() {
        Map<String, Object> testParams = new Map<String, Object>{
            'applicationId' => 'APP-001',
            'amount' => 25000
        };
        
        Test.startTest();
        ServiceRequest request = new ServiceRequest(testParams);
        Test.stopTest();
        
        // Verify parameters are set
        Assert.areEqual(testParams, request.parameters, 'Parameters should match constructor input');
        Assert.areEqual('APP-001', request.getStringParameter('applicationId'), 'Application ID should be retrievable');
    }
    
    @IsTest
    static void testConstructorWithNullParameters() {
        Test.startTest();
        ServiceRequest request = new ServiceRequest(null);
        Test.stopTest();
        
        // Verify null parameters are handled
        Assert.isNotNull(request.parameters, 'Parameters should be initialized even with null input');
        Assert.areEqual(0, request.parameters.size(), 'Parameters map should be empty');
    }
    
    @IsTest
    static void testGetParameter() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('testKey', 'testValue');
        request.setParameter('numericKey', 123);
        
        Test.startTest();
        Object stringValue = request.getParameter('testKey');
        Object numericValue = request.getParameter('numericKey');
        Object nullValue = request.getParameter('nonExistentKey');
        Test.stopTest();
        
        // Verify parameter retrieval
        Assert.areEqual('testValue', stringValue, 'String parameter should be retrievable');
        Assert.areEqual(123, numericValue, 'Numeric parameter should be retrievable');
        Assert.isNull(nullValue, 'Non-existent parameter should return null');
    }
    
    @IsTest
    static void testGetStringParameter() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('stringKey', 'testValue');
        request.setParameter('numericKey', 123);
        
        Test.startTest();
        String stringValue = request.getStringParameter('stringKey');
        String numericAsString = request.getStringParameter('numericKey');
        String nullValue = request.getStringParameter('nonExistentKey');
        Test.stopTest();
        
        // Verify string parameter retrieval and conversion
        Assert.areEqual('testValue', stringValue, 'String parameter should be returned as string');
        Assert.areEqual('123', numericAsString, 'Numeric parameter should be converted to string');
        Assert.isNull(nullValue, 'Non-existent parameter should return null');
    }
    
    @IsTest
    static void testSetParameter() {
        ServiceRequest request = new ServiceRequest();
        
        Test.startTest();
        request.setParameter('newKey', 'newValue');
        request.setParameter('existingKey', 'value1');
        request.setParameter('existingKey', 'value2'); // Overwrite
        Test.stopTest();
        
        // Verify parameter setting and overwriting
        Assert.areEqual('newValue', request.getParameter('newKey'), 'New parameter should be set');
        Assert.areEqual('value2', request.getParameter('existingKey'), 'Existing parameter should be overwritten');
        Assert.areEqual(2, request.parameters.size(), 'Parameters map should have correct size');
    }
    
    @IsTest
    static void testSetParameterWithNullParameters() {
        ServiceRequest request = new ServiceRequest();
        request.parameters = null; // Force null state
        
        Test.startTest();
        request.setParameter('testKey', 'testValue');
        Test.stopTest();
        
        // Verify null parameters are handled
        Assert.isNotNull(request.parameters, 'Parameters should be initialized');
        Assert.areEqual('testValue', request.getParameter('testKey'), 'Parameter should be set even with null initial parameters');
    }
    
    @IsTest
    static void testGetParameterWithNullParameters() {
        ServiceRequest request = new ServiceRequest();
        request.parameters = null; // Force null state
        
        Test.startTest();
        Object value = request.getParameter('testKey');
        Test.stopTest();
        
        // Verify null parameters are handled gracefully
        Assert.isNull(value, 'Should return null when parameters map is null');
    }
    
    @IsTest
    static void testRequestIdGeneration() {
        Test.startTest();
        ServiceRequest request1 = new ServiceRequest();
        ServiceRequest request2 = new ServiceRequest();
        Test.stopTest();
        
        // Verify unique request IDs
        Assert.areNotEqual(request1.requestId, request2.requestId, 'Request IDs should be unique');
        Assert.isTrue(request1.requestId.startsWith('REQ-'), 'Request ID should have proper format');
        Assert.isTrue(request2.requestId.startsWith('REQ-'), 'Request ID should have proper format');
    }
}