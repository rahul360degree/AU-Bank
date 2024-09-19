/*******************************************************************************************
* @Name         AUSF_DocumentChecklistTriggerService
* @Author       Mohit M.
* @Description  Trigger Service class for Loan Application Trigger - common methods are written in this class
* @Test Class   AUSF_DocumentChecklistTriggerService_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Mohit M.             12-July-2024            Initial Creation
*******************************************************************************************/
public with sharing class AUSF_DocumentChecklistTriggerService {
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
}