/**
* @author        Tejendra Jaroli
* Class :		 AUSF_AMLControllerTest
* @date          1-July-2024
* @description   Test class for AUSF_AMLController,AUSF_AMLHandler
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra Jaroli        1-July-2024    Initial Version
*/
@isTest
public class AUSF_AMLControllerTest {
    @TestSetup
    public static void makeData(){
        Profile prof = [select Id,Name from profile where name = 'Standard User'];
        User usr = new User(firstName = 'Standard User',
                            lastName = 'test2',
                            profileId = prof.id,
                            username = 'standardUsertar'+UserInfo.getOrganizationId()+'@test.com',
                            email = 'test@test.com',
                            alias = 'test',
                            TimeZoneSidKey = 'GMT', 
                            LocaleSidKey = 'en_GB', 
                            EmailEncodingKey = 'ISO-8859-1',
                            LanguageLocaleKey = 'en_US');
        insert usr;
        Integration_Master__c intmassearch1 = new Integration_Master__c(
            Name = 'Aml',
            Active__c = true,
            Timeout__c = 120000,
            End_Point_URL__c = 'https://api.aubankuat.in/sfdckyc/Clari5RestAPIService/fraudCheck',
            HTTP_Method__c = 'POST',
            Apex_Class_Name__c = 'AUSF_AmlHandler',
            Content_Type__c = 'application/json'
        );
        insert intmassearch1;
        
        Loan_Application__c loanAppl = new Loan_Application__c();
        loanAppl.Name = 'AP-12345';
        insert loanAppl;
        
        Applicant__c appl1 = new Applicant__c();
        appl1.Loan_Application__c = loanAppl.Id;
        insert appl1;
    }
    
    @isTest
    public static void testdoAML1(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','','success'));
            String loanId = String.valueOf([SELECT Id FROM Loan_Application__c].Id);
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            AUSF_AmlController.doAML(loanId,applId);
            Integration_Checklist__c integrationChecklist = [SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c =: applId];
            integrationChecklist.Callback_Request__c = '{"AML_ACTION":"Rejected","ReferenceId":"SFDCDEV_e09f79792606911d03f3c2600","systemName":"PLSF","UserId":"SYS","BatchMode":"0","Refid":"LEAD-0000000001","MATCH":"YES","status":{"status":"success","errorDetails":""}}';
            update integrationChecklist;
            Test.stopTest();
            System.assertEquals('No',[SELECT AML_verified__c FROM Applicant__c WHERE Id =: applId].AML_verified__c,'AML should not verified');
        }
    }
    
    @isTest
    public static void testNameMatch2(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400',''));
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            String loanId = String.valueOf([SELECT Id FROM Loan_Application__c].Id);
            AUSF_AmlController.doAML(loanId,applId);
            Test.stopTest();
            System.assertEquals('Failed',[SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c =: applId].Status__c,'IC Not Completed');
        }    
    }
    @isTest
    public static void testNameMatch3(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','','error')); 
            String loanId = String.valueOf([SELECT Id FROM Loan_Application__c].Id);
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            AUSF_AmlController.doAML(loanId,applId);
            Test.stopTest();
            System.assertEquals('Failed',[SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c =: applId].Status__c,'IC Not Completed');
        }
    }
    
    @isTest
    public static void testdoAML4(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('{"AML_ACTION":"Hold","ReferenceId":"SFDCDEV_e09f79792606911d03f3c2600","systemName":"PLSF","UserId":"SYS","BatchMode":"0","Refid":"LEAD-0000000001","MATCH":"YES","status":{"status":"success","errorDetails":""}}',200));  
            String loanId = String.valueOf([SELECT Id FROM Loan_Application__c].Id);
            String applId = String.valueOf([SELECT Id FROM Applicant__c].Id);
            AUSF_AmlController.doAML(loanId,applId);
            Integration_Checklist__c integrationChecklist = [SELECT Status__c FROM Integration_Checklist__c WHERE Applicant__c =: applId];
            integrationChecklist.Callback_Request__c = '{"AML_ACTION":"Approved","ReferenceId":"SFDCDEV_e09f79792606911d03f3c2600","systemName":"PLSF","UserId":"SYS","BatchMode":"0","Refid":"LEAD-0000000001","MATCH":"YES","status":{"status":"success","errorDetails":""}}';
            update integrationChecklist;
            Test.stopTest();
            System.assertEquals('Yes',[SELECT AML_verified__c FROM Applicant__c WHERE Id =: applId].AML_verified__c,'AML should Verified');
        }
    }
    
    @isTest
    public static void AmlHandlerTest(){
        User usr = [SELECT Id FROM User WHERE FirstName = 'Standard User'];
        System.runAs(usr){
            Test.startTest();
            AUSF_AMLHandler obj = new AUSF_AMLHandler();
            List<Object> request = obj.generateRequest(new List<Object>());
            List<SObject> res = obj.generatePlatformEvents(NULL);
            obj.callbackService(NULL,NULL);
            obj.beforeUpdateService(NULL,NULL);
            Test.stopTest();
        }
    }
}