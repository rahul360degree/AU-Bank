/**
 * @author              : Amit Mishra
 * @date                : 28-June-2024
 * @description         : FICO BRE request wrapper 
 * Test Class		    : AUSF_INT_BRE_Test
 * History:
 * ====================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ====================================================================
 * 28-June-2024 	Amit Mishra 		Initial Version
**/
public without sharing class AUSF_INT_BRE_RequestWrapper {
    public AUSF_INT_BRE_RequestWrapper() {}

    public String name;
	public String RequestId;
	public String OriginatingChannel;
    public Value value;
	public class Value{
		public Application application;
		public String callType;
		public String decisionService;
		public String requestTime;
		public String callingSystem;
	}
    public class Application{
		public ApplicationInfo applicationInfo;
        public List<Applicants> applicants;
		public List<Product> product;
		public Integer randomNumber;
	}
	public class ApplicationInfo{
        public String applicationNumber;
		public String leadId;
        public String transactionId;
        public String branchCode;
        public String branchName;
		public String branchHub;
        public String branchRegion;
        public String applicationDate;//Xml.dateTime
		public String applicationStage;
		public Integer applicationCounter;
		public String journeyType;
		public String channel;
		public String source;
        public String processingDate;//XML.date
	}
	public class Applicants{
        public String customerName;
        public String applicantType;
        public String applicantId;
        public Boolean bureauPull;
		public Boolean isFinancialApplicant;
		public String customerType;
		public String customerSegment;
		public String customerLocationProfile;
		public String constitution;
		public Boolean existingCustomer;
		public String relationWithApplicant;
		public String birthPlace;
		public String dateOfBirth;
		public Double age;
		public String gender;
		public String nationality;
		public String maritalStatus;
		public Integer noOfDependents;
		public String residentType;
		public String customerRiskProfile;
		public Boolean isAUEmployee;
		public List<IdDetails> idDetails;
		public List<TelephoneDetails> telephoneDetails;
		public Boolean isETBAddressNotChanged;
		public String cfrStatus;
		public String amlStatus;
		public String relatedPartyStatus;
		public String negativePartyStatus;
        public Double totalRelationshipValue;
		public Boolean isLeadToLeadFullMatch;
		public Boolean isLeadToLeadPartialMatch;
		public Boolean isLeadToCustomerPartialMatch;
		public CompanyBusinessDetails companyBusinessDetails;
		public IncomeData incomeData;
		public List<Address> address;
		public EducationDetails educationDetails;
	}
	public class Product{
		public String productType;
        public String productCode;
        public String subProductType;
		public Double requestedROI;
		public Double requestedInstallmentAmount;
		public Double requestedLoanAmount;
	}
	public class IdDetails{
		public String idType;//ENUM
		public String idNumber;
        public Boolean isVerified;
        //public String issueDate;//XML.date
		//public String expiryDate;//XML.date
	}
	public class TelephoneDetails{
        public String telephoneExtention;
        public String telephoneNumber;
        public String telephoneType;
	}
	public class CompanyBusinessDetails{
        public String businessName;
		public String occupation;
		public String sector;
		public String industry;
		public String subIndustry;
        public Integer noOfDirectors;
        public Integer noOfPartners;
        public Double noOfYearsInBusiness;
        //public String dateOfIncorporation;//XML.date

	}
	public class IncomeData{
		public Double declaredAnnualTurnover;
		public Double declaredNetMonthlyIncome;
	}
	public class Address{
		public String addressType;
        public String pinCode;
        public String district;
        public String city;
        public String state;
        public String taluka;
        public String country;
        public Double timeAtCurrentCity;
        public Double timeAtCurrentAddress;
        public String ownershipStatus;
		//public String propertyType;
		public Double distanceFromBranch;
		public String locationType;
		public String locationSubType;
		public Boolean isNegativeArea;
		public Boolean isResiCumOffice;
		public String pinCodeCategory;
		public String address;
	}
	public class EducationDetails{
        public String educationStatus;
        public String professionalQualification;
		public Boolean isProfessionalDegreeVerified;
	}
}