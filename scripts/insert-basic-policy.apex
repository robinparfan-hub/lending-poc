// Insert policy with just Title and Category for now
Policy_Document__c decisionEnginePolicy = new Policy_Document__c();

decisionEnginePolicy.Title__c = 'Decision Engine Service Policy & ML Model Documentation';
decisionEnginePolicy.Category__c = 'Decision Engine';

try {
    insert decisionEnginePolicy;
    System.debug('SUCCESS: Policy document inserted with ID: ' + decisionEnginePolicy.Id);
    
    // Query to verify
    Policy_Document__c inserted = [SELECT Id, Name, Title__c, Category__c FROM Policy_Document__c WHERE Id = :decisionEnginePolicy.Id];
    System.debug('Inserted record: ' + inserted.Name + ' - ' + inserted.Title__c);
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('ERROR TYPE: ' + e.getTypeName());
}