/**
* @author        Pradeep Sharma
* @date          05-July-2024
* @description   Wrapper to store Response body
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        05-July-2024    Initial Version
*/
    public class AUSF_HunterAPIResponseWrapper{
    public AUSF_HunterAPIResponseWrapper(){}
    @AuraEnabled
    public MatchSummary MatchSummary;
    @AuraEnabled
    public ErrorWarnings ErrorWarnings;
    @AuraEnabled
    public TransactionStatus TransactionStatus;
public class Warnings{
    @AuraEnabled
    public Warning Warning;
}
public class Warning{
    @AuraEnabled
    public String Message;
    @AuraEnabled
    public String NumberTemp; //Number
    @AuraEnabled
    public Values Values;
}
public class Values{
    @AuraEnabled
    public list<String> Value;
}
public class TransactionStatus{
    @AuraEnabled
    public String ResponseMessage;
    @AuraEnabled
    public String ResponseCode;
}
public class Scheme{
    @AuraEnabled
    public String Score;
    @AuraEnabled
    public String SchemeID;
}
public class Rules{
    @AuraEnabled
    public list<Rule> Rule;
    @AuraEnabled
    public String totalRuleCount; //@totalRuleCount
}
public class Rule{
    @AuraEnabled
    public String Score;
    @AuraEnabled
    public String RuleID;
}
public class MatchSummary{
    @AuraEnabled
    public Rules Rules;
    @AuraEnabled
    public MatchSchemes MatchSchemes;
    @AuraEnabled
    public String TotalMatchScore;
    @AuraEnabled
    public String matches; //@matches
}
public class MatchSchemes{
    @AuraEnabled
    public list<Scheme> Scheme;
}
public class ErrorWarnings{
    @AuraEnabled
    public Warnings Warnings;
    @AuraEnabled
    public String Errors;
}
}