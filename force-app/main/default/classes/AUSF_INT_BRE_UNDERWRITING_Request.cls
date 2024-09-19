/**
 * @author              : Amit Mishra
 * @date                : 20-June-2024
 * @description         : BRE UNDERWRITING API Request Wrapper
 * Test Class           : 
 * History              :
 * ===========================================================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ===========================================================================================================
 * 20-June-2024 	Amit Mishra 		Initial Version
**/public with sharing class AUSF_INT_BRE_UNDERWRITING_Request {
    public AUSF_INT_BRE_UNDERWRITING_Request() {}
	
	public String name;
	public String RequestId;
	public String OriginatingChannel;
    public ValueWrapper value;

	public class ValueWrapper{
		public ApplicationWrapper application;
		public String callType;
		public String decisionService;
		public String requestTime;
		public String callingSystem;
	}
	public class ApplicationWrapper{
		public ApplicationInfoWrapper applicationInfo;
		public List<ApplicantWrapper> applicants;
		public List<ProductWrapper> product;
		public Integer randomNumber;
	}
	public class ApplicationInfoWrapper{
		public String applicationNumber;
		public String applicationDate;
		public String applicationStage;
		public Integer applicationCounter;
		public String leadId;
		public String transactionId;
		public String branchCode;
		public String branchName;
		public String branchHub;
		public String branchRegion;
		public String journeyType;
		public String channel;
		public String source;
		//public String processingDate;
	}
	public class ApplicantWrapper {
		public String customerName;
		public String applicantType;
		public String applicantId;
		public Boolean bureauPull;
		public String customerType;//ENUM
		public String customerSegment;//ENUM
		public String customerLocationProfile;//ENUM - METRO,NON_METRO,OTHERS
		public String constitution;//ENUM
		public Boolean existingCustomer;
		public String relationWithApplicant;//SELF
		public String birthPlace;//RAJASTHAN
		//public String dateOfBirth;
		public Double age;//360
		public String gender;//Male
		public String nationality;//Indian
		public String maritalStatus;//SINGLE
		public Integer noOfDependents;//2
		public String residentType;//RESIDENT
		public String customerRiskProfile;//NORMAL
		public String cfrStatus;//NO_MATCH
		public String amlStatus;//NO_MATCH
		public String relatedPartyStatus;//NO_MATCH
		public String negativePartyStatus;//NO_MATCH
		//public Double totalRelationshipValue = 0;
		public Boolean isFinancialApplicant;
		public Boolean isAUEmployee;
		public Boolean isETBAddressNotChanged;
		public Boolean isLeadToLeadFullMatch;
		public Boolean isLeadToLeadPartialMatch;
		public Boolean isLeadToCustomerPartialMatch;
		public IncomeDataWrapper incomeData;
		public List<AddressWrapper> address;
		public List<IdDetailsWrapper> idDetails;
		public EducationDetailsWrapper educationDetails;
		public EmploymentDetailsWrapper employmentDetails;
		public List<TelephoneDetailsWrapper> telephoneDetails;
		//public CompanyBusinessDetailsWrapper companyBusinessDetails;
	}
	public class IdDetailsWrapper {
		public String idType;
		public String idNumber;
		public Boolean isVerified;
		//public String issueDate;
		//public String expiryDate;
	}
	
	public class TelephoneDetailsWrapper {
		public String telephoneExtention;
		public String telephoneNumber;
		public String telephoneType;
	}
	/*public class CompanyBusinessDetailsWrapper {
		public String businessName;
		public String occupation;
		public String sector;
		public String industry;
		public String subIndustry;
		public Integer noOfDirectors;
		public Integer noOfPartners;
		public Double noOfYearsInBusiness;
		public String dateOfIncorporation;	//2020-01-01T10:10:10.100Z
	}*/
	public class EmploymentDetailsWrapper{
		public String employmentType;//ENUM SALARIED_GOVERNMENT or SALARIED_PRIVATE
		public String employerName;
		public String sector;
		public String occupation;
		public String industry;
		public String subIndustry;
		public String companyCategory;//ENUM
		public Boolean isEmploymentVerified;
		public Integer timeWithCurrentEmployer;//In months
		public Integer totalWorkExperience;//In months
	}
	public class IncomeDataWrapper {
		public Double declaredAnnualTurnover;
	}
	public class AddressWrapper {
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
	public class EducationDetailsWrapper {
		public String educationStatus;
		public String professionalQualification;
		//public Boolean isProfessionalDegreeVerified;
	}
	public class ProductWrapper {
		public String productType;
		public String productCode;
		public String subProductType;
		public Double requestedLoanAmount;
	}
}

/*	public static fromJSON parse(String json){
		return (fromJSON) System.JSON.deserialize(json, fromJSON.class);
	}

	static testMethod void testParse() {
		String json=		'['+
		'	{'+
		'		"name": "MasterMessageIn",'+
		'		"value": {'+
		'			"application": {'+
		'				"applicationInfo": {'+
		'					"applicationNumber": "APP01012312",'+
		'					"leadId": "LID00152",'+
		'					"transactionId": "T0001",'+
		'					"branchCode": "2365",'+
		'					"branchName": "Akola_Necklace Road",'+
		'					"branchHub": "Akola",'+
		'					"branchRegion": "Akola",'+
		'					"applicationDate": "2024-05-25T06:32:36.163Z",'+
		'					"applicationStage": "QDE",'+
		'					"applicationCounter": 0,'+
		'					"journeyType": "NTB",'+
		'					"channel": "DIY",'+
		'					"source": "MOBILE",'+
		'					"processingDate": "2024-06-04"'+
		'				},'+
		'				"applicants": ['+
		'					{'+
		'						"customerName": "Gaurav Sharma",'+
		'						"applicantType": "PRIMARY",'+
		'						"applicantId": "APP001",'+
		'						"bureauPull": false,'+
		'						"isFinancialApplicant": true,'+
		'						"customerType": "I",'+
		'						"customerSegment": "SELF_EMPLOYED",'+
		'						"customerLocationProfile": "METRO",'+
		'						"constitution": "INDIVIUDAL",'+
		'						"existingCustomer": false,'+
		'						"relationWithApplicant": "SELF",'+
		'						"birthPlace": "RAJASTHAN",'+
		'						"age": 360,'+
		'						"gender": "Male",'+
		'						"nationality": "Indian",'+
		'						"maritalStatus": "SINGLE",'+
		'						"noOfDependents": 2,'+
		'						"residentType": "RESIDENT",'+
		'						"customerRiskProfile": "NORMAL",'+
		'						"isAUEmployee": false,'+
		'						"idDetails": ['+
		'							{'+
		'								"idType": "AADHAAR",'+
		'								"idNumber": "639565421230",'+
		'								"isVerified": true,'+
		'								"issueDate": "2024-05-24T06:32:36.163Z",'+
		'								"expiryDate": "2024-05-24T06:32:36.163Z"'+
		'							},'+
		'							{'+
		'								"idType": "PAN",'+
		'								"idNumber": "BBPPS2564A",'+
		'								"isVerified": true,'+
		'								"issueDate": "2024-05-24T06:32:36.163Z",'+
		'								"expiryDate": "2024-05-24T06:32:36.163Z"'+
		'							}'+
		'						],'+
		'						"telephoneDetails": ['+
		'							{'+
		'								"telephoneExtention": "044",'+
		'								"telephoneNumber": "9887115555",'+
		'								"telephoneType": "01"'+
		'							}'+
		'						],'+
		'						"isETBAddressNotChanged": false,'+
		'						"cfrStatus": "NO_MATCH",'+
		'						"amlStatus": "NO_MATCH",'+
		'						"relatedPartyStatus": "NO_MATCH",'+
		'						"negativePartyStatus": "NO_MATCH",'+
		'						"totalRelationshipValue": 0,'+
		'						"isLeadToLeadFullMatch": false,'+
		'						"isLeadToLeadPartialMatch": false,'+
		'						"isLeadToCustomerPartialMatch": false,'+
		'						"companyBusinessDetails": {'+
		'							"businessName": "Industry",'+
		'							"dateOfIncorporation": "2020-01-01T10:10:10.100Z",'+
		'							"industry": "text",'+
		'							"noOfDirectors": 1,'+
		'							"noOfPartners": 1,'+
		'							"noOfYearsInBusiness": 10.5,'+
		'							"occupation": "text",'+
		'							"sector": "text",'+
		'							"subIndustry": "text"'+
		'						},'+
		'						"incomeData": {'+
		'							"declaredAnnualTurnover": 1000000'+
		'						},'+
		'						"address": ['+
		'							{'+
		'								"addressType": "CURRENT",'+
		'								"pinCode": "302001",'+
		'								"district": "RAJSHTHAN",'+
		'								"city": "Jaipur",'+
		'								"state": "Jaipur",'+
		'								"taluka": "Jaipur",'+
		'								"country": "India",'+
		'								"timeAtCurrentCity": 0,'+
		'								"timeAtCurrentAddress": 0,'+
		'								"ownershipStatus": "OWNED",'+
		'								"propertyType": "INDEPENDENT_HOUSE",'+
		'								"distanceFromBranch": 0,'+
		'								"locationType": "URBAN",'+
		'								"locationSubType": "METRO",'+
		'								"isNegativeArea": false,'+
		'								"isResiCumOffice": false,'+
		'								"pinCodeCategory": "WORKING",'+
		'								"address": "SR NO 2/1 2,PLOT NO 14"'+
		'							},'+
		'							{'+
		'								"addressType": "BUSINESS",'+
		'								"pinCode": "302001",'+
		'								"district": "RAJSHTHAN",'+
		'								"city": "Jaipur",'+
		'								"state": "Jaipur",'+
		'								"taluka": "Jaipur",'+
		'								"country": "India",'+
		'								"timeAtCurrentCity": 0,'+
		'								"timeAtCurrentAddress": 0,'+
		'								"ownershipStatus": "OWNED",'+
		'								"propertyType": "RESIDENTIAL_OFFICE",'+
		'								"distanceFromBranch": 0,'+
		'								"locationType": "URBAN",'+
		'								"locationSubType": "METRO",'+
		'								"isNegativeArea": false,'+
		'								"isResiCumOffice": false,'+
		'								"pinCodeCategory": "WORKING",'+
		'								"address": "SROT NO 14"'+
		'							}'+
		'						],'+
		'						"educationDetails": {'+
		'							"educationStatus": "UNEDUCATED",'+
		'							"professionalQualification": "string",'+
		'							"isProfessionalDegreeVerified": true'+
		'						}'+
		'					}'+
		'				],'+
		'				"product": ['+
		'					{'+
		'						"productType": "PL",'+
		'						"productCode": "0256",'+
		'						"subProductType": "string",'+
		'						"requestedLoanAmount": 600000'+
		'					}'+
		'				],'+
		'				"randomNumber": 0'+
		'			},'+
		'			"callType": "DP_UNDERWRITING",'+
		'			"decisionService": "DS_PL",'+
		'			"requestTime": "Apr 25, 2024 01:53:01.724 PM IST",'+
		'			"callingSystem": "DIY"'+
		'		}'+
		'	}'+
		']';
		fromJSON obj = parse(json);
		System.assert(obj != null);
	}
	*/