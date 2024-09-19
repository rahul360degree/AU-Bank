/**
* @author Nitesh Jaiswal
* @company Salesforce.com
* @description Controller class of AUPL_ConfirmPersonalDetailCmp
* Test Class: AUSF_ConfirmPersonalDetailControler_Test
*/

public without sharing class AUSF_ConfirmPersonalDetailsController {

    @TestVisible
    private static Boolean throwException = false;

    @AuraEnabled
    public static List<Location_Master__c> validatePinCode(string pinCode, string loanApplicationId){
        try {
            if(throwException){
                throw new CustomException('Custom Exception');
            }
            List<Location_Master__c> locationMasterList = [SELECT Id,Name,Zip_Code__c,Working_Area__c,City__c,State__c FROM Location_Master__c WHERE Zip_Code__c =: pinCode LIMIT 1];
            return locationMasterList;
        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,loanApplicationId,'Location Master','Confirm Personal Details');
            return null;
        }
    }

    public class CustomException extends Exception {}

}