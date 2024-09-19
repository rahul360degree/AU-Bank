/**
 * @author              : Amit Mishra
 * @date                : 29-July-2024
 * @description         : BRE mock response
 * Test Class           : AUSF_INT_BRE_Test
 * History              :
 * ===========================================================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ===========================================================================================================
 * 29-July-2024 	Amit Mishra 		Initial Version
**/
@isTest
public without sharing class AUSF_INT_BRE_MockResponse {
    
    public static String getResponse(Integer message,String systemDecision){
		List<Applicant__c> applicantList = [SELECT Id, Name, Gender__c, Loan_application__c FROM Applicant__c LIMIT 1];
        Boolean addBureauResponse = true;
		String errorMessage = '"error":null' ;
		String bureauResponse = '"bureauResponse":null,';
		String applicantWrap = '"applicantId":"'+applicantList[0].Id + '",';
		if(message == 1){
			errorMessage = '"error": [ { "stackTrace": "Error in Validate Request And Variable Assignment Script while Validating Input Message and stack trace is Missing required creator property \'journeyType\'", "source": "PL - FICO CDE PLOR", "dateTime": "23-07-2024 10:52:22", "errorCode": "PLOR_4001", "description": "FUNCTIONAL ERROR" } ]';
        }
        if(systemDecision == NULL){
			systemDecision = 'STP';
		}
        //add bureauResponse & cibilResponse
		if(addBureauResponse){
			bureauResponse = '"bureauResponse":{"cibilResponse":[{"accountSegment":[{"SegmentTag":"string","ReportingNumberShortName":"string","AccountNumber":"string","AccountType":"03","OwnershipIndicator":"01","DateOpenedDisbursed":"20022024","DateofLastPayment":"02022023","DateClosed":"02022023","DateReportedAndCertified":"string","HighCreditSanctionedAmount":0,"CurrentBalance":0,"AmountOverdue":0,"PaymentHistory1":"string","PaymentHistory2":"string","PaymentHistoryStartDate":"string","PaymentHistoryEndDate":"string","SuitFiledWilfulDefault":"03","CreditFacilityStatus":"string","ValueOfCollateral":0,"TypeOfCollateral":"string","CreditLimit": 0,"CashLimit": 0,"RateOfInterest":0,"RepaymentTenure": 0, "EMIAmount": 0, "WrittenOffAmountTotal": 0, "WrittenOffAmountPrincipal": 0, "SettlementAmount": 0, "PaymentFrequency": 0, "ActualPaymentAmount": 0, "DateOfEntryForErrorCode": "string", "ErrorCode": "string", "DateOfEntryForCIBILRemarksCode": "string", "CIBILRemarksCode": "string", "DateOfEntryForErrorDisputeRemarksCode": "string", "ErrorDisputeRemarksCode1": "string", "ErrorDisputeRemarksCode2": "string" }, { "SegmentTag": "string", "ReportingNumberShortName": "string", "AccountNumber": "string", "AccountType": "string", "OwnershipIndicator": "string", "DateOpenedDisbursed": "string", "DateofLastPayment": "string", "DateClosed": "string", "DateReportedAndCertified": "string", "HighCreditSanctionedAmount": 0, "CurrentBalance": 0, "AmountOverdue": 0, "PaymentHistory1": "string", "PaymentHistory2": "string", "PaymentHistoryStartDate": "string", "PaymentHistoryEndDate": "string", "SuitFiledWilfulDefault": "01", "CreditFacilityStatus": "string", "ValueOfCollateral": 0, "TypeOfCollateral": "string", "CreditLimit": 0, "CashLimit": 0, "RateOfInterest": 0, "RepaymentTenure": 0, "EMIAmount": 0, "WrittenOffAmountTotal": 0, "WrittenOffAmountPrincipal": 0, "SettlementAmount": 0, "PaymentFrequency": 0, "ActualPaymentAmount": 0, "DateOfEntryForErrorCode": "string", "ErrorCode": "string", "DateOfEntryForCIBILRemarksCode": "string", "CIBILRemarksCode": "string", "DateOfEntryForErrorDisputeRemarksCode": "string", "ErrorDisputeRemarksCode1": "string", "ErrorDisputeRemarksCode2": "string" } ], "addressList": [ { "AddressSegmentTag": "PA", "Length": "03", "AddressLine1FieldLength": "03", "AddressLine1": "HNO", "AddressLine2FieldLength": "09", "AddressLine2": "MASAGUPPI", "AddressLine5FieldLength": "08", "AddressLine5": "BELAGAVI", "StateCode": "29", "PinCodeFieldLength": "06", "PinCode": "591312", "AddressCategory": "02", "DateReported": "27032024", "EnrichedThroughEnquiry": "Y" } ], "enquiry": [ { "Length": "04", "SegmentTag": "I001", "DateOfEnquiryFields": "20052024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I002", "DateOfEnquiryFields": "20052024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I003", "DateOfEnquiryFields": "10052024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I004", "DateOfEnquiryFields": "09052024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I005", "DateOfEnquiryFields": "06052024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I006", "DateOfEnquiryFields": "06052024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I007", "DateOfEnquiryFields": "30042024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I008", "DateOfEnquiryFields": "30042024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I009", "DateOfEnquiryFields": "30042024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I010", "DateOfEnquiryFields": "17042024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I011", "DateOfEnquiryFields": "02042024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 }, { "Length": "04", "SegmentTag": "I012", "DateOfEnquiryFields": "27032024", "EnquiringMemberShortNameFieldLength": "06", "EnquiringMemberShortName": "AU SFB", "EnquiryPurpose": "32", "EnquiryAmountFieldLength": "04", "EnquiryAmount": 1000.0 } ], "header": { "SegmentTag": "TUEF", "Version": "12", "ReferencEnumber": "46209060", "MemberCode": "NB66521058_UATC2C7 ", "SubjectReturnCode": "1", "EnquiryControlNumber": "002160060020", "DateProcessed": "24052024", "TimeProcessed": "122847" }, "scoreSegment": [ { "Length": "10", "ScoreName": "CIBILTUSC3", "ScoreCardName": "16", "ScoreCardVersion": "10", "ScoreDate": "24052024", "Score": "00103", "ReasonCode1FieldLength": null, "ReasonCode1": null, "ReasonCode2FieldLength": null, "ReasonCode2": null, "ReasonCode3FieldLength": null, "ReasonCode3": null, "ReasonCode4FieldLength": null, "ReasonCode4": null, "ReasonCode5FieldLength": null, "ReasonCode5": null } ], "status": "SUCCESS", "isAddtionalMatch": false } ] },';
		}
        String response = '{"transactionId":"203ccd49-b92b-4797-9765-5af4b638959c","content":{"outputVariables":{"MasterMessageOut":{"requestTime":"2024-05-25T06:32:36.163Z","responseTime":"2024-07-20T11:37:46.193Z","elapsedTime":561742541,"decisionService":"DS_PL","callType":"DP_KNOCKOUT","callingSystem":"LOS","application":{"applicationInfo":{"applicationNumber":"LEAD-0000000258",';
		response += '"leadId":"'+applicantList[0].Loan_application__c+'",';
		response += '"transactionId":"T0001",';
		response += '"branchCode":"2365","branchName":"Akola_Necklace Road","branchHub":"Akola","branchRegion":"Akola","applicationDate":"2024-05-25T06:32:36.163+0000","applicationStage":"QDE","applicationCounter":0,"journeyType":"NTB","etbPAType":null,"channel":"DIY","source":"MOBILE","roName":null,"roCode":null,"rmName":null,"rmCode":null,"processingDate":"2024-06-04T00:00:00.000+0000"},"applicants":[{"customerName":"Gaurav Sharma","applicantType":"PRIMARY",';
		response += applicantWrap;
		response += '"bureauPull":false,"isFinancialApplicant":true,"customerType":"I","customerSegment":"SELF_EMPLOYED_NON_PROFESSIONAL","customerGrade":null,"customerLocationProfile":"METRO","constitution":"INDIVIUDAL","existingCustomer":false,"etbType":null,"birthPlace":"RAJASTHAN","age":360,"dateOfBirth":"1989-05-24T06:32:36.163+0000","gender":"Male","nationality":"Indian","maritalStatus":"SINGLE","noOfDependents":2,"relationWithApplicant":"SELF","residentType":"RESIDENT","customerRiskProfile":"NORMAL","auEmployeeDetails":null,"isAUEmployee":false,"isETBAddressNotChanged":false,"cfrStatus":"NO_MATCH","amlStatus":"NO_MATCH","relatedPartyStatus":"NO_MATCH","negativePartyStatus":"NO_MATCH","totalRelationshipValue":0,"isLeadToLeadFullMatch":false,"isLeadToLeadPartialMatch":false,"isLeadToCustomerPartialMatch":false,"ekycType":null,"companyBusinessDetails":{"businessName":"Industry","sector":"text","industry":"text","subIndustry":"text","occupation":"text","dateOfIncorporation":"2020-01-01T10:10:10.100+0000","noOfYearsInBusiness":10.5,"noOfPartners":1,"noOfDirectors":1},"employmentDetails":null,"idDetails":[{"idType":"PAN","idNumber":"BBPPS2564B","isVerified":true,"issueDate":"2024-05-24T06:32:36.163+0000","expiryDate":"2024-05-24T06:32:36.163+0000"},{"idType":"AADHAAR","idNumber":"639565421230","isVerified":true,"issueDate":"2024-05-24T06:32:36.163+0000","expiryDate":"2024-05-24T06:32:36.163+0000"}],"emailDetails":null,"address":[{"addressType":"CURRENT","pinCode":"560043","district":"RAJSHTHAN","city":"Jaipur","state":"Jaipur","taluka":"Jaipur","country":"India","timeAtCurrentCity":0,"timeAtCurrentAddress":0,"ownershipStatus":"OWNED","propertyType":"INDEPENDENT_HOUSE","distanceFromBranch":0,"locationType":"URBAN","locationSubType":"METRO","isNegativeArea":false,"isResiCumOffice":false,"pinCodeCategory":"WORKING","address":"SR NO 1 2,PLOT NO 14"},{"addressType":"OFFICE","pinCode":"560043","district":"RAJSHTHAN","city":"Jaipur","state":"Jaipur","taluka":"Jaipur","country":"India","timeAtCurrentCity":0,"timeAtCurrentAddress":0,"ownershipStatus":"OWNED","propertyType":"RESIDENTIAL_OFFICE","distanceFromBranch":0,"locationType":"URBAN","locationSubType":"METRO","isNegativeArea":false,"isResiCumOffice":false,"pinCodeCategory":"WORKING","address":"SROT NO 14"}],"telephoneDetails":[{"telephoneExtention":"044","telephoneNumber":"9887115555","telephoneType":"01"}],"incomeData":{"payslipDetails":null,"declaredAnnualTurnover":2000000,"declaredNetMonthlyIncome":0,"verfiedNetMonthlyIncome":0,"verfiedAnnualTurnover":0,"declaredMonthlyObligation":0},"bankAccountDetails":null,"existingLoanAccountDetails":null,"existingCardAccountDetails":null,"existingCCODDetails":null,"existingCASADetails":null,"gstDetails":null,"educationDetails":{"educationStatus":"UNEDUCATED","professionalQualification":"string","isProfessionalDegreeVerified":true},"karzaData":null,"posidexData":null,"verificationReportData":null,"interfaceResponses":null,';
		response += bureauResponse;
		response += '"applicantAddtionalAttributes":null,"applicantDecision":{"calculatedVariables":[{"fieldName":"CIBIL_SCORE","fieldType":"Integer","fieldValue":"860","varCategory":"CIBIL"},{"fieldName":"CIBIL_STATUS","fieldType":"String","fieldValue":"HIT","varCategory":"CIBIL"},{"fieldName":"CIBIL_SEGMENTATION","fieldType":"String","fieldValue":"THIN_CIBIL","varCategory":"CIBIL"},{"fieldName":"MAX_BUREAU_VINTAGE","fieldType":"Integer","fieldValue":"225","varCategory":"CIBIL"}],"uwCriterias":[],"bureauBasedIncomeEstimation":null,"bureauBasedCommitmentDTls":{"existingCommitment":1075,"existingAccountCommitment":[{"accountNumber":"string","dateClosed":"","dateOpen":"20102023","accountType":"01","reportingMemberShortName":"string","ownershipIndicator":"4","debtType":"","isUnsecured":false,"accountExcluded":true,"exclusionReason":"Account Excluded Due To Closed","tenure":0,"roi":0,"highCreditOrSanctionedAmount":2000000,"currentBalance":0,"paymentHistory1":"000000000000000000000","paymentHistory2":"000000","accountCommitment":0,"emiAmount":0,"imputedeEMIAmount":0,"obligationFromLOS":0},{"accountNumber":"string","dateClosed":"","dateOpen":"20102023","accountType":"10","reportingMemberShortName":"string","ownershipIndicator":"4","debtType":"Credit Card","isUnsecured":true,"accountExcluded":false,"exclusionReason":null,"tenure":0,"roi":5,"highCreditOrSanctionedAmount":1000000,"currentBalance":1000,"paymentHistory1":"000000000000000000000","paymentHistory2":"000025","accountCommitment":50,"emiAmount":0,"imputedeEMIAmount":50,"obligationFromLOS":0},{"accountNumber":"string","dateClosed":null,"dateOpen":"29032024","accountType":"35","reportingMemberShortName":"AUSFB","ownershipIndicator":"1","debtType":"Corporate Credit Card","isUnsecured":true,"accountExcluded":false,"exclusionReason":null,"tenure":0,"roi":5,"highCreditOrSanctionedAmount":500000,"currentBalance":1000,"paymentHistory1":"000000000000000000000","paymentHistory2":"030","accountCommitment":50,"emiAmount":0,"imputedeEMIAmount":50,"obligationFromLOS":0},{"accountNumber":"string","dateClosed":"","dateOpen":"01122023","accountType":"36","reportingMemberShortName":"AUSFB","ownershipIndicator":"1","debtType":"Kisan Credit Card","isUnsecured":true,"accountExcluded":false,"exclusionReason":null,"tenure":0,"roi":2,"highCreditOrSanctionedAmount":50000,"currentBalance":1500,"paymentHistory1":"000000000000000000000","paymentHistory2":"030","accountCommitment":1000,"emiAmount":0,"imputedeEMIAmount":1000,"obligationFromLOS":0},{"accountNumber":"string","dateClosed":"","dateOpen":"20102023","accountType":"10","reportingMemberShortName":"string","ownershipIndicator":"4","debtType":"","isUnsecured":false,"accountExcluded":true,"exclusionReason":"Account Excluded Due To Closed","tenure":0,"roi":0,"highCreditOrSanctionedAmount":2000000,"currentBalance":0,"paymentHistory1":"000000000000000000000","paymentHistory2":"000","accountCommitment":0,"emiAmount":0,"imputedeEMIAmount":0,"obligationFromLOS":0}]},"traditionalScoreModels":[{"modelID":"PL_SELF_EMPLOYED_SCORECARD","modelName":"Self_Employed_Scorecard","baseScore":0,"totalScore":542.2,"scoreBand":"5","scoreBasedDecision":"REFER",';
		response += applicantWrap;
		response += '"scoreModelCharacteristic":[{"characteristicName":"MAX_DPD_L36M","characteristicValue":"30","characteristicType":"Integer","characteristicReason":"Max DPD is GE 29 and less than 60","partialScore":50,"weight":0,"charScore":50},{"characteristicName":"MAX_COUNT_DPD_GT0_LIVE_ACCOUNTS_L12M","characteristicValue":"1","characteristicType":"Integer","characteristicReason":"One","partialScore":51,"weight":0,"charScore":51},{"characteristicName":"UTIL_LIVE_CC","characteristicValue":"0.044444444444444446","characteristicType":"Double","characteristicReason":"Less than 0.2","partialScore":69,"weight":0,"charScore":69}]}],"fiInitiationDetails":[]}}],"product":[{"productType":"PL","productCode":"0256","subProductType":"string","schemeId":null,"loanPurpose":null,"isTopUp":false,"linkedAccountNumberForTopUp":null,"natureOfLoan":null,"emiFrequency":null,"scheduleType":null,"requestedLoanAmount":600000,"requestedInstallmentAmount":10,"instalmentFreq":null,"requestedTenor":0,"requestedROI":60,"requestedPF":0,"rateType":null,"pslClassficatinType":null,"pslClassficatinSubType":null,"noOfTopUp":0,"totalExposure":0,"existingGroupExposure":0,"promoCode":null,"productDecision":{"productDecision":"STP","uwCriterias":[],"isAppliedPromoCode":false,"promoStartDate":null,"promoEndDate":null,"calculatedVariables":[],"ruleAudits":[],"offerData":{"maxEligibleLoanAmount":478000,"maxFOIR":0,"minTenure":12,"maxTenure":36,"roi":25,"roiGrid":[{"minLoanAmount":0,"maxLoanAmount":199999,"roi":25},{"minLoanAmount":200000,"maxLoanAmount":478000,"roi":25}],"stampDutyGrid":[{"minLoanAmount":0,"maxLoanAmount":478000,"stampDutyRate":0.25,"maxStampDutyCapping":1500000}],"pfRateGrid":[{"minLoanAmount":0,"maxLoanAmount":478000,"processingFeesRate":4}],"pfAmountGrid":[{"minLoanAmount":0,"maxLoanAmount":478000,"processingFeesAmount":0}],"loanAmountTenureGrid":[]},"schemeDecision":[]}}],"documentsReceived":null,"hunterResponse":null,"randomNumber":0,"applicationAddtionalAttributes":null,';
		response += '"applicationDecision":{"systemDecision":"' + systemDecision + '","systemDecisionDate":"2024-07-20T11:37:45.000+0000","strategyUsed":"CHAMPION","uwAuthority":null,"uwCriterias":[],"subjectivityMessages":[],"traditionalScoreModels":null,"mlModels":null,"calculatedVariables":[{"fieldName":"AVG_TOTAL_AVG_MONTHLY_BALANCE_L3M","fieldType":"Real","fieldValue":"0.0","varCategory":"COMMON"}],"ruleAudits":[{"metaphorName":"FN_PreProcessing","ruleId":"","ruleName":null,"timeStamp":null}]}},"finalUWDecision":null,';
		response += errorMessage;
		response += ',"responseStatus":"SUCCESS"}},"status":"complete","startTimestamp":"2024-07-20T11:37:41.904+0000","endTimestamp":"2024-07-20T11:37:47.297+0000","timeTaken":5393}}';
		System.debug('Test Class Resp 2:'+response);
        return response;
    }

    /*public static String getResponseString() {
        List<Applicant__c> applicantList = [SELECT Id, Name, Gender__c, Loan_application__c FROM Applicant__c LIMIT 1];
        String json=		'{'+
		'  "transactionId": "0f484530-d708-443f-bfe8-7c53ff3f8187",'+
		'  "content": {'+
		'    "outputVariables": {'+
		'      "name": "MasterMessageOut",'+
		'      "value": {'+
		'        "application": {'+
		'          "applicationInfo": {'+
		'            "applicationNumber": "APP01012312",'+
		'            "leadId": "LID00152",'+
		'            "transactionId": "'+[SELECT Id, Name FROM Loan_Application__c LIMIT 1].Id+'",'+
		'            "branchCode": "2365",'+
		'            "branchName": "Akola_Necklace Road",'+
		'            "branchHub": "Akola",'+
		'            "branchRegion": "Akola",'+
		'            "applicationDate": "2024-05-25T06:32:36.163Z",'+
		'            "applicationStage": "QDE",'+
		'            "applicationCounter": 0,'+
		'            "journeyType": "NTB",'+
		'            "channel": "DIY",'+
		'            "source": "MOBILE",'+
		'            "processingDate": "2024-06-04"'+
		'          },'+
		'          "applicants": ['+
		'            {'+
		'              "customerName": "Gaurav Sharma",'+
		'              "applicantType": "PRIMARY",'+
		'              "applicantId": "'+applicantList[0].Id+'",'+
		'              "bureauPull": false,'+
		'              "isFinancialApplicant": true,'+
		'              "customerType": "I",'+
		'              "customerSegment": "SELF_EMPLOYED",'+
		'              "customerLocationProfile": "METRO",'+
		'              "constitution": "INDIVIUDAL",'+
		'              "existingCustomer": false,'+
		'              "relationWithApplicant": "SELF",'+
		'              "birthPlace": "RAJASTHAN",'+
		'              "age": 360,'+
		'              "gender": "Male",'+
		'              "nationality": "Indian",'+
		'              "maritalStatus": "SINGLE",'+
		'              "noOfDependents": 2,'+
		'              "residentType": "RESIDENT",'+
		'              "customerRiskProfile": "NORMAL",'+
		'              "isAUEmployee": false,'+
		'              "idDetails": ['+
		'                {'+
		'                  "idType": "AADHAAR",'+
		'                  "idNumber": "639565421230",'+
		'                  "isVerified": true,'+
		'                  "issueDate": "2024-05-24T06:32:36.163Z",'+
		'                  "expiryDate": "2024-05-24T06:32:36.163Z"'+
		'                },'+
		'                {'+
		'                  "idType": "PAN",'+
		'                  "idNumber": "BBPPS2564A",'+
		'                  "isVerified": true,'+
		'                  "issueDate": "2024-05-24T06:32:36.163Z",'+
		'                  "expiryDate": "2024-05-24T06:32:36.163Z"'+
		'                }'+
		'              ],'+
		'              "telephoneDetails": ['+
		'                {'+
		'                  "telephoneExtention": "044",'+
		'                  "telephoneNumber": "9887115555",'+
		'                  "telephoneType": "01"'+
		'                }'+
		'              ],'+
		'              "isETBAddressNotChanged": false,'+
		'              "cfrStatus": "NO_MATCH",'+
		'              "amlStatus": "NO_MATCH",'+
		'              "relatedPartyStatus": "NO_MATCH",'+
		'              "negativePartyStatus": "NO_MATCH",'+
		'              "totalRelationshipValue": 0,'+
		'              "isLeadToLeadFullMatch": false,'+
		'              "isLeadToLeadPartialMatch": false,'+
		'              "isLeadToCustomerPartialMatch": false,'+
		'              "companyBusinessDetails": {'+
		'                "businessName": "Industry",'+
		'                "dateOfIncorporation": "2020-01-01T10:10:10.100Z",'+
		'                "industry": "text",'+
		'                "noOfDirectors": 1,'+
		'                "noOfPartners": 1,'+
		'                "noOfYearsInBusiness": 10.5,'+
		'                "occupation": "text",'+
		'                "sector": "text",'+
		'                "subIndustry": "text"'+
		'              },'+
		'              "incomeData": {'+
		'                "declaredAnnualTurnover": 1000000'+
		'              },'+
		'              "address": ['+
		'                {'+
		'                  "addressType": "CURRENT",'+
		'                  "pinCode": "302001",'+
		'                  "district": "RAJSHTHAN",'+
		'                  "city": "Jaipur",'+
		'                  "state": "Jaipur",'+
		'                  "taluka": "Jaipur",'+
		'                  "country": "India",'+
		'                  "timeAtCurrentCity": 0,'+
		'                  "timeAtCurrentAddress": 0,'+
		'                  "ownershipStatus": "OWNED",'+
		'                  "propertyType": "INDEPENDENT_HOUSE",'+
		'                  "distanceFromBranch": 0,'+
		'                  "locationType": "URBAN",'+
		'                  "locationSubType": "METRO",'+
		'                  "isNegativeArea": false,'+
		'                  "isResiCumOffice": false,'+
		'                  "pinCodeCategory": "WORKING",'+
		'                  "address": "SR NO 2/1 2,PLOT NO 14"'+
		'                },'+
		'                {'+
		'                  "addressType": "OFFICE",'+
		'                  "pinCode": "302001",'+
		'                  "district": "RAJSHTHAN",'+
		'                  "city": "Jaipur",'+
		'                  "state": "Jaipur",'+
		'                  "taluka": "Jaipur",'+
		'                  "country": "India",'+
		'                  "timeAtCurrentCity": 0,'+
		'                  "timeAtCurrentAddress": 0,'+
		'                  "ownershipStatus": "OWNED",'+
		'                  "propertyType": "RESIDENTIAL_OFFICE",'+
		'                  "distanceFromBranch": 0,'+
		'                  "locationType": "URBAN",'+
		'                  "locationSubType": "METRO",'+
		'                  "isNegativeArea": false,'+
		'                  "isResiCumOffice": false,'+
		'                  "pinCodeCategory": "WORKING",'+
		'                  "address": "SROT NO 14"'+
		'                }'+
		'              ],'+
		'              "educationDetails": {'+
		'                "educationStatus": "UNEDUCATED",'+
		'                "professionalQualification": "string",'+
		'                "isProfessionalDegreeVerified": true'+
		'              },'+
		'              "bureauResponse": {'+
		'                "cibilResponse": ['+
		'                  {'+
		'                    "accountSegment": ['+
		'                      {'+
		'                        "SegmentTag": "string",'+
		'                        "ReportingNumberShortName": "string",'+
		'                        "AccountNumber": "string",'+
		'                        "AccountType": "03",'+
		'                        "OwnershipIndicator": "01",'+
		'                        "DateOpenedDisbursed": "20022024",'+
		'                        "DateofLastPayment": "02022023",'+
		'                        "DateClosed": "02022023",'+
		'                        "DateReportedAndCertified": "string",'+
		'                        "HighCreditSanctionedAmount": 0,'+
		'                        "CurrentBalance": 0,'+
		'                        "AmountOverdue": 0,'+
		'                        "PaymentHistory1": "string",'+
		'                        "PaymentHistory2": "string",'+
		'                        "PaymentHistoryStartDate": "string",'+
		'                        "PaymentHistoryEndDate": "string",'+
		'                        "SuitFiledWilfulDefault": "03",'+
		'                        "CreditFacilityStatus": "string",'+
		'                        "ValueOfCollateral": 0,'+
		'                        "TypeOfCollateral": "string",'+
		'                        "CreditLimit": 0,'+
		'                        "CashLimit": 0,'+
		'                        "RateOfInterest": 0,'+
		'                        "RepaymentTenure": 0,'+
		'                        "EMIAmount": 0,'+
		'                        "WrittenOffAmountTotal": 0,'+
		'                        "WrittenOffAmountPrincipal": 0,'+
		'                        "SettlementAmount": 0,'+
		'                        "PaymentFrequency": 0,'+
		'                        "ActualPaymentAmount": 0,'+
		'                        "DateOfEntryForErrorCode": "string",'+
		'                        "ErrorCode": "string",'+
		'                        "DateOfEntryForCIBILRemarksCode": "string",'+
		'                        "CIBILRemarksCode": "string",'+
		'                        "DateOfEntryForErrorDisputeRemarksCode": "string",'+
		'                        "ErrorDisputeRemarksCode1": "string",'+
		'                        "ErrorDisputeRemarksCode2": "string"'+
		'                      },'+
		'                      {'+
		'                        "SegmentTag": "string",'+
		'                        "ReportingNumberShortName": "string",'+
		'                        "AccountNumber": "string",'+
		'                        "AccountType": "string",'+
		'                        "OwnershipIndicator": "string",'+
		'                        "DateOpenedDisbursed": "string",'+
		'                        "DateofLastPayment": "string",'+
		'                        "DateClosed": "string",'+
		'                        "DateReportedAndCertified": "string",'+
		'                        "HighCreditSanctionedAmount": 0,'+
		'                        "CurrentBalance": 0,'+
		'                        "AmountOverdue": 0,'+
		'                        "PaymentHistory1": "string",'+
		'                        "PaymentHistory2": "string",'+
		'                        "PaymentHistoryStartDate": "string",'+
		'                        "PaymentHistoryEndDate": "string",'+
		'                        "SuitFiledWilfulDefault": "01",'+
		'                        "CreditFacilityStatus": "string",'+
		'                        "ValueOfCollateral": 0,'+
		'                        "TypeOfCollateral": "string",'+
		'                        "CreditLimit": 0,'+
		'                        "CashLimit": 0,'+
		'                        "RateOfInterest": 0,'+
		'                        "RepaymentTenure": 0,'+
		'                        "EMIAmount": 0,'+
		'                        "WrittenOffAmountTotal": 0,'+
		'                        "WrittenOffAmountPrincipal": 0,'+
		'                        "SettlementAmount": 0,'+
		'                        "PaymentFrequency": 0,'+
		'                        "ActualPaymentAmount": 0,'+
		'                        "DateOfEntryForErrorCode": "string",'+
		'                        "ErrorCode": "string",'+
		'                        "DateOfEntryForCIBILRemarksCode": "string",'+
		'                        "CIBILRemarksCode": "string",'+
		'                        "DateOfEntryForErrorDisputeRemarksCode": "string",'+
		'                        "ErrorDisputeRemarksCode1": "string",'+
		'                        "ErrorDisputeRemarksCode2": "string"'+
		'                      }'+
		'                    ],'+
		'                    "addressList": ['+
		'                      {'+
		'                        "AddressSegmentTag": "PA",'+
		'                        "Length": "03",'+
		'                        "AddressLine1FieldLength": "03",'+
		'                        "AddressLine1": "HNO",'+
		'                        "AddressLine2FieldLength": "09",'+
		'                        "AddressLine2": "MASAGUPPI",'+
		'                        "AddressLine5FieldLength": "08",'+
		'                        "AddressLine5": "BELAGAVI",'+
		'                        "StateCode": "29",'+
		'                        "PinCodeFieldLength": "06",'+
		'                        "PinCode": "591312",'+
		'                        "AddressCategory": "02",'+
		'                        "DateReported": "27032024",'+
		'                        "EnrichedThroughEnquiry": "Y"'+
		'                      }'+
		'                    ],'+
		'                    "enquiry": ['+
		'                      {'+
		'                        "Length": "04",'+
		'                        "SegmentTag": "I001",'+
		'                        "DateOfEnquiryFields": "20052024",'+
		'                        "EnquiringMemberShortNameFieldLength": "06",'+
		'                        "EnquiringMemberShortName": "AU SFB",'+
		'                        "EnquiryPurpose": "32",'+
		'                        "EnquiryAmountFieldLength": "04",'+
		'                        "EnquiryAmount": 1000'+
		'                      },'+
		'                      {'+
		'                        "Length": "04",'+
		'                        "SegmentTag": "I002",'+
		'                        "DateOfEnquiryFields": "20052024",'+
		'                        "EnquiringMemberShortNameFieldLength": "06",'+
		'                        "EnquiringMemberShortName": "AU SFB",'+
		'                        "EnquiryPurpose": "32",'+
		'                        "EnquiryAmountFieldLength": "04",'+
		'                        "EnquiryAmount": 1000'+
		'                      },'+
		'                      {'+
		'                        "Length": "04",'+
		'                        "SegmentTag": "I003",'+
		'                        "DateOfEnquiryFields": "10052024",'+
		'                        "EnquiringMemberShortNameFieldLength": "06",'+
		'                        "EnquiringMemberShortName": "AU SFB",'+
		'                        "EnquiryPurpose": "32",'+
		'                        "EnquiryAmountFieldLength": "04",'+
		'                        "EnquiryAmount": 1000'+
		'                      },'+
		'                      {'+
		'                        "Length": "04",'+
		'                        "SegmentTag": "I004",'+
		'                        "DateOfEnquiryFields": "09052024",'+
		'                        "EnquiringMemberShortNameFieldLength": "06",'+
		'                        "EnquiringMemberShortName": "AU SFB",'+
		'                        "EnquiryPurpose": "32",'+
		'                        "EnquiryAmountFieldLength": "04",'+
		'                        "EnquiryAmount": 1000'+
		'                      },'+
		'                      {'+
		'                        "Length": "04",'+
		'                        "SegmentTag": "I005",'+
		'                        "DateOfEnquiryFields": "06052024",'+
		'                        "EnquiringMemberShortNameFieldLength": "06",'+
		'                        "EnquiringMemberShortName": "AU SFB",'+
		'                        "EnquiryPurpose": "32",'+
		'                        "EnquiryAmountFieldLength": "04",'+
		'                        "EnquiryAmount": 1000'+
		'                      },'+
		'                      {'+
		'                        "Length": "04",'+
		'                        "SegmentTag": "I006",'+
		'                        "DateOfEnquiryFields": "06052024",'+
		'                        "EnquiringMemberShortNameFieldLength": "06",'+
		'                        "EnquiringMemberShortName": "AU SFB",'+
		'                        "EnquiryPurpose": "32",'+
		'                        "EnquiryAmountFieldLength": "04",'+
		'                        "EnquiryAmount": 1000'+
		'                      },'+
		'                      {'+
		'                        "Length": "04",'+
		'                        "SegmentTag": "I007",'+
		'                        "DateOfEnquiryFields": "30042024",'+
		'                        "EnquiringMemberShortNameFieldLength": "06",'+
		'                        "EnquiringMemberShortName": "AU SFB",'+
		'                        "EnquiryPurpose": "32",'+
		'                        "EnquiryAmountFieldLength": "04",'+
		'                        "EnquiryAmount": 1000'+
		'                      },'+
		'                      {'+
		'                        "Length": "04",'+
		'                        "SegmentTag": "I008",'+
		'                        "DateOfEnquiryFields": "30042024",'+
		'                        "EnquiringMemberShortNameFieldLength": "06",'+
		'                        "EnquiringMemberShortName": "AU SFB",'+
		'                        "EnquiryPurpose": "32",'+
		'                        "EnquiryAmountFieldLength": "04",'+
		'                        "EnquiryAmount": 1000'+
		'                      },'+
		'                      {'+
		'                        "Length": "04",'+
		'                        "SegmentTag": "I009",'+
		'                        "DateOfEnquiryFields": "30042024",'+
		'                        "EnquiringMemberShortNameFieldLength": "06",'+
		'                        "EnquiringMemberShortName": "AU SFB",'+
		'                        "EnquiryPurpose": "32",'+
		'                        "EnquiryAmountFieldLength": "04",'+
		'                        "EnquiryAmount": 1000'+
		'                      },'+
		'                      {'+
		'                        "Length": "04",'+
		'                        "SegmentTag": "I010",'+
		'                        "DateOfEnquiryFields": "17042024",'+
		'                        "EnquiringMemberShortNameFieldLength": "06",'+
		'                        "EnquiringMemberShortName": "AU SFB",'+
		'                        "EnquiryPurpose": "32",'+
		'                        "EnquiryAmountFieldLength": "04",'+
		'                        "EnquiryAmount": 1000'+
		'                      },'+
		'                      {'+
		'                        "Length": "04",'+
		'                        "SegmentTag": "I011",'+
		'                        "DateOfEnquiryFields": "02042024",'+
		'                        "EnquiringMemberShortNameFieldLength": "06",'+
		'                        "EnquiringMemberShortName": "AU SFB",'+
		'                        "EnquiryPurpose": "32",'+
		'                        "EnquiryAmountFieldLength": "04",'+
		'                        "EnquiryAmount": 1000'+
		'                      },'+
		'                      {'+
		'                        "Length": "04",'+
		'                        "SegmentTag": "I012",'+
		'                        "DateOfEnquiryFields": "27032024",'+
		'                        "EnquiringMemberShortNameFieldLength": "06",'+
		'                        "EnquiringMemberShortName": "AU SFB",'+
		'                        "EnquiryPurpose": "32",'+
		'                        "EnquiryAmountFieldLength": "04",'+
		'                        "EnquiryAmount": 1000'+
		'                      }'+
		'                    ],'+
		'                    "header": {'+
		'                      "SegmentTag": "TUEF",'+
		'                      "Version": "12",'+
		'                      "ReferencEnumber": "46209060",'+
		'                      "MemberCode": "NB66521058_UATC2C7            ",'+
		'                      "SubjectReturnCode": "1",'+
		'                      "EnquiryControlNumber": "002160060020",'+
		'                      "DateProcessed": "24052024",'+
		'                      "TimeProcessed": "122847"'+
		'                    },'+
		'                    "scoreSegment": ['+
		'                      {'+
		'                        "Length": "10",'+
		'                        "ScoreName": "CIBILTUSC3",'+
		'                        "ScoreCardName": "16",'+
		'                        "ScoreCardVersion": "10",'+
		'                        "ScoreDate": "24052024",'+
		'                        "Score": "00103",'+
		'                        "ReasonCode1FieldLength": null,'+
		'                        "ReasonCode1": null,'+
		'                        "ReasonCode2FieldLength": null,'+
		'                        "ReasonCode2": null,'+
		'                        "ReasonCode3FieldLength": null,'+
		'                        "ReasonCode3": null,'+
		'                        "ReasonCode4FieldLength": null,'+
		'                        "ReasonCode4": null,'+
		'                        "ReasonCode5FieldLength": null,'+
		'                        "ReasonCode5": null'+
		'                      }'+
		'                    ],'+
		'                    "status": "SUCCESS",'+
		'                    "isAddtionalMatch": false'+
		'                  }'+
		'                ]'+
		'              },'+
		'              "applicantDecision": {'+
		'                "calculatedVariables": ['+
		'                  {'+
		'                    "fieldName": "CIBIL_SCORE",'+
		'                    "fieldValue": "150",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "CIBIL_STATUS",'+
		'                    "fieldValue": "HIT",'+
		'                    "fieldType": "String",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "MAX_BUREAU_VINTAGE",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "UL_ENQUIRIES_COUNT_L30D",'+
		'                    "fieldValue": "12",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "UL_ENQUIRIES_COUNT_L90D",'+
		'                    "fieldValue": "1",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "TOTAL_SANCTIONED_AMNT_UNSECURED_LOANS_AVAILED_L90D",'+
		'                    "fieldValue": "02",'+
		'                    "fieldType": "Real",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "COUNT_UNSECURED_LOANS_AVAILED_L90D",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "COUNT_UNSECURED_LOANS_AVAILED_L180D",'+
		'                    "fieldValue": "5",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "COUNT_ACTIVE_UNSECURED_LOANS",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "TOTAL_OVERDDUE",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "TOTAL_OUTSTANDING_BAL_CC_ACTIVE",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Real",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "COUNT_DPD_90P_ALL_ACCS",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "COUNT_DPD_0P_L3M",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "COUNT_DPD_30PLUS_ALL_ACCS_L6M",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "COUNT_DPD_30PLUS_ALL_ACCS_L12M",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "COUNT_DPD_60PLUS_ALL_ACCS_L12M",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "WILLFUL_DEFAULT_FLAG",'+
		'                    "fieldValue": "false",'+
		'                    "fieldType": "Boolean",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "RESTRUCTURED_WRITE_OFF_SETTLED_SUIT_FILED_GTE_0K",'+
		'                    "fieldValue": "false",'+
		'                    "fieldType": "Boolean",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "WRITE_OFF_FLAG",'+
		'                    "fieldValue": "false",'+
		'                    "fieldType": "Boolean",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "SETTLED_FLAG",'+
		'                    "fieldValue": "false",'+
		'                    "fieldType": "Boolean",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "SUIT_FILED_FLAG",'+
		'                    "fieldValue": "false",'+
		'                    "fieldType": "Boolean",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "WRITE_OFF_FLAG_SA_GT10KL36M",'+
		'                    "fieldValue": "false",'+
		'                    "fieldType": "Boolean",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "SETTLED_SA_GT10KL36M_FLAG",'+
		'                    "fieldValue": "false",'+
		'                    "fieldType": "Boolean",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "SUIT_FILED_SA_GT10K_L36M_FLAG",'+
		'                    "fieldValue": "false",'+
		'                    "fieldType": "Boolean",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "COUNT_ACTIVE_TRADES",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "IS_EXISTING_AU_ASSETS_COOLING_PERIOD_BREACHED",'+
		'                    "fieldValue": "false",'+
		'                    "fieldType": "Boolean",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "TOTAL_TIMELY_PAYMENTS",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "TOTAL_PAYMENTS",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Real",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "AVG_UTIL_PL",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Real",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "MAX_SANCTION_AMT_PL",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Real",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "AVG_UTIL_CC",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Real",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "LIVE_ACCOUNTS_CC",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "MAX_SANCTION_AMT_CC",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "LIVE_CC_COUNT",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "LIVE_HL_AL_COUNT",'+
		'                    "fieldValue": "0",'+
		'                    "fieldType": "Integer",'+
		'                    "varCategory": "CIBIL"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "CURRENT_ADD_PIN_CODE_CATGOEY",'+
		'                    "fieldType": "String",'+
		'                    "fieldValue": "WORKING",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "CURRENT_ADD_OWNERSHIP_STATUS",'+
		'                    "fieldType": "String",'+
		'                    "fieldValue": "OWNED",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "CURRENT_ADD_RESIDENCE_TIME",'+
		'                    "fieldType": "Real",'+
		'                    "fieldValue": "12",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "OFFICE_ADD_OWNERSHIP_STATUS",'+
		'                    "fieldType": "String",'+
		'                    "fieldValue": "RENTED",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "OFFICE_ADD_PIN_CODE_CATGOEY",'+
		'                    "fieldType": "String",'+
		'                    "fieldValue": "WORKING",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "OFFICE_ADD_STABILTY",'+
		'                    "fieldType": "Real",'+
		'                    "fieldValue": "24",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "CURRENT_ADD_LOCATION_TYPE",'+
		'                    "fieldType": "String",'+
		'                    "fieldValue": "URBAN",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "CURRENT_ADD_LOCATION_SUB_TYPE",'+
		'                    "fieldType": "Real",'+
		'                    "fieldValue": "METRO",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "BUSINESS_ADD_OWNERSHIP_STATUS",'+
		'                    "fieldType": "String",'+
		'                    "fieldValue": "RENTED",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "BUSINESS_ADD_PIN_CODE_CATGOEY",'+
		'                    "fieldType": "String",'+
		'                    "fieldValue": "NON_WORKING",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "BUSINESS_ADD_STABILTY",'+
		'                    "fieldType": "Real",'+
		'                    "fieldValue": "24",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "ETB_TYPE",'+
		'                    "fieldType": "String",'+
		'                    "fieldValue": "ETB_LIABLITIES_PLATINUM",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "TOTAL_AUSFB_CC_LIMIT",'+
		'                    "fieldType": "Real",'+
		'                    "fieldValue": "200000",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "TOTAL_AUSFB_CC_OS_BALANCE",'+
		'                    "fieldType": "Real",'+
		'                    "fieldValue": "250000",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "TOTAL_AUSFB_CC_UTILIZATION",'+
		'                    "fieldType": "Real",'+
		'                    "fieldValue": "25300",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "IS_AUSFB_CC_NPA",'+
		'                    "fieldType": "Boolean",'+
		'                    "fieldValue": "true",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "MAX_CC_CURRENT_DPD",'+
		'                    "fieldType": "Integer",'+
		'                    "fieldValue": "3",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "AUSFB_CC_VINTAGE",'+
		'                    "fieldType": "Integer",'+
		'                    "fieldValue": "24",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "IS_AUSFB_NPA",'+
		'                    "fieldType": "Boolean",'+
		'                    "fieldValue": "false",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "MAX_ASSET_CURRENT_DPD",'+
		'                    "fieldType": "Integer",'+
		'                    "fieldValue": "12",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "IS_DEDUPE_FOUND",'+
		'                    "fieldType": "Boolean",'+
		'                    "fieldValue": "true",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "MIN_LOAN_VINTAGE",'+
		'                    "fieldType": "Real",'+
		'                    "fieldValue": "24",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "IS_BOUNCES_L3M",'+
		'                    "fieldType": "Boolean",'+
		'                    "fieldValue": "true",'+
		'                    "varCategory": "COMMON"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "MAX_TENURE",'+
		'                    "fieldType": "Integer",'+
		'                    "fieldValue": "36",'+
		'                    "varCategory": "COMMON"'+
		'                  }'+
		'                ],'+
		'                "traditionalScoreModels": ['+
		'                  {'+
		'                    "modelID": "SCORECARD",'+
		'                    "modelName": "SELF EMPLOYED",'+
		'                    "baseScore": 0,'+
		'                    "totalScore": 600,'+
		'                    "scoreBand": "string",'+
		'                    "scoreBasedDecision": "string",'+
		'                    "applicantId": "'+applicantList[0].Id+'",'+
		'                    "scoreModelCharacteristic": ['+
		'                      {'+
		'                        "characteristicName": "MAX_DPD_L36M",'+
		'                        "characteristicValue": "25",'+
		'                        "characteristicType": "Integer",'+
		'                        "characteristicReason": "Max DPD is less than 29",'+
		'                        "partialScore": 57,'+
		'                        "weight": 0,'+
		'                        "charScore": 0'+
		'                      },'+
		'                      {'+
		'                        "characteristicName": "MAX_COUNT_DPD_GT0_LIVE_ACCOUNTS_L12M",'+
		'                        "characteristicValue": "0",'+
		'                        "characteristicType": "string",'+
		'                        "characteristicReason": "Less than 0.2",'+
		'                        "partialScore": 41,'+
		'                        "weight": 0,'+
		'                        "charScore": 0'+
		'                      },'+
		'                      {'+
		'                        "characteristicName": "UTIL_LIVE_CC",'+
		'                        "characteristicValue": "0",'+
		'                        "characteristicType": "string",'+
		'                        "characteristicReason": "Consumer Durable Loans LE 10,000 =0",'+
		'                        "partialScore": 34,'+
		'                        "weight": 0,'+
		'                        "charScore": 0'+
		'                      },'+
		'                      {'+
		'                        "characteristicName": "COUNT_CD_ACCOUNTS_LE_10000",'+
		'                        "characteristicValue": "0",'+
		'                        "characteristicType": "string",'+
		'                        "characteristicReason": "Consumer Durable Loans LE 10,000 =0",'+
		'                        "partialScore": 21,'+
		'                        "weight": 0,'+
		'                        "charScore": 0'+
		'                      },'+
		'                      {'+
		'                        "characteristicName": "TOTAL_CONSEC_DELIQ_L13M_PL_ACCOUNTS",'+
		'                        "characteristicValue": "-99",'+
		'                        "characteristicType": "string",'+
		'                        "characteristicReason": "No PL",'+
		'                        "partialScore": 41,'+
		'                        "weight": 0,'+
		'                        "charScore": 0'+
		'                      },'+
		'                      {'+
		'                        "characteristicName": "MIN_MOB_PL_ACCOUNTS_VS_MAX_MOB_ALL",'+
		'                        "characteristicValue": "BIN2",'+
		'                        "characteristicType": "string",'+
		'                        "characteristicReason": "PL Less then 7 month",'+
		'                        "partialScore": 45,'+
		'                        "weight": 0,'+
		'                        "charScore": 0'+
		'                      },'+
		'                      {'+
		'                        "characteristicName": "PRODUCT_HOLDING",'+
		'                        "characteristicValue": "BIN3",'+
		'                        "characteristicType": "string",'+
		'                        "characteristicReason": "CC accounts present",'+
		'                        "partialScore": 15,'+
		'                        "weight": 0,'+
		'                        "charScore": 0'+
		'                      },'+
		'                      {'+
		'                        "characteristicName": "COUNT_ACCOUNTS_OPENED_L12M_VS_COUNT_LIVE_ACCOUNTS_OPENED_L36M",'+
		'                        "characteristicValue": "0",'+
		'                        "characteristicType": "string",'+
		'                        "characteristicReason": "Less then 0.2",'+
		'                        "partialScore": 0,'+
		'                        "weight": 0,'+
		'                        "charScore": 0'+
		'                      },'+
		'                      {'+
		'                        "characteristicName": "CUSTOMER_AGE",'+
		'                        "characteristicValue": "45",'+
		'                        "characteristicType": "string",'+
		'                        "characteristicReason": "Age is less than 50",'+
		'                        "partialScore": 54,'+
		'                        "weight": 0,'+
		'                        "charScore": 0'+
		'                      },'+
		'                      {'+
		'                        "characteristicName": "UTIL_REGULAR_UNSEC_PRODUCTS",'+
		'                        "characteristicValue": "0",'+
		'                        "characteristicType": "Real",'+
		'                        "characteristicReason": "Less then 0.2",'+
		'                        "partialScore": 63,'+
		'                        "weight": 0,'+
		'                        "charScore": 0'+
		'                      }'+
		'                    ]'+
		'                  }'+
		'                ],'+
		'                "bureauBasedCommitmentDTls": {'+
		'                  "existingCommitment": 45000,'+
		'                  "existingAccountCommitment": ['+
		'                    {'+
		'                      "accountCommitment": 0,'+
		'                      "accountNumber": "string",'+
		'                      "dateClosed": "string",'+
		'                      "dateOpen": "string",'+
		'                      "accountType": "string",'+
		'                      "reportingMemberShortName": "string",'+
		'                      "ownershipIndicator": "string",'+
		'                      "debtType": "string",'+
		'                      "isUnsecured": true,'+
		'                      "accountExcluded": true,'+
		'                      "exclusionReason": "string",'+
		'                      "tenure": 0,'+
		'                      "roi": 0,'+
		'                      "highCreditOrSanctionedAmount": 0,'+
		'                      "currentBalance": 0,'+
		'                      "paymentHistory1": "string",'+
		'                      "paymentHistory2": "string",'+
		'                      "emiAmount": 0,'+
		'                      "imputedeEMIAmount": 0'+
		'                    },'+
		'                    {'+
		'                      "accountCommitment": 0,'+
		'                      "accountNumber": "string",'+
		'                      "dateClosed": "string",'+
		'                      "dateOpen": "string",'+
		'                      "accountType": "string",'+
		'                      "reportingMemberShortName": "string",'+
		'                      "ownershipIndicator": "string",'+
		'                      "debtType": "string",'+
		'                      "isUnsecured": true,'+
		'                      "accountExcluded": true,'+
		'                      "exclusionReason": "string",'+
		'                      "tenure": 0,'+
		'                      "roi": 0,'+
		'                      "highCreditOrSanctionedAmount": 0,'+
		'                      "currentBalance": 0,'+
		'                      "paymentHistory1": "string",'+
		'                      "paymentHistory2": "string",'+
		'                      "emiAmount": 0,'+
		'                      "imputedeEMIAmount": 0'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              }'+
		'            }'+
		'          ],'+
		'          "product": ['+
		'            {'+
		'              "productType": "PL",'+
		'              "productCode": "0256",'+
		'              "subProductType": "string",'+
		'              "requestedLoanAmount": 600000,'+
		'              "productDecision": {'+
		'                "productDecision": "STP",'+
		'                "isAppliedPromoCode": false,'+
		'                "promoStartDate": "string",'+
		'                "promoEndDate": "string",'+
		'                "calculatedVariables": ['+
		'                  {'+
		'                    "fieldName": "IS_DEDEUPE_FOUND",'+
		'                    "fieldType": "Boolean",'+
		'                    "fieldValue": "false",'+
		'                    "varCategory": "GST"'+
		'                  },'+
		'                  {'+
		'                    "fieldName": "string",'+
		'                    "fieldType": "string",'+
		'                    "fieldValue": "string",'+
		'                    "varCategory": "BSA"'+
		'                  }'+
		'                ],'+
		'                "offerData": {'+
		'                  "maxEligibleLoanAmount": 850000,'+
		'                  "maxFOIR": 85,'+
		'                  "minTenure": 12,'+
		'                  "maxTenure": 36,'+
		'                  "roi": 11.5,'+
		'                  "roiGrid": ['+
		'                    {'+
		'                      "minLoanAmount": 0,'+
		'                      "maxLoanAmount": 199999,'+
		'                      "roi": 12.25'+
		'                    },'+
		'                    {'+
		'                      "minLoanAmount": 200000,'+
		'                      "maxLoanAmount": 850000,'+
		'                      "roi": 11.25'+
		'                    }'+
		'                  ],'+
		'                  "stampDutyGrid": ['+
		'                    {'+
		'                      "minLoanAmount": 0,'+
		'                      "maxLoanAmount": 199999,'+
		'                      "stampDutyRate": 4.25'+
		'                    },'+
		'                    {'+
		'                      "minLoanAmount": 200000,'+
		'                      "maxLoanAmount": 850000,'+
		'                      "stampDutyRate": 4.25'+
		'                    }'+
		'                  ],'+
		'                  "pfGrid": ['+
		'                    {'+
		'                      "minLoanAmount": 0,'+
		'                      "maxLoanAmount": 199999,'+
		'                      "processingFeesRate": 3'+
		'                    },'+
		'                    {'+
		'                      "minLoanAmount": 200000,'+
		'                      "maxLoanAmount": 850000,'+
		'                      "processingFeesRate": 2.5'+
		'                    }'+
		'                  ],'+
		'                  "loanAmountTenureGrid": ['+
		'                    {'+
		'                      "minLoanAmount": 0,'+
		'                      "maxLoanAmount": 499999,'+
		'                      "maxTenure": 36'+
		'                    },'+
		'                    {'+
		'                      "minLoanAmount": 500000,'+
		'                      "maxLoanAmount": 850000,'+
		'                      "maxTenure": 48'+
		'                    }'+
		'                  ]'+
		'                }'+
		'              }'+
		'            }'+
		'          ],'+
		'          "randomNumber": 0,'+
		'          "applicationDecision": {'+
		'            "systemDecision": "STP",'+
		'            "systemDecisionDate": "2024-05-24T06:32:36.163Z",'+
		'            "strategyUsed": "Champion",'+
		'            "calculatedVariables": ['+
		'              {'+
		'                "fieldName": "MAX_TENURE",'+
		'                "fieldType": "Integer",'+
		'                "fieldValue": "36",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "SCORE_BASED_MULTIPLIER",'+
		'                "fieldType": "Real",'+
		'                "fieldValue": "0.5",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "AVG_TOTAL_MONTHLY_NET_CREDIT_L6M",'+
		'                "fieldType": "Real",'+
		'                "fieldValue": "350000",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "SERVICEABLE_EMI",'+
		'                "fieldType": "Real",'+
		'                "fieldValue": "2500",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "FOIR_MAX_TENURE",'+
		'                "fieldType": "Integer",'+
		'                "fieldValue": "36",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "FOIR_IRR",'+
		'                "fieldType": "Float",'+
		'                "fieldValue": "65",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "FINAL_ELIGIBILITY",'+
		'                "fieldType": "Float",'+
		'                "fieldValue": "",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "MAX_LOAN_CAPPING",'+
		'                "fieldType": "Float",'+
		'                "fieldValue": "",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "MAX_ALLOWED_EMI",'+
		'                "fieldType": "Float",'+
		'                "fieldValue": "",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "MAX_FOIR",'+
		'                "fieldType": "Float",'+
		'                "fieldValue": "",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "FOIR_BASED_ELIGIBILITY",'+
		'                "fieldType": "Float",'+
		'                "fieldValue": "",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "MULTIPLIER_BASED_ELIGIBILITY_APPLICATION",'+
		'                "fieldType": "Float",'+
		'                "fieldValue": "",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "DEEMED_MONTHLY_AVG_CREDIT",'+
		'                "fieldType": "Float",'+
		'                "fieldValue": "",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "TOTAL_EXISTING_OBLIGATION",'+
		'                "fieldType": "Float",'+
		'                "fieldValue": "",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "TOTAL_NET_TAKE_HOME",'+
		'                "fieldType": "Float",'+
		'                "fieldValue": "",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "TOTAL_NET_MONTHLY_INCOME",'+
		'                "fieldType": "Float",'+
		'                "fieldValue": "",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "TOTAL_ANNUAL_TURNOVER",'+
		'                "fieldType": "Float",'+
		'                "fieldValue": "",'+
		'                "varCategory": "BSA"'+
		'              },'+
		'              {'+
		'                "fieldName": "IS_KNOCKED_OUT",'+
		'                "fieldType": "Boolean",'+
		'                "fieldValue": "true",'+
		'                "varCategory": "BSA"'+
		'              }'+
		'            ],'+
		'            "ruleAudits": ['+
		'              {'+
		'                "metaphorName": "FN_PrePrcoessing",'+
		'                "ruleId": "",'+
		'                "ruleName": "",'+
		'                "timeStamp": "2024-05-24T06:32:36.163Z"'+
		'              },'+
		'              {'+
		'                "metaphorName": "FN_ProductPreProcessing",'+
		'                "ruleId": "",'+
		'                "ruleName": "",'+
		'                "timeStamp": "2024-05-24T06:32:36.163Z"'+
		'              },'+
		'              {'+
		'                "metaphorName": "FN_ApplicantionInitializations",'+
		'                "ruleId": "",'+
		'                "ruleName": "",'+
		'                "timeStamp": "2024-05-24T06:32:36.163Z"'+
		'              },'+
		'              {'+
		'                "metaphorName": "FN_ApplicantInitializations",'+
		'                "ruleId": "",'+
		'                "ruleName": "",'+
		'                "timeStamp": "2024-05-24T06:32:36.163Z"'+
		'              },'+
		'              {'+
		'                "metaphorName": "FN_ApplicantDerivationsCommon",'+
		'                "ruleId": "",'+
		'                "ruleName": "",'+
		'                "timeStamp": "2024-05-24T06:32:36.163Z"'+
		'              },'+
		'              {'+
		'                "metaphorName": "DFLow_Income",'+
		'                "ruleId": "",'+
		'                "ruleName": "",'+
		'                "timeStamp": "2024-05-24T06:32:36.163Z"'+
		'              },'+
		'              {'+
		'                "metaphorName": "FN_SalariedScorecardCharactersticsDerivation",'+
		'                "ruleId": "",'+
		'                "ruleName": "",'+
		'                "timeStamp": "2024-05-24T06:32:36.163Z"'+
		'              },'+
		'              {'+
		'                "metaphorName": "FN_DeriveNetIncomeAndTurnover",'+
		'                "ruleId": "",'+
		'                "ruleName": "",'+
		'                "timeStamp": "2024-05-24T06:32:36.163Z"'+
		'              },'+
		'              {'+
		'                "metaphorName": "RS_PostBureauKnockoutRules",'+
		'                "ruleId": "",'+
		'                "ruleName": "",'+
		'                "timeStamp": "2024-05-24T06:32:36.163Z"'+
		'              },'+
		'              {'+
		'                "metaphorName": "RS_PostBureauKnockoutRules",'+
		'                "ruleId": "APPLICATION_SCORE_CHECK_SELF",'+
		'                "ruleName": "RS_PostBureauKnockoutRules",'+
		'                "timeStamp": "2024-05-24T06:32:36.163Z"'+
		'              },'+
		'              {'+
		'                "metaphorName": "FN_KnockOutDecision",'+
		'                "ruleId": "",'+
		'                "ruleName": "",'+
		'                "timeStamp": "2024-05-24T06:32:36.163Z"'+
		'              },'+
		'              {'+
		'                "metaphorName": "FN_PostPrcoessing",'+
		'                "ruleId": "",'+
		'                "ruleName": "",'+
		'                "timeStamp": "2024-05-24T06:32:36.163Z"'+
		'              }'+
		'            ]'+
		'          }'+
		'        },'+
		'        "callType": "DP_KNOCKOUT",'+
		'        "decisionService": "DS_PL",'+
		'        "requestTime": "Apr 25, 2024 01:53:01.724 PM IST",'+
		'        "callingSystem": "DIY"'+
		'      }'+
		'    },'+
		'    "status": "SUCCESS"'+
		'  }'+
		'}';
        return json;
    }*/
}