/**
* @author        Pradeep Sharma
* Class :        AUSF_MobileOtpTest
* @date          22-June-2024
* @description   Test class for AUSF_MobileOTPIntegrationHandler,AUSF_MobileOtpController
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Pradeep Sharma        27-June-2024    Initial Version
*/
@isTest
public class AUSF_MobileOtpTest {
    @testSetup 
    public static void setup() {
        List<Integration_Master__c> mastersToInsert =  new List<Integration_Master__c>();
        Integration_Master__c intMaster1 = new Integration_Master__c (
            Name ='Mobile Generate OTP',
            End_Point_URL__c='https://api.aubankuat.in/sfdc/OTPEngineRestService/generateOTP',
            Channel__c ='SFDC',
            HTTP_Method__c='POST',
            Timeout__c=120000,
            content_type__c = 'application/json',
            Active__c = true,
            Apex_Class_Name__c = 'AUSF_MobileOTPIntegrationHandler'
        );  
        mastersToInsert.add(intMaster1);
        Integration_Master__c intMaster2 = new Integration_Master__c (
            Name ='Mobile Validate OTP',
            End_Point_URL__c='https://api.aubankuat.in/sfdc/OTPEngineRestService/validateOTP',
            Channel__c ='SFDC',
            HTTP_Method__c='POST',
            Timeout__c=120000,
            content_type__c = 'application/json',
            Active__c = true,
            Apex_Class_Name__c = 'AUSF_MobileOTPIntegrationHandler'
        );  
        mastersToInsert.add(intMaster2);
        Integration_Master__c intMaster3 = new Integration_Master__c (
            Name ='Mobile Resend OTP',
            End_Point_URL__c='https://api.aubankuat.in/sfdc/OTPEngineRestService/generateOTP',
            Channel__c ='SFDC',
            HTTP_Method__c='POST',
            Timeout__c=120000,
            Static_Response__c = 'MobileOTPValidate',
            content_type__c = 'application/json',
            Active__c = true,
            Apex_Class_Name__c = 'AUSF_MobileOTPIntegrationHandler'
        );  
        mastersToInsert.add(intMaster3);
        Lead_Stage__c lead = new Lead_Stage__c(); 
        insert lead;
        insert mastersToInsert;
        Integration_Checklist__c checklist = new Integration_Checklist__c (
            Integration_Master__c = intMaster1.Id,
            Status__c = 'Completed',
            Lead_Stage__c = lead.Id,
            Request__c = '{"requestId":"SFDCDEV_023c4b15cae2f64dea73454b3","otptype":"0","otptimeout":"300","otplength":"6","otp":"","msgContent":"Dear Customer,Confirmation code for loan application with us is {0}.....- AU Bank","mobile":"9057226483","custRef":"SFDCDEV023c4b15cae2f64dea73454b3","channel":"SFDC"}',
            Response__c = '{"StatusDesc":"The Otp is generated successfully","CustRef":"SFDCDEV023c4b15cae2f64dea73454b3","StatusCode":100,"RequestStatus":"Success"}'
        );  
        
        insert checklist;
        
        
    }
    @isTest
    public static void testGenerateOtp(){
        Test.startTest();
        String leadId = [SELECT Id,Name FROM Lead_Stage__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','100'));
        AUSF_MobileOtpController.mobileOtpVerificationHandler('9057226481','',leadId,'Mobile Generate OTP');
        AUSF_MobileOTPIntegrationHandler otp = new AUSF_MobileOTPIntegrationHandler();
        otp.beforeUpdateService(null,null);
        otp.callbackService(null,null);
        otp.generatePlatformEvents(new List<Object>());
        Test.stopTest();
        Assert.areEqual('Completed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE Lead_Stage__c = :leadId].Status__c ,'IC-Complete');
        
    }
    @isTest
    public static void testOtpFailure(){
        Test.startTest();
        String leadId = [SELECT Id,Name FROM Lead_Stage__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','110'));
        AUSF_MobileOtpController.mobileOtpVerificationHandler('9057226481','',leadId,'Mobile Generate OTP');
        Test.stopTest();
        Assert.areEqual('Failed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE Lead_Stage__c = :leadId].Status__c ,'IC-Failed');
        
    }
     @isTest
    public static void testOtpApiFailure(){
        Test.startTest();
        String leadId = [SELECT Id,Name FROM Lead_Stage__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','110'));
        AUSF_MobileOtpController.mobileOtpVerificationHandler('9057226481','',leadId,'Mobile Generate OTP');
        AUSF_INT_MobileOTPResponseWrapper mOtp = new AUSF_INT_MobileOTPResponseWrapper();
        AUSF_OTPRequestWrapper req = new AUSF_OTPRequestWrapper();
        Test.stopTest();
        Assert.areEqual('Failed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE Lead_Stage__c = :leadId].Status__c,'IC-Failed');
    }
    @isTest
    public static void testValidateOtp(){
        Test.startTest();
        String leadId = [SELECT Id,Name FROM Lead_Stage__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','100'));
        AUSF_MobileOtpController.mobileOtpVerificationHandler('9057226481','123456',leadId,'Mobile Validate OTP');
        Test.stopTest();
        Assert.areEqual('Completed' ,[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE Lead_Stage__c = :leadId and Integration_Master__r.Name = 'Mobile Validate OTP'].Status__c ,'IC-Complete');
        
    }
}