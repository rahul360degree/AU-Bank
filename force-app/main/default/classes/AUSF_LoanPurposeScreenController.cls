/**
* @author Nitesh Jaiswal
* @company Salesforce.com
* @description Controller class of AUPL_LoanPurposeScreenCmp
* Test Class: AUPL_LoanPurposeScreenController_Test
*/

public without sharing class AUSF_LoanPurposeScreenController {

    @TestVisible
    private static Boolean throwException = false;

    //Method to validate the referral code with any user's federation id.
    @AuraEnabled
    public static List<User> validateReferralCode(string referralCode,string loanApplicationId){
        try {
            if(throwException){
                throw new CustomException('Custom Exception');
            }
            List<User> userList = [SELECT Id,Name,FederationIdentifier FROM User WHERE FederationIdentifier=:referralCode AND IsActive = true LIMIT 1];
            return userList;

        } catch (Exception e) {
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,loanApplicationId,'User','Purpose of Loan');
            return null;
        }
    }

    public class CustomException extends Exception {}
}