public without sharing class AUSF_PaymentNEFTHandler implements AUSF_INT_IntegrationHandlerInterface{
    public AUSF_PaymentNEFTHandler() {

    }
    public List<String> generateRequest(List <Object> inputWrappers){
        List<String> lstRequestString = new List<String>(); 
        if (inputWrappers.isEmpty()) {
            return new List <String> ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_PaymentNEFTRequestWrapper objRequest = new AUSF_PaymentNEFTRequestWrapper();
        AUSF_PaymentNEFTRequestWrapper.cls_SettlementRequest settlementRequestObj = new AUSF_PaymentNEFTRequestWrapper.cls_SettlementRequest();
        settlementRequestObj.TransactionReferenceNumber = String.valueOf(inputWrapper.dynamicInputs.get('TransactionReferenceNumber'));
        settlementRequestObj.Amount = String.valueOf(inputWrapper.dynamicInputs.get('Amount'));
        settlementRequestObj.ValueDate = String.valueOf(inputWrapper.dynamicInputs.get('ValueDate'));
        settlementRequestObj.SenderIFSC = String.valueOf(inputWrapper.dynamicInputs.get('SenderIFSC'));
        settlementRequestObj.SenderAccountType = String.valueOf(inputWrapper.dynamicInputs.get('SenderAccountType'));
        settlementRequestObj.SenderAccountNumber = String.valueOf(inputWrapper.dynamicInputs.get('SenderAccountNumber'));
        settlementRequestObj.SendingCustomerName = String.valueOf(inputWrapper.dynamicInputs.get('SendingCustomerName'));
        settlementRequestObj.SenderContactInfo = String.valueOf(inputWrapper.dynamicInputs.get('SenderContactInfo'));
        settlementRequestObj.ReceiverIFSC = String.valueOf(inputWrapper.dynamicInputs.get('ReceiverIFSC'));
        settlementRequestObj.ReceiverAccountType = String.valueOf(inputWrapper.dynamicInputs.get('ReceiverAccountType'));
        settlementRequestObj.ReceiverAccountNumber = String.valueOf(inputWrapper.dynamicInputs.get('ReceiverAccountNumber'));
        settlementRequestObj.ReceivingCustomerName = String.valueOf(inputWrapper.dynamicInputs.get('ReceivingCustomerName'));
        settlementRequestObj.Narration = String.valueOf(inputWrapper.dynamicInputs.get('Narration'));
        settlementRequestObj.Source = String.valueOf(inputWrapper.dynamicInputs.get('Source'));
        objRequest.SettlementRequest = settlementRequestObj;
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