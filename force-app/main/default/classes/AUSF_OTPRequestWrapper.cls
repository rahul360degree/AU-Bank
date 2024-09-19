/**
* @author        Mohit M.
* @date          18-June-2024
* @description   Wrapper for OTP Generate request payload
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Mohit M.              18-June-2024    Initial Version
*/
public without sharing class AUSF_OTPRequestWrapper {
    public AUSF_OTPRequestWrapper(){}
    public String mobile;
    public String otptype;
    public String otplength;
    public String otptimeout;
    public String msgContent;
    public String requestId;
    public String custRef;
    public String channel;
    public String otp;    
}