/**
 * @author       Pradeep Sharma
 * Class :		 AUSF_ICAI_APIResponseWrapper
 * @date         05-Aug-2024
 * @description: Integration Response wrapper for ICAI API
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
--------------------------------------------------------------------------------------------
    Pradeep Sharma        05-Aug-2024    Initial Version
*/
public class AUSF_ICAI_APIResponseWrapper{
    
    public AUSF_ICAI_APIResponseWrapper(){}
    
    @AuraEnabled
    public result result;
    @AuraEnabled
    public String request_id;
    @AuraEnabled
    public String statusCode;//status-code
    public class result{
        @AuraEnabled
        public String memberStatus;
        @AuraEnabled
        public String AssociateYear;
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String COPStatus;
        @AuraEnabled
        public String gender;
        @AuraEnabled
        public String Qualification;
        @AuraEnabled
        public String address;
        @AuraEnabled
        public String FellowYear;
        @AuraEnabled
        public AUSF_AddressSplitResponseWrapper.splitaddress splitaddress;
    }
    
}