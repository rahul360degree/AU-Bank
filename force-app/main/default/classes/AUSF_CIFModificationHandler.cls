/**
* @author        Tejendra
* @date          25-July-2024
* @description   CIF Modification Handler class - use to generate request and validate the prerequisites
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Tejendra              25-July-2024    Initial Version
*/
public without sharing class AUSF_CIFModificationHandler implements AUSF_INT_IntegrationHandlerInterface{
    public static Map<String, String> replacements;
    public List<String> generateRequest(List <Object> inputWrappers){
        List<String> lstRequestString = new List<String>(); 
        if (inputWrappers.isEmpty()) {
            return new List <String> ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_CIFModificationRequestWrapper objRequest = new AUSF_CIFModificationRequestWrapper();
        objRequest.RequestId = String.valueOf(inputWrapper.dynamicInputs.get('RequestId'));
        objRequest.Channel = String.valueOf(inputWrapper.dynamicInputs.get('Channel'));
        objRequest.TransactionBranch = String.valueOf(inputWrapper.dynamicInputs.get('TransactionBranch'));
        objRequest.ReferenceNumber = String.valueOf(inputWrapper.dynamicInputs.get('ReferenceNumber'));
        AUSF_CIFModificationRequestWrapper.AddressWrapper addressWrapperObj = new AUSF_CIFModificationRequestWrapper.AddressWrapper();
        addressWrapperObj.Zip = String.valueOf(inputWrapper.dynamicInputs.get('Zip'));
        addressWrapperObj.State = String.valueOf(inputWrapper.dynamicInputs.get('State'));
        addressWrapperObj.Country = String.valueOf(inputWrapper.dynamicInputs.get('Country'));
        addressWrapperObj.City = String.valueOf(inputWrapper.dynamicInputs.get('City'));
        addressWrapperObj.Line1 = String.valueOf(inputWrapper.dynamicInputs.get('Line1'));
        addressWrapperObj.Line2 = String.valueOf(inputWrapper.dynamicInputs.get('Line2'));
        addressWrapperObj.Line3 = String.valueOf(inputWrapper.dynamicInputs.get('Line3'));
        addressWrapperObj.Line4 = String.valueOf(inputWrapper.dynamicInputs.get('Line4')); 
        AUSF_CIFModificationRequestWrapper.IndividualCustomerWrapper individualCustomerWrapperObj = new AUSF_CIFModificationRequestWrapper.IndividualCustomerWrapper();
        individualCustomerWrapperObj.MailingAddress = addressWrapperObj;
        individualCustomerWrapperObj.InoperativePan = String.valueOf(inputWrapper.dynamicInputs.get('InoperativePan'));
        individualCustomerWrapperObj.CustomerId = String.valueOf(inputWrapper.dynamicInputs.get('CustomerId'));
        individualCustomerWrapperObj.EmailId = String.valueOf(inputWrapper.dynamicInputs.get('EmailId'));
        individualCustomerWrapperObj.PAN = String.valueOf(inputWrapper.dynamicInputs.get('PAN'));
        objRequest.IndividualCustomer = individualCustomerWrapperObj;
        objRequest.CorporateCustomer = NULL;
        AUSF_CIFModificationRequestWrapper.CustomerProfilingDetailsWrapper customerProfilingDetailsWrapperObj = new AUSF_CIFModificationRequestWrapper.CustomerProfilingDetailsWrapper();
        customerProfilingDetailsWrapperObj.Activity = String.valueOf(inputWrapper.dynamicInputs.get('Activity'));
        customerProfilingDetailsWrapperObj.BusinessProfiler = String.valueOf(inputWrapper.dynamicInputs.get('BusinessProfiler'));
        customerProfilingDetailsWrapperObj.CustCategory = String.valueOf(inputWrapper.dynamicInputs.get('CustCategory'));
        customerProfilingDetailsWrapperObj.IncomeProfiler = String.valueOf(inputWrapper.dynamicInputs.get('IncomeProfiler'));
        customerProfilingDetailsWrapperObj.Industry = String.valueOf(inputWrapper.dynamicInputs.get('Industry'));
        customerProfilingDetailsWrapperObj.Sector = String.valueOf(inputWrapper.dynamicInputs.get('Sector'));
        customerProfilingDetailsWrapperObj.SubIndustry = String.valueOf(inputWrapper.dynamicInputs.get('SubIndustry'));
        objRequest.CustomerProfilingDetails = customerProfilingDetailsWrapperObj;
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