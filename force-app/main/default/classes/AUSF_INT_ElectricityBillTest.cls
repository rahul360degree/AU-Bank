/**
* @author        Rahul Yadav
* Class :		 AUSF_INT_ElectricityBillTest
* @date          04-July-2024
* @description   Test class for AUSF_INT_ElectricityBillController,AUSF_INT_ElectricityBillHandler
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav        27-June-2024    Initial Version
*/
@IsTest
public class AUSF_INT_ElectricityBillTest {
@testSetup 
    static void setup() {
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster(AUSF_ApexConstants.AUSF_ELECTRICITY_INTEGRATION_MASTER, 'https://api.aubankuat.in/sfdckyc/Karza/ebill?', 'SFDC', 'GET', 'application/json' , 'AUSF_INT_ElectricityBillHandler'); 
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
    @description    : AUSF_IntegrationMockResponse - this method will be cover code coverage in success scenario
    */
     @isTest
    public static void testControllerSuccess(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.ausf' LIMIT 1];
        system.assertEquals('sales@salesforce.com',objUser.Email);
        System.runAs(objUser){
            Test.startTest();
                // Mock response for success scenario
                String mockResponseBody = '{ "result": { "bill_no": "", "bill_due_date": "", "consumer_number": "3002497191", "bill_amount": "", "bill_issue_date": "", "mobile_number": "62XXXXX423", "amount_payable": "", "total_amount": "", "address": "", "consumer_name": "BALKAR SINGH", "email_address": "", "bill_date": "" }, "request_id": "ebcdad52-307e-407b-9701-8a87113f423f", "status-code": "101" }';
                Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(mockResponseBody, 200));
                Loan_Application__c lpList = [SELECT Id FROM Loan_Application__c LIMIT 1];
                Applicant__c apList = [SELECT Id FROM Applicant__c LIMIT 1];
                AUSF_INT_ElectricityBillResponseWrapper responseWrapper = AUSF_INT_ElectricityBillController.doElectricityBillCallOut(lpList.Id, apList.Id, '3002497191', 'PSPCL');
                // Assert the response
                System.assertEquals(true, responseWrapper.blnIntegrationSuccess);
                System.assertEquals('200', String.valueOf(responseWrapper.responseWrapper.statusCode));
            Test.stopTest();
        }
    }
     /*
    @description    : AUSF_IntegrationMockResponse - this method will be cover code coverage in failiure scenario
    */
    @isTest
    public static void testControllerFailure(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.ausf' LIMIT 1];
        system.assertEquals('sales@salesforce.com',objUser.Email);
        System.runAs(objUser){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400','102'));
                Loan_Application__c lpList = [SELECT Id FROM Loan_Application__c LIMIT 1];
                Applicant__c apList = [SELECT Id FROM Applicant__c LIMIT 1];
                AUSF_INT_ElectricityBillResponseWrapper responseWrapper = AUSF_INT_ElectricityBillController.doElectricityBillCallOut(lpList.Id, apList.Id, '3002497191', 'PSPCL');
		        System.assertEquals(false, responseWrapper.blnIntegrationSuccess);
                System.assertEquals('0', String.valueOf(responseWrapper.responseWrapper.statusCode));
            Test.stopTest();
        }    
    }
    /*
    @description    : AUSF_IntegrationMockResponse - this method will be cover code coverage of statscode !=101 condition. 
    */
    @isTest
    public static void testControllerSuccessAPI(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.ausf' LIMIT 1];
        system.assertEquals('sales@salesforce.com',objUser.Email);
        System.runAs(objUser){
            Test.startTest();
                // Mock response for success scenario
                String mockResponseBody = '{ "result": { "bill_no": "", "bill_due_date": "", "consumer_number": "3002497191", "bill_amount": "", "bill_issue_date": "", "mobile_number": "62XXXXX423", "amount_payable": "", "total_amount": "", "address": "", "consumer_name": "BALKAR SINGH", "email_address": "", "bill_date": "" }, "request_id": "ebcdad52-307e-407b-9701-8a87113f423f", "status-code": "104" }';
                Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(mockResponseBody, 200));
                Loan_Application__c lpList = [SELECT Id FROM Loan_Application__c LIMIT 1];
                Applicant__c apList = [SELECT Id FROM Applicant__c LIMIT 1];
                AUSF_INT_ElectricityBillResponseWrapper responseWrapper = AUSF_INT_ElectricityBillController.doElectricityBillCallOut(lpList.Id, apList.Id, '3002497191', 'PSPCL');
                AUSF_INT_ElectricityBillHandler ebhandler = new AUSF_INT_ElectricityBillHandler();
                ebhandler.generatePlatformEvents(new List<Object>());
                ebhandler.beforeUpdateService(null, null);
                ebhandler.callbackService(new List<Integration_Checklist__c>(), new List<ContentVersion>());
                // Assert the response
                System.assertEquals(false, responseWrapper.blnIntegrationSuccess);
                System.assertEquals('200', String.valueOf(responseWrapper.responseWrapper.statusCode));
            Test.stopTest();
        }    
    }
}