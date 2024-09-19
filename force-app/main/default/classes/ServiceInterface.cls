/*******************************************************************************************
* @Name         ServiceInterface 
* @Author       Mohit M.
* @Description  This acts as an interface for service class creation for apex triggers.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0             Mohit M.         24-June-2024        Initial Creation
*******************************************************************************************/
public interface ServiceInterface {
    void beforeInsert(List<sObject> newRecordList);

    void afterInsert(List<sObject> newRecordList, Map<Id,sObject> newRecordMap);

    void beforeUpdate(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap);

    void afterUpdate(List<sObject> newRecordList, Map<Id,sObject> oldRecordMap, Map<Id,sObject> newRecordMap);

    void beforeDelete(Map<Id,sObject> oldRecordMap);

    void afterDelete(Map<Id,sObject> oldRecordMap);

    void afterUndelete(Map<Id,sObject> newRecordList);
}