/**
* @author        Tejendra Jaroli
* Class :		 AUSF_WhatsAppNotificationHandlerTest
* @date          6-July-2024
* @description   Test class for AUSF_WhatsAppNotificationHandler,AUSF_WhatsAppNotificationIntegrationHandler
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra Jaroli        6-July-2024    Initial Version - APL-247
*/
@isTest
public class AUSF_WhatsAppNotificationHandlerTest {
    @TestSetup
    public static void makeData(){
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster(AUSF_ApexConstants.AUSF_WHATSAPP_INTEGRATION_MASTER, 'https://api.aubankuat.in/sfdc/WhatsappCongoService/SingleEvent', 'SFDC', 'POST', 'application/json' , 'AUSF_WhatsAppIntegrationHandler');  
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
    public static void sendWhatsAppNotificationTest1(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200',''));
            String loanId = String.valueOf([SELECT Id FROM Loan_Application__c].Id);
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            Applicant__c applicant;
            Loan_Application__c loan;
            String strTriggerPoint = 'Case_Rejection';
            String toUserId = '9090909090';
            AUSF_NotificationController.LoanAppWrapper loanAppWrapperObj = new AUSF_NotificationController.LoanAppWrapper(applicant,loan,applId,loanId,strTriggerPoint,toUserId);    
            AUSF_WhatsAppNotificationHandler.sendWhatsAppNotification(loanAppWrapperObj);
            Test.stopTest();
            System.assertEquals('Completed',[SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c =: applId].Status__c,'IC Not Failed');        
        }
    }
    @isTest
    public static void sendWhatsAppNotificationTest2(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400',''));
            Applicant__c applicant = [SELECT Id, Loan_Application__c,First_Name__c,Full_Name__c,Last_Name__c,Personal_email_ID__c,Mobile_Number__c 
                                      FROM Applicant__c LIMIT 1];
            Loan_Application__c loan = [SELECT Id,Name FROM Loan_Application__c LIMIT 1];
            String applicantId = applicant.Id;
            String loanApplicationId = loan.Id;
            String strTriggerPoint = 'Case_Rejection';
            String toUserId = applicant.Mobile_Number__c;
            AUSF_NotificationController.LoanAppWrapper loanAppWrapperObj = new AUSF_NotificationController.LoanAppWrapper(applicant,loan,applicantId,loanApplicationId,strTriggerPoint,toUserId);
            AUSF_WhatsAppNotificationHandler.sendWhatsAppNotification(loanAppWrapperObj);
            AUSF_WhatsAppNotificationHandler AUSF_WhatsAppNotificationHandlerObj = new AUSF_WhatsAppNotificationHandler();            
            Test.stopTest();
            System.assertEquals('Failed',[SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c =: applicantId].Status__c,'IC Not Completed');            
        }
    }
    @isTest
    public static void sendWhatsAppNotificationTest3(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('{"status_message":"success","recepient_id":"gBEGkZgzaUc0AgmkicwgsH8l2Cw","status":201}',200));  
            Applicant__c applicant = [SELECT Id, Loan_Application__c,First_Name__c,Full_Name__c,Last_Name__c,Personal_email_ID__c,Mobile_Number__c 
                                      FROM Applicant__c LIMIT 1];
            Loan_Application__c loan = [SELECT Id,Name FROM Loan_Application__c LIMIT 1];
            String applicantId = applicant.Id;
            String loanApplicationId = loan.Id;
            String strTriggerPoint = 'Case_Rejection';
            String toUserId = applicant.Mobile_Number__c;
            AUSF_NotificationController.LoanAppWrapper loanAppWrapperObj = new AUSF_NotificationController.LoanAppWrapper(applicant,loan,applicantId,loanApplicationId,strTriggerPoint,toUserId);
            AUSF_WhatsAppNotificationHandler.sendWhatsAppNotification(loanAppWrapperObj);
            Test.stopTest();
        }
    }

    @isTest
    public static void sendWhatsAppNotificationTest4(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400',''));
            Applicant__c applicant = [SELECT Id, Loan_Application__c,First_Name__c,Full_Name__c,Last_Name__c,Personal_email_ID__c,Mobile_Number__c 
                                      FROM Applicant__c LIMIT 1];
            applicant.Mobile_Number__c = '';
            update applicant;                          
            Loan_Application__c loan = [SELECT Id,Name FROM Loan_Application__c LIMIT 1];
            String applicantId = applicant.Id;
            String loanApplicationId = loan.Id;
            String strTriggerPoint = 'Case_Rejection';
            String toUserId = applicant.Mobile_Number__c;
            AUSF_NotificationController.LoanAppWrapper loanAppWrapperObj = new AUSF_NotificationController.LoanAppWrapper(applicant,loan,applicantId,loanApplicationId,strTriggerPoint,toUserId);
            AUSF_WhatsAppNotificationHandler.sendWhatsAppNotification(loanAppWrapperObj);
            Test.stopTest();
        }
    }

    @isTest
    public static void WhatsAppIntegrationHandlerTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            AUSF_WhatsAppIntegrationHandler obj = new AUSF_WhatsAppIntegrationHandler();
            List<Object> request = AUSF_WhatsAppIntegrationHandler.generateRequest(new List<Object>());
            List<SObject> res = obj.generatePlatformEvents(NULL);
            obj.callbackService(NULL,NULL);
            obj.beforeUpdateService(NULL,NULL);
            Test.stopTest();
        }
    }
}