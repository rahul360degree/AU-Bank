/**
 * @author       Ankit Bansal
 * Class :		 AUSF_ICAI_ApiTest
 * @date         08-Aug-2024
 * @description: test class for AUSF_ICAI_APIController and AUSF_ICAI_APIHandler
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
--------------------------------------------------------------------------------------------
    Ankit Bansal        08-Aug-2024    Initial Version
*/

@isTest
public class AUSF_ICAI_ApiTest {
    
    @testSetup 
    static void setup() {
        Integration_Master__c intMaster = AUSF_TestDataFactory.createIntegrationMaster('ICAI API', 'https://api.aubankuat.in/sfdckyc/SFDCKarzaAPIsService/CAMembershipAuth','SFDC','POST', 'application/json', 'AUSF_ICAI_APIHandler');
        Loan_Application__c loanApp = AUSF_TestDataFactory.createActiveLoanApplications(new List<Loan_Application__c>(),1)[0];
        insert loanApp;
        insert intMaster;
        System.debug('intMaster-->'+intMaster);
        System.debug('intMaster-->'+loanApp);
        List<Loan_Application__c> lstLoanApps = new List<Loan_Application__c>();
        lstLoanApps.add(loanApp);
        Applicant__c applicant = AUSF_TestDataFactory.createApplicantRecords(lstLoanApps, 1)[0];
        System.debug('applicant-->'+applicant);
    }
    
    @isTest
    public static void testControllerSuccess(){
        Test.startTest();
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));
        AUSF_INT_ICAI_APIWrapper objResponse = AUSF_ICAI_APIController.getICAIDetails(applicantId, '442740', '');
        AUSF_ICAI_APIHandler icaiApiHand = new AUSF_ICAI_APIHandler();
        icaiApiHand.beforeUpdateService(null,null);
        icaiApiHand.callbackService(null, null);
        icaiApiHand.generatePlatformEvents(null);
        AUSF_ICAI_APIResponseWrapper res = new  AUSF_ICAI_APIResponseWrapper();
        Test.stopTest();
        String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId LIMIT 1].Status__c;
        Assert.areEqual('Completed' ,status ,'IC-Complete');
    }
    
   	@isTest
    public static void testControllerFailure(){
        Test.startTest();
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400',''));
        AUSF_INT_ICAI_APIWrapper objResponse = AUSF_ICAI_APIController.getICAIDetails(applicantId, 'LURPS1624J', '');
        Test.stopTest();
        String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId LIMIT 1].Status__c;
        System.debug('Status :--->'+Status);
        Assert.areEqual('Failed' ,status ,'IC-Failed');
    }

}