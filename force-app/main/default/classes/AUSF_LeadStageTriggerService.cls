/*******************************************************************************************
* @Name         AUSF_LeadStageTriggerService
* @Author       Murtaza Ali
* @Description  Trigger Service class for Lead Stage Trigger - common methods are written in this class
* @Test Class   AUSF_LeadStageTriggerService_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Murtaza Ali.             28-June-2024            Initial Creation 
*******************************************************************************************/
public without sharing class AUSF_LeadStageTriggerService implements ServiceInterface {
    /*
    @method - beforeInsert - run on beforeInsert event
    @param1 - newRecordList - List of new sObject Records
    */    
    public void beforeInsert(List<sObject> newRecordList) {
        populateSourcingChannelAndName(newRecordList);
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

    /** 
	* @description Function to populate lead stage sourcing channel and channel name
	* Inputs: List of lead stage Records 
	* Returns: void
    * Jira Story :- APL-606
	*/
    @testVisible
    private void populateSourcingChannelAndName(List<sObject> newRecordList){
        try{
            // Get the current user's profile name
            String currentUserProfileName = [SELECT Profile.Name FROM User WHERE Id = :UserInfo.getUserId()].Profile.Name;
            String currentUserName = UserInfo.getName();

            for (Lead_Stage__c loanApp : (List<Lead_Stage__c> )newRecordList) {
                if (currentUserProfileName == AUSF_ApexConstants.AUSF_DSA_PROFILE) {
                    loanApp.Sourcing_Channel__c = AUSF_ApexConstants.AUSF_DSA_PROFILE;
                    loanApp.Sourcing_Channel_Name__c = currentUserName;
                } else if (currentUserProfileName == AUSF_ApexConstants.AUSF_TCU_PROFILE) {
                    loanApp.Sourcing_Channel__c = AUSF_ApexConstants.AUSF_TCU_PROFILE;
                    loanApp.Sourcing_Channel_Name__c = currentUserName;
                } else if (currentUserProfileName == AUSF_ApexConstants.AUSF_GUEST_USER_PROFILE) {
                    loanApp.Sourcing_Channel__c = AUSF_ApexConstants.AUSF_DIY_CHANNEL;
                    loanApp.Sourcing_Channel_Name__c = AUSF_ApexConstants.AUSF_BLANK;
                }else if(currentUserProfileName == AUSF_ApexConstants.AUSF_SALES_PROFILE){
                    loanApp.Sourcing_Channel__c = AUSF_ApexConstants.AUSF_DST;
                    loanApp.Sourcing_Channel_Name__c = currentUserName;
                }
            }
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium);
        }
    }
}