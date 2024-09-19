/*******************************************************************************************
* @Name         AUSF_DatabaseUtility
* @Author       Mohit M.
* @Description  Utility class to insert/upsert operations
* @Test Class   AUSF_DatabaseUtility_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Mohit M.             25-June-2024            Initial Creation 
*******************************************************************************************/
public without sharing class AUSF_DatabaseUtility {
    public static void createRecords(List<sObject> sobjList, String sobjName, String strProcessName){
        List<Object> errorsList = new List<Object> ();
        Database.SaveResult[] dbResult = Database.insert(sobjList, false);
        for(Integer i=0; i<dbResult.size(); i++){
            if (!dbResult[i].isSuccess()) {
                for(Database.Error err : dbResult[i].getErrors()){
                    String errLog = 'Message = \'Error: \'' +err.getStatusCode() + ';  Field: '+err.getFields() + ';  Error Messages: ' +err.getMessage() + ';  Failed Record: '+ sobjList[i];
                    errorsList.add(errLog);
                }
            }
        }
        if(!errorsList.isEmpty()){
            AUSF_Log.error('',errorsList,AUSF_Log.SeverityType.valueOf('High'), '', sobjName, strProcessName);
        }
    }
    
    public static void updateRecords(List<sObject> sobjList, String sobjName, String strProcessName){
        List<Object> errorsList = new List<Object> ();
        Database.SaveResult[] dbResult = Database.update(sobjList, false);
        for(Integer i=0; i<dbResult.size(); i++){
            if (!dbResult[i].isSuccess()) {
                for(Database.Error err : dbResult[i].getErrors()){
                    String errLog = 'Message = \'Error: \'' +err.getStatusCode() + ';  Field: '+err.getFields() + ';  Error Messages: ' +err.getMessage() + ';  Failed Record: '+ sobjList[i];
                    errorsList.add(errLog);
                }
            }
        }
        if(!errorsList.isEmpty()){
            AUSF_Log.error('',errorsList,AUSF_Log.SeverityType.valueOf('High'), '', sobjName, strProcessName);
        }
    }
    
    public static void upsertRecords(List<sObject> sobjList, String sobjName, String strProcessName){
        List<Object> errorsList = new List<Object> ();
        Database.UpsertResult[] dbResult = Database.upsert(sobjList, false);
        for(Integer i=0; i<dbResult.size(); i++){
            if (!dbResult[i].isSuccess()) {
                for(Database.Error err : dbResult[i].getErrors()){
                    String errLog = 'Message = \'Error: \'' +err.getStatusCode() + ';  Field: '+err.getFields() + ';  Error Messages: ' +err.getMessage() + ';  Failed Record: '+ sobjList[i];
                    errorsList.add(errLog);
                }
            }
        }
        if(!errorsList.isEmpty()){
            AUSF_Log.error('',errorsList,AUSF_Log.SeverityType.valueOf('High'), '', sobjName, strProcessName);
        }
    }
    
    public static void deleteRecords(List<sObject> sobjList, String sobjName, String strProcessName){
        List<Object> errorsList = new List<Object> ();
        Database.DeleteResult[] dbResult = Database.delete(sobjList, false);
        for(Integer i=0; i<dbResult.size(); i++){
            if (!dbResult[i].isSuccess()) {
                for(Database.Error err : dbResult[i].getErrors()){
                    String errLog = 'Message = \'Error: \'' +err.getStatusCode() + ';  Field: '+err.getFields() + ';  Error Messages: ' +err.getMessage() + ';  Failed Record: '+ sobjList[i];
                    errorsList.add(errLog);
                }
            }
        }
        if(!errorsList.isEmpty()){
            AUSF_Log.error('',errorsList,AUSF_Log.SeverityType.valueOf('High'), '', sobjName, strProcessName);
        }
    }
    
    public static Database.SaveResult[] updateRecordsWithSaveResult(List<sObject> sobjList, String sobjName, String strProcessName){
        List<Object> errorsList = new List<Object> ();
        Database.SaveResult[] dbResult = Database.update(sobjList, false);
        for(Integer i=0; i<dbResult.size(); i++){
            if (!dbResult[i].isSuccess()) {
                for(Database.Error err : dbResult[i].getErrors()){
                    String errLog = 'Message = \'Error: \'' +err.getStatusCode() + ';  Field: '+err.getFields() + ';  Error Messages: ' +err.getMessage() + ';  Failed Record: '+ sobjList[i];
                    errorsList.add(errLog);
                }
            }
        }
        if(!errorsList.isEmpty()){
            AUSF_Log.error('',errorsList,AUSF_Log.SeverityType.valueOf('High'), '', sobjName, strProcessName);
        }
        return dbResult; //return SaveResult array back to calling method
    }
    
    public static Database.SaveResult[] createRecordsWithSaveResult(List<sObject> sobjList, String sobjName, String strProcessName){
        List<Object> errorsList = new List<Object> ();
        Database.SaveResult[] dbResult = Database.insert(sobjList, false);
        for(Integer i=0; i<dbResult.size(); i++){
            if (!dbResult[i].isSuccess()) {
                for(Database.Error err : dbResult[i].getErrors()){
                    String errLog = 'Message = \'Error: \'' +err.getStatusCode() + ';  Field: '+err.getFields() + ';  Error Messages: ' +err.getMessage() + ';  Failed Record: '+ sobjList[i];
                    errorsList.add(errLog);
                }
            }
        }
        if(!errorsList.isEmpty()){
            AUSF_Log.error('',errorsList,AUSF_Log.SeverityType.valueOf('High'), '', sobjName, strProcessName);
        }
        return dbResult; //return SaveResult array back to calling method
    }
}