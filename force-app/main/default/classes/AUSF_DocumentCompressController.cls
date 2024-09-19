/**
 * @author        Pradeep Sharma
 * Class :		 AUSF_DocumentCompressController
 * Test Class	 AUSF_DocumentCompressTest
 * @date          05-July-2024
 * @description   Document Compression api controller
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
    --------------------------------------------------------------------------------------------
    Pradeep Sharma        05-July-2024    Initial Version
     */
public without sharing class AUSF_DocumentCompressController {
     /*
    @description    : getCompresssedDocument - This method is used to get the compressed document
    @author         : Pradeep Sharma
    @param1         : base64String - Base64 string of the document
    @param2         : filename - Name of the file
    @param3         : applicantId - Id of the applicant
    @param4         : loan_Applicantion__c Id
    @return         : Wrapper class contains return result
    */
    @AuraEnabled
    public static AUSF_INT_DocumentCompressWrapper getCompresssedDocument(String base64String, String filename,String applicantId,String loanId,String checklistId){ // String strDocMasterName
        AUSF_INT_DocumentCompressWrapper objResponse = new AUSF_INT_DocumentCompressWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_DOCUMENT_COMPRESSOR_INTEGRATION_MASTER);
        String respBody;
        String strIntMessage = '';
        String previousRequestId='';
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        try{
            filename = String.isNotBlank(filename) ? filename.replaceAll(' ','') : '';
            Loan_Application__c objApplication;
            List<Document_Checklist__c> lstDocChecklist = new List<Document_Checklist__c>();
            
            if(String.isNotBlank(applicantId)) {
                lstDocChecklist = [SELECT Id, Applicant__c, Loan_Application__c FROM Document_Checklist__c where Applicant__c =: applicantId AND Id=:checklistId AND Document_Master__r.Active__c = true LIMIT 1];
            }
            else if (String.isNotBlank(loanId)) {
                lstDocChecklist = [SELECT Id, Loan_Application__c, Applicant__c FROM Document_Checklist__c where Loan_Application__c =: loanId AND Id=:checklistId AND Document_Master__r.Active__c = true LIMIT 1];
            }
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;             
            newChecklistInstance.Applicant__c = lstDocChecklist.size() > 0 && String.isNotBlank(lstDocChecklist[0].Applicant__c)? lstDocChecklist[0].Applicant__c : NULL;
            newChecklistInstance.Loan_Application__c = lstDocChecklist.size() > 0 && String.isNotBlank(lstDocChecklist[0].Loan_Application__c) ? lstDocChecklist[0].Loan_Application__c : NULL;
            newChecklistInstance.Document_Checklist__c = lstDocChecklist.size() > 0 ? lstDocChecklist[0].Id : NULL;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.dynamicInputs = new Map<String, Object>();
            inputData.dynamicInputs.put('file', filename);
            inputData.dynamicInputs.put('base64string', base64String);
            inputData.dynamicInputs.put('channel', objIntMapper.Channel__c);
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(newChecklistInstance.Id);
                throw new CustomException(requestDetails.preRequisites+ ' - ' + objChecklist.Name);
            }
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper = new AUSF_INT_IntegrationResponseWrapper.ResponseWrapper();
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.captureRequestInAttachment = true;
            calloutRequestWrapper.performDML=true;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = (String.isEmpty(applicantId) ? (String.isEmpty(loanId) ? NULL : Id.valueOf(loanId)) : Id.valueOf(applicantId));
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper resp = calloutResponseWrapper;
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - ';
                upsert calloutResponseWrapper.checklistRecord;
            }
            else  {
                if(calloutResponseWrapper.statusCode==200 || calloutResponseWrapper.statusCode==201 || calloutResponseWrapper.statusCode==202 || calloutResponseWrapper.statusCode==203 || calloutResponseWrapper.statusCode==204){
                    AUSF_DocumentCompressResponseWrapper res = (AUSF_DocumentCompressResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_DocumentCompressResponseWrapper.class);
                    if(res.Code == 'ADS00'){
                        calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                        objResponse.blnIntegrationSuccess = true;
                        objResponse.OutputBase64String = res.OutputFileBase64string;
                    }
                    else{
                        calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                        strIntMessage = 'Error with Service - '  + res.OutputStatus+' '+ objIntMapper.Name + ' and record reference - ';
                    }
                    objResponse.Code = res.Code;
                    objResponse.OutputStatus = res.OutputStatus;
                }
                else{
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - ';
                    calloutResponseWrapper.errorMessage = strIntMessage;
                }
                upsert calloutResponseWrapper.checklistRecord;                
            }
            objResponse.responseWrapper = calloutResponseWrapper;
            if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strMessage = String.isNotBlank(strIntMessage) ? strIntMessage  + objChecklist.Name : '';
                throw new CustomException (objResponse.strMessage);
            }
            objResponse.blnSuccess = true;
            
        }
        catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            System.debug(LoggingLevel.Error,'Exception in class ' + ex.getLineNumber());
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,String.isEmpty(applicantId) ? loanId : applicantId, (String.isEmpty(applicantId) ? 'Loan Application' : 'Applicant'),'DocumentCompressAPI');
        }
        return objResponse;
    }
    public class CustomException extends Exception {}
}