trigger AUSF_PushNotificationEventSubscriber on Notification_Push_Event__e (after insert) {
    try{

        List<CustomNotificationType> CustomNotiLst= [Select id from CustomNotificationType where DeveloperName = 'Push_Notification' ];
        
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        
        // Set the contents for the notification
        notification.setTitle(trigger.new[0].Title__c);
        notification.setBody(trigger.new[0].Request_Body__c);
        
        // Set the notification type and target
        if(CustomNotiLst.size() == 1){
            notification.setNotificationTypeId(CustomNotiLst[0].id);
        }
        notification.setTargetId(trigger.new[0].sObjectId__c );
        set<string> u= new set<string>{};
            u.add( trigger.new[0].To__c );
            
            // Actually send the notification
            notification.send(u);
        
    }
    catch(exception e){
        //create error Log
    }
}