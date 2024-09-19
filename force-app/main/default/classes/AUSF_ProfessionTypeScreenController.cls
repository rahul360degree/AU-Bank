/**
* @author Ruturaj Chothe
* @company Salesforce.com
* @description Controller class for AUSF_ProfessionTypeCmp
* Test Class: AUSF_ProfessionTypeScreenController_Test
* History:
*
*************************************************************************************
MODIFICATION LOG
* Version     Date                Developer            Description
*-------------------------------------------------------------------------------------------
*  1.0    7th August 2024          Ruturaj Chothe        Initial Creation and added method to reject the application
*/
public without sharing class AUSF_ProfessionTypeScreenController {
    
    /*
    @ description   : fetches active employment details record
    @ US / Bug      : APL-722
    @ param1        : applicantId: Applicant ID
    */
    @AuraEnabled
    public static List<Employment_Detail__c> getActiveEmploymentDetailRecords(String applicantId){
        try {
            return [SELECT Id, Name,RecordType.Name, Document_Number__c, Others_Business_Proof_Name__c, Date_of_Incorporation__c, Registered_Business_name__c,
                       Sector__c, Industry__c, Sub_Industry__c, Activity__c
                FROM Employment_Detail__c
                WHERE Applicant__c = :applicantId and Active__c	= true];
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.valueOf('Medium'), null, null, null);
            throw new AuraHandledException(e.getMessage());
        }
    }

    /*
    @ description   : Sets the employment detail with given name as active and rest as inactive
    @ US / Bug      : APL-722
    @ param1        : applicantId: Applicant ID
    @ param2        : recordType: REcordType LAbel of selected profession proof method
    */
    @AuraEnabled
    public static String updateRemainingEmploymentDetailsRecords(String applicantId,String recordType){
        try {
            List<Id> empRecIdsList = new List<Id>{};
            String activeEmploymentDetailId;
            List<Employment_Detail__c> employmentDetailRecordsList = [SELECT Id, Name, RecordType.Name, Document_Number__c, Others_Business_Proof_Name__c, Date_of_Incorporation__c, Registered_Business_name__c,
                       Sector__c, Industry__c, Sub_Industry__c, Activity__c
                FROM Employment_Detail__c
                WHERE Applicant__c = :applicantId];
            
            for(Employment_Detail__c empDetail: employmentDetailRecordsList){
                empRecIdsList.add(empDetail.Id);
                if(empDetail.RecordType.Name == recordType){
                    empDetail.Active__c = true;
                    activeEmploymentDetailId = empDetail.Id;
                }else{
                    empDetail.Active__c = false;
                }
            }

            List<Document_Checklist__c> dclist = [SELECT Id, Active__c, Employment_Detail__c FROM Document_Checklist__c WHERE Employment_Detail__c IN :empRecIdsList ];
            for(Document_Checklist__c docChklst: dclist){
                if(docChklst.Employment_Detail__c == (ID)activeEmploymentDetailId){
                    docChklst.Active__c = true;
                }else{
                    docChklst.Active__c = false;
                }
            }
            

            List<SObject> recordsToUpdate = new List<SObject>();
            recordsToUpdate.addAll(employmentDetailRecordsList);
            recordsToUpdate.addAll(dclist);

            if(recordsToUpdate.size() > 0){
                update recordsToUpdate;
            }

            return activeEmploymentDetailId;

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.valueOf('Medium'), null, null, null);
            return null;
        }
    }
}