/**
* @author              : Amit Mishra
* @date                : 05-July-2024
* @description         : Test Class for BRE Integration 
* Classes covered      : AUSF_INT_BRE_Controller, AUSF_INT_BRE_Handler, AUSF_INT_BRE_ResponseWrapper, AUSF_INT_BRE_RequestWrapper
* History              :
* ===========================================================================================================
* <Date> 		<Authors Name> 		<Brief Description of Change>
* ===========================================================================================================
* 05-July-2024 	Amit Mishra 		Initial Version
**/
@isTest
public class AUSF_INT_BRE_Test {
    @TestSetup
    static void makeData(){
        //Create Integration Master
        Integration_Master__c integrationMaster = AUSF_TestDataFactory.createIntegrationMaster(AUSF_ApexConstants.FICO_BRE_KNOCKOUT_INTEGRATION_MASTER, 'https://servicesfdc.aubankuat.in/sfdckyc/FICOService_Wrapper/BRE_TEST', 'SFDC', 'POST', NULL , 'AUSF_INT_BRE_Handler');
        insert integrationMaster;
        //Create Loan Application
        List<Loan_Application__c> loanAppList = new List<Loan_Application__c>();
        loanAppList = AUSF_TestDataFactory.createActiveLoanApplications(loanAppList,1);
		loanAppList[0].Stage__c = 'Lead';
        insert loanAppList;
        Applicant__c applicant = new Applicant__c(Gender__c = 'Male', Loan_application__c = loanAppList[0].Id, Birth_Date__c = System.today().addYears(25), Marital_Status__c ='Single', Educational_Qualification__c='Graduate');
        insert Applicant;
        //create address
        List<Address__c> address = AUSF_TestDataFactory.createAddress(applicant, 1 , true);
        //create location master
		Location_Master__c locMaster = new Location_Master__c (CityType__c = 'Metro' ,Name = address[0].Pincode__c);
		insert locMaster;
    }
    
