/**
 * @description Test class for LoanCalculatorService
 * @author Lending POC Team
 * @date 2025-09-03
 */
@IsTest
private class LoanCalculatorServiceTest {
    
    @IsTest
    static void testCalculateMonthlyPaymentSuccess() {
        Decimal principal = 25000;
        Decimal annualRate = 6.0;
        Integer months = 60;
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.calculateMonthlyPaymentByParams(principal, annualRate, months);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
        Assert.areEqual(principal, response.data.get('principal'), 'Should contain principal');
        Assert.areEqual(annualRate, response.data.get('annualRate'), 'Should contain annual rate');
        Assert.areEqual(months, response.data.get('months'), 'Should contain months');
        Assert.isTrue(response.data.containsKey('monthlyPayment'), 'Should contain monthly payment');
        Assert.isTrue(response.data.containsKey('totalPayments'), 'Should contain total payments');
        Assert.isTrue(response.data.containsKey('totalInterest'), 'Should contain total interest');
        
        // Verify payment calculation is reasonable
        Decimal monthlyPayment = (Decimal)response.data.get('monthlyPayment');
        Assert.isTrue(monthlyPayment > 400 && monthlyPayment < 500, 'Monthly payment should be reasonable for test values');
    }
    
    @IsTest
    static void testCalculateMonthlyPaymentWithZeroInterest() {
        Decimal principal = 10000;
        Decimal annualRate = 0.0; // Zero interest
        Integer months = 12;
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.calculateMonthlyPaymentByParams(principal, annualRate, months);
        Test.stopTest();
        
        // Verify zero interest calculation
        Assert.areEqual(true, response.success, 'Response should be successful');
        Decimal expectedPayment = principal / months; // Should be simple division
        Decimal actualPayment = (Decimal)response.data.get('monthlyPayment');
        Assert.areEqual(expectedPayment, actualPayment, 'Zero interest payment should equal principal divided by months');
    }
    
