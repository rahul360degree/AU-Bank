/**
* @author        Rahul Yadav.
* @date          09-July-2024
* @description   Test class for AUSF_INT_PreApprovedController,AUSF_INT_PreApprovedHandler
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav.          09-July-2024    Initial Version
*/
@IsTest
public without sharing class AUSF_INT_PreApprovedTest {
    @testSetup 
    static void setup() {
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster(AUSF_ApexConstants.AUSF_PRE_APPROVED_INTEGRATION_MASTER, 'https://api.aubankuat.in/sfdc/CRMOfferRestService/OfferUpdate', 'SFDC', 'GET', 'application/json' , 'AUSF_INT_PreApprovedHandler');  
        List<Loan_Application__c> loanAppList = new List<Loan_Application__c>();
        loanAppList = AUSF_TestDataFactory.createActiveLoanApplications(loanAppList,1);
        insert loanAppList;
        insert integrationMaster;
        Applicant__c applicant = new Applicant__c(Gender__c = 'Male', Loan_application__c = loanAppList[0].Id, Is_Personal_Email_Id_Verified__c = true);
        insert Applicant;
        Profile objProfile = [Select Id from Profile where Name = 'Sales'];
        User objUser = AUSF_TestDataFactory.createUsersWithParams(null,'sales','user','123456','sales@salesforce.com','sales@salesforce.com.ausf',objProfile.Id,'ssu11');
        insert objUser;
    }
    /*
@description    : doPreApprovedCallout - this method will be cover code coverage of statscode equals 0. 
*/
    @isTest
    public static void testControllerSuccess(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.ausf' LIMIT 1];
        system.assertEquals('sales@salesforce.com',objUser.Email);
        System.runAs(objUser){
            Test.startTest();
            String mockResponseBody = '{ "TransactionStatus": { "ResponseCode": "0", "ResponseMessage": "Success", "ExtendedErrorDetails": { "messages": [ { "code": 0, "message": "Item has been updated successfully." } ] } }, "OfferId": "69876772" }';
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(mockResponseBody, 200));
            Applicant__c apList = [SELECT Id FROM Applicant__c LIMIT 1];
            AUSF_INT_PreApprovedResponseWrapper responseWrapper = AUSF_INT_PreApprovedController.doPreApprovedCallout(apList.Id, '69876772');
            // Assert the response
            AUSF_INT_PreApprovedHandler ebhandler = new AUSF_INT_PreApprovedHandler();
            ebhandler.generatePlatformEvents(new List<Object>());
            ebhandler.beforeUpdateService(null, null);
            ebhandler.callbackService(new List<Integration_Checklist__c>(), new List<ContentVersion>());
            System.assertEquals(true, responseWrapper.blnIntegrationSuccess);
            System.assertEquals('200', String.valueOf(responseWrapper.responseWrapper.statusCode));
            Test.stopTest();
        }
    }
      /*
@description    : doPreApprovedCallout - this method will be cover code coverage of all failure Scenario. 
*/
    @isTest
    public static void testControllerFailure(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.ausf' LIMIT 1];
        system.assertEquals('sales@salesforce.com',objUser.Email);
        System.runAs(objUser){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400','99'));
            Applicant__c apList = [SELECT Id FROM Applicant__c LIMIT 1];
            String statuscode = String.valueOf(AUSF_INT_PreApprovedController.doPreApprovedCallout( apList.Id, '69876772').responseWrapper.statusCode);
            AUSF_INT_PreApprovedHandler ebhandler = new AUSF_INT_PreApprovedHandler();
            ebhandler.generatePlatformEvents(new List<Object>());
            ebhandler.callbackService(new List<Integration_Checklist__c>(), new List<ContentVersion>());
            system.assertEquals('0',statuscode,'');
            Test.stopTest();
        }
    }
     /*
@description    : doPreApprovedCallout - this method will be cover code coverage of statscode not equals 0. 
*/
    @isTest
    public static void testControllerFailureStatus(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.ausf' LIMIT 1];
        system.assertEquals('sales@salesforce.com',objUser.Email);
        System.runAs(objUser){
            Test.startTest();
            String mockResponseBody = '{ "TransactionStatus": { "ResponseCode": "98", "ResponseMessage": "Success", "ExtendedErrorDetails": { "messages": [ { "code": 0, "message": "Item has been updated successfully." } ] } }, "OfferId": "69876772" }';
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(mockResponseBody, 200));
            Applicant__c apList = [SELECT Id FROM Applicant__c LIMIT 1];
            AUSF_INT_PreApprovedResponseWrapper responseWrapper = AUSF_INT_PreApprovedController.doPreApprovedCallout(apList.Id, '69876772');
            // Assert the response
            AUSF_INT_PreApprovedHandler ebhandler = new AUSF_INT_PreApprovedHandler();
            ebhandler.generatePlatformEvents(new List<Object>());
            ebhandler.beforeUpdateService(null, null);
            ebhandler.callbackService(new List<Integration_Checklist__c>(), new List<ContentVersion>());
            System.assertEquals(false, responseWrapper.blnIntegrationSuccess);
            System.assertEquals('200', String.valueOf(responseWrapper.responseWrapper.statusCode));
            Test.stopTest();
        }
    }
}