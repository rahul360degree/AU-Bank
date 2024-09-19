/**
* @author        Tejendra
* @date          12-July-2024
* @description   WhatsApp Notification Queueable class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              12-July-2024    Initial Version - APL-247
*/
public without sharing class AUSF_WhatsAppNotificationQueueable implements Queueable, Database.AllowsCallouts{
    public Applicant__c applicantObj;
    public Loan_Application__c loanApplicationObj;
    public AUSF_WhatsAppNotificationHandler.WhatsAppApiKeysWrapper whatsAppApiKeysWrapperObj;
    public String strTriggerPoint;
    public String toNumber;
    
    /*
    @description    : AUSF_WhatsAppNotificationQueueable - Constructor for class variable assignment
    @param1         : applicantObj - Applicant Record
    @param2         : loanApplicationObj - Loan Application Record
    @param3         : whatsAppApiKeysWrapperObj - WhatsApp api keys wrapper
    @param4         : strTriggerPoint - Notification trigger point
    @param5         : toNumber - mobile number to send whatsApp message  
    */
    public AUSF_WhatsAppNotificationQueueable(Applicant__c applicantObj, Loan_Application__c loanApplicationObj, AUSF_WhatsAppNotificationHandler.WhatsAppApiKeysWrapper whatsAppApiKeysWrapperObj, String strTriggerPoint, String toNumber) {
        this.applicantObj = applicantObj;
        this.loanApplicationObj = loanApplicationObj;
        this.whatsAppApiKeysWrapperObj = whatsAppApiKeysWrapperObj;
        this.strTriggerPoint = strTriggerPoint;
        this.toNumber = toNumber;
    }

    public void execute(QueueableContext context) {
        try{
            Map<String, String> paramValueMap = new Map<String, String>();
            for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c 
                                                                           FROM Integration_Static_Param__mdt 
                                                                           WHERE API_Name__c =: AUSF_ApexConstants.AUSF_WHATSAPP_INTEGRATION_MASTER]){
                                                                            paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
                                                                           }
                Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_WHATSAPP_INTEGRATION_MASTER);
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
                inputData.dynamicInputs.put('authorization', paramValueMap.get('authorization'));
                inputData.dynamicInputs.put('RequestId', AUSF_INT_IntegrationUtility.getReferenceId());
                inputData.dynamicInputs.put('whatsapp_bsp', paramValueMap.get('whatsapp_bsp'));
                inputData.dynamicInputs.put('Channel', objIntMapper.Channel__c);
                inputData.dynamicInputs.put('campaign_id', whatsAppApiKeysWrapperObj.campaignId);
                inputData.dynamicInputs.put('name', applicantObj.Full_Name__c);
                inputData.dynamicInputs.put('phone_number', toNumber);
                inputData.dynamicInputs.put('media_url', paramValueMap.get('media_url'));
                inputData.dynamicInputs.put('document_filename', paramValueMap.get('document_filename'));
                inputData.dynamicInputs.put('key1', whatsAppApiKeysWrapperObj.key1);
                inputData.dynamicInputs.put('key2', whatsAppApiKeysWrapperObj.key2);
                inputData.dynamicInputs.put('key3', whatsAppApiKeysWrapperObj.key3);
                inputData.dynamicInputs.put('key4', whatsAppApiKeysWrapperObj.key4);
                inputData.dynamicInputs.put('key5', whatsAppApiKeysWrapperObj.key5);
                AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
                AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
                // Check for Pre-Requisite Errors
                if (String.isNotBlank(requestDetails.preRequisites)) {
                    newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                    newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                    throw new CustomException(requestDetails.preRequisites+'-'+newChecklistInstance.Name);
                }

            AUSF_INT_WhatsAppResponseWrapper objWhatsAppResponse = new AUSF_INT_WhatsAppResponseWrapper(); 
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
                objWhatsAppResponse = (AUSF_INT_WhatsAppResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_WhatsAppResponseWrapper.class);
                objWhatsAppResponse.responseWrapper = calloutResponseWrapper;
                if (objWhatsAppResponse.status ==  200) {
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
            AUSF_Log.error(objException,AUSF_Log.SeverityType.High,applicantObj.Id,'Applicant',AUSF_ApexConstants.AUSF_WHATSAPP_INTEGRATION_MASTER);
        }
    }

public class CustomException extends Exception {}
}