public without sharing class AUSF_AddressSplitHandler implements AUSF_INT_IntegrationHandlerInterface{
    public List < String > generateRequest(List < Object > inputWrappers) {
        List<String> lstRequestString = new List<String>();
        if (inputWrappers.isEmpty()) {
            return new List < String > ();
        }          
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_AddressSplitRequestWrapper objRequest = new AUSF_AddressSplitRequestWrapper();
        objRequest.address = String.valueOf(inputWrapper.dynamicInputs.get('address'));
        objRequest.consent='Y';
        objRequest.ReqId=AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.version='2.1';
        objRequest.Channel = inputWrapper.integrationMasterRecord.Channel__c;
        lstRequestString.add(JSON.serialize(objRequest));
        return lstRequestString;
    }

    public List < String > validateInputData(List < Object > inputWrappers) {
        if (inputWrappers.isEmpty()) {
            return new List < String > ();
        }
        List < String > validationErrorsList = new List < String > ();        
        return validationErrorsList;
    }

    public void beforeUpdateService(Integration_Checklist__c checklistRecord, ContentVersion responseFile) {
        // TODO
    }

    public void callbackService(List < Integration_Checklist__c > checklistRecords, List < ContentVersion > responseFiles) {
        // TODO
    }

    public List < sObject > generatePlatformEvents(List < Object > inputWrappers) {
        return null;
    }

}