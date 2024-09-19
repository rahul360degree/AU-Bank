/**
* @author Asmita Mathur
* @company Salesforce.com
* @description A utility class for the custom metadata and Generic_Master__c object
* Test Class: AUSF_Utility_Test
* History:
*
*************************************************************************************
MODIFICATION LOG
* Version     Date                Developer            Description
*-------------------------------------------------------------------------------------------
*  1.0    20th June 2024          Asmita Mathur        Initial Creation and added method for getting Generic Master custom object records
*  2.0    23th June 2024          Nitesh Jaiswal       Add methods for getting configurable text and screen data from defined metadata
*  3.0    2nd  July 2024          Asmita Mathur        Add methods for creating Address custom object records
*  4.0    11th July 2024          Ruturaj Chothe       Added method to retrieve address list from Applicant
*  5.0    9th  Aug  2024          Charchit Niryanwal   Added method to retrieve the Active Employment Detail Record Based On Record Type 
*/

public without sharing class AUSF_Utility {

    @AuraEnabled(cacheable=true)
    public static List<Generic_Master__c> getGenericMasterRecords(String screenName, String name) {
        
        return [SELECT Id, Custom_String__c,Custom_String_for_DIY__c, Custom_String_Long__c
                FROM Generic_Master__c 
                WHERE Screen_Name__c =:screenName
                AND Name =:name
                LIMIT 1];            
                
    }

    @AuraEnabled(cacheable=true)
    public static ScreenWrapper getSalesDashboardDetails(String screenName, String name) {
        ScreenWrapper objWrap = new ScreenWrapper();
        objWrap.lstGenericMaster = getGenericMasterRecords (screenName, name);
        objWrap.objUser = getCurrentUserDetails()[0];
        return objWrap;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Generic_Master__c> getGenericMasterRecordsByRecordTypes(String screenName,String recordTypeName, String recordTypeName2) {
        try{
            List<Generic_Master__c> genericMasterList = new List<Generic_Master__c>();
            Map<String,Generic_Master__c> mapOfProvider   = new map<String,Generic_Master__c>();
            List<String> providerCodeList = new List<String>();
            List<Generic_Master__c> resultList = new List<Generic_Master__c>();

            genericMasterList = [SELECT Id, recordtype.name, Service_Provider_Name__c, District__c,
                                Service_Provider_Code__c, State__c , Has_district_mapping__c
                                FROM Generic_Master__c 
                                WHERE recordtype.name =:recordTypeName
                                ORDER By Service_Provider_Name__c
                                ];
            if(String.isBlank(recordTypeName2)){
                return genericMasterList;
            }
            else{
                for(Generic_Master__c genMasterItem : genericMasterList) {
                    if(genMasterItem.Has_district_mapping__c){
                        providerCodeList.add(genMasterItem.Service_Provider_Code__c);
                        mapOfProvider.put(genMasterItem.Service_Provider_Code__c, genMasterItem);
                    }
                    else{
                        resultList.add(genMasterItem);
                    }
                }
                genericMasterList = [SELECT Id, recordtype.name, Service_Provider_Name__c,
                                    Service_Provider_Code__c, State__c , Has_district_mapping__c, District__c
                                    FROM Generic_Master__c 
                                    WHERE recordtype.name =:recordTypeName2
                                    AND Service_Provider_Code__c IN :providerCodeList
                                    ORDER By Service_Provider_Name__c
                                    ];
                String prevCode = '';
                String district = '';
                Generic_Master__c genMasterItemOld;
                for(Generic_Master__c genMasterItem : genericMasterList) {
                    if(prevCode != '' && genMasterItem.Service_Provider_Code__c != prevCode){
                        genMasterItemOld = mapOfProvider.get(prevCode);
                        genMasterItemOld.District__c = district;
                        resultList.add(genMasterItemOld); 
                        district = '';
                    }
                    district += genMasterItem.District__c + ', '; 
                    prevCode = genMasterItem.Service_Provider_Code__c;
                }
                genMasterItemOld = mapOfProvider.get(prevCode);
                genMasterItemOld.District__c = district;
                resultList.add(genMasterItemOld); 
                return resultList;
            }

        }catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,'',null,screenName);
            return null;
        }           
    }

    @AuraEnabled
    public static List<Loan_Application__c> getLoanApplicationDetails(String loanApplicationId) {
        try {  
            return [SELECT Id,Name,Loan_Amount__c,IPA_Offer_Amount__c,Purpose_of_Loan_Others__c,Purpose_of_Loan__c,Last_visited_Page__c,Initiation_Referral_code__c,Initiation_Referral_code__r.FederationIdentifier,Stage__c, (SELECT Product_Type__c FROM Pre_Approved_Offers__r ORDER BY CreatedDate DESC LIMIT 1) FROM Loan_Application__c WHERE Id =:loanApplicationId LIMIT 1];   
                
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,loanApplicationId,null,'');
            return null;
        }     
    }



    @AuraEnabled
    public static ScreenWrapper getCurrentScreenData(String loanApplicationId, String applicantId, String screenName,string masterName){
        
        ScreenWrapper screenWrapperObj = new ScreenWrapper();
        try {
            if(String.isNotBlank(loanApplicationId)){
                List<Loan_Application__c> loanApplicationList = getLoanApplicationDetails(loanApplicationId);
                screenWrapperObj.loanApplicationList = loanApplicationList;
            }
            if(String.isNotBlank(applicantId)){
                List<Applicant__c> applicantList = [SELECT Id,Full_Name__c,Birth_Date__c,Personal_email_ID__c,Is_Personal_Email_Id_Verified__c,Gender__c,Current_Pincode__c,Current_Pincode_Retry_Count__c,Loan_Application__r.Stage__c,Loan_Application__r.Reject_Sub_Reason__c,Loan_Application__r.Last_visited_Page__c, CFR_Check__c, AML_verified__c, Hunter_Status__c,PAN__c,Employment_Type__c,(SELECT Id,Document_Name__c,Document_Number__c, Service_Provider__c, District__c,Active__c,Owned_Address_Proof_Type__c FROM Document_Checklists__r WHERE Document_Master__r.Document_Category__c = 'Residence ownership proof' LIMIT 100) FROM Applicant__c WHERE Id =:applicantId LIMIT 1];
                screenWrapperObj.applicantList = applicantList;

                screenWrapperObj.dedupeAddressList = getCustomerDedupeAddress(applicantId);
            }
            if(String.isNotBlank(screenName)){
                List<AUSF_Screen_Custom_Text__mdt> screenCustomTextList = AUSF_Utility.getScreenCustomTextRecords(screenName);
                screenWrapperObj.screenCustomTextList = screenCustomTextList;
    
                Id userProfileId = UserInfo.getProfileId();
    
                String profileName = [SELECT Id,Name FROM Profile WHERE Id =: userProfileId LIMIT 1].Name;

                screenWrapperObj.profileName = profileName;
        
                List<Profile_to_UI_Wizard_Mapping__mdt> profileToWizardMetadataList = [SELECT Profile_Name__c,Wizard_Metadata_Name__c,Label FROM Profile_to_UI_Wizard_Mapping__mdt WHERE Profile_Name__c=:profileName LIMIT 1];
        
                if(profileToWizardMetadataList.size()>0){
                    string metadataToBeUsed = profileToWizardMetadataList[0].Wizard_Metadata_Name__c;
                    if(metadataToBeUsed == 'Generic_UI_Wizard_Mapping_DIY__mdt'){
                        List<Generic_UI_Wizard_Mapping_DIY__mdt> wizardUIMapping = [SELECT Category__c,Current_Screen_Name__c,Is_Default__c,Order__c,Progress_in_Current_Step__c,Overall_Step__c,Current_Screen_Component__c,Label FROM Generic_UI_Wizard_Mapping_DIY__mdt WHERE Current_Screen_Name__c=:screenName LIMIT 1];
                        screenWrapperObj.wizardDataDIYList = wizardUIMapping;
                    }else if(metadataToBeUsed == 'Generic_UI_Wizard_Mapping_Assisted__mdt'){
                        List<Generic_UI_Wizard_Mapping_Assisted__mdt> wizardUIMapping = [SELECT Category__c,Current_Screen_Name__c,Is_Default__c,Order__c,Progress_in_Current_Step__c,Overall_Step__c,Current_Screen_Component__c,Label FROM Generic_UI_Wizard_Mapping_Assisted__mdt WHERE Current_Screen_Name__c=:screenName LIMIT 1];
                        screenWrapperObj.wizardDataAssistedList = wizardUIMapping;
                        // Progress_in_Overall_Step__c
                    }
                }
            }

            if(String.isNotBlank(masterName)){
                List<Integration_Master__c> masterList = [SELECT Id,Max_number_of_retries_allowed__c,Max_number_of_functional_retries__c FROM Integration_Master__c WHERE Name=:masterName LIMIT 1];
                if(masterList.size() > 0){
                    screenWrapperObj.masterDetails = masterList;
                }
            }

            Map<String,String> labelVsValueMap = new Map<String,String>();
            labelVsValueMap.put('GST Percent',Label.GST_Percent);
            labelVsValueMap.put('Minimum Loan Amount',Label.Minimum_Loan_Amount);
            labelVsValueMap.put('Slider Step Size',Label.Slider_Step_Size);

            screenWrapperObj.customLabelMap = labelVsValueMap;
        } catch (Exception e) {
            screenWrapperObj.errorMessage = e.getMessage();
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,loanApplicationId,null,screenName);
        }

        return screenWrapperObj;
    }

    /** 
	* @description Function to fetch current screen data along with applicant,document checklist, address and other records
	* Inputs: json string contain loan application id, applicant id,screen name,doc master name,doc category name, address id
	* Returns: Return a wrapper contain all required data
	*/
    @AuraEnabled
    public static ScreenWrapper getCurrentScreenDataCatg(String jsonString){
        Map<String, Object> currectScreeDataMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        String loanApplicationId = (currectScreeDataMap.get('loanApplicationId') != null) ? (String)currectScreeDataMap.get('loanApplicationId') : '';
        String applicantId = (currectScreeDataMap.get('applicantId') != null) ? (String)currectScreeDataMap.get('applicantId') : '' ; 
        String screenName = (currectScreeDataMap.get('screenName') != null) ? (String)currectScreeDataMap.get('screenName') : '';
        String masterName = (currectScreeDataMap.get('masterName') != null) ? (String)currectScreeDataMap.get('masterName') : '';
        String documentCategory = (currectScreeDataMap.get('documentCategory') !=null) ? (String)currectScreeDataMap.get('documentCategory') : ''; 
        String docMasterName = (currectScreeDataMap.get('docMasterName') != null) ? (String)currectScreeDataMap.get('docMasterName') : '';
        String addressSource = (currectScreeDataMap.get('addressSource') != null) ? (String)currectScreeDataMap.get('addressSource') : '';
        String addressId = (currectScreeDataMap.get('addressId') != null) ? (String)currectScreeDataMap.get('addressId') : '';
        
        ScreenWrapper screenWrapperObj = new ScreenWrapper();
        try {
            if(String.isNotBlank(loanApplicationId)){
                List<Loan_Application__c> loanApplicationList = [SELECT Id,Name,Loan_Amount__c,IPA_Offer_Amount__c,Purpose_of_Loan_Others__c,Purpose_of_Loan__c,Last_visited_Page__c,Initiation_Referral_code__c,Initiation_Referral_code__r.FederationIdentifier,Stage__c, (SELECT Product_Type__c FROM Pre_Approved_Offers__r ORDER BY CreatedDate DESC LIMIT 1) FROM Loan_Application__c WHERE Id =:loanApplicationId LIMIT 1];
                screenWrapperObj.loanApplicationList = loanApplicationList;
            }
            if(String.isNotBlank(applicantId)){
                List<Applicant__c> applicantList = [SELECT Id,Full_Name__c,Birth_Date__c,Personal_email_ID__c,Is_Personal_Email_Id_Verified__c,Gender__c,Current_Pincode__c,Current_Pincode_Retry_Count__c,Loan_Application__r.Stage__c,Loan_Application__r.Reject_Sub_Reason__c,Loan_Application__r.Last_visited_Page__c, CFR_Check__c, AML_verified__c, Hunter_Status__c,PAN__c,Employment_Type__c,(SELECT Id,Document_Name__c,Active__c,Owned_Address_Proof_Type__c FROM Document_Checklists__r WHERE Document_Master__r.Document_Category__c =:documentCategory and Document_Master__r.Name=:docMasterName LIMIT 100) FROM Applicant__c WHERE Id =:applicantId LIMIT 1];
                screenWrapperObj.applicantList = applicantList;
                if(String.isNotBlank(addressId)){
                    screenWrapperObj.dedupeAddressList = getCustomerAddress(addressId,addressSource);
                }
                
            }
            if(String.isNotBlank(screenName)){
                List<AUSF_Screen_Custom_Text__mdt> screenCustomTextList = AUSF_Utility.getScreenCustomTextRecords(screenName);
                screenWrapperObj.screenCustomTextList = screenCustomTextList;
    
                Id userProfileId = UserInfo.getProfileId();
    
                String profileName = [SELECT Id,Name FROM Profile WHERE Id =: userProfileId LIMIT 1].Name;

                screenWrapperObj.profileName = profileName;
        
                List<Profile_to_UI_Wizard_Mapping__mdt> profileToWizardMetadataList = [SELECT Profile_Name__c,Wizard_Metadata_Name__c,Label FROM Profile_to_UI_Wizard_Mapping__mdt WHERE Profile_Name__c=:profileName LIMIT 1];
        
                if(profileToWizardMetadataList.size()>0){
                    string metadataToBeUsed = profileToWizardMetadataList[0].Wizard_Metadata_Name__c;
                    if(metadataToBeUsed == 'Generic_UI_Wizard_Mapping_DIY__mdt'){
                        List<Generic_UI_Wizard_Mapping_DIY__mdt> wizardUIMapping = [SELECT Category__c,Current_Screen_Name__c,Is_Default__c,Order__c,Progress_in_Current_Step__c,Overall_Step__c,Current_Screen_Component__c,Label FROM Generic_UI_Wizard_Mapping_DIY__mdt WHERE Current_Screen_Name__c=:screenName LIMIT 1];
                        screenWrapperObj.wizardDataDIYList = wizardUIMapping;
                    }else if(metadataToBeUsed == 'Generic_UI_Wizard_Mapping_Assisted__mdt'){
                        List<Generic_UI_Wizard_Mapping_Assisted__mdt> wizardUIMapping = [SELECT Category__c,Current_Screen_Name__c,Is_Default__c,Order__c,Progress_in_Current_Step__c,Overall_Step__c,Current_Screen_Component__c,Label FROM Generic_UI_Wizard_Mapping_Assisted__mdt WHERE Current_Screen_Name__c=:screenName LIMIT 1];
                        screenWrapperObj.wizardDataAssistedList = wizardUIMapping;
                        // Progress_in_Overall_Step__c
                    }
                }
            }

            if(String.isNotBlank(masterName)){
                List<Integration_Master__c> masterList = [SELECT Id,Max_number_of_retries_allowed__c,Max_number_of_functional_retries__c FROM Integration_Master__c WHERE Name=:masterName LIMIT 1];
                if(masterList.size() > 0){
                    screenWrapperObj.masterDetails = masterList;
                }
            }
        } catch (Exception e) {
            screenWrapperObj.errorMessage = e.getMessage();
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,loanApplicationId,null,screenName);
        }

        return screenWrapperObj;
    }

    /** 
	* @description Function to fetch customer address
	* Inputs: address id and address source
	* Returns: Return list of address record
	*/
    @AuraEnabled
    public static List<Address__c> getCustomerAddress(string addressId, String addressSource){
        try {

            List<Address__c> addressList = [SELECT Id,Name,Pincode__c,Address_Line_1__c,Address_Line_2__c,Address_Line_3__c,Residence_Ownership_Type__c,Duration_of_Current_Stay_Months__c,Duration_of_Current_Stay_years__c,City__c,State__c FROM Address__c WHERE Id =:addressId  AND Address_Source__c =:addressSource AND Active__c = true LIMIT 1000];
            return addressList;

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'Address','Confirm Personal Details');
            return null;
        }
    }
    @AuraEnabled
    public static string updateLoanApplication(string loanApplcationObj,string loanApplicationId,string screenName){
        try {

            Loan_Application__c loanApplcationData = (Loan_Application__c)JSON.deserialize(loanApplcationObj,Loan_Application__c.class);
            loanApplcationData.Last_Activity__c = DateTime.now();
            update loanApplcationData;
            return 'success';

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,loanApplicationId,'Loan Application',screenName);
            return null;
        }
    }
    @AuraEnabled
    public static List<User> getCurrentUserDetails(){
        try {

            List<User> userList = [SELECT Id,Profile.Name,Name,Salutation__c,FirstName, UserType FROM User WHERE Id =: UserInfo.getUserId() LIMIT 1];
            return userList;

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'User','Check Journey');
            return null;
        }
    }
    @AuraEnabled
    public static List<Lead_Stage__c> getRelatedLeadStage(string mobileNumber){
        try {

            List<Lead_Stage__c> leadStageList = [SELECT Id,Name,Sourcing_Channel__c,Customer_OTP_Validated__c,Journey_Mode__c,Loan_Application__c,CreatedBy.Name,RO_to_continue_journey__c,CreatedBy.FirstName,CreatedBy.Salutation__c FROM Lead_Stage__c WHERE Name =: mobileNumber LIMIT 1];
            return leadStageList;

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'Lead Stage','Check Journey');
            return null;
        }
    }

    @AuraEnabled
    public static string updateApplicant(string applicantObj,string applicantId,string screenName){
        try {
            Applicant__c applicationData = (Applicant__c)JSON.deserialize(applicantObj,Applicant__c.class);
            update applicationData;
            return 'success';

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,applicantId,'Applicant',screenName);
            return null;
        }
    }
    //method overriding
    public static string updateApplicant(string applicantObj,string applicantId){
        try {
            Applicant__c applicationData = (Applicant__c)JSON.deserialize(applicantObj,Applicant__c.class);
            update applicationData;
            return 'success';

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,applicantId,'Applicant','');
            return null;
        }
    }
    //method overriding
    public static string updateLoanApplication(string loanApplcationObj,string loanApplicationId){
        try {
            Loan_Application__c loanApplcationData = (Loan_Application__c)JSON.deserialize(loanApplcationObj,Loan_Application__c.class);
            update loanApplcationData;
            return 'success';

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,loanApplicationId,'Loan Application','');
            return null;
        }
    }
    @AuraEnabled
    public static string updateLeadStage(string leadObj,string leadId,string screenName){
        try {
            Lead_Stage__c leadData = (Lead_Stage__c)JSON.deserialize(leadObj,Lead_Stage__c.class);
            update leadData;
            return 'success';

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,leadId,'Lead Stage',screenName);
            return null;
        }
    }
    @AuraEnabled
    public static string deleteLeadStage(string leadId,string screenName){
        try {
            List<Lead_Stage__c> leadData = [SELECT Id from Lead_Stage__c WHERE Id =: leadId LIMIT 1];
            if(leadData.size() > 0){
                delete leadData;
            }
            return 'success';

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,leadId,'Lead Stage',screenName);
            return null;
        }
    }

    @AuraEnabled
    public static ScreenWrapper getApplicationDetails(string phoneNumber,string screenName){
        ScreenWrapper screenWrapperObj = new ScreenWrapper();
        try {
            Id applicantRecordType = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary').getRecordTypeId();
            if(String.isNotBlank(phoneNumber)){
                screenWrapperObj.leadStageList = getRelatedLeadStage(phoneNumber);
                // if(screenWrapperObj.leadStageList != null && screenWrapperObj.leadStageList.size() > 0 && screenWrapperObj.leadStageList[0].Loan_Application__c != null){
                    screenWrapperObj.loanApplicationList = [
                        SELECT Id, Name, Journey_Mode__c, Last_Activity__c, Last_visited_Page__c, Branch__c, Lead_reference_number__c, SO_Name__c, SO_Employee_Id__c, Stage__c, Exempt_Duplicate__c, LastModifiedDate, Mobile_Number__c,(SELECT Id,Full_Name__c,Employment_Type__c FROM Applicants__r WHERE RecordTypeId =: applicantRecordType)
                        FROM Loan_Application__c
                        WHERE Mobile_Number__c =: phoneNumber
                        AND Exempt_Duplicate__c = false
                        LIMIT 1
                    ];
                    // WHERE Id =:screenWrapperObj.leadStageList[0].Loan_Application__c
                // }
            }
            system.debug(LoggingLevel.Info,'screenWrapperObj ' + screenWrapperObj);
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,null,screenName);
        }
        return screenWrapperObj;
    }

    @AuraEnabled
    public static ScreenWrapper getApplicationDetailsById(string loanId, string screenName){
        ScreenWrapper screenWrapperObj = new ScreenWrapper();
        try {
            Id applicantRecordType = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary').getRecordTypeId();
            if(String.isNotBlank(loanId)){
                    screenWrapperObj.loanApplicationList = [
                        SELECT Id, Name, Journey_Mode__c, Last_Activity__c, Last_visited_Page__c, Branch__c, Lead_reference_number__c, SO_Name__c, SO_Employee_Id__c, Stage__c, Exempt_Duplicate__c, LastModifiedDate, Mobile_Number__c,(SELECT Id,Name,Full_Name__c,Employment_Type__c FROM Applicants__r WHERE RecordTypeId =: applicantRecordType) 
                        FROM Loan_Application__c
                        WHERE Id =:loanId
                        LIMIT 1
                    ];
            }
            system.debug(LoggingLevel.Info,'screenWrapperObj ' + screenWrapperObj);
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,null,screenName);
        }
        return screenWrapperObj;
    }

    /** 
	* @description Function to create address record
	* Inputs: address object instance, pincode and screen name
	* Returns: Return updated or created address id
	*/
    @AuraEnabled
    public static string createAddress(string addressObj, string pincode,string screenName){
        try {
            Address__c addressData = (Address__c)JSON.deserialize(addressObj,Address__c.class);
            List<Address__c> adrsList = [SELECT Id, Active__c, Address_Type__c FROM Address__c 
                                        WHERE Applicant__c =:addressData.Applicant__c 
                                        AND Address_Type__c = 'Work' and Active__c = true];
            if(!adrsList.isEmpty()) {
		      for(Address__c adrs : adrsList){
       		     adrs.Active__c = false;
  			  }
			 Update adrsList;
             
			 }
            // insert addressData;
            // Changed logic from insert to upsert if address id is present by Ruturaj for genericBusinessDetail screen changes
            upsert addressData;
            return addressData.Id;
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,'','Address',screenName);
            return null;
        }
    }

    @AuraEnabled
    public static string createLeadStage(string leadStageObj,string screenName){
        try {
            Lead_Stage__c leadData = (Lead_Stage__c)JSON.deserialize(leadStageObj,Lead_Stage__c.class);
            insert leadData;
            return leadData.Id;

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,'','Lead Stage',screenName);
            return null;
        }
    }
    
    @AuraEnabled
    public static List<Lead_Stage__c> getRelatedLeadStageById(string leadId){
        try {

            List<Lead_Stage__c> leadStageList = [SELECT Id,Name,Sourcing_Channel__c,Customer_OTP_Validated__c,Journey_Mode__c,Loan_Application__c,CreatedBy.Name,RO_to_continue_journey__c,CreatedBy.FirstName,CreatedBy.Salutation__c, Is_Mobile_Number_Verified__c FROM Lead_Stage__c WHERE Id =: leadId LIMIT 1];
            return leadStageList;

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'Lead Stage','Check Journey');
            return null;
        }
    }


    @AuraEnabled
    public static List<Address__c> getCustomerDedupeAddress(string applicantId){
        try {

            List<Address__c> addressList = [SELECT Id,Name,Pincode__c FROM Address__c WHERE Id =: applicantId AND Address_Source__c = 'Customer Dedupe' LIMIT 1000];
            return addressList;

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'Address','Confirm Personal Details');
            return null;
        }
    }
    
    /** 
	* @description Function to get generic buisness metadata records
	* Inputs: label name
	* Returns: Return list of fetch metadata record
	*/
    @AuraEnabled
    public static List<AUSF_GenericBuisnessProofData__mdt> getGenericBuisnessMetadaData(String labelName){
        try {
            return [SELECT Id,Screen_Name__c,MasterLabel,DeveloperName,isBuisnessPrfName__c,Doc_Category_Name__c,Doc_Master_Name__c,Employment_Record_Name__c,Employment_Record_Type__c,isDateOfIncopration__c,component_Height__c,isDocNumber__c,isRegisteredBuisnessName__c,isUploadSection__c,Page_Sub_Title__c,Page_Title__c, Doc_Number_Label__c ,IsIndustryType__c  FROM AUSF_GenericBuisnessProofData__mdt WHERE Screen_Name__c=:labelName Limit 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /** 
	* @description Function to get generic buisness metadata records
	* Inputs: label name
	* Returns: Return list of fetch metadata record
	*/
    @AuraEnabled
    public static List<AUSF_GenericBuisnessProofData__mdt> getGenericBuisnessMetadaDataRec(String recName){
        try {
            return [SELECT Id,Screen_Name__c,MasterLabel,DeveloperName,isBuisnessPrfName__c,Doc_Category_Name__c,Doc_Master_Name__c,Employment_Record_Name__c,Employment_Record_Type__c,isDateOfIncopration__c,component_Height__c,isDocNumber__c,isRegisteredBuisnessName__c,isUploadSection__c,Page_Sub_Title__c,Page_Title__c, Doc_Number_Label__c ,IsIndustryType__c  FROM AUSF_GenericBuisnessProofData__mdt WHERE Employment_Record_Type__c=:recName Limit 1];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /** 
	* @description Function to get employment detail records
	* Inputs: applicantid and recordtype name
	* Returns: Return list of employment detail records
	*/
    @AuraEnabled(cacheable=true)
    public static List<Employment_Detail__c> getEmploymentDetail(String applicantId,String recordTypeName) {
        return [SELECT Id, Document_Number__c, Others_Business_Proof_Name__c, Date_of_Incorporation__c, Registered_Business_name__c,
                       Sector__c, Industry__c, Sub_Industry__c, Activity__c,Address__c, Industry_Type__c
                FROM Employment_Detail__c
                WHERE Applicant__c = :applicantId and RecordType.Name = :recordTypeName and Active__c	= true];
    }
    @AuraEnabled
    public static string getCommunityBaseUrl(){
        try {

            List<Network> networkList = [SELECT Name, UrlPathPrefix FROM Network WHERE Name = 'AUSFPLDIY'];
            if(networkList.size() > 0){
                return Network.getLoginUrl(networkList[0].Id);
            }else{
                return null;
            }

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,'','Network',null);
            return null;
        }
    }

    @AuraEnabled
    public static Boolean aditionalDedupeCheck(String applicantId){
        Boolean dedupeCheckPass = false;
        try {

            //dedupeCheckPass = AUSF_LoanApplicationService.aditionalDedupeCheck(applicantId);

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,'','Network',null);
        }
        return dedupeCheckPass;
    }

    @AuraEnabled
    public static List<Address__c> getApplicantAddressList(String applicantId){
        try{
            List<Address__c> addressList = [SELECT Id, Address_Line_1__c,Address_Line_2__c, Address_Line_3__c, Address_Source__c, Address_Type__c, Applicant__c, City__c, Duration_of_Current_Stay_Months__c, Duration_of_Current_Stay_years__c, Name, Pincode__c, Residence_Ownership_Type__c, Residence_Type__c, State__c, Type__c, Working_Area__c, Is_Communication_Address__c FROM Address__c WHERE Applicant__c = :applicantId AND (Address_Type__c = 'Permanent' OR Address_Type__c = 'Current' OR Address_Type__c = 'Work') AND Active__c = true];
            Id.valueOf(applicantId);
            return addressList;
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.valueOf('Medium'), null, null, null);
            return null;
        }
    }
    @AuraEnabled
    public static String test(String id){
        try{

            List<ContentDocumentLink> listOfContentDocumentLink = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: id];
            return EncodingUtil.Base64Encode([select Id,VersionData from contentversion where ContentDocumentId =: listOfContentDocumentLink[0].ContentDocumentId][0].VersionData);
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.valueOf('Medium'), null, null, null);
            return null;
        }
    }

    @AuraEnabled
    public static String cloneAddress(String applicantId){
        try{
            List<Address__c> addressList = getCustomerDedupeAddress(applicantId);
            if(addressList != null){
                Address__c addressObj = addressList[0].clone(false,false,false,false);
                addressObj.Active__c = true;
                addressObj.Address_Type__c = 'Current';
                insert addressObj;
            }
            return 'success';
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,null,'Address','Confirm Personal Details');
            return null;
        }
    }

     /** 
	* @description Function to upload file in salesforce
	* Inputs: json string contain detail of upload file
	* Returns: return id of contentversion
    * Jira Story : 
	*/
    @AuraEnabled
    public static String uploadFile(String jsonString) {
        try{
            Map<String, Object> fileUploadMap = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        
            // Access the values from the Map
            String base64 = (String) fileUploadMap.get('base64');
            String filename = (String) fileUploadMap.get('filename');
            String recordId = (String) fileUploadMap.get('recordId');
            String applicantId = (String) fileUploadMap.get('applicantId');
            String loanId = (String) fileUploadMap.get('loanId');
            String filetype = (String) fileUploadMap.get('filetype');
            String docMasterName = (String) fileUploadMap.get('docMasterName');
            Boolean isZipped = (Boolean) (fileUploadMap.get('isZipped')==null?false:fileUploadMap.get('isZipped'));
            Boolean isExistingFileDel = (Boolean) (fileUploadMap.get('isExistingFileDel')==null?false:fileUploadMap.get('isExistingFileDel'));
            System.debug('base64'+isZipped);
            if (isZipped || isExistingFileDel) {
				//deleteAttachedFiles(recordId);
			}
            ContentVersion cv = createContentVersion(base64, filename,applicantId,recordId);
            ContentDocumentLink cdl = createContentLink(cv.Id, recordId);
            if (cv == null || cdl == null) { return null; }
            return cv.Id;
        }
        catch(Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'Upload file','Upload Document File');
            return null;
        }
    }
    public static ContentVersion createContentVersion(String base64, String filename,String applicantId,string recordId) {
        try {
            AUSF_INT_DocumentCompressWrapper responseWrapper= AUSF_DocumentCompressController.getCompresssedDocument(base64,filename,applicantId,'',recordId);
            String compressedBase64 = base64;
            if(responseWrapper != null && responseWrapper.blnSuccess){
                compressedBase64 = responseWrapper.OutputBase64String;
            }

            ContentVersion cv = new ContentVersion();
            cv.VersionData = EncodingUtil.base64Decode(compressedBase64);
            cv.Title = filename;
            cv.PathOnClient = filename;
        
            insert cv;
            return cv;
        } catch(Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'Content Version','Residence Ownership Proof');
            return null;
        }
    }
  
    public static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
        if (contentVersionId == null || recordId == null) { return null; }
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.ContentDocumentId = [
          SELECT ContentDocumentId 
          FROM ContentVersion 
          WHERE Id =: contentVersionId
        ].ContentDocumentId;
        cdl.LinkedEntityId = recordId;
        // ShareType is either 'V', 'C', or 'I'
        // V = Viewer, C = Collaborator, I = Inferred
        cdl.ShareType = 'V';
        try {
            insert cdl;
            List<Document_Checklist__c> checklistLst = [SELECT Upload_Status__c FROM Document_Checklist__c WHERE Id=:recordId LIMIT 1];
            if(checklistLst.size() >0){
                checklistLst[0].Upload_Status__c = 'Upload';
                update checklistLst;
            }
            return cdl;
        } catch(Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'Content Document Link','Residence Ownership Proof');
            return null;
        }
    }  
    @AuraEnabled
    public static String createDocumentChecklist(String masterName,String documentChecklistObj){
        try{
            Map<Id,Document_Checklist__c> mapUpdateDocChecklist = new Map<Id,Document_Checklist__c>();
            List<Document_Master__c> documentMasterList = [SELECT Id,Document_Name__c FROM Document_Master__c WHERE Document_Name__c=: masterName AND Active__c = true AND Document_Category__c = 'Residence Ownership Proof' LIMIT 1 ];
            if(documentMasterList.size() > 0){
                Document_Checklist__c docChecklistRec = (Document_Checklist__c)JSON.deserialize(documentChecklistObj,Document_Checklist__c.class);
                string checklistId;
                List<Document_Checklist__c> exisitingDocChecklist = [SELECT Id,Document_Master__c,Active__c,Document_Name__c FROM Document_Checklist__c WHERE Document_Master__r.Document_Category__c = 'Residence Ownership Proof' AND Applicant__c=: docChecklistRec.Applicant__c LIMIT 1000];
                if(exisitingDocChecklist.size() > 0){
                    for(Document_Checklist__c docCheckList: exisitingDocChecklist){
                        docCheckList.Active__c = false;
                        if(docCheckList.Document_Name__c == docChecklistRec.Document_Name__c){
                            checklistId = docCheckList.Id;
                        }
                        mapUpdateDocChecklist.put(docCheckList.Id, docCheckList);
                    }
                    //update exisitingDocChecklist;

                }
                
                docChecklistRec.Document_Master__c = documentMasterList[0].Id;
                
                if (docChecklistRec != NULL && docChecklistRec.Id != NULL && mapUpdateDocChecklist.containsKey(Id.valueOf(docChecklistRec.Id+''))) {
                    //Document_Checklist__c objDocRecord = mapUpdateDocChecklist.get(Id.valueOf(docChecklistRec.Id+''));
                    //objDocRecord.Active__c = true;
                    mapUpdateDocChecklist.put(docChecklistRec.Id,docChecklistRec);
                }
                else if (String.isNotBlank(checklistId) && mapUpdateDocChecklist.containsKey(Id.valueOf(checklistId))) {
                    docChecklistRec.Id = Id.valueOf(checklistId);
                    mapUpdateDocChecklist.put(Id.valueOf(checklistId),docChecklistRec);
                }
                if (mapUpdateDocChecklist.size()>0) {
                    update mapUpdateDocChecklist.values();
                }
                System.debug(String.isNotBlank(checklistId));
                System.debug(docChecklistRec != NULL);
                System.debug(docChecklistRec.Id == NULL);
                if (String.isBlank(checklistId) && docChecklistRec != NULL && docChecklistRec.Id == NULL) {
                    insert docChecklistRec;
                }

                /*
                if(docChecklistRec.Id != null){
                    update docChecklistRec;
                }
                else if(checklistId != null){
                    docChecklistRec.Id = checklistId;
                    update docChecklistRec;
                }else{
                    insert docChecklistRec;
                }
                */
                return docChecklistRec.Id;
            }
            return null;
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,null,'Document_Checklist__c','Residential Proof');
            return null;
        }
    }

    @AuraEnabled
    public static String createDocumentChecklistRec(String masterName,String documentChecklistObj, string documentCategory){
        try{
            Map<Id,Document_Checklist__c> mapUpdateDocChecklist = new Map<Id,Document_Checklist__c>();
            List<Document_Master__c> documentMasterList = [SELECT Id,Document_Name__c FROM Document_Master__c WHERE Document_Name__c=: masterName AND Active__c = true AND Document_Category__c =: documentCategory LIMIT 1 ];
            if(documentMasterList.size() > 0){
                Document_Checklist__c docChecklistRec = (Document_Checklist__c)JSON.deserialize(documentChecklistObj,Document_Checklist__c.class);
                string checklistId;
                List<Document_Checklist__c> exisitingDocChecklist = [SELECT Id,Document_Master__c,Active__c,Document_Name__c FROM Document_Checklist__c WHERE Document_Master__r.Document_Category__c =:documentCategory AND Applicant__c=: docChecklistRec.Applicant__c AND Document_Master__r.Document_Name__c=: masterName LIMIT 1000];
                if(exisitingDocChecklist.size() > 0){
                    for(Document_Checklist__c docCheckList: exisitingDocChecklist){
                        docCheckList.Active__c = false;
                        if(docCheckList.Document_Name__c == docChecklistRec.Document_Name__c){
                            checklistId = docCheckList.Id;
                        }
                        mapUpdateDocChecklist.put(docCheckList.Id, docCheckList);
                    }
                }
                
                docChecklistRec.Document_Master__c = documentMasterList[0].Id;
                
                if (docChecklistRec != NULL && docChecklistRec.Id != NULL && mapUpdateDocChecklist.containsKey(Id.valueOf(docChecklistRec.Id+''))) {
                    mapUpdateDocChecklist.put(docChecklistRec.Id,docChecklistRec);
                }
                else if (String.isNotBlank(checklistId) && mapUpdateDocChecklist.containsKey(Id.valueOf(checklistId))) {
                    docChecklistRec.Id = Id.valueOf(checklistId);
                    mapUpdateDocChecklist.put(Id.valueOf(checklistId),docChecklistRec);
                }
                if (mapUpdateDocChecklist.size()>0) {
                    update mapUpdateDocChecklist.values();
                }
                if (String.isBlank(checklistId) && docChecklistRec != NULL && docChecklistRec.Id == NULL) {
                    insert docChecklistRec;
                }
                return docChecklistRec.Id;
            }
            return null;
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,null,'Document_Checklist__c',documentCategory);
            return null;
        }
    }
    @AuraEnabled
    public static Document_Master__c getDocumentMaster(String masterName){
        try{
            List<Document_Master__c> documentMasterList = [SELECT Id,Document_Name__c,File_Size__c,Multiple_Upload__c,Supported_Doc_Types__c,No_Of_Document_Upload__c,File_Upload_Note__c FROM Document_Master__c WHERE Document_Name__c=: masterName AND Active__c = true LIMIT 1 ];
            if(documentMasterList.size() > 0){
                return documentMasterList[0];
            }
            return null;
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,null,'Document_Master__c','Get Document_Master__c Record');
            return null;
        }
    }

    @AuraEnabled
    public static List<FileDataWrapper> getRelatedFiles(String documentChecklistRec){
        List<FileDataWrapper> fileWrapperList = new List<FileDataWrapper>();
        try{
            List<ContentDocumentLink> cdlList = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId=: documentChecklistRec LIMIT 1000];
            set<id> contentDocumentIdSet = new Set<Id>();
            for (ContentDocumentLink cdl : cdlList) {
                contentDocumentIdSet.add(cdl.ContentDocumentId);
            }

            List<ContentVersion> cvList = [SELECT Id,ContentDocumentId,ContentUrl,Title,FileExtension,VersionData,contentsize FROM ContentVersion WHERE ContentDocumentId IN : contentDocumentIdSet LIMIT 1000];
            if(cvList.size() > 0){
                for (ContentVersion cvObj : cvList) {
                    FileDataWrapper wrapperObj = new FileDataWrapper();
                    wrapperObj.base64 = EncodingUtil.Base64Encode(cvObj.VersionData);
                    wrapperObj.contentVersionObj = cvObj;
                    fileWrapperList.add(wrapperObj);
                }

            }
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,null,'Document_Checklist__c','Residential Proof');
        }
        return fileWrapperList;
    }
    @AuraEnabled
    public static string deleteSelectedFile(String contentVersionId){
        try{
            List<ContentVersion> cvList = [SELECT Id,ContentDocumentId,ContentUrl,Title,FileExtension,VersionData,contentsize FROM ContentVersion WHERE Id =: contentVersionId LIMIT 1];
            if(cvList.size()>0){
                delete [SELECT Id FROM ContentDocument WHERE Id=: cvList[0].ContentDocumentId LIMIT 1];
                return 'success';
            }
            return null;
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,null,'ContentVersion','Residential Proof');
            return null;
        }
    }
    
     @AuraEnabled(Cacheable=true)
    public static List<AUSF_Screen_Custom_Text__mdt> getScreenCustomTextRecords(String screenName) {
        try {
            return [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, Product__c, Custom_String__c, Screen_Name__c,Custom_String_for_DIY__c FROM AUSF_Screen_Custom_Text__mdt where Screen_Name__c =:screenName LIMIT 1000];
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'AUSF Screen Custom Text',screenName);
            return null;
        }
    }

    @AuraEnabled
    public static List<BRE_Response__c> checkBREIPAResponse(String masterName,string loanApplication,string screenName) {
        try {
            return [SELECT Id, Name, Integration_Checklist__c,BRE_Decision__c, Loan_Application__c,Loan_Application__r.Stage__c,Integration_Checklist__r.Status__c FROM BRE_Response__c WHERE Integration_Checklist__r.Integration_Master__r.Name =:masterName AND Loan_Application__c =: loanApplication ORDER BY CreatedDate DESC LIMIT 1];
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'BRE_Response__c',screenName);
            return null;
        }
    }

    /* Use getICRecords method -----
    @AuraEnabled
    public static List<Integration_Checklist__c> getLatestICRecord(String masterName,string loanApplication,string screenName) {
        try {
            return [SELECT Id, Name, Status__c,CreatedDate FROM Integration_Checklist__c WHERE Integration_Master__r.Name =:masterName AND Loan_Application__c =: loanApplication ORDER BY CreatedDate DESC LIMIT 1];
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'Integration_Checklist__c',screenName);
            return null;
        }
    }
    */

    /*
    @description    : getIntegrationChecklist
    @param1         : masterName - Integration Master Name
    @param2         : strObjectName - SObject API Name
    @param3         : strRelatedRecordId - related (Parent) Record Id
    @param4         : screenName - Screen Name
    @return         : NULL or List of Integration Checklist records
    */
    @AuraEnabled
    public static List<Integration_Checklist__c> getIntegrationChecklist(String masterName, String strObjectName, String strRelatedRecordId, string screenName) {
        List<Integration_Checklist__c> lstICRecords = new List<Integration_Checklist__c>();
        try {
            
            if (strObjectName == 'Applicant__c') {
                lstICRecords = [SELECT Id, Name, Status__c,Failure_Type__c,CreatedDate FROM Integration_Checklist__c WHERE Integration_Master__r.Name =:masterName AND Applicant__c =: strRelatedRecordId ORDER BY CreatedDate DESC LIMIT 10];
            }
            else if (strObjectName == 'Loan_Application__c') {
                lstICRecords = [SELECT Id, Name, Status__c,Failure_Type__c,CreatedDate FROM Integration_Checklist__c WHERE Integration_Master__r.Name =:masterName AND Loan_Application__c =: strRelatedRecordId ORDER BY CreatedDate DESC LIMIT 10];
            }
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'Integration Checklist',screenName);
            return NULL;
        }
        return lstICRecords;
    }

    @AuraEnabled
    public static List<Integration_Checklist__c> getICRecords(String masterName, String loanApplication, string screenName) {
        try {
            return [SELECT Id, Name, Status__c,Failure_Type__c,CreatedDate FROM Integration_Checklist__c WHERE Integration_Master__r.Name =:masterName AND Loan_Application__c =: loanApplication ORDER BY CreatedDate DESC LIMIT 10000];
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'Integration Checklist',screenName);
            return null;
        }
    }
    
    @AuraEnabled
    public static String doBackendOperation(string wrapperString) {
        BackendOperationWrapper wrapperObj = new BackendOperationWrapper();
        wrapperObj = (BackendOperationWrapper)JSON.deserialize(wrapperString,BackendOperationWrapper.class);
        try {
            if(wrapperObj != null && wrapperObj.screenName == 'IPA BRE Loader'){
                List<Loan_Application__c> loanAppList = [SELECT Id,Loan_Amount__c,IPA_Offer_Amount__c FROM Loan_Application__c WHERE Id =: wrapperObj.loanApplicationId LIMIT 1];
                if(loanAppList.size()>0){
                    loanAppList[0].Loan_Amount__c = loanAppList[0].IPA_Offer_Amount__c;
                    update loanAppList;
                    wrapperObj.operationComplete = true;
                }
            }
        } catch (Exception e) {
            wrapperObj.errorMsg = e.getMessage();
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'Integration_Checklist__c',wrapperObj.screenName);
        }
        return JSON.serialize(wrapperObj);
    }

    /** 
	* @description Function to fetch options for industry selection
	* Inputs: record type and parent value of profiling master
	* Returns: List of options  
    * Jira Story : 
	*/
    @AuraEnabled(cacheable=true)
    public static List<Map<String, String>> fetchOptions(String recordTypeName, String parentValue) {
        List<Map<String, String>> options = new List<Map<String, String>>();
        Map<String, String> parameters = new Map<String, String>();

        try{
        parameters.put('RecordTypeName', recordTypeName);
        if (String.isNotBlank(parentValue)) {
            parameters.put('ParentValue', parentValue);
        }

        // Build SOQL query based on parameters
        String query = 'SELECT Code__c, Name FROM Profiling_Master__c WHERE RecordType.DeveloperName = :parameters.RecordTypeName';
        
        if (parameters.containsKey('ParentValue')) {
            if (recordTypeName == 'Industry') {
                query += ' AND Sector__r.Name = :parameters.ParentValue';
            } else if (recordTypeName == 'Sub_Industry') {
                query += ' AND Industry__r.Name = :parameters.ParentValue';
            } else if (recordTypeName == 'Activity') {
                query += ' AND Sub_Industry__r.Name = :parameters.ParentValue';
            }
        }

        query += ' ORDER BY Code__c';
        
        // Execute query
        List<Profiling_Master__c> records = Database.query(query);

        // Process query results into a format suitable for the LWC
        for (Profiling_Master__c record : records) {
            Map<String, String> option = new Map<String, String>();
            option.put('name', record.Name);
            options.add(option);
        }
    }catch(Exception ex){
        AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium);
    }

        return options;
    }


    /** 
	* @description Function to invoke method for API
	* Inputs: screen name and json string
	* Returns: wrapper of EmploymentVerificationWrapper
    * Jira Story : 
	*/
    @AuraEnabled
    public static EmploymentVerificationWrapper invokeMethodForScreen(String screenName, String jsonString) {
        // Step 1: Retrieve metadata
        AUSF_GenericBuisnessProofData__mdt metadataRecord = [
            SELECT API_Method_Name__c, API_Method_Parameters__c,API_Class_Name__c,Integration_Master_Name__c
            FROM AUSF_GenericBuisnessProofData__mdt
            WHERE Screen_Name__c = :screenName
            LIMIT 1
        ];
        Map<String, Object> invokeMethodParams = (Map<String, Object>) JSON.deserializeUntyped(jsonString);
        String employmentId = (String)invokeMethodParams.get('employmentId');
        String memberShipNum = (String)invokeMethodParams.get('MembershipNo');
        String applicantId = (String)invokeMethodParams.get('applicantId');
        List<Employment_Detail__c> employmentDetailRec = [SELECT Id, Type_Verification__c, Document_Number__c,Address__c FROM Employment_Detail__c Where Id=:employmentId AND Document_Number__c=:memberShipNum AND Active__c=true];
        if (metadataRecord == null || String.isBlank(metadataRecord.API_Method_Name__c)) {
            throw new AuraHandledException('API Method not defined for the screen: ' + screenName);
        }
        

        if(employmentDetailRec.size()>0){
            if( employmentDetailRec[0].Type_Verification__c=='API'){
                List<Integration_Checklist__c> ic = [SELECT Id, Loan_Application__c, Applicant__c, Applicant__r.Loan_Application__c, Name, Response__c, Status__c, Applicant__r.Mobile_Number__c, Applicant__r.PAN__c, Applicant__r.Loan_Application__r.Employment_Type_Formula__c, Applicant__r.Loan_Application__r.Has_PA_Offer__c  
                                           FROM Integration_Checklist__c 
                                           WHERE Integration_Master__r.Name = :metadataRecord.Integration_Master_Name__c
                                           AND Status__c = :AUSF_ApexConstants.AUSF_IC_COMPLETED 
                                           AND Applicant__c = :applicantId 
                                           ORDER BY CreatedDate DESC LIMIT 1];
                if(ic.size()>0){
                    return new EmploymentVerificationWrapper(applicantId,(String)employmentDetailRec[0].Id,(String)employmentDetailRec[0].Address__c,true,true,metadataRecord);
                }
            }
            else{
                return new EmploymentVerificationWrapper(applicantId,(String)employmentDetailRec[0].Id,(String)employmentDetailRec[0].Address__c,false,true,metadataRecord);
            }  
        }
        Object result = null;
        //String returnResult = '{"strMessage": "","objIntResponse": null,"employmentDetailId": "a0PC10000026g0DMAQ","blnSuccess": true,"blnIntegrationSuccess": false,"addressId": "a0IC1000000FaMXMA0"}';
        String returnResult = '';
        // Step 3: Dynamically invoke the method on the class
        // Check the API class and method name from metadata
        if (metadataRecord.API_Class_Name__c == 'AUSF_ICSIController' && metadataRecord.API_Method_Name__c == 'getICSIDetails') {
            // Assuming methodName1 is a static method that accepts a JSON string
            result = AUSF_ICSIController.getICSIDetails(applicantId,memberShipNum,employmentId);
        } else if (metadataRecord.API_Class_Name__c == 'AUSF_ICAI_APIController' && metadataRecord.API_Method_Name__c == 'getICAIDetails') {
            // Assuming methodName2 is a static method that accepts individual parameters
            result = AUSF_ICAI_APIController.getICAIDetails(applicantId,memberShipNum,employmentId);
        } else if (metadataRecord.API_Class_Name__c == 'AUSF_ImportExportCertificateController' && metadataRecord.API_Method_Name__c == 'doImportExportCertification') {
            // Assuming methodName2 is a static method that accepts individual parameters
            result = AUSF_ImportExportCertificateController.doImportExportCertification(applicantId,memberShipNum,employmentId);
        }else if (metadataRecord.API_Class_Name__c == 'AUSF_INT_FSSAI_Callout_Controller' && metadataRecord.API_Method_Name__c == 'getFssaiResponse') {
            // Assuming methodName2 is a static method that accepts individual parameters
            result = AUSF_INT_FSSAI_Callout_Controller.getFssaiResponse(applicantId,memberShipNum,employmentId);
        }
         else {
            throw new AuraHandledException('No matching method found for ' + metadataRecord.API_Method_Name__c);
        }
        returnResult = result!=null?JSON.serialize(result):'';
        Map<String, Object> returnParamMap = (Map<String, Object>) JSON.deserializeUntyped(returnResult);

        return new EmploymentVerificationWrapper(applicantId,(String)returnParamMap.get('employmentDetailId'),(String)returnParamMap.get('addressId'),(Boolean)returnParamMap.get('blnSuccess'),true,metadataRecord);
    }

    /*
    @ description   : createLeadStageRecord
    @ US / Bug      : AUPL-605
    @ param1        : leadStageParams - stringify wrapper contains different attributes
    */
    @AuraEnabled
    public static string createLeadStageRecord(String leadStageParams){
        system.debug(LoggingLevel.Info, 'leadStageParams : ' + leadStageParams);
        Map<String,Object> mapObj = (Map<String,Object>)JSON.deserializeUntyped(leadStageParams);
        system.debug(LoggingLevel.Info, 'mapObj : ' + mapObj);
        String strScreenName = String.valueOf(mapObj.get('screenName'));
        try {
            if (mapObj.containsKey('strLeadObject')) {
                String strLeadRecord = JSON.serialize(mapObj.get('strLeadObject'));
                Lead_Stage__c leadData = (Lead_Stage__c)JSON.deserialize( strLeadRecord,Lead_Stage__c.class);
                insert leadData;
                return leadData.Id;
            }
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,'','Lead Stage',strScreenName);
            return null;
        }
            
        return null;
    }


    /*
    @ description   : sendRejectionNotifications
    @ US / Bug      : APL-880
    @ param1        : loanAppId: Loan Application ID
    @ param2        : applicantId: Applicant ID
    @ param3        : triggeringPoint: triigering point of notifications
    */
    @AuraEnabled
    public static void sendRejectionNotifications(String loanAppId, String applicantId, String triggeringPoint, String screenName){
        try {
            List<Loan_Application__c> applicationList = [SELECT Id, Name, Journey_Mode__c,Reject_Reason__c, Reject_Sub_Reason__c, OwnerId FROM Loan_Application__c WHERE Id=:loanAppId];
            if(applicationList.size() > 0){
                Loan_Application__c applicationObj = applicationList[0];
                if(applicationObj.Journey_Mode__c == AUSF_ApexConstants.AUSF_JOURNEY_MODE_DIY){
                    AUSF_NotificationController.sendAllNotification(null, null, applicantId, loanAppId, triggeringPoint, null);
                }else if(applicationObj.Journey_Mode__c == AUSF_ApexConstants.AUSF_JOURNEY_MODE_ASSISTED){
                    AUSF_NotificationController.sendAllNotification(null, applicationObj, applicantId, loanAppId, triggeringPoint, applicationObj.OwnerId);
                }
            }
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,'','Rejection Notification',screenName);
        }
    }

    /*
    @description    - method validate mobile number is valid or not
    @param1         - phoneNumber - Mobile Number in string
    @return         - Boolean
    */
    // Method to validate a mobile number
    public static Boolean isValidMobileNumber(String phoneNumber) {
        // Check for Blank
        if (string.isBlank(phoneNumber) || string.isBlank(phoneNumber.trim())) {
            return false;
        }
        // remove +91
        phoneNumber = phoneNumber.startsWith('+91') ? phoneNumber.subString(2) : phoneNumber;
        // check for length exclude +91
        if (phoneNumber.length() > 10 || phoneNumber.length() < 10) {
            return false;
        }
        String strFirstChars = phoneNumber.subString(0,1);
        String strSameCharacter = phoneNumber.replaceAll(strFirstChars,'');
        if (strFirstChars == '0' && strFirstChars == '1' || strFirstChars == '2' || strFirstChars == '3' || strFirstChars == '4' || strFirstChars == '5' || String.isEmpty(strSameCharacter)) {
            return false;
        }
        // Regular expression to match common mobile number formats
        // Modify this regex based on the specific format you expect
        String regex = '^(\\+\\d{1,3}[- ]?)?\\d{10}$';
        
        // Compile the regex pattern
        Pattern pattern = Pattern.compile(regex);
        
        // Match the provided phone number against the pattern
        Matcher matcher = pattern.matcher(phoneNumber);
        
        // Return true if the phone number matches the pattern, false otherwise
        return matcher.matches();
    }

    /*
    @description    - method validate PAN Number
    @param1         - strPanNumber - strPanNumber in String
    @return         - Boolean
    */
    // Method to validate a mobile number
    public static Boolean isValidPANNumber(String strPanNumber) {

        // Check if the PAN number is null or not exactly 10 characters long
        if (String.isEmpty(strPanNumber) || strPanNumber.length() != 10) {
            return false;
        }
        String strFourthChar = strPanNumber.substring(3,4);
        system.debug('strFourthChar ' + strFourthChar);
        if (strFourthChar != 'P') {
            return false;
        }
        // Regular expression to match the PAN number format
        String regex = '^[A-Z]{5}\\d{4}[A-Z]$';
        
        // Compile the regex pattern
        Pattern pattern = Pattern.compile(regex);
        
        // Match the provided PAN number against the pattern
        Matcher matcher = pattern.matcher(strPanNumber);
        
        // Return true if the PAN number matches the pattern, false otherwise
        return matcher.matches();
    }

    /*
    @description    - method to return Location Master
    @param1         - strZipCode - strZipCode in String
    @return         - List<Location_Master__c>
    */
    public static List<Location_Master__c> getLocationMasterFromZip (String strZipCode) {
        List<Location_Master__c> locationMasterList = new List<Location_Master__c>();
        locationMasterList = [SELECT Id, State__c, State_Code__c, City__c, City_Code__c, Working_Area__c FROM Location_Master__c WHERE Zip_Code__c =:strZipCode];
        return locationMasterList;
    }

    /*
    @description    - createIntegrationChecklistRecord - to create IC record
    @param1         - strMasterName - Integration Master Name
    @param2         - strObject - Related Object Name - Not Mandatory
    @param3         - strRecordId - Related Record Id - Not Mandatory
    @return         - Wrapper ScreenWrapper - consider blnSuccess and objIC record
    */
    @auraenabled
    public static ScreenWrapper createIntegrationChecklistRecord (String strMasterName, String strObject, String strRecordId) {
        ScreenWrapper objResponse = new ScreenWrapper();
        try {
            if (String.isEmpty(strMasterName)) {
                throw new CustomException ('Master Name cannot be blank');
            }
            Integration_Master__c integrationMasterRecord = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(strMasterName);
            if (integrationMasterRecord == NULL) {
                throw new CustomException ('Master Name is not correct');
            }
            objResponse.objIC = new Integration_Checklist__c();
            objResponse.objIC.put('Request_Id__c',AUSF_INT_IntegrationUtility.getReferenceId());
            objResponse.objIC.put('Integration_Master__c',integrationMasterRecord.Id);
            objResponse.objIC.put('Status__c','Pending');
            if (String.isNotBlank(strObject)) {
                objResponse.objIC.put(strObject,Id.valueOf(strRecordId));
            }
            insert objResponse.objIC;
            objResponse.blnSuccess = true;
        }
        catch(Exception ex) {
            objResponse.errorMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,'','Integration Checklist','Integration Checklist Creation');
        }
        return objResponse;

    }
    
    @AuraEnabled
    public static string createEmploymentDetails(string employmentDetObj, string screenName, String recordTypeName){
        try {
            Id recordTypeId = Schema.SObjectType.Employment_Detail__c.getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();
            Employment_Detail__c  employmentDetails = (Employment_Detail__c )JSON.deserialize(employmentDetObj,Employment_Detail__c .class);
            employmentDetails.RecordTypeId = recordTypeId;
            if(employmentDetails.Id != null){
               update employmentDetails;
            }
            else{
                insert employmentDetails;
            }
            return employmentDetails.Id;
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,'','',screenName);
            return null;
        }
    }


    /*
    @description    - getActiveEmploymentDetail - to get active Employment Detail Record with given record type
    @param1         - applicantId - Applicant Id
    @param2         - screenName -Screen Name
    @return         - Active Employment_Detail__c record Id
    @author         - Charchit Nirayanwal
    */
    @AuraEnabled
    public static string getActiveEmploymentDetail(string applicantId , string screenName, String recordTypeName){
        try {
            Employment_Detail__c empDetail = [SELECT ID, Document_Number__c FROM Employment_Detail__c WHERE Applicant__c =: applicantId AND RecordType.Name =: recordTypeName AND Active__c = true LIMIT 1];
            if(empDetail != null){
                return empDetail.Id;
            }
            else{
                return null;
            }
            
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,'','',screenName);
            return null;
        }
    }

    /** 
	* @description Function to get Employment dtail record type from map
	* Returns: Map of record type 
    * Jira Story : 
	*/
    @AuraEnabled
    public static Map<String, String> getEmploymentDetailRecordTypeMap(){
        try {
            return new Map<String, String>{
                'Others' => 'Others',
                'Factory registration certificate' => 'FRC',
                'GST Registration Certificate' => 'GST',
                'ICSI certificate' => 'ICSI',
                'Medical Degree by Medical Council of India' => 'Medical Degree',
                'Municipal Corp/Govt Issued Certificate' => 'Municipal Corp',
                'Pharmacy License' => 'Pharmacy License',
                'State/Central Pollution Control Board certificate' => 'PCBC',
                'Import Export Certificate' => 'IEC',
                'FSSAI Certificate' => 'FSSAI',
                'Shop & Establishment Certificate' => 'SEC',
                'Pharmacy License' => 'Pharmacy License',   
                'ICAI Certificate' => 'ICAI',
                'ICWAI Certificate' => 'ICWAI'
            };    
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /** 
	* @description Function to verify employment details
	* Inputs: applicant id
	* Returns: wrapper of EmploymentVerificationWrapper
    * Jira Story : 
	*/
    @AuraEnabled
    public static EmploymentVerificationWrapper verifyEmploymentDetails(Id applicantId) {
        // Step 1: Get the employment type (SEP or SENP)
        String employmentType = AUSF_LoanApplicationService.checkSelfEmploymentType(applicantId);

        // Step 2: Retrieve custom metadata record for the employment type
        String metadataName = (employmentType == 'SEP') ? 'SEP_Instant_Verification_Methods' : 'SENP_Instant_Verification_Methods';
        Boolean isInstant = false;
        AUSF_Screen_Custom_Text__mdt customMetadata = [
            SELECT Id, Custom_String__c
            FROM AUSF_Screen_Custom_Text__mdt
            WHERE DeveloperName = :metadataName
            LIMIT 1
        ];

        if (customMetadata == null || String.isBlank(customMetadata.Custom_String__c)) {
            throw new AuraHandledException('Custom metadata record not found or empty for employment type: ' + employmentType);
        }

        // Step 3: Parse the comma-separated string
        Set<String> employmentNamesSet = new Set<String>(customMetadata.Custom_String__c.split(','));

        // Step 4: Query employment detail records
        List<Employment_Detail__c> employmentDetails = [
            SELECT Id, Name, Applicant__c, Address__c,RecordType.Name
            FROM Employment_Detail__c
            WHERE Applicant__c = :applicantId AND Active__c = true
        ];

        Employment_Detail__c matchingEmploymentDetail = null;

        // Find the first matching employment detail
        for (Employment_Detail__c employmentDetail : employmentDetails) {
            matchingEmploymentDetail = employmentDetail;
            if (customMetadata.Custom_String__c.contains(employmentDetail.RecordType.Name)) {
                isInstant = true;
                break;
            }
        }
        AUSF_GenericBuisnessProofData__mdt metadataRecord = [
            SELECT API_Method_Name__c, API_Method_Parameters__c,API_Class_Name__c,Integration_Master_Name__c
            FROM AUSF_GenericBuisnessProofData__mdt
            WHERE Employment_Record_Type__c = :matchingEmploymentDetail.RecordType.Name
            LIMIT 1
        ];

        Boolean isSuccess = false;
        if(matchingEmploymentDetail!=null && isInstant){
            // Step 5: Query the latest Integration_Checklist__c record
            List<Integration_Checklist__c> ic = [SELECT Id, Loan_Application__c, Applicant__c, Applicant__r.Loan_Application__c, Name, Response__c, Status__c, Applicant__r.Mobile_Number__c, Applicant__r.PAN__c, Applicant__r.Loan_Application__r.Employment_Type_Formula__c, Applicant__r.Loan_Application__r.Has_PA_Offer__c  
                                           FROM Integration_Checklist__c 
                                           WHERE Integration_Master__r.Name = :metadataRecord.Integration_Master_Name__c
                                           AND Status__c = :AUSF_ApexConstants.AUSF_IC_COMPLETED 
                                           AND Applicant__c = :applicantId 
                                           ORDER BY CreatedDate DESC LIMIT 1];

            // Step 6: Check the status and return the wrapper
            if(ic.size()>0){
                isSuccess = true;
            }
                
        }
        AUSF_GenericBuisnessProofData__mdt genericMetadataPass = null;
        AUSF_GenericBuisnessProofData__mdt genericMetadataRec = null;
        for(AUSF_GenericBuisnessProofData__mdt genericMetadata : [SELECT Id,Screen_Name__c,MasterLabel,DeveloperName,isBuisnessPrfName__c,Doc_Category_Name__c,Doc_Master_Name__c,Employment_Record_Name__c,Employment_Record_Type__c,isDateOfIncopration__c,component_Height__c,isDocNumber__c,isRegisteredBuisnessName__c,isUploadSection__c,Page_Sub_Title__c,Page_Title__c, Doc_Number_Label__c ,IsIndustryType__c  FROM AUSF_GenericBuisnessProofData__mdt WHERE Employment_Record_Type__c=:matchingEmploymentDetail.RecordType.Name]){
            if(genericMetadata.Screen_Name__c.containsIgnoreCase('Pass')){
                genericMetadataPass = genericMetadata;
            }
            else{
                genericMetadataRec = genericMetadata;
            }
        }

        return new EmploymentVerificationWrapper(
            (String)applicantId,
            (String)matchingEmploymentDetail.Id,
            (String)matchingEmploymentDetail.Address__c,
            isSuccess,
            isInstant,
            isSuccess?genericMetadataPass:genericMetadataRec
        );
    }


    public class EmploymentVerificationWrapper {
        @AuraEnabled
        public String applicantId;
        @AuraEnabled
        public String employmentDetailId;
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public Boolean isInstant;
        @AuraEnabled
        public AUSF_GenericBuisnessProofData__mdt genericMetadata;
        @AuraEnabled
        public String addressId;
    
        public EmploymentVerificationWrapper(String applicantId, String employmentDetailId,String addressId, Boolean isSuccess, Boolean isInstant,AUSF_GenericBuisnessProofData__mdt genericMetadata) {
            this.applicantId = applicantId;
            this.employmentDetailId = employmentDetailId;
            this.isSuccess = isSuccess;
            this.isInstant = isInstant;
            this.genericMetadata = genericMetadata;
            this.addressId = addressId;
        }
    }

    public class ScreenWrapper{
        @AuraEnabled
        public List<Loan_Application__c> loanApplicationList;
        @AuraEnabled
        public List<Applicant__c> applicantList;
        @AuraEnabled
        public List<Lead_stage__c> leadStageList;
        @AuraEnabled
        public List<Address__c> dedupeAddressList;
        @AuraEnabled
        public List<Integration_Master__c> masterDetails;
        @AuraEnabled
        public List<AUSF_Screen_Custom_Text__mdt> screenCustomTextList;
        @AuraEnabled
        public  List<Generic_UI_Wizard_Mapping_DIY__mdt> wizardDataDIYList;
        @AuraEnabled
        public  List<Generic_UI_Wizard_Mapping_Assisted__mdt> wizardDataAssistedList;
        @AuraEnabled
        public  String errorMessage;
        @AuraEnabled
        public  String profileName;
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public Integration_Checklist__c objIC = NULL;
        @AuraEnabled
        public User objUser {get;set;}
        @AuraEnabled
        public List<Generic_Master__c> lstGenericMaster {get;set;}
        @AuraEnabled
        public Map<String,String> customLabelMap;

        
    }

    public class FileDataWrapper{
        @AuraEnabled
        public String base64;
        @AuraEnabled
        public ContentVersion contentVersionObj;
    }
    public class BackendOperationWrapper{
        @AuraEnabled
        public String loanApplicationId;
        @AuraEnabled
        public String applicantId;
        @AuraEnabled
        public String screenName;
        @AuraEnabled
        public String errorMsg;
        @AuraEnabled
        public Boolean operationComplete;
    }

    public class CustomException extends Exception {}



}