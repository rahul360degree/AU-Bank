/**
* @author  Nitesh jaiswal
* @company Salesforce.com
* @description :
* History:
*
*************************************************************************************
MODIFICATION LOG
* Version     Date                Developer            Description
*-------------------------------------------------------------------------------------------
*  1.0    24th June 2024          Nitesh jaiswal       Initial Creation and added test cases for success and error of AUSF_Screen_Custom_Text__mdt metadata records.
*/

@isTest
public class AUSF_LoanPurposeScreenController_Test {

    @TestSetup
    static void makeData(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();   
        loanApps = AUPL_TestDataFactory.createActiveLoanApplications(loanApps,1);
        insert loanApps;
        User userObj = new User(Alias = 'standt', Email='admin@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='test@auplorg1.com', FederationIdentifier='12345678');

        insert userObj;
    }

    @isTest
    static void testvalidateReferralCodeSuccess() {
        string referralCode = '12345678';
        test.startTest();
        List<User> userList = AUSF_LoanPurposeScreenController.validateReferralCode(referralCode,[SELECT Id FROM Loan_Application__c LIMIT 1].Id);
        System.assertEquals(1, userList.size());
        test.stopTest();
    }

    @isTest
    static void testvalidateReferralCodeFail() {
        string referralCode = '11111111';
        test.startTest();
        List<User> userList = AUSF_LoanPurposeScreenController.validateReferralCode(referralCode,[SELECT Id FROM Loan_Application__c LIMIT 1].Id);
        System.assertEquals(0, userList.size());
        test.stopTest();
    }

    @isTest
    static void testvalidateReferralCodeCatch() {
        test.startTest();
        AUSF_LoanPurposeScreenController.throwException = true;
        string referralCode = '11111111';
        List<User> userList = AUSF_LoanPurposeScreenController.validateReferralCode(referralCode,[SELECT Id FROM Loan_Application__c LIMIT 1].Id);
        test.stopTest();
    }
}