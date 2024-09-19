/**
* @author        Tejendra
* @date          29-July-2024
* @description   Wrapper for Fetching GST using PAN Response
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Tejendra             29-July-2024    Initial Version - APL-150
*/

public without sharing class AUSF_INT_GstPanResponseWrapper {
    public AUSF_INT_GstPanResponseWrapper() {

    }
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled
    public List<cls_result> result;
    @AuraEnabled
	public String requestId;
    @AuraEnabled	
	public Integer statusCode;	
	public class cls_result {
        @AuraEnabled
		public String gstinId;
        @AuraEnabled
		public String authStatus;
        @AuraEnabled
		public String applicationStatus;
        @AuraEnabled	
		public String registrationName;
        @AuraEnabled
		public String emailId;
        @AuraEnabled
		public String tinNumber;
        @AuraEnabled
		public String gstinRefId;	
        @AuraEnabled
		public String mobNum;
        @AuraEnabled
		public String pan;	
        @AuraEnabled
		public String regType;
	}
}