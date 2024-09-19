/**
* @author  Nitesh jaiswal
* @company Salesforce.com
* @description :
* History:
*
*************************************************************************************
MODIFICATION LOG
* Version     Date                Developer            Description
*-------------------------------------------------------------------------------------------
*  1.0    27th June 2024          Nitesh jaiswal       Initial Creation and added test cases for success and error of AUSF_Screen_Custom_Text__mdt metadata records.
*  2.0    27th June 2024          Asmita Mathur        Added test cases for success and error of getting Generic_Master__c object records.
*  3.0    2nd  July 2024          Asmita Mathur        Added test cases for success and error of creating Address__c object records.
*/

@isTest
public class AUSF_Utility_Test {
    
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
        Applicant__c applicant = AUSF_TestDataFactory.createApplicantRecords(lstLoanApps, 1)[0];
        ContentVersion contentVersion = AUSF_TestDataFactory.createContentVersion('Penguins','Penguins.jpg',Blob.valueOf('Test Content'),true);
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = AUSF_TestDataFactory.createContentDocumentLink(applicant.Id,documents[0].Id);
        Document_Master__c docMaster = AUSF_TestDataFactory.createDocumentMaster('Test Master');
        Document_Checklist__c docCheckList = AUSF_TestDataFactory.createDocumentChecklist(applicant.Id,docMaster.Id);
        ContentDocumentLink cdlDoc = AUSF_TestDataFactory.createContentDocumentLink(docCheckList.Id,documents[0].Id);

        // Fetch existing Record Types
        RecordType industryRt = [SELECT Id FROM RecordType WHERE SObjectType = 'Profiling_Master__c' AND DeveloperName = 'Industry' LIMIT 1];
        RecordType subIndustryRt = [SELECT Id FROM RecordType WHERE SObjectType = 'Profiling_Master__c' AND DeveloperName = 'Sub_Industry' LIMIT 1];
        RecordType activityRt = [SELECT Id FROM RecordType WHERE SObjectType = 'Profiling_Master__c' AND DeveloperName = 'Activity' LIMIT 1];

