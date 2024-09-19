public without sharing class AUSF_PaymentRTGSNEFTController {
    public AUSF_PaymentRTGSNEFTController() {

    }
    /*
    @description    : doRTGSPayment - Generate RTGS  Payment service method
    @param1         : loanId - Loan Application Record Id
    @param2         : applicantId - Applicant Record Id
    @return         : Wrapper class contains return result
    */
    @AuraEnabled
    public static RTGSPaymentWrapper doRTGSPayment(String loanId, String applicantId){
        RTGSPaymentWrapper objResponse = new RTGSPaymentWrapper();
        Applicant__c objApplicant;
        Loan_Application__c loanApplicationObj;
        Bank_Account_Records__c bankAccountObj;
        try{
            Map<String, String> paramValueMap = new Map<String, String>();
            for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c 
                                                                           FROM Integration_Static_Param__mdt 
                                                                           WHERE API_Name__c =: AUSF_ApexConstants.AUSF_Payment_RTGS_INTEGRATION_MASTER]){
                                                                               paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
                                                                           }
            loanApplicationObj = [SELECT Id,Name,Loan_Amount__c,Branch__c FROM Loan_Application__c WHERE Id =: loanId];     
            objApplicant = [SELECT Id,Full_Name__c,PAN__c,Mobile_Number__c,Personal_email_ID__c, First_Name__c, Middle_Name__c, Last_Name__c, RecordType.Name, AML_verified__c FROM Applicant__c where Id =: applicantId limit 1];
            bankAccountObj = [SELECT Id,IFSC_Code__c,Account_Type__c,Account_Number__c,Account_Name__c,Applicant__c FROM Bank_Account_Records__c WHERE Applicant__c =: applicantId];
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = objApplicant.Id);
            Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_Payment_RTGS_INTEGRATION_MASTER);
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicantId;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = objApplicant;
            inputData.dynamicInputs = createRequestDynamicInputData(loanApplicationObj,objApplicant,paramValueMap,bankAccountObj);                
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            // Check for Pre-Requisite Errors
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(newChecklistInstance.Id);
                throw new CustomException(requestDetails.preRequisites+'-'+objChecklist.Name);
            }
            AUSF_INT_doRTGSResponseWrapper objRTGSResponse = new AUSF_INT_doRTGSResponseWrapper(); 
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper;
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = objApplicant.Id;
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            if (calloutResponseWrapper.errorMessage!=null) {    
                objResponse.blnSuccess = true;
                objResponse.strIntMessage = calloutResponseWrapper.errorMessage;
                objResponse.blnIntegrationSuccess = false;
                return objResponse;
            }
            // Check for HTTP Status Code
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - '+objChecklist.Name;
                objResponse.blnIntegrationSuccess = false;
            }
            else  {
                objRTGSResponse = (AUSF_INT_doRTGSResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_doRTGSResponseWrapper.class);
                objRTGSResponse.responseWrapper = calloutResponseWrapper;
                // Check for Service response status
                if (objRTGSResponse.SettlementResponse.Code ==  '201') {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    upsert calloutResponseWrapper.checklistRecord;
                    objResponse.blnIntegrationSuccess = true;
                }
                else {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    upsert calloutResponseWrapper.checklistRecord;
                    Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                    objResponse.blnIntegrationSuccess = false;
                    objResponse.strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - '+objChecklist.Name;
                }
            }
            // Check for Integration Failure to populate Integration Checklist Name
            if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strIntMessage = String.isNotBlank(objResponse.strIntMessage) ? objResponse.strIntMessage  + objChecklist.Name : '';
            }
            objResponse.RTGSPaymentWrap = objRTGSResponse;
            objResponse.blnSuccess = true;
        }
        catch (Exception ex) {
            System.debug('ex.getMessage()='+ex.getMessage());
            System.debug('ex.getLineNumber()='+ex.getLineNumber());
            objResponse.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.High,objApplicant.Id,'Applicant',AUSF_ApexConstants.AUSF_Payment_RTGS_INTEGRATION_MASTER);
        }
        return objResponse;

    }

    /*
    @description    : doNEFTPayment - Generate NEFT  Payment service method
    @param1         : loanId - Loan Application Record Id
    @param2         : applicantId - Applicant Record Id
    @return         : Wrapper class contains return result
    */
    @AuraEnabled
    public static NEFTPaymentWrapper doNEFTPayment(String loanId, String applicantId){
        NEFTPaymentWrapper objResponse = new NEFTPaymentWrapper();
        Applicant__c objApplicant;
        Loan_Application__c loanApplicationObj;
        Bank_Account_Records__c bankAccountObj;
        try{
            Map<String, String> paramValueMap = new Map<String, String>();
            for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c 
                                                                           FROM Integration_Static_Param__mdt 
                                                                           WHERE API_Name__c =: AUSF_ApexConstants.AUSF_Payment_NEFT_INTEGRATION_MASTER]){
                                                                               paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
                                                                           }
            loanApplicationObj = [SELECT Id,Name,Loan_Amount__c,Branch__c FROM Loan_Application__c WHERE Id =: loanId];     
            objApplicant = [SELECT Id,Full_Name__c,PAN__c,Mobile_Number__c,Personal_email_ID__c, First_Name__c, Middle_Name__c, Last_Name__c, RecordType.Name, AML_verified__c FROM Applicant__c where Id =: applicantId limit 1];
            bankAccountObj = [SELECT Id,IFSC_Code__c,Account_Type__c,Account_Number__c,Account_Name__c,Applicant__c FROM Bank_Account_Records__c WHERE Applicant__c =: applicantId];
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = objApplicant.Id);
            Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_Payment_NEFT_INTEGRATION_MASTER);
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicantId;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = objApplicant;
            inputData.dynamicInputs = createRequestDynamicInputData(loanApplicationObj,objApplicant,paramValueMap,bankAccountObj);                
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            // Check for Pre-Requisite Errors
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(newChecklistInstance.Id);
                throw new CustomException(requestDetails.preRequisites+'-'+objChecklist.Name);
            }
            AUSF_INT_doNEFTResponseWrapper objNEFTResponse = new AUSF_INT_doNEFTResponseWrapper(); 
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper;
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = objApplicant.Id;
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            if (calloutResponseWrapper.errorMessage!=null) {    
                objResponse.blnSuccess = true;
                objResponse.strIntMessage = calloutResponseWrapper.errorMessage;
                objResponse.blnIntegrationSuccess = false;
                return objResponse;
            }
            // Check for HTTP Status Code
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - '+objChecklist.Name;
                objResponse.blnIntegrationSuccess = false;
            }
            else  {
                objNEFTResponse = (AUSF_INT_doNEFTResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_doNEFTResponseWrapper.class);
                objNEFTResponse.responseWrapper = calloutResponseWrapper;
                // Check for Service response status
                if (objNEFTResponse.SettlementResponse.Code ==  '201') {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    upsert calloutResponseWrapper.checklistRecord;
                    objResponse.blnIntegrationSuccess = true;
                }
                else {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    upsert calloutResponseWrapper.checklistRecord;
                    Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                    objResponse.blnIntegrationSuccess = false;
                    objResponse.strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - '+objChecklist.Name;
                }
            }
            // Check for Integration Failure to populate Integration Checklist Name
            if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strIntMessage = String.isNotBlank(objResponse.strIntMessage) ? objResponse.strIntMessage  + objChecklist.Name : '';
            }
            objResponse.NEFTPaymentWrap = objNEFTResponse;
            objResponse.blnSuccess = true;
        }
        catch (Exception ex) {
            System.debug('ex.getMessage()='+ex.getMessage());
            System.debug('ex.getLineNumber()='+ex.getLineNumber());
            objResponse.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.High,objApplicant.Id,'Applicant',AUSF_ApexConstants.AUSF_Payment_RTGS_INTEGRATION_MASTER);
        }
        return objResponse;

    }

    public static Map<String,String> createRequestDynamicInputData(Loan_Application__c loanApplicationObj, Applicant__c objApplicant, Map<String,String> paramValueMap, Bank_Account_Records__c bankAccountObj){
        String narration = loanApplicationObj.Name+' && SFDCPLPA'+' && '+loanApplicationObj.Branch__c+'&& Dr && '+bankAccountObj.Account_Number__c+' && '+bankAccountObj.Account_Name__c;
        Map<String,String> dynamicInputs = new Map<String,String>();
        dynamicInputs.put('TransactionReferenceNumber', getApplicationRelatedReferenceId(loanApplicationObj.Id));
        dynamicInputs.put('Amount',String.ValueOf(loanApplicationObj.Loan_Amount__c));
        dynamicInputs.put('ValueDate',(String.valueOf(Date.today())).replace('-',''));
        dynamicInputs.put('SenderIFSC',paramValueMap.get('SenderIFSC'));
        dynamicInputs.put('SenderAccountType',paramValueMap.get('SenderAccountType'));
        dynamicInputs.put('SenderAccountNumber',paramValueMap.get('SenderAccountNumber'));
        dynamicInputs.put('SendingCustomerName',paramValueMap.get('SendingCustomerName'));
        dynamicInputs.put('SenderContactInfo',paramValueMap.get('SenderContactInfo'));
        dynamicInputs.put('ReceiverIFSC',bankAccountObj.IFSC_Code__c);
        dynamicInputs.put('ReceiverAccountType',getReceiverAccountTypeMap().get(bankAccountObj.Account_Type__c));
        dynamicInputs.put('ReceiverAccountNumber',bankAccountObj.Account_Number__c);
        dynamicInputs.put('ReceivingCustomerName',bankAccountObj.Account_Name__c);
        dynamicInputs.put('Narration',narration);
        dynamicInputs.put('Source',paramValueMap.get('Source'));
        return dynamicInputs; 
    }

    public static Map<String,String> getReceiverAccountTypeMap(){
        Map<String,String> receiverAccountTypeMap = new Map<String,String>();
        receiverAccountTypeMap.put('Saving','10');
        receiverAccountTypeMap.put('Current','11');
        receiverAccountTypeMap.put('Cash Credit	','13');
        receiverAccountTypeMap.put('Loan','14');
        receiverAccountTypeMap.put('Overdraft','12');
        return receiverAccountTypeMap;
    }

    public static String getApplicationRelatedReferenceId(String applicationId){
        Integer charLength = 20;
        String hashString = applicationId + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash).left(charLength);
        system.debug('##########' + hexDigest );
        return hexDigest;
    }

    public class RTGSPaymentWrapper {
        @AuraEnabled
        public AUSF_INT_doRTGSResponseWrapper RTGSPaymentWrap {get;set;}
        @AuraEnabled
        public Boolean blnIntegrationSuccess = false;
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public String strMessage {get;set;}
        @AuraEnabled
        public String strIntMessage {get;set;}
    }

    public class NEFTPaymentWrapper {
        @AuraEnabled
        public AUSF_INT_doNEFTResponseWrapper NEFTPaymentWrap {get;set;}
        @AuraEnabled
        public Boolean blnIntegrationSuccess = false;
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public String strMessage {get;set;}
        @AuraEnabled
        public String strIntMessage {get;set;}
    }
    
    public class CustomException extends Exception {}
}