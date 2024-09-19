/*******************************************************************************************
* @Name         AUSF_DIYUtility
* @Author       Mohit M.
* @Description  Utility class to maintain logic related to DIY or Community
* @Test Class   AUSF_DIYUtility_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Mohit M.             27-June-2024            Initial Creation 
*******************************************************************************************/
public without sharing class AUSF_DIYUtility {
    public static boolean blnCheckForLastActivity = false;
    /*
    @description    : identify the previous screen, next screen order based on current screen pass in parameter
    @param1         : applicationId - RecordId (Lead Stage, Loan or Applicant)
    @param2         : strCurrentScreen - current screen open on community
    @param3         : objWrap - Wrapper class by calling method
    @param4         : strLastVisitPage - Last visited page screen name
    @return         : Wrapper with screen and order details
    */
    @AuraEnabled
    public static WrapClass getScreenDetails (String applicationId, String strCurrentScreen, WrapClass objWrap, String strLastVisitPage) {
        objWrap = objWrap == NULL ? new WrapClass () : objWrap; 
        try {
            Integer intCurrentOrder = NULL;
            Integer intPreviousOrder = -1;
            Integer intNextOrder = NULL;
            Boolean blnFoundNext = false;
            List<Generic_UI_Wizard_Mapping_DIY__mdt> lstUIWizardDIYMap = new List<Generic_UI_Wizard_Mapping_DIY__mdt>();
            lstUIWizardDIYMap = [SELECT Id, MasterLabel, DeveloperName, Category__c, Community_Page_Name__c, Current_Screen_Component__c, Current_Screen_Name__c, 
                                    Is_Default__c, Order__c, Progress_in_Current_Step__c, Overall_Step__c FROM Generic_UI_Wizard_Mapping_DIY__mdt ORDER BY Order__c];
            
            // Iterate for Current Screen Order Number
            for (Generic_UI_Wizard_Mapping_DIY__mdt obj : lstUIWizardDIYMap) {
                if (strLastVisitPage == obj.Current_Screen_Name__c) {
                    objWrap.blnExistingJourney = true;
                }
                if (objWrap.blnExistingJourney) {
                    strCurrentScreen = obj.Current_Screen_Name__c;
                    break;
                }
            }
            // Iterate for Previous and Next screen order number
            for (Generic_UI_Wizard_Mapping_DIY__mdt obj : lstUIWizardDIYMap) {
                if (strCurrentScreen == obj.Current_Screen_Name__c) {
                    intCurrentOrder = Integer.valueOf(obj.Order__c);
                    objWrap.currentScreenOrder = intCurrentOrder;
                    objWrap.currentScreenPageName = obj.Community_Page_Name__c;
                }
                if (intCurrentOrder == NULL || Integer.valueOf(obj.Order__c) < intCurrentOrder) {
                    intPreviousOrder = Integer.valueOf(obj.Order__c);
                    objWrap.previousScreenName = obj.Current_Screen_Name__c;
                    objWrap.previousPageName = obj.Community_Page_Name__c;
                }
                if (intCurrentOrder != NULL && Integer.valueOf(obj.Order__c) > intCurrentOrder && intNextOrder == NULL) {
                    intNextOrder = Integer.valueOf(obj.Order__c);
                    objWrap.nextScreenName = obj.Current_Screen_Name__c;
                    objWrap.nextPageName = obj.Community_Page_Name__c;
                    objWrap.nextScreenOrder = intNextOrder;
                }
            }
            if (intCurrentOrder == NULL) {
                throw new CustomException (Label.DIY_PageNotConfiguredErrorMessage);
            }
            objWrap.blnGoToPreviousPage = intCurrentOrder != intPreviousOrder;
            objWrap.blnGotoNextPage = intCurrentOrder != intNextOrder;
            objWrap.blnSuccess = true;
        }
        catch (Exception ex) {
            objWrap.blnSuccess = false;
            System.debug(LoggingLevel.Error,'Exception in class ' + ex);
            objWrap.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,applicationId,'Others',strCurrentScreen);
        }
        return objWrap;
    }

    /*
    @description    : get the Lead or Application Id and details based on session/encrypted recordId pass in parameter
    @param1         : sessionKey - Encryted Lead / ApplicationId / Session Id
    @return         : Wrapper with Session and Record details
    */
    @AuraEnabled
    public static WrapClass checkForValidSession (String sessionKey) {
        WrapClass objWrap = new WrapClass();
        try {
            String encryptionKey =  Integration_Static_Param__mdt.getInstance('DIY_Login_Encryption_Key').Param_Value__c;
            if(String.isNotBlank(sessionKey)) {
                Blob decrypted = Crypto.decryptWithManagedIV('AES256', Blob.valueOf(encryptionKey), EncodingUtil.base64Decode(sessionKey));
                objWrap = checkValidRecord (decrypted.toString(), objWrap);
                return objWrap;
            }
            objWrap.blnSuccess = true;
        }
        catch(Exception ex) {
            objWrap.blnSuccess = false;
            objWrap.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,'','Others','Session Details');
        }
        return objWrap;
    }

    /*
    @description    : identify the session is valid for the Guest User
    @param1         : sessionKey - Encryted Lead / ApplicationId / Session Id
    @param2         : strCurrentScreen - current open screen name
    @isGuestUser    : isGuestUser - true if logged in user is guest user
    @strRecordId    : RecordId
    @return         : Wrapper with Session and Record details
    */
    @AuraEnabled
    public static WrapClass checkForValidSessionWithScreen (String sessionKey, String strCurrentScreen, Boolean isGuestUser, String strRecordId, Boolean blnCheckExisting) {
        WrapClass objWrap = new WrapClass();
        try {
            if (isGuestUser) {
                blnCheckForLastActivity = strCurrentScreen != 'Check Journey' ? true : blnCheckForLastActivity;
                objWrap = checkForValidSession(sessionKey);
                if (!objWrap.blnSuccess && objWrap.blnSessionExpired) {
                    throw new CustomException (Label.DIY_SessionExpiredErrorMessage);
                }
                if (!objWrap.blnSuccess && objWrap.blnOTPInvalid) {
                    throw new CustomException (Label.DIY_InvalidAuthorizationErrorMessage);
                }
                if (!objWrap.blnSuccess) {
                    throw new CustomException (objWrap.strMessage);
                }
                else if (objWrap.blnSuccess && objWrap.strObjectName == 'Lead_Stage__c') {
                    
                }
                else if (objWrap.blnSuccess && objWrap.strObjectName == 'Applicant__c') {
                    
                }
                objWrap = getScreenDetails (objWrap.loanId, strCurrentScreen, objWrap, blnCheckExisting ? objWrap.lastVisitedPage : '');
            }
            else if (String.isNotBlank(strRecordId)) {
                Applicant__c objApplicant = [SELECT Id, Loan_Application__c, Loan_Application__r.Stage__c, Loan_Application__r.Last_Activity__c, Loan_Application__r.Last_visited_Page__c FROM Applicant__c WHERE Loan_Application__c =: strRecordId];
                objWrap.loanId = objApplicant.Loan_Application__c;
                objWrap.applicantId = objApplicant.Id;
                objWrap = getScreenDetails (objWrap.loanId, strCurrentScreen, objWrap,'');
            }
            else if (String.isBlank(strRecordId)) {
                objWrap = getScreenDetails ('', strCurrentScreen, objWrap,'');
            }
            if (!objWrap.blnSuccess) {
                throw new CustomException(objWrap.strMessage);
            }
            objWrap.blnSuccess = true;
        }
        catch(Exception ex) {
            objWrap.blnSuccess = false;
            objWrap.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,String.isNotBlank(strRecordId) ? strRecordId : sessionKey,'Others','Session and Screen Details');
        }
        return objWrap;
    }

    /*
    @description    - Generate Encrypted Id for Session
    @param1         - recordId - pass Lead/Application Id 
    */
    @AuraEnabled
    public static WrapForSession getEncryptedId (String recordId) {
        WrapForSession objWrap = new WrapForSession();
        try {
            String encryptionKey =  Integration_Static_Param__mdt.getInstance('DIY_Login_Encryption_Key').Param_Value__c;
            if(!String.isBlank(recordId)){
                objWrap.strSessionId = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', Blob.valueOf(encryptionKey), Blob.valueOf(recordId)));
            }
            else {
                throw new CustomException(Label.DIY_InvalidSessionErrorMessage);
            }
            objWrap.blnSuccess = true;
        }
        catch (Exception ex){
            objWrap.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,recordId,'Others','ID Encryption');
        }
        return objWrap;
    }

    /*
    @description    - Generate Encrypted Id for Session
    @param1         - recordId - pass Lead/Application Id 
    @param2         - 
    */
    @AuraEnabled
    public static WrapForSession getURLEncryptedId (String recordId, Boolean blnNotification) {
        WrapForSession objWrap = new WrapForSession();
        try {
            String encryptionKey =  Integration_Static_Param__mdt.getInstance('DIY_Login_Encryption_Key').Param_Value__c;
            if(!String.isBlank(recordId)){
                objWrap.strSessionId = EncodingUtil.urlEncode(EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', Blob.valueOf(encryptionKey), Blob.valueOf(String.valueOf(recordId)))),'UTF-8');
            }
            else {
                throw new CustomException(Label.DIY_InvalidSessionErrorMessage);
            }
            objWrap.blnSuccess = true;
        }
        catch (Exception ex){
            objWrap.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,recordId,'Others','URL Encryption');
        }
        return objWrap;
    }

    /*
    @description    - Generate Decoded Value from RecordId
    @param1         - recordId - encrypted record Id
    @return         - wrapper of success and decoded value
    */
    @AuraEnabled
    public static WrapForSession getDecodedValue (String recordId) {
        WrapForSession objWrap = new WrapForSession();
        try {
            String encryptionKey =  Integration_Static_Param__mdt.getInstance('DIY_Login_Encryption_Key').Param_Value__c;
            Blob decrypted = Crypto.decryptWithManagedIV('AES256', Blob.valueOf(encryptionKey), EncodingUtil.base64Decode(recordId));
            objWrap.strSessionId = decrypted.toString();
            objWrap.blnSuccess = true;
        }
        catch (Exception ex){
            objWrap.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,recordId,'Others','ID Decode');
        }
        return objWrap;
    }

    /*
    @description    - check for current Journey Mode
    @param1         - strSourcingChannel - pass Sourcing Channel
    @param2         - strJourneyMode - pass Journey Mode
    */
    @AuraEnabled
    public static String checkCurrentJourneyMode (String strSourcingChannel, String strJourneyMode, String strStage) {
        if (strStage == AUSF_ApexConstants.AUSF_APP_STAGE_UW) {
            return AUSF_ApexConstants.AUSF_JOURNEY_MODE_ASSISTED;
        }
        if (strSourcingChannel != AUSF_ApexConstants.AUSF_DIY_CHANNEL && strJourneyMode == AUSF_ApexConstants.AUSF_JOURNEY_MODE_DIY) {
            return AUSF_ApexConstants.AUSF_JOURNEY_MODE_DIY;
        }
        else if (strSourcingChannel != AUSF_ApexConstants.AUSF_DIY_CHANNEL && strJourneyMode == '') {
            return AUSF_ApexConstants.AUSF_JOURNEY_MODE_DIY;
            //return AUSF_ApexConstants.AUSF_JOURNEY_MODE_ASSISTED;
        }
        else if (strSourcingChannel != AUSF_ApexConstants.AUSF_DIY_CHANNEL && strJourneyMode == AUSF_ApexConstants.AUSF_JOURNEY_MODE_ASSISTED) {
            return AUSF_ApexConstants.AUSF_JOURNEY_MODE_ASSISTED;
        }
        else if (strSourcingChannel == AUSF_ApexConstants.AUSF_DIY_CHANNEL && strJourneyMode == '') {
            return AUSF_ApexConstants.AUSF_JOURNEY_MODE_DIY;
        }   
        else if (strSourcingChannel == AUSF_ApexConstants.AUSF_DIY_CHANNEL && strJourneyMode == AUSF_ApexConstants.AUSF_JOURNEY_MODE_DIY) {
            return AUSF_ApexConstants.AUSF_JOURNEY_MODE_DIY;
        }
        else if (strSourcingChannel == AUSF_ApexConstants.AUSF_DIY_CHANNEL && strJourneyMode == AUSF_ApexConstants.AUSF_JOURNEY_MODE_ASSISTED) {
            return AUSF_ApexConstants.AUSF_JOURNEY_MODE_ASSISTED;
        }
        return '';
    }

    /*
    @description    - for session creation and screen details
    @param1         - strRecordId recordId
    @param2         - strCurrentScreen - Current Screen
    @param3         - blnCheckExisting - true when system identifies existing journey
    */ 
    @AuraEnabled
    public static WrapClass checkValidRecordScreen (String strRecordId, String strCurrentScreen, Boolean blnCheckExisting) {
        WrapClass objWrap = new WrapClass();
        try {
            blnCheckForLastActivity = false;
            objWrap = checkValidRecord (strRecordId, objWrap);
            if (!objWrap.blnSuccess) {
                throw new CustomException(objWrap.strMessage);
            }
            objWrap = getScreenDetails (objWrap.loanId, strCurrentScreen, objWrap, blnCheckExisting ? objWrap.lastVisitedPage : '');
            objWrap.blnSuccess = true;
        }
        catch(Exception ex){
            objWrap.blnSuccess = false;
            objWrap.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,strRecordId,'Others','Session Details');
        }
        return objWrap;
    }

    /*
    @description    - check for valid record, Journey and Session Timeout based on last activity
    @param1         - strRecordId recordId
    @param2         - objWrap - wrapper passed from parent method
    */ 
    @AuraEnabled
    public static WrapClass checkValidRecord (String strRecordId, WrapClass objWrap) {
        objWrap = objWrap == NULL ? new WrapClass() : objWrap;
        try {
            Id recordId = Id.valueOf(strRecordId);
            Datetime timeFilter = Datetime.now().addHours(-1 * Integer.valueOf(Integration_Static_Param__mdt.getInstance('DIY_Hour_Login_Hour_Limit').Param_Value__c));
            Integer intDIYLoginHours = Integer.valueOf(Integration_Static_Param__mdt.getInstance('DIY_Hour_Login_Hour_Limit').Param_Value__c) * 60;
            Integer offsetHours = 5;
            Integer offsetMinutes = 30;
            timeFilter = timeFilter.addHours(offsetHours).addMinutes(offsetMinutes);
            String encryptionKey =  Integration_Static_Param__mdt.getInstance('DIY_Login_Encryption_Key').Param_Value__c;

            String strObjectName = recordId.getSObjectType().getDescribe().getName();
            // Lead Record
            if (strObjectName == 'Lead_Stage__c') {
                objWrap.strObjectName = 'Lead_Stage__c';
                objWrap.leadId = recordId;
                List<Lead_Stage__c> lstLeadStage = [SELECT Id, Name, Journey_Mode__c, Sourcing_Channel__c, Loan_Application__c FROM Lead_Stage__c WHERE Id =: recordId];
                if (lstLeadStage.isEmpty()) {
                    objWrap.blnOTPInvalid = true;
                    throw new CustomException(Label.DIY_InvalidAuthorizationErrorMessage);
                }
                Lead_Stage__c objLead = lstLeadStage[0];
                objWrap.objLeadRecord = objLead;
                objWrap.strSessionId = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', Blob.valueOf(encryptionKey), Blob.valueOf(strRecordId)));
                objWrap.strAppJourney = checkCurrentJourneyMode(objLead.Sourcing_Channel__c, objLead.Journey_Mode__c, '');
            }
            // Application or Applicant Record
            else if (strObjectName == 'Loan_Application__c' || strObjectName == 'Applicant__c') {
                String strQuery = 'SELECT Id, Name, Mobile_Number__c, Loan_Application__c, Loan_Application__r.Name, Loan_Application__r.Mobile_Number__c, Loan_Application__r.Stage__c, Loan_Application__r.Last_Activity__c, ';
                strQuery = strQuery + 'Loan_Application__r.Last_visited_Page__c, Loan_Application__r.Journey_Mode__c, Loan_Application__r.Sourcing_Channel__c, IsActive__c FROM Applicant__c ';
                strQuery = strQuery + 'WHERE ';
                strQuery = strQuery + (strObjectName == 'Loan_Application__c' ? 'Loan_Application__c ' : 'Id ') + ' =: recordId';
                List<Applicant__c> lstApplicants = Database.query(strQuery);
                Applicant__c objApplicant = lstApplicants[0];
                objWrap.loanId = objApplicant.Loan_Application__c;
                objWrap.applicantId = objApplicant.Id;
                objWrap.objApplicant = objApplicant;
                objWrap.strObjectName = 'Applicant__c';
                objWrap.strAppJourney = objApplicant.Loan_Application__r.Journey_Mode__c;
                objWrap.lastVisitedPage = objApplicant.Loan_Application__r.Last_visited_Page__c;
                objWrap.strAppJourney = checkCurrentJourneyMode(objApplicant.Loan_Application__r.Sourcing_Channel__c, objApplicant.Loan_Application__r.Journey_Mode__c, objApplicant.Loan_Application__r.Stage__c);
                objWrap.strSessionId = EncodingUtil.base64Encode(Crypto.encryptWithManagedIV('AES256', Blob.valueOf(encryptionKey), Blob.valueOf(strRecordId)));
                Datetime lastActivityDate = objApplicant.Loan_Application__r.Last_Activity__c != NULL ? objApplicant.Loan_Application__r.Last_Activity__c : System.Now();
                lastActivityDate = lastActivityDate.addHours(offsetHours).addMinutes(offsetMinutes);
                // Calculate the difference in milliseconds (since Apex doesn't directly support seconds)
                Long differenceMilliseconds = timeFilter.getTime() - lastActivityDate.getTime();
                // Convert milliseconds to minutes
                Long differenceMinutes = differenceMilliseconds / (1000 * 60);
                differenceMinutes = differenceMinutes < 0 ? (differenceMinutes * -1) : differenceMinutes;
                if (differenceMinutes > intDIYLoginHours && false) { // blnCheckForLastActivity
                    objWrap.blnSessionExpired = true;
                    throw new CustomException(Label.DIY_SessionExpiredErrorMessage);
                }
            }
            else {
                throw new CustomException(Label.DIY_InvalidURLErrorMessage);
            }
            objWrap.blnSuccess = true;
        }
        catch(Exception ex) {
            objWrap.blnSuccess = false;
            objWrap.strMessage = ex.getMessage();
        }
        return objWrap;
    }



    public class WrapClass {
        @AuraEnabled
        public Applicant__c objApplicant;
        @AuraEnabled
        public Loan_Application__c objLA;
        @AuraEnabled
        public Lead_Stage__c objLeadRecord;
        @AuraEnabled
        public string leadId = '';
        @AuraEnabled
        public string strObjectName = '';
        @AuraEnabled
        public string loanId = '';
        @AuraEnabled
        public string applicantId = '';
        @AuraEnabled
        public Boolean blnGotoNextPage = false;
        @AuraEnabled
        public Boolean blnGoToPreviousPage = false;
        @AuraEnabled
        public String nextPageName = '';
        @AuraEnabled
        public String previousPageName = '';
        @AuraEnabled
        public String nextScreenName = '';
        @AuraEnabled
        public String previousScreenName = '';
        @AuraEnabled
        public String strMessage = '';
        @AuraEnabled
        public Boolean blnSuccess = false; 
        @AuraEnabled
        public Boolean blnNoActionOnCustomer = false;
        @AuraEnabled
        public Boolean blnSessionExpired = false;
        @AuraEnabled
        public Boolean blnOTPInvalid = false;
        @AuraEnabled
        public String lastVisitedPage = '';
        @AuraEnabled
        public Integer currentScreenOrder = 10;
        @AuraEnabled
        public Integer nextScreenOrder = 10;
        @AuraEnabled
        public String strAppJourney = '';
        @AuraEnabled
        public Boolean blnExistingJourney = false;
        @AuraEnabled
        public String currentScreenPageName = '';
        @AuraEnabled
        public String strSessionId = '';
    }

    public class WrapForSession {
        @AuraEnabled
        public String strMessage = '';
        @AuraEnabled
        public Boolean blnSuccess = false; 
        @AuraEnabled
        public String strSessionId = '';
    }

    public class CustomException extends Exception {}
}