/**
 * @author              : Naga chandra
 * @date                : 25/june/2024
 * @description         : Test data factory
 * History              :
 * ===========================================================================================================
 * <Date>           <Authors Name>          <Brief Description of Change>
 * ===========================================================================================================
 * 27-June-2024     Naga chandra            Initial version
 * 05-July-2024     Amit Mishra             Created createIntegrationMaster method
 * 20/07/2024       Pradeep Sharma          Created createContentVersion,createContentDocumentLink,createDocumentChecklist,createDocumentCheckList,createContentDocumentLink method
 * 22-July-2024     Asmita Mathur           created createGenericMasterRecords method
**/
@isTest
public with sharing class AUSF_TestDataFactory {
    public static List<Loan_Application__c> createActiveLoanApplications(List<Loan_Application__c> loanApps,Integer numofLoanRecord) {
        for(Integer i=0;i<numofLoanRecord;i++){
            Loan_Application__c loanApp = new Loan_Application__c();
            loanApp.Mobile_Number__c = '1234567890';
            loanApp.Stage__c = 'Pending';
            loanApp.Exempt_Duplicate__c = false;
            loanApps.add(loanApp);
        }
        
        return loanApps;
    }
    public static List<Loan_Application__c> createCancelledLoanApplications(List<Loan_Application__c> loanApps,Integer numofLoanRecord) {
        for(Integer i=0;i<numofLoanRecord;i++){
            Loan_Application__c loanApp = new Loan_Application__c();
            loanApp.Mobile_Number__c = '1234567890';
            loanApp.Stage__c = 'Cancelled';
            loanApp.Exempt_Duplicate__c = false;
            loanApps.add(loanApp);
        }
        
        return loanApps;
    }
    public static List<Loan_Application__c> createRejectLoanApplications(List<Loan_Application__c> loanApps,Integer numofLoanRecord) {
        for(Integer i=0;i<numofLoanRecord;i++){
            Loan_Application__c loanApp = new Loan_Application__c();
            loanApp.Mobile_Number__c = '1234567890';
            loanApp.Stage__c = 'Reject';
            loanApp.Exempt_Duplicate__c = false;
            loanApps.add(loanApp);
        }
        
        return loanApps;
    }
    public static List<Loan_Application__c> createDisbursedLoanApplications(List<Loan_Application__c> loanApps,Integer numofLoanRecord) {
        for(Integer i=0;i<numofLoanRecord;i++){
            Loan_Application__c loanApp = new Loan_Application__c();
            loanApp.Mobile_Number__c = '1234567890';
            loanApp.Stage__c = 'Disbursed';
            loanApp.Exempt_Duplicate__c = false;
            loanApps.add(loanApp);
        }
        
        return loanApps;
    }

    public static List<Loan_Application__c> createActiveLeadLoanApplications(List<Loan_Application__c> loanApps,Integer numofLoanRecord) {
        List<Account> accounts = createAccountRecord();
        for(Integer i=0;i<numofLoanRecord;i++){
            Loan_Application__c loanApp = new Loan_Application__c();
            loanApp.Mobile_Number__c = '1234567890';
            loanApp.Stage__c = 'Operations';
            loanApp.Exempt_Duplicate__c = false;
            loanApp.Branch__c = accounts[0].id;
            loanApps.add(loanApp);
        }
        
        return loanApps;
    }

    public static List<Account> createAccountRecord(){
        List<Account> accounts = new List<Account>();
        Account branch = new Account(Name = 'Test Branch');
        branch.Pincode__c = createLocationMaster()[0].Id;
        accounts.add(branch);
        insert accounts;
        return accounts;
    }

    public static List<Location_Master__c> createLocationMaster(){
        List<Location_Master__c> locationMasters = new List<Location_Master__c>();
        Location_Master__c loanMaster = new Location_Master__c();
        loanMaster.City__c = 'JAIPUR';
        loanMaster.Zip_Code__c = '326033';
        loanMaster.State__c = 'Rajasthan';
        loanMaster.Name = 'JAIPUR';
        locationMasters.add(loanMaster);
        insert locationMasters;
        return locationMasters;
    }
    
    /*
    @description   - createLocationMaster - initialize LocationMaster record
    @param1        - strZip - Zipcode / Pincode
    @param2        - strCity - City
    @param3        - strState - State
    @return        - Location_Master__c
    */
    public static Location_Master__c createLocationMaster(String strZip, String strCity, String strState){
        Location_Master__c loanMaster = new Location_Master__c();
        loanMaster.City__c = strCity;
        loanMaster.Zip_Code__c = strZip;
        loanMaster.State__c = strState;
        loanMaster.Name = strZip;
        return loanMaster;
    }

    public static List<Applicant__c> createApplicantRecords(List<Loan_Application__c> loanApplications, Integer numofRecord){
        List<Applicant__c> applicants = new List<Applicant__c>();
        for(Integer i=0;i<numofRecord;i++){
            Applicant__c applicant = new Applicant__c();
            if(loanApplications.size()<=numofRecord){
                applicant.Loan_Application__c = loanApplications[i].Id;
            }
            else{
                break;
            }
            applicants.add(applicant);
        }
        insert applicants;
        return applicants;
    }
    public static List<Applicant__c> createApplicantRecordsWithSEP(List<Loan_Application__c> loanApplications, Integer numofRecord){
        List<Applicant__c> applicants = new List<Applicant__c>();
        for(Integer i=0;i<numofRecord;i++){
            Applicant__c applicant = new Applicant__c();
                applicant.Loan_Application__c = loanApplications[i].Id;
                applicant.Employment_Type__c = 'Self Employed Professional';
                applicants.add(applicant);
        }
        insert applicants;
        return applicants;
    }
    public static List<Applicant__c> createApplicantRecordsWithSENP(List<Loan_Application__c> loanApplications, Integer numofRecord){
        List<Applicant__c> applicants = new List<Applicant__c>();
        for(Integer i=0;i<numofRecord;i++){
            Applicant__c applicant = new Applicant__c();
                applicant.Loan_Application__c = loanApplications[i].Id;
                applicant.Employment_Type__c = 'Self Employed Non-Professional';
            applicants.add(applicant);
        }
        insert applicants;
        return applicants;
    }
    public static List<Lead_Stage__c> createLeadStagerecords(List<Lead_Stage__c> leadStages,Integer numofLoanRecord) {
        for(Integer i=0;i<numofLoanRecord;i++){
            Lead_Stage__c leadStage = new Lead_Stage__c();
            leadStage.Name = '1234567890';
            leadStage.Sourcing_Channel__c  = 'DSA';
            leadStage.Sourcing_Channel_Name__c  = UserInfo.getName();
            leadStages.add(leadStage);
        }
        
        return leadStages;
    }
    public static Integration_Master__c createIntegrationMaster(String name, String endPoint, String Channel, String httpMethod, String contentType, String handlerClass){
        Integration_Master__c integrationMaster = new Integration_Master__c (
            Name = String.isNotBlank(name)?name:'',
            End_Point_URL__c = String.isNotBlank(endPoint)?endPoint:'https://api.aubankuat.in/sfdckyc/PANValidationServiceV2/test',
            Channel__c = String.isNotBlank(Channel)?Channel:'SFDC',
            HTTP_Method__c = String.isNotBlank(httpMethod)?httpMethod:'POST',
            Timeout__c =  120000,
            content_type__c = String.isNotBlank(contentType)?contentType:'application/json',
            Apex_Class_Name__c = String.isNotBlank(handlerClass)?handlerClass:'',
            Active__c = true
        );
        return integrationMaster;
    }

    public static List<Address__c> createAddress(Applicant__c applicant, Integer numOfRec , Boolean doInsert){
        List<Address__c> addressList = new List<Address__c>();
        for(Integer i = 0; i < numOfRec; i++){
            Address__c address = new Address__c(
            Applicant__c = applicant.Id,
            Address_Line_1__c ='test 5th flor',
            Address_Line_2__c= 'Kanakia Zillon test',
            Address_Line_3__c = 'BKC Kurla West test', 
            City__c = 'MUMBAI',
            State__c = 'MAHARASHTRA',
            Pincode__c = '400070',
            Is_Aadhaar_Address__c = false,
            Address_Type__c = AUSF_ApexConstants.CURRENT_ADDRESS_TYPE,//Current
            Type__c = 'Residence Ownership',
            Is_Communication_Address__c = true,
            Address_Source__c = 'Aadhaar',
            Residence_Type__c = 'Owned',
            Working_Area__c = 'Yes',
            Residence_Ownership_Type__c = 'Owned'
            );
            addressList.add(address);
        }
        if(doInsert){
            insert addressList;
        }
        return addressList;
    }
    
    /* New User */
    public static User createUsersWithParams (User objUser, String strFirstName, String strLastName, String strEmpNumber, String strEmail, String strUserName, Id idProfile, String strAlias) {
        objUser = objUser == NULL ? new User () : objUser;
        objUser.FirstName = String.isBlank(strFirstName) ? 'TestFirstName' : strFirstName;
        objUser.LastName = String.isBlank(strLastName) ? 'TestLastName' : strLastName;
        objUser.EmployeeNumber = String.isBlank(strEmpNumber) ? '12345' : strEmpNumber;
        objUser.Email = String.isBlank(strEmail) ? 'testuser@salesforce.com' : strEmail;
        objUser.UserName = String.isBlank(strUserName) ? objUser.Email+'.aupl' : strUserName;
        objUser.TimeZoneSidKey = 'America/Los_Angeles';
        objUser.EmailEncodingKey = 'UTF-8';
        objUser.LanguageLocaleKey = 'en_US';
        objUser.LocaleSidKey = 'en_US';
        objUser.ProfileId = idProfile;
        objUser.IsActive = true;
        objUser.Alias = String.isBlank(strAlias) ? 'tuser' : strAlias;
        return objUser;
    }
    
    /* New User */
    public static User createUsers (User objUser) {
        return createUsersWithParams (objUser, '','','','','',NULL,'');
    }
    public static ContentVersion createContentVersion (String Title,String PathOnClient,Blob VersionData,Boolean IsMajorVersion) {
        ContentVersion contentVersion = new ContentVersion(
            Title = Title,
            PathOnClient = PathOnClient,
            VersionData = VersionData,
            IsMajorVersion = IsMajorVersion
        );
        insert contentVersion;
        return contentVersion;
    }
    public static ContentDocumentLink createContentDocumentLink (String LinkedEntityId,String ContentDocumentId) {
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = LinkedEntityId;
        cdl.ContentDocumentId = ContentDocumentId;
        cdl.shareType = 'V';
        insert cdl;
        return cdl;
    }
    public static Document_Master__c createDocumentMaster(String name){
        Document_Master__c docMaster = new Document_Master__c(Name=name,Active__c = true);
        insert docMaster;
        return docMaster;
    }
    public static Document_Checklist__c createDocumentCheckList(String applicantId,String masterId){
        Document_Checklist__c docCheck = new Document_Checklist__c(Applicant__c = applicantId,Document_Master__c= masterId,Active__c = true);
        insert docCheck;
        return docCheck;
    }
    
    public static List<Generic_Master__c> createGenericMasterRecords(String recordTypeName,Integer numOfRec){
       List<Generic_Master__c> genMasterList = new List<Generic_Master__c>();
       Id recordTypeId = Schema.SObjectType.Generic_Master__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId(); 
       for(Integer i = 0; i < numOfRec; i++){
           Generic_Master__c genMaster = new Generic_Master__c(
            Service_Provider_Name__c = 'Test Service Provider Company',
            Service_Provider_Code__c = 'TECODE',
            Has_district_mapping__c = True,
            District__c = 'TestDistrict',
            RecordTypeId = recordTypeId
            );
            genMasterList.add(genMaster);
        }
        insert genMasterList;
        return genMasterList;
    }
    
    public static List<Applicant__c> createApplicantRecordsCFR(List<Loan_Application__c> loanApplications, Integer numofRecord){
        List<Applicant__c> applicants = new List<Applicant__c>();
        for(Integer i=0;i<numofRecord;i++){
            Applicant__c applicant = new Applicant__c();
            if(loanApplications.size()<=numofRecord){
                applicant.Loan_Application__c = loanApplications[i].Id;
                applicant.PAN__c = 'TestFraud';
            }
            else{
                break;
            }
            applicants.add(applicant);
        }
        insert applicants;
        return applicants;
    }

    /*
    @description: Create CFR Master record
    @param1     : strPanNumber PAN Number
    @return     : CFR_Master__c initiated record
    */
    public static CFR_Master__c createCFRMasterRecord(String strPanNumber){
        CFR_Master__c cfrMaster = new CFR_Master__c();
        cfrMaster.PAN__C = strPanNumber;
        return cfrMaster;
    }
    
    public static void createPLPAOffer(Id loanApplicationId,Integer numOfRecord){
        List<Pre_Approved_Offer__c> paOfferRecs = new List<Pre_Approved_Offer__c>();
        for(Integer i=0;i<numofRecord;i++){
            Pre_Approved_Offer__c paOffer = new Pre_Approved_Offer__c();
            paOffer.Loan_Application__c = loanApplicationId;
            paOffer.Product_Type__c = 'PL';
            paOffer.OfferIsActive__c = true;
            paOfferRecs.add(paOffer);
        }
        insert paOfferRecs;
        
    }
    
    public static void createBLPAOffer(Id loanApplicationId,Integer numOfRecord){
        List<Pre_Approved_Offer__c> paOfferRecs = new List<Pre_Approved_Offer__c>();
        for(Integer i=0;i<numofRecord;i++){
            Pre_Approved_Offer__c paOffer = new Pre_Approved_Offer__c();
            paOffer.Loan_Application__c = loanApplicationId;
            paOffer.Product_Type__c = 'BL';
            paOffer.OfferIsActive__c = true;
            paOfferRecs.add(paOffer);
        }
        insert paOfferRecs;
        
    }

    public static List<Employment_Detail__c> createEmploymentDetail(Id applicantId,Integer numOfRecord){
         List<Employment_Detail__c> employmentDetailList = new List<Employment_Detail__c>();
         for(Integer i=0;i<numofRecord;i++){
            Employment_Detail__c employmentDetailObj = new Employment_Detail__c();
            employmentDetailObj.Applicant__c = applicantId;  
            employmentDetailList.add(employmentDetailObj); 
         }
         return employmentDetailList;
    }

}