/**
 * @author        Mohit M.
 * @date          18-June-2024
 * @description   Class will contains all the mock response and use in test class
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
    --------------------------------------------------------------------------------------------
    Mohit M.              18-June-2024    Initial Version
     */
public with sharing class AUSF_IntegrationMockResponse implements HttpCalloutMock {
    String strStatusCode = '200';
    String strstatusCodeApi = '101';
    String body = '';
    Integer StatusCode = 200;
    String strStatusApi;
    
    public AUSF_IntegrationMockResponse(){}
    
    public AUSF_IntegrationMockResponse (String strStatusCode , String strstatusCodeApi) {
        this.strStatusCode = strStatusCode;
        this.strstatusCodeApi = strstatusCodeApi;
    }
    public AUSF_IntegrationMockResponse (String strStatusCode,String strstatusCodeApi,String strStatusApi) {
        this.strStatusCode = strStatusCode;
        this.strstatusCodeApi = strstatusCodeApi;
        this.strStatusApi = strStatusApi;
    }
    public AUSF_IntegrationMockResponse(String bodyData , Integer code){
        body = String.isNotBlank(bodyData) ? bodyData : '';
        StatusCode = code !=NULL ? code : StatusCode ;
    }
    
    public HTTPResponse respond(HTTPRequest req) {
        String responseHardcoded;
        HTTPResponse res = new HTTPResponse();
        if(String.isNotBlank(body)){
            res.setStatusCode(StatusCode);
            res.setHeader('Content-Type', 'application/json');
            res.setBody(body);
            return res;
        }
        if (req.getEndpoint().endsWith('/PANDoBStatusService/PANDoBStatus')) {
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                // add the response here
                if(strstatusCodeApi=='101'){
                    responseHardcoded = '{"result":{"dob":"1999-03-03","name":"PRADEEP SHARMA","status":"Active"},"requestId":"4b9863e3-a34d-4ba8-aad8-15b614fa84ae","clientData":{"caseId":null},"statusCode":101}';
                }
                else if(strstatusCodeApi=='102'){
                    responseHardcoded = '{"result":{},"requestId":"b66fe81f-9942-4994-b2fa-6da3d52e9dcb","clientData":{"caseId":null},"statusMessage":"Invalid Input","statusCode":102}';
                }
                res.setStatusCode(200);
            }
            else if (strStatusCode == '201') {
                responseHardcoded = '{"result":{},"requestId":"b66fe81f-9942-4994-b2fa-6da3d52e9dcb","clientData":{"caseId":null},"statusMessage":"Invalid Input","statusCode":102}';
                res.setStatusCode(201);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        else  if (req.getEndpoint().endsWith('/CBSLoanAccountDrawdownInstMntService/LoanAccountDrawDown')) {
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                // add the response here
                if(strstatusCodeApi=='0'){
                    responseHardcoded = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":[{"code":0,"message":null}]}}}';
                }
                else if(strstatusCodeApi=='99'){
                    responseHardcoded = '{"TransactionStatus":{"ResponseCode":"99","ResponseMessage":"Failure","ExtendedErrorDetails":{"messages":[{"code":99,"message":"Invalid account number"}]}}}';
                }
                res.setStatusCode(200);
            }
            else if (strStatusCode == '201') {
                responseHardcoded = '{"result":{},"requestId":"b66fe81f-9942-4994-b2fa-6da3d52e9dcb","clientData":{"caseId":null},"statusMessage":"Invalid Input","statusCode":102}';
                res.setStatusCode(201);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        else if (req.getEndpoint().endsWith('/OTPEngineRestService/generateOTP')) {
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                // add the response here
                if(strstatusCodeApi=='100'){
                    responseHardcoded = '{"StatusDesc":"The Otp is generated successfully","CustRef":"SFDCDEV023c4b15cae2f64dea73454b3","StatusCode":100,"RequestStatus":"Success"}';
                }
                else if(strstatusCodeApi=='110'){
                    responseHardcoded = '{"result":{},"requestId":"b66fe81f-9942-4994-b2fa-6da3d52e9dcb","clientData":{"caseId":null},"statusMessage":"Invalid Input","statusCode":102}';
                }
                res.setStatusCode(200);
            }
            else if (strStatusCode == '110') {
                responseHardcoded = '{"result":{},"requestId":"b66fe81f-9942-4994-b2fa-6da3d52e9dcb","clientData":{"caseId":null},"statusMessage":"Invalid Input","statusCode":102}';
                res.setStatusCode(110);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        else if (req.getEndpoint().endsWith('/OTPEngineRestService/resendOTP')) {
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strstatusCodeApi=='100'){
                    responseHardcoded = '{"StatusDesc":"The Otp is generated successfully","CustRef":"SFDCDEV023c4b15cae2f64dea73454b3","StatusCode":100,"RequestStatus":"Success"}';
                }
                else if(strstatusCodeApi=='110'){
                    responseHardcoded = '{"result":{},"requestId":"b66fe81f-9942-4994-b2fa-6da3d52e9dcb","clientData":{"caseId":null},"statusMessage":"Invalid Input","statusCode":102}';
                }
                res.setStatusCode(200);
            }
            else if (strStatusCode == '110') {
                responseHardcoded = '{"result":{},"requestId":"b66fe81f-9942-4994-b2fa-6da3d52e9dcb","clientData":{"caseId":null},"statusMessage":"Invalid Input","statusCode":102}';
                res.setStatusCode(110);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        else if (req.getEndpoint().endsWith('/OTPEngineRestService/validateOTP')) {
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strstatusCodeApi=='100'){
                    responseHardcoded = '{"StatusDesc":"OTP Verified successfully","CustRef":"SFDCPRODb2f847355bc821bef250afea4","StatusCode":100,"RequestStatus":"Success"}';
                }
                else if(strstatusCodeApi=='102'){
                    responseHardcoded = '{"result":{},"requestId":"b66fe81f-9942-4994-b2fa-6da3d52e9dcb","clientData":{"caseId":null},"statusMessage":"Invalid Input","statusCode":102}';
                }
                res.setStatusCode(200);
            }
            else if (strStatusCode == '110') {
                responseHardcoded = '{"result":{},"requestId":"b66fe81f-9942-4994-b2fa-6da3d52e9dcb","clientData":{"caseId":null},"statusMessage":"Invalid Input","statusCode":102}';
                res.setStatusCode(110);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        else if (req.getEndpoint().endsWith('/TransunionVerifyService/emailVerification')){
            if (strStatusCode == '200') {
                if (strStatusCode == '200' && strstatusCodeApi == '50') {
                    res.setBody('{"Status":"Success","ResponseInfo":{"ApplicationId":40439475,"SolutionSetInstanceId":"3c24db16-2f00-404a-8127-f785a74e5fcb"},"Fields":{"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Pass","Id":"","Operations":{"Operation":[{"Status":"Pass","Data":{"Response":{"RawResponse":"{\\"eam\\":{\\"longevity\\":3,\\"velocity\\":0,\\"date_first_seen\\":\\"2020-05-03\\",\\"popularity\\":0},\\"email_validation\\":{\\"domain_type\\":\\"freeisp\\",\\"status_code\\":50,\\"address\\":\\"knitesh970@gmail.com\\",\\"status\\":\\"valid\\"}}"}},"Id":"","Name":"EmailVerification"}]},"Name":"EmailVerification"}]},"ApplicantIdentifier":"7afb6799-3152-4609-bde4-24a7fa606e31","EmailAddress":"knitesh970@gmail.com"}},"ApplicationData":{"Services":{"Service":{"Consent":true,"Skip":"N","Id":"","Name":"EmailVerification"}}},"ApplicationId":"40439475","Decision":"Pass"}}');
                } else {
                    res.setBody('{"Status":"Fail","ResponseInfo":{"ApplicationId":40439475,"SolutionSetInstanceId":"3c24db16-2f00-404a-8127-f785a74e5fcb"},"Fields":{"Applicants":{"Applicant":{"Services":{"Service":[{"Status":"Fail","Id":"","Operations":{"Operation":[{"Status":"Fail","Data":{"Response":{"RawResponse":"{\\"eam\\":{\\"longevity\\":3,\\"velocity\\":0,\\"date_first_seen\\":\\"2020-05-03\\",\\"popularity\\":0},\\"email_validation\\":{\\"domain_type\\":\\"freeisp\\",\\"status_code\\":'+strstatusCodeApi+',\\"address\\":\\"knitesh970@gmail.com\\",\\"status\\":\\"invalid\\"}}"}},"Id":"","Name":"EmailVerification"}]},"Name":"EmailVerification"}]},"ApplicantIdentifier":"7afb6799-3152-4609-bde4-24a7fa606e31","EmailAddress":"knitesh970@gmail.com"}},"ApplicationData":{"Services":{"Service":{"Consent":true,"Skip":"N","Id":"","Name":"EmailVerification"}}},"ApplicationId":"40439475","Decision":"Fail"}}');
                }
                res.setStatusCode(Integer.valueOf(strStatusCode));
            }
            return res;
        }
        else if (req.getEndpoint().endsWith('/sfdccbs/SFDCCustomerRestService/SearchCustomer')){
            if (strStatusCode == '200') {
                // add the response here
                if(strstatusCodeApi=='0'){
                    responseHardcoded = '{ "TransactionStatus": { "ResponseCode": "0", "ResponseMessage": "Success", "ExtendedErrorDetails": { "messages": { "code": "0", "message": null } }, "ValidationErrors": { "ApplicableAttributes": null, "AttributeName": null, "AttributeValue": null, "ErrorCode": null, "ErrorMessage": null } }, "MatchFound": [ { "CustomerResponse": { "CustomerMemo": null, "CustomerBasicInquiry": { "CustomerId": "21314552", "NationalIdentificationCode": "21314552", "CustomerName": { "Prefix": "MR.", "FirstName": "IFRAN", "MidName": null, "LastName": "KHAN", "ShortName": "IFRAN Khan", "SingleFullName": null, "FormattedFullName": "IFRAN##KHAN", "FullName": "IFRAN KHAN" }, "CustomerFullName": "IFRAN KHAN", "OfficerID": null, "CustomerAddress": { "Line1": "5th floor", "Line2": "Kanakia Zillon", "Line3": "BKC Kurla West", "Line4": null, "City": "MUMBAI", "State": "MAHARASHTRA", "Country": "India", "Zip": "400070" }, "BirthDateText": "1984-06-07", "CategoryType": "INDIVIDUAL - FULL KYC", "Sex": "M", "IsImageAvailable": "false", "IsSignatureAvailable": "true", "CombWithdrawBal": null, "AgeOfCustRel": "2017-09-28", "AadhaarDetail": { "AadhaarNumber": "21314552", "AadhaarLinkAccount": null }, "HomeBranch": "2276", "MobileNumber": "8104655801", "EmailAddress": "21314552@axc.com", "IcType": null, "IcTypeDesc": null, "BankShortName": "Jalore_Bagoda Road", "PAN": "ABCDE3333R", "CustomerType": "100", "AadharUpdateDate": null } }, "CRMQueryResults": [ { "BankName": null, "Scheme": null, "Avail": "No", "off_ex1_8": null, "ProductId": 11704, "OfferType": null, "OfferId": "726882", "RatingID": 1, "ValidFrom": "2023-06-26T00:00:00+05:30", "OfferDescription": "Savings Account - AU Royale", "Royale": null, "MinLoanTenureinMonths": "6", "CustomerNameinBankAccount": null, "CustomerId": "22143391", "OfferIsActive": "true", "RepaymentMode": null, "Mobile": "9988774410", "CurrencyID": null, "MaxLoanTenureinMonths": "48", "OfferName": "Savings Account - AU Royale", "Occupation": null, "IFSCcode": null, "RowNumber": 1, "FirstOfferAmount": 300000, "Employee": null, "BankBranch": null, "ValidTill": "2025-06-27T23:59:00+05:30", "Image_Offers": "plbanner", "TermsAndCondition": null, "RateofInterest": "16.000000", "Location": null } ], "CreditCardResponse": [ { "CustomerID": "2233XXXX", "CustomerAccountRelation": "Sole Owner", "AccountNumber": "0001691XXXXXXXXXXXX", "LoanStatus": "PA", "CustomerFullName": "AKASH G", "ProductCode": "101", "Decode": "ALTURA", "AccountOpenDate": "2021-01-20 00:00:00", "AccountStatus": "ACCOUNT OPEN REGULAR", "SanctionedAmount": "50000", "DPDValue": "0", "LastStatementBalance": "8,692.67" } ], "NPADPD": [ { "GrossAdvance": 66469, "Last30DaysUpg": "", "ACID": "", "Filler_3": "", "UCIF": "25200586", "Date": "27-04-2024", "NPAStatus": "N", "Filler_2": "", "Filler_1": "", "NPADate": null, "CustID": "", "IsTWO": "N", "DPD": 0, "AssetClass": "STANDARD", "OriginalProduct": "", "TotalProvision": 265.88 }, { "GrossAdvance": 66469, "Last30DaysUpg": "", "ACID": "9001010635460038", "Filler_3": "", "UCIF": "25200586", "Date": "27-04-2024", "NPAStatus": "N", "Filler_2": "", "Filler_1": "", "NPADate": null, "CustID": "25200586", "IsTWO": "N", "DPD": 0, "AssetClass": "STANDARD", "OriginalProduct": "A_WHEELS", "TotalProvision": 265.88 } ], "AccountDetails": { "CustomerAccount": [ { "ModuleCode": "C", "ProductName": "20101-AU Savings Account - Value", "AccountId": "1711227610089667", "CASAAccountName": null, "CurrencyCode": "1", "CurrencyShortName": "INR", "CustomerRelationship": "SOW", "BalanceBook": "99.00", "UnclearFunds": "0.00", "Classification": "NORMAL", "Reason": "UNBLOCKED ", "BillAmount": "0.00", "OriginalBalance": "0.00", "CurrentStatus": "8", "CurrentStatusDescription": "ACCOUNT OPEN REGULAR", "AcyAmount": "699.00", "AvailableBalance": "699.00", "LcyAmount": "699.00", "TotalAcyAmount": "699.00", "TotalLcyAmount": "699.00", "BranchName": "Jalore_Bagoda Road", "ExternalAccountId": "0", "LoanApplicationNumber": null, "FutureDatedAmount": "0.00", "SafeDepositBoxId": "0", "Iban": "0", "DateAccountOpen": "2017-09-28", "DateAccountActive": null, "DateRelation": "2017-09-28", "MonthsSinceActive": "47", "BalUncollectedPrinc": "0.00", "BalUncollectedInt": "0.00", "TotalBalUncollecPrinc": "0.00", "TotalBalUncollecInt": "0.00", "TotalBalBook": "99.00", "DateValue": "2017-05-04", "BalPrincipal": "0", "IntRate": "0", "DepositNo": null, "MaturityDate": null, "LienAmount": "0", "InstallmentAmount": "0", "OtherArrear": "0", "DepositStatus": null, "BalCombinedAcy": "699.0", "BalCombinedLcy": "699.0", "BranchCode": "2276", "IsMaturity": null, "IsTDLinkage": "N ", "MaturityAmount": null, "DepStat": null, "DisbursedAmount": null, "DraweeAccountNo": null, "EmailId": null, "EmiTenure": null, "HoldAmount": "0", "LoanAccountName": null, "MobileNumber": null, "NomineeName": "PRAVEENA BANU", "ODLimitSactioned": "0", "ODLimitUtilized": "0", "OperationMode": "SINGLYnull", "SmallClearingAccountNo": "000207", "TDAccountName": null, "CASARelationshipDetails": { "CustomerId": "21314552", "Emailid": "21314552@axc.com", "JointHolderName": "IFRAN KHAN", "MobileNo": "8104655801", "Relationship": "SOW" }, "AmtGoal": "0", "AmtGoalNew": null, "CodAcctCcy": null, "CodAcctNo": null, "CodGoalAcctStat": null, "CodGoalAcctXfer": null, "CodGoalAcctXferTitle": null, "CodGoalName": null, "CodGoalRefNo": null, "CtrGoalTermDays": null, "CtrGoalTermDaysNew": null, "CtrGoalTermMon": null, "CtrGoalTermMonNew": null, "CtrGoalTermYear": null, "CtrGoalTermYearNew": null, "DatMaturityNew": null, "ProductCode": "20101", "RatGoalInt": null, "Tenure": "0 Months 0 Days 0 Years " }, { "ModuleCode": "L", "ProductName": "12004-Securitization and Assignment", "AccountId": "9001020101389851", "CASAAccountName": null, "CurrencyCode": "1", "CurrencyShortName": "INR", "CustomerRelationship": "SOW", "BalanceBook": "0.00", "UnclearFunds": "0.00", "Classification": "NORMAL", "Reason": " ", "BillAmount": "0.00", "OriginalBalance": "390000.00", "CurrentStatus": "1", "CurrentStatusDescription": "ACCOUNT CLOSED", "AcyAmount": "0.00", "AvailableBalance": "0.00", "LcyAmount": "0.00", "TotalAcyAmount": "0.00", "TotalLcyAmount": "0.00", "BranchName": "Jalore_Bagoda Road", "ExternalAccountId": null, "LoanApplicationNumber": "9001020101389851 ", "FutureDatedAmount": "0.00", "SafeDepositBoxId": "0", "Iban": null, "DateAccountOpen": "2014-12-25", "DateAccountActive": null, "DateRelation": null, "MonthsSinceActive": "0", "BalUncollectedPrinc": "0.00", "BalUncollectedInt": "0.00", "TotalBalUncollecPrinc": "0.00", "TotalBalUncollecInt": "0.00", "TotalBalBook": "0.00", "DateValue": null, "BalPrincipal": "0", "IntRate": "0", "DepositNo": null, "MaturityDate": "2017-11-23", "LienAmount": "0", "InstallmentAmount": "0", "OtherArrear": "0", "DepositStatus": null, "BalCombinedAcy": "0.0", "BalCombinedLcy": "0.0", "BranchCode": "2276", "IsMaturity": null, "IsTDLinkage": "N ", "MaturityAmount": null, "DepStat": null, "DisbursedAmount": "390000", "DraweeAccountNo": null, "EmailId": null, "EmiTenure": "35", "HoldAmount": null, "LoanAccountName": "IFRAN Khan", "MobileNumber": null, "NomineeName": null, "ODLimitSactioned": null, "ODLimitUtilized": null, "OperationMode": null, "SmallClearingAccountNo": null, "TDAccountName": null, "AmtGoal": "0", "AmtGoalNew": null, "CodAcctCcy": null, "CodAcctNo": null, "CodGoalAcctStat": null, "CodGoalAcctXfer": null, "CodGoalAcctXferTitle": null, "CodGoalName": null, "CodGoalRefNo": null, "CtrGoalTermDays": null, "CtrGoalTermDaysNew": null, "CtrGoalTermMon": null, "CtrGoalTermMonNew": null, "CtrGoalTermYear": null, "CtrGoalTermYearNew": null, "DatMaturityNew": null, "ProductCode": "12004", "RatGoalInt": null, "Tenure": "35 Months 0 Days 0 Years " } ] } }] }';
                }
                else if(strstatusCodeApi=='1'){
                    responseHardcoded = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":{"code":"0","message":null}},"ValidationErrors":{ "ApplicableAttributes":null,"AttributeName":null,"AttributeValue":null,"ErrorCode":null,"ErrorMessage":null}},"MatchFound":[{"CustomerResponse":{"CustomerMemo":null,"CustomerBasicInquiry":{"CustomerId":"21314552","NationalIdentificationCode":"21314552","CustomerName":{ "Prefix":"MR.","FirstName":"IFRAN","MidName":null,"LastName":"KHAN","ShortName":"IFRAN Khan","SingleFullName":null,"FormattedFullName":"IFRAN##KHAN","FullName":"IFRAN KHAN"},"CustomerFullName":"IFRAN KHAN","OfficerID":null,"CustomerAddress":{"Line1":"5th floor","Line2":"Kanakia Zillon","Line3":"BKC Kurla West","Line4":null,"City":"MUMBAI","State":"MAHARASHTRA","Country":"India","Zip":"400070"},"BirthDateText":"1984-06-07","CategoryType":"INDIVIDUAL - FULL KYC","Sex":"M","IsImageAvailable":"false","IsSignatureAvailable":"true","CombWithdrawBal":null,"AgeOfCustRel":"2017-09-28","AadhaarDetail":{"AadhaarNumber":"21314552","AadhaarLinkAccount":null},"HomeBranch":"2276","MobileNumber":"8104655801","EmailAddress":"21314552@axc.com","IcType":null,"IcTypeDesc":null,"BankShortName":"Jalore_Bagoda Road","PAN":"ABCDE3333R","CustomerType":"100","AadharUpdateDate":null}},"CRMQueryResults":[{"BankName":null,"Scheme":null,"Avail":"No","off_ex1_8":null,"ProductId":11704,"OfferType":null,"OfferId":"726882","RatingID": 1,"ValidFrom":"2023-06-26T00:00:00+05:30","OfferDescription":"Savings Account - AU Royale","Royale":null,"MinLoanTenureinMonths":"6","CustomerNameinBankAccount":null,"CustomerId":"22143391","OfferIsActive":"true","RepaymentMode":null,"Mobile":"9988774410","CurrencyID":null,"MaxLoanTenureinMonths":"48","OfferName":"Savings Account - AU Royale","Occupation":null,"IFSCcode":null,"RowNumber":1,"FirstOfferAmount":300000,"Employee":null,"BankBranch":null,"ValidTill":"2025-06-27T23:59:00+05:30","Image_Offers":"plbanner","TermsAndCondition":null,"RateofInterest":"16.000000","Location":null}],"CreditCardResponse":[{"CustomerID":"2233XXXX","CustomerAccountRelation":"Sole Owner","AccountNumber":"0001691XXXXXXXXXXXX","LoanStatus":"PA","CustomerFullName":"AKASH G","ProductCode":"101","Decode":"ALTURA","AccountOpenDate":"2021-01-20 00:00:00","AccountStatus":"ACCOUNT OPEN REGULAR","SanctionedAmount":"50000","DPDValue":"0","LastStatementBalance":"8,692.67"}],"NPADPD":[{"GrossAdvance":66469,"Last30DaysUpg":"","ACID":"","Filler_3":"","UCIF":"25200586","Date":"27-04-2024","NPAStatus":"N","Filler_2":"","Filler_1":"","NPADate":null,"CustID":"","IsTWO":"N","DPD":0,"AssetClass":"STANDARD","OriginalProduct":"","TotalProvision":265.88},{"GrossAdvance":66469,"Last30DaysUpg":"","ACID":"9001010635460038","Filler_3":"","UCIF":"25200586","Date":"27-04-2024","NPAStatus":"N","Filler_2":"","Filler_1":"","NPADate":null,"CustID":"25200586","IsTWO":"N","DPD":0,"AssetClass":"STANDARD","OriginalProduct":"A_WHEELS","TotalProvision":265.88}],"AccountDetails":{"CustomerAccount":[{"ModuleCode":"C","ProductName":"20101-AU Savings Account - Value","AccountId":"1711227610089667","CASAAccountName":null,"CurrencyCode":"1","CurrencyShortName":"INR","CustomerRelationship":"SOW","BalanceBook":"99.00","UnclearFunds":"0.00","Classification":"NORMAL","Reason":"UNBLOCKED","BillAmount":"0.00","OriginalBalance":"0.00","CurrentStatus":"8","CurrentStatusDescription":"ACCOUNT OPEN REGULAR","AcyAmount":"699.00","AvailableBalance":"699.00","LcyAmount":"699.00","TotalAcyAmount":"699.00","TotalLcyAmount":"699.00","BranchName":"Jalore_Bagoda Road","ExternalAccountId":"0","LoanApplicationNumber":null,"FutureDatedAmount":"0.00","SafeDepositBoxId":"0","Iban":"0","DateAccountOpen":"2017-09-28","DateAccountActive":null,"DateRelation":"2017-09-28","MonthsSinceActive":"47","BalUncollectedPrinc":"0.00","BalUncollectedInt":"0.00","TotalBalUncollecPrinc":"0.00","TotalBalUncollecInt":"0.00","TotalBalBook":"99.00","DateValue":"2017-05-04","BalPrincipal":"0","IntRate":"0","DepositNo":null,"MaturityDate":null,"LienAmount":"0","InstallmentAmount":"0","OtherArrear":"0","DepositStatus":null,"BalCombinedAcy":"699.0","BalCombinedLcy":"699.0","BranchCode":"2276","IsMaturity":null,"IsTDLinkage":"N","MaturityAmount":null,"DepStat":null,"DisbursedAmount":null,"DraweeAccountNo":null,"EmailId":null,"EmiTenure":null,"HoldAmount":"0","LoanAccountName":null,"MobileNumber":null,"NomineeName":"PRAVEENA BANU","ODLimitSactioned":"0","ODLimitUtilized":"0","OperationMode":"SINGLYnull","SmallClearingAccountNo":"000207","TDAccountName":null,"CASARelationshipDetails":{"CustomerId":"21314552","Emailid":"21314552@axc.com","JointHolderName":"IFRAN KHAN","MobileNo":"8104655801","Relationship":"SOW"},"AmtGoal":"0","AmtGoalNew":null,"CodAcctCcy":null,"CodAcctNo":null,"CodGoalAcctStat":null,"CodGoalAcctXfer":null,"CodGoalAcctXferTitle":null,"CodGoalName":null,"CodGoalRefNo":null,"CtrGoalTermDays":null,"CtrGoalTermDaysNew":null,"CtrGoalTermMon":null,"CtrGoalTermMonNew":null,"CtrGoalTermYear":null,"CtrGoalTermYearNew":null,"DatMaturityNew":null,"ProductCode":"20101","RatGoalInt":null,"Tenure":"0 Months 0 Days 0 Years"},{"ModuleCode":"L","ProductName":"12004-Securitization and Assignment","AccountId":"9001020101389851","CASAAccountName":null,"CurrencyCode":"1","CurrencyShortName":"INR","CustomerRelationship":"SOW","BalanceBook":"0.00","UnclearFunds":"0.00","Classification":"NORMAL","Reason":" ","BillAmount":"0.00","OriginalBalance":"390000.00","CurrentStatus":"1","CurrentStatusDescription":"ACCOUNT CLOSED","AcyAmount":"0.00","AvailableBalance":"0.00","LcyAmount":"0.00","TotalAcyAmount":"0.00","TotalLcyAmount":"0.00","BranchName":"Jalore_Bagoda Road","ExternalAccountId":null,"LoanApplicationNumber":"9001020101389851","FutureDatedAmount":"0.00","SafeDepositBoxId":"0","Iban":null,"DateAccountOpen":"2014-12-25","DateAccountActive":null,"DateRelation":null,"MonthsSinceActive":"0","BalUncollectedPrinc":"0.00","BalUncollectedInt":"0.00","TotalBalUncollecPrinc":"0.00","TotalBalUncollecInt":"0.00","TotalBalBook":"0.00","DateValue":null,"BalPrincipal":"0","IntRate":"0","DepositNo":null,"MaturityDate":"2017-11-23","LienAmount":"0","InstallmentAmount":"0","OtherArrear":"0","DepositStatus":null,"BalCombinedAcy":"0.0","BalCombinedLcy":"0.0","BranchCode":"2276","IsMaturity":null,"IsTDLinkage":"N","MaturityAmount":null,"DepStat":null,"DisbursedAmount":"390000","DraweeAccountNo":null,"EmailId":null,"EmiTenure":"35","HoldAmount":null,"LoanAccountName":"IFRAN Khan","MobileNumber":null,"NomineeName":null,"ODLimitSactioned":null,"ODLimitUtilized":null,"OperationMode":null,"SmallClearingAccountNo":null,"TDAccountName":null,"AmtGoal":"0","AmtGoalNew":null,"CodAcctCcy":null,"CodAcctNo":null,"CodGoalAcctStat":null,"CodGoalAcctXfer":null,"CodGoalAcctXferTitle":null,"CodGoalName":null,"CodGoalRefNo":null,"CtrGoalTermDays":null,"CtrGoalTermDaysNew":null,"CtrGoalTermMon":null,"CtrGoalTermMonNew":null,"CtrGoalTermYear":null,"CtrGoalTermYearNew":null,"DatMaturityNew":null,"ProductCode":"12004","RatGoalInt":null,"Tenure":"35 Months 0 Days 0 Years "}]}}]}';
                }
                res.setStatusCode(200);
            }
            else if (strStatusCode == '400') {
                responseHardcoded = '{"result":{},"requestId":"b66fe81f-9942-4994-b2fa-6da3d52e9dcb","clientData":{"caseId":null},"statusMessage":"Invalid Input","statusCode":102}';
                res.setStatusCode(400);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        else if(req.getEndpoint().contains('/sfdckyc/Karza/ebill?')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strStatusCode == '200' && strstatusCodeApi == '101'){
                    responseHardcoded = '{ "result": { "bill_no": "", "bill_due_date": "", "consumer_number": "3002497191", "bill_amount": "", "bill_issue_date": "", "mobile_number": "62XXXXX423", "amount_payable": "", "total_amount": "", "address": "", "consumer_name": "BALKAR SINGH", "email_address": "", "bill_date": "" }, "request_id": "ebcdad52-307e-407b-9701-8a87113f423f", "status-code": "101" }';
                }
                else if(strstatusCodeApi =='102'){
                    responseHardcoded = '{ "result": { "bill_no": "", "bill_due_date": "", "consumer_number": "3002497191", "bill_amount": "", "bill_issue_date": "", "mobile_number": "62XXXXX423", "amount_payable": "", "total_amount": "", "address": "", "consumer_name": "BALKAR SINGH", "email_address": "", "bill_date": "" }, "request_id": "ebcdad52-307e-407b-9701-8a87113f423f", "status-code": "101" }';
                }
                
                res.setStatusCode(200);
            }
            
            return res;
        }
        else if(req.getEndpoint().contains('/CRMOfferRestService/OfferUpdate')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strStatusCode == '200' && strstatusCodeApi == '0'){
                    responseHardcoded = '{ "TransactionStatus": { "ResponseCode": "0", "ResponseMessage": "Success", "ExtendedErrorDetails": { "messages": [ { "code": 0, "message": "Item has been updated successfully." } ] } }, "OfferId": "69876772" }';
                }
                else if(strstatusCodeApi =='99'){
                    responseHardcoded = '{ "TransactionStatus": { "ResponseCode": "0", "ResponseMessage": "Success", "ExtendedErrorDetails": { "messages": [ { "code": 99, "message": "Item has been updated successfully." } ] } }, "OfferId": "69876772" }';
                }
                res.setStatusCode(200);
            }
            
            return res;
        }
        else if(req.getEndpoint().contains('SFDCKarza/BankAccVerification?')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strstatusCodeApi == '101'){
                    responseHardcoded = '{ "result": { "accountNumber": "11111111111170", "ifsc": "UTIB0002118", "accountName": "T..... LA", "bankResponse": "Transaction Successful", "bankTxnStatus": true }, "request_id": "91d919e2-84dc-4838-8087-245526932a92", "status-code": "101" }';
                }
                else if(strstatusCodeApi =='102'){
                    responseHardcoded = '{ "result": { "accountNumber": "11111111111170", "ifsc": "UTIB0002118", "accountName": "T..... LA", "bankResponse": "Transaction Successful", "bankTxnStatus": true }, "request_id": "91d919e2-84dc-4838-8087-245526932a92", "status-code": "101" }';
                }
                res.setStatusCode(200);
            }
            
            return res;
        }
        else if(req.getEndpoint().contains('/LDAPLoginServiceV1/login')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                responseHardcoded = '{"return" : "true"}';
                res.setStatusCode(200);
                
            }
            else {
                responseHardcoded = '{"return" : "false"}';
                res.setStatusCode(201);
            }
            return res;
        }
        else if(req.getEndpoint().contains('/sfdckyc/Clari5RestAPIService/fraudCheck')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strStatusApi == 'success'){
                    responseHardcoded = '{"AML_ACTION":"Hold","ReferenceId":"SFDCDEV_e09f79792606911d03f3c2600","systemName":"PLSF","UserId":"SYS","BatchMode":"0","Refid":"LEAD-0000000001","MATCH":"NO","status":{"status":"success","errorDetails":""}}';
                }else{
                    responseHardcoded = '{"AML_ACTION":"Hold","ReferenceId":"SFDCDEV_e09f79792606911d03f3c2600","systemName":"PLSF","UserId":"SYS","BatchMode":"0","Refid":"LEAD-0000000001","MATCH":"NO","status":{"status":"error","errorDetails":""}}';
                }
                res.setStatusCode(200);
                
            }else if(strStatusCode == '400'){
                responseHardcoded = '{"AML_ACTION":"Approved","ReferenceId":"SFDCDEV_e09f79792606911d03f3c2600","systemName":"PLSF","UserId":"SYS","BatchMode":"0","Refid":"LEAD-0000000001","MATCH":"YES","status":{"status":"success","errorDetails":""}}';
                res.setStatusCode(400);
            }
            else {
                responseHardcoded = '{"return" : "false"}';
                res.setStatusCode(201);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        else if (req.getEndpoint().endsWith('/sfdckyc/KarzaService/NameMatch')) {
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strstatusCodeApi=='101'){
                    responseHardcoded = '{"requestId" : "34678hYYt","result" : {"score" : 0.0,"result" : true},"statusCode" : 101}';
                }
                else if(strstatusCodeApi=='201'){
                    responseHardcoded = '{"requestId" : "34678hYYt","result" : {"score" : 0.0,"result" : true},"statusCode" : 201}';
                }
                res.setStatusCode(200);
            }
            else if (strStatusCode == '400') {
                responseHardcoded = '{"requestId" : "34678hYYt","result" : {"score" : -1,"result" : true},"statusCode" : 201}';
                res.setStatusCode(400);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        if (req.getEndpoint().endsWith('/Service1.svc/CompressFiles')) {
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                // add the response here
                if(strstatusCodeApi=='ADS00'){
                    responseHardcoded = '{"Code":"ADS00","OutputFileBase64string":"JVBERi0xLjUNCiXipbmVhcml6ZWQgMQ0KL0wgMTc3NTMNCi9IIFsgODwMTE5OTBhYTUyZGJkMjEyODdmYWE3Mj5dDQo+Pg0Kc3RhcnR4cmVmDQoxNzgNCiUlRU9GDQo=","OutputStatus":"File Successfully Compressed"}';
                }
                else if(strstatusCodeApi=='ADS05'){
                    responseHardcoded = '{"Code":"ADS05","OutputFileBase64string":"JVBERi0xLjUNCiXipbmVhcml6ZWQgMQ0KL0wgMTc3NTMNCi9IIFsgODwMTE5OTBhYTUyZGJkMjEyODdmYWE3Mj5dDQo+Pg0Kc3RhcnR4cmVmDQoxNzgNCiUlRU9GDQo=","OutputStatus":"Compression Not Supported."}';
                }
                else if(strstatusCodeApi==''){
                    responseHardcoded = '{"Code":"ADS01","OutputFileBase64string":"JVBERi0xLjUNCiXipbmVhcml6ZWQgMQ0KL0wgMTc3NTMNCi9IIFsgODwMTE5OTBhYTUyZGJkMjEyODdmYWE3Mj5dDQo+Pg0Kc3RhcnR4cmVmDQoxNzgNCiUlRU9GDQo=","OutputStatus":"Compression Not Supported."}';
                }
                res.setStatusCode(200);
            }
            else if (strStatusCode == '400') {
                responseHardcoded = 'Internal server Error';
                res.setStatusCode(400);
            }
            res.setBody(responseHardcoded);
            return res;
        }else if(req.getEndpoint().contains('/sfdc/CommunicationRestService/sendSMS')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                responseHardcoded = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":{"code":"0","message":"7976335481 : APP-TESTAXIOM6-1721024462430-656-DC0101 : Success"}}}}';
                res.setStatusCode(200);
            }else if(strStatusCode == '400'){
                responseHardcoded = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":{"code":"0","message":"7976335481 : APP-TESTAXIOM6-1721024462430-656-DC0101 : Success"}}}}';
                res.setStatusCode(400);
            }
            else {
                responseHardcoded = '{"return" : "false"}';
                res.setStatusCode(201);
            }
            res.setBody(responseHardcoded);
            return res;
        }else if(req.getEndpoint().contains('/sfdc/CommunicationRestService/mail')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                responseHardcoded = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":{"code":"0","message":"Email Request has been Acknowledged"}}}}';
                res.setStatusCode(200);
            }else if(strStatusCode == '400'){
                responseHardcoded = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success","ExtendedErrorDetails":{"messages":{"code":"0","message":"Email Request has been Acknowledged"}}}}';
                res.setStatusCode(400);
            }
            else {
                responseHardcoded = '{"return" : "false"}';
                res.setStatusCode(201);
            }
            res.setBody(responseHardcoded);
            return res;
        }else if(req.getEndpoint().contains('/sfdc/WhatsappCongoService/SingleEvent')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                responseHardcoded = '{"status_message":"success","recepient_id":"gBEGkZgzaUc0AgmkicwgsH8l2Cw","status":200}';
                res.setStatusCode(200);
            }else if(strStatusCode == '400'){
                responseHardcoded = '{"status_message":"success","recepient_id":"gBEGkZgzaUc0AgmkicwgsH8l2Cw","status":400}';
                res.setStatusCode(400);
            }
            else {
                responseHardcoded = '{"return" : "false"}';
                res.setStatusCode(201);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        else if(req.getEndpoint().contains('/sfdckyc/HunterRestService/Check')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strstatusCodeApi=='0'){
                    responseHardcoded = '{"TransactionStatus":{"ResponseCode":"0","ResponseMessage":"Success"},"MatchSummary":{"@matches":"0","TotalMatchScore":null},"ErrorWarnings":{"ErrorCount":"0","Errors":null,"Warnings":{"Warning":{"Number":"102009","Message":"Match schemes not used","Values":{"Value":["64 317 318 532 533 676 764 858 973 1167 1181 1262 1562 1563 1571 1597 1598 1637 1638 1659 1673 1674 1675 1727 1768 1780 1800 2054 2160 2161 2162 2163 2164 2165 2166 2167 2259 2260 2261 2270 2271 2272 2273 2274 2275 2276 1776 1777 1778 1779"]}}}}}';
                }
                else if(strstatusCodeApi=='1'){
                    responseHardcoded = '{"TransactionStatus":{"ResponseCode":"1","ResponseMessage":"Success"},"MatchSummary":{"@matches":"1","TotalMatchScore":null},"ErrorWarnings":{"ErrorCount":"0","Errors":null,"Warnings":{"Warning":{"Number":"102009","Message":"Match schemes not used","Values":{"Value":["64 317 318 532 533 676 764 858 973 1167 1181 1262 1562 1563 1571 1597 1598 1637 1638 1659 1673 1674 1675 1727 1768 1780 1800 2054 2160 2161 2162 2163 2164 2165 2166 2167 2259 2260 2261 2270 2271 2272 2273 2274 2275 2276 1776 1777 1778 1779"]}}}}}';
                }
                res.setStatusCode(200);
            }else if(strStatusCode == '400'){
                if(strstatusCodeApi=='0'){
                    responseHardcoded = '{"return" : "false"}';
                }
                
                res.setStatusCode(400);
            }
            else {
                responseHardcoded = '{"return" : "false"}';
                res.setStatusCode(201);
            }
            res.setBody(responseHardcoded);
            return res;
        }else if(req.getEndpoint().contains('/sfdckyc/KarzaGSTServiceV1/gstpan')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strstatusCodeApi=='101'){
                responseHardcoded = '{"requestId":"b495e858-b774-4f68-adcf-d2ef85568ce6","result": [{"authStatus":"Active","applicationStatus":null,"emailId":null,"gstinId":"32AAACR5055K1ZG","gstinRefId":null,"mobNum":null,"pan":"AAACR5055K","regType":null,"registrationName":null,"tinNumber":null}],"statusCode": 101}';
                }else if(strstatusCodeApi=='102'){
                    responseHardcoded = '{"requestId" : "bebab1c3-0927-4768-a75f-2a4575504e52","statusCode" : 102}';
                }
                res.setStatusCode(200);
            }else if(strStatusCode == '400'){
                responseHardcoded = '{"requestId" : "bebab1c3-0927-4768-a75f-2a4575504e52","statusCode" : 102}';
                res.setStatusCode(400);
            }
            else {
                responseHardcoded = '{"return" : "false"}';
                res.setStatusCode(201);
            }
            res.setBody(responseHardcoded);
            return res;
        }else if(req.getEndpoint().contains('/sfdckyc/KarzaGSTServiceV1/verifypan')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strstatusCodeApi=='101'){
                responseHardcoded = '{"requestId":"04c139f6-d3ce-409b-96ad-ab1e917d5e43","result":{"stjCd":"KLC287","lgnm":"RELIANCE INDUSTRIES LIMITED","stj":"Taxpayer Services  Circle, Vyttila","dty":"Regular","adadr":{"addr":"NA","ntr":"Office Sale Office","adr":"DOOR NO.13481 C-1, B.C.ROAD ,CHERUVANUR, FEROKE, Kozhikode, Kerala, pin: 673631","em":null,"lastUpdatedDate":"NA","mb":null},"cxdt":null,"gstin":"32AAACR5055K1ZG","nba":["Office  Sale Office","Retail Business","Warehouse  Depot"],"lstupdt":"18052024","rgdt":"01/07/2017","ctb":"Public Limited Company","pradr":{"addr":"NA","ntr":"Office  Sale Office","adr":"1, 291338, CHANDRIKA CHAMBERS, S.A.ROAD, VYTTILA, Ernakulam, Kerala, pin: 682019","em":null,"lastUpdatedDate":"NA","mb":null},"tradeNam":"RELIANCE INDUSTRIES LTD","sts":"Active","ctjCd":"TI0405","ctj":"ERNAKULAM RANGE-5","canFlag":"NA","cmpRt":"NA","contacted":null,"ppr":"NA"},"statusCode":101}';
                }else if(strstatusCodeApi=='102'){
                    responseHardcoded = '{"requestId":"04c139f6-d3ce-409b-96ad-ab1e917d5e43","result":{"stjCd":"KLC287","lgnm":"RELIANCE INDUSTRIES LIMITED","stj":"Taxpayer Services  Circle, Vyttila","dty":"Regular","adadr":{"addr":"NA","ntr":"Office Sale Office","adr":"DOOR NO.13481 C-1, B.C.ROAD ,CHERUVANUR, FEROKE, Kozhikode, Kerala, pin: 673631","em":null,"lastUpdatedDate":"NA","mb":null},"cxdt":null,"gstin":"32AAACR5055K1ZG","nba":["Office  Sale Office","Retail Business","Warehouse  Depot"],"lstupdt":"18052024","rgdt":"01/07/2017","ctb":"Public Limited Company","pradr":{"addr":"NA","ntr":"Office  Sale Office","adr":"1, 291338, CHANDRIKA CHAMBERS, S.A.ROAD, VYTTILA, Ernakulam, Kerala, pin: 682019","em":null,"lastUpdatedDate":"NA","mb":null},"tradeNam":"RELIANCE INDUSTRIES LTD","sts":"Active","ctjCd":"TI0405","ctj":"ERNAKULAM RANGE-5","canFlag":"NA","cmpRt":"NA","contacted":null,"ppr":"NA"},"statusCode":102}';
                }
                res.setStatusCode(200);
            }else if(strStatusCode == '400'){
                responseHardcoded = '{"requestId":"04c139f6-d3ce-409b-96ad-ab1e917d5e43","result":{"stjCd":"KLC287","lgnm":"RELIANCE INDUSTRIES LIMITED","stj":"Taxpayer Services  Circle, Vyttila","dty":"Regular","adadr":{"addr":"NA","ntr":"Office  Sale Office","adr":"DOOR NO.13481 C-1, B.C.ROAD ,CHERUVANUR, FEROKE, Kozhikode, Kerala, pin: 673631","em":null,"lastUpdatedDate":"NA","mb":null},"cxdt":null,"gstin":"32AAACR5055K1ZG","nba":["Office  Sale Office","Retail Business","Warehouse  Depot"],"lstupdt":"18052024","rgdt":"01/07/2017","ctb":"Public Limited Company","pradr":{"addr":"NA","ntr":"Office  Sale Office","adr":"1, 291338, CHANDRIKA CHAMBERS, S.A.ROAD, VYTTILA, Ernakulam, Kerala, pin: 682019","em":null,"lastUpdatedDate":"NA","mb":null},"tradeNam":"RELIANCE INDUSTRIES LTD","sts":"Active","ctjCd":"TI0405","ctj":"ERNAKULAM RANGE-5","canFlag":"NA","cmpRt":"NA","contacted":null,"ppr":"NA"},"statusCode":102}';
                res.setStatusCode(400);
            }
            else {
                responseHardcoded = '{"return" : "false"}';
                res.setStatusCode(201);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        else if(req.getEndpoint().contains('/SFDCKarzaAPIsService/ICWAIMembershipAuth')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strstatusCodeApi=='101'){
                responseHardcoded = '{"result":{"ValidUpDt":"31/03/2025","gender":"","Retired":"","SrName":"","Mname":"","Chapter":"","MemRegion":"NORTHERN","CancellationDt":"","EffectiveDt":"","CrtEmployer":"Pankaj Jain & Associates","MemCategory":"F","FirmEftDt":"","ProtFirmName":"Pankaj Jain & Associates","dob":"","MemshipDt":"","Fname":"Pankaj Jain"},"status-code":"101","request_id":"828a8b75-11a3-48e7-81b1-b960b2057457"}';
                }
                res.setStatusCode(200);
            }
            else {
                responseHardcoded = '{"result":{},"status-code":"102","request_id":"34c98272-11b1-4e9d-8a55-188d069a524d"}';
                res.setStatusCode(400);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        else if(req.getEndpoint().contains('/SFDCKarzaAPIsService/FSSAILicenseAuth')){
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(Integer.valueOf(strStatusCode));
            responseHardcoded = '{"result":{"Status":"Active","LicType":"Registration","FirmName":"PREM ADANIYA / PREM DAIRY","Address":"RAJPURA DHAR,Dhar,Rajpura,Madhya Pradesh,454441","LicNO":"21424990000358"},"status-code":"'+ strstatusCodeApi + '","request_id":"4d33f84d-1c55-46e9-898c-181ada53f39d"}';
            res.setBody(responseHardcoded);
            return res;
        }
        else if(req.getEndpoint().contains('/SFDCKarzaAPIsService/CAMembershipAuth')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strstatusCodeApi=='101'){
                responseHardcoded = '{"result":{"FellowYear":"","Qualification":"BCOM","splitaddress":{"C/O":"","House":"OFFICE NO 11","Floor":3,"Building":"","Complex":"","Street":"SANGANER ROAD","Untagged":"MAHIMA TRINITY MALL OPPOSITE SANJEEVANI HOSPITAL SWEJ FARM NEW","locality":"SODALA","State":"RAJASTHAN","District":"JAIPUR","Pin":302019},"address":"OFFICE NO 11 THIRD FLOOR MAHIMA TRINITY MALL OPPOSITE SANJEEVANI HOSPITAL SWEJ FARM NEW SANGANER ROAD SODALA JAIPUR 302019","gender":"M","name":"DUGAR ANKIT","memberStatus":"","AssociateYear":"A2019","COPStatus":""},"status-code":101,"request_id":"adba88c0-20cf-4d9d-b7ef-e7ab0270cc3a"}';
                }
                res.setStatusCode(200);
            }
            else {
                responseHardcoded = '{"result":{},"status-code":"102","request_id":"34c98272-11b1-4e9d-8a55-188d069a524d"}';
                res.setStatusCode(400);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        else if(req.getEndpoint().contains('/SFDCKarzaAPIsService/ICSIMembership')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strstatusCodeApi=='101'){
                responseHardcoded = '{"result":{"membershipNumber":"F12916","splitaddress":{"C/O":"","House":"P . B . NO . 73","Floor":"","Building":"","Complex":"","Street":"MARKET ROAD","Untagged":"8 / 224 KOCHI","locality":"","State":"KERALA","District":"ERNAKULAM","Pin":683101},"address":"P.B. NO.73,,VIII / 224,MARKET ROAD,KERALA,ERNAKULAM,KOCHI,683101","benevolentMember":"","memberImage":"","city":"KOCHI","phone":"","organization":"COCHIN MINERALS & RUTILE  LTD.","mobile":9447021114,"memberName":"CS  P  SURESHKUMAR","cpNumber":0,"designation":"CHIEF GEN MANAGER(FIN)&CO SECY","email":"SKUMARPAI@GMAIL.COM"},"requestId":"285ff48c-e84c-4105-b990-b2a962f83a3c","statusCode":101}';
                }
                res.setStatusCode(200);
            }
            else {
                responseHardcoded = '{"result":{},"status-code":"102","request_id":"34c98272-11b1-4e9d-8a55-188d069a524d"}';
                res.setStatusCode(400);
            }
            res.setBody(responseHardcoded);
            return res;
        }else if(req.getEndpoint().contains('/sfdckyc/SFDCKarzaAPIsService/IECDetailed')){
            res.setHeader('Content-Type', 'application/json');
            if (strStatusCode == '200') {
                if(strstatusCodeApi=='101'){
                responseHardcoded = '{"result":{"ie_code":"0388066415","party_name_and_address":"RELIANCE INDUSTRIES LIMITED MAKER CHAMBER IV","phone_no":"9967515848","address":"MAKER CHAMBER IV","registration_details":null,"nature_of_concern":"Public Limited","iec_allotment_date":"12-04-1988","bank_details":null,"directors":[{"address":"D-4","father_name":"ANANT TUKARAM MASHELKAR","contact_no":null,"dir_name":"RAGHUNATH ANANT MASHELKAR"}],"no_of_branches":"296","branches":[{"branch_code":"20","address":"CO.CHEMICAL TERMINAL TROMBAY LTD, PIRPAU INSTALLATION,NEAR BPT,PUMP H , TROMBAY MUMBAI,MAHARASHTRA,400074"}],"file_number":"MUMIECPAMEND00038637AM23","bin_pan_extension":"AAACR5055KFT001","file_date":"29-07-2022","date_of_establishment":"08-05-1973","iecgate_status":"AMENDMENT","e_mail":"ashokkumar.khandelwal@ril.com","exporter_type":"Manufacturer Exporter","pan_issue_date":null,"name":"RELIANCE INDUSTRIES LIMITED","iec_status":"Valid","pan_issued_by":null,"rcmc_details":null,"pan":"AAACR5055K"},"status-code":"101","request_id":"dfdeec5c-ad69-42f4-9392-d210b8ad7a59"}';
                }else if(strstatusCodeApi=='102'){
                    responseHardcoded = '{"result":{"ie_code":"0388066415","party_name_and_address":"RELIANCE INDUSTRIES LIMITED MAKER CHAMBER IV","phone_no":"9967515848","address":"MAKER CHAMBER IV","registration_details":null,"nature_of_concern":"Public Limited","iec_allotment_date":"12-04-1988","bank_details":null,"directors":[{"address":"D-4","father_name":"ANANT TUKARAM MASHELKAR","contact_no":null,"dir_name":"RAGHUNATH ANANT MASHELKAR"}],"no_of_branches":"296","branches":[{"branch_code":"20","address":"CO.CHEMICAL TERMINAL TROMBAY LTD, PIRPAU INSTALLATION,NEAR BPT,PUMP H , TROMBAY MUMBAI,MAHARASHTRA,400074"}],"file_number":"MUMIECPAMEND00038637AM23","bin_pan_extension":"AAACR5055KFT001","file_date":"29-07-2022","date_of_establishment":"08-05-1973","iecgate_status":"AMENDMENT","e_mail":"ashokkumar.khandelwal@ril.com","exporter_type":"Manufacturer Exporter","pan_issue_date":null,"name":"RELIANCE INDUSTRIES LIMITED","iec_status":"Valid","pan_issued_by":null,"rcmc_details":null,"pan":"AAACR5055K"},"status-code":"102","request_id":"dfdeec5c-ad69-42f4-9392-d210b8ad7a59"}';
                }
                res.setStatusCode(200);
            }else if(strStatusCode == '400'){
                responseHardcoded = '{"result":{"ie_code":"0388066415","party_name_and_address":"RELIANCE INDUSTRIES LIMITED MAKER CHAMBER IV","phone_no":"9967515848","address":"MAKER CHAMBER IV","registration_details":null,"nature_of_concern":"Public Limited","iec_allotment_date":"12-04-1988","bank_details":null,"directors":[{"address":"D-4","father_name":"ANANT TUKARAM MASHELKAR","contact_no":null,"dir_name":"RAGHUNATH ANANT MASHELKAR"}],"no_of_branches":"296","branches":[{"branch_code":"20","address":"CO.CHEMICAL TERMINAL TROMBAY LTD, PIRPAU INSTALLATION,NEAR BPT,PUMP H , TROMBAY MUMBAI,MAHARASHTRA,400074"}],"file_number":"MUMIECPAMEND00038637AM23","bin_pan_extension":"AAACR5055KFT001","file_date":"29-07-2022","date_of_establishment":"08-05-1973","iecgate_status":"AMENDMENT","e_mail":"ashokkumar.khandelwal@ril.com","exporter_type":"Manufacturer Exporter","pan_issue_date":null,"name":"RELIANCE INDUSTRIES LIMITED","iec_status":"Valid","pan_issued_by":null,"rcmc_details":null,"pan":"AAACR5055K"},"status-code":"102","request_id":"dfdeec5c-ad69-42f4-9392-d210b8ad7a59"}';
                res.setStatusCode(400);
            }
            else {
                responseHardcoded = '{"return" : "false"}';
                res.setStatusCode(201);
            }
            res.setBody(responseHardcoded);
            return res;
        }
        else if(req.getEndpoint().contains('/SFDCKarzaAPIsService/shop')){
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(Integer.valueOf(strStatusCode));
            responseHardcoded = '{"requestId": "6c2d0636-c3b8-4847-9578-225e703e0397","result": {"category": "Commercial Establishment","status": "","ownerName": "Ramanand","entityName": "Shiva Enterprises","registrationDate": "2/1/2017","validTo": "","contact": "9560084286, 27917553","commenceDate": "2/1/2017","totalWorkers": "5","father\'sNameOfOccupier": "Jag Ram","natureOfBusiness": "Others","splitaddress" : {"C/O" : "","House" : "","Floor" : "","Building" : "","Complex" : "","Street" : "","Untagged" : "","locality" : "NATIONAL YOUTH COMPUTER TRAINING ACADEMY TRI NAGAR","State" : "DELHI","District" : "NORTH EAST DELHI","Pin" : 110053},"address": "N-18/242, L-block Jj Colony Wazirpur Delhi, Delhi. PIN-110052","validFrom": "","email": "spraygunsales@gmail.com","websiteUrl": "","applicantName": ""},"statusCode": "'+ strstatusCodeApi + '","clientData": {"caseId":"123456"}}';
            res.setBody(responseHardcoded);
            return res;
        }
        else {
            System.assert(false, 'unexpected endpoint ' + req.getEndpoint());
            return null;
        }
    }
}