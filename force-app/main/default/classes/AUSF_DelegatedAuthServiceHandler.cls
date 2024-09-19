/**
 * @author        Enuganti Ram
 * Class :		 AUSF_DelegatedAuthServiceHandler
 * Test Class	 AUSF_DelegatedAuthServiceHandlerTest
 * @date          23-June-2024
 * @description   LDAP service used for authentication
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
    --------------------------------------------------------------------------------------------
    Enuganti Ram        23-June-2024    Initial Version
     */

public without sharing class AUSF_DelegatedAuthServiceHandler implements AUSF_INT_IntegrationHandlerInterface{
  public  List<String> generateRequest(List <Object> inputWrappers){
        List<String> lstRequestString = new List<String>(); 
        if (inputWrappers.isEmpty()) {
            return new List <String> ();
        }
    AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
      List<String> lstString = new List<String>();
        DelegatedAuthServiceRequestWrapper objDelegatedAuthServiceRequest = new DelegatedAuthServiceRequestWrapper();
        objDelegatedAuthServiceRequest.Channel =String.valueOf(inputWrapper.dynamicInputs.get('Channel'));
        objDelegatedAuthServiceRequest.UserId = String.valueOf(inputWrapper.dynamicInputs.get('UserId'));
        objDelegatedAuthServiceRequest.Password = String.valueOf(inputWrapper.dynamicInputs.get('Password'));
        lstString.add(JSON.serialize(objDelegatedAuthServiceRequest));   
        return lstString;
    }
    
    public String generateJSONResponse(List<Object> recordList){
        return null;
    }
    
    public class DelegatedAuthServiceRequestWrapper{
        public String Channel;  //SFDC
        public String UserId;   //983602
        public String Password; //strPasswordEncrypted
    }
    public List<String> validateInputData(List<Object> inputWrappers){
        List<String> validationErrorsList = new List <String>();
        return validationErrorsList;
    }
    public List<sObject> generatePlatformEvents(List<Object> recordList){
        return NULL;
    }
    public void callbackService(List<Integration_Checklist__c> checklistRecords, List<ContentVersion> responseFiles){}
    public void beforeUpdateService(Integration_Checklist__c checklistRecord, ContentVersion responseFile){
        
        
    }

}