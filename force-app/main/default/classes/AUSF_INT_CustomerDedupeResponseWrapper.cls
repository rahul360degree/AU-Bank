/**
* @author        
* @date          28-June-2024
* @description   Wrapper for Customer Dedupe screen
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        28-June-2024    Initial Version
*/
public class AUSF_INT_CustomerDedupeResponseWrapper {
    public AUSF_INT_CustomerDedupeResponseWrapper(){}
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper objIntResponse;
    @AuraEnabled
    public Boolean blnSuccess = false;
    @AuraEnabled
    public String strMessage {get;set;}
    @AuraEnabled
    public Boolean blnIntegrationSuccess = false;
    @AuraEnabled
    public list<Customer> customers;
    public class Customer {
      @AuraEnabled
      public String CIF;
      @AuraEnabled
      public String Name;
      @AuraEnabled
      public String MobileNo;
      @AuraEnabled
      public String PAN;
      @AuraEnabled
      public String Type;
      @AuraEnabled
      public Boolean unsecureDLODMatch;
      @AuraEnabled
      public Boolean overDraftCheck;
      @AuraEnabled
      public Boolean DPD;
      @AuraEnabled
      public Boolean NPA;
      @AuraEnabled
      public PA preApprovedOffer;
    }
    public class PA{
      @AuraEnabled
      public String ProductType;
      @AuraEnabled
      public String OfferAmount;
      @AuraEnabled
      public String OfferType;
      @AuraEnabled
      public String ProcessingFee;
      @AuraEnabled
      public String BankAccountNumber;
    }
}