/**
 * @description Agent Action to query policy documents for Agentforce
 * @author Claude Code
 * @date September 2025
 */
public class PolicyQueryAction {
    
    // Flow-friendly method with simple string input
    @InvocableMethod(label='Query Policy Documents' 
                     description='Search policy documents based on keywords for agent responses'
                     category='Agentforce Actions')
    public static List<PolicyQueryResult> queryPolicyDocuments(List<String> searchTerms) {
        List<PolicyQueryResult> results = new List<PolicyQueryResult>();
        
        if (searchTerms.isEmpty()) {
            results.add(createErrorResult('No search terms provided'));
            return results;
        }
        
        String searchTerm = searchTerms[0];
        return performPolicyQuery(searchTerm);
    }
    
    // Original method for direct Apex calls
    public static List<PolicyQueryResult> queryPolicyDocumentsWithRequest(List<PolicyQueryRequest> requests) {
        List<PolicyQueryResult> results = new List<PolicyQueryResult>();
        
        if (requests.isEmpty()) {
            results.add(createErrorResult('No search terms provided'));
            return results;
        }
        
        String searchTerm = requests[0].searchTerm;
        return performPolicyQuery(searchTerm);
    }
    
    // Shared method to perform the actual policy query
    private static List<PolicyQueryResult> performPolicyQuery(String searchTerm) {
        List<PolicyQueryResult> results = new List<PolicyQueryResult>();
        System.debug('PolicyQueryAction: Searching for term: ' + searchTerm);
        
        try {
            // Query policy documents based on title or category
            List<Policy_Document__c> policies = [
                SELECT Id, Name, Title__c, Category__c 
                FROM Policy_Document__c 
                WHERE Title__c LIKE :('%' + searchTerm + '%')
                OR Category__c LIKE :('%' + searchTerm + '%')
                ORDER BY CreatedDate DESC
                LIMIT 5
            ];
            
            if (policies.isEmpty()) {
                results.add(createNoResultsFound(searchTerm));
            } else {
                results.add(createSuccessResult(policies, searchTerm));
            }
            
        } catch (Exception e) {
            System.debug('PolicyQueryAction ERROR: ' + e.getMessage());
            results.add(createErrorResult('Error searching policies: ' + e.getMessage()));
        }
        
        return results;
    }
    
    private static PolicyQueryResult createSuccessResult(List<Policy_Document__c> policies, String searchTerm) {
        PolicyQueryResult result = new PolicyQueryResult();
        result.success = true;
        result.searchTerm = searchTerm;
        result.recordCount = policies.size();
        
        // Build response content
        String content = 'I found ' + policies.size() + ' policy document(s) related to "' + searchTerm + '":\n\n';
        
        for (Policy_Document__c policy : policies) {
            content += '• ' + policy.Title__c + ' (Category: ' + policy.Category__c + ')\n';
            content += '  Record: ' + policy.Name + ' | ID: ' + policy.Id + '\n\n';
        }
        
        // Add specific decision engine guidance if found
        if (searchTerm.toLowerCase().contains('decision') || searchTerm.toLowerCase().contains('approval')) {
            content += 'KEY DECISION ENGINE GUIDANCE:\n';
            content += '• APPROVED (≥75% probability): Full approval, competitive rates\n';
            content += '• APPROVED_WITH_CONDITIONS (50-74%): Conditional approval, higher rates\n';
            content += '• PENDING_REVIEW (30-49%): Manual review required\n';
            content += '• DENIED (<30%): Automatic denial\n\n';
            content += 'Main risk factors: Credit Score (highest impact), Previous Defaults, DTI Ratio, Employment Stability\n';
            content += 'Interest Rate = Base Rate (5.5%) + Risk Premium based on approval probability\n\n';
        }
        
        content += 'Would you like me to explain any specific aspect of these policies?';
        
        result.responseContent = content;
        return result;
    }
    
    private static PolicyQueryResult createNoResultsFound(String searchTerm) {
        PolicyQueryResult result = new PolicyQueryResult();
        result.success = true;
        result.searchTerm = searchTerm;
        result.recordCount = 0;
        result.responseContent = 'I didn\'t find any policy documents specifically matching "' + searchTerm + '". ' +
            'However, I have access to our Decision Engine Policy which covers loan approval processes, ' +
            'risk factors, and interest rate calculations. Would you like me to help with a specific question about our lending policies?';
        return result;
    }
    
    private static PolicyQueryResult createErrorResult(String errorMessage) {
        PolicyQueryResult result = new PolicyQueryResult();
        result.success = false;
        result.responseContent = 'I encountered an issue accessing our policy documents: ' + errorMessage + 
            '. Please try rephrasing your question or contact support for assistance.';
        return result;
    }
    
    // Input wrapper class
    public class PolicyQueryRequest {
        @InvocableVariable(required=true description='Search term for policy documents')
        public String searchTerm;
    }
    
    // Output wrapper class
    public class PolicyQueryResult {
        @InvocableVariable(description='Whether the query was successful')
        public Boolean success;
        
        @InvocableVariable(description='The search term used')
        public String searchTerm;
        
        @InvocableVariable(description='Number of records found')
        public Integer recordCount;
        
        @InvocableVariable(description='Response content for the agent')
        public String responseContent;
    }
}