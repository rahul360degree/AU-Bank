/**
* @author        Tejendra
* @date          4-July-2024
* @description   Email Notification Service Response Wrapper class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              4-July-2024    Initial Version
*/
public without sharing class AUSF_INT_EmailResponseWrapper {
    public AUSF_INT_EmailResponseWrapper() {

    }
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled
    public cls_TransactionStatus TransactionStatus;
	public class cls_TransactionStatus {
        @AuraEnabled
		public String ResponseCode;
        @AuraEnabled	
		public String ResponseMessage;
        @AuraEnabled	
		public cls_ExtendedErrorDetails ExtendedErrorDetails;
	}
	public class cls_ExtendedErrorDetails {
        @AuraEnabled
		public cls_messages messages;
	}
	public class cls_messages {
        @AuraEnabled
		public String code;
        @AuraEnabled	
		public String message;	
	}
}