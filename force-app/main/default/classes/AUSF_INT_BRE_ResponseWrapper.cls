/**
 * @author              : Amit Mishra
 * @date                : 28-June-2024
 * @description         : FICO BRE response wrapper 
 * Test Class		    : AUSF_INT_BRE_Test
 * History:
 * ====================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ====================================================================
 * 28-June-2024 	Amit Mishra 		Initial Version
**/
public without sharing class AUSF_INT_BRE_ResponseWrapper {
    public AUSF_INT_BRE_ResponseWrapper() {}
    
    @AuraEnabled
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseWrapper;
    @AuraEnabled
    public Boolean blnIntegrationSuccess = false;
    @AuraEnabled
    public Boolean blnSuccess = false;
    @AuraEnabled
    public String strMessage;
    @AuraEnabled
    public Response response;


    public class Response{
        public String transactionId;       
        public Content content;
    }
	public class Content{
		public OutputVariables outputVariables;
		public String status;
	} 
	public class OutputVariables{
        public String name;//no use
        public Value MasterMessageOut;//check
	}
	public class Value{
		public Application application;
		public List<ErrorWrapper> error; 
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
		public ApplicationDecision applicationDecision;
	}
	public class ApplicationInfo{
        public String applicationNumber;//Loan Application Number/Name
		public String leadId;//Loan Application Id
        public String transactionId; // unique Id genererated
        public String branchCode;
        public String branchName;
		public String branchHub;
        public String branchRegion;
        public String applicationDate;
		public String applicationStage;
		public Integer applicationCounter;
		public String journeyType;
		public String channel;
		public String source;
        public String processingDate;
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
		public BureauResponse bureauResponse;
		public ApplicantDecision applicantDecision;
	}
	public class Product{
        public String productType;
        public String productCode;
        public String subProductType;
        public Double requestedLoanAmount;
        public ProductDecision productDecision;
	}
	public class ApplicationDecision{
		public String systemDecision;
        public String systemDecisionDate;
        public String strategyUsed;
        public List<CalculatedVariables> calculatedVariables;
        public List<RuleAudits> ruleAudits;
	}
    //ApplicationDecision sub class
    public class RuleAudits{
		public String metaphorName;
        public String ruleId;
        public String ruleName;
		public String timeStamp;
	}
    //ApplicationDecision sub class end
    //Applicants sub classes
	
	public class IdDetails{
        public String idType;
        public String idNumber;
        public Boolean isVerified;
		public String issueDate;
		public String expiryDate;
	}
	public class TelephoneDetails{
        public String telephoneExtention;
        public String telephoneNumber;
		public String telephoneType;
	}
	public class CompanyBusinessDetails{
        public String businessName;
        public String dateOfIncorporation;
        public String industry;
        public Integer noOfDirectors;
        public Integer noOfPartners;
		public Double noOfYearsInBusiness;
        public String occupation;
        public String sector;
		public String subIndustry;
	}
    public class IncomeData{
		public Double declaredAnnualTurnover;
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
		public String propertyType;
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
	public class BureauResponse{
		public List<CibilResponse> cibilResponse;
	}
	public class ApplicantDecision{
		public List<CalculatedVariables> calculatedVariables;
		public List<TraditionalScoreModels> traditionalScoreModels;
		public BureauBasedCommitmentDTls bureauBasedCommitmentDTls;
	}
    //ApplicantDecision sub class
	public class BureauBasedCommitmentDTls{
		public Double existingCommitment;
		public List<ExistingAccountCommitment> existingAccountCommitment;
	}
    // BureauBasedCommitmentDTls sub class
    public class ExistingAccountCommitment{
        public Double accountCommitment;
        public String accountNumber;
		public String dateClosed;
		public String dateOpen;
		public String accountType;
		public String reportingMemberShortName;
        public String ownershipIndicator;
		public String debtType;
		public Boolean isUnsecured;
		public Boolean accountExcluded;
		public String exclusionReason;
		public Integer tenure;
		public Double roi;
		public Double highCreditOrSanctionedAmount;
		public Double currentBalance;
		public String paymentHistory1;
		public String paymentHistory2;
		public Double emiAmount;
		public Double imputedeEMIAmount;
	}
    // BureauBasedCommitmentDTls sub class End
	public class TraditionalScoreModels{
        public String modelID;
        public String modelName;
        public Double baseScore;
		public Double totalScore;
		public String scoreBand;
		public String scoreBasedDecision;
        public String applicantId;
        public List<ScoreModelCharacteristic> scoreModelCharacteristic;
	}
    //TraditionalScoreModels sub class
    public class ScoreModelCharacteristic{
        public String characteristicName;
        public String characteristicValue;
        public String characteristicType;
        public String characteristicReason;
        public Double partialScore;
        public Double weight;
        public Double charScore;
	}
    //TraditionalScoreModels sub class end
    //ApplicantDecision sub class end
    //Product sub class
	public class ProductDecision{
        public String productDecision;//Required
        public Boolean isAppliedPromoCode;
        public String promoStartDate;
		public String promoEndDate;
		public List<CalculatedVariables> calculatedVariables;
		public OfferData offerData;
	}
    //Product sub class end
    public class CalculatedVariables{
		public String fieldName;
        public String fieldType;
        public String fieldValue;
		public String varCategory;
	}
	public class OfferData{
		public Double maxEligibleLoanAmount;//Required (for parsing)
        public Double maxFOIR;
        public Integer minTenure;//Required (for parsing)
        public Integer maxTenure;//Required (for parsing)
		public Double roi;//Required (for parsing)
		public List<RoiGrid> roiGrid;
		public List<StampDutyGrid> stampDutyGrid;
		public List<PfGrid> pfRateGrid;//pfGrid name changed in new response
		public List<LoanAmountTenureGrid> loanAmountTenureGrid;
	}
    // OfferData sub class
	public class RoiGrid{
		public Double minLoanAmount;
		public Double maxLoanAmount;
        public Double roi;
    }
	public class StampDutyGrid{
		public Double minLoanAmount;
        public Double maxLoanAmount;
        public Double stampDutyRate;//Required
	}
	public class PfGrid{
        public Double minLoanAmount;
        public Double maxLoanAmount;
		public Double processingFeesRate;//Required not is success response
	}
	public class LoanAmountTenureGrid{
        public Double minLoanAmount;
        public Double maxLoanAmount;
		public Integer maxTenure;
	}
    // OfferData sub class End	
	public class CibilResponse{
        public List<AccountSegment> accountSegment;
        public List<AddressList> addressList;
        public List<Enquiry> enquiry;
        public Header header;
		public List<ScoreSegment> scoreSegment;
		public String status;
		public Boolean isAddtionalMatch;//Required
	}
    //CibilResponse sub class
	public class AccountSegment{
        public String SegmentTag;
        public String ReportingNumberShortName;
        public String AccountNumber;
        public String AccountType;
        public String OwnershipIndicator;
        public String DateOpenedDisbursed;
        public String DateofLastPayment;
        public String DateClosed;
        public String DateReportedAndCertified;
		public Double HighCreditSanctionedAmount;
		public Double CurrentBalance;
		public Double AmountOverdue;
		public String PaymentHistory1;
		public String PaymentHistory2;
		public String PaymentHistoryStartDate;
		public String PaymentHistoryEndDate;
		public String SuitFiledWilfulDefault;
		public String CreditFacilityStatus;
        public Double ValueOfCollateral;
        public String TypeOfCollateral;
		public Double CreditLimit;
		public Double CashLimit;
		public Double RateOfInterest;
		public Integer RepaymentTenure;
		public Double EMIAmount;
		public Double WrittenOffAmountTotal;
		public Double WrittenOffAmountPrincipal;
		public Double SettlementAmount;
		public Integer PaymentFrequency;
		public Double ActualPaymentAmount;
		public String DateOfEntryForErrorCode;
		public String ErrorCode;
		public String DateOfEntryForCIBILRemarksCode;
		public String CIBILRemarksCode;
		public String DateOfEntryForErrorDisputeRemarksCode;
		public String ErrorDisputeRemarksCode1;
		public String ErrorDisputeRemarksCode2;
	}
	public class AddressList{
		public String AddressSegmentTag;
		public String Length;
		public String AddressLine1FieldLength;
		public String AddressLine1;
        public String AddressLine2FieldLength;
        public String AddressLine2;
		public String AddressLine3FieldLength;
		public String AddressLine3;
		public String StateCode;
		public String PinCodeFieldLength;
		public String PinCode;
		public String AddressCategory;
		public String DateReported;
		public String EnrichedThroughEnquiry;
	}
	public class Enquiry{
		public String Length;
        public String SegmentTag;
        public String DateOfEnquiryFields;
        public String EnquiringMemberShortNameFieldLength;
        public String EnquiringMemberShortName;
		public String EnquiryPurpose;
		public String EnquiryAmountFieldLength;
		public Decimal EnquiryAmount;
	}
	public class Header{
        public String SegmentTag;
        public String Version;
        public String ReferencEnumber;
        public String MemberCode;
		public String SubjectReturnCode;
		public String EnquiryControlNumber;
        public String DateProcessed;
        public String TimeProcessed;
	}
	public class ScoreSegment{
        public String Length;
        public String ScoreName;
        public String ScoreCardName;
        public String ScoreCardVersion;
        public String ScoreDate;
        public String Score;//Required
        public String ReasonCode1FieldLength;
        public String ReasonCode1;
		public String ReasonCode2FieldLength;
		public String ReasonCode2;
		public String ReasonCode3FieldLength;
		public String ReasonCode3;
		public String ReasonCode4FieldLength;
		public String ReasonCode4;
        public String ReasonCode5FieldLength;
        public String ReasonCode5;
	}
    //CibilResponse sub class End
	public class ErrorWrapper {
		public String stackTrace;//400 Bad Request:"{"error":{"code":"DBDesigner-Jar-Validation-DBD-126","timestamp":"2024-05-28T10:32:01.867+0000","desc":"Invalid request found.","details":[{"code":"DBDesigner-Jar-Field-Validation","target":"Field error: callType","desc":"Size must be between 0 and 20"}]}}"
		public String source;//PL - FICO CDE PLOR
		//public String dateTimeWrapper;//2024-05-28T10:13:04.347+0000
		public String errorCode;//PLOR_2001
		public String description;//Error running element 'Insert DM Data
	}
	public static AUSF_INT_BRE_ResponseWrapper.Response parseData(String jsonString){
		if(jsonString != NULL){
			Integration_Master__c integrationMaster = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.FICO_BRE_KNOCKOUT_INTEGRATION_MASTER);
			jsonString = integrationMaster.Static_Response__c;
		}
		AUSF_INT_BRE_ResponseWrapper.Response responseWrapper = (AUSF_INT_BRE_ResponseWrapper.Response)JSON.deserialize(jsonString, AUSF_INT_BRE_ResponseWrapper.Response.class);
		System.debug(responseWrapper);
		return responseWrapper;
	}
}