/**
 * @author        Pradeep Sharma
 * Class :		 AUSF_CustomerDedupeTest
 * @date          28-June-2024
 * @description   test class for AUSF_Customer_Dedupe_Controller and AUSF_Customer_Dedupe_Handler
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
    --------------------------------------------------------------------------------------------
    Pradeep Sharma        28-June-2024    Initial Version
     */
@isTest
public class AUSF_CustomerDedupeTest {
    @testSetup 
    static void setup() {
        Integration_Master__c intMaster = AUSF_TestDataFactory.createIntegrationMaster('Customer Dedupe Detail', 'https://api.aubankuat.in/sfdccbs/SFDCCustomerRestService/SearchCustomer','SFDC','POST', 'application/json', 'AUSF_CustomerDedupeHandler');
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
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','0'));
        AUSF_INT_CustomerDedupeResponseWrapper objResponse = AUSF_CustomerDedupeController.getCustomerDedupe('LURPS1624J',[SELECT Id FROM Loan_Application__c][0].Id,applicantId);
        String CIF = objresponse.customers[0].CIF;
        AUSF_CustomerDedupeUtility.updateRecordForCIF(CIF,applicantId);
        AUSF_CustomerDedupeHandler dedupeApi = new AUSF_CustomerDedupeHandler();
        dedupeApi.beforeUpdateService(null,null);
        dedupeApi.callbackService(null, null);
        dedupeApi.generatePlatformEvents(null);
        AUSF_CustomerDedupeResponseWrapper response = new AUSF_CustomerDedupeResponseWrapper();
        Test.stopTest();
        String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId LIMIT 1].Status__c;
        Assert.areEqual('Completed' ,status ,'IC-Complete');
    }
    @isTest
    public static void testControllerSuccessSingleMatch(){
        Test.startTest();
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','1'));
        AUSF_CustomerDedupeController.getCustomerDedupe('LURPS1624J',[SELECT Id FROM Loan_Application__c][0].Id,applicantId);
        AUSF_CustomerDedupeResponseWrapper wrap = new AUSF_CustomerDedupeResponseWrapper();
        Test.stopTest();
        String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId LIMIT 1].Status__c;
        Assert.areEqual('Completed' ,status ,'IC-Complete');
    }
    @isTest
    public static void testControllerIntFailure(){
        Test.startTest();
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400',''));
        AUSF_CustomerDedupeController.getCustomerDedupe('LURPS1624J',[SELECT Id FROM Loan_Application__c][0].Id,applicantId);
        Test.stopTest();
        String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId LIMIT 1].Status__c;
        Assert.areEqual('Failed' ,status ,'IC-Failed');
    }

   
}