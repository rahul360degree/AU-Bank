public without sharing class AUSF_INT_CodeMessageMapController {
    
    /*
    @description    : getErrorMessages - method which return error message based on statuc code
    @return         : Map of status code with error message.
    */
    public static map<Integer, String> getTUEmailErrorMessages(){
        Map<Integer,String> errorMessageMap = new Map<Integer,String>();
            errorMessageMap.put(5,'Timeout. Did not get a response in time.');
            errorMessageMap.put(10,'Syntax OK.');
            errorMessageMap.put(20,'Syntax OK and the domain is valid.');
            errorMessageMap.put(45,'Domain is a catch all and does not support validation.');
            errorMessageMap.put(100,'General syntax error.');
            errorMessageMap.put(110,'Invalid character in address.');
            errorMessageMap.put(115,'Invalid domain syntax.');
            errorMessageMap.put(120,'Invalid username syntax.');
            errorMessageMap.put(125,'Invalid username syntax for that domain.');
            errorMessageMap.put(130,'Address is too long.');
            errorMessageMap.put(135,'Address has unbalance parentheses.');
            errorMessageMap.put(140,'Address doesn’t have a username.');
            errorMessageMap.put(145,'Address doesn’t have a domain.');
            errorMessageMap.put(150,'Address doesn’t have an @ sign.');
            errorMessageMap.put(155,'Address has more than one @ sign.');
            errorMessageMap.put(200,'Invalid top-level domain (TLD) in address.');
            errorMessageMap.put(205,'IP address is not allowed as a domain.');
            errorMessageMap.put(210,'Address contains an extra space or character.');
            errorMessageMap.put(215,'Unquoted spaces not allowed in email addresses.');
            errorMessageMap.put(310,'Domain doesn’t exist.');
            errorMessageMap.put(315,'Domain doesn’t have a valid IP address.');
            errorMessageMap.put(325,'Domain can’t receive email.');
            errorMessageMap.put(400,'Mailbox does not exist.');
            errorMessageMap.put(410,'The mailbox is full and can’t receive email.');
            errorMessageMap.put(420,'Mail is not accepted for this domain.');
            errorMessageMap.put(500,'Emails with that username aren’t accepted.');
            errorMessageMap.put(505,'Emails with that domain aren’t accepted.');
            errorMessageMap.put(510,'That address isn’t accepted.');
            errorMessageMap.put(520,'Address matched to known bouncers (optional feature).');
            errorMessageMap.put(525,'Address is a spamtrap, a known complainer or is suppressed.');
            errorMessageMap.put(530,'Address has opted out from commercial email.');
            errorMessageMap.put(999,'System error.');
            return errorMessageMap;
    }
    /*
    @description    : getLoanType - method which return type Of Loan
    @return         : Map of loan type
    */
    public static Map<String,String> getLoanType(){
        Map<String,String> loanTypeMap = new Map<String,String>{'11704'=>'PL','11403'=>'BL'};
        return loanTypeMap;
    }
}