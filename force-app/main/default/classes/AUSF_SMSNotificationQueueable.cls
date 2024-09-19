/**
* @author        Tejendra
* @date          11-July-2024
* @description   SMS Notification Queueable class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              11-July-2024    Initial Version - APL-240
*/

public without sharing class AUSF_SMSNotificationQueueable implements Queueable, Database.AllowsCallouts {
    public Applicant__c applicantObj;
    public Loan_Application__c loanApplicationObj;
    public String message;
    public String strTriggerPoint;
    public String toNumber;
    /*
    @description    : AUSF_SMSNotificationQueueable - Constructor for class variable assignment
    @param1         : applicantObj - Applicant Record
    @param2         : loanApplicationObj - Loan Application Record
    @param3         : message - sms message
    @param4         : strTriggerPoint - Notification trigger point
    @param5         : toNumber - mobile number to send sms  
    */
    public AUSF_SMSNotificationQueueable(Applicant__c applicantObj, Loan_Application__c loanApplicationObj, String message, String strTriggerPoint ,String toNumber) {
        this.applicantObj = applicantObj;
        this.loanApplicationObj = loanApplicationObj;
        this.message = message;
        this.strTriggerPoint = strTriggerPoint;
        this.toNumber = toNumber;
    }

    public void execute(QueueableContext context) {
        try{
        Map<String, String> paramValueMap = new Map<String, String>();
        for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c 
                                                                       FROM Integration_Static_Param__mdt 
                                                                       WHERE API_Name__c =: AUSF_ApexConstants.AUSF_SMS_INTEGRATION_MASTER]){
                                                                        paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
                                                                       }
            
            Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_SMS_INTEGRATION_MASTER);
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicantObj.Id;
            newChecklistInstance.Loan_Application__c = loanApplicationObj.Id;
            newChecklistInstance.Integration_Trigger_Type__c = strTriggerPoint;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = applicantObj;
            inputData.dynamicInputs = new Map<String, Object>();
            inputData.dynamicInputs.put('GroupID', paramValueMap.get('GroupID'));
            inputData.dynamicInputs.put('ContentType', paramValueMap.get('ContentType'));
            inputData.dynamicInputs.put('Channel', objIntMapper.Channel__c);
            inputData.dynamicInputs.put('NationalorInternational', paramValueMap.get('NationalorInternational'));
            inputData.dynamicInputs.put('MessageType', paramValueMap.get('MessageType'));
            inputData.dynamicInputs.put('IsOTPMessage', paramValueMap.get('IsOTPMessage'));
            inputData.dynamicInputs.put('LanguageId', paramValueMap.get('LanguageId'));
            inputData.dynamicInputs.put('RequestId', AUSF_INT_IntegrationUtility.getReferenceId());
            inputData.dynamicInputs.put('MobileNumber', toNumber);
            inputData.dynamicInputs.put('MessageText', message);
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(newChecklistInstance.Id);
                throw new CustomException(requestDetails.preRequisites+'-'+objChecklist.Name);
            }
            AUSF_INT_SMSNotificationResponseWrapper objSMSResponse = new AUSF_INT_SMSNotificationResponseWrapper(); 
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper;
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = applicantObj.Id;
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            String strIntMessage;
            if (calloutResponseWrapper.errorMessage!=null) {    
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                strIntMessage = calloutResponseWrapper.errorMessage+' record reference - '+objChecklist.Name;
                throw new CustomException(strIntMessage);
            }
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - '+objChecklist.Name;
                throw new CustomException(strIntMessage);
            }
            else  {
                objSMSResponse = (AUSF_INT_SMSNotificationResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_SMSNotificationResponseWrapper.class);
                objSMSResponse.responseWrapper = calloutResponseWrapper;
                if (objSMSResponse != NULL && objSMSResponse.TransactionStatus != NULL && objSMSResponse.TransactionStatus.ResponseCode ==  '0') {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    upsert calloutRequestWrapper.checklistRecord;
                }
                else {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    upsert calloutRequestWrapper.checklistRecord;
                    Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                    strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - '+objChecklist.Name;
                    throw new CustomException(strIntMessage);
                }
            }
        }catch(exception objException){
            AUSF_Log.error(objException,AUSF_Log.SeverityType.High,applicantObj.Id,'Applicant',AUSF_ApexConstants.AUSF_SMS_INTEGRATION_MASTER);
        }
    }

public class CustomException extends Exception {}
}