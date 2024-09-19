/*******************************************************************************************
* @Name         AUSF_NotificationChatter
* @Author       Charchit Nirayanwal
* @Description  
* @Test Class   AUSF_NotificationControllerTest
*******************************************************************************************/
/* MODIFICATION LOG
* Version                   Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Charhit Nirayanwal            03-July-2024            Initial Creation 
*******************************************************************************************/
public without sharing class AUSF_NotificationChatter{
    
    public static void sendChatterNotification(AUSF_NotificationController.LoanAppWrapper loanWrap){
        List<Notification_Content__mdt> lstNM = new List<Notification_Content__mdt>();
        lstNM = [Select Id, On_Screen_Push_SMSContent__c from Notification_Content__mdt where Notification_Master__r.DeveloperName =:loanWrap.strTriggerPoint AND isActive__c = true and Chatter_Notification__c = 'Yes'];
        for (Notification_Content__mdt objNC : lstNM) { 
            
            Notification_Chatter_Event__e event = new Notification_Chatter_Event__e();
            
            // Set the fields
            event.Request_Body__c = AUSF_NotificationUtility.bindValues(loanWrap,objNC.On_Screen_Push_SMSContent__c);
            event.sObjectId__c  = loanWrap.loanApplicationId;
            event.Trigger_Point__c = loanWrap.strTriggerPoint;
            
            // Publish the event
            Database.SaveResult sr = EventBus.publish(event);
            
            // Check if the event was published successfully
            if (!sr.isSuccess()) {
                //create Error Record
            }
        }
        
        // Event Call Back need to be implement - Mohit 
        
    }
     
    
    
    
    
}