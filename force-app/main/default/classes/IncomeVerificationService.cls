/**
 * @description Service for income verification and pattern analysis
 * @author Lending POC Team
 * @date 2025-09-06
 */
public with sharing class IncomeVerificationService {
    
    private static final String SERVICE_NAME = 'IncomeVerification';
    
    /**
     * @description Verify income for an applicant
     * @param applicationId The loan application ID
     * @return ServiceResponse Income verification response
     */
    @AuraEnabled(cacheable=false)
    public static ServiceResponse verifyIncomeByApplicationId(String applicationId) {
        try {
            // Check if we should use mock data or real API
            if (ServiceConfigurationHelper.shouldUseMockData(SERVICE_NAME)) {
                return getMockIncomeResponse(applicationId);
            } else {
                return getAPIIncomeResponse(applicationId);
            }
        } catch (Exception e) {
            System.debug('Error in verifyIncomeByApplicationId: ' + e.getMessage());
            return ServiceResponse.createError('Income verification failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Analyze income patterns using ML
     * @param applicationId The loan application ID
     * @return ServiceResponse Income pattern analysis response
     */
    @AuraEnabled(cacheable=false)
    public static ServiceResponse analyzeIncomePattern(String applicationId) {
        try {
            // Check if ML is enabled for income verification
            if (!ServiceConfigurationHelper.isMLEnabledForIncomeVerification()) {
                return getMockPatternAnalysisResponse(applicationId);
            }
            
            // Get applicant data
            Loan_Application__c app = [
                SELECT Id, Applicant_Profile__r.Total_Income__c,
                       Applicant_Profile__r.Employment_Status__c
                FROM Loan_Application__c
                WHERE Id = :applicationId
                LIMIT 1
            ];
            
            // Simulate getting monthly income history (in production, this would come from bank statements)
            List<Decimal> monthlyIncomes = generateMonthlyIncomeHistory(
                app.Applicant_Profile__r.Total_Income__c
            );
            
            // Simulate deposit patterns
            List<Integer> depositPatterns = generateDepositPatterns();
            
            // Call ML endpoint
            return HttpCalloutService.callIncomePatternAnalysis(
                monthlyIncomes,
                depositPatterns,
                12, // Employment months
                app.Applicant_Profile__r.Employment_Status__c,
                app.Applicant_Profile__r.Total_Income__c / 12
            );
            
        } catch (Exception e) {
            System.debug('Error in analyzeIncomePattern: ' + e.getMessage());
            return ServiceResponse.createError('Income pattern analysis failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Calculate debt-to-income ratio
     * @param monthlyIncome Monthly income amount
     * @param monthlyDebts Map of monthly debt payments
     * @return ServiceResponse DTI calculation response
     */
    @AuraEnabled(cacheable=false)
    public static ServiceResponse calculateDTI(Decimal monthlyIncome, Map<String, Decimal> monthlyDebts) {
        try {
            if (monthlyIncome == null || monthlyIncome <= 0) {
                return ServiceResponse.createError('Valid monthly income required', ServiceException.VALIDATION_ERROR);
            }
            
            Decimal totalDebts = 0;
            if (monthlyDebts != null) {
                for (Decimal debt : monthlyDebts.values()) {
                    if (debt != null) {
                        totalDebts += debt;
                    }
                }
            }
            
            Decimal dtiRatio = (totalDebts / monthlyIncome) * 100;
            
            Map<String, Object> data = new Map<String, Object>{
                'monthlyIncome' => monthlyIncome,
                'totalMonthlyDebts' => totalDebts,
                'dtiRatio' => dtiRatio.setScale(2),
                'status' => dtiRatio <= 43 ? 'ACCEPTABLE' : 'HIGH',
                'recommendation' => dtiRatio <= 36 ? 'EXCELLENT' : (dtiRatio <= 43 ? 'GOOD' : 'NEEDS_REVIEW')
            };
            
            return ServiceResponse.createSuccess(data);
            
        } catch (Exception e) {
            System.debug('Error in calculateDTI: ' + e.getMessage());
            return ServiceResponse.createError('DTI calculation failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Get mock income verification response
     * @param applicationId The loan application ID
     * @return ServiceResponse Mock response
     */
    private static ServiceResponse getMockIncomeResponse(String applicationId) {
        Map<String, Object> data = new Map<String, Object>{
            'annualIncome' => 75000,
            'monthlyIncome' => 6250,
            'verificationStatus' => 'VERIFIED',
            'verificationMethod' => 'BANK_STATEMENT',
            'verificationDate' => DateTime.now(),
            'incomeSource' => new Map<String, Object>{
                'type' => 'EMPLOYMENT',
                'employer' => 'Tech Corp',
                'jobTitle' => 'Software Engineer',
                'employmentType' => 'FULL_TIME',
                'startDate' => Date.today().addYears(-3)
            },
            'financialSummary' => new Map<String, Object>{
                'monthlyIncome' => 6250,
                'monthlyDebtPayments' => 2100,
                'disposableIncome' => 4150,
                'debtToIncomeRatio' => 33.6
            }
        };
        
        return ServiceResponse.createSuccess(data);
    }
    
    /**
     * @description Get API income verification response
     * @param applicationId The loan application ID
     * @return ServiceResponse API response
     */
    private static ServiceResponse getAPIIncomeResponse(String applicationId) {
        // Call the actual income verification API
        return HttpCalloutService.verifyIncome(applicationId);
    }
    
    /**
     * @description Get mock pattern analysis response
     * @param applicationId The loan application ID
     * @return ServiceResponse Mock response
     */
    private static ServiceResponse getMockPatternAnalysisResponse(String applicationId) {
        Map<String, Object> data = new Map<String, Object>{
            'stabilityScore' => 85,
            'verificationConfidence' => 'HIGH',
            'statistics' => new Map<String, Object>{
                'meanIncome' => 6250,
                'medianIncome' => 6250,
                'stdDeviation' => 125,
                'coefficientOfVariation' => 0.02,
                'trend' => 'STABLE',
                'trendStrength' => 0.05
            },
            'anomalies' => new List<Object>(),
            'fraudIndicators' => new List<Object>(),
            'recommendation' => 'APPROVE',
            'analysisDate' => DateTime.now()
        };
        
        return ServiceResponse.createSuccess(data);
    }
    
    /**
     * @description Generate simulated monthly income history
     * @param annualIncome Annual income amount
     * @return List<Decimal> Monthly income values
     */
    private static List<Decimal> generateMonthlyIncomeHistory(Decimal annualIncome) {
        List<Decimal> monthlyIncomes = new List<Decimal>();
        Decimal baseMonthly = annualIncome != null ? annualIncome / 12 : 5000;
        
        // Generate 12 months of income with slight variations
        for (Integer i = 0; i < 12; i++) {
            // Add small random variation (-2% to +2%)
            Decimal variation = baseMonthly * (Math.random() * 0.04 - 0.02);
            monthlyIncomes.add(baseMonthly + variation);
        }
        
        return monthlyIncomes;
    }
    
    /**
     * @description Generate simulated deposit patterns
     * @return List<Integer> Deposit counts per month
     */
    private static List<Integer> generateDepositPatterns() {
        List<Integer> patterns = new List<Integer>();
        
        // Most people get 2 deposits per month (bi-weekly pay)
        for (Integer i = 0; i < 12; i++) {
            patterns.add(2);
        }
        
        return patterns;
    }
}