public with sharing class AUSF_PaymentIFTAPIHandler implements AUSF_INT_IntegrationHandlerInterface{
    public List < String > generateRequest(List < Object > inputWrappers) {
        system.debug('Inside handler');
        List<String> lstRequestString = new List<String>();
        if (inputWrappers.isEmpty()) {
            return new List < String > ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_PaymentIFTAPIRequestWrapper objRequest = new AUSF_PaymentIFTAPIRequestWrapper();
        objRequest.ReferenceNumber = AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.Channel = String.valueOf(inputWrapper.dynamicInputs.get('Channel'));
        objRequest.valueDate = String.valueOf(inputWrapper.dynamicInputs.get('valueDate'));
        objRequest.UserReferenceNumber = AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.TransactionType = String.valueOf(inputWrapper.dynamicInputs.get('TransactionType'));
        objRequest.TransactionCurrency = String.valueOf(inputWrapper.dynamicInputs.get('TransactionCurrency'));
        objRequest.TransactionBranch = String.valueOf(inputWrapper.dynamicInputs.get('TransactionBranch'));
        objRequest.TransactionAmount = String.valueOf(inputWrapper.dynamicInputs.get('TransactionAmount'));
        objRequest.ToAccountCurrency = String.valueOf(inputWrapper.dynamicInputs.get('ToAccountCurrency'));
        objRequest.ToAccountBranch = String.valueOf(inputWrapper.dynamicInputs.get('ToAccountBranch'));
        objRequest.ToAccount = String.valueOf(inputWrapper.dynamicInputs.get('ToAccount'));
        objRequest.PostingDate = '';
        objRequest.Narrative = String.valueOf(inputWrapper.dynamicInputs.get('Narrative'));
        objRequest.GLRefrenceNo = '250408454';
        objRequest.FromAccountCurrency = String.valueOf(inputWrapper.dynamicInputs.get('FromAccountCurrency'));
        objRequest.FromAccountBranch = String.valueOf(inputWrapper.dynamicInputs.get('FromAccountBranch'));
        objRequest.FromAccount = String.valueOf(inputWrapper.dynamicInputs.get('FromAccount'));
        objRequest.ChequeNumber = '';
        lstRequestString.add(JSON.serialize(objRequest));
        system.debug('lstRequestString--->'+lstRequestString);
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