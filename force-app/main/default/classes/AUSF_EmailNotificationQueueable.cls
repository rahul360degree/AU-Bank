/**
* @author        Tejendra
* @date          11-July-2024
* @description   Email Notification Queueable class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              11-July-2024    Initial Version - APL-244
*/
public without sharing class AUSF_EmailNotificationQueueable implements Queueable, Database.AllowsCallouts{
    public Applicant__c applicantObj;
    public Loan_Application__c loanApplicationObj;
    public String message;
    public String subject;
    public String strTriggerPoint;
    public String toEmailId;
    public AUSF_EmailNotificationHandler.DocumentWrapper documentWrapperObj;
    
    /*
    @description    : AUSF_EmailNotificationQueueable - Constructor for class variable assignment
    @param1         : applicantObj - Applicant Record
    @param2         : loanApplicationObj - Loan Application Record
    @param3         : message - email message
    @param4         : subject - email subject
    @param5         : strTriggerPoint - Notification trigger point
    @param6         : toEmailId - emailId to send email  
    */
    public AUSF_EmailNotificationQueueable(Applicant__c applicantObj, Loan_Application__c loanApplicationObj, String message, String subject, String strTriggerPoint, String toEmailId,AUSF_EmailNotificationHandler.DocumentWrapper documentWrapperObj) {
        this.applicantObj = applicantObj;
        this.loanApplicationObj = loanApplicationObj;
        this.message = message;
        this.subject = subject;
        this.strTriggerPoint = strTriggerPoint;
        this.toEmailId = toEmailId;
        this.documentWrapperObj = documentWrapperObj;
    }

    public void execute(QueueableContext context) {
        try{
            Map<String, String> paramValueMap = new Map<String, String>();
            for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c 
                                                                           FROM Integration_Static_Param__mdt 
                                                                           WHERE API_Name__c =: AUSF_ApexConstants.AUSF_EMAIL_INTEGRATION_MASTER]){
                                                                            paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
                                                                           }
                
                Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_EMAIL_INTEGRATION_MASTER);
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
                inputData.dynamicInputs.put('RequestId', AUSF_INT_IntegrationUtility.getReferenceId());
                inputData.dynamicInputs.put('Channel', objIntMapper.Channel__c);
                inputData.dynamicInputs.put('TO', toEmailId);
                inputData.dynamicInputs.put('Subject', subject);
                inputData.dynamicInputs.put('Text', message);
                inputData.dynamicInputs.put('FileName',documentWrapperObj != NULL ? documentWrapperObj.documentName : '');
                inputData.dynamicInputs.put('FileMimeType',documentWrapperObj != NULL ? paramValueMap.get('FileMimeType') : '');
                inputData.dynamicInputs.put('FileDataContent',documentWrapperObj != NULL ? documentWrapperObj.fileContent : '');
                AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
                AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
                List<ContentVersion> contentVersionList = new List<ContentVersion>();
                // Check for Pre-Requisite Errors    
                if (String.isNotBlank(requestDetails.preRequisites)) {
                    newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                    newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                    upsert newChecklistInstance;
                    Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(newChecklistInstance.Id);
                    throw new CustomException(requestDetails.preRequisites+'-'+objChecklist.Name);
                }
            AUSF_INT_EmailResponseWrapper objEmailResponse = new AUSF_INT_EmailResponseWrapper(); 
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper;
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = applicantObj.Id;
            if(documentWrapperObj != NULL && documentWrapperObj.fileContent != NULL){
                calloutRequestWrapper.captureRequestInAttachment = true;
            } 
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
                if(String.isNotBlank(calloutResponseWrapper.response)){
                    objEmailResponse = (AUSF_INT_EmailResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_EmailResponseWrapper.class);
                    objEmailResponse.responseWrapper = calloutResponseWrapper;
                    if (objEmailResponse != NULL && objEmailResponse.TransactionStatus != NULL && objEmailResponse.TransactionStatus.ResponseCode ==  '0') {
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
                }else{
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    upsert calloutRequestWrapper.checklistRecord;
                    Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                    strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - '+objChecklist.Name;
                    throw new CustomException(strIntMessage);
                }
            }
        }catch(exception objException){
            AUSF_Log.error(objException,AUSF_Log.SeverityType.High,applicantObj.Id != NULL ? applicantObj.Id : loanApplicationObj.Id,applicantObj.Id != NULL ? 'Applicant' : 'Loan Application',AUSF_ApexConstants.AUSF_EMAIL_INTEGRATION_MASTER);
        }    
    }
    public class CustomException extends Exception {}
}