    @IsTest
    static void testCalculateMonthlyPaymentWithRequest() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('principal', 30000);
        request.setParameter('annualRate', 7.5);
        request.setParameter('months', 72);
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.calculateMonthlyPayment(request);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual(30000, response.data.get('principal'), 'Should contain correct principal');
        Assert.areEqual(7.5, response.data.get('annualRate'), 'Should contain correct rate');
        Assert.areEqual(72, response.data.get('months'), 'Should contain correct months');
    }
    
    @IsTest
    static void testCalculateMonthlyPaymentInvalidParameters() {
        Test.startTest();
        ServiceResponse negPrincipal = LoanCalculatorService.calculateMonthlyPaymentByParams(-1000, 6.0, 60);
        ServiceResponse zeroPrincipal = LoanCalculatorService.calculateMonthlyPaymentByParams(0, 6.0, 60);
        ServiceResponse negRate = LoanCalculatorService.calculateMonthlyPaymentByParams(25000, -1.0, 60);
        ServiceResponse highRate = LoanCalculatorService.calculateMonthlyPaymentByParams(25000, 51.0, 60);
        ServiceResponse zeroMonths = LoanCalculatorService.calculateMonthlyPaymentByParams(25000, 6.0, 0);
        ServiceResponse highMonths = LoanCalculatorService.calculateMonthlyPaymentByParams(25000, 6.0, 481);
        Test.stopTest();
        
        // Verify validation errors
        Assert.areEqual(false, negPrincipal.success, 'Should reject negative principal');
        Assert.areEqual('VALIDATION_ERROR', negPrincipal.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, zeroPrincipal.success, 'Should reject zero principal');
        Assert.areEqual('VALIDATION_ERROR', zeroPrincipal.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, negRate.success, 'Should reject negative rate');
        Assert.areEqual('VALIDATION_ERROR', negRate.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, highRate.success, 'Should reject rate over 50%');
        Assert.areEqual('VALIDATION_ERROR', highRate.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, zeroMonths.success, 'Should reject zero months');
        Assert.areEqual('VALIDATION_ERROR', zeroMonths.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, highMonths.success, 'Should reject more than 480 months');
        Assert.areEqual('VALIDATION_ERROR', highMonths.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testCalculateMonthlyPaymentNullParameters() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('principal', null);
        request.setParameter('annualRate', 6.0);
        request.setParameter('months', 60);
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.calculateMonthlyPayment(request);
        Test.stopTest();
        
        // Verify null parameter handling
        Assert.areEqual(false, response.success, 'Should reject null principal');
        Assert.areEqual('VALIDATION_ERROR', response.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testGenerateAmortizationScheduleSuccess() {
        Decimal principal = 10000;
        Decimal annualRate = 12.0; // High rate for easier testing
        Integer months = 12;
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.generateAmortizationScheduleByParams(principal, annualRate, months);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
        Assert.areEqual(principal, response.data.get('principal'), 'Should contain principal');
        Assert.areEqual(annualRate, response.data.get('annualRate'), 'Should contain rate');
        Assert.areEqual(months, response.data.get('months'), 'Should contain months');
        Assert.isTrue(response.data.containsKey('schedule'), 'Should contain schedule');
        
        // Verify schedule structure
        List<Object> schedule = (List<Object>)response.data.get('schedule');
        Assert.areEqual(months, schedule.size(), 'Schedule should have correct number of payments');
        
        // Verify first payment structure
        Map<String, Object> firstPayment = (Map<String, Object>)schedule[0];
        Assert.areEqual(1, firstPayment.get('paymentNumber'), 'First payment should be numbered 1');
        Assert.isTrue(firstPayment.containsKey('paymentAmount'), 'Should contain payment amount');
        Assert.isTrue(firstPayment.containsKey('principalPayment'), 'Should contain principal payment');
        Assert.isTrue(firstPayment.containsKey('interestPayment'), 'Should contain interest payment');
        Assert.isTrue(firstPayment.containsKey('remainingBalance'), 'Should contain remaining balance');
        
        // Verify last payment has zero balance
        Map<String, Object> lastPayment = (Map<String, Object>)schedule[schedule.size() - 1];
        Decimal finalBalance = (Decimal)lastPayment.get('remainingBalance');
        Assert.areEqual(0, finalBalance, 'Final payment should result in zero balance');
    }
    
    @IsTest
    static void testGenerateAmortizationScheduleWithRequest() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('principal', 20000);
        request.setParameter('annualRate', 6.0);
        request.setParameter('months', 24);
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.generateAmortizationSchedule(request);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        List<Object> schedule = (List<Object>)response.data.get('schedule');
        Assert.areEqual(24, schedule.size(), 'Schedule should have 24 payments');
    }
    
    @IsTest
    static void testAmortizationScheduleProgressiveBalance() {
        Decimal principal = 5000;
        Decimal annualRate = 10.0;
        Integer months = 6;
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.generateAmortizationScheduleByParams(principal, annualRate, months);
        Test.stopTest();
        
        // Verify balance decreases over time
        List<Object> schedule = (List<Object>)response.data.get('schedule');
        Decimal previousBalance = principal;
        
        for (Object paymentObj : schedule) {
            Map<String, Object> payment = (Map<String, Object>)paymentObj;
            Decimal currentBalance = (Decimal)payment.get('remainingBalance');
            Assert.isTrue(currentBalance < previousBalance, 'Balance should decrease with each payment');
            previousBalance = currentBalance;
        }
    }
    
    @IsTest
    static void testCalculateAPRSuccess() {
        Decimal principal = 20000;
        Decimal annualRate = 8.0;
        Integer months = 48;
        Decimal fees = 500;
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.calculateAPRByParams(principal, annualRate, months, fees);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
        Assert.areEqual(principal, response.data.get('principal'), 'Should contain principal');
        Assert.areEqual(fees, response.data.get('fees'), 'Should contain fees');
        Assert.isTrue(response.data.containsKey('apr'), 'Should contain APR');
        Assert.isTrue(response.data.containsKey('netPrincipal'), 'Should contain net principal');
        
        // APR should be higher than nominal rate due to fees
        Decimal apr = (Decimal)response.data.get('apr');
        Assert.isTrue(apr > annualRate, 'APR should be higher than nominal rate when fees are present');
    }
    
    @IsTest
    static void testCalculateAPRWithZeroFees() {
        Decimal principal = 15000;
        Decimal annualRate = 7.0;
        Integer months = 36;
        Decimal fees = 0;
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.calculateAPRByParams(principal, annualRate, months, fees);
        Test.stopTest();
        
        // With zero fees, APR should be close to nominal rate
        Assert.areEqual(true, response.success, 'Response should be successful');
        Decimal apr = (Decimal)response.data.get('apr');
        Assert.isTrue(Math.abs(apr - annualRate) < 0.1, 'APR should be close to nominal rate with zero fees');
    }
    
    @IsTest
    static void testCalculateAPRInvalidParameters() {
        Test.startTest();
        ServiceResponse negFees = LoanCalculatorService.calculateAPRByParams(20000, 8.0, 48, -100);
        Test.stopTest();
        
        // Verify validation error for negative fees
        Assert.areEqual(false, negFees.success, 'Should reject negative fees');
        Assert.areEqual('VALIDATION_ERROR', negFees.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testCalculateAPRWithRequest() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('principal', 25000);
        request.setParameter('annualRate', 9.0);
        request.setParameter('months', 60);
        request.setParameter('fees', 1000);
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.calculateAPR(request);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual(24000, response.data.get('netPrincipal'), 'Net principal should be principal minus fees');
    }
    
    @IsTest
    static void testCalculateEarlyPayoffSuccess() {
        Decimal principal = 30000;
        Decimal annualRate = 8.0;
        Integer months = 60;
        Integer paymentsMade = 12;
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.calculateEarlyPayoffByParams(principal, annualRate, months, paymentsMade);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.isNotNull(response.data, 'Response should contain data');
        Assert.areEqual(principal, response.data.get('originalPrincipal'), 'Should contain original principal');
        Assert.areEqual(paymentsMade, response.data.get('paymentsMade'), 'Should contain payments made');
        Assert.isTrue(response.data.containsKey('remainingBalance'), 'Should contain remaining balance');
        Assert.isTrue(response.data.containsKey('interestSavings'), 'Should contain interest savings');
        Assert.isTrue(response.data.containsKey('monthlyPayment'), 'Should contain monthly payment');
        
        // Remaining balance should be less than original principal
        Decimal remainingBalance = (Decimal)response.data.get('remainingBalance');
        Assert.isTrue(remainingBalance < principal, 'Remaining balance should be less than original principal');
        
        // Interest savings should be positive
        Decimal interestSavings = (Decimal)response.data.get('interestSavings');
        Assert.isTrue(interestSavings > 0, 'Interest savings should be positive');
    }
    
    @IsTest
    static void testCalculateEarlyPayoffNearEnd() {
        Decimal principal = 10000;
        Decimal annualRate = 6.0;
        Integer months = 24;
        Integer paymentsMade = 23; // Almost paid off
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.calculateEarlyPayoffByParams(principal, annualRate, months, paymentsMade);
        Test.stopTest();
        
        // Verify response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Decimal remainingBalance = (Decimal)response.data.get('remainingBalance');
        Assert.isTrue(remainingBalance > 0, 'Should have small remaining balance');
        Assert.isTrue(remainingBalance < 500, 'Remaining balance should be small near end of loan');
    }
    
    @IsTest
    static void testCalculateEarlyPayoffInvalidParameters() {
        Test.startTest();
        ServiceResponse negPayments = LoanCalculatorService.calculateEarlyPayoffByParams(20000, 8.0, 60, -1);
        ServiceResponse tooManyPayments = LoanCalculatorService.calculateEarlyPayoffByParams(20000, 8.0, 60, 60);
        ServiceResponse equalPayments = LoanCalculatorService.calculateEarlyPayoffByParams(20000, 8.0, 60, 60);
        Test.stopTest();
        
        // Verify validation errors
        Assert.areEqual(false, negPayments.success, 'Should reject negative payments made');
        Assert.areEqual('VALIDATION_ERROR', negPayments.errorCode, 'Should return validation error');
        
        Assert.areEqual(false, tooManyPayments.success, 'Should reject payments made equal to term');
        Assert.areEqual('VALIDATION_ERROR', tooManyPayments.errorCode, 'Should return validation error');
    }
    
    @IsTest
    static void testCalculateEarlyPayoffWithRequest() {
        ServiceRequest request = new ServiceRequest();
        request.setParameter('principal', 40000);
        request.setParameter('annualRate', 7.5);
        request.setParameter('months', 72);
        request.setParameter('paymentsMade', 24);
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.calculateEarlyPayoff(request);
        Test.stopTest();
        
        // Verify successful response
        Assert.areEqual(true, response.success, 'Response should be successful');
        Assert.areEqual(48, response.data.get('remainingPayments'), 'Should calculate correct remaining payments');
    }
    
    @IsTest
    static void testNullRequestValidation() {
        Test.startTest();
        ServiceResponse monthlyResponse = LoanCalculatorService.calculateMonthlyPayment((ServiceRequest)null);
        ServiceResponse scheduleResponse = LoanCalculatorService.generateAmortizationSchedule((ServiceRequest)null);
        ServiceResponse aprResponse = LoanCalculatorService.calculateAPR((ServiceRequest)null);
        ServiceResponse payoffResponse = LoanCalculatorService.calculateEarlyPayoff((ServiceRequest)null);
        Test.stopTest();
        
        // All should return validation errors
        Assert.areEqual(false, monthlyResponse.success, 'Should reject null request');
        Assert.areEqual(false, scheduleResponse.success, 'Should reject null request');
        Assert.areEqual(false, aprResponse.success, 'Should reject null request');
        Assert.areEqual(false, payoffResponse.success, 'Should reject null request');
    }
    
    @IsTest
    static void testCalculationAccuracy() {
        // Test with known values for accuracy verification
        Decimal principal = 100000;
        Decimal annualRate = 6.0;
        Integer months = 360; // 30 year mortgage
        
        Test.startTest();
        ServiceResponse response = LoanCalculatorService.calculateMonthlyPaymentByParams(principal, annualRate, months);
        Test.stopTest();
        
        // Verify calculation accuracy (should be around $599.55 for these values)
        Assert.areEqual(true, response.success, 'Response should be successful');
        Decimal monthlyPayment = (Decimal)response.data.get('monthlyPayment');
        Assert.isTrue(Math.abs(monthlyPayment - 599.55) < 1.0, 'Monthly payment should be accurate within $1');
    }
}