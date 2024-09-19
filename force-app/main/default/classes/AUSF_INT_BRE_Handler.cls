/**
 * @author          : Amit Mishra
 * @date            : 03-July-2024
 * @description     : BRE Knockout integration handler for genrating request
 * Test Class       : AUSF_INT_BRE_Test
 * History          :
 * =========================================================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * =========================================================================================================
 * 03-July-2024 	Amit Mishra 		Initial Version 
**/
public without sharing class AUSF_INT_BRE_Handler implements AUSF_INT_IntegrationHandlerInterface{

    public List<Object> generateRequest(List<Object> inputWrappers){
        List<String> requestStringList = new List<String>();
        if (inputWrappers.isEmpty()) {
            return requestStringList;
        }
        AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
        String referenceId = String.valueOf(inputWrapper.dynamicInputs.get(AUSF_INT_BRE_Constants.BRE_REFERENCE_ID));
        AUSF_INT_BRE_RequestWrapper requestWrapper = new AUSF_INT_BRE_RequestWrapper();
        requestWrapper.value = getValue(inputWrapper, referenceId);
        requestWrapper.name = AUSF_INT_BRE_Constants.BRE_REQUEST_WRAPPER_NAME;
        requestWrapper.RequestId = referenceId;
        requestWrapper.OriginatingChannel = inputWrapper.integrationMasterRecord.Channel__c;
        requestStringList.add(JSON.serialize(requestWrapper));
        return requestStringList;
    }

    public List<String> validateInputData(List<Object> inputWrappers){
        List<String> validationErrorsList = new List <String>();
        //JourneyType
        //Applicant.Birth_Date__c 
        //Marital_Status__c
        return validationErrorsList;
    }

    public List<sObject> generatePlatformEvents(List<Object> recordList){
        return NULL;
    }

    public void callbackService(List<Integration_Checklist__c> checklistRecords, List<ContentVersion> responseFiles){/*To Do*/}
    public void beforeUpdateService(Integration_Checklist__c checklistRecord, ContentVersion responseFile){/*To Do*/} 
    
    
    // =========================================================================================================
    //      helper methods to get and set wrapppers
    // =========================================================================================================
    /*
    @description    : getValue - return value warapper
    @param1         : AUSF_INT_IntegrationUtility.InputWrapper
    @return         : AUSF_INT_BRE_RequestWrapper.Value - value warpper
    */
    private static AUSF_INT_BRE_RequestWrapper.Value getValue(AUSF_INT_IntegrationUtility.InputWrapper inputWrapper,String referenceId){
        List<Applicant__c> applicant = new List<Applicant__c> {inputWrapper.applicantRecord};
        String cityType = String.valueOf(inputWrapper.dynamicInputs.get(AUSF_INT_BRE_Constants.BRE_CITY_TYPE));
        AUSF_INT_BRE_RequestWrapper.Value value = new AUSF_INT_BRE_RequestWrapper.Value();
        value.callType = String.valueOf(inputWrapper.dynamicInputs.get(AUSF_INT_BRE_Constants.BRE_CALLTYPE));
        value.application = getAapplication(inputWrapper.loanRecord, applicant, cityType, referenceId);
        value.decisionService = AUSF_INT_BRE_Constants.BRE_REQUEST_DECISION_SERVICE_DS_PL;
		value.requestTime = AUSF_INT_BRE_Utility.formatDateTime(DateTime.now(),1);
		value.callingSystem = AUSF_INT_BRE_Constants.BRE_REQUEST_CALLING_SYSTEM_NAME;
        return value;
    }
    /*
    @description    : getAapplication - set and return wrapper 
    @param1         : loanApp - Loan Application object
    @param2         : applicant - Applicant object
    @param3         : cityType - Metro/Non metro from Location Master
    @param4         : referenceId - Unique Request Id
    @return         : AUSF_INT_BRE_RequestWrapper.Application warpper
    */
    private static AUSF_INT_BRE_RequestWrapper.Application getAapplication(Loan_Application__c loanApp, List<Applicant__c> applicant, String cityType, String referenceId){
        String journeyType = AUSF_INT_BRE_Utility.checkjourney(loanApp,applicant[0]);// for STP response'ETB_PA'
        AUSF_INT_BRE_RequestWrapper.Application applicationWrapper = new AUSF_INT_BRE_RequestWrapper.Application();
        applicationWrapper.applicationInfo = getApplicationInfo(loanApp, applicant[0], referenceId, journeyType);
        applicationWrapper.applicants = getApplicants(loanApp, applicant, cityType, journeyType) ;
        applicationWrapper.product = getProduct(loanApp);
        applicationWrapper.randomNumber = Integer.valueof((Math.random() * 100));
        return applicationWrapper;
    }
    /*
    @description    : getApplicationInfo - set and return wrapper 
    @param1         : loanApp - Loan Application object
    @param2         : applicant - Applicant object
    @param3         : referenceId - Unique Request Id
    @param4         : journeyType - String of CustomerData 
    @return         : AUSF_INT_BRE_RequestWrapper.ApplicationInfo warpper
    */
    private static AUSF_INT_BRE_RequestWrapper.ApplicationInfo getApplicationInfo(Loan_Application__c loanApp, Applicant__c applicant, String referenceId, String journeyType){
        AUSF_INT_BRE_RequestWrapper.ApplicationInfo appInfo = new AUSF_INT_BRE_RequestWrapper.ApplicationInfo();
        appInfo.applicationNumber = loanApp.Name;
		appInfo.leadId = loanApp.Id ;
        appInfo.transactionId = referenceId;
        appInfo.branchCode = loanApp.Branch__r.Account_Code__c;
        appInfo.branchName = loanApp.Branch__r.Name;
		appInfo.branchHub = 'Akola';//loanApp.Branch__r.Hub_Code__c;//Change later
        appInfo.branchRegion = 'Akola';//loanApp.Branch__r.Region_Code__c;//Change later
        appInfo.applicationDate = AUSF_INT_BRE_Utility.formatDateTime(loanApp.CreatedDate,1);// String.valueOf(loanApp.CreatedDate.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'', 'UTC'));
		appInfo.applicationStage = loanApp.Stage__c;
        appInfo.applicationCounter = loanApp.BRE_Knockout_Application_Counter__c != NULL ? loanApp.BRE_Knockout_Application_Counter__c.intValue()+1 :1;
        if(journeyType != NULL){
		    appInfo.journeyType = journeyType;
        } 
        // Commented for testing purpose - MM - Need to remove static mapping
		//appInfo.channel= loanApp.Sourcing_Channel__c;
        appInfo.channel= loanApp.Sourcing_Channel__c == 'DST' ? 'DSA' : loanApp.Sourcing_Channel__c;
		appInfo.source = AUSF_INT_BRE_Constants.BRE_REQUEST_APPLICATION_INFO_SOURCE_MOBILE;
        appInfo.processingDate = String.valueOf(Date.today());//check
        return appInfo;
    }
    /*
    @description    : getApplicants - set and return wrapper 
    @param1         : loanApp - Loan Application object
    @param2         : applicantList - List Applicant__c object
    @param3         : cityType - from Location Master
    @param4         : journeyType - String of CustomerData 
    @return         : AUSF_INT_BRE_RequestWrapper.Applicants warpper list
    */
    private static List<AUSF_INT_BRE_RequestWrapper.Applicants> getApplicants(Loan_Application__c loanApp, List<Applicant__c> applicantList, String cityType, String journeyType){
        List<AUSF_INT_BRE_RequestWrapper.Applicants> applicantWrapperList = new List<AUSF_INT_BRE_RequestWrapper.Applicants>();
        for(Applicant__c applicant : applicantList){
            AUSF_INT_BRE_RequestWrapper.Applicants applicantWrapper = new AUSF_INT_BRE_RequestWrapper.Applicants();
            applicantWrapper.customerName = applicant.Full_Name__c;
            if(String.isNotBlank(applicant.RecordType?.DeveloperName)){
                applicantWrapper.applicantType = applicant.RecordType.DeveloperName.toUpperCase();//check
            }
            applicantWrapper.applicantId = applicant.Id;
            applicantWrapper.bureauPull = false;
            applicantWrapper.isFinancialApplicant = true;
            applicantWrapper.customerType = 'I';
            applicantWrapper.customerSegment = 'SALARIED';
            applicantWrapper.customerLocationProfile = cityType?.toUpperCase();//ENUM - METRO,NON_METRO,OTHERS
            applicantWrapper.constitution = 'INDIVIUDAL';//kyc
            applicantWrapper.existingCustomer = applicant.NTB_ETB__c == 'ETB' ? true : false;
            applicantWrapper.relationWithApplicant = 'SELF';
            applicantWrapper.birthPlace = 'INDIA';
            applicantWrapper.dateOfBirth = AUSF_INT_BRE_Utility.formatDateTime(applicant.Birth_Date__c,1);
            applicantWrapper.age = applicant.Age__c;
            applicantWrapper.gender = applicant.Gender__c;
            applicantWrapper.nationality = String.isNotBlank(applicant.Nationality__c) ? applicant.Nationality__c :'INDIA';
            if(String.isNotBlank( applicant.Marital_Status__c)){
                applicantWrapper.maritalStatus = applicant.Marital_Status__c?.toUpperCase();
            }
            applicantWrapper.noOfDependents = 0;
            applicantWrapper.residentType = 'RESIDENT';//ENUM
            applicantWrapper.customerRiskProfile = 'NORMAL';
            applicantWrapper.isAUEmployee = applicant.Employee__c == 'Yes'? true : false;
            applicantWrapper.idDetails = getIdDetails(applicant);
            applicantWrapper.telephoneDetails = getTelephoneDetails(loanApp);
            applicantWrapper.isETBAddressNotChanged = true;
            if(applicant.CFR_Check__c != NULL){
                applicantWrapper.cfrStatus = applicant.CFR_Check__c == 'True'? 'FULL_MATCH' : 'NO_MATCH';
            }else{
                applicantWrapper.cfrStatus = 'NO_MATCH';
            }
            if(applicant.AML_verified__c != NULL){
                applicantWrapper.amlStatus = applicant.AML_verified__c == 'Yes'? 'FULL_MATCH' : 'NO_MATCH';
            }else{
                applicantWrapper.amlStatus = 'NO_MATCH';
            }
            applicantWrapper.relatedPartyStatus = 'NO_MATCH';
            applicantWrapper.negativePartyStatus = 'NO_MATCH';
            applicantWrapper.totalRelationshipValue = 0;
            applicantWrapper.isLeadToLeadFullMatch = true;
            applicantWrapper.isLeadToLeadPartialMatch = false;
            applicantWrapper.isLeadToCustomerPartialMatch = false;

            applicantWrapper.companyBusinessDetails = getCompanyBusinessDetails(applicant);
            applicantWrapper.incomeData = getIncomeData(loanApp, applicant, journeyType);
            applicantWrapper.address = getAddress(applicant.Addresses__r);
            applicantWrapper.educationDetails = getEducationDetails(applicant);
            applicantWrapperList.add(applicantWrapper);
        }
        return applicantWrapperList;
    }
    /*
    @description    : getIdDetails - set and return wrapper 
    @param1         : applicant - Applicant__c object
    @return         : AUSF_INT_BRE_RequestWrapper.IdDetails warpper list
    */
    private static List<AUSF_INT_BRE_RequestWrapper.IdDetails> getIdDetails(Applicant__c applicant){
        List<AUSF_INT_BRE_RequestWrapper.IdDetails> idDetailsWrapperList = new List<AUSF_INT_BRE_RequestWrapper.IdDetails>();
        AUSF_INT_BRE_RequestWrapper.IdDetails idDetailsWrapper = new AUSF_INT_BRE_RequestWrapper.IdDetails();
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
    @return         : AUSF_INT_BRE_RequestWrapper.TelephoneDetails warpper list
    */
    private static List<AUSF_INT_BRE_RequestWrapper.TelephoneDetails> getTelephoneDetails(Loan_Application__c loanApp){
        List<AUSF_INT_BRE_RequestWrapper.TelephoneDetails> telephoneDetailsWrapperList = new List<AUSF_INT_BRE_RequestWrapper.TelephoneDetails>();
        AUSF_INT_BRE_RequestWrapper.TelephoneDetails telephoneDetailsWrapper = new AUSF_INT_BRE_RequestWrapper.TelephoneDetails();
        telephoneDetailsWrapper.telephoneExtention = '';
        telephoneDetailsWrapper.telephoneType = 'Mobile';
        telephoneDetailsWrapper.telephoneNumber = loanApp.Mobile_Number__c;
        telephoneDetailsWrapperList.add(telephoneDetailsWrapper);
        return telephoneDetailsWrapperList;
    }
    /*
    @description    : getCompanyBusinessDetails - set and return wrapper 
    @param1         : applicant - Applicant__c object
    @return         : AUSF_INT_BRE_RequestWrapper.CompanyBusinessDetails warpper
    */
    public static AUSF_INT_BRE_RequestWrapper.CompanyBusinessDetails getCompanyBusinessDetails(Applicant__c applicant){
        AUSF_INT_BRE_RequestWrapper.CompanyBusinessDetails compBusinessDetails = new AUSF_INT_BRE_RequestWrapper.CompanyBusinessDetails();
        compBusinessDetails.businessName = 'Industry';//changed later
        if(applicant.Employment_Type__c  != NULL && !applicant.Employment_Type__c.containsIgnoreCase('Salaried')){
            //compBusinessDetails.dateOfIncorporation = AUSF_INT_BRE_Utility.formatDateTime(DateTime.now(),1)//need to change object.field value 
        }
        //compBusinessDetails.industry = 'changed later'; 
        compBusinessDetails.noOfDirectors = 0;
        compBusinessDetails.noOfPartners = 0;
        compBusinessDetails.noOfYearsInBusiness = String.isNotBlank(applicant.Business_Vintage_Years__c)?Double.valueOf(applicant.Business_Vintage_Years__c):0;
		compBusinessDetails.occupation = applicant.Employment_Type__c ;//check
		//compBusinessDetails.sector = 'changed later' ;//Employment_Object
		//compBusinessDetails.subIndustry = 'changed later';
        return compBusinessDetails;
    }
    /*
    @description    : getIncomeData - set and return wrapper
    @param1         : loanApp - Loan Application object
    @param2         : applicant - Applicant__c object
    @param3         : journeyType - String of CustomerData 
    @return         : AUSF_INT_BRE_RequestWrapper.IncomeData warpper
    */
    private static AUSF_INT_BRE_RequestWrapper.IncomeData getIncomeData(Loan_Application__c loanApp, Applicant__c applicant, String journeyType){
        AUSF_INT_BRE_RequestWrapper.IncomeData incomeDataWrapper = new AUSF_INT_BRE_RequestWrapper.IncomeData();
        incomeDataWrapper.declaredAnnualTurnover = 0;
        incomeDataWrapper.declaredNetMonthlyIncome = 0;
        if(applicant.Employment_Type__c  != NULL){
            if(applicant.Employment_Type__c == 'Self Employed Professional'){
                incomeDataWrapper.declaredAnnualTurnover = 2000000;
            }
            if(applicant.Employment_Type__c.containsIgnoreCase('Salaried') && journeyType == 'ETB_PA'){
                incomeDataWrapper.declaredNetMonthlyIncome = 35000;
            }
        }
        return incomeDataWrapper;
    }
    /*
    @description    : getAddress - set and return wrapper 
    @param1         : addressList - List Address__c object
    @return         : AUSF_INT_BRE_RequestWrapper.Address warpper list
    */
    private static List<AUSF_INT_BRE_RequestWrapper.Address> getAddress(List<Address__c> addressList){
        List<AUSF_INT_BRE_RequestWrapper.Address> addressWrapperList = new List<AUSF_INT_BRE_RequestWrapper.Address>();
        for(Address__c address : addressList ){
            AUSF_INT_BRE_RequestWrapper.Address addressWrapper = new AUSF_INT_BRE_RequestWrapper.Address();
            if(String.isNotBlank(address.Address_Type__c)){
                addressWrapper.addressType = address.Address_Type__c.toUpperCase();
            }
            addressWrapper.pinCode = address.Pincode__c;
            addressWrapper.district = '';
            addressWrapper.city = address.City__c;
            addressWrapper.state = address.State__c;
            addressWrapper.taluka = 'changed later';//check
            addressWrapper.country = 'India';
            addressWrapper.timeAtCurrentCity = 0;//DateTime.now().time();//check
            addressWrapper.timeAtCurrentAddress = 0;// DateTime.now().time();//check
            if(String.isNotBlank(address.Residence_Ownership_Type__c)){
                addressWrapper.ownershipStatus = address.Residence_Ownership_Type__c.toUpperCase();
            }else{
                addressWrapper.ownershipStatus = 'OWNED';
            }
            //addressWrapper.propertyType = '';
            addressWrapper.distanceFromBranch = Double.valueOf(0);//check
            addressWrapper.locationType ='';
            addressWrapper.locationSubType = '';
            addressWrapper.isNegativeArea = address.Working_Area__c == 'Yes' ? true : false;
            addressWrapper.isResiCumOffice = false;
            addressWrapper.pinCodeCategory = address.Working_Area__c =='Yes'? 'WORKING' : 'NON_WORKING';
            addressWrapper.address = (String.isNotBlank(address.Address_Line_1__c)?address.Address_Line_1__c : '') +' '+ (String.isNotBlank(address.Address_Line_2__c)?address.Address_Line_2__c:'')	+' '+ (String.isNotBlank(address.Address_Line_3__c)?address.Address_Line_3__c:'');
            addressWrapperList.add(addressWrapper);
        }
        return addressWrapperList;
    }
    /*
    @description    : getEducationDetails - set and return wrapper 
    @param1         : applicant - Applicant__c object
    @return         : AUSF_INT_BRE_RequestWrapper.EducationDetails warpper
    */
    private static AUSF_INT_BRE_RequestWrapper.EducationDetails getEducationDetails(Applicant__c applicant){
        AUSF_INT_BRE_RequestWrapper.EducationDetails eduDetails = new AUSF_INT_BRE_RequestWrapper.EducationDetails();
        if(String.isNotBlank(applicant.Educational_Qualification__c)){
            eduDetails.educationStatus = applicant.Educational_Qualification__c.toUpperCase();//enum
        }
        eduDetails.professionalQualification = applicant.Educational_Qualification__c;
		eduDetails.isProfessionalDegreeVerified = false;
        return eduDetails;
    }
    /*
    @description    : getProduct - set and return wrapper 
    @param1         : loanApp - Loan Application object
    @return         : AUSF_INT_BRE_RequestWrapper.Product warpper list
    */
    private static List<AUSF_INT_BRE_RequestWrapper.Product> getProduct(Loan_Application__c loanApp){
        List<AUSF_INT_BRE_RequestWrapper.Product> productWrapperList = new List<AUSF_INT_BRE_RequestWrapper.Product>();
        AUSF_INT_BRE_RequestWrapper.Product productWrapper = new AUSF_INT_BRE_RequestWrapper.Product();
		productWrapper.productType = loanApp.RecordType.DeveloperName == AUSF_INT_BRE_Constants.LOAN_RECORD_TYPE_PERSONAL_LOAN ? AUSF_INT_BRE_Constants.BRE_REQUEST_PRODUCT_TYPE_PL : AUSF_INT_BRE_Constants.BRE_REQUEST_PRODUCT_TYPE_CC;
        productWrapper.productCode = AUSF_INT_BRE_Constants.BRE_REQUEST_PRODUCT_CODE;
        productWrapper.subProductType = AUSF_INT_BRE_Constants.BRE_REQUEST_PRODUCT_TYPE_PL;
		productWrapper.requestedLoanAmount = loanApp.Loan_Amount__c;
        productWrapper.requestedROI = 0;//mapping Req
        productWrapper.requestedInstallmentAmount = 0;//mapping Req
        productWrapperList.add(productWrapper);
        return productWrapperList;
	}

    //====================================================================================================================
    //     helper methods
    //====================================================================================================================
    /*private static string checkjourney(Loan_Application__c loanApp, Applicant__c applicant){
        if(applicant.NTB_ETB__c == 'ETB'){
            if(loanApp.Pre_Approved_Offers__r != NULL && !loanApp.Pre_Approved_Offers__r.isEmpty()){
                return 'ETB_PA';
            }
            return 'ETB_NPA';
        }
        else if(applicant.NTB_ETB__c == 'NTB'){
            return applicant.NTB_ETB__c;
        }
        return NULL;
    }
    */
    /*public static String formatDateTime(DateTime datevalue, Integer formatName){
        String formattedDate;
        if(formatName == 1){
            formattedDate = datevalue.format('yyyy-MM-dd\'T\'HH:mm:ss.SSS\'Z\'', 'UTC');//2024-05-25T06:32:36.163Z //yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
        }
        else if(formatName == 2){
            formattedDate = datevalue.format('MMM dd, yyyy hh:mm:ss.SSS a z', 'IST');//Jul 11, 2024 12:50:07.961 PM IST
        }
        else{
            formattedDate = String.valueOf(datevalue);
        }
        return formattedDate;
    }*/
}