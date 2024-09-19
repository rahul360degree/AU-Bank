@isTest
public with sharing class AUPL_LoanApplicationService_Test {
    @testSetup
    static void setupTestData() { 
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();   
        loanApps = AUPL_TestDataFactory.createActiveLoanApplications(loanApps,1);
        loanApps=AUPL_TestDataFactory.createCancelledLoanApplications(loanApps,1);
        loanApps=AUPL_TestDataFactory.createRejectLoanApplications(loanApps,1);
        loanApps=AUPL_TestDataFactory.createDisbursedLoanApplications(loanApps,1);
        insert loanApps;
        

    }
    @isTest
    static void testlocalDedupeSearch_ActiveApplication() {
        Test.startTest();
        Map<String,AUPL_LoanApplicationService.DedupeResult> result = AUPL_LoanApplicationService.localDedupeSearch(new List<String>{'1234567890'});
        Test.stopTest();
        System.assertEquals('Resume', result.get('1234567890').dedupeStatus);
        Assert.isNotNull(result.get('1234567890').existingLoanApplication);
        System.assertEquals('Pending', result.get('1234567890').existingLoanApplication.Stage__c);
    }
    @isTest
    static void testlocalDedupeSearch_CancelledApplication() {
        // Remove active application to test cancelled scenario
        delete [SELECT Id FROM Loan_Application__c WHERE Stage__c IN ('Pending','Reject','Disbursed')];
        Test.startTest();
        Map<String,AUPL_LoanApplicationService.DedupeResult> result = AUPL_LoanApplicationService.localDedupeSearch(new List<String>{'1234567890'});
        Test.stopTest();
        System.assertEquals('New', result.get('1234567890').dedupeStatus);
        Assert.isNotNull(result.get('1234567890').existingLoanApplication);
        System.assertEquals('1234567890', result.get('1234567890').existingLoanApplication.Mobile_Number__c);
    }
    @isTest
    static void testlocalDedupeSearch_DisbursedApplication() {
        // Remove active application to test cancelled scenario
        delete [SELECT Id FROM Loan_Application__c WHERE Stage__c IN ('Pending')];
        Test.startTest();
        Map<String,AUPL_LoanApplicationService.DedupeResult> result = AUPL_LoanApplicationService.localDedupeSearch(new List<String>{'1234567890'});
        Test.stopTest();
        System.assertEquals('Disbursed', result.get('1234567890').dedupeStatus);
        Assert.isNotNull(result.get('1234567890').existingLoanApplication);
        System.assertEquals('1234567890', result.get('1234567890').existingLoanApplication.Mobile_Number__c);
    }
    @isTest
    static void testlocalDedupeSearch_RejectedApplication() {
        // Remove active and cancelled applications to test rejected scenario
        delete [SELECT Id FROM Loan_Application__c WHERE Stage__c IN ('Pending', 'Cancelled','Disbursed')];
        Test.startTest();
        Map<String,AUPL_LoanApplicationService.DedupeResult> result = AUPL_LoanApplicationService.localDedupeSearch(new List<String>{'1234567890'});
        Test.stopTest();
        System.assertEquals('Reject', result.get('1234567890').dedupeStatus);
        Assert.isNotNull(result.get('1234567890').existingLoanApplication);
        System.assertEquals('Reject', result.get('1234567890').existingLoanApplication.Stage__c);
        System.assert(result.get('1234567890').message.contains('Lead has been rejected with following params'));
    }
    @isTest
    static void testlocalDedupeSearch_NoExistingApplication() {
        Test.startTest();
        Map<String,AUPL_LoanApplicationService.DedupeResult> result = AUPL_LoanApplicationService.localDedupeSearch(new List<String>{'0987654321'});
        Test.stopTest();
        System.assertEquals('New', result.get('0987654321').dedupeStatus);
        Assert.isNotNull(result.get('0987654321').existingLoanApplication);
        System.assertEquals('0987654321', result.get('0987654321').existingLoanApplication.Mobile_Number__c);
    }
}