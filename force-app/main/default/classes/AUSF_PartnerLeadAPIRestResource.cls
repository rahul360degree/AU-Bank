/*******************************************************************************************
* @Name         AUSF_PartnerLeadAPIRestResource
* @Author       Mohit M.
* @Description  Inbound API Rest Service for Partner Leads
* @Test Class   AUSF_PartnerLeadAPIRestResource_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Mohit M.             19-July-2024            Initial Creation - AUPL-605
*******************************************************************************************/
@RestResource(urlMapping='/PartnerLeadAPIRestResource/*')
global with sharing class AUSF_PartnerLeadAPIRestResource {
    /**
    * @description    : postPartherLeadDetails - handle and process request received from Inbound service
    * @author         : Mohit M.
    * @return         : Wrapper - callbackUrl with external Lead Id
    **/
    @HttpPost
    global static void postPartherLeadDetails(){
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        AUSF_INT_PartnerLeadRequestWrapper leadWrap;
        Lead_Stage__c objInsertLead = NULL;
        AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS objReturnResp = new AUSF_INT_PartnerLeadResponseWrapper.CALLBACK_DETAILS();
        String strPartnerLeadMasterName = Label.AUPL_PartnerLeadMasterName;
        Integration_Master__c objIntMasterReg = new Integration_Master__c(Name = strPartnerLeadMasterName);
        Integration_Checklist__c objIntCheck = new Integration_Checklist__c();
        objIntCheck.Integration_Master__r = objIntMasterReg;
        objIntCheck.Request_Initiated_At__c = System.Now();
        String strMobileNumber = '';
        try {
            leadWrap = AUSF_INT_PartnerLeadRequestWrapper.parse(req.requestBody.toString());
            if (leadWrap != NULL) {
                objInsertLead = new Lead_Stage__c();
                // leadWrap.WORKFLOW_GROUP_ID
                objInsertLead.UTM_Source__c = String.isNotBlank(leadWrap.CHANNEL) ? leadWrap.CHANNEL : '';
                // leadWrap.SUB_CHANNEL
                objInsertLead.Campaign_Id__c = String.isNotBlank(leadWrap.CAMPAIGN_ID) ? leadWrap.CAMPAIGN_ID : '';
                // leadWrap.CHANNEL_REF_NO
                objInsertLead.Lead_External_Id__c = String.isNotBlank(leadWrap.PROSPECT_REF_NO) ? leadWrap.PROSPECT_REF_NO : '';
                objInsertLead.Is_Mobile_Number_Verified__c = String.isNotBlank(leadWrap.IS_MOBILE_NO_VERIFIED) && leadWrap.IS_MOBILE_NO_VERIFIED == 'Yes' ? 'Yes' : '';
                objInsertLead.Lead_Customer_Id__c = String.isNotBlank(leadWrap.CUST_ID) ? leadWrap.CUST_ID : '';
                /* START - Process Prospect Data Request */
                if (leadWrap.PROSPECT_DATA != NULL) {
                    AUSF_INT_PartnerLeadRequestWrapper.PROSPECT_DATA objProspectData = leadWrap.PROSPECT_DATA;
                    strMobileNumber = String.isNotBlank(strMobileNumber) ? strMobileNumber.trim() : '';
                    strMobileNumber = String.isBlank(objProspectData.MOBILE_NO) ? '' : objProspectData.MOBILE_NO;                    
                    // Check for Existing Lead
                    if (String.isNotBlank(strMobileNumber)) {
                        Boolean blnValidMobile = AUSF_Utility.isValidMobileNumber(strMobileNumber);
                        if (!blnValidMobile) {
                            throw new CustomException (Label.PartnerLeadInvalidMobileNumber);
                        }
                        List<Lead_Stage__c> lstLeadStage = [SELECT Id, Name FROM Lead_Stage__c WHERE Name =: strMobileNumber ORDER BY CreatedDate DESC];
                        objInsertLead.Id = lstLeadStage.isEmpty() ? NULL : lstLeadStage[0].Id;
                    }
                    objInsertLead.Name = strMobileNumber;
                    String strPanNumber =  String.isNotBlank(objProspectData.PAN_NUMBER) ? objProspectData.PAN_NUMBER : '';
                    if (String.isNotBlank(strPanNumber)) {
                        Boolean blnValidPan = AUSF_Utility.isValidPANNumber(strPanNumber);
                        if (!blnValidPan) {
                            throw new CustomException (Label.PartnerLeadInvalidPanNumberMsg);
                        }
                    }
                    objInsertLead.PAN_Number__c = strPanNumber;
                    objInsertLead.First_Name__c = String.isNotBlank(objProspectData.FIRST_NAME) ? objProspectData.FIRST_NAME : '';
                    objInsertLead.Middle_Name__c = String.isNotBlank(objProspectData.MIDDLE_NAME) ? objProspectData.MIDDLE_NAME : '';
                    objInsertLead.Last_Name__c = String.isNotBlank(objProspectData.LAST_NAME) ? objProspectData.LAST_NAME : '';
                    objInsertLead.PERMANENT_ADDRESS_LINE_1__c = String.isNotBlank(objProspectData.PERMANENT_ADDRESS_LINE_1) ? objProspectData.PERMANENT_ADDRESS_LINE_1 : '';
                    objInsertLead.PERMANENT_ADDRESS_LINE_2__c = String.isNotBlank(objProspectData.PERMANENT_ADDRESS_LINE_2) ? objProspectData.PERMANENT_ADDRESS_LINE_2 : '';
                    objInsertLead.PERMANENT_ADDRESS_LINE_3__c = String.isNotBlank(objProspectData.PERMANENT_ADDRESS_LINE_3) ? objProspectData.PERMANENT_ADDRESS_LINE_3 : '';
                    objInsertLead.Permanent_Address_Pincode__c = String.isNotBlank(objProspectData.PERMANENT_PINCODE) ? objProspectData.PERMANENT_PINCODE : '';
                    objInsertLead.Permanent_Address_City__c = String.isNotBlank(objProspectData.PERMANENT_CITY) ? objProspectData.PERMANENT_CITY : '';
                    objInsertLead.Permanent_Address_State__c = String.isNotBlank(objProspectData.PERMANENT_STATE) ? objProspectData.PERMANENT_STATE : '';
                    objInsertLead.Communication_Address_Line_1__c = String.isNotBlank(objProspectData.COMM_ADDRESS_LINE_1) ? objProspectData.COMM_ADDRESS_LINE_1 : '';
                    objInsertLead.Communication_Address_Line_2__c = String.isNotBlank(objProspectData.COMM_ADDRESS_LINE_2) ? objProspectData.COMM_ADDRESS_LINE_2 : '';
                    objInsertLead.Communication_Address_Line_3__c = String.isNotBlank(objProspectData.COMM_ADDRESS_LINE_3) ? objProspectData.COMM_ADDRESS_LINE_3 : '';
                    objInsertLead.Communication_Address_Pincode__c = String.isNotBlank(objProspectData.COMM_PINCODE) ? objProspectData.COMM_PINCODE : '';
                    objInsertLead.Communication_Address_City__c = String.isNotBlank(objProspectData.COMM_CITY) ? objProspectData.COMM_CITY : '';
                    objInsertLead.Communication_Address_State__c = String.isNotBlank(objProspectData.COMM_STATE) ? objProspectData.COMM_STATE : '';
                    objInsertLead.Email_Id__c = String.isNotBlank(objProspectData.EMAIL_ID) ? objProspectData.EMAIL_ID : '';
                    // Expectation - mm/dd/yyyy
                    String strDateOfBirth = String.isNotBlank(objProspectData.DATE_OF_BIRTH) ? objProspectData.DATE_OF_BIRTH : '';
                    Date dtDob = NULL;
                    if (String.isNotBlank(strDateOfBirth)) {
                        List<String> lstDate = strDateOfBirth.indexOf('/') > 0 ? strDateOfBirth.split('/') : (strDateOfBirth.indexOf('-') > 0 ? strDateOfBirth.split('/') : new List<String>());
                        dtDob = Date.newInstance(Integer.valueOf(lstDate[2]), Integer.valueOf(lstDate[1]), Integer.valueOf(lstDate[0]));
                    }
                    objInsertLead.Date_of_Birth__c = dtDob;
                    objInsertLead.Gender__c = String.isNotBlank(objProspectData.GENDER) ? getGenderValue(objProspectData.GENDER) : '';
                    
                    if (String.isBlank(objInsertLead.PERMANENT_ADDRESS_LINE_1__c) || String.isBlank(objInsertLead.Permanent_Address_Pincode__c)) {
                        if (String.isBlank(objInsertLead.PERMANENT_ADDRESS_LINE_1__c) && String.isNotBlank(objInsertLead.Permanent_Address_Pincode__c)) {
                            throw new CustomException (Label.PartnerLeadAddressLine1MissingMsg);
                        }
                        else if (String.isNotBlank(objInsertLead.PERMANENT_ADDRESS_LINE_1__c) && String.isBlank(objInsertLead.Permanent_Address_Pincode__c)) {
                            throw new CustomException (Label.PartnerLeadPincodeMissingErrorMsg);
                        }
                        else if (String.isNotBlank(objInsertLead.PERMANENT_ADDRESS_LINE_2__c) || 
                            String.isNotBlank(objInsertLead.PERMANENT_ADDRESS_LINE_3__c) || 
                            String.isNotBlank(objInsertLead.Permanent_Address_City__c) || 
                            String.isNotBlank(objInsertLead.Permanent_Address_State__c)
                        ) {
                            throw new CustomException (Label.PartnerLeadAddressAndPincodeMissingErrorMsg);
                        }
                    }
                    if (String.isBlank(objInsertLead.Communication_ADDRESS_LINE_1__c) || String.isBlank(objInsertLead.Communication_Address_Pincode__c)) {
                        if (String.isBlank(objInsertLead.Communication_ADDRESS_LINE_1__c) && String.isNotBlank(objInsertLead.Communication_Address_Pincode__c)) {
                            throw new CustomException (Label.PartnerLeadAddressLine1MissingMsg);
                        }
                        else if (String.isNotBlank(objInsertLead.Communication_ADDRESS_LINE_1__c) && String.isBlank(objInsertLead.Communication_Address_Pincode__c)) {
                            throw new CustomException (Label.PartnerLeadPincodeMissingErrorMsg);
                        }
                        else if (String.isNotBlank(objInsertLead.Communication_ADDRESS_LINE_2__c) || 
                            String.isNotBlank(objInsertLead.Communication_ADDRESS_LINE_3__c) || 
                            String.isNotBlank(objInsertLead.Communication_Address_City__c) || 
                            String.isNotBlank(objInsertLead.Communication_Address_State__c)
                        ) {
                            throw new CustomException (Label.PartnerLeadAddressAndPincodeMissingErrorMsg);
                        }
                    }
                    if(String.isNotBlank(objInsertLead.Communication_Address_Pincode__c)) {
                        List<Location_Master__c> lstLM = AUSF_Utility.getLocationMasterFromZip(objInsertLead.Communication_Address_Pincode__c);
                        objInsertLead.Communication_Address_City__c = lstLM.size()>0 && String.isNotBlank(lstLM[0].City__c) ? lstLM[0].City__c : '';
                        objInsertLead.Communication_Address_State__c = lstLM.size()>0 && String.isNotBlank(lstLM[0].State__c) ? lstLM[0].State__c : '';
                    }
                    if(String.isNotBlank(objInsertLead.Permanent_Address_Pincode__c)) {
                        List<Location_Master__c> lstLM = AUSF_Utility.getLocationMasterFromZip(objInsertLead.Communication_Address_Pincode__c);
                        objInsertLead.Permanent_Address_City__c = lstLM.size()>0 && String.isNotBlank(lstLM[0].City__c) ? lstLM[0].City__c : '';
                        objInsertLead.Permanent_Address_State__c = lstLM.size()>0 && String.isNotBlank(lstLM[0].State__c) ? lstLM[0].State__c : '';
                    }
                }
                /* END - Process Prospect Data Request */
                /* START - Process UTM Data Request */
                if (leadWrap.UTM != NULL) {
                    AUSF_INT_PartnerLeadRequestWrapper.UTM objUTM = leadWrap.UTM;
                    //objInsertLead.UTM_Source__c = String.isNotBlank(objUTM.SOURCE) ? objUTM.SOURCE : '';
                    objInsertLead.UTM_Campaign__c = String.isNotBlank(objUTM.CAMPAIGN) ? objUTM.CAMPAIGN : '';
                    objInsertLead.UTM_Medium__c = String.isNotBlank(objUTM.MEDIUM) ? objUTM.MEDIUM : '';
                    objInsertLead.UTM_Card__c = String.isNotBlank(objUTM.CARD) ? objUTM.CARD : '';
                }
                /* END - Process UTM Data Request */
                objInsertLead.Sourcing_Channel__c = Label.PartnerLeadDefaultSourcingChannel;
                upsert objInsertLead;

                // Fetch Lead Stage record to fetch and set SF generated External Lead Id
                Lead_Stage__c objNewLead = [SELECT Id, Name, Lead_Number__c, SF_External_Lead_Id__c FROM Lead_Stage__c WHERE Id =: objInsertLead.Id];
                objNewLead.SF_External_Lead_Id__c = objNewLead.Lead_Number__c;
                objNewLead.Name = String.isBlank(strMobileNumber) ? objNewLead.SF_External_Lead_Id__c : objNewLead.Name;
                update objNewLead;

                /* START - Set return response */
                AUSF_DIYUtility.WrapForSession objWrap = AUSF_DIYUtility.getURLEncryptedId (String.valueOf(objNewLead.Id), false);
                objReturnResp.RETURN_URL = Label.AUPL_DIYCommunityStartPageURL + '?appId=' + objWrap.strSessionId;
                objReturnResp.LeadNumber = objNewLead.SF_External_Lead_Id__c;
                objReturnResp.message = Label.PartnerLeadInsertSuccessMessage;
                objReturnResp.status = 'Success';
                objReturnResp.duration = Integer.valueOf(System.Now().getTime() - objIntCheck.Request_Initiated_At__c.getTime())+'ms';
                /* END - Set return response */
                /* START - Insert Integration Checklist Record */
                objIntCheck.Request__c = req.requestBody.toString();
                objIntCheck.Response__c = JSON.serialize(objReturnResp);
                objIntCheck.Lead_Stage__c = objNewLead.Id;
                objIntCheck.Response_Received_At__c = System.Now();
                objIntCheck.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                insert objIntCheck;
                /* END - Insert Integration Checklist Record */
            }
        }
        catch (Exception ex) {
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,'','Others',strPartnerLeadMasterName);
            objIntCheck.Response_Received_At__c = System.now();
            objIntCheck.Request__c = req.requestBody.toString();
            objIntCheck.Response__c = JSON.serialize(objReturnResp);
            objIntCheck.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
            insert objIntCheck;
            objReturnResp.status = 'Error';
            objReturnResp.message = Label.PartnerLeadInsertFailMessage + ' - ' + ex.getMessage();
            objReturnResp.duration = Integer.valueOf(objIntCheck.Response_Received_At__c.getTime() - objIntCheck.Request_Initiated_At__c.getTime())+'ms';
        }
        RestContext.response.addHeader('Content-Type', 'application/json');
        RestContext.response.responseBody = Blob.valueOf(JSON.serialize(objReturnResp));
    }

    @TestVisible
    private static string getGenderValue (String strGender) {
        if (strGender == AUSF_ApexConstants.GENDER_MALE || strGender == AUSF_ApexConstants.GENDER_MALE_SHORT_VAL) {
            return AUSF_ApexConstants.GENDER_MALE;
        }
        else if (strGender == AUSF_ApexConstants.GENDER_FEMALE || strGender == AUSF_ApexConstants.GENDER_FEMALE_SHORT_VAL) {
            return AUSF_ApexConstants.GENDER_FEMALE;
        }
        return AUSF_ApexConstants.GENDER_OTHER;
    }

    public class CustomException extends Exception {}
}