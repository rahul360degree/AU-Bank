/**
** @author        Mohit M.
** @date          18-June-2024
** @description   Controller for integration container component on loan and applicant
** Modification Log:
** --------------------------------------------------------------------------------------------
** Developer                Date            Description
** --------------------------------------------------------------------------------------------
** Mohit M.                 18-June-2024    Original Version
*/
public without sharing class AUSF_IntegrationContainerController {
    /* Method to fetch integration status records for a loan/applicant. Depending on the parameter object name a dynamic query is created to
    * initiate status query. Related mapper fields are also part of the query as these are used for display on integration container component.
    * Before returning the integration status records, this method also removes the status records which aren't relevant for the stage.
    * Display only on Applicable Stages field on mapper indicates if a status record is relevant to any stage. For loan related integrations, the
    * stage name is derived by opportunity stage field. For applicants, stage is derived from all related loan applicants */
    public static User objCurrentUser;
    @AuraEnabled
    public static  List<Integration_Checklist__c> fetchIntegrationStatusDetails(List<String> recordIdList, String objectName, String caseRecordTypeName) {
        system.debug('@@recordIdList'+recordIdList);
        system.debug('@@objectName'+objectName);
        Set<String> loanStages = new Set<String>();
        Set<Id> appIdsSet = New Set<Id>();
        List<Integration_Checklist__c> applicableRecords = new List<Integration_Checklist__c>();
        Map<String, List<Integration_Checklist__c>> recIdstoIntStatusMap = new Map<String, List<Integration_Checklist__c>>();
        Map<String,Integration_Checklist__c> checklistMap = new Map<String,Integration_Checklist__c>();
        Map<String,Integration_Checklist__c> lastUpdatedRecordsMap = new Map<String,Integration_Checklist__c>();
        String queryString = 'SELECT Id, Response_Received_At__c, Status__c, Applicant__c, Integration_Master__r.Allow_Manual_Initiate_After__c, Integration_Master__r.Display_Level__c, '
            + 'Integration_Master__r.Allow_Refresh_After__c, Integration_Master__r.Allow_Retry__c, Integration_Master__r.Component_Reference__c, Integration_Master__r.Is_Mandatory__c, '
            + 'Integration_Master__r.Dependent_Integration__c, CreatedDate, Integration_Master__r.Allow_User_to_Print_Results__c, Integration_Master__r.Is_Fintech_API__c, Message__c, '
            + 'Integration_Master__r.User_Friendly_Label__c,Integration_Status_Label__c , Loan_Application__r.Stage__c, LastModifiedBy.Name, Missing_Pre_requisites__c, Request_Initiated_At__c, Is_Auto__c, Integration_Master__r.Allow_PE_Retry__c, '
            + 'Integration_Master__r.Allow_Refresh__c,Integration_Master__r.Allow_Rerun_For_Personas__c, LastModifiedDate, Integration_Master__r.Allow_Override__c '
            + 'FROM Integration_Checklist__c '
            + 'WHERE Integration_Master__r.User_Friendly_Label__c != NULL AND ';/*Is_Latest__c = true AND */
            //+ 'Integration_Master__r.Component_Reference__c != NULL AND ';
        if (objectName == 'Loan_Application__c') {
            for(Applicant__c app: [SELECT id FROM Applicant__c WHERE Loan_Application__c =: recordIdList]){
                appIdsSet.add(app.id);
            }
            queryString += '(Loan_Application__c IN: recordIdList OR Applicant__c IN: appIdsSet) order by lastModifiedDate Desc';
        }
        /*
        else if(objectName == 'Case') {
            for(Applicant__c app: [select id from Applicant__c where Loan_Application__c =: recordIdList]){
                appIdsSet.add(app.id);
            }
            List<String> rcuRelatedList = New List<String>();
            String rcuIntegrations;
            if(caseRecordTypeName == 'RCU_Review_Request_PL' || caseRecordTypeName == 'Hunter_Verification_Request'){
                rcuIntegrations = Integration_Mappings__mdt.getInstance('RCUIntegrationsPL').LOS_Value__c;
            }else{
                rcuIntegrations = Integration_Mappings__mdt.getInstance('RCUIntegrations').LOS_Value__c;
            }
            rcuRelatedList = rcuIntegrations.split(',');
            queryString += '(Loan_Application__c IN: recordIdList OR Applicant__c IN: appIdsSet) and Integration_Master__r.Name in: rcuRelatedList order by lastModifiedDate Desc';
        }
        */ 
        else {
            queryString += 'Applicant__c IN:recordIdList order by lastModifiedDate Desc';
            for (Applicant__c each : [SELECT Id, Loan_Application__r.Stage__c FROM Applicant__c WHERE Id IN :recordIdList WITH SECURITY_ENFORCED]) {
                loanStages.add(each.Loan_Application__r.Stage__c);
            }
        }


        List<Integration_Checklist__c> statusRecords = Database.query(String.escapeSingleQuotes(queryString));
        
        return statusRecords;
    }
    
    @AuraEnabled
    public static Integration_Checklist__c fetchIntegrationStatusRecord(String recordId) {
        for (Integration_Checklist__c each : [SELECT Id, Response_Received_At__c, Status__c, Applicant__c, Loan_Application__c, Integration_Master__r.Allow_Manual_Initiate_After__c,
                                           Integration_Master__r.Allow_Refresh_After__c, Integration_Master__r.Component_Reference__c,Integration_Master__r.Allow_Rerun_For_Personas__c,
                                           Integration_Master__r.Dependent_Integration__c, Integration_Master__r.Display_only_on_Applicable_Stages__c, CreatedDate,
                                           Integration_Master__r.User_Friendly_Label__c, Loan_Application__r.Stage__c, LastModifiedBy.Name, Missing_Pre_requisites__c, Request_Initiated_At__c, Is_Auto__c,
                                           Integration_Master__r.Allow_PE_Retry__c FROM Integration_Checklist__c WHERE Id = :recordId]) {
            return each;
        }
        return null;
    }
    
    @AuraEnabled
    public static ResponseWrapper fetchIntegrationStatusRecords(String recordId, String objectName) {
        ResponseWrapper responseWrapper = new ResponseWrapper();
        responseWrapper.commonStatusRecords = new List<Integration_Checklist__c>();
        Id rec = (Id) recordId;
        objectName = String.valueOf(rec.getsobjecttype());
        Map<String, List<Integration_Checklist__c>> recIdstoIntStatusMap = new Map<String, List<Integration_Checklist__c>>();
        Map<String,String> recIdtoNameMap = new Map<String,String>();
        List<String> recIdsList = new List<String>();
        Boolean showIntegrationSplit = false;
        Id parentLoanId;
        String caseRecordTypeName;		
        
        Map<String,String> oppIdAccessLevel = New Map<String,String>();
        
        if (objectName == 'Loan_Application__c') {
            /*
            for(OpportunityTeamMember otm: [Select UserId, OpportunityAccessLevel From OpportunityTeamMember 
                Where OpportunityId =: recordId]){
                    oppIdAccessLevel.put(otm.UserId,otm.OpportunityAccessLevel);
            }
            */
            recIdsList.add(recordId);
        }
        /*
        else if (objectName == 'Case') {
            Case cas = [select id,Loan_Application_ID__c, RecordType.DeveloperName from case where id =:recordId];
            caseRecordTypeName = cas.RecordType.DeveloperName;
            for(OpportunityTeamMember otm: [Select UserId, OpportunityAccessLevel From OpportunityTeamMember 
                Where OpportunityId =: cas.Loan_Application_ID__c]){
                    oppIdAccessLevel.put(otm.UserId,otm.OpportunityAccessLevel);
            }
            recIdsList.add(cas.Loan_Application_ID__c);
        }
        */
        else{
            Applicant__c app = [SELECT Id, Loan_Application__c FROM Applicant__c WHERE Id = :recordId];
            /*
            for(OpportunityTeamMember otm: [Select UserId, OpportunityAccessLevel From OpportunityTeamMember 
                Where OpportunityId =: app.Loan_Application__c]){
                    oppIdAccessLevel.put(otm.UserId,otm.OpportunityAccessLevel);
            }
            */
            recIdsList.add(recordId);
        }
        if(oppIdAccessLevel.get(UserInfo.getUserId()) <> null && oppIdAccessLevel.get(UserInfo.getUserId()) <> 'Read'){
            responseWrapper.isOwner = true;
        }
        if (objCurrentUser == NULL) {
            objCurrentUser = [SELECT Id, ManagerId, Profile.Name, email, username, usertype, communitynickname, timezonesidkey, languagelocalekey, firstname, lastname, phone, title,
            street, city, country, postalcode, state, localesidkey, mobilephone, extension, fax, contact.email FROM USER WHERE Id = : UserInfo.getUserId()];
            if (objCurrentUser.Profile.Name == 'System Administrator' || objCurrentUser.Profile.Name == 'Integration Admin') {
                responseWrapper.isOwner = true;
            }
        }
        List<Integration_Checklist__c> chkListRecs = fetchIntegrationStatusDetails(recIdsList, objectName, caseRecordTypeName);
        if (chkListRecs.isEmpty()) {
            responseWrapper.noRecords = true;
            return responseWrapper;
        }
        responseWrapper.individualStatusRecords = chkListRecs;
        responseWrapper.objectName = objectName;
        return responseWrapper;
    }

    @AuraEnabled
    public static Boolean isRecordEditable(Id recordId){
        // return UIFrameworkMasterController.isRecordEditable(recordId);
        return true;
    }

    
    @AuraEnabled
    public static Boolean manuallyCompleteIntegration(String intgChecklistId, String recordId, String remarks, List<Object> fileData){
        try {
            List<ContentVersion> files = new List<ContentVersion>();
            for(Object each : fileData){
                FileDataWrapper file = (FileDataWrapper)JSON.deserializeStrict(JSON.serialize(each), FileDataWrapper.class);
                files.add(new ContentVersion(VersionData = Blob.valueOf(file.fileContent), 
                Title = file.fileName, //Document_Type__c = 'Manually Uploaded Information', 
                PathOnClient = file.fileName, FirstPublishLocationId = intgChecklistId));  
            }
            insert files;

            Integration_Checklist__c checkList = new Integration_Checklist__c();
            checkList.Id = intgChecklistId;
            checkList.Override_Remarks__c = remarks;
            checkList.Override_API_Status__c = true;
            checkList.Status__c = 'Manually Completed';
            upsert checkList;
            return true;
        } catch (DmlException e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public class ResponseWrapper {
        @AuraEnabled public String objectName;
        @AuraEnabled public List<Integration_Checklist__c> commonStatusRecords;
        @AuraEnabled public List<Integration_Checklist__c> individualStatusRecords;
        @AuraEnabled public Boolean noRecords = false;
        @AuraEnabled public Boolean isOwner = false;
    }
    
    public class FileDataWrapper{
        public String fileName;
        public String fileContent;
        public string index;

    }
    
}