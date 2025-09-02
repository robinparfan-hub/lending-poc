@isTest
private class HelloWorldTest {
    
    @isTest
    static void testSayHello() {
        Test.startTest();
        String result = HelloWorld.sayHello();
        Test.stopTest();
        
        System.assertEquals('Hello World!', result, 'Should return Hello World!');
    }
    
    @isTest
    static void testSayHelloToName() {
        Test.startTest();
        String result = HelloWorld.sayHelloToName('Salesforce');
        Test.stopTest();
        
        System.assertEquals('Hello Salesforce!', result, 'Should return personalized greeting');
    }
    
    @isTest
    static void testSayHelloToNameWithNull() {
        Test.startTest();
        String result = HelloWorld.sayHelloToName(null);
        Test.stopTest();
        
        System.assertEquals('Hello World!', result, 'Should return default greeting for null');
    }
    
    @isTest
    static void testSayHelloToNameWithEmptyString() {
        Test.startTest();
        String result = HelloWorld.sayHelloToName('');
        Test.stopTest();
        
        System.assertEquals('Hello World!', result, 'Should return default greeting for empty string');
    }
    
    @isTest
    static void testSayHelloToNameWithBlankString() {
        Test.startTest();
        String result = HelloWorld.sayHelloToName('   ');
        Test.stopTest();
        
        System.assertEquals('Hello World!', result, 'Should return default greeting for blank string');
    }
    
    @isTest
    static void testSayHelloToCurrentUser() {
        // Create a test user
        User testUser = new User(
            FirstName = 'Test',
            LastName = 'User',
            Email = 'testuser@example.com',
            Username = 'testuser' + DateTime.now().getTime() + '@example.com',
            Alias = 'tuser',
            TimeZoneSidKey = 'America/Los_Angeles',
            LocaleSidKey = 'en_US',
            EmailEncodingKey = 'UTF-8',
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1].Id,
            LanguageLocaleKey = 'en_US'
        );
        insert testUser;
        
        System.runAs(testUser) {
            Test.startTest();
            String result = HelloWorld.sayHelloToCurrentUser();
            Test.stopTest();
            
            System.assertEquals('Hello Test User!', result, 'Should return greeting with current user name');
        }
    }
    
    @isTest
    static void testSayMultipleHellos() {
        Test.startTest();
        List<String> results = HelloWorld.sayMultipleHellos(3);
        Test.stopTest();
        
        System.assertEquals(3, results.size(), 'Should return 3 greetings');
        System.assertEquals('Hello #1!', results[0], 'First greeting should be Hello #1!');
        System.assertEquals('Hello #2!', results[1], 'Second greeting should be Hello #2!');
        System.assertEquals('Hello #3!', results[2], 'Third greeting should be Hello #3!');
    }
    
    @isTest
    static void testSayMultipleHellosWithZero() {
        Test.startTest();
        List<String> results = HelloWorld.sayMultipleHellos(0);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return 1 default greeting');
        System.assertEquals('Hello World!', results[0], 'Should return default greeting');
    }
    
    @isTest
    static void testSayMultipleHellosWithNegative() {
        Test.startTest();
        List<String> results = HelloWorld.sayMultipleHellos(-5);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return 1 default greeting');
        System.assertEquals('Hello World!', results[0], 'Should return default greeting');
    }
    
    @isTest
    static void testSayMultipleHellosWithNull() {
        Test.startTest();
        List<String> results = HelloWorld.sayMultipleHellos(null);
        Test.stopTest();
        
        System.assertEquals(1, results.size(), 'Should return 1 default greeting');
        System.assertEquals('Hello World!', results[0], 'Should return default greeting');
    }
    
    @isTest
    static void testCodeCoverage() {
        // This test ensures we have 100% code coverage
        HelloWorld hw = new HelloWorld();
        System.assertNotEquals(null, hw, 'Constructor should work');
    }
}