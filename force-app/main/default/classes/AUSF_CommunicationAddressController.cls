/**
* @author Ruturaj Chothe
* @company Salesforce.com
* @description Controller class for Ausf_CommunicationAddressCmp
* Test Class: AUSF_CommunicationAddressController_Test
* History:
*
*************************************************************************************
MODIFICATION LOG
* Version     Date                Developer            Description
*-------------------------------------------------------------------------------------------
*  1.0    16th July 2024          Ruturaj Chothe        Initial Creation and added method to reject the application
*  2.0    17th July 2024          Ruturaj Chothe        Added method to update tenure of address record
*/
public without sharing class AUSF_CommunicationAddressController {
    
    /*
    @ description   : rejectApplication
    @ US / Bug      : APL-731
    @ param1        : loanAppId: Loan Application ID
    @ param2        : applicantId: Applicant ID
    @ param3        : rejectionReason: Rejection reason for salaried person. 
                      Values: 'PEP', 'NRI'
    */
    @AuraEnabled
    public static void rejectApplication(String applicationId,String applicantId, String rejectionReason){
        try {   
            Applicant__c applicant = new Applicant__c(Id = applicantId);
            Loan_Application__c loanApp = new Loan_Application__c(id = (id)applicationId, Reject_Reason__c = AUSF_ApexConstants.AUSF_DECLARATION_REJECTION_REASON);
            if(rejectionReason == 'PEP'){
                loanApp.Reject_Reason__c = AUSF_ApexConstants.AUSF_PEP_REJECTION_REASON;
                loanApp.Reject_Sub_Reason__c = AUSF_ApexConstants.AUSF_PEP_REJECTION_CODE;
                applicant.PEP_Declaration__c = true;
            }else if(rejectionReason == 'NRI'){
                loanApp.Reject_Reason__c = AUSF_ApexConstants.AUSF_TAX_OTHER_THAN_INDIA_REJECTION_REASON;
                loanApp.Reject_Sub_Reason__c = AUSF_ApexConstants.AUSF_TAX_OTHER_THAN_INDIA_REJECTION_CODE;
                applicant.FATCA_Declaration__c = true;
            }
            Database.SaveResult[] saveResultArr = AUSF_DatabaseUtility.updateRecordsWithSaveResult(new List<SObject>{loanApp, applicant}, 'Loan_Application__c', null);
            AUSF_Utility.sendRejectionNotifications(applicationId, applicantId, 'NSDL_Rejection', null);
        } catch (Exception ex) {
            AUSF_Log.error(ex, AUSF_Log.SeverityType.valueOf('Medium'), null, null, null);
            
        }
    }

    /*
    @ description   : updateApplicantAddressTenure
    @ US / Bug      : APL-731
    @ param1        : addressId: address record id
    @ param2        : month: month
    @ param3        : year: year
    @ param4        : typeOfResidence: residence type of applicant
    @ param5        : applicantId: Applicant ID
    */
    @AuraEnabled
    public static void updateApplicantAddressTenure(String addressId, String month, String year, String typeOfResidence, String applicantId){
        List<Address__c> nonCommunicationAddressList = new List<Address__c>();
        try {   
            Address__c address = new Address__c(id = (id)addressId, Residence_Ownership_Type__c = typeOfResidence, Duration_of_Current_Stay_Months__c = month, Duration_of_Current_Stay_years__c = year, Is_Communication_Address__c = true);

            for(Address__c remainingAddress: [SELECT Id, Is_Communication_Address__c FROM Address__c WHERE Applicant__c = :applicantId AND Id != :addressId]){
                remainingAddress.Is_Communication_Address__c = false;
                nonCommunicationAddressList.add(remainingAddress);
            }

            Database.SaveResult[] commAddressSR = AUSF_DatabaseUtility.updateRecordsWithSaveResult(new List<Address__c>{address}, 'Address__c', null);
            Database.SaveResult[] nonCommAddressSR = AUSF_DatabaseUtility.updateRecordsWithSaveResult(nonCommunicationAddressList, 'Address__c', null);
        } catch (Exception ex) {
            AUSF_Log.error(ex, AUSF_Log.SeverityType.valueOf('Medium'), null, null, null);
            
        }
    }
}