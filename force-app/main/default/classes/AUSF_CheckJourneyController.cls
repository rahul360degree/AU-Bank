/**
* @author  Nitesh jaiswal
* @company Salesforce.com
* @description : This is the controller class of ausf_CheckJourneyCmp
* History:
*
*************************************************************************************
MODIFICATION LOG
* Version     Date                Developer            Description
*-------------------------------------------------------------------------------------------
*  1.0    28th June 2024          Nitesh jaiswal       Initial Creation 
*/

public without sharing class AUSF_CheckJourneyController {

    @AuraEnabled
    public static CheckJourneyWrapper getDedupeResult(string mobileNumber){
        CheckJourneyWrapper wrapperObj = new CheckJourneyWrapper();
        try {
            wrapperObj.dedupeResult = AUSF_LoanApplicationService.localDedupeSearch(new List<string>{mobileNumber});
            wrapperObj.leadStageList = AUSF_Utility.getRelatedLeadStage(mobileNumber);
            wrapperObj.userList = AUSF_Utility.getCurrentUserDetails();

        } catch (Exception e) {
            wrapperObj.errorMsg = e.getMessage();
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,null,'Check Journey');
        }
        system.debug(wrapperObj);
        return wrapperObj;
    }

    @AuraEnabled
    public static CheckJourneyWrapper createNewJourneyRecords(string mobileNumber){
        CheckJourneyWrapper wrapperObj = new CheckJourneyWrapper();
        try {
            wrapperObj.dataWrapper = AUSF_LoanApplicationService.createNewLoanApplication(new List<string>{mobileNumber});
        } catch (Exception e) {
            wrapperObj.errorMsg = e.getMessage();
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,null,'Check Journey');
        }
        system.debug(wrapperObj);
        return wrapperObj;
    }
    @AuraEnabled
    public static CheckJourneyWrapper updateLoanApplicationNumber(string applicantId){
        CheckJourneyWrapper wrapperObj = new CheckJourneyWrapper();
        try {
            AUSF_LoanApplicationService.populateLoanApplicationNumber(new List<string>{applicantId});
            wrapperObj.msg = 'success';
        } catch (Exception e) {
            wrapperObj.errorMsg = e.getMessage();
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,null,null,'IPA Screen');
        }
        system.debug(wrapperObj);
        return wrapperObj;
    }

    public class CheckJourneyWrapper{
        @auraEnabled
        public Map<String, AUSF_LoanApplicationService.DedupeResult> dedupeResult;
        @auraEnabled
        public AUSF_LoanApplicationService.RecordCreationResult dataWrapper;
        @auraEnabled
        public List<Lead_Stage__c> leadStageList;
        @auraEnabled
        public List<User> userList;
        @auraEnabled
        public String msg;
        @auraEnabled
        public String errorMsg;
    }

}