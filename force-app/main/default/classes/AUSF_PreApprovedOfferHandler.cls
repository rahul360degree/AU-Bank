public without sharing class AUSF_PreApprovedOfferHandler implements AUSF_INT_IntegrationHandlerInterface{
    public List<String> generateRequest(List <Object> inputWrappers){
        List<String> lstRequestString = new List<String>();
        if (inputWrappers.isEmpty()) {
            return new List <String> ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_PreApprovedOfferRequestWrapper objRequest = new AUSF_PreApprovedOfferRequestWrapper();
        objRequest.RequestId = AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.OriginatingChannel = String.valueOf(inputWrapper.dynamicInputs.get('originatingChannel'));
        objRequest.CustomerId = String.valueOf(inputWrapper.dynamicInputs.get('customerId'));
        objRequest.ProductId = '11704';
        lstRequestString.add(JSON.serialize(objRequest));   
        return lstRequestString;
}
public List < String > validateInputData(List < Object > inputWrappers) {
    if (inputWrappers.isEmpty()) {
        return new List < String > ();
    }
    List < String > validationErrorsList = new List < String > ();
    for (Object each: inputWrappers) {
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper) each;
        /*if (inputWrapper.loanRecord.Stage__c == null) {
            validationErrorsList.add('Stage is mandatory.');
        }
        */
    }
    
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