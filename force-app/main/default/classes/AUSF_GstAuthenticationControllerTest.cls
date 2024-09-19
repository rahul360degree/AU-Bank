/**
* @author        Tejendra Jaroli
* Class :        AUSF_GstAuthenticationControllerTest
* @date          2-August-2024
* @description   Test class for AUSF_GstAuthenticationController,AUSF_GstAuthenticationHandler
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra Jaroli       2-August-2024    Initial Version
*/
@isTest
public class AUSF_GstAuthenticationControllerTest {
@TestSetup
    public static void makeData(){
        Integration_Master__c integrationMaster1 = AUSF_TestDataFactory.createIntegrationMaster(AUSF_ApexConstants.AUSF_GST_AUTHENTICATION, 'https://api.aubankuat.in/sfdckyc/KarzaGSTServiceV1/verifypan', 'SFDC', 'POST', 'application/json' , 'AUSF_GstAuthenticationHandler'); 
        Integration_Master__c integrationMaster2 = AUSF_TestDataFactory.createIntegrationMaster(AUSF_ApexConstants.AUSF_KARZA_NAME_MATCH_INTEGRATION_MASTER, 'https://service.aubank.in/sfdckyc/KarzaService/NameMatch', 'SFDC', 'POST', 'application/json' , 'AUSF_KarzaNameMatchHandler');  
        List<Loan_Application__c> loanAppList = new List<Loan_Application__c>();
        loanAppList = AUSF_TestDataFactory.createActiveLoanApplications(loanAppList,1);
        insert loanAppList;
        insert integrationMaster1;
        insert integrationMaster2;
        List<Applicant__c> applicantList = AUSF_TestDataFactory.createApplicantRecords(loanAppList,1);
        applicantList[0].Full_Name__c = 'test full name';
        update applicantList[0];
        
        List<Address__c> addressList = AUSF_TestDataFactory.createAddress(applicantList[0], 1 , true);
        
        List<Employment_Detail__c> employmentDetailList = AUSF_TestDataFactory.createEmploymentDetail(applicantList[0].Id,1);
        employmentDetailList[0].Owner_Name__c = 'test full name';
        employmentDetailList[0].Address__c = addressList[0].Id;
        insert employmentDetailList;
        
        Profile objProfile = [Select Id from Profile where Name = 'Sales'];
        User objUser = AUSF_TestDataFactory.createUsersWithParams(null,'Standard User','user','123456','sales@salesforce.com','sales@salesforce.com.ausf',objProfile.Id,'ssu11');
        insert objUser;
    }
    
    // Employment Id not there
    @isTest
    public static void testWithoutEmploymentId(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            AUSF_GstAuthenticationController.fetchGstAuthenticationDetails(applId,'32AAACR5055K1ZG','');
            Assert.areEqual('Completed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applId].Status__c ,'IC-Complete');
            Test.stopTest();
        }
    }
    // Employment Id is there
    @isTest
    public static void testWithEmploymentId(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Employment_Detail__c employmentDetails = [Select Id,Address__c from Employment_Detail__c limit 1];
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            AUSF_GstAuthenticationController.fetchGstAuthenticationDetails(applId,'32AAACR5055K1ZG',employmentDetails.Id);
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
            AUSF_GstAuthenticationController.fetchGstAuthenticationDetails(applId,'32AAACR5055K1ZG','');
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
            AUSF_GstAuthenticationController.fetchGstAuthenticationDetails(applId,'32AAACR5055K1ZG','');
            Assert.areEqual('Failed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applId].Status__c ,'IC-Failed');
            Test.stopTest();
        }
    }
     
    @isTest
    public static void gstAuthenticationHandlerTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            AUSF_GstAuthenticationHandler obj = new AUSF_GstAuthenticationHandler();
            List<Object> request = obj.generateRequest(new List<Object>());
            List<SObject> res = obj.generatePlatformEvents(NULL);
            obj.callbackService(NULL,NULL);
            obj.beforeUpdateService(NULL,NULL);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void QueueableUtilityTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));
            Applicant__c objApplicant = [SELECT Id, Full_Name__c FROM Applicant__c];
            Employment_Detail__c employmentDetailobj = [SELECT Id FROM Employment_Detail__c];
            Id JobId = System.enqueueJob(new AUSF_QueuableUtility(objApplicant,employmentDetailobj));    
            Test.stopTest();
        }
    }
}