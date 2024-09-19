/*******************************************************************************************
* @Name         AUSF_DIYUtility_Test
* @Author       Mohit M.
* @Description  Test Class for AUSF_DIYUtility_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Mohit M.             11-July-2024            Initial Creation 
*******************************************************************************************/
@isTest
public with sharing class AUSF_DIYUtility_Test {
    /* Setup Test Data */
    @testSetup
    static void setupTestData() {

        Profile objProfile = [Select Id from Profile where Name = 'Sales'];
        User objUser = AUSF_TestDataFactory.createUsersWithParams(null,'sales','user','123456','sales@salesforce.com','sales@salesforce.com.aupl',objProfile.Id,'ssu11');
        insert objUser;
        System.runAs(objUser) {
            List<Lead_Stage__c> lstLead = AUSF_TestDataFactory.createLeadStagerecords (new List<Lead_Stage__c> (), 1);
            insert lstLead;
        }
        /*
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();   
        loanApps = AUPL_TestDataFactory.createActiveLoanApplications(loanApps,1);
        loanApps=AUPL_TestDataFactory.createCancelledLoanApplications(loanApps,1);
        loanApps=AUPL_TestDataFactory.createRejectLoanApplications(loanApps,1);
        loanApps=AUPL_TestDataFactory.createDisbursedLoanApplications(loanApps,1);
        insert loanApps;

        Profile prof = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        
        User asmUser = (User)TestFactory.createSObject(new User(
            Alias = 'test1235', ProfileId = prof.Id, Username = 'asmuserchennai@gmail.com.uat',
            User_Type__c = 'ASM', Product__c = 'PL', Portfolio__c = 'Personal Loan '), 'TestFactoryDefaults.UserDefaults', true);
        
        */
    }

    /* checkForValidSessionWithScreen */
    @isTest
    public static void testCheckForValidSessionWithScreenForLead(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.aupl' LIMIT 1];
        system.assertEquals('sales@salesforce.com',objUser.Email);
        System.runAs(objUser) {
            Lead_Stage__c objLead = [SELECT Id FROM Lead_Stage__c LIMIT 1];
            Test.startTest();
                AUSF_DIYUtility.WrapForSession objWrap = AUSF_DIYUtility.getEncryptedId (String.valueOf(objLead.Id));
                system.assertEquals(true,objWrap.blnSuccess);

                AUSF_DIYUtility.WrapClass objWrapSession = AUSF_DIYUtility.checkForValidSessionWithScreen (objWrap.strSessionId, 'Enter Mobile Number', true, '', false);
                system.assertEquals('',objWrapSession.strMessage);
                system.assertEquals('Lead_Stage__c',objWrapSession.strObjectName);
            Test.stopTest();
        }
    }
}