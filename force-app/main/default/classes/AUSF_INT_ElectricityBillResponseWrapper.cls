/**
* @author        Rahul Yadav
* @date          29-June-2024
* @description   This class will store the response of Electricity Bill Authentication
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Rahul Yadav              29-June-2024    Initial Version
*/
public with sharing class AUSF_INT_ElectricityBillResponseWrapper {
    @AuraEnabled public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled public Boolean blnIntegrationSuccess = false;
    @AuraEnabled public Boolean blnSuccess = false;
    @AuraEnabled Public String strMessage;
    @AuraEnabled public string request_id;
    @AuraEnabled public integer statuscode;
    @AuraEnabled public resultWrapper result;
    public AUSF_INT_ElectricityBillResponseWrapper(){
      result = new resultWrapper();
    }
    public class resultWrapper{
        @AuraEnabled public String address;
        @AuraEnabled public String amount_payable;
        @AuraEnabled public String bill_amount;
        @AuraEnabled public String bill_date;
        @AuraEnabled public String bill_due_date;
        @AuraEnabled public String bill_issue_date;
        @AuraEnabled public String bill_no;
        @AuraEnabled public String consumer_name;
        @AuraEnabled public String consumer_number;
        @AuraEnabled public String email_address;
        @AuraEnabled public String mobile_number;
        @AuraEnabled public String total_amount;
    }
}