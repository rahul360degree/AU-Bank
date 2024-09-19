/**
 * @author        Mohit M.
 * @date          18-June-2024
 * @description   Class to store all constants used only in apex and aren't configurable
 * @reference     Generic
 * Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Mohit M.              18-June-2024    Initial Version
  Murtaza Ali           27-June-2024.   Add Profile Constants
  Charchit Niray        09-July-2024    CFR Check Contants
*/
public with sharing class AUSF_ApexConstants {
    public static final String DEFAULT_CERTIFICATE_NAME = '';
    public static final String SEND_SMS_OTP_PL = '';
    public static final String SEND_SMS_PL = '';
    public static final String VERIFY_SMS_OTP_PL = '';
    public static final String MISSING_PRE_REQUISITES = 'Missing Pre-requisites';
    public static final String DOCUMENT_CHECKLIST_OBJECT_LABEL = 'Document Checklist';
    public static final String DOCUMENT_CHECKLIST_INSERT_PROCESS_NAME = 'Create Document Checklist';
    public static final String PRIMAY_APPLICANT_RECORDTYPE_DEV_NAME = 'Primary';
    public static final String AUSF_DSA_PROFILE = 'DSA';
    public static final String AUSF_TCU_PROFILE = 'TCU';
    public static final String AUSF_GUEST_USER_PROFILE = 'AUSFPLDIY Profile';
    public static final String AUSF_DIY_CHANNEL = 'DIY';
    public static final String AUSF_SALES_PROFILE = 'Sales';
    public static final String AUSF_DST = 'DST';
    public static final String AUSF_BLANK = '';
    public static final String AUSF_CANCELLED = 'Cancelled';
    public static final String AUSF_REJECT = 'Reject';
    public static final String AUSF_DISBURSED = 'Disbursed';
    public static final String AUSF_NEW = 'New';
    public static final String AUSF_RESUME = 'Resume';
    public static final String AUSF_LEAD = 'Lead';
    public static final String AUSF_EMPLOYMENTPREFIX_BL = 'BL';
    public static final String AUSF_EMPLOYMENTPREFIX_PL = 'PL';
    public static final String AUSF_SALARIED = 'Salaried';
    public static final String AUSF_SELF_EMPLOYEED = 'Self Employed';
    public static final String GENERIC_INTEGRATION_FAILUR_MSG_INTERNAL = 'Something went wrong!!';
    public static final String GENERIC_INTEGRATION_FAILUR_MSG_CUSTOMER = 'Something went wrong!!';
    public static final String NSDL_PAN_INTEGRATION_MASTER = 'NSDL - PAN Verification';
    public static final String INTEGRATION_MASTER_MISSING = 'Master configuration is missing';
    public static final String NSDL_PAN_ERROR_MESSAGE = 'Something went wrong. Please try again';
    public static final String NSDL_PAN_INVALID_ERROR_MESSAGE = 'Your pan is not valid for this journey';
    public static final String Is_PAN_VERIFIED_YES = 'Yes';
    public static final String PAN_SOURCE_NSDL = 'NSDL';
    public static final String AUSF_AML_INTEGRATION_MASTER = 'AML';
    public static final String AUSF_IC_COMPLETED = 'Completed';
    public static final String AUSF_IC_FAILED = 'Failed';
    public static final String AUSF_IC_IN_PROGRESS = 'In Progress';
    public static final String AUSF_KARZA_NAME_MATCH_INTEGRATION_MASTER = 'Karza Name Match';
    public static final String AUSF_SMS_INTEGRATION_MASTER = 'SMS Notification';
    public static final String AUSF_WHATSAPP_INTEGRATION_MASTER = 'Whatsapp Notification';
    public static final String AUSF_EMAIL_INTEGRATION_MASTER = 'Email Notification';
    public static final String GENERIC_MASTER_MISSING_ERROR_MSG = 'Master configuration is missing';
    public static final String AUSF_JOURNEY_MODE_DIY = 'DIY';
    public static final String AUSF_JOURNEY_MODE_ASSISTED = 'Assisted';
    public static final String AUSF_APP_STAGE_UW = 'Underwriting';
    public static final String AUSF_ELECTRICITY_INTEGRATION_MASTER = 'Electricity Bill';
    public static final String AUSF_EMAIL_VERIFICATION_INTEGRATION_MASTER = 'Email Verification - TU';
    public static final String AUSF_PENNY_DROP_INTEGRATION_MASTER = 'Penny Drop';
    public static final String AUSF_DOCUMENT_COMPRESSOR_INTEGRATION_MASTER = 'DocumentCompressService';
    public static final String AUSF_LDAP_IDAM_INTEGRATION_MASTER = 'LDAP_IDAM';
    public static final String AUSF_Payment_RTGS_INTEGRATION_MASTER = 'Payment RTGS';
    public static final String AUSF_Payment_NEFT_INTEGRATION_MASTER = 'Payment NEFT'; 
    public static final String AUSF_CUSTOMER_ONBOARDING = 'Customer Onboarding';

    
    public static final String PAN_REQUIRED = 'PAN can not be empty.';
    public static final String NAME_REQUIRED = 'Name can not be empty.';
    public static final String DATE_OF_BIRTH_REQUIRED = 'Date Of Birth can not be empty.';

    public static final String FICO_BRE_KNOCKOUT_INTEGRATION_MASTER = 'FICO KNOCKOUT BRE';
    public static final String LOAN_APPLICATION_ID_REQUIRED = 'Loan Application Id is required';
    public static final String BRE_CALL_TYPE_REQUIRED = 'Call Type is required';
    public static final String APPLICANT_NOT_FOUND_FOR_LOAN_APP = 'Applicant does not exist for this Loan Application';
    public static final String INVALID_LOAN_APPLICATION_ID = 'Invalid Loan Application Id';
  
    //public static final User currentUser = [SELECT Id, ManagerId, Profile.Name, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
    //street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email FROM USER WHERE Id = : UserInfo.getUserId()];
    public static final String AUSF_CustomerDedupe_INTEGRATION_MASTER = 'Customer Dedupe Detail';
    public static final String AUSF_MobileGenerateOTP_INTEGRATION_MASTER = 'Mobile Generate OTP';
    public static final String AUSF_MobileResendOTP_INTEGRATION_MASTER = 'Mobile Resend OTP';
    public static final String AUSF_MobileValidateOTP_INTEGRATION_MASTER = 'Mobile Validate OTP';
    public static final String AUSF_LDAP_INTEGRATION_MASTER = 'LDAP_IDAM';
    public static final String AUSF_PANDOB_INTEGRATION_MASTER = 'PAN-DOB';
    public static final String CURRENT_ADDRESS_TYPE = 'Current';   
    public static final String AUSF_PAYMENTIFT_INTEGRATION_MASTER = 'Payment IFT';
    public static final String AUSF_CFR_Check_Reject_Reason = 'CFR Check';
    public static final String AUSF_CFR_Check_Reject_Sub_Reason = 'P238';
    public static final String AUSF_HUNTERAPI_INTEGRATION_MASTER = 'Hunter Api';
    public static final String AUSF_PRE_APPROVED_INTEGRATION_MASTER = 'Pre Approved - Avail Offer';
    
    public static final String AUSF_AML_VERIFIED_YES = 'Yes';
    public static final String AUSF_AML_VERIFIED_NO = 'No';
    public static final String AUSF_AML_VERIFIED_HOLD = 'Hold';
    public static final String AUSF_AML_ACTION_APPROVED = 'Approved';
    public static final String AUSF_AML_ACTION_REJECTED = 'Rejected';
    public static final String AUSF_AML_ACTION_HOLD = 'Hold';
    public static final String AUSF_AML_MATCH_YES = 'YES';
    public static final String AUSF_AML_MATCH_NO = 'NO';
    public static final String AUSF_AML_REJECT_REASON = 'AML Check';
    public static final String AUSF_AML_REJECT_SUB_REASON = 'P237';
    public static final String AUSF_EMAILTU_STATUS = 'valid';
    public static final String AUSF_PEP_REJECTION_CODE = 'P236';
    public static final String AUSF_PEP_REJECTION_REASON = 'PEP';
    public static final String AUSF_TAX_OTHER_THAN_INDIA_REJECTION_CODE = 'P235';
    public static final String AUSF_TAX_OTHER_THAN_INDIA_REJECTION_REASON = 'Tax resident other than India';
    public static final String AUSF_DECLARATION_REJECTION_REASON = 'Declaration';
    public static final String AUSF_STATUS_CODE = '101';
    public static final String AUSF_CustomerDedupe_BANKNAME = 'AU SFB';
    public static final String AUSF_GENERIC_CONSENT = 'consent';
    public static final String AUSF_EB_SERVICE_PROVIDER = 'service_provider';
    public static final String AUSF_EB_CONSUMERID = 'consumer_id';
    public static final String AUSF_GENERIC_REQID = 'ReqId';
    public static final String AUSF_GENERIC_CHANNEL = 'Channel';
    public static final String AUSF_EB_IFSC = 'IFSC';
    public static final String AUSF_PENNYDROP_ACCOUNTNUMBER = 'AccNum';
    public static final String AUSF_PREAPPROVED_ITEMID = 'ItemId';
    public static final String AUSF_PREAPPROVED_OfferActive = 'Offer Is Active';
    public static final String AUSF_PREAPPROVED_OFFER = 'Offer';
    public static final String AUSF_HUNTERAPI_STATUS_YES = 'Yes';
    public static final String AUSF_HUNTERAPI_STATUS_NO = 'No';
    public static final String AUSF_HUNTERAPI_STATUS_MATCH_FOUND = 'Match Found';
    public static final String AUSF_HUNTERAPI_STATUS_MATCH_NOT_FOUND = 'Match Not Found';
    public static final String AUSF_HUNTERAPI_STATUS_HOLD = 'Hold';
    public static final String AUSF_ADDRESS_SOURCE_CUSTOMER_DEDUPE = 'Customer Dedupe';
    public static final String AUSF_ADDRESS_TYPE_PERMANENT = 'Permanent';
    public static final String REJECT_REASON_NPA_CHECK = 'NPA check';
    public static final String  REJECT_REASON_DPD_CHECK = 'DPD Check';

    public static final String  REJECT_SUB_REASON_MobileNumberNotMatch = 'P221';
    public static final String  REJECT_SUB_REASON_OD_found = 'P223';
    public static final String  REJECT_SUB_REASON_DPD_found = 'P224';
    public static final String  REJECT_SUB_REASON_NPA_found = 'P227';
    public static final String  REJECT_SUB_REASON_Customer_is_not_full_KYC = 'P222';
    public static final String  REJECT_SUB_REASON_PA_offer_not_found = 'P230';
    public static final String  REJECT_SUB_REASON_PA_Offer_Expired = 'P231';
    public static final String  REJECT_SUB_REASON_NTB_Customer = 'P232';
    public static final String  REJECT_REASON_Dedupe_check = 'Dedupe check';
    public static final String  REJECT_REASON_Offer_eligibility = 'Offer eligibility';
    public static final String  AUSF_ETB = 'ETB';
    public static final String  AUSF_NTB = 'NTB';
    public static final String  AUSF_TriggerPoint_Case_Rejection = 'Case_Rejection';
    public static final String  AUSF_EMAIL_MISSISNG = 'Email id is required';
    public static final String  AUSF_MOBILE_MISSISNG = 'Mobile number is required';
    public static final String AUSF_BANK_SOURCE_CUSTOMER_DEDUPE = 'Customer Dedupe';
    public static final String AUSF_BANK_SOURCE_PRE_APPROVED_OFFER = 'Pre Approved Offer';
    public static final String AUSF_CIF_MODIFICATION_INTEGRATION_MASTER = 'CIF Modification';
    public static final String AUSF_True = 'True';
    public static final String AUSF_False = 'False';
    public static final String AUSF_NotValidAppliacantId = 'Applicant Id is not valid';    

    public static final String AUSF_NSDL_REJECTION_TRIGGERING_POINT = 'NSDL_Rejection';
    public static final String AUSF_CBSSI_INTEGRATION_MASTER = 'CBS SI Service';
    public static final String AUSF_AddressSplit_INTEGRATION_MASTER = 'Karza Address Split';
    public static final String AUSF_AccountType_CASA = 'CASA';
    public static final String AUSF_CBS_LOAN_CREATION_INTEGRATION_MASTER = 'CBS-Loan Account Creation';
    public static final String AUSF_AddressSource_OWNERSHIP_PROOF = 'Ownership Proof';
    public static final String AUSF_BUSINESSOWNERSHIPPROOF = 'business ownership proof';
    public static final String GENDER_MALE = 'Male';
    public static final String GENDER_FEMALE = 'Female';
    public static final String GENDER_MALE_SHORT_VAL = 'M';
    public static final String GENDER_FEMALE_SHORT_VAL = 'F';
    public static final String GENDER_OTHER = 'Other';

    public static final String AUSF_GST_PAN = 'GST_PAN';
    public static final String AUSF_GST_AUTHENTICATION = 'GST Authentication';
    public static final String AUSF_IMPORT_EXPORT_CERTIFICATION = 'Import Export Certification';
    public static final String AUSF_ICAI_API = 'ICAI API';
    public static final String AUSF_ICWAI_API = 'ICWAI API';  
    public static final String AUSF_ICSI_API = 'ICSI API';
    public static final String FSSAI_CONSENT = 'Y';
    public static final String AUSF_ADDRTYPE_WORK = 'Work';
    public static final String FSSAI = 'FSSAI';
    public static final String REGISTRATION_NO_REQUIRED = 'Registraion No required';
    public static final String FSSAI_ERROR_MSG = 'Internal Server Error , Please try again later or contact your system administrator';
    public static final String AUSF_SHOP_ESTABLISH_INTEGRATION_MASTER = 'Shop and Establishment Certificate';
    public static final String AUSF_PRODUCTCODE_PL = '11704';
}