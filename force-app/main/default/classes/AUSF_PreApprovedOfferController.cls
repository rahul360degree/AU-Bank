public with sharing class AUSF_PreApprovedOfferController {
@AuraEnabled
public static PreApprovedOfferWrapper fetchPA(String loan,String strApplicantId,String cif){
    PreApprovedOfferWrapper objResponse = new PreApprovedOfferWrapper();
    String respBody;
    String strIntMessage = '';
    AUSF_PreApprovedOfferResponseWrapper.PreApprovedOfferResponseWrapper objResultWrapper;
    try{
        Applicant__c objApplicant = [SELECT Name, Id, RecordType.Name FROM Applicant__c where Id=:strApplicantId limit 1];
        Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = strApplicantId);
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord('PreApprovedOffer');
        Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
        newChecklistInstance.Integration_Master__c = objIntMapper.Id;
        newChecklistInstance.Applicant__c = strApplicantId;

        AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
        inputData.integrationChecklistRecord = newChecklistInstance;
        inputData.integrationMasterRecord = objIntMapper;
        inputData.applicantRecord = objApplicant;
        inputData.dynamicInputs = new Map<String, Object>();  
        inputData.dynamicInputs.put('originatingChannel',objIntMapper.Channel__c);
        inputData.dynamicInputs.put('customerId',cif);
        //inputData.dynamicInputs.put('productId','11704');

        AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                throw new CustomException(requestDetails.preRequisites);
            }
            AUSF_PreApprovedOfferResponseWrapper objPreApprovedOfferResponse = new AUSF_PreApprovedOfferResponseWrapper();
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper;
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = objApplicant.Id;
            //calloutRequestWrapper.performDML = true;
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            if (calloutResponseWrapper.errorMessage!=null) {    
                objResponse.blnSuccess = true;
                objResponse.strIntMessage = calloutResponseWrapper.errorMessage;
                objResponse.blnIntegrationSuccess = false;
                return objResponse;
            }
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299) { 
                calloutResponseWrapper.checklistRecord.Status__c = 'Failed';
                upsert calloutResponseWrapper.checklistRecord;
                strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - ';
                objResponse.blnIntegrationSuccess = false;
            }
            else  {
                objPreApprovedOfferResponse.PreApprovedOfferResponse = (AUSF_PreApprovedOfferResponseWrapper.PreApprovedOfferResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_PreApprovedOfferResponseWrapper.PreApprovedOfferResponseWrapper.class);
                if(objPreApprovedOfferResponse.PreApprovedOfferResponse != NULL && objPreApprovedOfferResponse.PreApprovedOfferResponse.CRMQueryResults != NULL && !objPreApprovedOfferResponse.PreApprovedOfferResponse.CRMQueryResults.isEmpty()){
                    calloutResponseWrapper.checklistRecord.Status__c = 'Completed';
                    objResponse.blnIntegrationSuccess = true;
                }else{
                    calloutResponseWrapper.checklistRecord.Status__c = 'Failed';
                    objResponse.blnIntegrationSuccess = false;
                    strIntMessage = 'Something went wrong. Please contact System Admin.';
                }
                upsert calloutRequestWrapper.checklistRecord;
            }
            if (!objResponse.blnIntegrationSuccess) {
                Integration_Checklist__c objChecklist = [Select Id, Name FROM Integration_Checklist__c WHERE Id =: calloutResponseWrapper.checklistRecord.Id LIMIT 1];
                objResponse.strIntMessage = String.isNotBlank(strIntMessage) ? strIntMessage  + objChecklist.Name : '';
            }
            objResponse.preApprovedOfferWrap = objPreApprovedOfferResponse;
            objResponse.blnSuccess = true;
    }
        catch (Exception ex) {
            System.debug(LoggingLevel.Error,'Exception in class ' + ex);
            System.debug('Exception Error='+ex.getMessage());
            System.debug('Exception Line='+ex.getLineNumber());
            objResponse.strMessage = ex.getMessage();
            // Params - Exception, Severity, RecordId, Object Label Name, Screen
            AUSF_Log.error(ex, AUSF_Log.SeverityType.High,strApplicantId,'Applicant','Pre Approved Offer');
        }
        return objResponse;
}

public class PreApprovedOfferWrapper {
    @AuraEnabled
    public AUSF_PreApprovedOfferResponseWrapper preApprovedOfferWrap {get;set;}
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