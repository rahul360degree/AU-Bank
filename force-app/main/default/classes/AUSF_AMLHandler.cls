/**
* @author        Tejendra
* @date          29-June-2024
* @description   Aml Handler class - use to generate request and validate the prerequisites
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Tejendra              29-June-2024    Initial Version
*/
public without sharing class AUSF_AMLHandler implements AUSF_INT_IntegrationHandlerInterface{
    public static Map<String, String> replacements;
    public List<String> generateRequest(List <Object> inputWrappers){
        List<String> lstRequestString = new List<String>(); 
        if (inputWrappers.isEmpty()) {
            return new List <String> ();
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        AUSF_AmlRequestWrapper objRequest = new AUSF_AmlRequestWrapper();
        String currentDateTime = String.valueOf(Datetime.now().format('yyyy-MM-dd HH:mm:ss'));
        replacements = new Map<String, String> {
            'datetimex' => 'datetime'
        };
        objRequest.AML_ACTION = null;
        objRequest.batch_mode = String.valueOf(inputWrapper.dynamicInputs.get('batch_mode'));
        objRequest.callbackurl = String.valueOf(inputWrapper.dynamicInputs.get('callbackurl'));
        objRequest.datetimex = currentDateTime;
        objRequest.errorCode = null;
        objRequest.errorMessage = null;
        List<String> fieldsName = new List<String>{'name','pan','mobile','email','dob','nationality','country'};
        for(String field : fieldsName){
            AUSF_AmlRequestWrapper.cls_fields fieldObj = new AUSF_AmlRequestWrapper.cls_fields();
            fieldObj.name = field;
            fieldObj.value = String.valueOf(inputWrapper.dynamicInputs.get(field));
            objRequest.fields.add(fieldObj);
        } 
        objRequest.MATCH = null;
        objRequest.referenceid = String.valueOf(inputWrapper.dynamicInputs.get('referenceid'));
        objRequest.refid = String.valueOf(inputWrapper.dynamicInputs.get('refid'));
        objRequest.status = null;
        objRequest.systemname = String.valueOf(inputWrapper.dynamicInputs.get('systemname'));
        objRequest.userid = String.valueOf(inputWrapper.dynamicInputs.get('userid'));
        String body = JSON.serialize(objRequest);
        body = AUSF_INT_IntegrationUtility.mogrifyJSON(body, replacements);
        system.debug('body of generateJSONForAMLReq --> ' + body);
        //lstRequestString.add(JSON.serialize(objRequest));
        lstRequestString.add(body);      
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