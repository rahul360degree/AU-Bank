/**
 * @author: Amit Mishra
 * @date: 25-June-2024
 * @description: NSDL PAN verification response wrapper 
 * Test Class: AUSF_NsdlPanTest
 * History:
 * ====================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ====================================================================
 * 25-June-2024 	Amit Mishra 		Initial Version
**/
public without sharing class AUSF_INT_ValidatePANResponseWrapper {
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled
    public String status;
    @AuraEnabled
    public String pan;
    @AuraEnabled
    public String name;
    @AuraEnabled
    public String nameOnCard;
    @AuraEnabled
    public String fatherName;
    @AuraEnabled
    public String dateofBirth;
    @AuraEnabled
    public String seedingStatus;
    @AuraEnabled
    public Boolean blnIntegrationSuccess = false;
    @AuraEnabled
    public Boolean blnSuccess = false;
    @AuraEnabled
    Public String strMessage;
    
    public class LOSNsdlResponseWrapper {
        @AuraEnabled
        public Headers headers;
        @AuraEnabled
        public List<Response> response;
        
        public LOSNsdlResponseWrapper parse(String json) {
            return (LOSNsdlResponseWrapper) System.JSON.deserialize(json, LOSNsdlResponseWrapper.class);
        }  
    }
    public class Response {
        @AuraEnabled
        public String Status;
        @AuraEnabled
        public String PAN;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String NameOnCard;
        @AuraEnabled
        public String FatherName;
        @AuraEnabled
        public String DateofBirth;
        @AuraEnabled
        public String SeedingStatus;
    }
    public class Headers {
        public String responseCode;
        public String responseMsg;
    }
}