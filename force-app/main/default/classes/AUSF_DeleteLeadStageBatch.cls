/*******************************************************************************************
* @Name         AUSF_DeleteLeadStageBatch
* @Author       Murtaza Ali
* @Description  Batch Class to Lead Stage record for every day
* @Test Class   AUSF_DeleteLeadStageBatch_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Murtaza Ali.             28-June-2024            Initial Creation 
*******************************************************************************************/
public with sharing class AUSF_DeleteLeadStageBatch implements Database.Batchable<SObject>, Schedulable, Database.Stateful {
    
    public Database.QueryLocator start(Database.BatchableContext BC) {
        // Query to select the records created today
        return Database.getQueryLocator([
            SELECT Id
            FROM Lead_Stage__c
            WHERE CreatedDate = TODAY
        ]);
    }
    
    public void execute(Database.BatchableContext BC, List<Lead_Stage__c> scope) {
        try{
            // Delete the records in the current scope
            delete scope;
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium);
        }
        
    }
    
    public void finish(Database.BatchableContext BC) {
        // Optional: Add any post-processing logic here
    }
    
    public void execute(SchedulableContext SC) {
        // Instantiate the batch class and execute it
        Database.executeBatch(this);
    }
}