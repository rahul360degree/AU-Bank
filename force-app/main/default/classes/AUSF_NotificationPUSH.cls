/*******************************************************************************************
* @Name         AUSF_NotificationPUSH
* @Author       Charchit Nirayanwal
* @Description  
* @Test Class   AUSF_NotificationControllerTest
*******************************************************************************************/
/* MODIFICATION LOG
* Version                   Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Charhit Nirayanwal            03-July-2024            Initial Creation 
*******************************************************************************************/
public without sharing class AUSF_NotificationPUSH { 
    
    public static void sendPushNotification(AUSF_NotificationController.LoanAppWrapper loanWrap){
        List<Notification_Content__mdt> lstNC = new List<Notification_Content__mdt>();
        lstNC = [Select Id, On_Screen_Push_SMSContent__c, To__c,Title__c from Notification_Content__mdt where Notification_Master__r.DeveloperName =:loanWrap.strTriggerPoint AND isActive__c = true and Push_On_Screen__c = 'Yes'];
        for (Notification_Content__mdt objNC : lstNC) { 
            
            Notification_Push_Event__e event = new Notification_Push_Event__e();
            
            // Set the fields
            event.Request_Body__c = AUSF_NotificationUtility.bindValues(loanWrap,objNC.On_Screen_Push_SMSContent__c);
            event.sObjectId__c  = loanWrap.loanApplicationId;
            event.Trigger_Point__c = loanWrap.strTriggerPoint;
            event.Title__c = objNC.Title__c;
            event.To__c = loanWrap.toUserId != null ? loanWrap.toUserId : objNC.To__c;
            
            // Publish the event
            Database.SaveResult sr = EventBus.publish(event);
            
            // Check if the event was published successfully
            if (sr.isSuccess()) {
                System.debug('Platform event published successfully.');
            } else {
                //Create Error log
            }  
        }    
    }
}