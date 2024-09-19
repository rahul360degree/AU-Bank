/**
 * @author       Pradeep Sharma
 * Class :		 AUSF_ICSIResponseWrapper
 * @date         05-Aug-2024
 * @description: Integration response wrapper for ICSI API
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
--------------------------------------------------------------------------------------------
    Pradeep Sharma        05-Aug-2024    Initial Version
*/
public class AUSF_ICSIResponseWrapper{   
    public AUSF_ICSIResponseWrapper(){}
    @AuraEnabled
    public result result;
    @AuraEnabled
    public String statusCode;
    @AuraEnabled
    public String requestId;
    public class result{
        @AuraEnabled
        public String mobile;
        @AuraEnabled
        public String memberName;
        @AuraEnabled
        public String organization;
        @AuraEnabled
        public String cpNumber;
        @AuraEnabled
        public String phone;
        @AuraEnabled
        public String designation;
        @AuraEnabled
        public String city;
        @AuraEnabled
        public String email;
        @AuraEnabled
        public String memberImage;
        @AuraEnabled
        public String address;
        @AuraEnabled
        public String benevolentMember;
        @AuraEnabled
        public String membershipNumber;
        @AuraEnabled
        public AUSF_AddressSplitResponseWrapper.splitaddress splitaddress;
    }
    
}