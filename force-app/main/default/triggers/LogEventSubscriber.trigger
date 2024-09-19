trigger LogEventSubscriber on Log_Event__e (after insert) {
    List<Log__c> logList = new List<Log__c>();
    Log__c logInstance;
    for (Log_Event__e event : Trigger.New) {
        logInstance = new Log__c();
        logInstance.Async_Job_Id__c = event.Async_Job_Id__c;
        logInstance.Class__c = event.Class__c;
        logInstance.Integration_End_Time__c = event.Integration_End_Time__c;
        logInstance.Integration_Start_Time__c = event.Integration_Start_Time__c;
        logInstance.Line_Number__c = event.Line_Number__c;
        logInstance.Message__c = event.Message__c;
        logInstance.Method__c = event.Method__c;
        logInstance.Send_Email__c = event.Send_Email__c;
        logInstance.Severity__c = event.Severity__c;
        logInstance.Stack_Trace__c = event.Stack_Trace__c;
        logInstance.Type__c = event.Type__c;
        logInstance.Record_Id__c = event.Record_Id__c;
        logInstance.Object_Name__c = event.Object_Name__c;
        logInstance.Method_Process_Name__c = event.Method_Process_Name__c;
        logInstance.User__c = event.User__c;
        logList.add(logInstance);
    }
    if(!logList.isEmpty()){
        insert logList;
    }
}