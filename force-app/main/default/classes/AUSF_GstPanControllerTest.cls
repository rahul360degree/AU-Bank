/**
* @author        Tejendra Jaroli
* Class :		 AUSF_GstPanControllerTest
* @date          31-July-2024
* @description   Test class for AUSF_GstPanController,AUSF_GstPanHandler
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra Jaroli       31-July-2024    Initial Version - APL-150
*/
@isTest
public class AUSF_GstPanControllerTest {
@TestSetup
    public static void makeData(){
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster(AUSF_ApexConstants.AUSF_GST_PAN, 'https://api.aubankuat.in/sfdckyc/KarzaGSTServiceV1/gstpan', 'SFDC', 'POST', 'application/json' , 'AUSF_GstPanHandler');  
        List<Loan_Application__c> loanAppList = new List<Loan_Application__c>();
        loanAppList = AUSF_TestDataFactory.createActiveLoanApplications(loanAppList,1);
        insert loanAppList;
        insert integrationMaster;
        List<Applicant__c> applicantList = AUSF_TestDataFactory.createApplicantRecords(loanAppList,1);
        Profile objProfile = [Select Id from Profile where Name = 'Sales'];
        User objUser = AUSF_TestDataFactory.createUsersWithParams(null,'Standard User','user','123456','sales@salesforce.com','sales@salesforce.com.ausf',objProfile.Id,'ssu11');
        insert objUser;
    }
    
    @isTest
    public static void testFetchGstDetails1(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            AUSF_GstPanController.fetchGstDetails(applId);
            Assert.areEqual('Completed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applId].Status__c ,'IC-Complete');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testFetchGstDetails2(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','102'));
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            AUSF_GstPanController.fetchGstDetails(applId);
            Assert.areEqual('Failed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applId].Status__c ,'IC-Failed');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void testFetchGstDetails3(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400','102'));
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            AUSF_GstPanController.fetchGstDetails(applId);
            Assert.areEqual('Failed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applId].Status__c ,'IC-Failed');
            Test.stopTest();
        }
    }
    
    @isTest
    public static void gstPanHandlerTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            AUSF_GstPanHandler obj = new AUSF_GstPanHandler();
            List<Object> request = obj.generateRequest(new List<Object>());
            List<SObject> res = obj.generatePlatformEvents(NULL);
            obj.callbackService(NULL,NULL);
            obj.beforeUpdateService(NULL,NULL);
            Test.stopTest();
        }
    }
}