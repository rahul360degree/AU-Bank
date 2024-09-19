/**
 * @author              : Amit Mishra
 * @date                : 03-July-2024
 * @description         : BRE (Business Rule Engine FICO) KNOCKOUT api callout controller
 * Test Class           : AUSF_INT_BRE_Test
 * History              :
 * ===========================================================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ===========================================================================================================
 * 03-July-2024 	Amit Mishra 		Initial Version
 * 05-July-2024 	Amit Mishra 		Modified getApplicantData() and getLoanData() method added new fields in querry
**/
public without sharing class AUSF_INT_BRE_Controller {

    public class CustomException extends Exception {}
    /*
    @description    : getBreResponse - main method to genrate request and publish bre Integration platform event
    @author         : Amit Mishra
    @date           : 03-July-2024
    @param1         : loanId - Loan Application Id
    @param2         : callType - Type of BRE callout
    @return         : AUSF_INT_BRE_ResponseWrapper - BRE response wrapper
    */
    @AuraEnabled
    public static AUSF_INT_BRE_ResponseWrapper getBreResponse(String loanId, String callType,string icRecordId){
        AUSF_INT_BRE_ResponseWrapper controllerResponseWrapper = new AUSF_INT_BRE_ResponseWrapper();
        Boolean isCheckListNameRequired = false;
        String checklistId = '';
        Boolean runPlatformEvent = false;//if platform event used mark true
        try{
            //validating input parameters
            if(String.isBlank(loanId)){
                throw new CustomException(AUSF_ApexConstants.LOAN_APPLICATION_ID_REQUIRED);
            }
            if(String.isBlank(callType)){
                throw new CustomException(AUSF_ApexConstants.BRE_CALL_TYPE_REQUIRED);
            }
            //Integration Master query & validation
            Integration_Master__c integrationMasterRecord = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.FICO_BRE_KNOCKOUT_INTEGRATION_MASTER);
            /*if(integrationMasterRecord == null || integrationMasterRecord.Id == null){
                throw new CustomException(AUSF_ApexConstants.INTEGRATION_MASTER_MISSING);
            }*/
            List<Integration_Checklist__c> lstCheckListRecords = [SELECT Id, Request_Id__c FROM Integration_Checklist__c where Id =: icRecordId];
            //creting Integration Checklist 
            Integration_Checklist__c checkListRecord = new Integration_Checklist__c();
            checkListRecord.Integration_Master__c = integrationMasterRecord.Id;
            checkListRecord.Loan_Application__c = loanId;
            checkListRecord.Id = lstCheckListRecords.size() > 0 ? lstCheckListRecords[0].Id : NULL;
            checkListRecord.Request_Id__c = lstCheckListRecords.size() > 0 && String.isNotBlank(lstCheckListRecords[0].Request_Id__c) ? lstCheckListRecords[0].Request_Id__c : AUSF_INT_IntegrationUtility.getReferenceId();
            //Creating genric request wrapper
            AUSF_INT_IntegrationUtility.InputWrapper inputReqWrapper = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputReqWrapper.integrationMasterRecord = integrationMasterRecord;
            inputReqWrapper.loanRecord = getLoanData(loanId)[0];
            inputReqWrapper.applicantRecord = getApplicantData(loanId)[0];
            inputReqWrapper.integrationChecklistRecord = checkListRecord;
            inputReqWrapper.dynamicInputs = new Map<String, Object>{AUSF_INT_BRE_Constants.BRE_CALLTYPE => callType};
            inputReqWrapper.dynamicInputs.put(AUSF_INT_BRE_Constants.BRE_CITY_TYPE,getLocationMaster(inputReqWrapper.applicantRecord));
            inputReqWrapper.dynamicInputs.put(AUSF_INT_BRE_Constants.BRE_REFERENCE_ID,checkListRecord.Request_Id__c);

            //Creating Integration Utility instance for generting  main request
            AUSF_INT_IntegrationUtility intUtility = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestData = intUtility.constructRequest(inputReqWrapper);
            //checking validation i.e.if preRequisites exist
            if (String.isNotBlank(requestData.preRequisites)) {
                checkListRecord.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                checkListRecord.Missing_Pre_requisites__c = requestData.preRequisites;
                upsert checkListRecord;
                isCheckListNameRequired = true;
                checklistId = checkListRecord.Id;
                throw new CustomException(requestData.preRequisites);
            }
            //Platform event to publish request
            if(runPlatformEvent){
                handlePlatformEvent(callType, requestData.request, checkListRecord.Id);
                controllerResponseWrapper.blnIntegrationSuccess = true;
                controllerResponseWrapper.blnSuccess = true;
                //calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
            }else{
                //BRE API synchronous callout
                AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
                calloutRequestWrapper.request = requestData.request;
                calloutRequestWrapper.masterRecord = integrationMasterRecord;
                calloutRequestWrapper.checklistRecord = checkListRecord;
                calloutRequestWrapper.entityId = loanId;
                //calloutRequestWrapper.performDML = true;
                System.debug(LoggingLevel.Info,'callout Request Wrapper:'+calloutRequestWrapper);
                AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper = intUtility.initiateCallout(calloutRequestWrapper);
                System.debug('Callout Response Wrapper:'+calloutResponseWrapper);
                System.debug('Callout Response Wrapper(response):'+calloutResponseWrapper.response);
                //Validate hit limit resticrtion for user
                if (calloutResponseWrapper.errorMessage != null) {
                    throw new CustomException(calloutResponseWrapper.errorMessage);
                }
                if(calloutResponseWrapper == NULL || calloutResponseWrapper.statusCode != 200 ){
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    upsert calloutResponseWrapper.checklistRecord;
                    isCheckListNameRequired = true;
                    checklistId = calloutResponseWrapper.checklistRecord.Id;
                    throw new CustomException(AUSF_ApexConstants.GENERIC_INTEGRATION_FAILUR_MSG_INTERNAL);
                }
                controllerResponseWrapper.blnIntegrationSuccess = true;
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                upsert calloutResponseWrapper.checklistRecord;
                controllerResponseWrapper.responseWrapper = calloutResponseWrapper;
                //handle all DML and error handling from response
                //handleBreResponse(calloutResponseWrapper.response, inputReqWrapper.loanRecord, calloutResponseWrapper.checklistRecord);
                controllerResponseWrapper.blnSuccess = true;
            }
        } catch (Exception ex) {
            String message = ex.getMessage();
            if(isCheckListNameRequired){
                message += '-'+AUSF_INT_IntegrationUtility.getIntegrationChecklist(checklistId).Name;
            }
            controllerResponseWrapper.strMessage = message;
            System.debug(LoggingLevel.Error,'Exception in AUSF_INT_BRE_Controller: ' + ex);
            System.debug('===============================================================');
            System.debug(LoggingLevel.Error,'Exception type caught: ' + ex.getTypeName());
            System.debug(LoggingLevel.Error,'Message: ' + ex.getMessage());
            System.debug(LoggingLevel.Error,'Line number: ' + ex.getLineNumber());
            System.debug(LoggingLevel.Error,'Stack trace: ' + ex.getStackTraceString());
            System.debug('===============================================================');
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium, loanId, 'Applicant','AUSF_INT_BRE_Controller');      
        }
        return controllerResponseWrapper;        
    }
    /*
    @description    : getLoanData - querry loan Application record
    @param1         : loanId - Loan application Id
    @return         : List<Loan_Application__c> - Loan application 
    */
    public static List<Loan_Application__c> getLoanData(String loanId){
        List<Loan_Application__c> loanApp = new List<Loan_Application__c>();
        loanApp = [SELECT Id, Name, CreatedDate, Primary_Applicant__c, Stage__c, Sourcing_Channel__c, Loan_Amount__c, Mobile_Number__c, BRE_Knockout_Application_Counter__c,
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
             RecordType.DeveloperName, 
                (SELECT Id, Pincode__c, Address_Type__c, City__c, State__c, Residence_Ownership_Type__c, Working_Area__c, Address_Line_1__c	, Address_Line_2__c, Address_Line_3__c
                FROM Addresses__r)
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
    @return         : String - CityType from Location Master
    */
    public static String getLocationMaster(Applicant__c applicant){
        String pincode;
        for(Address__c address : applicant.Addresses__r){
            if(address.Address_Type__c == AUSF_ApexConstants.CURRENT_ADDRESS_TYPE){
                pincode = address.Pincode__c;
                break;
            }
        }
        List<Location_Master__c> locMaster = [SELECT Id, CityType__c 
        FROM Location_Master__c
        WHERE Name =:pincode
        LIMIT 1];
        System.debug('locMaster[0].CityType__c :'+locMaster[0].CityType__c);
        if(!locMaster.isEmpty()){
            return locMaster[0].CityType__c;
        }
        return NULL;
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
    /*
    @description    :   Handle BRE in response 
    @param1         :   String - BRE API response
    @param2         :   loan - loan Application to get stage
    @param3         :   checkListRecord - Integration CheckList Record
    */
    public static void handleBreResponse(String responseString, Loan_Application__c loan, Integration_Checklist__c checkListRecord){
        system.debug(LoggingLevel.Info,'responseString ' + responseString);
        system.debug(LoggingLevel.Info,'checkListRecord.Callback_Request__c ' + checkListRecord.Callback_Request__c);
        if(String.isBlank(responseString) && String.isNotBlank(checkListRecord.Callback_Request__c)){
            responseString = checkListRecord.Callback_Request__c;
        }
        if(loan == NULL){
            loan = getLoanData(checkListRecord.Loan_Application__c)[0];
        }
        //Convert JSON response to AUSF_INT_BRE_ResponseWrapper class
        AUSF_INT_BRE_ResponseWrapper.Response responseWrapper = (AUSF_INT_BRE_ResponseWrapper.Response) JSON.deserialize(responseString, AUSF_INT_BRE_ResponseWrapper.Response.class);
        AUSF_INT_BRE_ResponseWrapper.Value masterMessageOutWrapper = responseWrapper.content.outputVariables.MasterMessageOut;
        List<AUSF_INT_BRE_ResponseWrapper.ErrorWrapper> errorData = masterMessageOutWrapper?.error;
        AUSF_INT_BRE_ResponseWrapper.application applicationWrapper = masterMessageOutWrapper.application;
        AUSF_INT_BRE_ResponseWrapper.ApplicationDecision applicationDecisionWrapper = applicationWrapper.applicationDecision;
        String breDecision;
        // handle error in  BRE response
        if(errorData != NULL && !errorData.isEmpty()){
            breDecision = AUSF_INT_BRE_Constants.BRE_FAILED_DECISION;
            createBreResponseRecord(responseString, checkListRecord, applicationWrapper, loan, breDecision);
            upsert checkListRecord Request_Id__c;
            for(AUSF_INT_BRE_ResponseWrapper.ErrorWrapper error : errorData ){
                throw new AuraHandledException(error.errorCode +',' + error.description);
            }
        }else {
            breDecision = applicationDecisionWrapper.systemDecision;
            createBreResponseRecord(responseString, checklistRecord, applicationWrapper, loan, breDecision);
            if(breDecision == AUSF_INT_BRE_Constants.BRE_DECLINE_DECISION){
                //update Loan on decline
                loan.Stage__c = AUSF_INT_BRE_Constants.BRE_LOAN_STAGE_REJECT;
                loan.Reject_Reason__c = AUSF_INT_BRE_Constants.BRE_LOAN_REJECT_REASON_FICO;
                loan.Reject_Sub_Reason__c = AUSF_INT_BRE_Constants.BRE_LOAN_REJECT_SUB_REASON_APPLICATION_SCORE_NORMS_NOT_MET;
                update loan;
            }else{
                updateFieldsFromResponse(responseWrapper);
            }
        }
    }
    /*
    @description    :   create BRE Response object after Bre response received
    @param1         :   responseString - generic Api response string
    @param2         :   loan - loan Application to get stage 
    */
    public static void createBreResponseRecord(String responseString, Integration_Checklist__c checkListRecord, AUSF_INT_BRE_ResponseWrapper.application applicationWrapper, Loan_Application__c loan, String decision){
        BRE_Response__c breResponseObj = new BRE_Response__c();
        breResponseObj.Name = AUSF_INT_BRE_Constants.BRE_RESPONSE_OBJECT_NAME;
        breResponseObj.Request_Time__c = DateTime.now();
        breResponseObj.CallType__c = AUSF_INT_BRE_Constants.BRE_RESPONSE_OBJECT_CALLTYPE;
        breResponseObj.BRE_Decision__c = decision;
        breResponseObj.BRE_Response__c = responseString;
        breResponseObj.Integration_Checklist__c = checklistRecord.Id;
        breResponseObj.BRE_Request_Id__c = applicationWrapper.applicationInfo.transactionId; //or responseWrapper.transactionId;
        breResponseObj.Loan_Application__c = loan.Id; // applicationWrapper.applicationInfo.leadId; Mohit M.
        breResponseObj.Stage__c = loan.Stage__c;
        upsert breResponseObj;
    }
    /*
    @description    :   updateFieldsFromResponse - update fields in Loan and Applicant from Bre response
    @param1         :   responseWrapper - response body wrapper of BRE
    */
    public static void updateFieldsFromResponse(AUSF_INT_BRE_ResponseWrapper.Response responseWrapper){
        AUSF_INT_BRE_ResponseWrapper.application applicationWrapper = responseWrapper.content.outputVariables.MasterMessageOut.application;
        AUSF_INT_BRE_ResponseWrapper.applicants applicantWrapper = applicationWrapper.applicants[0];
        AUSF_INT_BRE_ResponseWrapper.ProductDecision productDecisionWrapper = applicationWrapper.product[0].productDecision;
        
        Loan_Application__c loanApp = new Loan_Application__c();
        if(productDecisionWrapper != NULL){
            AUSF_INT_BRE_ResponseWrapper.OfferData offerDataWrapper = productDecisionWrapper.offerData;
            if(offerDataWrapper != NULL){
                //Loan -> IPA Offer Amount	= offerDataWrapper.maxEligibleLoanAmount;
                loanApp.Loan_Amount__c = offerDataWrapper.maxEligibleLoanAmount;
                loanApp.ROI__c = offerDataWrapper.roi;
                loanApp.Min_Loan_Tenure_in_Months__c = offerDataWrapper.minTenure;
                loanApp.Max_Loan_Tenure_in_Months__c = offerDataWrapper.maxTenure;
                loanApp.Stamp_Duty_perc__c = offerDataWrapper.stampDutyGrid[0].stampDutyRate;
                loanApp.PF__c = offerDataWrapper.pfRateGrid[0].processingFeesRate;
            }
        }
        loanApp.Id = applicationWrapper.applicationInfo.leadId;
        loanApp.BRE_Knockout_Decision__c = productDecisionWrapper.productDecision;
        loanApp.BRE_Knockout_Application_Counter__c = loanApp.BRE_Knockout_Application_Counter__c != NULL ? loanApp.BRE_Knockout_Application_Counter__c + 1 : 1; 
        update loanApp;
        //Upsert Bank Account Record
        Bank_Account_Records__c  bankAccountRecord = new Bank_Account_Records__c();
        if(applicantWrapper.bureauResponse != NULL && !applicantWrapper.bureauResponse.cibilResponse.isEmpty()){
            AUSF_INT_BRE_ResponseWrapper.CibilResponse cibilResponseWrapper = applicantWrapper.bureauResponse.cibilResponse[0];
            //loanApp.isAddtionalMatch = cibilResponseWrapper.isAddtionalMatch;//need to check
            Applicant__c applicant = new Applicant__c();
            applicant.Id = applicantWrapper.applicantId;
            applicant.Cibil_Score__c = Decimal.valueOf(cibilResponseWrapper.scoreSegment[0].Score);
            update applicant;
            //Create Address from source cibil
            List<Address__c> addressList = new List<Address__c>();
            for( AUSF_INT_BRE_ResponseWrapper.AddressList addWrapper: cibilResponseWrapper.addressList){
                Address__c address = new Address__c();
                address.Applicant__c = applicant.Id;
                address.Address_Line_1__c = addWrapper.AddressLine1;
                address.Address_Line_2__c = addWrapper.AddressLine2;
                address.Address_Line_3__c = addWrapper.AddressLine3;
                address.State__c = addWrapper.StateCode;
                String category = addWrapper.AddressCategory;
                if(category == '01' || category == '03'){
                    address.Address_Type__c = category == '01'? AUSF_INT_BRE_Constants.BRE_ADDRESS_TYPE_PERMANENT : AUSF_INT_BRE_Constants.BRE_ADDRESS_TYPE_WORK;
                }
                address.Pincode__c = addWrapper.PinCode;
                address.Address_Source__c = AUSF_INT_BRE_Constants.BRE_ADDRESS_SOURCE_CIBIL;
                addressList.add(address);
            }
            upsert addressList;
            //Populate Bank Account record
            String dateOpenedDisbursedString = cibilResponseWrapper.accountSegment[0].DateOpenedDisbursed;//20022024 = 20/02/2024
            bankAccountRecord.Account_Opening_Date__c = date.parse(dateOpenedDisbursedString.substring(0,2) +'/'+ dateOpenedDisbursedString.substring(2,4)+'/'+ dateOpenedDisbursedString.substring(4));
            bankAccountRecord.Sanctioned_Amount__c = cibilResponseWrapper.accountSegment[0].HighCreditSanctionedAmount;
        }
        //Populate Bank Account record
        AUSF_INT_BRE_ResponseWrapper.ExistingAccountCommitment existAccCommitmentWrapper = applicantWrapper.applicantDecision.bureauBasedCommitmentDTls.existingAccountCommitment[0];
        bankAccountRecord.Account_Type__c = existAccCommitmentWrapper.AccountType;
        bankAccountRecord.Account_Number__c = existAccCommitmentWrapper.accountNumber;
        bankAccountRecord.Current_Balance__c = existAccCommitmentWrapper.CurrentBalance;
        //bankAccountRecord.Highest_12_24_Month_DPD__c = Max DPD//To be confirmed with FICO team
        Map<String, String> ownershipIndicatorMap = new Map<String, String>{'01' => 'Individual', '02' => 'Authorised User', '03' => 'Guarantor', '04' => 'Joint', '05' => 'Deceased'};
        if(ownershipIndicatorMap.containsKey(existAccCommitmentWrapper.OwnershipIndicator)){
            bankAccountRecord.Owenership_Indicator__c = ownershipIndicatorMap.get(existAccCommitmentWrapper.OwnershipIndicator);
        }
        //bankAccountRecord.No_of_Emi_Paid__c = No of EMIS Paid ;//To be confirmed with FICO team
        if(existAccCommitmentWrapper.emiAmount != NULL){
            bankAccountRecord.EMI_Amount__c = existAccCommitmentWrapper.emiAmount; 
        }
        else if(existAccCommitmentWrapper.imputedeEMIAmount != NULL){
            bankAccountRecord.EMI_Amount__c = existAccCommitmentWrapper.imputedeEMIAmount;
        }
        upsert bankAccountRecord Account_Number__c;
    }
}