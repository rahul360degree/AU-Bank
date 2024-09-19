public without sharing class AUSF_CBSStandingInstructionHandler implements AUSF_INT_IntegrationHandlerInterface{
    public List < String > generateRequest(List < Object > inputWrappers) {
        List<String> lstRequestString = new List<String>();
        if (inputWrappers.isEmpty()) {
            return new List < String > ();
        }          
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_CBSSIRequestWrapper objRequest = new AUSF_CBSSIRequestWrapper();
        objRequest.RequestId = AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.ReferenceNumber = AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.OriginatingChannel = String.valueOf(inputWrapper.dynamicInputs.get('channel'));
        objRequest.TransactionBranch = 2141;//String.valueOf(inputWrapper.dynamicInputs.get('TransactionBranch'));
        objRequest.OperationMode = 'A';//String.valueOf(inputWrapper.dynamicInputs.get('OperationMode'));
        objRequest.LoanAccountNumber = '9001020139196050';//String.valueOf(inputWrapper.dynamicInputs.get('LoanAccountNumber'));
        objRequest.RemitterAccountNumber = 'XXXXXXXXXXXXXXXX';//String.valueOf(inputWrapper.dynamicInputs.get('RemitterAccountNumber'));
        objRequest.ArrearTypeDetails = 'cpmin';//String.valueOf(inputWrapper.dynamicInputs.get('ArrearTypeDetails'));
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