    @isTest
    static void getBreResponseTest(){
        Test.startTest();
        Integer statusCode = 200;
        String responseBody = AUSF_INT_BRE_MockResponse.getResponse(NULL,NULL);
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(responseBody,statusCode));
        Loan_Application__c loanApp =  [SELECT Id FROM Loan_Application__c LIMIT 1];
        String callType = 'DP_KNOCKOUT';
        AUSF_INT_BRE_ResponseWrapper res = AUSF_INT_BRE_Controller.getBreResponse(loanApp.Id, callType);
        Test.stopTest();
    }
	@isTest
    static void getBreResponseErrorWrapperTest(){
        Test.startTest();
        Integer statusCode = 200;
        String responseBody = AUSF_INT_BRE_MockResponse.getResponse(1,NULL);
		try{
			Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(responseBody,statusCode));
			Loan_Application__c loanApp =  [SELECT Id FROM Loan_Application__c LIMIT 1];
			String callType = 'DP_KNOCKOUT';
			AUSF_INT_BRE_ResponseWrapper res = AUSF_INT_BRE_Controller.getBreResponse(loanApp.Id, callType);	
		}catch(Exception ex){
			System.debug('ex:'+ex);
		}
        Test.stopTest();
    }
	@isTest
    static void getBreResponse_DeclineDecision_Test(){
        Test.startTest();
        Integer statusCode = 200;
        String responseBody = AUSF_INT_BRE_MockResponse.getResponse(1,NULL);
		try{
			Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(responseBody,statusCode));
			Loan_Application__c loanApp =  [SELECT Id FROM Loan_Application__c LIMIT 1];
			String callType = 'DP_KNOCKOUT';
			AUSF_INT_BRE_ResponseWrapper res = AUSF_INT_BRE_Controller.getBreResponse(loanApp.Id, callType);	
		}catch(Exception ex){
			System.debug('ex:'+ex);
		}
        Test.stopTest();
    }
    @isTest
    static void getBreResponsNegativeTest(){
        Test.startTest();
        Loan_Application__c loanApp =  [SELECT Id FROM Loan_Application__c LIMIT 1];
        String callType = 'DP_KNOCKOUT';
        AUSF_INT_BRE_ResponseWrapper res = AUSF_INT_BRE_Controller.getBreResponse(loanApp.Id, NULL);
        AUSF_INT_BRE_ResponseWrapper res2 = AUSF_INT_BRE_Controller.getBreResponse(NULL, NULL);
        AUSF_INT_BRE_ResponseWrapper res3 = AUSF_INT_BRE_Controller.getBreResponse('a01C100000GlJkLIAV', callType);
        Test.stopTest();
    }
    @isTest
    static void getBreResponsNegativeApplicantTest(){
        List<Applicant__c> applicants = [SELECT Id, Gender__c, Loan_application__c FROM Applicant__c];
        //delete applicants;
        Test.startTest();
        Loan_Application__c loanApp =  [SELECT Id FROM Loan_Application__c LIMIT 1];
        String callType = 'DP_KNOCKOUT';
        AUSF_INT_BRE_ResponseWrapper res2 = AUSF_INT_BRE_Controller.getBreResponse(loanApp.Id, callType);
        Test.stopTest();
        for(Applicant__c applicant : applicants){
            applicant.Id = NULL;
        }
        //insert applicants;
    }
    @isTest
    static void getBreResponsNegativeMasterTest(){
        Integration_Master__c intMaster = [SELECT Id, Name, Channel__c, End_Point_URL__c, HTTP_Method__c,Timeout__c, content_type__c, Apex_Class_Name__c, Active__c FROM Integration_Master__c LIMIT 1]; 
        delete intMaster;
        Test.startTest();
        Loan_Application__c loanApp =  [SELECT Id FROM Loan_Application__c LIMIT 1];
        String callType = 'DP_KNOCKOUT';
        AUSF_INT_BRE_ResponseWrapper res = AUSF_INT_BRE_Controller.getBreResponse(loanApp.Id, callType);
        intMaster.Id = NULL;
        insert intMaster;
        Test.stopTest();
    }
    @isTest
    static void breHandlerTest(){
        Test.startTest();
        AUSF_INT_BRE_Handler obj = new AUSF_INT_BRE_Handler();
        List<Object> request = obj.generateRequest(new List<Object>());
        List<SObject> res = obj.generatePlatformEvents(NULL);
        obj.callbackService(NULL,NULL);
        obj.beforeUpdateService(NULL,NULL);
        Test.stopTest();
    }
    @isTest
    static void handlePlatformEvent(){
        Test.startTest();
        Integer statusCode = 200;
        String responseBody = AUSF_INT_BRE_MockResponse.getResponse(NULL,NULL);
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse(responseBody,statusCode));
        Loan_Application__c loanApp =  [SELECT Id FROM Loan_Application__c LIMIT 1];
        String callType = 'DP_KNOCKOUT';
        AUSF_INT_BRE_Controller.handlePlatformEvent(callType, 'Test', loanApp.Id );
        Test.stopTest();
    }
    /*
    public static String getSuccessResponse(Integer message,String systemDecision){
		List<Applicant__c> applicantList = [SELECT Id, Name, Gender__c, Loan_application__c FROM Applicant__c LIMIT 1];
		//System.debug('Test Class message:'+message);
		if(systemDecision == NULL){
			systemDecision = 'STP';
		}
		String errorMessage = '"error":null' ;
		String bureauResponse = '"bureauResponse":null,';
		Boolean addBureauResponse = true;
		String applicantWrap = '"applicantId":"APP001",';
		applicantWrap = '"applicantId":"'+applicantList[0].Id + '",';
		if(message == 1){
			errorMessage = '"error": [ { "stackTrace": "Error in Validate Request And Variable Assignment Script while Validating Input Message and stack trace is Missing required creator property \'journeyType\'", "source": "PL - FICO CDE PLOR", "dateTime": "23-07-2024 10:52:22", "errorCode": "PLOR_4001", "description": "FUNCTIONAL ERROR" } ]';
        }
        String response = '{"transactionId":"203ccd49-b92b-4797-9765-5af4b638959c","content":{"outputVariables":{"MasterMessageOut":{"requestTime":"2024-05-25T06:32:36.163Z","responseTime":"2024-07-20T11:37:46.193Z","elapsedTime":561742541,"decisionService":"DS_PL","callType":"DP_KNOCKOUT","callingSystem":"LOS","application":{"applicationInfo":{"applicationNumber":"LEAD-0000000258",';
		response += '"leadId":"'+applicantList[0].Loan_application__c+'",';
		response += '"transactionId":"T0001",';
		response += '"branchCode":"2365","branchName":"Akola_Necklace Road","branchHub":"Akola","branchRegion":"Akola","applicationDate":"2024-05-25T06:32:36.163+0000","applicationStage":"QDE","applicationCounter":0,"journeyType":"NTB","etbPAType":null,"channel":"DIY","source":"MOBILE","roName":null,"roCode":null,"rmName":null,"rmCode":null,"processingDate":"2024-06-04T00:00:00.000+0000"},"applicants":[{"customerName":"Gaurav Sharma","applicantType":"PRIMARY",';
		response += applicantWrap;
		response += '"bureauPull":false,"isFinancialApplicant":true,"customerType":"I","customerSegment":"SELF_EMPLOYED_NON_PROFESSIONAL","customerGrade":null,"customerLocationProfile":"METRO","constitution":"INDIVIUDAL","existingCustomer":false,"etbType":null,"birthPlace":"RAJASTHAN","age":360,"dateOfBirth":"1989-05-24T06:32:36.163+0000","gender":"Male","nationality":"Indian","maritalStatus":"SINGLE","noOfDependents":2,"relationWithApplicant":"SELF","residentType":"RESIDENT","customerRiskProfile":"NORMAL","auEmployeeDetails":null,"isAUEmployee":false,"isETBAddressNotChanged":false,"cfrStatus":"NO_MATCH","amlStatus":"NO_MATCH","relatedPartyStatus":"NO_MATCH","negativePartyStatus":"NO_MATCH","totalRelationshipValue":0,"isLeadToLeadFullMatch":false,"isLeadToLeadPartialMatch":false,"isLeadToCustomerPartialMatch":false,"ekycType":null,"companyBusinessDetails":{"businessName":"Industry","sector":"text","industry":"text","subIndustry":"text","occupation":"text","dateOfIncorporation":"2020-01-01T10:10:10.100+0000","noOfYearsInBusiness":10.5,"noOfPartners":1,"noOfDirectors":1},"employmentDetails":null,"idDetails":[{"idType":"PAN","idNumber":"BBPPS2564B","isVerified":true,"issueDate":"2024-05-24T06:32:36.163+0000","expiryDate":"2024-05-24T06:32:36.163+0000"},{"idType":"AADHAAR","idNumber":"639565421230","isVerified":true,"issueDate":"2024-05-24T06:32:36.163+0000","expiryDate":"2024-05-24T06:32:36.163+0000"}],"emailDetails":null,"address":[{"addressType":"CURRENT","pinCode":"560043","district":"RAJSHTHAN","city":"Jaipur","state":"Jaipur","taluka":"Jaipur","country":"India","timeAtCurrentCity":0,"timeAtCurrentAddress":0,"ownershipStatus":"OWNED","propertyType":"INDEPENDENT_HOUSE","distanceFromBranch":0,"locationType":"URBAN","locationSubType":"METRO","isNegativeArea":false,"isResiCumOffice":false,"pinCodeCategory":"WORKING","address":"SR NO 1 2,PLOT NO 14"},{"addressType":"OFFICE","pinCode":"560043","district":"RAJSHTHAN","city":"Jaipur","state":"Jaipur","taluka":"Jaipur","country":"India","timeAtCurrentCity":0,"timeAtCurrentAddress":0,"ownershipStatus":"OWNED","propertyType":"RESIDENTIAL_OFFICE","distanceFromBranch":0,"locationType":"URBAN","locationSubType":"METRO","isNegativeArea":false,"isResiCumOffice":false,"pinCodeCategory":"WORKING","address":"SROT NO 14"}],"telephoneDetails":[{"telephoneExtention":"044","telephoneNumber":"9887115555","telephoneType":"01"}],"incomeData":{"payslipDetails":null,"declaredAnnualTurnover":2000000,"declaredNetMonthlyIncome":0,"verfiedNetMonthlyIncome":0,"verfiedAnnualTurnover":0,"declaredMonthlyObligation":0},"bankAccountDetails":null,"existingLoanAccountDetails":null,"existingCardAccountDetails":null,"existingCCODDetails":null,"existingCASADetails":null,"gstDetails":null,"educationDetails":{"educationStatus":"UNEDUCATED","professionalQualification":"string","isProfessionalDegreeVerified":true},"karzaData":null,"posidexData":null,"verificationReportData":null,"interfaceResponses":null,';
		//add bureauResponse & cibilResponse
		if(addBureauResponse){
			bureauResponse = '"bureauResponse":{"cibilResponse":[{"accountSegment":[{"SegmentTag":"string","ReportingNumberShortName":"string","AccountNumber":"string","AccountType":"03","OwnershipIndicator":"01","DateOpenedDisbursed":"20022024","DateofLastPayment":"02022023","DateClosed":"02022023","DateReportedAndCertified":"string","HighCreditSanctionedAmount":0,"CurrentBalance":0,"AmountOverdue":0,"PaymentHistory1":"string","PaymentHistory2":"string","PaymentHistoryStartDate":"string","PaymentHistoryEndDate":"string","SuitFiledWilfulDefault":"03","CreditFacilityStatus":"string","ValueOfCollateral":0,"TypeOfCollateral":"string","CreditLimit": 0,"CashLimit": 0,"RateOfInterest":0,"RepaymentTenure": 0, "EMIAmount": 0, "WrittenOffAmountTotal": 0, "WrittenOffAmountPrincipal": 0, "SettlementAmount": 0, "PaymentFrequency": 0, "ActualPaymentAmount": 0, "DateOfEntryForErrorCode": "string", "ErrorCode": "string", "DateOfEntryForCIBILRemarksCode": "string", "CIBILRemarksCode": "string", "DateOfEntryForErrorDisputeRemarksCode": "string", "ErrorDisputeRemarksCode1": "string", "ErrorDisputeRemarksCode2": "string" }, { "SegmentTag": "string", "ReportingNumberShortName": "string", "AccountNumber": "string", "AccountType": "string", "OwnershipIndicator": "string", "DateOpenedDisbursed": "string", "DateofLastPayment": "string", "DateClosed": "string", "DateReportedAndCertified": "string", "HighCreditSanctionedAmount": 0, "CurrentBalance": 0, "AmountOverdue": 0, "PaymentHistory1": "string", "PaymentHistory2": "string", "PaymentHistoryStartDate": "string", "PaymentHistoryEndDate": "string", "SuitFiledWilfulDefault": "01", "CreditFacilityStatus": "string", "ValueOfCollateral": 0, "TypeOfCollateral": "string", "CreditLimit": 0, "CashLimit": 0, "RateOfInterest": 0, "RepaymentTenure": 0, "EMIAmount": 0, "WrittenOffAmountTotal": 0, "WrittenOffAmountPrincipal": 0, "SettlementAmount": 0, "PaymentFrequency": 0, "ActualPaymentAmount": 0, "DateOfEntryForErrorCode": "string", "ErrorCode": "string", "DateOfEntryForCIBILRemarksCode": "string", "CIBILRemarksCode": "string", "DateOfEntryForErrorDisputeRemarksCode": "string", "ErrorDisputeRemarksCode1": "string", "ErrorDisputeRemarksCode2": "string" } ], "addressList": [ { "AddressSegmentTag": "PA", "Length": "03", "AddressLine1FieldLength": "03", "AddressLine1": "HNO", "AddressLine2FieldLength": "09", "AddressLine2": "MASAGUPPI", "AddressLine5FieldLength": "08", "AddressLine5": "BELAGAVI", "StateCode": "29", "PinCodeFieldLength": "06", "PinCode": "591312", "AddressCategory": "02", "DateReported": "27032024", "EnrichedThroughEnquiry": "Y" } ], "enquiry": [ { "Length": "04", "SegmentTag": "I001", "DateOfEnquiryFields": "20052024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I002", "DateOfEnquiryFields": "20052024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I003", "DateOfEnquiryFields": "10052024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I004", "DateOfEnquiryFields": "09052024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I005", "DateOfEnquiryFields": "06052024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I006", "DateOfEnquiryFields": "06052024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I007", "DateOfEnquiryFields": "30042024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I008", "DateOfEnquiryFields": "30042024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I009", "DateOfEnquiryFields": "30042024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I010", "DateOfEnquiryFields": "17042024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I011", "DateOfEnquiryFields": "02042024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I012", "DateOfEnquiryFields": "27032024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 } ], "header": { "SegmentTag": "TUEF", "Version": "12", "ReferencEnumber": "46209060", "MemberCode": "NB66521058_UATC2C7 ", "SubjectReturnCode": "1", "EnquiryControlNumber": "002160060020", "DateProcessed": "24052024", "TimeProcessed": "122847" }, "scoreSegment": [ { "Length": "10", "ScoreName": "CIBILTUSC3", "ScoreCardName": "16", "ScoreCardVersion": "10", "ScoreDate": "24052024", "Score": "00103", "ReasonCode1FieldLength": null, "ReasonCode1": null, "ReasonCode2FieldLength": null, "ReasonCode2": null, "ReasonCode3FieldLength": null, "ReasonCode3": null, "ReasonCode4FieldLength": null, "ReasonCode4": null, "ReasonCode5FieldLength": null, "ReasonCode5": null } ], "status": "SUCCESS", "isAddtionalMatch": false } ] },';
		}
		response += bureauResponse;
		response += '"applicantAddtionalAttributes":null,"applicantDecision":{"calculatedVariables":[{"fieldName":"CIBIL_SCORE","fieldType":"Integer","fieldValue":"860","varCategory":"CIBIL"},{"fieldName":"CIBIL_STATUS","fieldType":"String","fieldValue":"HIT","varCategory":"CIBIL"},{"fieldName":"CIBIL_SEGMENTATION","fieldType":"String","fieldValue":"THIN_CIBIL","varCategory":"CIBIL"},{"fieldName":"MAX_BUREAU_VINTAGE","fieldType":"Integer","fieldValue":"225","varCategory":"CIBIL"}],"uwCriterias":[],"bureauBasedIncomeEstimation":null,"bureauBasedCommitmentDTls":{"existingCommitment":1075,"existingAccountCommitment":[{"accountNumber":"string","dateClosed":"","dateOpen":"20102023","accountType":"01","reportingMemberShortName":"string","ownershipIndicator":"4","debtType":"","isUnsecured":false,"accountExcluded":true,"exclusionReason":"Account Excluded Due To Closed","tenure":0,"roi":0,"highCreditOrSanctionedAmount":2000000,"currentBalance":0,"paymentHistory1":"000000000000000000000","paymentHistory2":"000000","accountCommitment":0,"emiAmount":0,"imputedeEMIAmount":0,"obligationFromLOS":0},{"accountNumber":"string","dateClosed":"","dateOpen":"20102023","accountType":"10","reportingMemberShortName":"string","ownershipIndicator":"4","debtType":"Credit Card","isUnsecured":true,"accountExcluded":false,"exclusionReason":null,"tenure":0,"roi":5,"highCreditOrSanctionedAmount":1000000,"currentBalance":1000,"paymentHistory1":"000000000000000000000","paymentHistory2":"000025","accountCommitment":50,"emiAmount":0,"imputedeEMIAmount":50,"obligationFromLOS":0},{"accountNumber":"string","dateClosed":null,"dateOpen":"29032024","accountType":"35","reportingMemberShortName":"AUSFB","ownershipIndicator":"1","debtType":"Corporate Credit Card","isUnsecured":true,"accountExcluded":false,"exclusionReason":null,"tenure":0,"roi":5,"highCreditOrSanctionedAmount":500000,"currentBalance":1000,"paymentHistory1":"000000000000000000000","paymentHistory2":"030","accountCommitment":50,"emiAmount":0,"imputedeEMIAmount":50,"obligationFromLOS":0},{"accountNumber":"string","dateClosed":"","dateOpen":"01122023","accountType":"36","reportingMemberShortName":"AUSFB","ownershipIndicator":"1","debtType":"Kisan Credit Card","isUnsecured":true,"accountExcluded":false,"exclusionReason":null,"tenure":0,"roi":2,"highCreditOrSanctionedAmount":50000,"currentBalance":1500,"paymentHistory1":"000000000000000000000","paymentHistory2":"030","accountCommitment":1000,"emiAmount":0,"imputedeEMIAmount":1000,"obligationFromLOS":0},{"accountNumber":"string","dateClosed":"","dateOpen":"20102023","accountType":"10","reportingMemberShortName":"string","ownershipIndicator":"4","debtType":"","isUnsecured":false,"accountExcluded":true,"exclusionReason":"Account Excluded Due To Closed","tenure":0,"roi":0,"highCreditOrSanctionedAmount":2000000,"currentBalance":0,"paymentHistory1":"000000000000000000000","paymentHistory2":"000","accountCommitment":0,"emiAmount":0,"imputedeEMIAmount":0,"obligationFromLOS":0}]},"traditionalScoreModels":[{"modelID":"PL_SELF_EMPLOYED_SCORECARD","modelName":"Self_Employed_Scorecard","baseScore":0,"totalScore":542.2,"scoreBand":"5","scoreBasedDecision":"REFER",';
		response += applicantWrap;
		response += '"scoreModelCharacteristic":[{"characteristicName":"MAX_DPD_L36M","characteristicValue":"30","characteristicType":"Integer","characteristicReason":"Max DPD is GE 29 and less than 60","partialScore":50,"weight":0,"charScore":50},{"characteristicName":"MAX_COUNT_DPD_GT0_LIVE_ACCOUNTS_L12M","characteristicValue":"1","characteristicType":"Integer","characteristicReason":"One","partialScore":51,"weight":0,"charScore":51},{"characteristicName":"UTIL_LIVE_CC","characteristicValue":"0.044444444444444446","characteristicType":"Double","characteristicReason":"Less than 0.2","partialScore":69,"weight":0,"charScore":69}]}],"fiInitiationDetails":[]}}],"product":[{"productType":"PL","productCode":"0256","subProductType":"string","schemeId":null,"loanPurpose":null,"isTopUp":false,"linkedAccountNumberForTopUp":null,"natureOfLoan":null,"emiFrequency":null,"scheduleType":null,"requestedLoanAmount":600000,"requestedInstallmentAmount":10,"instalmentFreq":null,"requestedTenor":0,"requestedROI":60,"requestedPF":0,"rateType":null,"pslClassficatinType":null,"pslClassficatinSubType":null,"noOfTopUp":0,"totalExposure":0,"existingGroupExposure":0,"promoCode":null,"productDecision":{"productDecision":"STP","uwCriterias":[],"isAppliedPromoCode":false,"promoStartDate":null,"promoEndDate":null,"calculatedVariables":[],"ruleAudits":[],"offerData":{"maxEligibleLoanAmount":478000,"maxFOIR":0,"minTenure":12,"maxTenure":36,"roi":25,"roiGrid":[{"minLoanAmount":0,"maxLoanAmount":199999,"roi":25},{"minLoanAmount":200000,"maxLoanAmount":478000,"roi":25}],"stampDutyGrid":[{"minLoanAmount":0,"maxLoanAmount":478000,"stampDutyRate":0.25,"maxStampDutyCapping":1500000}],"pfRateGrid":[{"minLoanAmount":0,"maxLoanAmount":478000,"processingFeesRate":4}],"pfAmountGrid":[{"minLoanAmount":0,"maxLoanAmount":478000,"processingFeesAmount":0}],"loanAmountTenureGrid":[]},"schemeDecision":[]}}],"documentsReceived":null,"hunterResponse":null,"randomNumber":0,"applicationAddtionalAttributes":null,';
		response += '"applicationDecision":{"systemDecision":"' + systemDecision + '","systemDecisionDate":"2024-07-20T11:37:45.000+0000","strategyUsed":"CHAMPION","uwAuthority":null,"uwCriterias":[],"subjectivityMessages":[],"traditionalScoreModels":null,"mlModels":null,"calculatedVariables":[{"fieldName":"AVG_TOTAL_AVG_MONTHLY_BALANCE_L3M","fieldType":"Real","fieldValue":"0.0","varCategory":"COMMON"}],"ruleAudits":[{"metaphorName":"FN_PreProcessing","ruleId":"","ruleName":null,"timeStamp":null}]}},"finalUWDecision":null,';
		response += errorMessage;
		response += ',"responseStatus":"SUCCESS"}},"status":"complete","startTimestamp":"2024-07-20T11:37:41.904+0000","endTimestamp":"2024-07-20T11:37:47.297+0000","timeTaken":5393}}';
		System.debug('Test Class Resp 2:'+response);
        return response;
    }*/

}