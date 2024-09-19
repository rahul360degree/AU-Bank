/**
* @author        Tejendra
* @date          5-July-2024
* @description   WhatsApp Notification Handler class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              5-July-2024    Initial Version - APL-247
*/
public without sharing class AUSF_WhatsAppNotificationHandler {
    public AUSF_WhatsAppNotificationHandler() {

    }
    /*
    @description    : sendWhatsAppNotification - Generate Whatsapp notification service method
    @param1         : applicantId - Applicant Record Id
    @param2         : loanId - Loan Application Record Id
    @param3         : strTriggerPoint - Notification trigger point
    @return         : void
    */
    public static void sendWhatsAppNotification(AUSF_NotificationController.LoanAppWrapper objWrapper){
        objWrapper = objWrapper == NULL ? new AUSF_NotificationController.LoanAppWrapper (null, null, null, null, null, null) : objWrapper;
        Applicant__c applicantObj = objWrapper.objApp;
        Loan_Application__c loanApplicationObj = objWrapper.objLoan;
        String  applicantId = objWrapper.applicantId;
        String loanId = objWrapper.loanApplicationId;
        String strTriggerPoint = objWrapper.strTriggerPoint;
        String toUserId = objWrapper.toUserId;
        try{
            if (applicantObj == NULL && applicantId != NULL) {
                List<Applicant__c> lstApplicant = getApplicant(applicantId);
                applicantObj = lstApplicant != NULL ? lstApplicant[0] : NULL;
                objWrapper.ObjApp = applicantObj;
                objWrapper.applicantId = applicantObj != NULL ? applicantObj.Id : NULL;
            }
            if (loanApplicationObj == NULL && loanId != NULL) {
                List<Loan_Application__c> lstApplication = getLoanDetais(loanId);
                loanApplicationObj = lstApplication != NULL ? lstApplication[0] : NULL;
                objWrapper.objLoan = loanApplicationObj;
                objWrapper.loanApplicationId = loanApplicationObj != NULL ? loanApplicationObj.Id : NULL;
            }
        List <Notification_Content__mdt> notificationList = getNotificationContent(strTriggerPoint);
        if (!notificationList.isEmpty()) {
          for (Notification_Content__mdt record: notificationList) {
            String toNumber = '';
            if (record.Notification_Internal_Or_External__c == 'External') {
                toNumber = applicantObj.Mobile_Number__c;
            }
            else if (record.Notification_Internal_Or_External__c == 'Internal') {
                toNumber = toUserId;
            }
            WhatsAppApiKeysWrapper whatsAppApiKeysWrapperObj = new WhatsAppApiKeysWrapper();
            whatsAppApiKeysWrapperObj.key1 = AUSF_NotificationUtility.bindValues(objWrapper,String.isNotBlank(record.Whatsapp_Parameter_1__c)?record.Whatsapp_Parameter_1__c:'');
            whatsAppApiKeysWrapperObj.key2 = AUSF_NotificationUtility.bindValues(objWrapper,String.isNotBlank(record.Whatsapp_Parameter_2__c)?record.Whatsapp_Parameter_2__c:'');
            whatsAppApiKeysWrapperObj.key3 = AUSF_NotificationUtility.bindValues(objWrapper,String.isNotBlank(record.Whatsapp_Parameter_3__c)?record.Whatsapp_Parameter_3__c:'');
            whatsAppApiKeysWrapperObj.key4 = AUSF_NotificationUtility.bindValues(objWrapper,String.isNotBlank(record.Whatsapp_Parameter_4__c)?record.Whatsapp_Parameter_4__c:'');
            whatsAppApiKeysWrapperObj.key5 = AUSF_NotificationUtility.bindValues(objWrapper,String.isNotBlank(record.Whatsapp_Parameter_5__c)?record.Whatsapp_Parameter_5__c:'');
            whatsAppApiKeysWrapperObj.campaignId = record.Campign_ID__c;
                  Id JobId = System.enqueueJob(new AUSF_WhatsAppNotificationQueueable(applicantObj,loanApplicationObj,whatsAppApiKeysWrapperObj,strTriggerPoint,toNumber));
          }
      }
  }catch (Exception ex) {
    System.debug('ex.getMessage='+ex.getMessage());
    System.debug('ex.getLineNumber='+ex.getLineNumber());  
    AUSF_Log.error(ex, AUSF_Log.SeverityType.High,applicantId,'Applicant',AUSF_ApexConstants.AUSF_SMS_INTEGRATION_MASTER);
}
}

/*
@description : Method to Get Loan Details Based on LoanId
@param       : loanApplicationId - Loan Application record id
@return      : List < Loan_Application__c > 
*/
public static List < Loan_Application__c > getLoanDetais(String loanApplicationId) {
        List < Loan_Application__c > loanList = [SELECT Id,Name FROM Loan_Application__c
                                                 WHERE Id =: loanApplicationId
                                                ];
            return loanList;
}

/*
@description : Method to Get applicant list based on applicantId
@param       : applicantId - applicant record id
@return      : List < Applicant__c >
*/
public static List < Applicant__c > getApplicant(String applicantId) {
        List < Applicant__c > applicantList = [SELECT Id, Loan_Application__c,First_Name__c,Full_Name__c,Last_Name__c,Personal_email_ID__c,Mobile_Number__c 
                                               FROM Applicant__c
                                               WHERE Id =: applicantId
                                              ];
            return applicantList;
}

        /*
@description : Method to get the Notification Content Metadata records based on the Trigger Point  
@param       : notificationName - notification name
@return : List <Notification_Content__mdt>
*/

public static List < Notification_Content__mdt > getNotificationContent(String notificationName) {
List < Notification_Content__mdt > notificationContentList = new List < Notification_Content__mdt > ();
    notificationContentList = [SELECT id,MasterLabel,Notification_Internal_Or_External__c,Whatsapp__c, Campign_ID__c, Whatsapp_Parameter_1__c, Whatsapp_Parameter_2__c, Whatsapp_Parameter_3__c, Whatsapp_Parameter_4__c, Whatsapp_Parameter_5__c, Notification_Master__r.Trigger_Point__c, Notification_Master__r.Push_Notification__c, Notification_Master__r.Whatsapp__c, Core__c, Push_On_Screen__c, Retention_Period__c,  To__c, Urban__c, isActive__c
                               FROM Notification_Content__mdt
                               WHERE Notification_Master__r.DeveloperName =: notificationName AND Whatsapp__c = 'Yes' /*AND Notification_Master__r.Whatsapp__c = 'Yes'*/ AND isActive__c = true
                              ];
return notificationContentList;

}
public class CustomException extends Exception {}
public class WhatsAppApiKeysWrapper{
    public string key1;
    public string key2;
    public string key3;
    public string key4;
    public string key5;
    public string campaignId;
}
}