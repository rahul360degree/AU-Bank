/**
* @author        Pradeep Sharma
* @date          05-July-2024
* @description   Wrapper for creating request body
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Pradeep Sharma        05-July-2024    Initial Version
*/
public class AUSF_HunterAPIRequestWrapper{
    public AUSF_HunterAPIRequestWrapper(){}
    public ControlBlock ControlBlock;
    public String TransactionBranch;
    public BatchBlock BatchBlock;
    public String ReferenceNumber;
    public String Username;
    public String OriginatingChannel;
    public String Password;
    public String RequestId;
public class Submissions{
    public Submission Submission;
}
public class Submission{
    public String LoanPurpose;
    public String ApplicationDate;
    public String SubmissionDate;
    public String Identifier;
    public String ProductCode;
    public String Classification;
    public MainApplicant MainApplicant;
}
public class SpecificScores{
    public String ResultType;
    public String ScoreType;
}
public class Scores{
    public SpecificScores SpecificScores;
}
public class Results{
    public Scores Scores;
    public String ResultCode;
}
public class ResidentialAddress{
    public String AddressLines;
    public String Pincode;
    public String Country;
    public String State;
    public String City;
}
public class PermanentAddress{
    public String AddressLines;
    public String City;
    public String State;
    public String Pincode;
    public String Country;
}
public class MobileTelephone{
    public String TelephoneNumber;
}
public class MatchSchemeSet{
    public list<String> SchemeSetID;
}
public class Matching{
    public String WorklistInsert;
    public String PersistMatches;
    public MatchSchemeSet MatchSchemeSet;
}
public class MainApplicant{
    public String Age;
    public String Gender;
    public String DOB;
    public String MaritalStatus;
    public String LastName;
    public String Qualification;
    public String FirstName;
    public String MonthlySalary;
    public String PAN_No;
    public ResidentialAddress ResidentialAddress;
    public HomeTelephone HomeTelephone;
    public MobileTelephone MobileTelephone;
    public BusinessTelephone BusinessTelephone;
    public PermanentAddress PermanentAddress;
    public Email Email;
    public IDDocument IDDocument;
}
public class Loading{
    public String SuppressVersion;
    public String SubmissionLoad;
}
public class IDDocument{
    public String DocumentType;
    public String DocNumber;
}
public class HomeTelephone{
    public String TelephoneNumber;
}
public class Header{
    public String Originator;
    public String Count;
}
public class Email{
    public String EmailAddress;
}
public class Customer{
    public String CustomerName;
    public String CustomerID;
}
public class ControlBlock{
    public Matching Matching;
    public Results Results;
    public Loading Loading;
    public Customer Customer;
}
public class BusinessTelephone{
    public String TelephoneNumber;
}
public class BatchBlock{
    public Header Header;
    public Submissions Submissions;
}
}