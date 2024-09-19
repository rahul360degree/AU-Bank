/*******************************************************************************************
* @Name         AUSF_CFRCheck
* @Author       Charchit Nirayanwal
* @Description  
* @Test Class   AUSF_CFRCheckTest
*******************************************************************************************/
/* MODIFICATION LOG
* Version                   Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Charhit Nirayanwal            09-July-2024            Initial Creation 
*******************************************************************************************/

public without Sharing class AUSF_CFRCheck {
   /*
   	@params applicantId (Applicant Record ID), loanApplicationId (Loan Application Record Id)
	@Returns CFR Found - true, CFR Not Found - False, Error - NULL
   */
    
    @AuraEnabled
    public static boolean checkCFR(id applicantId, id loanApplicationId){
        
        try{
            //Check if Pan Value present in any cfr
            List<Applicant__c> appRec = [select Id, PAN__c, Loan_Application__c, CFR_Check__c from Applicant__c where Id=:applicantId];
            if(appRec.size() == 1){
                List<CFR_Master__c> cfrRec = [select id from CFR_Master__c where PAN__c = :appRec[0].PAN__c];
                if(cfrRec.size()>0){
                    appRec[0].CFR_Check__c = AUSF_ApexConstants.AUSF_True;
                    Loan_Application__c loanAppRec = new Loan_Application__c(Id=appRec[0].Loan_Application__c, Reject_Reason__c = AUSF_ApexConstants.AUSF_CFR_Check_Reject_Reason, Reject_Sub_Reason__c = AUSF_ApexConstants.AUSF_CFR_Check_Reject_Sub_Reason, stage__c='Reject');
                    Update loanAppRec;
                    Update appRec;
                    AUSF_NotificationController.sendAllNotification(null, null, applicantId, appRec[0].Loan_Application__c, 'CFR_Reject', userinfo.getUserId());
                    return true;
                }
                else if (appRec[0].CFR_Check__c != AUSF_ApexConstants.AUSF_False) {
                    appRec[0].CFR_Check__c = AUSF_ApexConstants.AUSF_False;
                    Update appRec;
                }
            }
            else{
                throw new CustomException (AUSF_ApexConstants.AUSF_NotValidAppliacantId);
            }
        }
        catch(exception e){
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,applicantId,'Applicant','CFR check');
            return null;
        }
        return false;
    }

    public class CustomException extends exception {}
}