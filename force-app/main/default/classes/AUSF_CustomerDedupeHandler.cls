/**
* @author        Pradeep Sharma
* @date          28-June-2024
* Class :		 AUSF_CustomerDedupeHandler
* Test Class	 AUSF_CustomerDedupeTest
* @description   Customer Dedupe Handler class - use to generate request and validate the prerequisites
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        28-June-2024    Initial Version
*/
public without sharing class AUSF_CustomerDedupeHandler implements AUSF_INT_IntegrationHandlerInterface{
    public List < String > generateRequest(List < Object > inputWrappers) {
        List<String> lstRequestString = new List<String>();
        if (inputWrappers.isEmpty()) {
            return new List < String > ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_CustomerDedupeRequestWrapper objRequest = new AUSF_CustomerDedupeRequestWrapper();
        objRequest.AadhaarNumber = String.valueOf(inputWrapper.dynamicInputs.get('channel'));
        objRequest.MobileNumber = '';
        objRequest.LandLineNumber = '';
        objRequest.CustomerId = AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.VoterID = '';
        objRequest.DrivingLicense = '';
        objRequest.FullName = '';
        objRequest.ReferenceNumber = AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.PanNumber = String.valueOf(inputWrapper.dynamicInputs.get('panNumber'));
        objRequest.Channel = String.valueOf(inputWrapper.dynamicInputs.get('consent'));
        objRequest.PassportNumber = '';
        objRequest.RequestId = AUSF_INT_IntegrationUtility.getReferenceId();
        objRequest.TransactionBranch = '2011';
        //objRequest.DateOfBirth = '';
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