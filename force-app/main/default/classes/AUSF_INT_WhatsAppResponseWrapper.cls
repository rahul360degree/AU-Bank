/**
* @author        Tejendra
* @date          6-July-2024
* @description   Whatsapp Notification Service Response Wrapper class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              6-July-2024    Initial Version
*/
public without sharing class AUSF_INT_WhatsAppResponseWrapper {
    public AUSF_INT_WhatsAppResponseWrapper() {

    }
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled
    public String status_message;
    @AuraEnabled	
	public String recepient_id;
    @AuraEnabled	
	public Integer status;
    @AuraEnabled
    public String ServiceExecutionStatus;
    @AuraEnabled
	public cls_Errors Errors;
	class cls_Errors {
        @AuraEnabled
		public cls_Error Error;
	}
	class cls_Error {
        @AuraEnabled
		public String Code;	
        @AuraEnabled
		public String Message;	
	}	
}