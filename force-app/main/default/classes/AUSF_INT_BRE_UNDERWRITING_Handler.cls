/**
 * @author              : Amit Mishra
 * @date                : 29-June-2024
 * @description         : BRE UNDERWRITING API handler to handle request
 * Test Class           : AUSF_INT_BRE_Test
 * History              :
 * ===========================================================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ===========================================================================================================
 * 29-June-2024 	Amit Mishra 		Initial Version
**/
public without sharing class AUSF_INT_BRE_UNDERWRITING_Handler implements AUSF_INT_IntegrationHandlerInterface{

    public List<Object> generateRequest(List<Object> inputWrappers){
        List<String> requestStringList = new List<String>();
        if (inputWrappers.isEmpty()) {
            return requestStringList;
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        String referenceId = String.valueOf(inputWrapper.dynamicInputs.get(AUSF_INT_BRE_Constants.BRE_REFERENCE_ID));
        AUSF_INT_BRE_UNDERWRITING_Request requestWrapper = new AUSF_INT_BRE_UNDERWRITING_Request();
        requestWrapper.value = getValueWrapper(inputWrapper, referenceId);
        requestWrapper.name = AUSF_INT_BRE_Constants.BRE_REQUEST_WRAPPER_NAME;
        requestWrapper.RequestId = referenceId;
        requestWrapper.OriginatingChannel = inputWrapper.integrationMasterRecord.Channel__c;
        requestStringList.add(JSON.serialize(requestWrapper));
        return requestStringList;
    }

    public List<String> validateInputData(List<Object> inputWrappers){
        List<String> validationErrorsList = new List <String>();
        /*
        applicantWrapper.customerSegment = applicant.Employment_Type__c?.toUpperCase();//'SALARIED'
        appInfo.branchCode = loanApp.Branch__r.Account_Code__c;
        appInfo.branchName = loanApp.Branch__r.Name;
        appInfo.branchHub = loanApp.Branch__r.Hub_Code__c;//Change later
        appInfo.branchRegion = loanApp.Branch__r.Region_Code__c;//Change later
        */
        return validationErrorsList;
    }

    public List<sObject> generatePlatformEvents(List<Object> recordList){
        return NULL;
    }

    public void callbackService(List<Integration_Checklist__c> checklistRecords, List<ContentVersion> responseFiles){/*To Do*/}
    public void beforeUpdateService(Integration_Checklist__c checklistRecord, ContentVersion responseFile){/*To Do*/} 

    // =========================================================================================================
    //      Helper methods to get and set wrapppers
    // =========================================================================================================
    /*
    @description    : getValueWrapper - return value warapper
    @param1         : AUSF_INT_IntegrationUtility.InputWrapper
    @param2         : referenceId : unique requestId
    @return         : AUSF_INT_BRE_UNDERWRITING_Request.ValueWrapper - Value warpper
    */
	public static AUSF_INT_BRE_UNDERWRITING_Request.ValueWrapper getValueWrapper(AUSF_INT_IntegrationUtility.InputWrapper inputWrapper,String referenceId){
		List<Applicant__c> applicant = new List<Applicant__c> {inputWrapper.applicantRecord};
        List<Location_Master__c> locationMaster = (List<Location_Master__c>)inputWrapper.dynamicInputs.get(AUSF_INT_BRE_Constants.LOCATION_MASTER);
        //Set ValueWrapper
        AUSF_INT_BRE_UNDERWRITING_Request.ValueWrapper value = new AUSF_INT_BRE_UNDERWRITING_Request.ValueWrapper();
		value.callType = String.valueOf(inputWrapper.dynamicInputs.get(AUSF_INT_BRE_Constants.BRE_CALLTYPE));//'DP_UNDERWRITING';
		value.decisionService = AUSF_INT_BRE_Constants.BRE_REQUEST_DECISION_SERVICE_DS_PL;
		value.callingSystem = AUSF_INT_BRE_Constants.BRE_REQUEST_CALLING_SYSTEM_NAME;
        value.requestTime = AUSF_INT_BRE_Utility.formatDateTime(DateTime.now(),1);
        value.application = getAapplication(inputWrapper.loanRecord, applicant, referenceId, locationMaster[0]);
        return value;
	}
    /*
    @description    : getAapplication - set and return wrapper 
    @param1         : loanApp - Loan Application object
    @param2         : applicant - Applicant object
    @param3         : referenceId - Unique Request Id
    @param4         : locationMaster - Loacation Master Object
    @return         : AUSF_INT_BRE_UNDERWRITING_Request.ApplicationWrapper warpper
    */
    private static AUSF_INT_BRE_UNDERWRITING_Request.ApplicationWrapper getAapplication(Loan_Application__c loanApp, List<Applicant__c> applicant, String referenceId, Location_Master__c locationMaster){
        AUSF_INT_BRE_UNDERWRITING_Request.ApplicationWrapper applicationWrapper = new AUSF_INT_BRE_UNDERWRITING_Request.ApplicationWrapper();
        applicationWrapper.applicationInfo = getApplicationInfo(loanApp, applicant[0], referenceId);
        applicationWrapper.applicants = getApplicants(loanApp, applicant, locationMaster) ;
        applicationWrapper.product = getProduct(loanApp);
        applicationWrapper.randomNumber = Integer.valueof((Math.random() * 100));
        return applicationWrapper;
    }

    /*
    @description    : getApplicationInfo - set and return wrapper 
    @param1         : loanApp - Loan Application object
    @param2         : applicant - Applicant object
    @param3         : referenceId - Unique Request Id
    @return         : AUSF_INT_BRE_UNDERWRITING_Request.ApplicationInfo warpper
    */
    private static AUSF_INT_BRE_UNDERWRITING_Request.ApplicationInfoWrapper getApplicationInfo(Loan_Application__c loanApp, Applicant__c applicant, String referenceId ){
        AUSF_INT_BRE_UNDERWRITING_Request.ApplicationInfoWrapper appInfo = new AUSF_INT_BRE_UNDERWRITING_Request.ApplicationInfoWrapper();
        appInfo.applicationNumber = loanApp.Name;
		appInfo.leadId = loanApp.Id ;
        appInfo.transactionId = referenceId;
        appInfo.branchCode = loanApp.Branch__r.Account_Code__c;
        appInfo.branchName = loanApp.Branch__r.Name;
		appInfo.branchHub = 'ALOKA';//loanApp.Branch__r.Hub_Code__c;
        appInfo.branchRegion = 'ALOKA';//loanApp.Branch__r.Region_Code__c;
        appInfo.applicationDate = AUSF_INT_BRE_Utility.formatDateTime(loanApp.CreatedDate,1);
		appInfo.applicationStage = loanApp.Stage__c;
        appInfo.applicationCounter = loanApp.BRE_Knockout_Application_Counter__c != NULL ? loanApp.BRE_Knockout_Application_Counter__c.intValue()+1 :1;//change
        String journeyType = AUSF_INT_BRE_Utility.checkjourney(loanApp,applicant);
        if(journeyType != NULL){
		    appInfo.journeyType = journeyType;
        }  
		appInfo.channel = loanApp.Sourcing_Channel__c;
		appInfo.source = AUSF_INT_BRE_Constants.BRE_REQUEST_APPLICATION_INFO_SOURCE_MOBILE;
        //appInfo.processingDate = String.valueOf(Date.today());
        return appInfo;
    }
    /*
    @description    : getApplicants - set and return wrapper 
    @param1         : loanApp - Loan Application object
    @param2         : applicantList - List Applicant__c object
    @param3         : locationMaster - Loacation Master object
    @return         : AUSF_INT_BRE_UNDERWRITING_Request.Applicants warpper list
    */
    private static List<AUSF_INT_BRE_UNDERWRITING_Request.ApplicantWrapper> getApplicants(Loan_Application__c loanApp, List<Applicant__c> applicantList, Location_Master__c locationMaster){
        List<AUSF_INT_BRE_UNDERWRITING_Request.ApplicantWrapper> applicantWrapperList = new List<AUSF_INT_BRE_UNDERWRITING_Request.ApplicantWrapper>();
        for(Applicant__c applicant : applicantList){
            AUSF_INT_BRE_UNDERWRITING_Request.ApplicantWrapper applicantWrapper = new AUSF_INT_BRE_UNDERWRITING_Request.ApplicantWrapper();
            applicantWrapper.customerType = 'I';
            applicantWrapper.customerName = applicant.Full_Name__c;
            applicantWrapper.customerSegment = applicant?.Employment_Type__c?.toUpperCase();
            applicantWrapper.customerLocationProfile = (locationMaster != NULL && !String.isEmpty(locationMaster.CityType__c)) ? locationMaster.CityType__c.toUpperCase():'OTHERS';
            applicantWrapper.customerRiskProfile = 'NORMAL';
            applicantWrapper.existingCustomer = applicant.NTB_ETB__c == 'ETB' ? true : false;
            if(String.isNotBlank(applicant.RecordType?.DeveloperName)){
                applicantWrapper.applicantType = applicant.RecordType.DeveloperName.toUpperCase();//If Applicant Type is primary then Self
            }
            applicantWrapper.applicantId = applicant.Id ;
            applicantWrapper.bureauPull = true;
            applicantWrapper.isFinancialApplicant = true;
            applicantWrapper.constitution = applicant.KYC_Type__c;//Change
            applicantWrapper.relationWithApplicant = 'SELF';
            applicantWrapper.birthPlace = 'INDIA';
            //applicantWrapper.dateOfBirth = AUSF_INT_BRE_Utility.formatDateTime(applicant.Birth_Date__c,1);
            applicantWrapper.age = applicant.Age__c;
            applicantWrapper.gender = applicant.Gender__c;
            applicantWrapper.nationality = String.isNotBlank(applicant.Nationality__c) ? applicant.Nationality__c :'INDIA';
            if(String.isNotBlank( applicant.Marital_Status__c)){
                applicantWrapper.maritalStatus = applicant.Marital_Status__c?.toUpperCase();
            }
            applicantWrapper.noOfDependents = 0;
            applicantWrapper.residentType = 'RESIDENT';//ENUM
            applicantWrapper.isAUEmployee = applicant.Employee__c == 'Yes'? true : false;
            applicantWrapper.isETBAddressNotChanged = true;
            applicantWrapper.cfrStatus = (applicant.CFR_Check__c != NULL && applicant.CFR_Check__c == 'True')? 'FULL_MATCH' : 'NO_MATCH';
            applicantWrapper.amlStatus = (applicant.AML_verified__c != NULL && applicant.AML_verified__c == 'Yes')? 'FULL_MATCH' : 'NO_MATCH';
            applicantWrapper.relatedPartyStatus = 'NO_MATCH';
            applicantWrapper.negativePartyStatus = 'NO_MATCH';
            //applicantWrapper.totalRelationshipValue = 0;
            applicantWrapper.isLeadToLeadFullMatch = true;//new Field is Mapped
            applicantWrapper.isLeadToLeadPartialMatch = false;
            applicantWrapper.isLeadToCustomerPartialMatch = false;
             
            applicantWrapper.idDetails = getIdDetails(applicant);
            applicantWrapper.telephoneDetails = getTelephoneDetails(loanApp);
            //applicantWrapper.companyBusinessDetails = getCompanyBusinessDetails(applicant);
            applicantWrapper.employmentDetails = getEmploymentDetails(applicant);
            applicantWrapper.incomeData = getIncomeData();
            applicantWrapper.address = getAddress(applicant.Addresses__r, locationMaster);
            applicantWrapper.educationDetails = getEducationDetails(applicant);
            applicantWrapperList.add(applicantWrapper);
        }
        return applicantWrapperList;
    }
    /*
    @description    : getIdDetails - set and return wrapper 
    @param1         : applicant - Applicant__c object
    @return         : AUSF_INT_BRE_UNDERWRITING_Request.IdDetailsWrapper warpper list
    */
    private static List<AUSF_INT_BRE_UNDERWRITING_Request.IdDetailsWrapper> getIdDetails(Applicant__c applicant){
        List<AUSF_INT_BRE_UNDERWRITING_Request.IdDetailsWrapper> idDetailsWrapperList = new List<AUSF_INT_BRE_UNDERWRITING_Request.IdDetailsWrapper>();
        AUSF_INT_BRE_UNDERWRITING_Request.IdDetailsWrapper idDetailsWrapper = new AUSF_INT_BRE_UNDERWRITING_Request.IdDetailsWrapper();
        idDetailsWrapper.idType = 'PAN';
		idDetailsWrapper.idNumber = applicant.PAN__c;
        idDetailsWrapper.isVerified = applicant.Is_PAN_Verified__c == 'Yes'?true: false;
        //idDetailsWrapper.issueDate = AUSF_INT_BRE_Utility.formatDateTime(mydate,1);
		//idDetailsWrapper.expiryDate = AUSF_INT_BRE_Utility.formatDateTime(mydate,1);
        idDetailsWrapperList.add(idDetailsWrapper);
        return idDetailsWrapperList;
    }
    /*
    @description    : getTelephoneDetails - set and return wrapper 
    @param1         : loanApp - Loan Application object
    @return         : AUSF_INT_BRE_UNDERWRITING_Request.TelephoneDetailsWrapper warpper list
    */
    private static List<AUSF_INT_BRE_UNDERWRITING_Request.TelephoneDetailsWrapper> getTelephoneDetails(Loan_Application__c loanApp){
        List<AUSF_INT_BRE_UNDERWRITING_Request.TelephoneDetailsWrapper> telephoneDetailsWrapperList = new List<AUSF_INT_BRE_UNDERWRITING_Request.TelephoneDetailsWrapper>();
        AUSF_INT_BRE_UNDERWRITING_Request.TelephoneDetailsWrapper telephoneDetailsWrapper = new AUSF_INT_BRE_UNDERWRITING_Request.TelephoneDetailsWrapper();
        telephoneDetailsWrapper.telephoneExtention = '';
        telephoneDetailsWrapper.telephoneType = 'Mobile';
        telephoneDetailsWrapper.telephoneNumber = loanApp.Mobile_Number__c;
        telephoneDetailsWrapperList.add(telephoneDetailsWrapper);
        return telephoneDetailsWrapperList;
    }
    
    /*
    @description    : getCompanyBusinessDetails - set and return wrapper 
    @param1         : applicant - Applicant__c object
    @return         : AUSF_INT_BRE_UNDERWRITING_Request.EmploymentDetailsWrapper warpper
    */
    public static AUSF_INT_BRE_UNDERWRITING_Request.EmploymentDetailsWrapper getEmploymentDetails(Applicant__c applicant){
        Employment_Detail__c empDetail = new Employment_Detail__c();
        empDetail = applicant.Employment_Details__r;
        Integer currentEmpDurationYears = String.isBlank(empDetail?.Current_Employment_Duration_Years__c)? 0 : Integer.valueOf(empDetail.Current_Employment_Duration_Years__c);
		Integer currentEmpDurationMonths = String.isBlank(empDetail?.Current_Employment_Duration_Months__c)? 0 : Integer.valueOf(empDetail.Current_Employment_Duration_Months__c);
        Integer workExperienceYears = String.isBlank(empDetail?.Total_Employment_Duration_Years__c)? 0 : Integer.valueOf(empDetail.Total_Employment_Duration_Years__c);
		Integer workExperienceMonths = String.isBlank(empDetail?.Total_Employment_Duration_Months__c)? 0 : Integer.valueOf(empDetail.Total_Employment_Duration_Months__c);
		
        AUSF_INT_BRE_UNDERWRITING_Request.EmploymentDetailsWrapper employmentDetail = new AUSF_INT_BRE_UNDERWRITING_Request.EmploymentDetailsWrapper();
        employmentDetail.employmentType = applicant?.Employment_Type__c;
        employmentDetail.occupation = applicant?.Employment_Type__c;
		employmentDetail.employerName = empDetail?.Registered_Business_name__c;
		//employmentDetail.sector = empDetail?.Sector__r?.Name;
		//employmentDetail.industry = empDetail?.Industry__r?.Name;
		//employmentDetail.subIndustry = empDetail?.Sub_Industry__r?.Name;
		//employmentDetail.companyCategory = empDetail.;//check
		employmentDetail.isEmploymentVerified = (empDetail?.Is_EPFO_Verified__c || empDetail?.Is_Work_Email_Id_Verified__c) ? true : false;
        employmentDetail.timeWithCurrentEmployer = currentEmpDurationYears * 12 + currentEmpDurationMonths;//In months
        employmentDetail.totalWorkExperience = workExperienceYears * 12 + workExperienceMonths;//In months
        return employmentDetail;
    }
    /*
    @description    : getCompanyBusinessDetails - set and return wrapper 
    @param1         : applicant - Applicant__c object
    @return         : AUSF_INT_BRE_UNDERWRITING_Request.CompanyBusinessDetailsWrapper warpper
    */
    /*public static AUSF_INT_BRE_UNDERWRITING_Request.CompanyBusinessDetailsWrapper getCompanyBusinessDetails(Applicant__c applicant){
        AUSF_INT_BRE_UNDERWRITING_Request.CompanyBusinessDetailsWrapper compBusinessDetails = new AUSF_INT_BRE_UNDERWRITING_Request.CompanyBusinessDetailsWrapper();
        compBusinessDetails.businessName = 'Industry';//changed later
        if(applicant.Employment_Type__c  != NULL && !applicant.Employment_Type__c.containsIgnoreCase('Salaried')){
            //compBusinessDetails.dateOfIncorporation = AUSF_INT_BRE_Utility.formatDateTime(DateTime.now(),1)//need to change object.field value 
        }
        compBusinessDetails.industry = 'changed later'; 
        compBusinessDetails.noOfDirectors = 0;
        compBusinessDetails.noOfPartners = 0;
        compBusinessDetails.noOfYearsInBusiness = String.isNotBlank(applicant.Business_Vintage_Years__c)?Double.valueOf(applicant.Business_Vintage_Years__c):0;
		compBusinessDetails.occupation = applicant.Employment_Type__c ;//check
		compBusinessDetails.sector = 'changed later' ;//Employment_Object
		compBusinessDetails.subIndustry = 'changed later';
        return compBusinessDetails;
    }*/

    /*
    @description    : getIncomeData - set and return wrapper 
    @return         : AUSF_INT_BRE_UNDERWRITING_Request.IncomeDataWrapper warpper
    */
    private static AUSF_INT_BRE_UNDERWRITING_Request.IncomeDataWrapper getIncomeData(){
        AUSF_INT_BRE_UNDERWRITING_Request.IncomeDataWrapper incomeDataWrapper = new AUSF_INT_BRE_UNDERWRITING_Request.IncomeDataWrapper();
        incomeDataWrapper.declaredAnnualTurnover = 0;//hard coded
        return incomeDataWrapper;
    }
    /*
    @description    : getAddress - set and return wrapper 
    @param1         : addressList - List Address__c object
    @param2         : locationMaster - Loacation Master Object
    @return         : AUSF_INT_BRE_UNDERWRITING_Request.AddressWrapper warpper list
    */
    private static List<AUSF_INT_BRE_UNDERWRITING_Request.AddressWrapper> getAddress(List<Address__c> addressList, Location_Master__c locationMaster){
        List<AUSF_INT_BRE_UNDERWRITING_Request.AddressWrapper> addressWrapperList = new List<AUSF_INT_BRE_UNDERWRITING_Request.AddressWrapper>();
        for(Address__c address : addressList ){
            AUSF_INT_BRE_UNDERWRITING_Request.AddressWrapper addressWrapper = new AUSF_INT_BRE_UNDERWRITING_Request.AddressWrapper();
            if(String.isNotBlank(address.Address_Type__c)){
                addressWrapper.addressType = address.Address_Type__c?.toUpperCase();
            }
            addressWrapper.pinCode = address.Pincode__c;
            addressWrapper.district = '';
            addressWrapper.city = address.City__c;
            addressWrapper.state = address.State__c;
            addressWrapper.country = 'India';
            addressWrapper.timeAtCurrentCity = 0;//check
            addressWrapper.timeAtCurrentAddress = 0;//check
            addressWrapper.ownershipStatus = String.isNotBlank(address.Residence_Ownership_Type__c) ? address.Residence_Ownership_Type__c.toUpperCase() : 'OWNED';
            //addressWrapper.propertyType = '';
            addressWrapper.distanceFromBranch = Double.valueOf(0);
            if(locationMaster != NULL){
            addressWrapper.taluka = locationMaster.Taluka__c;
            addressWrapper.locationType = String.isBlank(locationMaster.Area_Type__c)? NULL : locationMaster.Area_Type__c.toUpperCase();//handle NULL value
            addressWrapper.locationSubType = String.isBlank(locationMaster.CityType__c) ? NULL :locationMaster.CityType__c.toUpperCase();//handle NULL value
            }
            addressWrapper.isNegativeArea = locationMaster?.Working_Area__c == 'Yes' ? true : false;
            addressWrapper.pinCodeCategory = locationMaster?.Working_Area__c == 'Yes' ? 'WORKING' : 'NON_WORKING';
            addressWrapper.isResiCumOffice = false;
            addressWrapper.address = (String.isNotBlank(address.Address_Line_1__c)?address.Address_Line_1__c : '') +' '+ (String.isNotBlank(address.Address_Line_2__c)?address.Address_Line_2__c:'')	+' '+ (String.isNotBlank(address.Address_Line_3__c)?address.Address_Line_3__c:'');
            addressWrapperList.add(addressWrapper);
        }
        return addressWrapperList;
    }
    /*
    @description    : getEducationDetails - set and return wrapper 
    @param1         : applicant - Applicant__c object
    @return         : AUSF_INT_BRE_UNDERWRITING_Request.EducationDetailsWrapper warpper
    */
    private static AUSF_INT_BRE_UNDERWRITING_Request.EducationDetailsWrapper getEducationDetails(Applicant__c applicant){
        AUSF_INT_BRE_UNDERWRITING_Request.EducationDetailsWrapper eduDetails = new AUSF_INT_BRE_UNDERWRITING_Request.EducationDetailsWrapper();
        if(String.isNotBlank(applicant.Educational_Qualification__c)){
            eduDetails.educationStatus = applicant?.Educational_Qualification__c?.toUpperCase();
        }
        eduDetails.professionalQualification = applicant?.Educational_Qualification__c;
		//eduDetails.isProfessionalDegreeVerified = false;
        return eduDetails;
    }
    /*
    @description    : getProduct - set and return wrapper 
    @param1         : loanApp - Loan Application object
    @return         : AUSF_INT_BRE_UNDERWRITING_Request.ProductWrapper warpper list
    */
    private static List<AUSF_INT_BRE_UNDERWRITING_Request.ProductWrapper> getProduct(Loan_Application__c loanApp){
        List<AUSF_INT_BRE_UNDERWRITING_Request.ProductWrapper> productWrapperList = new List<AUSF_INT_BRE_UNDERWRITING_Request.ProductWrapper>();
        AUSF_INT_BRE_UNDERWRITING_Request.ProductWrapper productWrapper = new AUSF_INT_BRE_UNDERWRITING_Request.ProductWrapper();
		productWrapper.productType = loanApp.RecordType.DeveloperName == AUSF_INT_BRE_Constants.LOAN_RECORD_TYPE_PERSONAL_LOAN ? AUSF_INT_BRE_Constants.BRE_REQUEST_PRODUCT_TYPE_PL : AUSF_INT_BRE_Constants.BRE_REQUEST_PRODUCT_TYPE_CC;
        productWrapper.productCode = AUSF_INT_BRE_Constants.BRE_REQUEST_PRODUCT_CODE;
        productWrapper.subProductType = AUSF_INT_BRE_Constants.BRE_REQUEST_PRODUCT_TYPE_PL;
		productWrapper.requestedLoanAmount = loanApp.Loan_Amount__c;
        productWrapperList.add(productWrapper);
        return productWrapperList;
	}
}