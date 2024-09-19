/**
* @author        Pradeep Sharma
* Class :		 AUSF_DocumentCompressTest
* @date          05-July-2024
* @description   Test class for AUSF_DocumentCompressController,AUSF_DocumentCompressHandler
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Pradeep Sharma        05-July-2024    Initial Version
*/
@isTest
public class AUSF_DocumentCompressTest {
    @testSetup 
    static void setup() {
        Integration_Master__c intMaster = AUSF_TestDataFactory.createIntegrationMaster('DocumentCompressService', 'https://aufilecompressor.aubank.in:8443/Service1.svc/CompressFiles', 'SFDC','POST', 'application/json', 'AUSF_DocumentCompressHandler');
        Loan_Application__c loanApp = AUSF_TestDataFactory.createActiveLoanApplications(new List<Loan_Application__c>(),1)[0];
        insert loanApp;
        insert intMaster;
        List<Loan_Application__c> lstLoanApps = new List<Loan_Application__c>();
        lstLoanApps.add(loanApp);
        Applicant__c applicant = AUSF_TestDataFactory.createApplicantRecords(lstLoanApps, 1)[0];
        ContentVersion contentVersion = AUSF_TestDataFactory.createContentVersion('Penguins','Penguins.jpg',Blob.valueOf('Test Content'),true);
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = AUSF_TestDataFactory.createContentDocumentLink(applicant.Id,documents[0].Id);
        Document_Master__c docMaster = AUSF_TestDataFactory.createDocumentMaster('Test Master');
        Document_Checklist__c docCheckList = AUSF_TestDataFactory.createDocumentChecklist(applicant.Id,docMaster.Id);

    }
    @isTest
    public static void testDocumentCompress(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','ADS00'));
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Blob blobData = [SELECT Id,VersionData,FileType FROM ContentVersion WHERE FileType = 'jpg' Order by createddate LIMIT 1].VersionData;
        Document_Checklist__c docChecklist = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        AUSF_DocumentCompressController.getCompresssedDocument(EncodingUtil.base64Encode(blobData),'test.jpg',applicantId,'',docChecklist.Id);
        AUSF_DocumentCompressHandler docApi = new AUSF_DocumentCompressHandler();
        docApi.beforeUpdateService(null,null);
        docApi.callbackService(null, null);
        docApi.generatePlatformEvents(null);
        AUSF_DocumentCompressResponseWrapper response = new AUSF_DocumentCompressResponseWrapper();
        Test.stopTest();
        String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId OR Document_Checklist__c =:docChecklist.Id LIMIT 1].Status__c;
        Assert.areEqual('Completed' ,status ,'IC-Complete');
    }
    @isTest
    public static void testDocumentCompressWrongCode(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','ADS05'));
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Blob blobData = [SELECT Id,VersionData,FileType FROM ContentVersion WHERE FileType = 'jpg' Order by createddate LIMIT 1].VersionData;
        Document_Checklist__c docChecklist = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        AUSF_DocumentCompressController.getCompresssedDocument(EncodingUtil.base64Encode(blobData),'test.jpg',applicantId,'',docChecklist.Id);
        Test.stopTest();
        String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId OR Document_Checklist__c =:docChecklist.Id LIMIT 1].Status__c;
        Assert.areEqual('Failed' ,status ,'IC-Failed');
    }
    @isTest
    public static void testDocumentCompressFail(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('400',''));
        String loanId = [SELECT ID FROM Loan_Application__c LIMIT 1].Id;
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Blob blobData = [SELECT Id,VersionData,FileType FROM ContentVersion WHERE FileType = 'jpg' Order by createddate LIMIT 1].VersionData;
        Document_Checklist__c docChecklist = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        AUSF_DocumentCompressController.getCompresssedDocument(EncodingUtil.base64Encode(blobData),'test.jpg',applicantId,'',docChecklist.Id);
        Test.stopTest();
        String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE Loan_application__c = :loanId OR Document_Checklist__c =:docChecklist.Id LIMIT 1].Status__c;
        Assert.areEqual('Failed' ,status ,'IC-Failed');
    }
    @isTest
    public static void testDocumentCompressCalloutFail(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','ADS01'));
        String loanId = [SELECT ID FROM Loan_Application__c LIMIT 1].Id;
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Blob blobData = [SELECT Id,VersionData,FileType FROM ContentVersion WHERE FileType = 'jpg' Order by createddate LIMIT 1].VersionData;
        Document_Checklist__c docChecklist = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        AUSF_DocumentCompressController.getCompresssedDocument(EncodingUtil.base64Encode(blobData),'test.jpg',applicantId,'',docChecklist.Id);
        Test.stopTest();
        String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE applicant__c = :applicantId OR Document_Checklist__c =:docChecklist.Id LIMIT 1].Status__c;
        Assert.areEqual('Failed' ,status ,'IC-Failed');    }
}