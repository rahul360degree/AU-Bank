/**
* @author        Tejendra Jaroli
* Class :		 AUSF_KarzaNameMatchControllerTest
* @date          26-June-2024
* @description   Test class for AUSF_KarzaNameMatchController,AUSF_KarzaNameMatchHandler
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra Jaroli        26-June-2024    Initial Version
*/
@isTest
public class AUSF_KarzaNameMatchControllerTest {
    @TestSetup
    public static void makeData(){
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster(AUSF_ApexConstants.AUSF_KARZA_NAME_MATCH_INTEGRATION_MASTER, 'https://service.aubank.in/sfdckyc/KarzaService/NameMatch', 'SFDC', 'POST', 'application/json' , 'AUSF_KarzaNameMatchHandler');  
        List<Loan_Application__c> loanAppList = new List<Loan_Application__c>();
        loanAppList = AUSF_TestDataFactory.createActiveLoanApplications(loanAppList,1);
        insert loanAppList;
        insert integrationMaster;
        Applicant__c applicant = new Applicant__c(Gender__c = 'Male', Loan_application__c = loanAppList[0].Id, Full_Name__c = 'Test',Mobile_Number__c = '9090909090');
        insert Applicant;
        Profile objProfile = [Select Id from Profile where Name = 'Sales'];
        User objUser = AUSF_TestDataFactory.createUsersWithParams(null,'Standard User','user','123456','sales@salesforce.com','sales@salesforce.com.ausf',objProfile.Id,'ssu11');
        insert objUser;
    }
    
    @isTest
    public static void testNameMatch1(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            AUSF_KarzaNameMatchController.nameMatch('Akshay Dange','AKSHAY NANASO DANGE',applId);
            Test.stopTest();
            Assert.areEqual('Completed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applId].Status__c ,'IC-Complete');
        }
    }
    
    @isTest
    public static void testNameMatch2(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','201'));
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            AUSF_KarzaNameMatchController.nameMatch('Akshay Dange','AKSHAY NANASO DANGE',applId);
            Test.stopTest();
            Assert.areEqual('Failed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applId].Status__c ,'IC-Failed');
        }
    }
    @isTest
    public static void testNameMatch3(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('{"requestId" : "34678hYYt","result" : {"score" : -1,"result" : true},"statusCode" : 201}',200));  
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            AUSF_KarzaNameMatchController.nameMatch('Akshay Dange','AKSHAY NANASO DANGE',applId);
            Test.stopTest();
            Assert.areEqual('Failed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applId].Status__c ,'IC-Failed');
        }
    }
    
    @isTest
    public static void testNameMatch4(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400',''));
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            AUSF_KarzaNameMatchController.nameMatch('Akshay Dange','AKSHAY NANASO DANGE',applId);
            Test.stopTest();
            Assert.areEqual('Failed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applId].Status__c ,'IC-Failed');
        }
    }
    
    @isTest
    public static void karzaNameMatchHandlerTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            AUSF_KarzaNameMatchHandler obj = new AUSF_KarzaNameMatchHandler();
            List<Object> request = obj.generateRequest(new List<Object>());
            List<SObject> res = obj.generatePlatformEvents(NULL);
            obj.callbackService(NULL,NULL);
            obj.beforeUpdateService(NULL,NULL);
            Test.stopTest();
        }
    }
    
}