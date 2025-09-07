// Query all fields to see what's available
List<Policy_Document__c> allPolicies = [SELECT FIELDS(ALL) FROM Policy_Document__c LIMIT 5];

for (Policy_Document__c policy : allPolicies) {
    System.debug('Policy: ' + policy);
}