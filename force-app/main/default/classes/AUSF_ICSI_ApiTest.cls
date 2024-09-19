/**
 * @author       Ankit Bansal
 * Class :		 AUSF_ICSIApiTest
 * @date         08-Aug-2024
 * @description: test class for AUSF_ICSI_APIController and AUSF_ICSI_APIHandler
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
--------------------------------------------------------------------------------------------
    Ankit Bansal        08-Aug-2024    Initial Version
*/

@isTest
public class AUSF_ICSI_ApiTest {
    
    @testSetup 
    static void setup() {
        list<Integration_Master__c> intList = new list<Integration_Master__c>();
        Integration_Master__c intMaster = AUSF_TestDataFactory.createIntegrationMaster('ICSI API', 'https://api.aubankuat.in/sfdckyc/SFDCKarzaAPIsService/ICSIMembership','SFDC','POST', 'application/json', 'AUSF_ICSIHandler');
        Integration_Master__c intMaster2 = AUSF_TestDataFactory.createIntegrationMaster('DocumentCompressService', 'https://aufilecompressor.aubank.in:8443/Service1.svc/CompressFiles', 'SFDC','POST', 'application/json', 'AUSF_DocumentCompressHandler');
        intList.add(intMaster);
        intList.add(intMaster2);
        Loan_Application__c loanApp = AUSF_TestDataFactory.createActiveLoanApplications(new List<Loan_Application__c>(),1)[0];
        insert loanApp;
        insert intList;  
        List<Loan_Application__c> lstLoanApps = new List<Loan_Application__c>();
        lstLoanApps.add(loanApp);
        Applicant__c applicant = AUSF_TestDataFactory.createApplicantRecords(lstLoanApps, 1)[0];
    }
    
    @isTest
    public static void testControllerSuccess(){
        Test.startTest();
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));
        AUSF_INT_ICSIWrapper objResponse = AUSF_ICSIController.getICSIDetails(applicantId, 'LURPS1624J', '');
        AUSF_ICSIHandler icsiApiHand = new AUSF_ICSIHandler();
        icsiApiHand.beforeUpdateService(null,null);
        icsiApiHand.callbackService(null, null);
        icsiApiHand.generatePlatformEvents(null);
        AUSF_ICSIResponseWrapper res = new  AUSF_ICSIResponseWrapper();
        Test.stopTest();
        String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId LIMIT 1].Status__c;
        Assert.areEqual('Completed' ,status ,'IC-Complete');
    }
    
   	@isTest
    public static void testControllerFailure(){
        Test.startTest();
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400',''));
        AUSF_INT_ICSIWrapper objResponse = AUSF_ICSIController.getICSIDetails(applicantId, 'LURPS1624J', '');
        Test.stopTest();
        String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId LIMIT 1].Status__c;
        System.debug('Status :--->'+Status);
        Assert.areEqual('Failed' ,status ,'IC-Failed');
    }

}