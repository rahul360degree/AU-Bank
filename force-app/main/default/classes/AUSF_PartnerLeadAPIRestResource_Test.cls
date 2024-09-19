/*******************************************************************************************
* @Name         AUSF_PartnerLeadAPIRestResource_Test
* @Author       Mohit M.
* @Description  Code coverage for AUSF_PartnerLeadAPIRestResource
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Mohit M.             26-July-2024            Initial Creation - AUPL-605
*******************************************************************************************/
@isTest
public with sharing class AUSF_PartnerLeadAPIRestResource_Test {
    @testSetup
    static void Setup(){

        Profile objProfile = [Select Id from Profile where Name = 'System Administrator'];
        User objUser = AUSF_TestDataFactory.createUsersWithParams(null,'admin','user','123456','admintest@salesforce.com','admintest@salesforce.com.aupl',objProfile.Id,'ad11');
        insert objUser;
        System.runAs(objUser) {
            // Insert Location Master
            Location_Master__c objLocMaster = AUSF_TestDataFactory.createLocationMaster ('326033', 'JAIPUR', 'Rajasthan');
            insert objLocMaster;

            // Insert Integration Master
            Integration_Master__c objMaster = AUSF_TestDataFactory.createIntegrationMaster (Label.AUPL_PartnerLeadMasterName, '', '', 'POST', '', '');
            insert objMaster;
        }
    }

    /* Test Case for Success */
    @isTest
    public static void testInsertLeadSuccess(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'admintest@salesforce.com.aupl' LIMIT 1];
        system.assertEquals('admintest@salesforce.com',objUser.Email);
        System.runAs(objUser) {
            Test.startTest();
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();             
                req.requestURI = 'apexrest/v1/PartnerLeadAPIRestResource';
                req.httpMethod = 'POST';
                String requestBody = '{"WORKFLOW_GROUP_ID":"CC_SELF_MB","CHANNEL":"MB","SUB_CHANNEL":"","CAMPAIGN_ID":"123","PRODUCT":"CC","CHANNEL_REF_NO":"1234","PROSPECT_REF_NO":"1234","IS_MOBILE_NO_VERIFIED":"Yes","CUST_ID":"25224651","UTM":{"SOURCE":"abc","CAMPAIGN":"abc","MEDIUM":"abc","CARD":"abc"},"PROSPECT_DATA":{"MOBILE_NO":"8899878787","PAN_NUMBER":"ATEPB4345M","FIRST_NAME":"Test","MIDDLE_NAME":"M","LAST_NAME":"Test","PERMANENT_ADDRESS_LINE_1":"line1","PERMANENT_ADDRESS_LINE_2":"line2","PERMANENT_ADDRESS_LINE_3":"line3","PERMANENT_PINCODE":"326033","PERMANENT_CITY":"SHUR","PERMANENT_STATE":"MAD","COMM_ADDRESS_LINE_1":"Hr Mohalla","COMM_ADDRESS_LINE_2":"Grda Narela","COMM_ADDRESS_LINE_3":"Waapur","COMM_PINCODE":"326033","COMM_CITY":"BARE","COMM_STATE":"MADHH","COMM_COUNTRY":"IN","DATE_OF_BIRTH":"12/21/1991","EMAIL_ID":"test@test.com","GENDER":"M"},"OTHER_INFO":{"TYPE":"ETB","FLEXIFIELD1":"","FLEXIFIELD2":""},"CALLBACK_DETAILS":{"RETURN_URL":""}}';
                req.requestBody = Blob.valueOf(requestBody);
                RestContext.request = req;
                RestContext.response = res;
                AUSF_PartnerLeadAPIRestResource.postPartherLeadDetails();
                AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS objReturnResp = (AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS)JSON.deserialize(res.responseBody.toString(), AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS.class);
                system.assertEquals('Success',objReturnResp.status);

            Test.stopTest();
        }
    }

    /* Test Case for Invalid PAN Without P */
    @isTest
    public static void testInsertLeadFailInvalidPAN1(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'admintest@salesforce.com.aupl' LIMIT 1];
        system.assertEquals('admintest@salesforce.com',objUser.Email);
        System.runAs(objUser) {
            Test.startTest();
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();             
                req.requestURI = 'apexrest/v1/PartnerLeadAPIRestResource';
                req.httpMethod = 'POST';
                String requestBody = '{"WORKFLOW_GROUP_ID":"CC_SELF_MB","CHANNEL":"MB","SUB_CHANNEL":"","CAMPAIGN_ID":"123","PRODUCT":"CC","CHANNEL_REF_NO":"1234","PROSPECT_REF_NO":"1234","IS_MOBILE_NO_VERIFIED":"Yes","CUST_ID":"25224651","UTM":{"SOURCE":"abc","CAMPAIGN":"abc","MEDIUM":"abc","CARD":"abc"},"PROSPECT_DATA":{"MOBILE_NO":"8899878787","PAN_NUMBER":"ATEBB4345M","FIRST_NAME":"Test","MIDDLE_NAME":"M","LAST_NAME":"Test","PERMANENT_ADDRESS_LINE_1":"line1","PERMANENT_ADDRESS_LINE_2":"line2","PERMANENT_ADDRESS_LINE_3":"line3","PERMANENT_PINCODE":"326033","PERMANENT_CITY":"SHUR","PERMANENT_STATE":"MAD","COMM_ADDRESS_LINE_1":"Hr Mohalla","COMM_ADDRESS_LINE_2":"Grda Narela","COMM_ADDRESS_LINE_3":"Waapur","COMM_PINCODE":"326033","COMM_CITY":"BARE","COMM_STATE":"MADHH","COMM_COUNTRY":"IN","DATE_OF_BIRTH":"12/21/1991","EMAIL_ID":"test@test.com","GENDER":"M"},"OTHER_INFO":{"TYPE":"ETB","FLEXIFIELD1":"","FLEXIFIELD2":""},"CALLBACK_DETAILS":{"RETURN_URL":""}}';
                req.requestBody = Blob.valueOf(requestBody);
                RestContext.request = req;
                RestContext.response = res;
                AUSF_PartnerLeadAPIRestResource.postPartherLeadDetails();
                AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS objReturnResp = (AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS)(AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS)JSON.deserialize(res.responseBody.toString(), AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS.class);
                system.assertEquals('Error',objReturnResp.status);

            Test.stopTest();
        }
    }

    /* Test Case for Invalid PAN Without Middle Digit */
    @isTest
    public static void testInsertLeadFailInvalidPAN2(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'admintest@salesforce.com.aupl' LIMIT 1];
        system.assertEquals('admintest@salesforce.com',objUser.Email);
        System.runAs(objUser) {
            Test.startTest();
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();             
                req.requestURI = 'apexrest/v1/PartnerLeadAPIRestResource';
                req.httpMethod = 'POST';
                String requestBody = '{"WORKFLOW_GROUP_ID":"CC_SELF_MB","CHANNEL":"MB","SUB_CHANNEL":"","CAMPAIGN_ID":"123","PRODUCT":"CC","CHANNEL_REF_NO":"1234","PROSPECT_REF_NO":"1234","IS_MOBILE_NO_VERIFIED":"Yes","CUST_ID":"25224651","UTM":{"SOURCE":"abc","CAMPAIGN":"abc","MEDIUM":"abc","CARD":"abc"},"PROSPECT_DATA":{"MOBILE_NO":"8899878787","PAN_NUMBER":"ATEPB4PK5M","FIRST_NAME":"Test","MIDDLE_NAME":"M","LAST_NAME":"Test","PERMANENT_ADDRESS_LINE_1":"line1","PERMANENT_ADDRESS_LINE_2":"line2","PERMANENT_ADDRESS_LINE_3":"line3","PERMANENT_PINCODE":"326033","PERMANENT_CITY":"SHUR","PERMANENT_STATE":"MAD","COMM_ADDRESS_LINE_1":"Hr Mohalla","COMM_ADDRESS_LINE_2":"Grda Narela","COMM_ADDRESS_LINE_3":"Waapur","COMM_PINCODE":"326033","COMM_CITY":"BARE","COMM_STATE":"MADHH","COMM_COUNTRY":"IN","DATE_OF_BIRTH":"12/21/1991","EMAIL_ID":"test@test.com","GENDER":"M"},"OTHER_INFO":{"TYPE":"ETB","FLEXIFIELD1":"","FLEXIFIELD2":""},"CALLBACK_DETAILS":{"RETURN_URL":""}}';
                req.requestBody = Blob.valueOf(requestBody);
                RestContext.request = req;
                RestContext.response = res;
                AUSF_PartnerLeadAPIRestResource.postPartherLeadDetails();
                AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS objReturnResp = (AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS)JSON.deserialize(res.responseBody.toString(), AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS.class);
                system.assertEquals('Error',objReturnResp.status);

            Test.stopTest();
        }
    }

    /* Test Case for Invalid Number */
    @isTest
    public static void testInsertLeadFailInvalidPhone(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'admintest@salesforce.com.aupl' LIMIT 1];
        system.assertEquals('admintest@salesforce.com',objUser.Email);
        System.runAs(objUser) {
            Test.startTest();
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();             
                req.requestURI = 'apexrest/v1/PartnerLeadAPIRestResource';
                req.httpMethod = 'POST';
                String requestBody = '{"WORKFLOW_GROUP_ID":"CC_SELF_MB","CHANNEL":"MB","SUB_CHANNEL":"","CAMPAIGN_ID":"123","PRODUCT":"CC","CHANNEL_REF_NO":"1234","PROSPECT_REF_NO":"1234","IS_MOBILE_NO_VERIFIED":"Yes","CUST_ID":"25224651","UTM":{"SOURCE":"abc","CAMPAIGN":"abc","MEDIUM":"abc","CARD":"abc"},"PROSPECT_DATA":{"MOBILE_NO":"88999978787","PAN_NUMBER":"ATEPB4345M","FIRST_NAME":"Test","MIDDLE_NAME":"M","LAST_NAME":"Test","PERMANENT_ADDRESS_LINE_1":"line1","PERMANENT_ADDRESS_LINE_2":"line2","PERMANENT_ADDRESS_LINE_3":"line3","PERMANENT_PINCODE":"326033","PERMANENT_CITY":"SHUR","PERMANENT_STATE":"MAD","COMM_ADDRESS_LINE_1":"Hr Mohalla","COMM_ADDRESS_LINE_2":"Grda Narela","COMM_ADDRESS_LINE_3":"Waapur","COMM_PINCODE":"326033","COMM_CITY":"BARE","COMM_STATE":"MADHH","COMM_COUNTRY":"IN","DATE_OF_BIRTH":"12/21/1991","EMAIL_ID":"test@test.com","GENDER":"M"},"OTHER_INFO":{"TYPE":"ETB","FLEXIFIELD1":"","FLEXIFIELD2":""},"CALLBACK_DETAILS":{"RETURN_URL":""}}';
                req.requestBody = Blob.valueOf(requestBody);
                RestContext.request = req;
                RestContext.response = res;
                AUSF_PartnerLeadAPIRestResource.postPartherLeadDetails();
                AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS objReturnResp = (AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS)JSON.deserialize(res.responseBody.toString(), AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS.class);
                system.assertEquals('Error',objReturnResp.status);
            Test.stopTest();
        }
    }

    /* Test Case for Without Permanent Address Line 1 */
    @isTest
    public static void testInsertLeadFailInvalidAddress1(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'admintest@salesforce.com.aupl' LIMIT 1];
        system.assertEquals('admintest@salesforce.com',objUser.Email);
        System.runAs(objUser) {
            Test.startTest();
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();             
                req.requestURI = 'apexrest/v1/PartnerLeadAPIRestResource';
                req.httpMethod = 'POST';
                String requestBody = '{"WORKFLOW_GROUP_ID":"CC_SELF_MB","CHANNEL":"MB","SUB_CHANNEL":"","CAMPAIGN_ID":"123","PRODUCT":"CC","CHANNEL_REF_NO":"1234","PROSPECT_REF_NO":"1234","IS_MOBILE_NO_VERIFIED":"Yes","CUST_ID":"25224651","UTM":{"SOURCE":"abc","CAMPAIGN":"abc","MEDIUM":"abc","CARD":"abc"},"PROSPECT_DATA":{"MOBILE_NO":"8899997879","PAN_NUMBER":"ATEPB4345M","FIRST_NAME":"Test","MIDDLE_NAME":"M","LAST_NAME":"Test","PERMANENT_ADDRESS_LINE_1":"","PERMANENT_ADDRESS_LINE_2":"line2","PERMANENT_ADDRESS_LINE_3":"line3","PERMANENT_PINCODE":"326033","PERMANENT_CITY":"SHUR","PERMANENT_STATE":"MAD","COMM_ADDRESS_LINE_1":"Hr Mohalla","COMM_ADDRESS_LINE_2":"Grda Narela","COMM_ADDRESS_LINE_3":"Waapur","COMM_PINCODE":"326033","COMM_CITY":"BARE","COMM_STATE":"MADHH","COMM_COUNTRY":"IN","DATE_OF_BIRTH":"12/21/1991","EMAIL_ID":"test@test.com","GENDER":"M"},"OTHER_INFO":{"TYPE":"ETB","FLEXIFIELD1":"","FLEXIFIELD2":""},"CALLBACK_DETAILS":{"RETURN_URL":""}}';
                req.requestBody = Blob.valueOf(requestBody);
                RestContext.request = req;
                RestContext.response = res;
                AUSF_PartnerLeadAPIRestResource.postPartherLeadDetails();
                AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS objReturnResp = (AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS)JSON.deserialize(res.responseBody.toString(), AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS.class);
                system.assertEquals('Error',objReturnResp.status);
            Test.stopTest();
        }
    }

    /* Test Case for Without Permanent Without Pincode */
    @isTest
    public static void testInsertLeadFailInvalidAddress2(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'admintest@salesforce.com.aupl' LIMIT 1];
        system.assertEquals('admintest@salesforce.com',objUser.Email);
        System.runAs(objUser) {
            Test.startTest();
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();             
                req.requestURI = 'apexrest/v1/PartnerLeadAPIRestResource';
                req.httpMethod = 'POST';
                String requestBody = '{"WORKFLOW_GROUP_ID":"CC_SELF_MB","CHANNEL":"MB","SUB_CHANNEL":"","CAMPAIGN_ID":"123","PRODUCT":"CC","CHANNEL_REF_NO":"1234","PROSPECT_REF_NO":"1234","IS_MOBILE_NO_VERIFIED":"Yes","CUST_ID":"25224651","UTM":{"SOURCE":"abc","CAMPAIGN":"abc","MEDIUM":"abc","CARD":"abc"},"PROSPECT_DATA":{"MOBILE_NO":"8899997879","PAN_NUMBER":"ATEPB4345M","FIRST_NAME":"Test","MIDDLE_NAME":"M","LAST_NAME":"Test","PERMANENT_ADDRESS_LINE_1":"abc","PERMANENT_ADDRESS_LINE_2":"line2","PERMANENT_ADDRESS_LINE_3":"line3","PERMANENT_PINCODE":"","PERMANENT_CITY":"SHUR","PERMANENT_STATE":"MAD","COMM_ADDRESS_LINE_1":"Hr Mohalla","COMM_ADDRESS_LINE_2":"Grda Narela","COMM_ADDRESS_LINE_3":"Waapur","COMM_PINCODE":"326033","COMM_CITY":"BARE","COMM_STATE":"MADHH","COMM_COUNTRY":"IN","DATE_OF_BIRTH":"12/21/1991","EMAIL_ID":"test@test.com","GENDER":"M"},"OTHER_INFO":{"TYPE":"ETB","FLEXIFIELD1":"","FLEXIFIELD2":""},"CALLBACK_DETAILS":{"RETURN_URL":""}}';
                req.requestBody = Blob.valueOf(requestBody);
                RestContext.request = req;
                RestContext.response = res;
                AUSF_PartnerLeadAPIRestResource.postPartherLeadDetails();
                AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS objReturnResp = (AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS)JSON.deserialize(res.responseBody.toString(), AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS.class);
                system.assertEquals('Error',objReturnResp.status);
            Test.stopTest();
        }
    }

    /* Test Case for Without Comminication Without Pincode */
    @isTest
    public static void testInsertLeadFailInvalidAddress3(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'admintest@salesforce.com.aupl' LIMIT 1];
        system.assertEquals('admintest@salesforce.com',objUser.Email);
        System.runAs(objUser) {
            Test.startTest();
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();             
                req.requestURI = 'apexrest/v1/PartnerLeadAPIRestResource';
                req.httpMethod = 'POST';
                String requestBody = '{"WORKFLOW_GROUP_ID":"CC_SELF_MB","CHANNEL":"MB","SUB_CHANNEL":"","CAMPAIGN_ID":"123","PRODUCT":"CC","CHANNEL_REF_NO":"1234","PROSPECT_REF_NO":"1234","IS_MOBILE_NO_VERIFIED":"Yes","CUST_ID":"25224651","UTM":{"SOURCE":"abc","CAMPAIGN":"abc","MEDIUM":"abc","CARD":"abc"},"PROSPECT_DATA":{"MOBILE_NO":"8899997879","PAN_NUMBER":"ATEPB4345M","FIRST_NAME":"Test","MIDDLE_NAME":"M","LAST_NAME":"Test","PERMANENT_ADDRESS_LINE_1":"abc","PERMANENT_ADDRESS_LINE_2":"line2","PERMANENT_ADDRESS_LINE_3":"line3","PERMANENT_PINCODE":"326033","PERMANENT_CITY":"SHUR","PERMANENT_STATE":"MAD","COMM_ADDRESS_LINE_1":"Hr Mohalla","COMM_ADDRESS_LINE_2":"Grda Narela","COMM_ADDRESS_LINE_3":"Waapur","COMM_PINCODE":"","COMM_CITY":"BARE","COMM_STATE":"MADHH","COMM_COUNTRY":"IN","DATE_OF_BIRTH":"12/21/1991","EMAIL_ID":"test@test.com","GENDER":"M"},"OTHER_INFO":{"TYPE":"ETB","FLEXIFIELD1":"","FLEXIFIELD2":""},"CALLBACK_DETAILS":{"RETURN_URL":""}}';
                req.requestBody = Blob.valueOf(requestBody);
                RestContext.request = req;
                RestContext.response = res;
                AUSF_PartnerLeadAPIRestResource.postPartherLeadDetails();
                AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS objReturnResp = (AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS)JSON.deserialize(res.responseBody.toString(), AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS.class);
                system.assertEquals('Error',objReturnResp.status);
            Test.stopTest();
        }
    }

    /* Test Case for Without Comminication Without Address Line 1 */
    @isTest
    public static void testInsertLeadFailInvalidAddress4(){
        User objUser = [SELECT Id, Email FROM User WHERE username = 'admintest@salesforce.com.aupl' LIMIT 1];
        system.assertEquals('admintest@salesforce.com',objUser.Email);
        System.runAs(objUser) {
            Test.startTest();
                RestRequest req = new RestRequest(); 
                RestResponse res = new RestResponse();             
                req.requestURI = 'apexrest/v1/PartnerLeadAPIRestResource';
                req.httpMethod = 'POST';
                String requestBody = '{"WORKFLOW_GROUP_ID":"CC_SELF_MB","CHANNEL":"MB","SUB_CHANNEL":"","CAMPAIGN_ID":"123","PRODUCT":"CC","CHANNEL_REF_NO":"1234","PROSPECT_REF_NO":"1234","IS_MOBILE_NO_VERIFIED":"Yes","CUST_ID":"25224651","UTM":{"SOURCE":"abc","CAMPAIGN":"abc","MEDIUM":"abc","CARD":"abc"},"PROSPECT_DATA":{"MOBILE_NO":"8899997879","PAN_NUMBER":"ATEPB4345M","FIRST_NAME":"Test","MIDDLE_NAME":"M","LAST_NAME":"Test","PERMANENT_ADDRESS_LINE_1":"abc","PERMANENT_ADDRESS_LINE_2":"line2","PERMANENT_ADDRESS_LINE_3":"line3","PERMANENT_PINCODE":"326033","PERMANENT_CITY":"SHUR","PERMANENT_STATE":"MAD","COMM_ADDRESS_LINE_1":"","COMM_ADDRESS_LINE_2":"Grda Narela","COMM_ADDRESS_LINE_3":"Waapur","COMM_PINCODE":"326033","COMM_CITY":"BARE","COMM_STATE":"MADHH","COMM_COUNTRY":"IN","DATE_OF_BIRTH":"12/21/1991","EMAIL_ID":"test@test.com","GENDER":"M"},"OTHER_INFO":{"TYPE":"ETB","FLEXIFIELD1":"","FLEXIFIELD2":""},"CALLBACK_DETAILS":{"RETURN_URL":""}}';
                req.requestBody = Blob.valueOf(requestBody);
                RestContext.request = req;
                RestContext.response = res;
                AUSF_PartnerLeadAPIRestResource.postPartherLeadDetails();
                AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS objReturnResp = (AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS)JSON.deserialize(res.responseBody.toString(), AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS.class);
                system.assertEquals('Error',objReturnResp.status);
            Test.stopTest();
        }
    }
}