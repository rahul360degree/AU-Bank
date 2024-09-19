/*******************************************************************************************
* @Name         AUSF_IntegrationChecklistTriggerService
* @Author       Mohit M.
* @Description  Trigger Service class for Loan Application Trigger - common methods are written in this class
* @Test Class   AUSF_IntegrationChecklistTriggerService_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Mohit M.             12-July-2024            Initial Creation
*******************************************************************************************/
public without sharing class AUSF_IntegrationChecklistTriggerService implements ServiceInterface {
    /*
    @method - beforeInsert - run on beforeInsert event
    @param1 - newRecordList - List of new sObject Records
    */    
    public void beforeInsert(List<sObject> newRecordList) {

    }
    
    /*
    @method - afterInsert - run on afterInsert event
    @param1 - newRecordList - List of new sObject Records
    @param2 - newRecordMap - map of new sObject Records
    */ 
    public void afterInsert(List<sObject> newRecordList, Map<Id,sObject> newRecordMap) {
        
    }
    
    /*
    @method - beforeUpdate - run on beforeUpdate event
    @param1 - newRecordList - List of new sObject Records
    @param2 - oldRecordMap - map of old sObject Records with old values
    @param2 - newRecordMap - map of new sObject Records with new values
    */ 
    public void beforeUpdate(List<sObject> newRecordList, Map<Id, sObject> oldRecordMap,Map<Id, sObject> newRecordMap) { 
        
    }
    
    /*
    @method - afterUpdate - run on afterUpdate event
    @param1 - newRecordList - List of new sObject Records
    @param2 - oldRecordMap - map of old sObject Records with old values
    @param2 - newRecordMap - map of new sObject Records with new values
    */ 
    public void afterUpdate(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap) {
        //APL-217 start
        List<Applicant__c> applicantList = new List<Applicant__c>();
        List<Integration_Checklist__c> breIntCheckList = new List<Integration_Checklist__c>();
        for(Integration_Checklist__c integCheckRec : (List<Integration_Checklist__c>)newRecordList) {
            Integration_Checklist__c oldIntegrationChecklist = (Integration_Checklist__c)oldRecordMap.get(integCheckRec.Id);
            /* START - Check for AML Callback */
            if(integCheckRec.Integration_Master_Name__c == AUSF_ApexConstants.AUSF_AML_INTEGRATION_MASTER && String.isNotBlank(integCheckRec.Callback_Request__c) && String.isBlank(oldIntegrationChecklist.Callback_Request__c)){    
                AUSF_INT_DOAMLResponseWrapper amlCallbackResponse = (AUSF_INT_DOAMLResponseWrapper)JSON.deserialize(integCheckRec.Callback_Request__c, AUSF_INT_DOAMLResponseWrapper.Class);
                Applicant__c applicantObj = new Applicant__c(Id = integCheckRec.Applicant__c);
                if(amlCallbackResponse.AML_Action == 'Approved') {
                    applicantObj.AML_verified__c = AUSF_ApexConstants.AUSF_AML_VERIFIED_NO;
                }
                if(amlCallbackResponse.AML_Action == 'Rejected') {
                    applicantObj.AML_verified__c =  AUSF_ApexConstants.AUSF_AML_VERIFIED_YES;
                }
                applicantList.add(applicantObj);
            }
            /* END - Check for AML Callback */
            if(integCheckRec.Integration_Master_Name__c == AUSF_ApexConstants.FICO_BRE_KNOCKOUT_INTEGRATION_MASTER && String.isNotBlank(integCheckRec.Callback_Request__c) && String.isBlank(oldIntegrationChecklist.Callback_Request__c)){
                breIntCheckList.add(integCheckRec);
            }
        }
        // Update Applicant - AML Callback
        updateApplicantAfterAMLCallback(applicantList);
        //APL-217 end
        if(!breIntCheckList.isEmpty()){
            AUSF_INT_BRE_Controller.handleBreResponse(breIntCheckList[0].Callback_Request__c, NULL, breIntCheckList[0]);
        }
    }
    /*
    @method - beforeDelete - run on beforeDelete event
    @param1 - oldRecordMap - map of old sObject Records with old values
    */ 
    public void beforeDelete(Map<Id,sObject> oldRecordMap) {
    }
    
    /*
    @method - afterDelete - run on afterDelete event
    @param1 - oldRecordMap - map of old sObject Records with old values
    */ 
    public void afterDelete(Map<Id,sObject> oldRecordMap) {
    }
    
    /*
    @method - afterUndelete - run on afterUnDelete event
    @param1 - newRecordList - map of new sObject Records
    */ 
    public void afterUndelete(Map<Id,sObject> newRecordList) {
    }
    
    /*
    @method - updateApplicantAfterAMLCallback - run on after update event for updating applicant AML Verified field
    @param1 - applicantList - list of Applicant Records
    */ 
    public void updateApplicantAfterAMLCallback(List<Applicant__c> applicantList) {
        if(applicantList!=NULL && applicantList.size() >0){
            update applicantList;
        }
    }
}