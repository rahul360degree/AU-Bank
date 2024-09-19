public with sharing class AUSF_PaymentIFTAPIController {
    @AuraEnabled
    public static AUSF_INT_PaymentIFTAPIWrapper doIFTPayment(String loanId,String disburseBtn){
        AUSF_INT_PaymentIFTAPIWrapper objResponse = new AUSF_INT_PaymentIFTAPIWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_PAYMENTIFT_INTEGRATION_MASTER);
        String respBody;
        String strIntMessage = '';
        Map<String,String> paramsValueMap = getParamsValue();
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        try {
            Loan_Application__c loan = [SELECT Id,Name,Loan_Amount__c FROM Loan_Application__c where Id=:loanId limit 1];
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Loan_Application__c = loanId;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.loanRecord = loan;
            inputData.dynamicInputs = new Map<String, Object>();
            inputData.dynamicInputs.put('valueDate', System.Today());
            inputData.dynamicInputs.put('TransactionType', paramsValueMap.get('TransactionType'));
            inputData.dynamicInputs.put('TransactionCurrency', paramsValueMap.get('TransactionCurrency'));
            inputData.dynamicInputs.put('TransactionBranch', paramsValueMap.get('TransactionBranch'));
            inputData.dynamicInputs.put('TransactionAmount', loan.Loan_Amount__c);
            inputData.dynamicInputs.put('ToAccountCurrency', paramsValueMap.get('ToAccountCurrency'));
            inputData.dynamicInputs.put('ToAccountBranch', paramsValueMap.get('ToAccountBranch'));
            inputData.dynamicInputs.put('ToAccount', paramsValueMap.get('ToAccount'));
            inputData.dynamicInputs.put('Narrative', 'MAH0000638114 SHRISHAIL MADANS');//logical
            inputData.dynamicInputs.put('FromAccountCurrency', paramsValueMap.get('FromAccountCurrency'));
            inputData.dynamicInputs.put('FromAccountBranch', paramsValueMap.get('FromAccountBranch'));
            inputData.dynamicInputs.put('FromAccount', paramsValueMap.get('FromAccount'));
            inputData.dynamicInputs.put('Channel', objIntMapper.Channel__c);
            system.debug('inputData--->'+inputData);
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                throw new CustomException(requestDetails.preRequisites);
            }
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper = new AUSF_INT_IntegrationResponseWrapper.ResponseWrapper();
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = loanId;
            System.debug('calloutRequestWrapper--->'+calloutRequestWrapper);
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            System.debug('calloutResponseWrapper--->'+calloutResponseWrapper);
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - ';
            }
            else  {
                AUSF_PaymentIFTAPIResponseWrapper res = (AUSF_PaymentIFTAPIResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_PaymentIFTAPIResponseWrapper.class);
                if(calloutResponseWrapper.statusCode == 200){
                    if(res.TransactionStatus.ResponseCode == '0'){
                        calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                        objResponse.blnIntegrationSuccess = true;

                    }
                    else{
                        calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                        strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - ';
                        calloutResponseWrapper.errorMessage = strIntMessage;    

                    }
                }
            }
            upsert calloutResponseWrapper.checklistRecord;
            if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strMessage = String.isNotBlank(strIntMessage) ? strIntMessage  + objChecklist.Name : '';
                throw new CustomException (objResponse.strMessage);
            }
            objResponse.responseWrapper = calloutResponseWrapper;
            objResponse.blnSuccess = true;
        }
        catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            System.debug(LoggingLevel.Error,'Exception in class ' + ex.getLineNumber()+ ''+ex.getCause());
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,loanId,'Loan Application','Payment IFT');
        }
        system.debug('objResponse--->'+objResponse);
        return objResponse;
    }
    public static Map<String,String> getParamsValue(){
        Map<String,String> paramsValueMap = new Map<String,String>();
        for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c
                                                                           FROM Integration_Static_Param__mdt
                                                                           WHERE API_Name__c = :AUSF_ApexConstants.AUSF_PAYMENTIFT_INTEGRATION_MASTER]){
            paramsValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
        }
        return paramsValueMap;
    }
    public class CustomException extends Exception {}
}