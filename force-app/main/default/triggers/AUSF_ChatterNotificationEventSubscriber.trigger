trigger AUSF_ChatterNotificationEventSubscriber on Notification_Chatter_Event__e (after insert) {
    
        FeedItem post = new FeedItem();
        post.ParentId = trigger.new[0].sObjectId__c; // Id of the record to post on (e.g., a User, Account, etc.)
        post.Body = trigger.new[0].Request_Body__c;
        post.Type = 'TextPost'; // Specify the type of post (TextPost, ContentPost, LinkPost, etc.)

        try {
            insert post;
            System.debug('Successfully posted to Chatter.');
        } catch (Exception e) {
            System.debug('Error posting to Chatter: ' + e.getMessage());
        }
    }