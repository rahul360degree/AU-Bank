/**
* @author        Rahul Yadav.
* @date          18-June-2024
* @description   This class is covring of code coverage AUSF_EmailAuthenticationController,AUSF_EmailAuthenticationHandler,AUSF_EmailAuthenticationWrapper,AUSF_INT_ElectricityBillRequestWrapper
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav.          26-June-2024    Initial Version
*/
@IsTest
public class AUSF_EmailAuthenticationTest {
    @testSetup 
    static void setup() {
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster(AUSF_ApexConstants.AUSF_EMAIL_VERIFICATION_INTEGRATION_MASTER, 'https://api.aubankuat.in/sfdc/TransunionVerifyService/emailVerification', 'SFDC', 'POST', 'application/json' , 'AUSF_EmailAuthenticationHandler'); 
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
    @description    : doEmailAuthentication - this method will be cover code coverage in success scenario
    */
    @IsTest
    public static void testControllerSuccess() {
        User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.ausf' LIMIT 1];
        system.assertEquals('sales@salesforce.com',objUser.Email);
        System.runAs(objUser){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200', '50'));
                Loan_Application__c lpList = [SELECT Id FROM Loan_Application__c LIMIT 1];
                Applicant__c apList = [SELECT Id FROM Applicant__c LIMIT 1];
                AUSF_EmailAuthenticationWrapper response = AUSF_EmailAuthenticationController.doEmailAuthentication(lpList.Id, apList.Id, 'knitesh970@gmail.com');
                System.assert(response.responseWrapper.checklistRecord.Status__c == 'Completed');
                System.assert(response.responseWrapper != null);
            Test.stopTest();
        }
    }
    /*
    @description    : doEmailAuthentication - this method will be cover code coverage in failiure scenario
    */
    @IsTest
    public static void testControllerFailure() {
        User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.ausf' LIMIT 1];
        system.assertEquals('sales@salesforce.com',objUser.Email);
        System.runAs(objUser){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400', '101'));
                Loan_Application__c lpList = [SELECT Id FROM Loan_Application__c LIMIT 1];
                Applicant__c apList = [SELECT Id FROM Applicant__c LIMIT 1];
                AUSF_EmailAuthenticationController.doEmailAuthentication(lpList.Id, apList.Id, 'tarun@aubank.in');
                AUSF_EmailAuthenticationWrapper response = AUSF_EmailAuthenticationController.doEmailAuthentication(lpList.Id, apList.Id, 'invalidemail@aubank.in');
                System.assert(response.responseWrapper.checklistRecord.Status__c == 'Failed');
            Test.stopTest();
        }
    }
    /*
    @description    : doEmailAuthentication - this method will be cover code coverage of Invalid email case conditions.
    */
    @IsTest
    public static void testControllerInvalidEmail() {
        User objUser = [SELECT Id, Email FROM User WHERE username = 'sales@salesforce.com.ausf' LIMIT 1];
        system.assertEquals('sales@salesforce.com',objUser.Email);
        System.runAs(objUser){
            Test.startTest();
                Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200', '51'));
                AUSF_EmailAuthenticationHandler ebhandler = new AUSF_EmailAuthenticationHandler();
                ebhandler.generatePlatformEvents(new List<Object>());
            	ebhandler.beforeUpdateService(null, null);
        	    ebhandler.callbackService(new List<Integration_Checklist__c>(), new List<ContentVersion>());
                Loan_Application__c lpList = [SELECT Id FROM Loan_Application__c LIMIT 1];
                Applicant__c apList = [SELECT Id FROM Applicant__c LIMIT 1];
                try {
                    AUSF_EmailAuthenticationWrapper response = AUSF_EmailAuthenticationController.doEmailAuthentication(lpList.Id, apList.Id, 'invalidemail@aubank.in');
                    System.assert(response.blnIntegrationSuccess == false);
                } catch (AUSF_EmailAuthenticationController.CustomException e) {
                    System.assert(e.getMessage().contains('Invalid email validation status code.'));
                }
            Test.stopTest();
        } 
    }
}