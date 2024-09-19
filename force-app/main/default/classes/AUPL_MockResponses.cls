/**
* @author: Ruturaj Chothe
* @company: Salesforce.com
* @description: Mock class to verify otp response
* Test Class: 
* History:
* <Date> <Authors Name> <Brief Description of Change>
*
*/

public with sharing class AUPL_MockResponses {

    /** 
    * @author Ruturaj Chothe
    * @company Salesforce.com
    * @description: sends mock response boolean if otp is verified or not
    * Inputs: String otpString
    * Returns: true - if otp is verified, false - if wrong otp is given
    * History:
    * <Date> <Authors Name> <Brief Description of Change>
    */
    @AuraEnabled
    public static Boolean isOtpVerified(String otpString){
        try {
            List<String> validOtpsList = new List<String> {'123456', '111111', '654321'};
            if(validOtpsList.contains(otpString)){
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    
}