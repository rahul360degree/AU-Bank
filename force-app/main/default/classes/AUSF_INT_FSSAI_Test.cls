/**
* @author              : Amit Mishra
* @date                : 07-Aug-2024
* @description         : Test Class for FSSAI API 
* Classes covered      : AUSF_INT_FSSAI_Callout_Controller, AUSF_INT_FSSAI_Handler, AUSF_INT_FSSAI_RequestWrapper, AUSF_INT_FSSAI_ResponseWrapper
* History              :
* ===========================================================================================================
* <Date>        <Authors Name>      <Brief Description of Change>
* ===========================================================================================================
* 07-Aug-2024   Amit Mishra         Initial Version
**/
@isTest
public without sharing class AUSF_INT_FSSAI_Test {

    @TestSetup
    static void makeData(){
        String endpoint = 'https://api.aubankuat.in/sfdckyc/SFDCKarzaAPIsService/FSSAILicenseAuth';
        String channel = 'FOS';
        //Create User
        Profile objProfile = [Select Id FROM Profile WHERE Name = 'Sales'];
        //User objUser = AUSF_TestDataFactory.createUsersWithParams(null);
        //objUser.ProfileId = objProfile.Id;
        User objUser = AUSF_TestDataFactory.createUsersWithParams(null,'Standard User','user','123456','sales@salesforce.com','sales@salesforce.com.ausf',objProfile.Id,'ssu11');
        //objUser.IsActive = true;
        insert objUser;

        //Create Integration Master
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster('FSSAI', endpoint, 'FOS', 'POST', NULL , 'AUSF_INT_FSSAI_Handler');
        integrationMaster.Disable_Api__c = false;
        integrationMaster.Static_Response__c = '{"result":{"Status":"Active","LicType":"Registration","FirmName":"PREM ADANIYA / PREM DAIRY","Address":"RAJPURA DHAR,Dhar,Rajpura,Madhya Pradesh,454441","LicNO":"21424990000358"},"status-code":"101","request_id":"4d33f84d-1c55-46e9-898c-181ada53f39d"}';
        insert integrationMaster;

        //Create Loan Application
        List<Loan_Application__c> loanAppList = new List<Loan_Application__c>();
        loanAppList = AUSF_TestDataFactory.createActiveLoanApplications(loanAppList,1);
        //loanAppList[0].Stage__c = 'Lead';
        insert loanAppList;

        //Create Applicant
        List<Applicant__c> applicantList = AUSF_TestDataFactory.createApplicantRecords(loanAppList, 1);
    }

    @isTest
    static void getFssaiResponseTest(){
        //User usrList = [SELECT Id FROM User];
        //System.debug('user 2:'+usrList);
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            List<Applicant__c> applicantList = [SELECT Id FROM Applicant__c LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));
            AUSF_INT_FSSAI_Callout_Controller.getFssaiResponse(applicantList[0].Id,'21424990000358',NULL);
            Test.stopTest();
            String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantList[0].Id LIMIT 1].Status__c;
            Assert.areEqual('Completed' ,status ,'IC-Complete');
        }
    }
    
    @isTest
    static void fssaiResponseFailedTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            List<Applicant__c> applicantList = [SELECT Id FROM Applicant__c LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','0'));
            AUSF_INT_FSSAI_Callout_Controller.getFssaiResponse(applicantList[0].Id,'21424990000358',NULL);
            Test.stopTest();
            String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantList[0].Id LIMIT 1].Status__c;
            Assert.areEqual('Completed' ,status ,'IC-Complete');
        }
    }
    
    @isTest
    static void fssaiResWrapperFailedTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            List<Applicant__c> applicantList = [SELECT Id FROM Applicant__c LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('101','0'));
            AUSF_INT_FSSAI_Callout_Controller.getFssaiResponse(applicantList[0].Id,'21424990000358',NULL);
            Test.stopTest();
            String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantList[0].Id LIMIT 1].Status__c;
            Assert.areEqual('Failed' ,status ,'IC-Complete');
        }
    }
    @isTest
    static void getFssaiResponse_Negative_Test(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            List<Applicant__c> applicantList = [SELECT Id FROM Applicant__c LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('101','0'));
            AUSF_INT_FSSAI_ResponseWrapper finalResponseWrapper = AUSF_INT_FSSAI_Callout_Controller.getFssaiResponse(applicantList[0].Id, NULL, NULL);
            finalResponseWrapper = AUSF_INT_FSSAI_Callout_Controller.getFssaiResponse(NULL,'21424990000358',NULL);
            Test.stopTest();
            Assert.isTrue(finalResponseWrapper.strMessage != NULL, 'Assertion failed'); //(condition, msg)
        }
    }     
    @isTest
    public static void validateHandlerTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            AUSF_INT_FSSAI_Handler obj = new AUSF_INT_FSSAI_Handler();
            List<Object> request = obj.generateRequest(new List<Object>());//List<Object> inputWrappers
            List<SObject> res = obj.generatePlatformEvents(NULL);//new List<Object> recordList;
            obj.callbackService(NULL,NULL);//List<Integration_Checklist__c> checklistRecords, List<ContentVersion> responseFiles
            obj.beforeUpdateService(NULL,NULL);//Integration_Checklist__c checklistRecord, ContentVersion responseFile
            Test.stopTest();
            Assert.isTrue(request.isEmpty(), 'Assertion failed');
        }
    }
}