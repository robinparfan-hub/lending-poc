// Test minimal insert
Policy_Document__c testPolicy = new Policy_Document__c();
testPolicy.Title__c = 'Test Policy';
testPolicy.Category__c = 'Decision Engine';

try {
    insert testPolicy;
    System.debug('SUCCESS: Test policy inserted with ID: ' + testPolicy.Id);
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
}