        // Create Test Records
        Profiling_Master__c industry1 = new Profiling_Master__c(Name = 'Industry 1', Code__c = 12, Inactive__c = false, RecordTypeId = industryRt.Id);
        insert industry1;
        Profiling_Master__c subIndustry1 = new Profiling_Master__c(Name = 'Sub Industry 1', Code__c = 123, Inactive__c = false, RecordTypeId = subIndustryRt.Id, Industry__c = industry1.Id);
        insert subIndustry1;
        Profiling_Master__c activity1 = new Profiling_Master__c(Name = 'Activity 1', Code__c = 1234, Inactive__c = false, RecordTypeId = activityRt.Id, Sub_Industry__c = subIndustry1.Id);
        insert activity1;

    }
    
    @isTest
    static void testgetGenericMasterRecordsSuccess() {
        string screenName = 'Usage Policy';
        string name = 'AU Usage Policy';
        List<Generic_Master__c> genericMasterList = AUSF_Utility.getGenericMasterRecords(screenName,name);
        System.assertEquals(1, genericMasterList.size());
    }
    @isTest
    static void testgetGenericMasterRecordsError() {
        string screenName = 'Test';
        string name = 'AU Terms of use';
        List<Generic_Master__c> genericMasterList = AUSF_Utility.getGenericMasterRecords(screenName,name);
        System.assertEquals(0, genericMasterList.size());
    }
    @isTest
    static void testgetScreenCustomTextRecordsSuccess() {
        string screenName = 'Purpose of Loan';
        List<AUSF_Screen_Custom_Text__mdt> metadatList = AUSF_Utility.getScreenCustomTextRecords(screenName);
        //System.assertEquals(1, metadatList.size());
    }
    @isTest
    static void testgetScreenCustomTextRecordsError() {
        string screenName = 'Test';
        List<AUSF_Screen_Custom_Text__mdt> metadatList = AUSF_Utility.getScreenCustomTextRecords(screenName);
        System.assertEquals(0, metadatList.size());
    }
    @isTest
    static void testgetCurrentScreenDetailsSuccess() {
        string screenName = 'Purpose of Loan';
        AUSF_Utility.ScreenWrapper wrapperObj = AUSF_Utility.getCurrentScreenData((String)([SELECT Id FROM Loan_Application__c LIMIT 1].Id),(String)([SELECT Id FROM Applicant__c LIMIT 1].Id),screenName,'');
        //System.assertEquals(1, wrapperObj.wizardDataDIYList.size());
        System.assertEquals(1, wrapperObj.loanApplicationList.size());
    }
    @isTest
    static void testgetCurrentScreenDetailsSuccess2() {
        List<User> userList = [SELECT Id FROM User WHERE Profile.Name = 'Credit'];
        string screenName = 'Purpose of Loan';
        System.runas(userList[0]){
            AUSF_Utility.ScreenWrapper wrapperObj = AUSF_Utility.getCurrentScreenData((String)([SELECT Id FROM Loan_Application__c LIMIT 1].Id),(String)([SELECT Id FROM Applicant__c LIMIT 1].Id),screenName,'');
            System.assertEquals(1, wrapperObj.wizardDataAssistedList.size());
            System.assertEquals(1, wrapperObj.loanApplicationList.size());
        }
    }
    
    @isTest
    static void testgetCurrentScreenDataCatgSuccess() {
        Loan_Application__c loanApp = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Applicant__c applicant = [SELECT Id FROM Applicant__c LIMIT 1];
        // JSON string for input parameters
        String jsonString = '{"loanApplicationId":"'+loanApp.Id+'", "applicantId":"'+applicant.Id+'", "screenName":"Purpose of Loan", "masterName":"TestMaster", "documentCategory":"TestCategory", "docMasterName":"TestDocMaster", "addressSource":"TestSource", "addressId":"TestAddressId"}';
        AUSF_Utility.ScreenWrapper wrapperObj = AUSF_Utility.getCurrentScreenDataCatg(jsonString);
        System.assertEquals(1, wrapperObj.loanApplicationList.size());
    }
    @isTest
    static void testgetCurrentScreenDataCatgSuccess2() {
        List<User> userList = [SELECT Id FROM User WHERE Profile.Name = 'Credit'];
        Loan_Application__c loanApp = [SELECT Id FROM Loan_Application__c LIMIT 1];
        Applicant__c applicant = [SELECT Id FROM Applicant__c LIMIT 1];
        // JSON string for input parameters
        String jsonString = '{"loanApplicationId":"'+loanApp.Id+'", "applicantId":"'+applicant.Id+'", "screenName":"Purpose of Loan", "masterName":"TestMaster", "documentCategory":"TestCategory", "docMasterName":"TestDocMaster", "addressSource":"TestSource", "addressId":"TestAddressId"}';
        System.runas(userList[0]){
        AUSF_Utility.ScreenWrapper wrapperObj = AUSF_Utility.getCurrentScreenDataCatg(jsonString);
        System.assertEquals(1, wrapperObj.wizardDataAssistedList.size());
        System.assertEquals(1, wrapperObj.loanApplicationList.size());
        }
    }
    @isTest
    static void updateLoanApplicationtest() {
        string screenName = 'Purpose of Loan';
        string loanApplcationObj = '{ "Id":"'+ [SELECT Id FROM Loan_Application__c LIMIT 1].Id+'", "Loan_Amount__c": 1000, "Last_visited_Page__c":"'+screenName+'" }';
        string result = AUSF_Utility.updateLoanApplication(loanApplcationObj,[SELECT Id FROM Loan_Application__c LIMIT 1].Id,screenName);
        System.assertEquals('success', result);
    }
    @isTest
    static void updateLoanApplicationCatch() {
        string screenName = 'Purpose of Loan';
        string result = AUSF_Utility.updateLoanApplication('loanApplcationObj',[SELECT Id FROM Loan_Application__c LIMIT 1].Id,screenName);
    }
    @isTest
    static void updateApplicanttest() {
        string screenName = 'Purpose of Loan';
        string applicantObj = '{ "Id":"'+ [SELECT Id FROM Applicant__c LIMIT 1].Id+'", "Current_Pincode_Retry_Count__c": 1}';
        string result = AUSF_Utility.updateApplicant(applicantObj,[SELECT Id FROM Loan_Application__c LIMIT 1].Id,screenName);
        System.assertEquals('success', result);
    }
    @isTest
    static void updateApplicantcatch() {
        string screenName = 'Purpose of Loan';
        string result = AUSF_Utility.updateApplicant('applicantObj',[SELECT Id FROM Loan_Application__c LIMIT 1].Id,screenName);
    }
    
    @isTest 
    static void createAddressTest(){
        List<Applicant__c> ApplicantLst = [SELECT Id FROM Applicant__c LIMIT 1];
        string screenName = 'Confirm Personal Details';
        string pincode = '111111';
        Address__c addressObj = new Address__c();
        addressObj.Pincode__c = '111111';
        addressObj.Address_Type__c = 'Current';
        addressObj.Address_Line_1__c = 'TestAddrs1';
        addressObj.Address_Line_2__c = 'TestAddrs2';
        addressObj.Address_Line_3__c = 'TestAddrs3';
        addressObj.Applicant__c = ApplicantLst[0].Id;
        Map<String,Object> addrssMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(addressObj));
        addrssMap.remove('attributes');
        String addrsObj = JSON.serialize(addrssMap);
        string result = AUSF_Utility.createAddress(addrsObj,pincode,screenName);
    }
    
    @isTest 
    static void createEmploymentDetailsTest(){
        List<Applicant__c> ApplicantLst = [SELECT Id FROM Applicant__c LIMIT 1];
        string screenName = 'Confirm Personal Details';
        string recordTypeName = 'Others';
        Employment_Detail__c employmentDetObj = new Employment_Detail__c();
        employmentDetObj.Name = 'Business Proof-Others';
        employmentDetObj.Owner_Name_Vintage_Verified__c = false;
        employmentDetObj.Document_Number__c = 'TE347598';
        employmentDetObj.Active__c = true;
        employmentDetObj.Registered_Business_name__c = 'TE5694509';
        employmentDetObj.Applicant__c = ApplicantLst[0].Id;
        Map<String,Object> employmentMap = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(employmentDetObj));
        employmentMap.remove('attributes');
        String employmentObj = JSON.serialize(employmentMap);
        string result = AUSF_Utility.createEmploymentDetails(employmentObj,screenName,recordTypeName);
    }
    
    @isTest 
    static void createAddressCatchTest(){
        string screenName = 'Confirm Personal Details';
        string pincode = '111111';
        string addressObj;
        string result = AUSF_Utility.createAddress(addressObj,pincode,screenName);
    }
    
    @isTest 
    static void createLeadStageTest(){
        string screenName = 'Confirm Personal Details';
        Lead_Stage__c leadStageObj = new Lead_Stage__c();
        leadStageObj.Business_Proof_Consent_Date_Time__c = System.now();
        leadStageObj.Name = '1234560661';
        String leadObj = JSON.serialize(leadStageObj);
        string result = AUSF_Utility.createLeadStage(leadObj,screenName);
        List<Lead_Stage__c> leadStage = AUSF_Utility.getRelatedLeadStageById(result);
    }
    
    @isTest 
    static void createLeadStageCatchTest(){
        string screenName = 'Confirm Personal Details';
        string leadStageObj;
        string result = AUSF_Utility.createLeadStage(leadStageObj,screenName);
        List<Lead_Stage__c> leadStage = AUSF_Utility.getRelatedLeadStageById(result);
    }
    
    
    @isTest
    static void testGetApplicantAddressList(){
        Loan_Application__c loanApp = new Loan_Application__c();
        insert loanApp;
        Applicant__c applicant = new Applicant__c(Loan_Application__c = loanApp.id);
        insert applicant;
        string pincode = '111111';
        Address__c addressObj = new Address__c();
        addressObj.Pincode__c = '111111';
        addressObj.Address_Type__c = 'Current';
        addressObj.Address_Line_1__c = 'TestAddrs1';
        addressObj.Address_Line_2__c = 'TestAddrs2';
        addressObj.Address_Line_3__c = 'TestAddrs3';
        addressObj.Applicant__c = applicant.id;
        addressObj.Active__c = true;
        insert addressObj;
        List<Address__c> addressList = AUSF_Utility.getApplicantAddressList(applicant.id);
        ASSERT.areEqual(1, addressList.size());
        
        List<Address__c> addressListNegative = AUSF_Utility.getApplicantAddressList('jhsbv');
    }
    
    @isTest
    static void testgetGenericMasterRecordsByRecordTypeError() {
        string screenName = 'Test';
        string recordTypeName;
        List<Generic_Master__c> genericMasterList = AUSF_Utility.getGenericMasterRecordsByRecordTypes(screenName,recordTypeName, '');
        System.assertEquals(0, genericMasterList.size());
    }
    
    @isTest
    static void testgetGenericMasterRecordsByRecordTypeSuccess() {
        string screenName = 'TestScreen';
        List<Generic_Master__c> genMasterList = [SELECT Id,RecordType.Name FROM Generic_Master__c WHERE RecordType.Name = 'Electricity Bill Service Providers' LIMIT 1];
        List<Generic_Master__c> genMasterLst = [SELECT Id,RecordType.Name FROM Generic_Master__c WHERE RecordType.Name = 'Electricity Bill Service Providers to District Mapping' LIMIT 1];
        string recordTypeName = genMasterList[0].RecordType.Name ;
        string recordTypeName2 = genMasterLst[0].RecordType.Name ;
        string providerName = '';
        List<Generic_Master__c> genericMasterList = AUSF_Utility.getGenericMasterRecordsByRecordTypes(screenName,recordTypeName, '');
        System.assertEquals(1, genericMasterList.size());
        List<Generic_Master__c> genericMasterListResult = AUSF_Utility.getGenericMasterRecordsByRecordTypes(screenName,recordTypeName, recordTypeName2);
        System.assertEquals(1, genericMasterListResult.size());
    }
    @isTest
    static void testGetDocumentMaster() {
        // Create test data
        Document_Master__c testDocumentMaster = new Document_Master__c(
            Document_Name__c = 'Test Document',
            File_Size__c = 1024,
            Multiple_Upload__c = true,
            Supported_Doc_Types__c = 'pdf,docx',
            No_Of_Document_Upload__c = 5,
            File_Upload_Note__c = 'Test note',
            Active__c = true
        );
        insert testDocumentMaster;
        // Call the method
        Document_Master__c result = AUSF_Utility.getDocumentMaster('Test Document');
        // Assert the results
        System.assertNotEquals(null, result, 'The result should not be null');
        System.assertEquals('Test Document', result.Document_Name__c, 'The document name should match');
        System.assertEquals(1024, result.File_Size__c, 'The file size should match');
        System.assertEquals(true, result.Multiple_Upload__c, 'The multiple upload flag should match');
        System.assertEquals('pdf,docx', result.Supported_Doc_Types__c, 'The supported document types should match');
        System.assertEquals(5, result.No_Of_Document_Upload__c, 'The number of document uploads should match');
        System.assertEquals('Test note', result.File_Upload_Note__c, 'The file upload note should match');
    }
    @isTest
    static void testGetDocumentMaster_NoMatch() {
        // Call the method with a name that doesn't exist
        Document_Master__c result = AUSF_Utility.getDocumentMaster('Nonexistent Document');
        // Assert the results
        System.assertEquals(null, result, 'The result should be null for a nonexistent document');
    }
    
    @isTest
    static void testUploadFile() {
        // Create test data
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','ADS00'));
        String applicantId = [SELECT Id,Name,Full_Name__c,Birth_Date__c FROM Applicant__c][0].Id;
        Document_Checklist__c docChecklist = [SELECT Id FROM Document_Checklist__c LIMIT 1];
        String base64 = 'dGVzdCBmaWxlIGNvbnRlbnQ=';  
        String filename = 'testfile.txt';
        String recordId = docChecklist.Id;
        String loanId = 'a0Bxx0000008TmiEAE';
        String filetype = 'txt';
        String docMasterName = 'Test Document';
        Boolean isZipped = true;
        // Create JSON string
        Map<String, Object> fileUploadMap = new Map<String, Object>{
            'base64' => base64,
                'filename' => filename,
                'recordId' => recordId,
                'applicantId' => applicantId,
                'loanId' => loanId,
                'filetype' => filetype,
                'docMasterName' => docMasterName,
                'isZipped'=>isZipped
                };
        String jsonString = JSON.serialize(fileUploadMap);
        Test.startTest();
        // Call the method
        String contentVersionId = AUSF_Utility.uploadFile(jsonString);
        // Verify the results
        System.assertNotEquals(null, contentVersionId, 'ContentVersionId should not be null');
        ContentVersion cv = [SELECT Id, Title, PathOnClient FROM ContentVersion WHERE Id = :contentVersionId];
        System.assertEquals(filename, cv.Title, 'ContentVersion title should match the filename');
        System.assertEquals(filename, cv.PathOnClient, 'ContentVersion PathOnClient should match the filename');
        ContentDocumentLink cdl = [SELECT Id, LinkedEntityId, ShareType FROM ContentDocumentLink WHERE LinkedEntityId = :recordId Limit 1];
        System.assertEquals(recordId, cdl.LinkedEntityId, 'ContentDocumentLink LinkedEntityId should match the recordId');
        System.assertEquals('V', cdl.ShareType, 'ContentDocumentLink ShareType should be Viewer (V)');
        Test.stopTest();
    }
    @isTest
    static void testUploadFileWithError() {
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','ADS00'));
        // Create test data with invalid base64
        String base64 = 'invalidbase64';
        String filename = 'testfile.txt';
        String recordId = '001xx000003DGbPAAW'; 
        String applicantId = '003xx000004TmiFAAS'; 
        String loanId = 'a0Bxx0000008TmiEAE';
        String filetype = 'txt';
        String docMasterName = 'Test Document';
        // Create JSON string
        Map<String, Object> fileUploadMap = new Map<String, Object>{
            'base64' => base64,
                'filename' => filename,
                'recordId' => recordId,
                'applicantId' => applicantId,
                'loanId' => loanId,
                'filetype' => filetype,
                'docMasterName' => docMasterName
                };
                    String jsonString = JSON.serialize(fileUploadMap);
        Test.startTest();
        // Call the method
        String contentVersionId = AUSF_Utility.uploadFile(jsonString);
        // Verify the results
        System.assertEquals(null, contentVersionId, 'ContentVersionId should be null due to invalid base64');
        Test.stopTest();
    }

    @isTest
    static void testFetchOptionsWithIndustry() {
        Test.startTest();
        List<Map<String, String>> result = AUSF_Utility.fetchOptions('Industry', null);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals('Industry 1', result[0].get('name'));
    }

    @isTest
    static void testFetchOptionsWithSubIndustry() {
        Test.startTest();
        List<Map<String, String>> result = AUSF_Utility.fetchOptions('Sub_Industry', 'Industry 1');
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals('Sub Industry 1', result[0].get('name'));
    }

    @isTest
    static void testFetchOptionsWithActivity() {
        Test.startTest();
        List<Map<String, String>> result = AUSF_Utility.fetchOptions('Activity', 'Sub Industry 1');
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(1, result.size());
        System.assertEquals('Activity 1', result[0].get('name'));
    }

    @isTest
    static void testFetchOptionsWithNoRecords() {
        Test.startTest();
        List<Map<String, String>> result = AUSF_Utility.fetchOptions('NonExistentType', null);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
    }

    @isTest
    static void testExceptionHandling() {
        Test.startTest();
        // Trigger an exception by passing invalid parameters or manipulating the mock data accordingly
        List<Map<String, String>> result = AUSF_Utility.fetchOptions(null, null);
        Test.stopTest();
        
        // Ensure that the exception is handled and an empty list is returned
        System.assertNotEquals(null, result);
        System.assertEquals(0, result.size());
    }
    @isTest
    static void testGetGenericBuisnessMetadaData() {
        // Use an existing Screen_Name__c value from your org's metadata
        String existingScreenName = [SELECT Id,Screen_Name__c FROM AUSF_GenericBuisnessProofData__mdt Limit 1].Screen_Name__c; // Replace with an actual Screen_Name__c from your org

        // Test with a valid label name that matches existing metadata
        Test.startTest();
        List<AUSF_GenericBuisnessProofData__mdt> result = AUSF_Utility.getGenericBuisnessMetadaData(existingScreenName);
        Test.stopTest();

        // Validate the results
        System.assert(result.size() > 0, 'Result size should be greater than 0 for a valid label');
    }
    @IsTest
    static void testGetEmploymentDetail() {
        // Step 1: Set up test data
        List<Loan_Application__c> loanApplications = [SELECT Id FROM Loan_Application__c Where Stage__c='Pending' Limit 2]; 
        List<Applicant__c> applicants = AUSF_TestDataFactory.createApplicantRecords(loanApplications,2);
        Applicant__c applicant = applicants[1];
		RecordType employmentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Employment_Detail__c' AND DeveloperName = 'ICSI' LIMIT 1];
        Employment_Detail__c empDetail = new Employment_Detail__c(
            Applicant__c = applicant.Id,
            Name = 'TestRecordName',
            Document_Number__c = '123456',
            Others_Business_Proof_Name__c = 'Business Proof',
            Date_of_Incorporation__c = Date.today(),
            Registered_Business_name__c = 'Test Business',
            Sector__c = 'Finance',
            Industry__c = 'Banking',
            Sub_Industry__c = 'Commercial Banking',
            Activity__c = 'Lending',
            Active__c = true,
			RecordTypeId = employmentRecordType.Id
        );
        insert empDetail;

        // Step 2: Call the method with valid applicantId and recordName
        Test.startTest();
        List<Employment_Detail__c> result = AUSF_Utility.getEmploymentDetail(applicant.Id, 'ICSI');
        Test.stopTest();

        // Step 3: Verify the results
        System.assertEquals(1, result.size(), 'Result size should be 1');
        System.assertEquals('123456', result[0].Document_Number__c, 'Document Number should match');
        System.assertEquals('Test Business', result[0].Registered_Business_name__c, 'Registered Business Name should match');
        System.assertEquals('Finance', result[0].Sector__c, 'Sector should match');
    }
    
    @IsTest
    static void testVerifyEmploymentDetails() {
        // Step 1: Create test data

        List<Loan_Application__c> loanApplications = [SELECT Id FROM Loan_Application__c Where Stage__c='Pending' Limit 2];
        AUSF_TestDataFactory.createApplicantRecordsWithSENP(loanApplications,1);
        Applicant__c applicantSENP = [SELECT id FROM Applicant__c WHERE Employment_Type__c = 'Self Employed Non-Professional'];
        
        List<Employment_Detail__c> emplDetailrecs = AUSF_TestDataFactory.createEmploymentDetail(applicantSENP.Id,1);
		RecordType employmentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Employment_Detail__c' AND DeveloperName = 'ICSI' LIMIT 1];
       	emplDetailrecs[0].RecordTypeId = employmentRecordType.Id;
        
        insert emplDetailrecs;

        // Create an Integration_Checklist__c record with Status__c as 'Completed'
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster('ICAI API','','','','','');
        insert integrationMaster;
        
        Integration_Checklist__c integrationChecklist = new Integration_Checklist__c(
            Applicant__c = applicantSENP.Id,
            Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED,
            Integration_Master__c = integrationMaster.Id
        );
        insert integrationChecklist;

        // Step 2: Test the method
        Test.startTest();
        AUSF_Utility.EmploymentVerificationWrapper result = AUSF_Utility.verifyEmploymentDetails(applicantSENP.Id);
        Test.stopTest();

        // Step 3: Verify the results
        System.assertNotEquals(null, result);
        System.assertEquals(applicantSENP.Id, result.applicantId);
        System.assertEquals(emplDetailrecs[0].Id, result.employmentDetailId);
        System.assertEquals(emplDetailrecs[0].Address__c, result.addressId);
        System.assert(result.isInstant); // Based on the custom metadata
    }
    
    @IsTest
    static void testInvokeMethodForScreenForManualUpload() {
        // Step 1: Create test data

        List<Loan_Application__c> loanApplications = [SELECT Id FROM Loan_Application__c Where Stage__c='Pending' Limit 2];
        AUSF_TestDataFactory.createApplicantRecordsWithSENP(loanApplications,1);
        Applicant__c applicantSENP = [SELECT id FROM Applicant__c WHERE Employment_Type__c = 'Self Employed Non-Professional'];
        
        List<Employment_Detail__c> emplDetailrecs = AUSF_TestDataFactory.createEmploymentDetail(applicantSENP.Id,1);
		RecordType employmentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Employment_Detail__c' AND DeveloperName = 'ICAI' LIMIT 1];
       	emplDetailrecs[0].RecordTypeId = employmentRecordType.Id;
        emplDetailrecs[0].Document_Number__c = '12345';
        
        insert emplDetailrecs;


        // Create an Integration_Checklist__c record with Status__c as 'Completed'
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster('ICAI API','','','','','');
        insert integrationMaster;
        
        Integration_Checklist__c integrationChecklist = new Integration_Checklist__c(
            Applicant__c = applicantSENP.Id,
            Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED,
            Integration_Master__c = integrationMaster.Id
        );
        insert integrationChecklist;

        // Create a JSON string for input
        String jsonString = JSON.serialize(new Map<String, Object>{
            'employmentId' => emplDetailrecs[0].Id,
            'MembershipNo' => '12345',
            'applicantId' => applicantSENP.Id
        });

        // Step 2: Test the method
        Test.startTest();
        AUSF_Utility.EmploymentVerificationWrapper result = AUSF_Utility.invokeMethodForScreen('ICAI Certificate Failure', jsonString);
        Test.stopTest();

        // Step 3: Verify the results
        System.assertNotEquals(null, result);
        System.assertEquals(applicantSENP.Id, result.applicantId);
        System.assertEquals(emplDetailrecs[0].Id, result.employmentDetailId);
        System.assertEquals(emplDetailrecs[0].Address__c, result.addressId);
        System.assert(result.isInstant); // Based on Type_Verification__c value
    }
    @IsTest
    static void testInvokeMethodForScreenForAPIWithintegration() {
        // Step 1: Create test data

        List<Loan_Application__c> loanApplications = [SELECT Id FROM Loan_Application__c Where Stage__c='Pending' Limit 2];
        AUSF_TestDataFactory.createApplicantRecordsWithSENP(loanApplications,1);
        Applicant__c applicantSENP = [SELECT id FROM Applicant__c WHERE Employment_Type__c = 'Self Employed Non-Professional'];
        
        List<Employment_Detail__c> emplDetailrecs = AUSF_TestDataFactory.createEmploymentDetail(applicantSENP.Id,1);
		RecordType employmentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Employment_Detail__c' AND DeveloperName = 'ICAI' LIMIT 1];
       	emplDetailrecs[0].RecordTypeId = employmentRecordType.Id;
        emplDetailrecs[0].Document_Number__c = '12345';
        emplDetailrecs[0].Type_Verification__c = 'API';
        
        insert emplDetailrecs;


        // Create an Integration_Checklist__c record with Status__c as 'Completed'
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster('ICAI API','','','','','');
        insert integrationMaster;
        
        Integration_Checklist__c integrationChecklist = new Integration_Checklist__c(
            Applicant__c = applicantSENP.Id,
            Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED,
            Integration_Master__c = integrationMaster.Id
        );
        insert integrationChecklist;

        // Create a JSON string for input
        String jsonString = JSON.serialize(new Map<String, Object>{
            'employmentId' => emplDetailrecs[0].Id,
            'MembershipNo' => '12345',
            'applicantId' => applicantSENP.Id
        });

        // Step 2: Test the method
        Test.startTest();
        AUSF_Utility.EmploymentVerificationWrapper result = AUSF_Utility.invokeMethodForScreen('ICAI Certificate Failure', jsonString);
        Test.stopTest();

        // Step 3: Verify the results
        System.assertNotEquals(null, result);
        System.assertEquals(applicantSENP.Id, result.applicantId);
        System.assertEquals(emplDetailrecs[0].Id, result.employmentDetailId);
        System.assertEquals(emplDetailrecs[0].Address__c, result.addressId);
        System.assert(result.isInstant); // Based on Type_Verification__c value
    }
    @IsTest
    static void testInvokeMethodForScreenForICAIAPI() {
        // Step 1: Create test data

        List<Loan_Application__c> loanApplications = [SELECT Id FROM Loan_Application__c Where Stage__c='Pending' Limit 2];
        AUSF_TestDataFactory.createApplicantRecordsWithSENP(loanApplications,1);
        Applicant__c applicantSENP = [SELECT id FROM Applicant__c WHERE Employment_Type__c = 'Self Employed Non-Professional'];
        
        List<Employment_Detail__c> emplDetailrecs = AUSF_TestDataFactory.createEmploymentDetail(applicantSENP.Id,1);
		RecordType employmentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Employment_Detail__c' AND DeveloperName = 'ICAI' LIMIT 1];
       	emplDetailrecs[0].RecordTypeId = employmentRecordType.Id;
        emplDetailrecs[0].Document_Number__c = '12345';
        emplDetailrecs[0].Type_Verification__c = 'API';
        
        insert emplDetailrecs;
        
         // Create an Integration_Checklist__c record with Status__c as 'Completed'
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster('ICAI API','','','','','');
        insert integrationMaster;

        // Create a JSON string for input
        String jsonString = JSON.serialize(new Map<String, Object>{
            'employmentId' => emplDetailrecs[0].Id,
            'MembershipNo' => '12345',
            'applicantId' => applicantSENP.Id
        });
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));

        // Step 2: Test the method
        Test.startTest();
        AUSF_Utility.EmploymentVerificationWrapper result = AUSF_Utility.invokeMethodForScreen('ICAI Certificate Failure', jsonString);
        Test.stopTest();

        // Step 3: Verify the results
        System.assertNotEquals(null, result);
        System.assertEquals(applicantSENP.Id, result.applicantId);
        System.assert(result.isInstant); // Based on Type_Verification__c value
    }
    
    @IsTest
    static void testInvokeMethodForScreenForICSIAPI() {
        // Step 1: Create test data

        List<Loan_Application__c> loanApplications = [SELECT Id FROM Loan_Application__c Where Stage__c='Pending' Limit 2];
        AUSF_TestDataFactory.createApplicantRecordsWithSENP(loanApplications,1);
        Applicant__c applicantSENP = [SELECT id FROM Applicant__c WHERE Employment_Type__c = 'Self Employed Non-Professional'];
        
        List<Employment_Detail__c> emplDetailrecs = AUSF_TestDataFactory.createEmploymentDetail(applicantSENP.Id,1);
		RecordType employmentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Employment_Detail__c' AND DeveloperName = 'ICSI' LIMIT 1];
       	emplDetailrecs[0].RecordTypeId = employmentRecordType.Id;
        emplDetailrecs[0].Document_Number__c = '12345';
        emplDetailrecs[0].Type_Verification__c = 'API';
        
        insert emplDetailrecs;
        
         // Create an Integration_Checklist__c record with Status__c as 'Completed'
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster('ICSI API','','','','','');
        insert integrationMaster;

        // Create a JSON string for input
        String jsonString = JSON.serialize(new Map<String, Object>{
            'employmentId' => emplDetailrecs[0].Id,
            'MembershipNo' => '12345',
            'applicantId' => applicantSENP.Id
        });
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));

        // Step 2: Test the method
        Test.startTest();
        AUSF_Utility.EmploymentVerificationWrapper result = AUSF_Utility.invokeMethodForScreen('ICSI Certificate Failure', jsonString);
        Test.stopTest();

        // Step 3: Verify the results
        System.assertNotEquals(null, result);
        System.assertEquals(applicantSENP.Id, result.applicantId);
        System.assert(result.isInstant); // Based on Type_Verification__c value
    }
    
    @IsTest
    static void testInvokeMethodForScreenForImportExport() {
        // Step 1: Create test data

        List<Loan_Application__c> loanApplications = [SELECT Id FROM Loan_Application__c Where Stage__c='Pending' Limit 2];
        AUSF_TestDataFactory.createApplicantRecordsWithSENP(loanApplications,1);
        Applicant__c applicantSENP = [SELECT id FROM Applicant__c WHERE Employment_Type__c = 'Self Employed Non-Professional'];
        
        List<Employment_Detail__c> emplDetailrecs = AUSF_TestDataFactory.createEmploymentDetail(applicantSENP.Id,1);
		RecordType employmentRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Employment_Detail__c' AND DeveloperName = 'IEC' LIMIT 1];
       	emplDetailrecs[0].RecordTypeId = employmentRecordType.Id;
        emplDetailrecs[0].Document_Number__c = '12345';
        emplDetailrecs[0].Type_Verification__c = 'API';
        
        insert emplDetailrecs;
        
         // Create an Integration_Checklist__c record with Status__c as 'Completed'
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster('Import Export Certification','','','','','');
        insert integrationMaster;

        // Create a JSON string for input
        String jsonString = JSON.serialize(new Map<String, Object>{
            'employmentId' => emplDetailrecs[0].Id,
            'MembershipNo' => '12345',
            'applicantId' => applicantSENP.Id
        });
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','101'));

        // Step 2: Test the method
        Test.startTest();
        AUSF_Utility.EmploymentVerificationWrapper result = AUSF_Utility.invokeMethodForScreen('Import Export Certificate Failure', jsonString);
        Test.stopTest();

        // Step 3: Verify the results
        System.assertNotEquals(null, result);
        System.assertEquals(applicantSENP.Id, result.applicantId);
        System.assert(result.isInstant); // Based on Type_Verification__c value
    }
    
    
}