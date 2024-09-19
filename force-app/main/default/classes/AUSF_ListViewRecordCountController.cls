/**
* @author Asmita Mathur
* @company Salesforce.com
* @description A generic class for fetching list views of an object and filter the records based on the filter conditions
* Test Class: AUSF_ListViewRecordCountController_Test
* History:
*
*****************************************************************************************************************************
MODIFICATION LOG
* Version     Date                Developer            Description
*----------------------------------------------------------------------------------------------------------------------------
*  1.0    26th July 2024          Asmita Mathur        Initial Creation and added methods for getting list view details of object and filter records based on filter criterias
*/

public with sharing class AUSF_ListViewRecordCountController {
    
    @AuraEnabled(cacheable=true)
    public static List<ListView> getListViews(String ObjectName) {
        try{
            List<ListView> lstView = [SELECT Id,Name,DeveloperName FROM ListView where SObjectType =:ObjectName];
            return lstView;
        }catch(Exception e){
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,'',null,'');
            return null;
        }
    }

    @AuraEnabled(cacheable=true)
    public static Integer getFilteredRecordCount(String filterCondition){
       try{
            String query = 'SELECT COUNT() FROM Loan_Application__c WHERE ' + filterCondition; 
            Integer recCount = Database.countQuery(query);
            return recCount;   
        }catch(Exception e){
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,'',null,'');
            return null;
        }
    }
}