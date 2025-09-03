/**
 * @description Service for performing loan calculations using standard financial formulas
 * @author Lending POC Team
 * @date 2025-09-03
 */
public with sharing class LoanCalculatorService {
    
    // Configuration from Custom Labels (USE_MOCK_DATA included for consistency, though calculations are always real)
    private static Boolean USE_MOCK_DATA {
        get {
            if (USE_MOCK_DATA == null) {
                String labelValue = System.Label.Use_Mock_Data;
                USE_MOCK_DATA = (labelValue != null && labelValue.equalsIgnoreCase('true'));
            }
            return USE_MOCK_DATA;
        }
        set;
    }
    private static final String SERVICE_NAME = 'LoanCalculatorService';
    private static final Decimal MAX_LOAN_AMOUNT = Decimal.valueOf(System.Label.Max_Loan_Amount);
    
    /**
     * @description Calculate monthly payment for a loan
     * @param principal Loan principal amount
     * @param annualRate Annual interest rate (as percentage, e.g., 6.5)
     * @param months Loan term in months
     * @return ServiceResponse Monthly payment calculation
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse calculateMonthlyPaymentByParams(Decimal principal, Decimal annualRate, Integer months) {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('principal', principal);
        request.setParameter('annualRate', annualRate);
        request.setParameter('months', months);
        return calculateMonthlyPayment(request);
    }
    
    /**
     * @description Calculate monthly payment for a loan (full request)
     * @param request Service request containing loan parameters
     * @return ServiceResponse Monthly payment calculation
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse calculateMonthlyPayment(ServiceRequest request) {
        try {
            // Input validation
            validateLoanParameters(request);
            
            // Log service call
            System.debug('LoanCalculatorService.calculateMonthlyPayment called with request: ' + request);
            
            Decimal principal = (Decimal)request.getParameter('principal');
            Decimal annualRate = (Decimal)request.getParameter('annualRate');
            Integer months = (Integer)request.getParameter('months');
            
            // Calculate monthly payment using standard amortization formula
            Decimal monthlyPayment = calculatePayment(principal, annualRate, months);
            
            Map<String, Object> data = new Map<String, Object>();
            data.put('principal', principal);
            data.put('annualRate', annualRate);
            data.put('months', months);
            data.put('monthlyPayment', monthlyPayment);
            data.put('totalPayments', monthlyPayment * months);
            data.put('totalInterest', (monthlyPayment * months) - principal);
            
            return ServiceResponse.createSuccess(data);
            
        } catch (ServiceException e) {
            return ServiceResponse.createError(e.getMessage(), e.getErrorCode());
        } catch (Exception e) {
            System.debug('Unexpected error in calculateMonthlyPayment: ' + e.getMessage());
            return ServiceResponse.createError('Payment calculation failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Generate full amortization schedule
     * @param principal Loan principal amount
     * @param annualRate Annual interest rate (as percentage)
     * @param months Loan term in months
     * @return ServiceResponse Amortization schedule
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse generateAmortizationScheduleByParams(Decimal principal, Decimal annualRate, Integer months) {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('principal', principal);
        request.setParameter('annualRate', annualRate);
        request.setParameter('months', months);
        return generateAmortizationSchedule(request);
    }
    
    /**
     * @description Generate full amortization schedule (full request)
     * @param request Service request containing loan parameters
     * @return ServiceResponse Amortization schedule
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse generateAmortizationSchedule(ServiceRequest request) {
        try {
            // Input validation
            validateLoanParameters(request);
            
            // Log service call
            System.debug('LoanCalculatorService.generateAmortizationSchedule called with request: ' + request);
            
            Decimal principal = (Decimal)request.getParameter('principal');
            Decimal annualRate = (Decimal)request.getParameter('annualRate');
            Integer months = (Integer)request.getParameter('months');
            
            // Calculate monthly payment
            Decimal monthlyPayment = calculatePayment(principal, annualRate, months);
            
            // Generate amortization schedule
            List<Object> schedule = generateSchedule(principal, annualRate, months, monthlyPayment);
            
            Map<String, Object> data = new Map<String, Object>();
            data.put('principal', principal);
            data.put('annualRate', annualRate);
            data.put('months', months);
            data.put('monthlyPayment', monthlyPayment);
            data.put('schedule', schedule);
            data.put('totalPayments', monthlyPayment * months);
            data.put('totalInterest', (monthlyPayment * months) - principal);
            
            return ServiceResponse.createSuccess(data);
            
        } catch (ServiceException e) {
            return ServiceResponse.createError(e.getMessage(), e.getErrorCode());
        } catch (Exception e) {
            System.debug('Unexpected error in generateAmortizationSchedule: ' + e.getMessage());
            return ServiceResponse.createError('Amortization schedule generation failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Calculate APR including fees
     * @param principal Loan principal amount
     * @param annualRate Annual interest rate (as percentage)
     * @param months Loan term in months
     * @param fees Total fees charged
     * @return ServiceResponse APR calculation
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse calculateAPRByParams(Decimal principal, Decimal annualRate, Integer months, Decimal fees) {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('principal', principal);
        request.setParameter('annualRate', annualRate);
        request.setParameter('months', months);
        request.setParameter('fees', fees);
        return calculateAPR(request);
    }
    
    /**
     * @description Calculate APR including fees (full request)
     * @param request Service request containing loan parameters and fees
     * @return ServiceResponse APR calculation
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse calculateAPR(ServiceRequest request) {
        try {
            // Input validation
            validateAPRParameters(request);
            
            // Log service call
            System.debug('LoanCalculatorService.calculateAPR called with request: ' + request);
            
            Decimal principal = (Decimal)request.getParameter('principal');
            Decimal annualRate = (Decimal)request.getParameter('annualRate');
            Integer months = (Integer)request.getParameter('months');
            Decimal fees = (Decimal)request.getParameter('fees');
            
            // Calculate APR using iterative method
            Decimal apr = calculateActualAPR(principal, annualRate, months, fees);
            
            Map<String, Object> data = new Map<String, Object>();
            data.put('principal', principal);
            data.put('annualRate', annualRate);
            data.put('months', months);
            data.put('fees', fees);
            data.put('apr', apr);
            data.put('netPrincipal', principal - fees);
            
            return ServiceResponse.createSuccess(data);
            
        } catch (ServiceException e) {
            return ServiceResponse.createError(e.getMessage(), e.getErrorCode());
        } catch (Exception e) {
            System.debug('Unexpected error in calculateAPR: ' + e.getMessage());
            return ServiceResponse.createError('APR calculation failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Calculate early payoff amount
     * @param principal Original principal
     * @param annualRate Annual interest rate
     * @param months Original term
     * @param paymentsMade Number of payments made
     * @return ServiceResponse Early payoff calculation
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse calculateEarlyPayoffByParams(Decimal principal, Decimal annualRate, Integer months, Integer paymentsMade) {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('principal', principal);
        request.setParameter('annualRate', annualRate);
        request.setParameter('months', months);
        request.setParameter('paymentsMade', paymentsMade);
        return calculateEarlyPayoff(request);
    }
    
    /**
     * @description Calculate early payoff amount (full request)
     * @param request Service request containing loan parameters and payments made
     * @return ServiceResponse Early payoff calculation
     */
    @AuraEnabled(cacheable=true)
    public static ServiceResponse calculateEarlyPayoff(ServiceRequest request) {
        try {
            // Input validation
            validateEarlyPayoffParameters(request);
            
            // Log service call
            System.debug('LoanCalculatorService.calculateEarlyPayoff called with request: ' + request);
            
            Decimal principal = (Decimal)request.getParameter('principal');
            Decimal annualRate = (Decimal)request.getParameter('annualRate');
            Integer months = (Integer)request.getParameter('months');
            Integer paymentsMade = (Integer)request.getParameter('paymentsMade');
            
            // Calculate remaining balance
            Decimal monthlyPayment = calculatePayment(principal, annualRate, months);
            Decimal remainingBalance = calculateRemainingBalance(principal, annualRate, months, paymentsMade, monthlyPayment);
            
            // Calculate interest savings
            Decimal remainingPayments = months - paymentsMade;
            Decimal interestSavings = (monthlyPayment * remainingPayments) - remainingBalance;
            
            Map<String, Object> data = new Map<String, Object>();
            data.put('originalPrincipal', principal);
            data.put('monthlyPayment', monthlyPayment);
            data.put('paymentsMade', paymentsMade);
            data.put('remainingBalance', remainingBalance);
            data.put('remainingPayments', remainingPayments);
            data.put('interestSavings', interestSavings);
            
            return ServiceResponse.createSuccess(data);
            
        } catch (ServiceException e) {
            return ServiceResponse.createError(e.getMessage(), e.getErrorCode());
        } catch (Exception e) {
            System.debug('Unexpected error in calculateEarlyPayoff: ' + e.getMessage());
            return ServiceResponse.createError('Early payoff calculation failed', ServiceException.SYSTEM_ERROR);
        }
    }
    
    /**
     * @description Validate basic loan parameters
     * @param request Service request to validate
     */
    private static void validateLoanParameters(ServiceRequest request) {
        if (request == null) {
            throw new ServiceException('Request cannot be null', ServiceException.VALIDATION_ERROR);
        }
        
        Decimal principal = (Decimal)request.getParameter('principal');
        if (principal == null || principal <= 0) {
            throw new ServiceException('Principal must be a positive number', ServiceException.VALIDATION_ERROR);
        }
        
        Decimal annualRate = (Decimal)request.getParameter('annualRate');
        if (annualRate == null || annualRate < 0 || annualRate > 50) {
            throw new ServiceException('Annual rate must be between 0 and 50 percent', ServiceException.VALIDATION_ERROR);
        }
        
        Integer months = (Integer)request.getParameter('months');
        if (months == null || months <= 0 || months > 480) {
            throw new ServiceException('Loan term must be between 1 and 480 months', ServiceException.VALIDATION_ERROR);
        }
    }
    
    /**
     * @description Validate APR calculation parameters
     * @param request Service request to validate
     */
    private static void validateAPRParameters(ServiceRequest request) {
        validateLoanParameters(request);
        
        Decimal fees = (Decimal)request.getParameter('fees');
        if (fees == null || fees < 0) {
            throw new ServiceException('Fees must be zero or positive', ServiceException.VALIDATION_ERROR);
        }
    }
    
    /**
     * @description Validate early payoff parameters
     * @param request Service request to validate
     */
    private static void validateEarlyPayoffParameters(ServiceRequest request) {
        validateLoanParameters(request);
        
        Integer paymentsMade = (Integer)request.getParameter('paymentsMade');
        Integer months = (Integer)request.getParameter('months');
        
        if (paymentsMade == null || paymentsMade < 0) {
            throw new ServiceException('Payments made must be zero or positive', ServiceException.VALIDATION_ERROR);
        }
        
        if (paymentsMade >= months) {
            throw new ServiceException('Payments made cannot exceed loan term', ServiceException.VALIDATION_ERROR);
        }
    }
    
    /**
     * @description Calculate monthly payment using standard amortization formula
     * @param principal Loan principal
     * @param annualRate Annual interest rate (percentage)
     * @param months Loan term in months
     * @return Decimal Monthly payment amount
     */
    private static Decimal calculatePayment(Decimal principal, Decimal annualRate, Integer months) {
        if (annualRate == 0) {
            return principal / months; // No interest case
        }
        
        Decimal monthlyRate = annualRate / 100 / 12; // Convert to monthly decimal rate
        Decimal factor = power(1 + monthlyRate, months);
        
        return principal * (monthlyRate * factor) / (factor - 1);
    }
    
    /**
     * @description Generate complete amortization schedule
     * @param principal Loan principal
     * @param annualRate Annual interest rate
     * @param months Loan term
     * @param monthlyPayment Monthly payment amount
     * @return List<Object> Amortization schedule
     */
    private static List<Object> generateSchedule(Decimal principal, Decimal annualRate, Integer months, Decimal monthlyPayment) {
        List<Object> schedule = new List<Object>();
        Decimal balance = principal;
        Decimal monthlyRate = annualRate / 100 / 12;
        
        for (Integer i = 1; i <= months; i++) {
            Decimal interestPayment = balance * monthlyRate;
            Decimal principalPayment = monthlyPayment - interestPayment;
            balance = balance - principalPayment;
            
            // Ensure balance doesn't go negative due to rounding
            if (balance < 0) {
                principalPayment = principalPayment + balance;
                balance = 0;
            }
            
            Map<String, Object> payment = new Map<String, Object>();
            payment.put('paymentNumber', i);
            payment.put('paymentAmount', monthlyPayment.setScale(2));
            payment.put('principalPayment', principalPayment.setScale(2));
            payment.put('interestPayment', interestPayment.setScale(2));
            payment.put('remainingBalance', balance.setScale(2));
            
            schedule.add(payment);
            
            // Break if balance is zero
            if (balance == 0) {
                break;
            }
        }
        
        return schedule;
    }
    
    /**
     * @description Calculate APR using iterative method
     * @param principal Loan principal
     * @param annualRate Nominal interest rate
     * @param months Loan term
     * @param fees Total fees
     * @return Decimal APR percentage
     */
    private static Decimal calculateActualAPR(Decimal principal, Decimal annualRate, Integer months, Decimal fees) {
        // For simplicity, using approximation formula
        // In real implementation, would use Newton-Raphson method
        Decimal netPrincipal = principal - fees;
        Decimal monthlyPayment = calculatePayment(principal, annualRate, months);
        
        // Simple approximation: adjust rate based on fee impact
        Decimal feeImpact = (fees / netPrincipal) * (12.0 / months);
        return annualRate + (feeImpact * 100);
    }
    
    /**
     * @description Calculate remaining balance after specified payments
     * @param principal Original principal
     * @param annualRate Annual interest rate
     * @param months Original term
     * @param paymentsMade Payments made
     * @param monthlyPayment Monthly payment amount
     * @return Decimal Remaining balance
     */
    private static Decimal calculateRemainingBalance(Decimal principal, Decimal annualRate, Integer months, Integer paymentsMade, Decimal monthlyPayment) {
        Decimal balance = principal;
        Decimal monthlyRate = annualRate / 100 / 12;
        
        for (Integer i = 0; i < paymentsMade; i++) {
            Decimal interestPayment = balance * monthlyRate;
            Decimal principalPayment = monthlyPayment - interestPayment;
            balance = balance - principalPayment;
            
            if (balance <= 0) {
                balance = 0;
                break;
            }
        }
        
        return balance.setScale(2);
    }
    
    /**
     * @description Calculate power (base^exponent) since Math.pow doesn't exist in Apex
     * @param base Base value
     * @param exponent Exponent value
     * @return Decimal Result of base raised to exponent
     */
    private static Decimal power(Decimal base, Integer exponent) {
        if (exponent == 0) return 1.0;
        if (exponent == 1) return base;
        
        Decimal result = 1.0;
        for (Integer i = 0; i < exponent; i++) {
            result = result * base;
        }
        return result;
    }
}