/*******************************************************************************************
* @Name         AUSF_ApplicantTriggerService
* @Author       Mohit M.
* @Description  Trigger Service class for Applicant Trigger - common methods are written in this class
* @Test Class   AUSF_ApplicantTriggerService_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Mohit M.             25-June-2024            Initial Creation 
*******************************************************************************************/
public without sharing class AUSF_ApplicantTriggerService implements ServiceInterface {
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
        Set<String> setApplicantIds = new Set<String>();
        List<Applicant__c> newLoanApplication = (List<Applicant__c>) newRecordMap.values();
        for (Applicant__c objApplicant : newLoanApplication) {
            setApplicantIds.add(objApplicant.Id);
        }
        // Create Document Checklist Records
        if (setApplicantIds.size()>0) {
            createChecklists (setApplicantIds, true);
        }

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
        List<Applicant__c> lstApplicant = new List<Applicant__c>();
        for(Applicant__c applicant : (List<Applicant__c>)newRecordList){
            Applicant__c objOldApplicant = (Applicant__c)oldRecordMap.get(applicant.Id);
            // Check for AML Rejection
            if(objOldApplicant.AML_verified__c != applicant.AML_verified__c && applicant.AML_verified__c == AUSF_ApexConstants.AUSF_AML_VERIFIED_YES){
                lstApplicant.add(applicant);
            }
        }
        if (lstApplicant.size()>0) {
            amlRejectLoanApplication(lstApplicant); //APL-217
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
    @method - createChecklists - to create Document Checklist records related to Applicant
    @param1 - setApplicantIds - Set of Applicant Ids
    */
    public void createChecklists(Set<String> setApplicantIds, Boolean blnInsert) {
        system.debug('checklist>>>');
        AUSF_RuleEngineHandler getDocChecklists = new AUSF_RuleEngineHandler();
        List<Document_Checklist__c> checklistsToInsert = new List<Document_Checklist__c>();
        Map<Id, Set<String>> mapLoanIdWithDocDetails = new Map <Id, Set<String>>();
        try {
            for (Document_Checklist__c objDoc : [SELECT Id, Document_Master__r.Document_ID__c, Loan_Application__c FROM Document_Checklist__c WHERE Applicant__c in: setApplicantIds]) {
                Set<String> setDocId = mapLoanIdWithDocDetails.containsKey(objDoc.Loan_Application__c) ? mapLoanIdWithDocDetails.get(objDoc.Loan_Application__c) : new Set<String>();
                setDocId.add(objDoc.Document_Master__r.Document_ID__c.toUpperCase());
                mapLoanIdWithDocDetails.put(objDoc.Loan_Application__c,setDocId);
            }

            Map<Id, Set<String>> documentMasterIdsByApplicant = getDocumentIds(getDocChecklists.main('Applicant__c', setApplicantIds, new Set<String>(), 'Document Checklist'));
            Map<String,Document_Master__c> docMasterMap = new Map<String,Document_Master__c>();
            System.debug('***doc Ids: '+documentMasterIdsByApplicant.keySet());
            
            for(Document_Master__c each : [SELECT Id, Name, Document_Sub_Category__c FROM Document_Master__c WHERE Document_ID__c IN: documentMasterIdsByApplicant.keySet()]){
                docMasterMap.put(each.Document_ID__c,each);                                 
            }
            
            for (Id each : documentMasterIdsByApplicant.keySet()) {
                for (String eachMasterId : documentMasterIdsByApplicant.get(each)) {
                    Document_Master__c currentRec = docMasterMap.containsKey(eachMasterId) ? docMasterMap.get(eachMasterId) : new Document_Master__c(); 
                    checklistsToInsert.add(new Document_Checklist__c
                                        (Applicant__c = each, 
                                            Document_Master__r = new Document_Master__c(Document_ID__c = eachMasterId),
                                            Category__c = currentRec.Document_Sub_Category__c,
                                            Sub_Category__c = currentRec.Name,
                                            Active__c = true
                                        )
                                        );
                }
            }
            AUSF_DatabaseUtility.createRecords(checklistsToInsert, AUSF_ApexConstants.DOCUMENT_CHECKLIST_OBJECT_LABEL, AUSF_ApexConstants.DOCUMENT_CHECKLIST_INSERT_PROCESS_NAME);     
        }
        catch (Exception ex) {
            system.debug(LoggingLevel.Error,'****err' + ex.getMessage());
        }
    }
    
    private Map<Id, Set<String>> getDocumentIds(String breJSONString) {
        Map<Id, Set<String>> returnValue = new Map<Id, Set<String>>();
        Map<String, Object> applicantChecklists = (Map<String, Object>) JSON.deserializeUntyped(breJSONString);
        Map<String, Object> checklists = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(applicantChecklists.get('Value')));
        if(checklists != null){
            for (String each : checklists.keySet()) {
                Set<String> masterIds = new Set<String>();
                List<Object> checklistsOfApp = (List<Object>) JSON.deserializeUntyped(JSON.serialize(checklists.get(each)));
                for (Object eachObject : checklistsOfApp) {
                    Map<String, Object> objProperties = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(eachObject));
                    masterIds.add((String) objProperties.get('TV'));
                }
                returnValue.put(each, masterIds);
            }
        }
        return returnValue;
    }
    
    /*
    @method - amlRejectLoanApplication - to reject loan application and send sms to customer
    @param1 - newRecordList - List of new records 
    */
    public static void amlRejectLoanApplication(List<Applicant__c> newRecordList) {
        List<Loan_Application__c> loanApplicationList = new List<Loan_Application__c>();
        for(Applicant__c applicant : newRecordList){
            Loan_Application__c loanApplication = new Loan_Application__c();
            loanApplication.Id = applicant.Loan_Application__c;
            loanApplication.Stage__c = AUSF_ApexConstants.AUSF_REJECT;
            loanApplication.Reject_Reason__c = AUSF_ApexConstants.AUSF_AML_REJECT_REASON;
            loanApplication.Reject_Sub_Reason__c = AUSF_ApexConstants.AUSF_AML_REJECT_SUB_REASON;	                                        
            loanApplicationList.add(loanApplication);
        }
        if (loanApplicationList.size()>0) {
           update loanApplicationList;
        }
        for(Applicant__c applicant : newRecordList) {
            String strTriggerPoint = AUSF_ApexConstants.AUSF_TriggerPoint_Case_Rejection; 
            AUSF_Utility.sendRejectionNotifications(applicant.Loan_Application__c,applicant.Id,strTriggerPoint,null);
        }
    }
}