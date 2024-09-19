/**
* @author              : Amit Mishra
* @date                : 26-June-2024
* @description         : Test Class for AUSF_NsdlPanCalloutController, AUSF_NsdlPanHandler, AUSF_NsdlPanRequestWrapper, AUSF_INT_ValidatePANResponseWrapper
* History              :
* ====================================================================
* <Date> 		<Authors Name> 		<Brief Description of Change>
* ====================================================================
* 26-June-2024 	Amit Mishra 		Initial Version
**/
@isTest
public class AUSF_NsdlPanTest {
    
    @TestSetup
    static void makeData(){
        Integration_Master__c intMaster = new Integration_Master__c (
            Name = 'NSDL - PAN Verification',
            End_Point_URL__c ='https://api.aubankuat.in/sfdckyc/PANValidationServiceV2/verifyPan',
            Channel__c = 'SFDC',
            HTTP_Method__c = 'POST',
            Timeout__c = 120000,
            content_type__c = 'application/json',
            Apex_Class_Name__c = 'AUSF_NsdlPanHandler',
            Active__c = true
        );  
        insert intMaster;
        
        Loan_Application__c loanApp = new Loan_Application__c();
        loanApp.Mobile_Number__c = '1234567890';
        loanApp.Stage__c = 'Pending';
        loanApp.Exempt_Duplicate__c = false;
        insert loanApp;
        
        Applicant__c applicant = new Applicant__c(Gender__c = 'Male',Loan_application__c = loanApp.Id);
        insert Applicant;
    }
    @isTest
    public static void validatePANTest(){
        Test.startTest();
        List<Applicant__c> applicant = [SELECT Id FROM Applicant__c LIMIT 1];
        String body = '{"headers":{"responseCode":"0","responseMsg":"Success"},"response":[{"PAN":"CGVPD9078l","Name":"N","NameOnCard":null,"FatherName":null,"Status":"E","DateofBirth":"N","SeedingStatus":"Y"}]}';
        Integer StatusCode = 200;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(body,StatusCode));
        AUSF_INT_ValidatePANResponseWrapper value = AUSF_NsdlPanCalloutController.validatePAN(NULL, applicant[0].Id, 'ABCDD1056L', 'PRADEEP SHARMA', '03/03/1999');
        Test.stopTest();
    }
    
    @isTest
    public static void validatePanInvalidTest(){
        Test.startTest();
        String resException;
        List<Applicant__c> applicant = [SELECT Id FROM Applicant__c LIMIT 1];
        String bodyWithStatusG = '{"headers":{"responseCode":"0","responseMsg":"Success"},"response":[{"PAN":"ABCDD1086L","Name":"N","NameOnCard":null,"FatherName":null,"Status":"G","DateofBirth":"N","SeedingStatus":"Y"}]}';
        Integer StatusCode = 200;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(bodyWithStatusG,StatusCode));
        try{
            AUSF_INT_ValidatePANResponseWrapper value = AUSF_NsdlPanCalloutController.validatePAN(NULL, applicant[0].Id, 'ABCDD1086L', 'PRAP SHAMA', '03/03/1989');
        }catch(Exception ex){
            resException = ex.getMessage();
        }
        Test.stopTest();
    }
    
    @isTest
    public static void validatePANFailTest(){
        Test.startTest();
        String resException;
        List<Applicant__c> applicant = [SELECT Id FROM Applicant__c LIMIT 1];
        String body ='{"headers":{"responseCode":"0","responseMsg":"Success"},"response":[{"PAN":"CGVPD9078l","Name":"N","NameOnCard":null,"FatherName":null,"Status":"E","DateofBirth":"N","SeedingStatus":"Y"}]}';
        Integer StatusCode = 400;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(body,StatusCode));
        try{
            AUSF_INT_ValidatePANResponseWrapper value = AUSF_NsdlPanCalloutController.validatePAN(NULL, applicant[0].Id, 'ABCDD1086L', 'PRAP SHAMA', '03/03/1989');
        }catch(Exception ex){
            resException = ex.getMessage();
        }
        Test.stopTest();
    }
    @isTest
    public static void validatePANMasterFailTest(){
        List<Integration_Master__c> intMaster = [SELECT Id, Name FROM Integration_Master__c LIMIT 1];
        String masterName = intMaster[0].Name;
        intMaster[0].Name = 'test no master';
        update intMaster;
        Test.startTest();
        String resException;
        List<Applicant__c> applicant = [SELECT Id FROM Applicant__c LIMIT 1];
        String body ='';
        Integer StatusCode = 400;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(body,StatusCode));
        try{
			AUSF_INT_ValidatePANResponseWrapper value = AUSF_NsdlPanCalloutController.validatePAN(NULL, applicant[0].Id, 'ABCDD1056L', 'PRADEEP SHARMA', '03/03/1999');
        }catch(Exception ex){
            resException = ex.getMessage();
        }
        Test.stopTest();
        Assert.isNotNull(resException, 'Expected result not found');
        intMaster[0].Name = masterName;
        update intMaster;
    }
    
    @isTest
    public static void validateNsdlPanHandlerTest(){
        Test.startTest();
        AUSF_NsdlPanHandler obj = new AUSF_NsdlPanHandler();
        List<Object> request = obj.generateRequest(new List<Object>());//List<Object> inputWrappers
        List<SObject> res = obj.generatePlatformEvents(NULL);//new List<Object> recordList;
        obj.callbackService(NULL,NULL);//List<Integration_Checklist__c> checklistRecords, List<ContentVersion> responseFiles
        obj.beforeUpdateService(NULL,NULL);//Integration_Checklist__c checklistRecord, ContentVersion responseFile
        Test.stopTest();
    }
    
}