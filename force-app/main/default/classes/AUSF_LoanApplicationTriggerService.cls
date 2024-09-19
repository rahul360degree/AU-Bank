/*******************************************************************************************
* @Name         AUSF_LoanApplicationTriggerService
* @Author       Mohit M.
* @Description  Trigger Service class for Loan Application Trigger - common methods are written in this class
* @Test Class   AUSF_LoanApplicationTriggerService_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Mohit M.             28-June-2024            Initial Creation 
*  2.0             Murtaza Ali			26-June-2024            Add Populate Initial Loan Application number method
*  3.0      	   Murtaza Ali          27-June-2024            Add Populate Sourcing Channel and Channel Name
*******************************************************************************************/
public without sharing class AUSF_LoanApplicationTriggerService implements ServiceInterface {
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
        Set<String> setLoanIds = new Set<String>();
        List<Loan_Application__c> newLoanApplication = (List<Loan_Application__c>) newRecordMap.values();
        List<Loan_Application__c> loanApplicationsToUpdate = new List<Loan_Application__c>();
        for (Loan_Application__c objLA : newLoanApplication) {
            setLoanIds.add(objLA.Id);
            /* START - AUPL-700 - Assigned Name to Loan Application Number */
            if (objLA.Name != null && objLA.Stage__c==AUSF_ApexConstants.AUSF_CUSTOMER_ONBOARDING && objLA.Name!=objLA.Lead_reference_number__c) {
                Loan_Application__c loanRec = new Loan_Application__c(ID=objLA.Id);
                loanRec.Name = objLA.Lead_reference_number__c;
                loanApplicationsToUpdate.add(loanRec);
            }
            /* END - AUPL-700 - Assigned Name to Loan Application Number */
        }
        // Create Document Checklist Records
        if (setLoanIds.size()>0) {
            createChecklists (setLoanIds, true);
        }
        // AUPL-700 - Update the Loan Application records
        if (!loanApplicationsToUpdate.isEmpty()) {
            update loanApplicationsToUpdate;
        }
        //populateInitialLoanApplicationNumber(newRecordList);
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

    /*
    @method - createChecklists - to create Document Checklist records related to Application
    @param1 - loanIds - Set of Loan Ids
    */
    public void createChecklists(Set<String> loanIds, Boolean blnOnInsert) {
        AUSF_RuleEngineHandler getDocChecklists = new AUSF_RuleEngineHandler();
        List <Document_Checklist__c> checklistsToInsert = new List <Document_Checklist__c> ();
        Map<Id, Set<String>> mapLoanIdWithDocDetails = new Map <Id, Set<String>>();
        try{
            
            for (Document_Checklist__c objDoc : [SELECT Id, Document_Master__r.Document_ID__c, Loan_Application__c FROM Document_Checklist__c WHERE Loan_Application__c in: loanIds AND Applicant__c = NULL]) {
                Set<String> setDocId = mapLoanIdWithDocDetails.containsKey(objDoc.Loan_Application__c) ? mapLoanIdWithDocDetails.get(objDoc.Loan_Application__c) : new Set<String>();
                setDocId.add(objDoc.Document_Master__r.Document_ID__c.toUpperCase());
                mapLoanIdWithDocDetails.put(objDoc.Loan_Application__c,setDocId);
            }
            Map <Id, Set <String>> documentMasterIdsByApp = getDocumentIds(getDocChecklists.main('Loan_Application__c', loanIds, new Set<String>(), 'Document Checklist'));
            Map <String, Document_Master__c> docMasterMap = new Map <String, Document_Master__c> ();
            for (Document_Master__c each: [SELECT Id, Name, Document_Sub_Category__c,Document_Name__c, Document_ID__c FROM Document_Master__c WHERE Document_ID__c IN: documentMasterIdsByApp.keySet()]) {
                docMasterMap.put(each.Document_ID__c, each);
            }
            for (Id each: documentMasterIdsByApp.keySet()) {
                for (String eachMasterId: documentMasterIdsByApp.get(each)) {
                    if (mapLoanIdWithDocDetails.containsKey(each) && mapLoanIdWithDocDetails.get(each).contains(eachMasterId.toUpperCase())) {
                        continue;
                    }
                    Document_Master__c currentRec = docMasterMap.containsKey(eachMasterId) ? docMasterMap.get(eachMasterId) : new Document_Master__c();
                    checklistsToInsert.add(new Document_Checklist__c(Loan_Application__c = each,
                                                                     Document_Master__r = new Document_Master__c(Document_ID__c = eachMasterId),
                                                                     Category__c = currentRec.Document_Sub_Category__c,
                                                                     Sub_Category__c = currentRec.Name,
                                                                     Document_Name__c = currentRec.Document_Name__c,
                                                                     Active__c = true
                                                                    ));
                }
            }
            if (checklistsToInsert.size()>0)
                AUSF_DatabaseUtility.createRecords(checklistsToInsert, AUSF_ApexConstants.DOCUMENT_CHECKLIST_OBJECT_LABEL, AUSF_ApexConstants.DOCUMENT_CHECKLIST_INSERT_PROCESS_NAME);
        } catch (Exception ex) {
            system.debug(LoggingLevel.Error,'****err' + ex.getMessage());
        }
    }

    private Map <Id, Set <String>> getDocumentIds(String breJSONString) {
        Map <Id, Set <String>> returnValue = new Map <Id, Set <String>> ();
        Map <String, Object> applicantChecklists = (Map <String, Object> ) JSON.deserializeUntyped(breJSONString);
        Map <String, Object> checklists = (Map <String, Object> ) JSON.deserializeUntyped(JSON.serialize(applicantChecklists.get('Value')));
        if (checklists != null) {
            for (String each: checklists.keySet()) {
                Set <String> masterIds = new Set <String> ();
                List <Object> checklistsOfApp = (List <Object> ) JSON.deserializeUntyped(JSON.serialize(checklists.get(each)));
                for (Object eachObject: checklistsOfApp) {
                    Map <String, Object> objProperties = (Map <String, Object> ) JSON.deserializeUntyped(JSON.serialize(eachObject));
                    masterIds.add((String) objProperties.get('TV'));
                }
                returnValue.put(each, masterIds);
            }
        }
        return returnValue;
    }
    /** 
	* @description Function to populate Loan Application Number as initial Lead Reference Number after insert
	* Inputs: List of Loan Application Records 
	* Returns: void
    * Jira Story :- APL-700
	*
    public void populateInitialLoanApplicationNumber(List<sObject> newRecordList){
        try{
            List<Loan_Application__c> loanApplicationsToUpdate = new List<Loan_Application__c>();
            for (Loan_Application__c loanApp : (List<Loan_Application__c> )newRecordList) {
                // Check if the Loan Application Number (standard Name field) is populated
                if (loanApp.Name != null && loanApp.Stage__c==AUSF_ApexConstants.AUSF_LEAD && loanApp.Name!=loanApp.Lead_reference_number__c) {
                    Loan_Application__c loanRec = new Loan_Application__c(ID=loanApp.Id);
                    loanRec.Name = loanApp.Lead_reference_number__c;
                    loanApplicationsToUpdate.add(loanRec);
                }
            }
            if (!loanApplicationsToUpdate.isEmpty()) {
                // Update the Loan Application records
                update loanApplicationsToUpdate;
            }
        } catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium);
        }
    }
    */
}