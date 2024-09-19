/*******************************************************************************************
* @Name         AUSF_INT_PartnerLeadRequestWrapper
* @Author       Mohit M.
* @Description  Request Wrapper for Partner Lead Inbound SF Service
* @Test Class   AUSF_INT_PartnerLeadRequestWrapper_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Mohit M.             19-July-2024            Initial Creation 
*******************************************************************************************/
public with sharing class AUSF_INT_PartnerLeadRequestWrapper {
    public class CALLBACK_DETAILS {
        public String RETURN_URL;
    }

    public String WORKFLOW_GROUP_ID;
    public String CHANNEL;
    public String SUB_CHANNEL;
    public String CAMPAIGN_ID;
    public String PRODUCT;
    public String CHANNEL_REF_NO;
    public String PROSPECT_REF_NO;
    public String IS_MOBILE_NO_VERIFIED;
    public String CUST_ID;
    public UTM UTM;
    public PROSPECT_DATA PROSPECT_DATA;
    public OTHER_INFO OTHER_INFO;
    public CALLBACK_DETAILS CALLBACK_DETAILS;

    public class OTHER_INFO {
        public String TYPE;
        public String FLEXIFIELD1;
        public String FLEXIFIELD2;
    }

    public class UTM {
        public String SOURCE;
        public String CAMPAIGN;
        public String MEDIUM;
        public String CARD;
    }

    public class PROSPECT_DATA {
        public String MOBILE_NO;
        public String PAN_NUMBER;
        public String FIRST_NAME;
        public String MIDDLE_NAME;
        public String LAST_NAME;
        public String PERMANENT_ADDRESS_LINE_1;
        public String PERMANENT_ADDRESS_LINE_2;
        public String PERMANENT_ADDRESS_LINE_3;
        public String PERMANENT_PINCODE;
        public String PERMANENT_CITY;
        public String PERMANENT_STATE;
        public String COMM_ADDRESS_LINE_1;
        public String COMM_ADDRESS_LINE_2;
        public String COMM_ADDRESS_LINE_3;
        public String COMM_PINCODE;
        public String COMM_CITY;
        public String COMM_STATE;
        public String COMM_COUNTRY;
        public String DATE_OF_BIRTH;
        public String EMAIL_ID;
        public String GENDER;
    }

    public static AUSF_INT_PartnerLeadRequestWrapper parse(String json) {
		return (AUSF_INT_PartnerLeadRequestWrapper) System.JSON.deserialize(json, AUSF_INT_PartnerLeadRequestWrapper.class);
	}
}