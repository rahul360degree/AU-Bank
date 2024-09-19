/*******************************************************************************************
* @Name         AUSF_CFRCheckTest
* @Author       Charchit Nirayanwal
* @Description  
*******************************************************************************************/
/* MODIFICATION LOG
* Version                   Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Charhit Nirayanwal            09-July-2024            Initial Creation 
*******************************************************************************************/


@isTest
public class AUSF_CFRCheckTest {
    
        @TestSetup
    static void makeData(){
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        Profile creditProfile = [SELECT Id FROM Profile WHERE Name='Credit']; 
        List<User> userObjList = new List<User>();
        User userObj = new User(Alias = 'standt', Email='admin@testorg.com', 
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = sysAdminProfile.Id, 
                                TimeZoneSidKey='America/Los_Angeles', UserName='test@auplorg1.com', FederationIdentifier='12345678');
        
        userObjList.add(userObj);
        
        User userObj1 = new User(Alias = 'standt', Email='admin@testorg.com', 
                                 EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                 LocaleSidKey='en_US', ProfileId = creditProfile.Id, 
                                 TimeZoneSidKey='America/Los_Angeles', UserName='test1@auplorg1.com', FederationIdentifier='12345678');
        
        userObjList.add(userObj1);
        insert userObjList;
        
        Generic_Master__c genericMasterObj = new Generic_Master__c();
        genericMasterObj.Custom_String__c = 'test';
        genericMasterObj.Screen_Name__c = 'Usage Policy ';
        genericMasterObj.name = 'AU Usage Policy';
        insert genericMasterObj;
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();   
        loanApps = AUPL_TestDataFactory.createActiveLoanApplications(loanApps,1);
        insert loanApps;
        AUSF_TestDataFactory.createApplicantRecords(loanApps,1);
        AUSF_TestDataFactory.createGenericMasterRecords('Electricity Bill Service Providers',1);
        AUSF_TestDataFactory.createGenericMasterRecords('Electricity Bill Service Providers to District Mapping',1);
        Integration_Master__c intMaster = AUSF_TestDataFactory.createIntegrationMaster('DocumentCompressService', 'https://aufilecompressor.aubank.in:8443/Service1.svc/CompressFiles', 'SFDC','POST', 'application/json', 'AUSF_DocumentCompressHandler');
        Loan_Application__c loanApp = AUSF_TestDataFactory.createActiveLoanApplications(new List<Loan_Application__c>(),1)[0];
        insert loanApp;
        insert intMaster;
        List<Loan_Application__c> lstLoanApps = new List<Loan_Application__c>();
        lstLoanApps.add(loanApp);
        Applicant__c applicant = AUSF_TestDataFactory.createApplicantRecordsCFR(lstLoanApps, 1)[0];
        ContentVersion contentVersion = AUSF_TestDataFactory.createContentVersion('Penguins','Penguins.jpg',Blob.valueOf('Test Content'),true);
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = AUSF_TestDataFactory.createContentDocumentLink(applicant.Id,documents[0].Id);
        Document_Master__c docMaster = AUSF_TestDataFactory.createDocumentMaster('Test Master');
        Document_Checklist__c docCheckList = AUSF_TestDataFactory.createDocumentChecklist(applicant.Id,docMaster.Id);
        CFR_Master__c CFRRec = new CFR_Master__c(PAN__C = 'TestFraud1');
        insert CFRRec;
    }
    
     @isTest
    static void CheckCFRFraud() {
        Test.startTest();
        // Call the method
        boolean res = AUSF_CFRCheck.checkCFR([SELECT Id FROM Applicant__c where PAN__C='TestFraud' LIMIT 1].Id,[SELECT Id FROM Loan_Application__c LIMIT 1].Id);
        // Verify the results
        System.assertEquals(res,true,'Fraud- Check need to be true');
        Test.stopTest();
    }
    
         @isTest
    static void CheckCFRNotFraud() {
        Test.startTest();
        // Call the method
        boolean res = AUSF_CFRCheck.checkCFR([SELECT Id FROM Applicant__c where PAN__C='TestFraud' LIMIT 1].Id,[SELECT Id FROM Loan_Application__c LIMIT 1].Id);
        // Verify the results
        System.assertEquals(res,false,'Fraud- Check need to be true');
        Test.stopTest();
    }
    
    /*
    @isTest
    static void CheckCFRWrongLoanApp() {
        Test.startTest();
        // Call the method
        boolean res = AUSF_CFRCheck.checkCFR([SELECT Id FROM Applicant__c where PAN__C='TestFraud' LIMIT 1].Id,[SELECT Id FROM Applicant__c where PAN__C='TestFraud' LIMIT 1].Id);
        // Verify the results
        System.assertEquals(res,null,'Fraud- Check need to be true');
        Test.stopTest();
    }
    */
    @isTest
    static void CheckCFRNullId() {
        Test.startTest();
        // Call the method
        boolean res = AUSF_CFRCheck.checkCFR([SELECT Id FROM Applicant__c where PAN__C='TestFraud' LIMIT 1].Id,null);
        // Verify the results
        System.assertEquals(res,false,'Fraud- Check need to be true');
        Test.stopTest();
    }
        @isTest
    static void CheckCFRNullAppId() {
        Test.startTest();
        // Call the method
        boolean res = AUSF_CFRCheck.checkCFR(null,null);
        // Verify the results
        System.assertEquals(res,null,'Fraud- Check need to be true');
        Test.stopTest();
    }
    
    

}