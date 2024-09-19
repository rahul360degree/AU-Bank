/**
* @author        Mohit M.
* @date          18-June-2024
* @description   Test Class Log
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Mohit M.              18-June-2024    Initial Version
*/
@isTest
private class AUSF_LogEventSubscriberTest {
    @isTest
    static void testLogEvent(){
        Log_Event__e event  = new Log_Event__e();
        event.Line_Number__c = 4;
        event.Message__c = 'Exception';
        Test.startTest();
        // Publish test event
        Database.SaveResult sr = EventBus.publish(event);
        Test.stopTest();
        // Verify SaveResult value
        System.assertEquals(true, sr.isSuccess());
    }
}