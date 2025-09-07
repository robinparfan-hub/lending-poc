// Test the Flow-friendly PolicyQueryAction method
List<String> searchTerms = new List<String>{'decision'};

try {
    List<PolicyQueryAction.PolicyQueryResult> results = PolicyQueryAction.queryPolicyDocuments(searchTerms);
    
    if (!results.isEmpty()) {
        PolicyQueryAction.PolicyQueryResult result = results[0];
        System.debug('SUCCESS: ' + result.success);
        System.debug('SEARCH TERM: ' + result.searchTerm);
        System.debug('RECORD COUNT: ' + result.recordCount);
        System.debug('RESPONSE CONTENT: ' + result.responseContent);
    } else {
        System.debug('ERROR: No results returned');
    }
    
} catch (Exception e) {
    System.debug('ERROR: ' + e.getMessage());
    System.debug('ERROR TYPE: ' + e.getTypeName());
}