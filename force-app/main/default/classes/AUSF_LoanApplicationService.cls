/**
* @author Murtaza Ali
* @company Salesforce.com
* @description A service class for the Loan Application
* Test Class: AUSF_LoanApplicationService_test
*************************************************************************************
MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0              Murtaza Ali.       21-June-2024             Initial Creation 
*  2.0              Murtaza Ali        25-June-2024             Add Populate Loan Apllication Number Method
*  3.0.             Murtaza Ali        27-June-2024             Add Sourcing channel logic in create loan application method
*  4.0              Mohit M.           27-June-2024             AUPL-605 - assign partner lead value to Loan, Applicant and Address Records
*  5.0              Mohit M.           07-Aug-2024              Add Primary Applicant on Application - createNewLoanApplication
*/

public without sharing class AUSF_LoanApplicationService {
    // Configurable value for the number of days
    public static Integer nDays = Integer.valueOf(Label.AUPL_LastNDaysConfig);
    public static Id recordPLTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Personal_Loan').getRecordTypeId();
    public static Id applicantPrimaryRecordType = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary').getRecordTypeId();
            
    
    public class DedupeResult {
        @auraEnabled
        public String dedupeStatus;
        @auraEnabled
        public String message;
        @auraEnabled
        public Loan_Application__c existingLoanApplication;
    }
    /** 
	* @description Function to check if already a Loan Application Present in the LOS data base 
	* Inputs: Mobile Number of the user.
	* Returns: result whether active loan appliaction is present in the system or not.
    * Jira Story :- APL-88
	*/
    public static Map<String, DedupeResult> localDedupeSearch(List<String> mobileNumbers) {
        Map<String, DedupeResult> results = new Map<String, DedupeResult>();
        try{
            Date nDaysAgo = Date.today().addDays(-nDays);
            // Query to find loan applications with the given mobile numbers
            List<Loan_Application__c> loanApplications = [
                SELECT Id, Name,Last_visited_Page__c,Journey_Mode__c, Branch__c, Lead_reference_number__c, SO_Name__c, SO_Employee_Id__c, Stage__c, Exempt_Duplicate__c, LastModifiedDate, Mobile_Number__c,(SELECT Id,Full_Name__c FROM Applicants__r)
                FROM Loan_Application__c
                WHERE Mobile_Number__c IN :mobileNumbers
                AND LastModifiedDate >= :nDaysAgo
                AND Exempt_Duplicate__c = false
                AND RecordType.DeveloperName in ('Personal_Loan','Business_Loan')
            ];
            // Group loan applications by mobile number
            Map<String, List<Loan_Application__c>> loanAppsByMobile = new Map<String, List<Loan_Application__c>>();
            for (Loan_Application__c loanApp : loanApplications) {
                if (!loanAppsByMobile.containsKey(loanApp.Mobile_Number__c)) {
                    loanAppsByMobile.put(loanApp.Mobile_Number__c, new List<Loan_Application__c>());
                }
                loanAppsByMobile.get(loanApp.Mobile_Number__c).add(loanApp);
            }
            // Process each mobile number
            for (String mobileNumber : mobileNumbers) {
                DedupeResult result = new DedupeResult();
                result.dedupeStatus = '';
                result.message = '';
                Boolean activeApplication = false;
                Boolean cancelledApp = false;
                Boolean rejectApp = false;
                Loan_Application__c rejectLoan;
                if (loanAppsByMobile.containsKey(mobileNumber)) {
                    List<Loan_Application__c> loanApps = loanAppsByMobile.get(mobileNumber);
                    for (Loan_Application__c loanApp : loanApps) {
                        if (loanApp.Stage__c != AUSF_ApexConstants.AUSF_CANCELLED && loanApp.Stage__c != AUSF_ApexConstants.AUSF_REJECT) {
                            if (loanApp.Stage__c == AUSF_ApexConstants.AUSF_DISBURSED) { // Will be consider in Disbursement Stage (Future Sprint AUPL-921 User Stories)
                                result.dedupeStatus = AUSF_ApexConstants.AUSF_DISBURSED;
                                result.existingLoanApplication = loanApp;
                                result.message = '';
                                activeApplication = true;
                            } else {
                                result.dedupeStatus = AUSF_ApexConstants.AUSF_RESUME;
                                result.existingLoanApplication = loanApp;
                                activeApplication = true;
                            }
                            break;
                        } else if (loanApp.Stage__c == AUSF_ApexConstants.AUSF_CANCELLED) {
                            cancelledApp = true;
                        } else {
                            rejectApp = true;
                            rejectLoan = loanApp;
                        }
                    }
                    if (!activeApplication && !rejectApp) {
                        // Allow fresh lead creation
                        result.dedupeStatus = AUSF_ApexConstants.AUSF_NEW;
                    } else if (!activeApplication && rejectLoan != null) {
                        result.dedupeStatus = AUSF_ApexConstants.AUSF_REJECT;
                        result.message = String.format(System.Label.AUSF_LoanRejectionMessage,new String[]{rejectLoan.Applicants__r[0].Full_Name__c,String.valueOf(System.now()),rejectLoan.Branch__c,rejectLoan.Lead_reference_number__c,rejectLoan.SO_Name__c,rejectLoan.SO_Employee_Id__c,rejectLoan.Stage__c});
                        // result.message = 'Lead has been rejected with following params: ' +
                        //     'Name: ' + rejectLoan.Name + ', ' +
                        //     'Branch: ' + rejectLoan.Branch__c + ', ' +
                        //     'Reference Number: ' + rejectLoan.Lead_reference_number__c + ', ' +
                        //     'SO Name: ' + rejectLoan.SO_Name__c + ', ' +
                        //     'SO Employee Id: ' + rejectLoan.SO_Employee_Id__c + ', ' +
                        //     'Stage: ' + rejectLoan.Stage__c;
                        result.existingLoanApplication = rejectLoan;
                    }
                } else {
                    // No duplicate lead found, create a new loan application
                    result.dedupeStatus = AUSF_ApexConstants.AUSF_NEW;
                }

                results.put(mobileNumber, result);
            }
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium);
        }
        return results;
    }
    
    /** 
	* @description Function to create a new loan application record 
	* Inputs: Mobile Number of the user.
	* Returns: new created loan application record instance 
    * Jira Story : APL-88,APL-606
	*/
    public static RecordCreationResult createNewLoanApplication(List<String> mobileNumbers) {
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();
        List<Applicant__c> applicants = new List<Applicant__c>();
        List<Address__c> lstAddress = new List<Address__c>();
        RecordCreationResult recordcreationResult = new RecordCreationResult();
        Map<String,Lead_Stage__c> mapLeadStage = new Map<String,Lead_Stage__c>();
        Map<Id, Loan_Application__c> mapLoanApplication = new Map<Id, Loan_Application__c>();
        List<Loan_Application__c> lstPrimaryApplication = new List<Loan_Application__c>();
        
        try{
            //Id recordTypeId = Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Personal_Loan').getRecordTypeId();
            //Id applicantRecordType = Schema.SObjectType.Applicant__c.getRecordTypeInfosByDeveloperName().get('Primary').getRecordTypeId();
            List<Lead_stage__c> lstLeadStage = getLeadRecordsByMobileNumber(mobileNumbers);
            for (Lead_Stage__c leadStage : lstLeadStage) {
                /* Assign Loan Application */
                Loan_Application__c newLoanApp = initLoanApplication (leadStage, null, recordPLTypeId);
                mapLeadStage.put(leadStage.Name,leadStage);
                loanApps.add(newLoanApp);
                /*
                Loan_Application__c newLoanApp = new Loan_Application__c();
                newLoanApp.Mobile_Number__c = leadStage.Name;
                newLoanApp.Loan_Processing_Consent__c = true;
                newLoanApp.Loan_Processing_Consent_Captured_At__c = System.now();
                newLoanApp.Stage__c = AUSF_ApexConstants.AUSF_LEAD;
                newLoanApp.RecordTypeId = recordTypeId;
                newLoanApp.Sourcing_Channel__c = leadStage.Sourcing_Channel__c;
                newLoanApp.Sourcing_Channel_Name__c = leadStage.Sourcing_Channel_Name__c;
                mapLeadStage.put(leadStage.Name,leadStage);
                loanApps.add(newLoanApp);
                */
            }
            insert loanApps;
            recordcreationResult.newLoanApplications = loanApps;
            for(Loan_Application__c loanApp: loanApps){
                RecordInitWrapper objInitWrap = new RecordInitWrapper();
                objInitWrap.objLeadStage = mapLeadStage.get(loanApp.Mobile_Number__c);
                /* Assign Applicant values */
                objInitWrap.objLoan = loanApp;
                Applicant__c applicant = initApplicantRecord (JSON.serialize(objInitWrap), applicantPrimaryRecordType);
                applicants.add(applicant);
                mapLoanApplication.put(loanApp.Id, loanApp);
                /*
                Lead_Stage__c leadStage = mapLeadStage.get(loanApp.Mobile_Number__c);
                Applicant__c applicant = new Applicant__c();
                applicant.Loan_Application__c = loanApp.Id;
                applicant.Mobile_Number__c = loanApp.Mobile_Number__c;
                applicant.RecordTypeId = applicantRecordType;
                applicant.Electricity_Bill_Consent_Date_Time__c = leadStage.Electricity_Bill_Consent_Date_Time__c;
                applicant.CART_Consent_Date_Time__c = leadStage.CART_Consent_Date_Time__c;
                applicant.Salary_Slip_Consent_Date_Time__c = leadStage.Salary_Slip_Consent_Date_Time__c;
                applicant.GST_Consent_Date_Time__c = leadStage.GST_Consent_Date_Time__c;
                applicant.GST_Authentication_Consent_Date_time__c = leadStage.GST_Authentication_Consent_Date_time__c;
                applicant.Business_Proof_Consent_Date_Time__c = leadStage.Business_Proof_Consent_Date_Time__c;
                applicants.add(applicant);
                */
            }
            insert applicants;
            recordcreationResult.newApplicants = applicants;
            /* Check and create Address records */
            for (Applicant__c objApplicant : applicants) {
                RecordInitWrapper objInitWrap = new RecordInitWrapper();
                objInitWrap.objLeadStage = mapLeadStage.get(objApplicant.Mobile_Number__c);
                objInitWrap.objLoan = mapLoanApplication.get(objApplicant.Loan_Application__c);
                objInitWrap.objApplicant = objApplicant;
                lstAddress  = initAddressRecord (JSON.serialize(objInitWrap), lstAddress);
            }
            if (lstAddress.size()>0) {
                insert lstAddress;
            }
            // Update Primary Applicant on Loan Application
            for (Applicant__c objApplicant : applicants) {
                Loan_Application__c objUpdateApplication = new Loan_Application__c();
                objUpdateApplication.Id = objApplicant.Loan_Application__c;
                objUpdateApplication.Primary_Applicant__c = objApplicant.Id;
                lstPrimaryApplication.add(objUpdateApplication);
            }
            update lstPrimaryApplication;
            System.debug('New loan application created with mobile number: ' + mobileNumbers);
            sendWelcomeMessage(applicants);
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium);
        }
        return recordcreationResult;
        
    }

    /** 
	* @description Function to populate Loan Application Number with the required format after claim offer
	* Inputs: List of Applicants records
	* Returns: void
    * Jira Story : APL-700
	*/
    public static void populateLoanApplicationNumber(List<Id> applicants) {
        try{
            // Query Applicants with related Loan Applications and Branch (Account)
            List<Applicant__c> applicantsWithLoanApps = [
            SELECT Id, Employment_Type__c, Loan_Application__c,
            Loan_Application__r.Name,
            Loan_Application__r.Branch__c, Loan_Application__r.Lead_reference_number__c,Loan_Application__r.Branch__r.City__c
            FROM Applicant__c
            WHERE Id IN :applicants
            ];
            // Prepare list to update Loan Applications
            List<Loan_Application__c> loanApplicationsToUpdate = new List<Loan_Application__c>();
            // Iterate over applicants and populate Loan Application Number
            for (Applicant__c applicant : applicantsWithLoanApps) {
                Loan_Application__c loanApp = applicant.Loan_Application__r;
                if (loanApp != null) {
                    String employmentTypePrefix = AUSF_ApexConstants.AUSF_EMPLOYMENTPREFIX_BL; // Default to 'BL'
                    if (applicant.Employment_Type__c != null && applicant.Employment_Type__c.containsIgnoreCase(AUSF_ApexConstants.AUSF_SALARIED)) {
                        employmentTypePrefix = AUSF_ApexConstants.AUSF_EMPLOYMENTPREFIX_PL;
                    }
                    String city = loanApp.Branch__r.City__c != null ? loanApp.Branch__r.City__c : '';
                    String cityPrefix = city.length() >= 3 ? city.substring(0, 3).toUpperCase() : city.toUpperCase();
                    String autoNumber = loanApp.Lead_reference_number__c != null ? loanApp.Lead_reference_number__c.substring(5) : '';
                    // Construct the Loan Application Number
                    String loanAppNumber = employmentTypePrefix + cityPrefix + '-' + autoNumber;
                    // Set the Loan Application Number
                    loanApp.Name = loanAppNumber;
                    // Add to the list for update
                    loanApplicationsToUpdate.add(loanApp);
                }
            }
            // Update Loan Applications
            if (!loanApplicationsToUpdate.isEmpty()) {
                update loanApplicationsToUpdate;
            }
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium);
        }
    }
    
    /** 
	* @description Function to reject the Loan if the unsecured laon is present
	* Inputs: Applicant Id
	* Returns: Return is Lead reject
    * Jira Story : APL-808
	*/
    public static Boolean aditionalDedupeCheck(String applicantId) {
        Boolean isLoanReject = false;
        try {
            Integration_Checklist__c ic = [SELECT Id, Loan_Application__c, Applicant__c, Applicant__r.Loan_Application__c, Name, Response__c, Status__c, Applicant__r.Mobile_Number__c, Applicant__r.PAN__c, Applicant__r.Loan_Application__r.Employment_Type_Formula__c, Applicant__r.Loan_Application__r.Has_PA_Offer__c  
                                           FROM Integration_Checklist__c 
                                           WHERE Integration_Master__r.Name = :AUSF_ApexConstants.AUSF_CustomerDedupe_INTEGRATION_MASTER 
                                           AND Status__c = :AUSF_ApexConstants.AUSF_IC_COMPLETED 
                                           AND Applicant__c = :applicantId 
                                           ORDER BY CreatedDate DESC LIMIT 1];
            
            String response = ic.Response__c;
            String mobileNumber = ic.Applicant__r.Mobile_Number__c;
            String pan = ic.Applicant__r.PAN__c;
            Boolean hasPAOffer = ic.Applicant__r.Loan_Application__r.Has_PA_Offer__c;
            String employmentType = ic.Applicant__r.Loan_Application__r.Employment_Type_Formula__c;
            // Query custom metadata
            List<Loan_Product_Metadata__mdt> productMetadata = [SELECT Product_Code__c, Vintage_In_Month__c, Non_Pre_approved_Salaried__c, Non_Pre_approved_Self_Employed__c, Pre_Approved_BL__c, Pre_approved_First_Loan__c, Pre_approved_PL_Second_Loan__c 
                                                                FROM Loan_Product_Metadata__mdt];
            
            Set<String> seNonPAExcludedProductsSet = new Set<String>();
            Set<String> salariedPA1stOfferExcludedProductsSet = new Set<String>();
            Set<String> salariedPA2ndOfferExcludedProductsSet = new Set<String>();
            Set<String> salariedNonPAExcludedProductsSet = new Set<String>();
            Set<String> sePAExcludedProductsSet = new Set<String>();
            
            // Maps for product codes and vintage values
            Map<String, Integer> seNonPAExcludedProductsWithVintageMap = new Map<String, Integer>();
            Map<String, Integer> salariedPA1stOfferExcludedProductsWithVintageMap = new Map<String, Integer>();
            Map<String, Integer> salariedPA2ndOfferExcludedProductsWithVintageMap = new Map<String, Integer>();
            Map<String, Integer> salariedNonPAExcludedProductsWithVintageMap = new Map<String, Integer>();
            Map<String, Integer> sePAExcludedProductsWithVintageMap = new Map<String, Integer>();
            
            for (Loan_Product_Metadata__mdt metadata : productMetadata) {
                // Handle SE Non PA Excluded Products With Vintage
                if (metadata.Non_Pre_approved_Self_Employed__c) {
                    if (metadata.Vintage_In_Month__c != null) {
                        seNonPAExcludedProductsWithVintageMap.put(metadata.Product_Code__c, Integer.valueOf(metadata.Vintage_In_Month__c));
                    } else {
                        seNonPAExcludedProductsSet.add(metadata.Product_Code__c);
                    }
                }
                // Handle Salaried Non PA Excluded Products
                if (metadata.Non_Pre_approved_Salaried__c) {
                    if (metadata.Vintage_In_Month__c != null) {
                        salariedNonPAExcludedProductsWithVintageMap.put(metadata.Product_Code__c, Integer.valueOf(metadata.Vintage_In_Month__c));
                    } else {
                        salariedNonPAExcludedProductsSet.add(metadata.Product_Code__c);
                    }
                }
                // Handle Salaried PA 1st Offer Excluded Products
                if (metadata.Pre_approved_First_Loan__c) {
                    if (metadata.Vintage_In_Month__c != null) {
                        salariedPA1stOfferExcludedProductsWithVintageMap.put(metadata.Product_Code__c, Integer.valueOf(metadata.Vintage_In_Month__c));
                    } else {
                        salariedPA1stOfferExcludedProductsSet.add(metadata.Product_Code__c);
                    }
                }
                // Handle Salaried PA 2nd Offer Excluded Products
                if (metadata.Pre_approved_PL_Second_Loan__c) {
                    if (metadata.Vintage_In_Month__c != null) {
                        salariedPA2ndOfferExcludedProductsWithVintageMap.put(metadata.Product_Code__c, Integer.valueOf(metadata.Vintage_In_Month__c));
                    } else {
                        salariedPA2ndOfferExcludedProductsSet.add(metadata.Product_Code__c);
                    }
                }
                // Handle SE PA Excluded Products
                if (metadata.Pre_Approved_BL__c) {
                    if (metadata.Vintage_In_Month__c != null) {
                        sePAExcludedProductsWithVintageMap.put(metadata.Product_Code__c, Integer.valueOf(metadata.Vintage_In_Month__c));
                    } else {
                        sePAExcludedProductsSet.add(metadata.Product_Code__c);
                    }
                }
            }
            
            
            String rejectReason = '';
            AUSF_CustomerDedupeResponseWrapper res = (AUSF_CustomerDedupeResponseWrapper) JSON.deserialize(response, AUSF_CustomerDedupeResponseWrapper.class);
            Loan_Application__c loanToUpdate = new Loan_Application__c(Id = ic.applicant__r.Loan_Application__c);
            
            for (AUSF_CustomerDedupeResponseWrapper.MatchFound resRec : res.MatchFound) {
                if (resRec.CustomerResponse.CustomerBasicInquiry.MobileNumber == mobileNumber && resRec.CustomerResponse.CustomerBasicInquiry.PAN == pan) {
                    for (AUSF_CustomerDedupeResponseWrapper.CustomerAccount account : resRec.AccountDetails.CustomerAccount) {
                        if (account.ModuleCode.startsWith('L') && (account.CurrentStatus == '8' || account.CurrentStatus == '6')) {
                            if (employmentType.equalsIgnoreCase('Self Employed') && !hasPAOffer) {
                                // Check SE Non PA Excluded Products With Vintage
                                if (seNonPAExcludedProductsWithVintageMap.containsKey(account.ProductCode)) {
                                    Integer vintage = Date.today().monthsBetween(Date.valueOf(account.DateAccountOpen));
                                    if (vintage < seNonPAExcludedProductsWithVintageMap.get(account.ProductCode)) {
                                        isLoanReject = true;
                                        rejectReason = 'P220'; // Update with actual reason
                                    }
                                }
                                // Check SE Non PA Excluded Products
                                if (seNonPAExcludedProductsSet.contains(account.ProductCode)) {
                                    isLoanReject = true;
                                    rejectReason = 'P220'; // Update with actual reason
                                }
                            } else if (employmentType.equalsIgnoreCase('Salaried') && hasPAOffer) {
                                // Check Salaried PA 1st Offer Excluded Products With Vintage
                                if (salariedPA1stOfferExcludedProductsWithVintageMap.containsKey(account.ProductCode)) {
                                    Integer vintage = Date.today().monthsBetween(Date.valueOf(account.DateAccountOpen));
                                    if (vintage < salariedPA1stOfferExcludedProductsWithVintageMap.get(account.ProductCode)) {
                                        isLoanReject = true;
                                        rejectReason = 'P220'; // Update with actual reason
                                    }
                                }
                                // Check Salaried PA 1st Offer Excluded Products
                                if (salariedPA1stOfferExcludedProductsSet.contains(account.ProductCode)) {
                                    isLoanReject = true;
                                    rejectReason = 'P220'; // Update with actual reason
                                }
                                // Check Salaried PA 2nd Offer Excluded Products With Vintage
                                if (salariedPA2ndOfferExcludedProductsWithVintageMap.containsKey(account.ProductCode)) {
                                    Integer vintage = Date.today().monthsBetween(Date.valueOf(account.DateAccountOpen));
                                    if (vintage < salariedPA2ndOfferExcludedProductsWithVintageMap.get(account.ProductCode)) {
                                        isLoanReject = true;
                                        rejectReason = 'P220'; // Update with actual reason
                                    }
                                }
                                // Check Salaried PA 2nd Offer Excluded Products
                                if (salariedPA2ndOfferExcludedProductsSet.contains(account.ProductCode)) {
                                    isLoanReject = true;
                                    rejectReason = 'P220'; // Update with actual reason
                                }
                            } else if (employmentType.equalsIgnoreCase('Salaried') && !hasPAOffer) {
                                // Check Salaried Non PA Excluded Products With Vintage
                                if (salariedNonPAExcludedProductsWithVintageMap.containsKey(account.ProductCode)) {
                                    Integer vintage = Date.today().monthsBetween(Date.valueOf(account.DateAccountOpen));
                                    if (vintage < salariedNonPAExcludedProductsWithVintageMap.get(account.ProductCode)) {
                                        isLoanReject = true;
                                        rejectReason = 'P220'; // Update with actual reason
                                    }
                                }
                                // Check Salaried Non PA Excluded Products
                                if (salariedNonPAExcludedProductsSet.contains(account.ProductCode)) {
                                    isLoanReject = true;
                                    rejectReason = 'P220'; // Update with actual reason
                                }
                            }else if (employmentType.equalsIgnoreCase('Self Employed') && hasPAOffer) {
                                // Check SE Non PA Excluded Products With Vintage
                                if (sePAExcludedProductsWithVintageMap.containsKey(account.ProductCode)) {
                                    Integer vintage = Date.today().monthsBetween(Date.valueOf(account.DateAccountOpen));
                                    if (vintage < sePAExcludedProductsWithVintageMap.get(account.ProductCode)) {
                                        isLoanReject = true;
                                        rejectReason = 'P220'; // Update with actual reason
                                    }
                                }
                                // Check SE Non PA Excluded Products
                                if (sePAExcludedProductsSet.contains(account.ProductCode)) {
                                    isLoanReject = true;
                                    rejectReason = 'P220'; // Update with actual reason
                                }
                            }
                        }
                    }
                }
            }
            
            // Update loan applications based on the rejection flag
            if (isLoanReject) {
                loanToUpdate.Stage__c = 'Reject';
                loanToUpdate.Reject_Reason__c  = 'Dedupe check';
                loanToUpdate.Reject_Sub_Reason__c  = rejectReason;
                // Update loan applications
                update loanToUpdate;
            }
            
            
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium);
        }
        return isLoanReject;
    }
    
    /** 
	* @description Function to validate PA offer for seleried and self employeed
	* Inputs: Loan Application Id
	* Returns: Return is Salaried or delf employeed
    * Jira Story : APL-849
	*/
    public static Boolean validatePAOfferProductType(Id loanApplicationId) {
        // Query to get the Pre_Approved_Offer__c records related to the given Loan_Application__c record
        List<Pre_Approved_Offer__c> preApprovedOffers = [
            SELECT Product_Type__c, OfferIsActive__c
            FROM Pre_Approved_Offer__c
            WHERE Loan_Application__c = :loanApplicationId
            AND OfferIsActive__c = true
        ];
        
        // Iterate through the list of Pre_Approved_Offer__c records
        for (Pre_Approved_Offer__c offer : preApprovedOffers) {
            // Check the Product_Type__c field and return the appropriate boolean value
            if (offer.Product_Type__c == AUSF_ApexConstants.AUSF_EMPLOYMENTPREFIX_PL) {
                return true;
            } else if (offer.Product_Type__c == AUSF_ApexConstants.AUSF_EMPLOYMENTPREFIX_BL) {
                return false;
            }
        }
        
        // Default return value if no matching records are found
        return false;
    }

    /** 
	* @description Function to validate Employment Type
	* Inputs: Applicant Id
	* Returns: Return Self Employeed Professional or Non Professional
    * Jira Story : APL-139
	*/
    public static String checkSelfEmploymentType(Id applicantId) {
        // Query to get the Pre_Approved_Offer__c records related to the given Loan_Application__c record
        List<Applicant__c> applicants = [
            SELECT Id,Employment_Type__c
            FROM Applicant__c
            WHERE Id = :applicantId
        ];
        
        if(applicants.size()>0){
            if(applicants[0].Employment_Type__c=='Self Employed Professional'){
                return 'SEP';
            }
            else if(applicants[0].Employment_Type__c=='Self Employed Non-Professional'){
                return 'SENP';
            }
        }
        
        // Default return value if no matching records are found
        return '';
    }

     /** 
	* @description      : Method 
	* param1            : List of Applicant records
	* Returns           : void
    * Jira Story        : APL-906
	*/
    public static void sendWelcomeMessage(List<Applicant__c> applicants) {
        for(Applicant__c applicantRecord: applicants){
            AUSF_NotificationController.sendAllNotification(null, null, applicantRecord.Id, applicantRecord.Loan_Application__c, 'Application_Generation', null);
        }
    }
    
    /*
    @description    - AUPL-605 Query on Lead_Stage__c
    @param1         - mobileNumbers - List of mobile numbers
    @return         - List of Lead_Stage__c records
    */
    private static List<Lead_Stage__c> getLeadRecordsByMobileNumber (List<String> mobileNumbers) {
        List<Lead_Stage__c> lstLeadStage = new List<Lead_Stage__c>();
        lstLeadStage = [SELECT Id,Name,Sourcing_Channel__c,Sourcing_Channel_Name__c,Electricity_Bill_Consent_Date_Time__c,
            CART_Consent_Date_Time__c,Salary_Slip_Consent_Date_Time__c,GST_Consent_Date_Time__c, 
            GST_Authentication_Consent_Date_time__c,Business_Proof_Consent_Date_Time__c, Campaign_Id__c, Campaign_Medium__c, 
            Lead_External_Id__c, SF_External_Lead_Id__c, Lead_Number__c, UTM_Campaign__c, UTM_Card__c, UTM_Content__c, UTM_Medium__c, 
            UTM_Source__c, UTM_Term__c, Campaign_Name__c,  
            Date_of_Birth__c, First_Name__c, Middle_Name__c, Last_Name__c, Gender__c, PAN_Number__c, Email_Id__c, Lead_Customer_Id__c, 
            Communication_Address_City__c, Communication_Address_Line_1__c, Communication_Address_Line_2__c, 
            Communication_Address_Line_3__c, Communication_Address_Pincode__c, Permanent_Address_City__c, 
            Permanent_Address_Line_1__c, Permanent_Address_Line_2__c, Permanent_Address_Line_3__c, 
            Permanent_Address_Pincode__c, Permanent_Address_State__c, Communication_Address_State__c 
            FROM Lead_Stage__c Where Name IN:mobileNumbers];
        return lstLeadStage;
    }

    /*
    @description    - AUPL-605 set Loan application values lead record
    @param1         - leadStage - Lead_Stage__c record
    @param2         - newLoanApp - Loan_Application__c record
    @param3         - recordPLTypeId - Loan RecordType Id
    @return         - Loan_Application__c
    */
    private static Loan_Application__c initLoanApplication (Lead_Stage__c leadStage, Loan_Application__c newLoanApp, Id recordPLTypeId) {
        recordPLTypeId = recordPLTypeId == NULL ? Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Personal_Loan').getRecordTypeId() : recordPLTypeId;
        newLoanApp = newLoanApp == NULL ? new Loan_Application__c() : newLoanApp;
        newLoanApp.Mobile_Number__c = leadStage.Name;
        newLoanApp.Loan_Processing_Consent__c = true;
        newLoanApp.Loan_Processing_Consent_Captured_At__c = System.now();
        newLoanApp.Stage__c = AUSF_ApexConstants.AUSF_CUSTOMER_ONBOARDING;
        newLoanApp.RecordTypeId = recordPLTypeId;
        newLoanApp.Sourcing_Channel__c = leadStage.Sourcing_Channel__c;
        newLoanApp.Sourcing_Channel_Name__c = leadStage.Sourcing_Channel_Name__c;
        newLoanApp.Campaign_Id__c = leadStage.Campaign_Id__c;
        newLoanApp.Campaign_Medium__c = leadStage.UTM_Medium__c;
        newLoanApp.Campaign_Name__c = leadStage.Campaign_Name__c;
        newLoanApp.SF_External_Lead_Id__c = leadStage.SF_External_Lead_Id__c;
        newLoanApp.UTM_Campaign__c = leadStage.UTM_Campaign__c;
        newLoanApp.UTM_Card__c = leadStage.UTM_Card__c;
        newLoanApp.UTM_Content__c = leadStage.UTM_Content__c;
        newLoanApp.UTM_Source__c = leadStage.UTM_Source__c;
        newLoanApp.UTM_Term__c = leadStage.UTM_Term__c;
        newLoanApp.Lead_External_Id__c = leadStage.Lead_External_Id__c;
        return newLoanApp;
    }

    /*
    @description    - AUPL-605 set Applicant values from Loan and Lead Record
    @param1         - objRecordInit - Stringify Wrapper
    @param2         - applicantPrimaryRecordType -  Applicant RecordType Id
    @return         - Applicant__c
    */
    private static Applicant__c initApplicantRecord (String objRecordInit, Id applicantPrimaryRecordType) {
        applicantPrimaryRecordType = applicantPrimaryRecordType == NULL ? Schema.SObjectType.Loan_Application__c.getRecordTypeInfosByDeveloperName().get('Personal_Loan').getRecordTypeId() : applicantPrimaryRecordType;
        
        RecordInitWrapper objInitWrap = (RecordInitWrapper)JSON.deserialize(objRecordInit, RecordInitWrapper.class);
        
        Applicant__c applicant = objInitWrap.objApplicant == NULL ? new Applicant__c() : objInitWrap.objApplicant;
        Loan_Application__c loanApp = objInitWrap.objLoan;
        Lead_Stage__c leadStage = objInitWrap.objLeadStage;
        applicant.Loan_Application__c = loanApp.Id;
        applicant.Mobile_Number__c = loanApp.Mobile_Number__c;
        applicant.RecordTypeId = applicantPrimaryRecordType;
        applicant.Electricity_Bill_Consent_Date_Time__c = leadStage.Electricity_Bill_Consent_Date_Time__c;
        applicant.CART_Consent_Date_Time__c = leadStage.CART_Consent_Date_Time__c;
        applicant.Salary_Slip_Consent_Date_Time__c = leadStage.Salary_Slip_Consent_Date_Time__c;
        applicant.GST_Consent_Date_Time__c = leadStage.GST_Consent_Date_Time__c;
        applicant.GST_Authentication_Consent_Date_time__c = leadStage.GST_Authentication_Consent_Date_time__c;
        applicant.Business_Proof_Consent_Date_Time__c = leadStage.Business_Proof_Consent_Date_Time__c;
        applicant.Birth_Date__c = leadStage.Date_of_Birth__c;
        applicant.First_Name__c = leadStage.First_Name__c;
        applicant.Middle_Name__c = leadStage.Middle_Name__c;
        applicant.Last_Name__c = leadStage.Last_Name__c;
        applicant.Personal_Email_ID__c = leadStage.Email_Id__c;
        applicant.Gender__c = leadStage.Gender__c;
        applicant.PAN__c = leadStage.PAN_Number__c;
        applicant.CIF__c = leadStage.Lead_Customer_Id__c;
        return applicant;
    }

    /*
    @description    - AUPL-605 set Address values from Lead Record
    @param1         - objRecordInit - Stringify Wrapper
    @param2         - lstAddress -  List of Address
    @return         - List<Address__c>
    */
    private static List<Address__c> initAddressRecord (String objRecordInit, List<Address__c> lstAddress) {
        lstAddress = lstAddress == NULL ? new List<Address__c> () : lstAddress;
        RecordInitWrapper objInitWrap = (RecordInitWrapper)JSON.deserialize(objRecordInit, RecordInitWrapper.class);
        Applicant__c applicant = objInitWrap.objApplicant;
        Loan_Application__c loanApp = objInitWrap.objLoan;
        Lead_Stage__c leadStage = objInitWrap.objLeadStage;
        /* Check for Permanent Address */
        if (String.isNotBlank(leadStage.Permanent_Address_Line_1__c) && 
            String.isNotBlank(leadStage.Permanent_Address_Pincode__c)
        ) {
            Address__c objAddress = new Address__c();
            objAddress.Address_Type__c = 'Permanent';
            objAddress.Address_Line_1__c = leadStage.Permanent_Address_Line_1__c;
            objAddress.Address_Line_2__c = leadStage.Permanent_Address_Line_2__c;
            objAddress.Address_Line_3__c = leadStage.Permanent_Address_Line_3__c;
            objAddress.City__c = leadStage.Permanent_Address_City__c;
            objAddress.State__c = leadStage.Permanent_Address_State__c;
            objAddress.Pincode__c = leadStage.Permanent_Address_Pincode__c;
            objAddress.Applicant__c = applicant.Id;
            lstAddress.add(objAddress);
        }
        /* Check for Current Address */
        if (String.isNotBlank(leadStage.Communication_Address_Line_1__c) && 
            String.isNotBlank(leadStage.Communication_Address_Pincode__c)
        ) {
            Address__c objAddress = new Address__c();
            objAddress.Address_Type__c = 'Current';
            objAddress.Address_Line_1__c = leadStage.Communication_Address_Line_1__c;
            objAddress.Address_Line_2__c = leadStage.Communication_Address_Line_2__c;
            objAddress.Address_Line_3__c = leadStage.Communication_Address_Line_3__c;
            objAddress.City__c = leadStage.Communication_Address_City__c;
            objAddress.State__c = leadStage.Communication_Address_State__c;
            objAddress.Pincode__c = leadStage.Communication_Address_Pincode__c;
            objAddress.Applicant__c = applicant.Id;
            lstAddress.add(objAddress);
        }
        return lstAddress;
    }

    public class RecordInitWrapper {
        public Lead_Stage__c objLeadStage {get;set;}
        public Loan_Application__c objLoan {get;set;}
        public Applicant__c objApplicant {get;set;}
        public Address__c objAddress {get;set;}
    }

    public class RecordCreationResult {
        @AuraEnabled
        public List<Loan_Application__c> newLoanApplications;
        @AuraEnabled
        public List<Applicant__c> newApplicants;
    }
}