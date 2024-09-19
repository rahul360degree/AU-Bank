/**
* @author        Pradeep Sharma
* Class :		 AUSF_PanDobTest
* @date          21-June-2024
* @description   Test class for AUSF_PanDobController,AUSF_PanDobHandler
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Pradeep Sharma        21-June-2024    Initial Version
*/
@isTest
public class AUSF_PanDobTest {
    @testSetup 
    static void setup() {
        Integration_Master__c intMaster = new Integration_Master__c (
            Name ='PAN-DOB',
            End_Point_URL__c='https://api.aubankuat.in/sfdc/PANDoBStatusService/PANDoBStatus',
            Channel__c ='SFDC',
            HTTP_Method__c='POST',
            Timeout__c=120000,
            content_type__c = 'application/json',
            Active__c = true,
            Apex_Class_Name__c = 'AUSF_PanDobHandler'
        );  
        Loan_Application__c loanApp = new Loan_Application__c();
        loanApp.Mobile_Number__c = '1234567890';
        loanApp.Stage__c = 'Pending';
        loanApp.Exempt_Duplicate__c = false;
        insert loanApp;
        insert intMaster;
        Applicant__c applicant = new Applicant__c(Gender__c = 'Male',Loan_application__c = loanApp.Id);
        Insert Applicant;
    }
    @isTest
    public static void testControllerSuccess(){
        Test.startTest();
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));
        AUSF_PanDobController.getPANDOB(applicantId, 'XPERF1614J');
        AUSF_PanDobHandler pan = new AUSF_PanDobHandler();
        pan.generatePlatformEvents(new List<Object>());
        Test.stopTest();
        Assert.areEqual('Completed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId].Status__c ,'IC-Complete');
    }
    @isTest
    public static void testControllerFailure(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','102'));
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        AUSF_PanDobController.getPANDOB(applicantId, 'XPERF1614J');
        AUSF_PanDobHandler pan = new AUSF_PanDobHandler();
        pan.callbackService(null,null);
        Test.stopTest();
        Assert.areEqual('Failed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId].Status__c ,'IC-Failed');
    }
    @isTest
    public static void testControllerFailure201(){
        Test.startTest();
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('201',''));
        AUSF_PanDobController.getPANDOB(applicantId, 'XPERF1614J');
        AUSF_PanDobHandler pan = new AUSF_PanDobHandler();
        pan.beforeUpdateService(null,null);
        AUSF_PanDobResponseWrapper wrp = new AUSF_PanDobResponseWrapper();
        Test.stopTest();
        Assert.areEqual('Failed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId].Status__c ,'IC-Failed');
    }
    
}