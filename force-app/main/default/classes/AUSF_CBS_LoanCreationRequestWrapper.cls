/**
* @author        Rahul Yadav.
* @date          25-July-2024
* @description   
* Modification Log:
* Test Class     AUSF_CBS_LoanCreationTest
--------------------------------------------------------------------------------------------
Developer               Date            Description
--------------------------------------------------------------------------------------------
Rahul Yadav.            25-July-2024    Initial Version
*/
public without sharing class AUSF_CBS_LoanCreationRequestWrapper {
    public LoanAccountWrapper LoanAccount;
    public string ReferenceNumber;
    public string Channel;
    public ReportingParamWrapper ReportingParam;
    public string TransactionBranch;
    public class LoanAccountWrapper{
        public CustomerAndRelationWrapper CustomerAndRelation;
        public string AgreementNumber;
        public string LtvRatio;
        public string ProductCode;
        public string RateChartCode;
        public string CustomerId;
        public string RepaymentMode;
        public string ScheduleCode;
        public string LoanPurpose;
        public string AccountDateBasis;
        public string LoanTerm;
        public string LetterOfOfferDate;
        public string AcctOpenDate;
        public string AssetValue;
        public string AgreementSignDate;
        public string ApplicationId;
        public string FixedTermInMonths;
        public string FlgJointHolder;
        public AccountVarianceWrap AccountVariance;
    }
    public class CustomerAndRelationWrapper{
        public string Relation;
        public string CustomerId;
        public string CustomerName;
    }
    public class AccountVarianceWrap{
        public string rateType;
        public loanVarianceDetailsTypeWrap loanVarianceDetailsType;
        public string interestVarianceType;
        public string rescheduleType;
    }
    public class loanVarianceDetailsTypeWrap{
        public string endDate;
        public string variance;
        public string startDate;
    }
    public class ReportingParamWrapper{
        public string MISClass;
        public string MISCode;
    }
}