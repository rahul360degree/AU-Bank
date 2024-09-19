/**
* @author              : Rajesh Kumar
* @date                : 09-Aug-2024
* @description         : Test Class for Shop and Establishment Certificate API 
* Classes covered      : AUSF_ShopEstablishmentController, AUSF_ShopEstablishmentHandler, AUSF_ShopEstablishmentRequestWrapper
* History              :
* ===========================================================================================================
* <Date>        <Authors Name>      <Brief Description of Change>
* ===========================================================================================================
* 09-Aug-2024   Rajesh Kumar         Initial Version
**/
@isTest
public class AUSF_ShopEstablishment_Test {
    @TestSetup
    static void makeData(){
        String endpoint = 'https://api.aubankuat.in/sfdckyc/SFDCKarzaAPIsService/shop';
        //Create Integration Master
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster('Shop and Establishment Certificate', endpoint, 'SFDC', 'POST', 'application/json' , 'AUSF_ShopEstablishmentHandler');
        Loan_Application__c loanApp = AUSF_TestDataFactory.createActiveLoanApplications(new List<Loan_Application__c>(),1)[0];
        insert loanApp;
        insert integrationMaster;

        List<Loan_Application__c> lstLoanApps = new List<Loan_Application__c>();
        lstLoanApps.add(loanApp);
        Applicant__c applicant = AUSF_TestDataFactory.createApplicantRecords(lstLoanApps, 1)[0];
        
        List<Address__c> addressList = AUSF_TestDataFactory.createAddress(applicant, 1 , true);
        
        List<Employment_Detail__c> employmentDetailList = AUSF_TestDataFactory.createEmploymentDetail(applicant.Id,1);
        employmentDetailList[0].Owner_Name__c = 'test full name';
        employmentDetailList[0].Address__c = addressList[0].Id;
        insert employmentDetailList;
        
        Profile objProfile = [Select Id from Profile where Name = 'Sales'];
        User objUser = AUSF_TestDataFactory.createUsersWithParams(null,'Standard User','user','123456','sales@salesforce.com','sales@salesforce.com.ausf',objProfile.Id,'ssu11');
        insert objUser;
        
    }
    
    @isTest
    static void testWithoutEmploymentId(){
      
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            List<Applicant__c> applicantList = [SELECT Id FROM Applicant__c LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));
            AUSF_ShopEstablishmentController.getShopAndEstablish(applicantList[0].Id,'21424990000358','', '');
            AUSF_ShopEstablishmentHandler handler = new AUSF_ShopEstablishmentHandler();
            handler.beforeUpdateService(null, null);
            handler.generatePlatformEvents(null);
            handler.callbackService(null,null);
            Test.stopTest();
            String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantList[0].Id LIMIT 1].Status__c;
            Assert.areEqual('Completed' ,status ,'IC-Complete');
        }
    }
    
    @isTest
    static void testWithEmploymentId(){
      
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Employment_Detail__c employmentDetails = [Select Id,Address__c from Employment_Detail__c limit 1];
            List<Applicant__c> applicantList = [SELECT Id FROM Applicant__c LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));
            AUSF_ShopEstablishmentController.getShopAndEstablish(applicantList[0].Id,'21424990000358','', employmentDetails.Id);
            AUSF_ShopEstablishmentHandler handler = new AUSF_ShopEstablishmentHandler();
            handler.beforeUpdateService(null, null);
            handler.generatePlatformEvents(null);
            handler.callbackService(null,null);
            Test.stopTest();
            String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantList[0].Id LIMIT 1].Status__c;
            Assert.areEqual('Completed' ,status ,'IC-Complete');
        }
    }
    
    @isTest
    static void failedShopEstablishMentAPI(){
        
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            List<Applicant__c> applicantList = [SELECT Id FROM Applicant__c LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400','101'));
            AUSF_ShopEstablishmentController.getShopAndEstablish(applicantList[0].Id,'21424990000358','', '');
            Test.stopTest();
            
            String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantList[0].Id LIMIT 1].Status__c;
            Assert.areEqual('Failed' ,status ,'IC-Complete');
        }
    }
    
    @isTest
    static void objShopEstablishmentResponseNull(){
        
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            List<Applicant__c> applicantList = [SELECT Id FROM Applicant__c LIMIT 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','102'));
            AUSF_ShopEstablishmentController.ShopEstablishmentWrapper objResWrapper = AUSF_ShopEstablishmentController.getShopAndEstablish(applicantList[0].Id,null,'', null);
            Test.stopTest();
            Assert.isTrue(objResWrapper.strMessage!= NULL, 'Assertion failed');
        }
        
    }
}