/**
 * @author              : Amit Mishra
 * @date                : 30-June-2024
 * @description         : BRE API Utility methods
 * Test Class           : 
 * History              :
 * ===========================================================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ===========================================================================================================
 * 29-June-2024 	Amit Mishra 		Initial Version
**/
public without sharing class AUSF_INT_BRE_Utility {
    /*
    @description    : checkjourney type of Applicant
    @param1         : loanApp - Loan Application Object
    @param2         : applicant - Applicant Object
    @return         : String of ENUM for journey type
    */
    public static String checkjourney(Loan_Application__c loanApp, Applicant__c applicant){
        if(applicant.NTB_ETB__c == 'ETB'){
            if(loanApp.Pre_Approved_Offers__r != NULL && !loanApp.Pre_Approved_Offers__r.isEmpty()){
                return 'ETB_PA';
            }
            return 'ETB_NPA';
        }
        else if(applicant.NTB_ETB__c == 'NTB'){
            return applicant.NTB_ETB__c;
        }
        return NULL;
    }
    /*
    @description    : format Date and Time type in required format 
    @param1         : datevalue - DateTime value need to format
    @param2         : formatName - Integer value to select format type
    @return         : string - formatted (in String) DateTime value 
    */
    public static String formatDateTime(DateTime datevalue, Integer formatName){
        String formattedDate;
        if(formatName == 1){
            formattedDate = datevalue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'', 'UTC');//2024-05-25T06:32:36.163Z //yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
        }
        else if(formatName == 2){
            formattedDate = datevalue.format('MMM dd, yyyy hh:mm:ss.SSS a z', 'IST');//Jul 11, 2024 12:50:07.961 PM IST
        }
        else{
            formattedDate = String.valueOf(datevalue);
        }
        return formattedDate;
    }
    /*
    @description    : getLoanData - querry loan Application record
    @param1         : loanId - Loan application Id
    @return         : List<Loan_Application__c> - Loan application 
    */
    public static List<Loan_Application__c> getLoanData(String loanId){
        List<Loan_Application__c> loanApp = new List<Loan_Application__c>();
        loanApp = [SELECT Id, Name, CreatedDate, Stage__c, Sourcing_Channel__c, Loan_Amount__c, Mobile_Number__c, BRE_Knockout_Application_Counter__c,
                Branch__r.Account_Code__c, Branch__r.Bank_Name__c, Branch__r.Name, Branch__r.Hub_Code__c, Branch__r.Region_Code__c,
                RecordType.DeveloperName,
                (SELECT Id, Avail__c FROM Pre_Approved_Offers__r)
                FROM Loan_Application__c
                WHERE Id =:loanId
                LIMIT 1];
        if(loanApp.isEmpty()){
            throw new AuraHandledException(AUSF_ApexConstants.INVALID_LOAN_APPLICATION_ID);
        }
        return loanApp;
    }
    /*
    @description    : getApplicantData - querry child Applicant records using loan Id
    @param1         : loanId - Loan application Id
    @return         : List<Applicant__c> - list of applicant
    */
    public static List<Applicant__c> getApplicantData(String LoanId){
        List<Applicant__c> applicantList = new List<Applicant__c>();
        applicantList = [SELECT Id, Name, NTB_ETB__c, Full_Name__c, Gender__c, Marital_Status__c, PAN__c, Is_PAN_Verified__c, CFR_Check__c, AML_verified__c, Employment_Type__c, Birth_Date__c, Age__c, Nationality__c, Employee__c, Business_Vintage_Years__c, Educational_Qualification__c, 
             toLabel(KYC_Type__c), 
             RecordType.DeveloperName,
                (SELECT Id, Pincode__c, Address_Type__c, City__c, State__c, Residence_Ownership_Type__c, Working_Area__c, Address_Line_1__c	, Address_Line_2__c, Address_Line_3__c
                FROM Addresses__r),
                (SELECT Id, Registered_Business_name__c, Is_Work_Email_Id_Verified__c , Is_EPFO_Verified__c, Current_Employment_Duration_Years__c, Current_Employment_Duration_Months__c, Total_Employment_Duration_Years__c, Total_Employment_Duration_Months__c
                
                FROM Employment_Details__r LIMIT 1)
             FROM Applicant__c
             WHERE Loan_Application__c =:LoanId
             LIMIT 1];
        if(applicantList.isEmpty()){
            throw new AuraHandledException(AUSF_ApexConstants.APPLICANT_NOT_FOUND_FOR_LOAN_APP);
        }
        return applicantList;
    }
    /*
    @description    : getLocationMaster - querry Metro/Non Metro from Location Master
    @param1         : applicant - Applicant__c object
    @return         : List<Location_Master__c> - List of Location Master
    */
    public static List<Location_Master__c> getLocationMaster(Applicant__c applicant){
        String pincode;
        for(Address__c address : applicant.Addresses__r){
            if(address.Address_Type__c == AUSF_ApexConstants.CURRENT_ADDRESS_TYPE){
                pincode = address.Pincode__c;
                break;
            }
        }
        List<Location_Master__c> locMaster = [SELECT Id, CityType__c, Taluka__c, Working_Area__c, Area_Type__c
        FROM Location_Master__c
        WHERE Name =:pincode
        LIMIT 1];
        if(!locMaster.isEmpty()){
            return locMaster;
        }
        return new List<Location_Master__c>();
    }
    /*
    @description    : handlePlatformEvent - create and publish plateform event
    @param1         : callType - Type of BRE callout
    @param2         : requestBody - request body of BRE api
    @param3         : intReqRecordId - Integration checklist request id or recordId when request Id not exist
    */
    public static void handlePlatformEvent(String callType, String requestBody , String intReqRecordId){
        BRE_Integration_Event__e brePlatformEvent = new BRE_Integration_Event__e();
        brePlatformEvent.Service_Name__c = AUSF_ApexConstants.FICO_BRE_KNOCKOUT_INTEGRATION_MASTER;
        brePlatformEvent.Request_Body__c = requestBody; 
        brePlatformEvent.Integration_Request_Id__c = intReqRecordId ;
        brePlatformEvent.BRE_Call_Type__c = callType;
        Database.SaveResult publishrResult = EventBus.publish(brePlatformEvent);
    }
}