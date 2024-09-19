public without sharing class AUSF_CBSStandingInstructionController {
    @AuraEnabled
    public static AUSF_INT_CBSSIWrapper callCBSSIApi(String loanId){
        AUSF_INT_CBSSIWrapper objresponse = new AUSF_INT_CBSSIWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_CBSSI_INTEGRATION_MASTER);
        String respBody;
        String strIntMessage = '';
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        try{
            List<Loan_Application__c> loanList = [SELECT Id FROM Loan_Application__c WHERE id=:loanId];
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Loan_Application__c = loanId;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.loanRecord = !loanList.isEmpty()?loanList[0]:null;
            inputData.dynamicInputs = new Map<String, Object>();
            /*inputData.dynamicInputs.put('TransactionBranch', paramsValueMap.get('TransactionBranch'));
            inputData.dynamicInputs.put('CustomerId', paramsValueMap.get('CustomerId'));
            inputData.dynamicInputs.put('CustomerName', paramsValueMap.get('CustomerName'));
            inputData.dynamicInputs.put('SubmissionLoad', paramsValueMap.get('SubmissionLoad'));
            inputData.dynamicInputs.put('SuppressVersion', paramsValueMap.get('SuppressVersion'));*/
            inputData.dynamicInputs.put('channel', objIntMapper.Channel__c);
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            System.debug('requestDetails--->'+requestDetails);
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                throw new CustomException(requestDetails.preRequisites);
            }
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = loanId;
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            if (calloutResponseWrapper.errorMessage!=null) {
                throw new CustomException(calloutResponseWrapper.errorMessage);
            }
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - ';
                calloutResponseWrapper.errorMessage = strIntMessage;
            }
            else  {
                AUSF_CBSSIResponseWrapper res = (AUSF_CBSSIResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_CBSSIResponseWrapper.class);
                if(res!=null && res.TransactionStatus!=null && res.TransactionStatus.ResponseCode!=null){
                    if (res.TransactionStatus.ResponseCode == '0') {
                        calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                        objResponse.blnIntegrationSuccess = true;
                    }
                    else {
                        calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                        strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - ';
                        calloutResponseWrapper.errorMessage = strIntMessage;
                    }
                }
            }
            upsert calloutResponseWrapper.checklistRecord;
            objResponse.objIntResponse = calloutResponseWrapper;
            if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strMessage = String.isNotBlank(strIntMessage) ? strIntMessage  + objChecklist.Name : '';
                throw new CustomException(objResponse.strMessage);
            }
            objResponse.blnSuccess = true;
        }
        catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            System.debug(LoggingLevel.Error,'Exception in class ' + ex.getLineNumber()+ ''+ex.getCause());
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,loanId,'Loan Application',AUSF_ApexConstants.AUSF_CBSSI_INTEGRATION_MASTER);
        }
        System.debug('objResponse--->'+objResponse);
        return objresponse;
    }
    public class CustomException extends Exception {}
}