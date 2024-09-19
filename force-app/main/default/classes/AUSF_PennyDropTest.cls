/**
* @author        Rahul Yadav
* Class :        AUSF_PennyDropTest
* @date          06-July-2024
* @description   Test class for AUSF_PennyDropController,AUSF_PennyDropHandler
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav        06-July-2024    Initial Version
*/
@IsTest
public class AUSF_PennyDropTest {
@testSetup 
static void setup() {
    Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster(AUSF_ApexConstants.AUSF_PENNY_DROP_INTEGRATION_MASTER, 'https://api.aubankuat.in/sfdckyc/SFDCKarza/BankAccVerification?', 'SFDC', 'GET', 'application/json' , 'AUSF_PennyDropHandler');  
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
    @description    : doAccountVerificationCallOut - this method will be cover code coverage of statscode ==101 condition. 
    */
@isTest
public static void testControllerSuccessStatus101(){
    User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.ausf' LIMIT 1];
    system.assertEquals('sales@salesforce.com',objUser.Email);
    System.runAs(objUser){
        Test.startTest();
            String mockResponseBody = '{"result":{"accountNumber":"2301244951696922","ifsc":"AUBL0002449","accountName":"","bankResponse":"Invalid Account Number","bankTxnStatus":false},"request_id":"a579636c-a6c1-4366-b243-ac07a4d52707","status-code":"101"}';
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(mockResponseBody, 200));
            Loan_Application__c lpList = [SELECT Id FROM Loan_Application__c LIMIT 1];
            Applicant__c apList = [SELECT Id FROM Applicant__c LIMIT 1];
            AUSF_PennyDropResponseWrapper responseWrapper = AUSF_PennyDropController.doAccountVerificationCallOut(lpList.Id, apList.Id, 'UTIB0002118', '11111111111170');
            // Assert the response
            AUSF_PennyDropHandler ebhandler = new AUSF_PennyDropHandler();
            ebhandler.generatePlatformEvents(new List<Object>());
            ebhandler.beforeUpdateService(null, null);
            System.assertEquals(true, responseWrapper.blnIntegrationSuccess);
            System.assertEquals('200', String.valueOf(responseWrapper.responseWrapper.statusCode));
        Test.stopTest();
    }
}
    /*
    @description    : doAccountVerificationCallOut - this method will be cover code coverage of statscode !=101 condition.
    */
@isTest
public static void testControllerSuccessStatus104(){
    User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.ausf' LIMIT 1];
    system.assertEquals('sales@salesforce.com',objUser.Email);
    System.runAs(objUser){
        Test.startTest();
            String mockResponseBody = '{"result":{"accountNumber":"2301244951696922","ifsc":"AUBL0002449","accountName":"","bankResponse":"Invalid Account Number","bankTxnStatus":false},"request_id":"a579636c-a6c1-4366-b243-ac07a4d52707","status-code":"104"}';
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(mockResponseBody, 200));
            Loan_Application__c lpList = [SELECT Id FROM Loan_Application__c LIMIT 1];
            Applicant__c apList = [SELECT Id FROM Applicant__c LIMIT 1];
            AUSF_PennyDropResponseWrapper responseWrapper = AUSF_PennyDropController.doAccountVerificationCallOut(lpList.Id, apList.Id, 'UTIB0002118', '11111111111170');
            // Assert the response
            AUSF_PennyDropHandler ebhandler = new AUSF_PennyDropHandler();
            ebhandler.generatePlatformEvents(new List<Object>());
            ebhandler.beforeUpdateService(null, null);
            System.assertEquals(false, responseWrapper.blnIntegrationSuccess);
            System.assertEquals('200', String.valueOf(responseWrapper.responseWrapper.statusCode));
        Test.stopTest();
    }
}
   /*
    @description    : doAccountVerificationCallOut - this method will be cover code coverage in failiure scenario
    */
@isTest
public static void testControllerFailure(){
    User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.ausf' LIMIT 1];
    system.assertEquals('sales@salesforce.com',objUser.Email);
    System.runAs(objUser){
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400','101'));
            Loan_Application__c lpList = [SELECT Id FROM Loan_Application__c LIMIT 1];
            Applicant__c apList = [SELECT Id FROM Applicant__c LIMIT 1];
            String statuscode = String.valueOf(AUSF_PennyDropController.doAccountVerificationCallOut(lpList.Id, apList.Id, 'UTIB0002118', '11111111111170').responseWrapper.statusCode);
            AUSF_PennyDropHandler ebhandler = new AUSF_PennyDropHandler();
            ebhandler.generatePlatformEvents(new List<Object>());
        	ebhandler.callbackService(new List<Integration_Checklist__c>(), new List<ContentVersion>());
            system.assertEquals('0',statuscode,'');
        Test.stopTest();
    }
 }
}