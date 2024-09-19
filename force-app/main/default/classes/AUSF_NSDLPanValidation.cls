/**
 * @description       : APL-631
 * @author            : Ruturaj Chothe
 * @group             : 
 * @last modified on  : 07-02-2024
 * @last modified by  : Ruturaj Chothe
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-27-2024   Ruturaj Chothe   Initial Version
**/
public without sharing class AUSF_NSDLPanValidation {
    
    @AuraEnabled
    public static Integer getRemainingPANValidationAttempts(String applicationId, String applicantId){
        Integration_Master__c nsdlMaster = [
            SELECT id, Name, Max_number_of_retries_allowed__c
            FROM Integration_Master__c
            WHERE Name = :'NSDL - PAN Verification' and Active__c = true
            LIMIT 1
        ];
        Integer maxAllowed = (Integer)nsdlMaster.Max_number_of_retries_allowed__c;

        List<Integration_Checklist__c> existingAttempts = [
            SELECT Id, Status__c, Integration_Master__r.Name, Applicant__c FROM Integration_Checklist__c 
            WHERE Applicant__c = :ApplicantId AND Integration_Master__r.Name = 'NSDL - PAN Verification'
        ];

        Integer numOfExistingAttempts = existingAttempts.size();

        if(numOfExistingAttempts == 0){
            return maxAllowed;
        }else if(maxAllowed - numOfExistingAttempts > 0){
            return maxAllowed - numOfExistingAttempts;
        }else{
            return 0;
        }
    }
    
    @AuraEnabled
    public static Boolean ifrFraudCheck(string pan, string applicationId, String applicantId){
        try {
            // Do fraud check
            List<IFR_Master__C> fraudRecordsList = [SELECT Id, Name, CIF__c, Name_as_per_PAN__c FROM IFR_Master__C WHERE Name = :pan];
            if(fraudRecordsList.size() > 0){
                // Reject application
                Loan_Application__c loanApp = new Loan_Application__c(id = (id)applicationId);
                loanApp.Reject_Sub_Reason__c = 'D004';
                AUSF_DatabaseUtility.updateRecords(new List<Loan_Application__c>{loanApp}, 'Loan_Application__c', null);

                Applicant__c loanApplicant = new Applicant__c(id = (id)applicantId, IFR_Check__c = 'True');
                AUSF_DatabaseUtility.updateRecords(new List<Applicant__c>{loanApplicant}, 'Applicant__c', null);
                return false;
            }
        return true;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @AuraEnabled(Cacheable=true)
    public static List<AUSF_Screen_Custom_Text__mdt> getScreenCustomTextRecords(String screenName) {
        try {
            return [SELECT Id, DeveloperName, MasterLabel, Label, QualifiedApiName, Product__c, Custom_String__c, Screen_Name__c,Custom_String_for_DIY__c FROM AUSF_Screen_Custom_Text__mdt where Screen_Name__c =:screenName LIMIT 1000];
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,'AUSF Screen Custom Text',screenName);
            return null;
        }
    }


    @AuraEnabled(Cacheable=true)
    public static List<Generic_Master__c> getGenericMasterRecords(String Name) {
        
        return [SELECT Id, Custom_String__c,Custom_String_for_DIY__c, Name
                FROM Generic_Master__c 
                WHERE Name =:name
                LIMIT 1];
                
    }

    

}