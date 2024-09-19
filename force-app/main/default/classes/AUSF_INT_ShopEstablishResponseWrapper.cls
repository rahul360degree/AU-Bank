/**
* @author        Enuganti Ram
 * @date          07-July-2024
 * @description   Fetch Shop Establishment Response wrapper class
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
    --------------------------------------------------------------------------------------------
    Enuganti Ram              07-July-2024    Initial Version - APL-204
*/

public without sharing class AUSF_INT_ShopEstablishResponseWrapper {
 public AUSF_INT_ShopEstablishResponseWrapper() {
}
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;   
    @AuraEnabled
    public String requestId;    //6c2d0636-c3b8-4847-9578-225e703e0397
    @AuraEnabled
    public cls_result result;
    @AuraEnabled
    public Integer statusCode;  //101
    @AuraEnabled
    public cls_clientData clientData;
    public class cls_result {
        @AuraEnabled
        public AUSF_AddressSplitResponseWrapper.splitaddress splitaddress;
        @AuraEnabled
        public String category; //Commercial Establishment
        @AuraEnabled
        public String status;   //
        @AuraEnabled
        public String ownerName;    //Ramanand
        @AuraEnabled
        public String entityName;   //Shiva Enterprises
        @AuraEnabled
        public String registrationDate; //2/1/2017
        @AuraEnabled
        public String validTo;  //
        @AuraEnabled
        public String contact;  //9560084286, 27917553
        @AuraEnabled
        public String commenceDate; //2/1/2017
        @AuraEnabled
        public String totalWorkers; //5
        @AuraEnabled
        public String fathersNameOfOccupier;    //Jag Ram
        @AuraEnabled
        public String natureOfBusiness; //Others
        @AuraEnabled
        public String address;  //N-18/242, L-block Jj Colony Wazirpur Delhi, Delhi. PIN-110052
        @AuraEnabled
        public String validFrom;    //
        @AuraEnabled
        public String email;    //spraygunsales@gmail.com
        @AuraEnabled
        public String websiteUrl;   //
        @AuraEnabled
        public String applicantName;    //
    }
    public class cls_clientData {
        @AuraEnabled
        public String caseId;   //123456
    }
     public class cls_splitaddress{
        public String CO;
        public String House;
        public String Floor;
        public String Building;
        public String Complex;
        public String Street;
        public String Untagged;
        public String locality;
        public String State;
        public String District;
        public String City;
        public String Landmark;
        public String Pin;
    }

}