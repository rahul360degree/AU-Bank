/*******************************************************************************************
* @Name         AUSF_NotificationController
* @Author       Charchit Nirayanwal
* @Description  
* @Test Class   AUSF_NotificationControllerTest
*******************************************************************************************/
/* MODIFICATION LOG
* Version                   Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Charhit Nirayanwal            03-July-2024            Initial Creation 
*******************************************************************************************/
public without sharing class AUSF_NotificationController {
    
    @AuraEnabled
    public static string sendAllNotification (Applicant__c objApp, Loan_Application__c objLoan, Id applicantId, Id loanId, String strTriggerPoint, string toUserId) {
                
		LoanAppWrapper LoanAppWrap = new LoanAppWrapper(objApp,objLoan,applicantId,loanId,strTriggerPoint,toUserId);

        List<Notification_Master__mdt> lstNM = new List<Notification_Master__mdt>();
        lstNM = [Select Id, DeveloperName, Label, Trigger_Point__c, SMS__c, WhatsApp__c, Push_Notification__c, 
                 Chatter_Notification__c, Mail__c from Notification_Master__mdt  where DeveloperName = :strTriggerPoint AND Is_Active__c  = true];
        for (Notification_Master__mdt objNM : lstNM) {
            if (objNM.Mail__c == 'Yes') {
                AUSF_EmailNotificationHandler.sendEmailNotification(LoanAppWrap);
            }
            if (objNM.SMS__c == 'Yes') {
                AUSF_SMSNotificationHandler.sendSmsNotification(LoanAppWrap);
            }
            if (objNM.WhatsApp__c == 'Yes') {
                //AUSF_NotificationHandler.sendWhatsApp(parameters);
            }
            if (objNM.Push_Notification__c == 'Yes') {
                AUSF_NotificationPUSH.sendPushNotification(LoanAppWrap);
            }
            if (objNM.Chatter_Notification__c == 'Yes') {
                AUSF_NotificationChatter.sendChatterNotification(LoanAppWrap); // Charchit
            }
        }
        return 'success';
    }
    
	public class LoanAppWrapper {
        @AuraEnabled
        public Applicant__c ObjApp;
        @AuraEnabled
        public Loan_Application__c ObjLoan;
        @AuraEnabled
        public Id loanApplicationId;
        @AuraEnabled
        public Id applicantId;
        @AuraEnabled
        public String toUserId;
        @AuraEnabled
        public String strTriggerPoint;
        
        public LoanAppWrapper(Applicant__c objApplicant, Loan_Application__c objLoan, Id applicantId, Id loanId, String strTriggerPoint,String toUserId) {
            this.objApp = objApplicant;
            this.objLoan = objLoan;
            this.applicantId = applicantId;
            this.loanApplicationId = loanId;
            this.strTriggerPoint = strTriggerPoint;
            this.toUserId = toUserId;
        }
        
 	}
}