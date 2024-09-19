/**
* @author        Rahul Yadav
* @date          25-June-2024
* @description   This class use to generate request and validate the prerequisites
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Rahul Yadav              25-June-2024    Initial Version
*/
public without sharing class AUSF_EmailAuthenticationHandler implements AUSF_INT_IntegrationHandlerInterface{
    public List < String > generateRequest(List < Object > inputWrappers) {
        List<String> lstRequestString = new List<String>();
            if (inputWrappers.isEmpty()) {
                return new List < String > ();
            }
            AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
            AUSF_EmailAuthenticationRequestWrapper objRequest = new AUSF_EmailAuthenticationRequestWrapper();
            objRequest.Fields.Applicants.Applicant.Services.Service.Id = '';
            objRequest.Fields.Applicants.Applicant.Services.Service.Operations.Operation = new List<AUSF_EmailAuthenticationRequestWrapper.OperationWrap>();
            AUSF_EmailAuthenticationRequestWrapper.OperationWrap operationObj = new AUSF_EmailAuthenticationRequestWrapper.OperationWrap();
            operationObj.ID = '';
            operationObj.Name = 'EmailVerification';
            objRequest.Fields.Applicants.Applicant.Services.Service.Operations.Operation.add(operationObj);
            objRequest.Fields.Applicants.Applicant.Services.Service.Name = 'EmailVerification';
            objRequest.Fields.Applicants.Applicant.EmailAddress = String.valueOf(inputWrapper.dynamicInputs.get('emailAddress'));
            objRequest.Fields.ApplicationData.Services.Service.Consent = true;
            objRequest.Fields.ApplicationData.Services.Service.Skip = 'N';
            objRequest.Fields.ApplicationData.Services.Service.Id = '';
            objRequest.Fields.ApplicationData.Services.Service.Name = 'EmailVerification';
            objRequest.RequestId = AUSF_INT_IntegrationUtility.getReferenceId();
            objRequest.Channel = String.valueOf(inputWrapper.dynamicInputs.get('channel'));
            objRequest.RequestInfo.ExecuteLatestVersion = true;
            objRequest.RequestInfo.SolutionSetName = 'GO_AUSFB_AGSS';
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