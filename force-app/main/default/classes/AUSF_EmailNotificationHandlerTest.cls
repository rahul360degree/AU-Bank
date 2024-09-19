/**
* @author        Tejendra Jaroli
* Class :		 AUSF_EmailNotificationHandlerTest
* @date          6-July-2024
* @description   Test class for AUSF_EmailNotificationHandler,AUSF_EmailNotificationIntegrationHandler
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra Jaroli        6-July-2024    Initial Version - APL-244
*/
@isTest
public class AUSF_EmailNotificationHandlerTest {
    @TestSetup
    public static void makeData(){
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster(AUSF_ApexConstants.AUSF_Email_INTEGRATION_MASTER, 'https://api.aubankuat.in/sfdc/CommunicationRestService/mail', 'SFDC', 'POST', 'application/json' , 'AUSF_EmailNotificationIntegrationHandler');  
        List<Loan_Application__c> loanAppList = new List<Loan_Application__c>();
        loanAppList = AUSF_TestDataFactory.createActiveLoanApplications(loanAppList,1);
        insert loanAppList;
        insert integrationMaster;
        Applicant__c applicant = new Applicant__c(Gender__c = 'Male', Loan_application__c = loanAppList[0].Id, Full_Name__c = 'Test',Mobile_Number__c = '9090909090',Personal_email_ID__c='test@gmail.com');
        insert Applicant;
        Profile objProfile = [Select Id from Profile where Name = 'Sales'];
        User objUser = AUSF_TestDataFactory.createUsersWithParams(null,'Standard User','user','123456','sales@salesforce.com','sales@salesforce.com.ausf',objProfile.Id,'ssu11');
        insert objUser;
        Document_Checklist__c docChecklist = new Document_Checklist__c();
        docChecklist.Document_Name__c = 'Rejection letter';
        docChecklist.Loan_Application__c = loanAppList[0].Id;
        insert docChecklist;
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Rejection letter',
            PathOnClient = 'Rejectionletter.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [
            SELECT Id, Title, LatestPublishedVersionId 
            FROM ContentDocument
        ];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = docChecklist.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        insert cdl;
    }
    @isTest
    public static void sendEmailNotificationTest1(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200',''));
            String loanId = String.valueOf([SELECT Id FROM Loan_Application__c].Id);
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            Applicant__c applicant;
            Loan_Application__c loan;
            String strTriggerPoint = 'Case_Rejection';
            String toUserId = 'test@gmail.com';
            AUSF_NotificationController.LoanAppWrapper loanAppWrapperObj = new AUSF_NotificationController.LoanAppWrapper(applicant,loan,applId,loanId,strTriggerPoint,toUserId);
            AUSF_EmailNotificationHandler.sendEmailNotification(loanAppWrapperObj);
            Test.stopTest();
            System.assertEquals('Completed',[SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c =: applId].Status__c,'IC Not Failed');        
        }
    }
    @isTest
    public static void sendEmailNotificationTest2(){
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
            String toUserId = applicant.Personal_email_ID__c;
            AUSF_NotificationController.LoanAppWrapper loanAppWrapperObj = new AUSF_NotificationController.LoanAppWrapper(applicant,loan,applicantId,loanApplicationId,strTriggerPoint,toUserId);
            AUSF_EmailNotificationHandler.sendEmailNotification(loanAppWrapperObj); 
            Test.stopTest();
            System.assertEquals('Failed',[SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c =: applicantId].Status__c,'IC Not Completed');            
        }
    }
     
    @isTest
    public static void sendEmailNotificationTest3(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('{"TransactionStatus":{"ResponseCode":"1","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":{"code":"0","message":"7976335481 : APP-TESTAXIOM6-1721024462430-656-DC0101 : Success"}}}}',200));  
            Applicant__c applicant = [SELECT Id, Loan_Application__c,First_Name__c,Full_Name__c,Last_Name__c,Personal_email_ID__c,Mobile_Number__c 
                                      FROM Applicant__c LIMIT 1];
            Loan_Application__c loan = [SELECT Id,Name FROM Loan_Application__c LIMIT 1];
            String applicantId = applicant.Id;
            String loanApplicationId = loan.Id;
            String strTriggerPoint = 'Case_Rejection';
            String toUserId = applicant.Personal_email_ID__c;
            AUSF_NotificationController.LoanAppWrapper loanAppWrapperObj = new AUSF_NotificationController.LoanAppWrapper(applicant,loan,applicantId,loanApplicationId,strTriggerPoint,toUserId);
            AUSF_EmailNotificationHandler.sendEmailNotification(loanAppWrapperObj);
            AUSF_EmailNotificationHandler AUSF_EmailNotificationHandlerObj = new AUSF_EmailNotificationHandler();
            Test.stopTest();
            System.assertEquals('Failed',[SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c =: applicantId].Status__c,'IC Not Completed');            
        }
    }
    @isTest
    public static void sendEmailNotificationTest4(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('{"TransactionStatus":{"ResponseCode":"1","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":{"code":"0","message":"7976335481 : APP-TESTAXIOM6-1721024462430-656-DC0101 : Success"}}}}',200));  
            Applicant__c applicant = [SELECT Id, Loan_Application__c,First_Name__c,Full_Name__c,Last_Name__c,Personal_email_ID__c,Mobile_Number__c 
                                      FROM Applicant__c LIMIT 1];
            applicant.Personal_email_ID__c = '';
            update applicant;
            Loan_Application__c loan = [SELECT Id,Name FROM Loan_Application__c LIMIT 1];
            String applicantId = applicant.Id;
            String loanApplicationId = loan.Id;
            String strTriggerPoint = 'Case_Rejection';
            String toUserId = 'test@gmail.com';
            AUSF_NotificationController.LoanAppWrapper loanAppWrapperObj = new AUSF_NotificationController.LoanAppWrapper(applicant,loan,applicantId,loanApplicationId,strTriggerPoint,toUserId);
            AUSF_EmailNotificationHandler.sendEmailNotification(loanAppWrapperObj);
            AUSF_EmailNotificationHandler.getFileDetails('',loanApplicationId,applicantId);
            Test.stopTest();
            System.assertEquals('Missing Pre-requisites',[SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c =: applicantId].Status__c,'IC Not Missing Pre-requisites');            
        }
    }
    @isTest
    public static void sendEmailNotificationTest5(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('',400));  
            Applicant__c applicant = [SELECT Id, Loan_Application__c,First_Name__c,Full_Name__c,Last_Name__c,Personal_email_ID__c,Mobile_Number__c 
                                      FROM Applicant__c LIMIT 1];
            Loan_Application__c loan = [SELECT Id,Name FROM Loan_Application__c LIMIT 1];
            String applicantId = applicant.Id;
            String loanApplicationId = loan.Id;
            String strTriggerPoint = 'Case_Rejection';
            String toUserId = 'test@gmail.com';
            AUSF_NotificationController.LoanAppWrapper loanAppWrapperObj = new AUSF_NotificationController.LoanAppWrapper(applicant,loan,applicantId,loanApplicationId,strTriggerPoint,toUserId);
            AUSF_EmailNotificationHandler.sendEmailNotification(loanAppWrapperObj);
            AUSF_EmailNotificationHandler.getFileDetails('Rejection Letter',loanApplicationId,applicantId);
            Test.stopTest();
            System.assertEquals('Completed',[SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c =: applicantId].Status__c,'IC Not Failed');            
        }
    }
    @isTest
    public static void EmailNotificationIntegrationHandlerTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            AUSF_EmailNotificationIntegrationHandler obj = new AUSF_EmailNotificationIntegrationHandler();
            List<Object> request = AUSF_EmailNotificationIntegrationHandler.generateRequest(new List<Object>());
            List<SObject> res = obj.generatePlatformEvents(NULL);
            obj.callbackService(NULL,NULL);
            obj.beforeUpdateService(NULL,NULL);
            Test.stopTest();
        }
    }
}