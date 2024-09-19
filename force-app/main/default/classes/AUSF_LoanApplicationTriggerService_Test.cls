@isTest
public class AUSF_LoanApplicationTriggerService_Test {
    @testSetup
    static void setupTestData() {
            // Create test data for Loan Application
            List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
            loanApps = AUSF_TestDataFactory.createActiveLeadLoanApplications(loanApps,5);
        	insert loanApps;
        }
    
    @isTest
    static void testPopulateInitialLoanApplicationNumber() {
        // Retrieve the test data
        List<Loan_Application__c> loanApps = [SELECT Id, Name, Stage__c, Lead_reference_number__c FROM Loan_Application__c];
        
        // Call the method to test
        Test.startTest();
        new AUSF_LoanApplicationTriggerService().populateInitialLoanApplicationNumber(loanApps);
        Test.stopTest();
        
        // Verify the results
        List<Loan_Application__c> updatedLoanApps = [SELECT Id, Name, Lead_reference_number__c FROM Loan_Application__c];
        for (Loan_Application__c loanApp : updatedLoanApps) {
            System.assertEquals(loanApp.Name, loanApp.Lead_reference_number__c, 'Loan Application Number should be updated to Lead Reference Number');
        }
    }
}