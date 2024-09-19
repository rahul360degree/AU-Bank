@isTest
public with sharing class AUPL_TestDataFactory {
    public static List<Loan_Application__c> createActiveLoanApplications(List<Loan_Application__c> loanApps,Integer numofLoanRecord) {
        for(Integer i=0;i<numofLoanRecord;i++){
            Loan_Application__c loanApp = new Loan_Application__c();
            loanApp.Mobile_Number__c = '1234567890';
            loanApp.Stage__c = 'Pending';
            loanApp.Exempt_Duplicate__c = false;
            loanApps.add(loanApp);
        }
        
        return loanApps;
    }
    public static List<Loan_Application__c> createCancelledLoanApplications(List<Loan_Application__c> loanApps,Integer numofLoanRecord) {
        for(Integer i=0;i<numofLoanRecord;i++){
            Loan_Application__c loanApp = new Loan_Application__c();
            loanApp.Mobile_Number__c = '1234567890';
            loanApp.Stage__c = 'Cancelled';
            loanApp.Exempt_Duplicate__c = false;
            loanApps.add(loanApp);
        }
        
        return loanApps;
    }
    public static List<Loan_Application__c> createRejectLoanApplications(List<Loan_Application__c> loanApps,Integer numofLoanRecord) {
        for(Integer i=0;i<numofLoanRecord;i++){
            Loan_Application__c loanApp = new Loan_Application__c();
            loanApp.Mobile_Number__c = '1234567890';
            loanApp.Stage__c = 'Reject';
            loanApp.Exempt_Duplicate__c = false;
            loanApps.add(loanApp);
        }
        
        return loanApps;
    }
    
    public static List<Loan_Application__c> createDisbursedLoanApplications(List<Loan_Application__c> loanApps,Integer numofLoanRecord) {
        for(Integer i=0;i<numofLoanRecord;i++){
            Loan_Application__c loanApp = new Loan_Application__c();
            loanApp.Mobile_Number__c = '1234567890';
            loanApp.Stage__c = 'Disbursed';
            loanApp.Exempt_Duplicate__c = false;
            loanApps.add(loanApp);
        }
        
        return loanApps;
    }
    
    
    
}