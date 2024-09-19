/**
 * @author        Pradeep Sharma
 * Class :		 AUSF_HunterAPIController
 * @date          5-July-2024
 * @description   Test Classes for Hunter API
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
    --------------------------------------------------------------------------------------------
    Pradeep Sharma        5-July-2024    Initial Version
*/
@isTest
public class AUSF_HunterAPITest {
    @testSetup 
    static void setup() {
        Integration_Master__c intMaster = new Integration_Master__c (
            Name =AUSF_ApexConstants.AUSF_HUNTERAPI_INTEGRATION_MASTER,
            End_Point_URL__c='https://api.aubankuat.in/sfdckyc/HunterRestService/Check',
            Channel__c ='SFDC',
            HTTP_Method__c='POST',
            Timeout__c=120000,
            content_type__c = 'application/json',
            Active__c = true,
            Apex_Class_Name__c = 'AUSF_HunterAPIHandler'
        );  
        Loan_Application__c loanApp = new Loan_Application__c();
        loanApp.Mobile_Number__c = '1234567890';
        loanApp.Stage__c = 'Pending';
        loanApp.Exempt_Duplicate__c = false;
        insert loanApp;
        insert intMaster;
        Applicant__c applicant = new Applicant__c(Gender__c = 'Male',Loan_application__c = loanApp.Id);
        insert applicant;
        Address__c addr = new  Address__c(Address_Line_1__c = 'test',Applicant__c = applicant.Id,Address_Type__c = 'Permanent');
        insert addr;
        Address__c addr1 = new  Address__c(Address_Line_1__c = 'test',Applicant__c = applicant.Id,Address_Type__c = 'Current');
        insert addr1;
        
    }
    @isTest
    public static void testControllerSuccess(){
        Test.startTest();
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','0'));
        AUSF_HunterAPIController.callHunterApi(applicantId);
        AUSF_HunterAPIHandler hunter = new AUSF_HunterAPIHandler();
        hunter.beforeUpdateService(null,null);
        hunter.callbackService(null, null);
        hunter.generatePlatformEvents(null);
        AUSF_HunterAPIResponseWrapper response = new AUSF_HunterAPIResponseWrapper();
        Test.stopTest();
        Assert.areEqual('Completed',[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId].Status__c ,'IC-Complete');
    }
    @isTest
    public static void testControllerFail(){
        Test.startTest();
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','1'));
        AUSF_HunterAPIController.callHunterApi(applicantId);
        Test.stopTest();
        Assert.areEqual('Failed',[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId].Status__c ,'IC-Failed');
    }
    @isTest
    public static void testControllerHttpFail(){
        Test.startTest();
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400','0'));
        AUSF_HunterAPIController.callHunterApi(applicantId);
        Test.stopTest();
        Assert.areEqual('Failed',[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId].Status__c ,'IC-Failed');
    }
}