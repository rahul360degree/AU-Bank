/**
* @author        Mohit M.
* @date          24-June-2024
* @description   Mock Response Class for Mobile OTP
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Mohit M.              24-June-2024    Initial Version
*/
public without sharing class AUSF_MobileOtpMockResponse {
    public static string strSuccessResponse = '{"statusDesc":"Validated Success","statusCode":"100","requestStatus":"Success","custRef":"9999999999"}';
    public static string strFailedResponse = '{"statusDesc":"Validation Unscussfull","statusCode":"0","requestStatus":"Failure","custRef":""}';
    public static string strOtherfailure = '{Internal server Error}';
}