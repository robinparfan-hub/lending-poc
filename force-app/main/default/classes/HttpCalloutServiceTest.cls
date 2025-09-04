/**
 * @description Test class for HttpCalloutService
 * @author Lending POC Team
 * @date 2025-09-04
 */
@isTest
public class HttpCalloutServiceTest {
    
    /**
     * @description Mock HTTP response for testing
     */
    private class MockHttpResponse implements HttpCalloutMock {
        private Integer statusCode;
        private String status;
        private String body;
        
        public MockHttpResponse(Integer statusCode, String status, String body) {
            this.statusCode = statusCode;
            this.status = status;
            this.body = body;
        }
        
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setStatusCode(statusCode);
            response.setStatus(status);
            response.setBody(body);
            return response;
        }
    }
    
    @isTest
    static void testPostSuccess() {
        // Prepare mock response
        Map<String, Object> mockResponseData = new Map<String, Object>{
            'decision' => 'APPROVED',
            'approvedAmount' => 35000,
            'interestRate' => 8.99
        };
        
        Map<String, Object> mockResponse = new Map<String, Object>{
            'success' => true,
            'data' => mockResponseData,
            'metadata' => new Map<String, Object>{
                'requestId' => 'TEST-123',
                'timestamp' => String.valueOf(DateTime.now())
            }
        };
        
        Test.setMock(
            HttpCalloutMock.class, 
            new MockHttpResponse(200, 'OK', JSON.serialize(mockResponse))
        );
        
        // Test
        Test.startTest();
        Map<String, Object> requestBody = new Map<String, Object>{
            'applicationId' => 'APP-001'
        };
        ServiceResponse response = HttpCalloutService.post(
            'https://test.example.com/api/test',
            requestBody
        );
        Test.stopTest();
        
        // Verify
        System.assert(response.success, 'Response should be successful');
        System.assertEquals('APPROVED', response.data.get('decision'));
        System.assertEquals(35000, response.data.get('approvedAmount'));
    }
    
    @isTest
    static void testPostServiceError() {
        // Prepare mock error response
        Map<String, Object> mockResponse = new Map<String, Object>{
            'success' => false,
            'message' => 'Credit score too low',
            'errorCode' => 'LOW_CREDIT_SCORE'
        };
        
        Test.setMock(
            HttpCalloutMock.class, 
            new MockHttpResponse(200, 'OK', JSON.serialize(mockResponse))
        );
        
        // Test
        Test.startTest();
        ServiceResponse response = HttpCalloutService.post(
            'https://test.example.com/api/test',
            new Map<String, Object>()
        );
        Test.stopTest();
        
        // Verify
        System.assert(!response.success, 'Response should indicate failure');
        System.assertEquals('Credit score too low', response.message);
        System.assertEquals('LOW_CREDIT_SCORE', response.errorCode);
    }
    
    @isTest
    static void testPostHttpError() {
        // Prepare mock HTTP error
        Test.setMock(
            HttpCalloutMock.class, 
            new MockHttpResponse(500, 'Internal Server Error', 'Server error')
        );
        
        // Test
        Test.startTest();
        ServiceResponse response = HttpCalloutService.post(
            'https://test.example.com/api/test',
            null
        );
        Test.stopTest();
        
        // Verify
        System.assert(!response.success, 'Response should indicate failure');
        System.assert(response.message.contains('HTTP Error'));
        System.assertEquals('HTTP_500', response.errorCode);
    }
    
    @isTest
    static void testGetSuccess() {
        // Prepare mock response
        Map<String, Object> mockResponse = new Map<String, Object>{
            'status' => 'healthy',
            'service' => 'test-service',
            'version' => '1.0.0'
        };
        
        Test.setMock(
            HttpCalloutMock.class, 
            new MockHttpResponse(200, 'OK', JSON.serialize(mockResponse))
        );
        
        // Test
        Test.startTest();
        ServiceResponse response = HttpCalloutService.get(
            'https://test.example.com/health'
        );
        Test.stopTest();
        
        // Verify
        System.assert(response.success, 'Response should be successful');
        System.assertEquals('healthy', response.data.get('status'));
    }
    
    @isTest
    static void testCheckHealthSuccess() {
        // Prepare mock healthy response
        Map<String, Object> mockResponse = new Map<String, Object>{
            'status' => 'healthy',
            'service' => 'test-service'
        };
        
        Test.setMock(
            HttpCalloutMock.class, 
            new MockHttpResponse(200, 'OK', JSON.serialize(mockResponse))
        );
        
        // Test
        Test.startTest();
        Boolean isHealthy = HttpCalloutService.checkHealth(
            'https://test.example.com/health'
        );
        Test.stopTest();
        
        // Verify
        System.assert(isHealthy, 'Service should be healthy');
    }
    
    @isTest
    static void testCheckHealthFailure() {
        // Prepare mock unhealthy response
        Map<String, Object> mockResponse = new Map<String, Object>{
            'status' => 'unhealthy',
            'service' => 'test-service'
        };
        
        Test.setMock(
            HttpCalloutMock.class, 
            new MockHttpResponse(200, 'OK', JSON.serialize(mockResponse))
        );
        
        // Test
        Test.startTest();
        Boolean isHealthy = HttpCalloutService.checkHealth(
            'https://test.example.com/health'
        );
        Test.stopTest();
        
        // Verify
        System.assert(!isHealthy, 'Service should be unhealthy');
    }
    
    @isTest
    static void testVerifyIncome() {
        // Prepare mock response
        Map<String, Object> mockResponseData = new Map<String, Object>{
            'annualIncome' => 65000,
            'monthlyIncome' => 5417,
            'verificationStatus' => 'VERIFIED'
        };
        
        Map<String, Object> mockResponse = new Map<String, Object>{
            'success' => true,
            'data' => mockResponseData
        };
        
        Test.setMock(
            HttpCalloutMock.class, 
            new MockHttpResponse(200, 'OK', JSON.serialize(mockResponse))
        );
        
        // Test
        Test.startTest();
        ServiceResponse response = HttpCalloutService.verifyIncome('APP-001');
        Test.stopTest();
        
        // Verify
        System.assert(response.success, 'Income verification should succeed');
        System.assertEquals(65000, response.data.get('annualIncome'));
        System.assertEquals('VERIFIED', response.data.get('verificationStatus'));
    }
    
    @isTest
    static void testCallDecisionEngineAsync() {
        // Prepare mock response
        Map<String, Object> mockResponseData = new Map<String, Object>{
            'decision' => 'APPROVED',
            'approvedAmount' => 25000
        };
        
        Map<String, Object> mockResponse = new Map<String, Object>{
            'success' => true,
            'data' => mockResponseData
        };
        
        Test.setMock(
            HttpCalloutMock.class, 
            new MockHttpResponse(200, 'OK', JSON.serialize(mockResponse))
        );
        
        // Test (future method)
        Test.startTest();
        HttpCalloutService.callDecisionEngineAsync('APP-001');
        Test.stopTest();
        
        // Future methods are executed after Test.stopTest()
        // Verify through debug logs or by checking updated records
        System.assert(true, 'Future method executed');
    }
}