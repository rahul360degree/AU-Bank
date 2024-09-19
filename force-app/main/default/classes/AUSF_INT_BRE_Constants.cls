/**
 * @author              : Amit Mishra
 * @date                : 23-June-2024
 * @description         : BRE API Constants
 * Test Class           : 
 * History              :
 * ===========================================================================================================
 * <Date> 		<Authors Name> 		<Brief Description of Change>
 * ===========================================================================================================
 * 23-June-2024 	Amit Mishra 		Initial Version
**/
public without sharing class AUSF_INT_BRE_Constants {
    //========================================================================================================
    //  BRE Controller Constants
    //========================================================================================================
    public static final String FICO_BRE_KNOCKOUT_INTEGRATION_MASTER = 'FICO KNOCKOUT BRE';
    public static final String FICO_BRE_UNDERWRITTING_INTEGRATION_MASTER = 'FICO UNDERWRITTING BRE';
    public static final String BRE_CALLTYPE = 'callType';
    public static final String BRE_REFERENCE_ID = 'ReferenceId';
    public static final String BRE_CITY_TYPE = 'CityType';
    public static final String BRE_FAILED_DECISION = 'FAILED';
    public static final String BRE_DECLINE_DECISION ='DECLINE';
    public static final String BRE_FUCTIONAL_FAILURE_TYPE = 'Functional';

    public static final String BRE_LOAN_STAGE_REJECT = 'Reject';
    public static final String BRE_LOAN_REJECT_REASON_FICO = 'FICO';
    public static final String BRE_LOAN_REJECT_SUB_REASON_APPLICATION_SCORE_NORMS_NOT_MET = 'D213';

    public static final String BRE_RESPONSE_OBJECT_NAME = 'DP_KNOCKOUT BRE RESPONSE';
    public static final String BRE_RESPONSE_OBJECT_CALLTYPE = 'DP_KNOCKOUT';

    public static final String BRE_ADDRESS_TYPE_PERMANENT = 'Permanent';
    public static final String BRE_ADDRESS_TYPE_WORK = 'Work';
    public static final String BRE_ADDRESS_SOURCE_CIBIL = 'CIBIL';

    //========================================================================================================
    //  BRE Handler Constants
    //========================================================================================================
    public static final String BRE_REQUEST_WRAPPER_NAME = 'MasterMessageInput';
    public static final String BRE_REQUEST_DECISION_SERVICE_DS_PL = 'DS_PL';
    public static final String BRE_REQUEST_CALLING_SYSTEM_NAME = 'LOS';
    public static final String BRE_REQUEST_APPLICATION_INFO_SOURCE_MOBILE = 'MOBILE';
    public static final String BRE_REQUEST_PRODUCT_TYPE_PL = 'PL';
    public static final String BRE_REQUEST_PRODUCT_TYPE_CC = 'CC';
    public static final String LOAN_RECORD_TYPE_PERSONAL_LOAN = 'Personal_Loan';
    public static final String BRE_REQUEST_PRODUCT_CODE = '11704';
    //========================================================================================================
    //  BRE UNDERWRITTING Constants
    //========================================================================================================
    public static final String LOCATION_MASTER = 'Location_Master';
}