/**
* @author        Tejendra
* @date          22-July-2024
* @description   Wrapper for CIF Modification request payload
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra            22-July-2024     Initial Version - APL-226
*/
public without sharing class AUSF_CIFModificationRequestWrapper {
    public AUSF_CIFModificationRequestWrapper() {

    }
    public String RequestId;
    public String Channel;
    public String TransactionBranch;
    public String ReferenceNumber;
    public IndividualCustomerWrapper IndividualCustomer;
    public CorporateCustomerWrapper CorporateCustomer;
    public CustomerProfilingDetailsWrapper CustomerProfilingDetails;

    public class IndividualCustomerWrapper{
        public AddressWrapper Address;
        public AddressWrapper MailingAddress;
        public String InoperativePan;
        public String CustomerId;
        public String EmailId;
        public String PAN;
    }

    public class CorporateCustomerWrapper{
        public AddressWrapper Address;
        public AddressWrapper MailingAddress;
        public String InoperativePan;
        public String MobileNumber;
        public String EmailId;
        public String CustomerId;
        public String PAN; 
    }

    public class CustomerProfilingDetailsWrapper{
        public String Activity;
        public String BusinessProfiler;
        public String CustCategory;
        public String IncomeProfiler;
        public String Industry;
        public String Sector;
        public String SubIndustry;
    }

    public class AddressWrapper{
        public String Zip;
        public String State;
        public String Country;
        public String City;
        public String Line1;
        public String Line2;
        public String Line3;
        public String Line4;
    }
}