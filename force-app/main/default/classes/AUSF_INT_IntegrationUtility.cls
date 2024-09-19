/**
* @author        Mohit M.
* @date          18-June-2024
* @description   Utility class that provides methods for encryption & header generation
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Mohit M.              18-June-2024    Initial Version
  Pradeep Sharma        18-July-2024    added mogrifyJSON method
  Pradeep Sharma        22-July-2024    added getAccountTypes Method
  Pradeep Sharma        31/07/2024      added getParamsValue MEthod
*/
public without sharing class AUSF_INT_IntegrationUtility {
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper initiateCallout(AUSF_INT_IntegrationRequestWrapper.RequestWrapper requestInstance) {
        if (requestInstance.masterRecord == null) {
            throw new HandledException('Integration Master details are mandatory for initiating an interface');
        }
        if (String.isBlank(requestInstance.masterRecord.HTTP_Method__c)) {
            throw new HandledException('Method is mandatory for initiating an interface');
        }
        if (String.isBlank(requestInstance.masterRecord.End_Point_URL__c)) {
            throw new HandledException('Endpoint URL is mandatory. Update these details in master or in the input parameters');
        }
        AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseInstance = new AUSF_INT_IntegrationResponseWrapper.ResponseWrapper();
        HTTPResponse response;
        Boolean isBlobRequest = false;
        Integration_Checklist__c checklistRecord = requestInstance.checklistRecord;
        checklistRecord.Is_Latest__c = true;
        checklistRecord.Integration_Master__c = requestInstance.masterRecord.Id;
        try {
            // Check for Re Run Options
            responseInstance = getReRunOptions(requestInstance);
            system.debug(LoggingLevel.Info,'getReRunOptions ' + responseInstance);
            if(!(responseInstance.isRetryAllowed || responseInstance.isReinitiateAllowed)){
                return responseInstance;
            }
            HttpRequest request = new HttpRequest();
            request.setMethod(requestInstance.masterRecord.HTTP_Method__c);
            String urlQueryParams;
            if (requestInstance.masterRecord.HTTP_Method__c == 'GET' && requestInstance.urlParamsMap != null) {
                urlQueryParams = generateURLQueryParams(requestInstance.urlParamsMap);
            }
            
            Integer intTimeOut = Integer.valueOf(requestInstance.masterRecord.Timeout__c != NULL ? requestInstance.masterRecord.Timeout__c : requestInstance.timeOut);
            request.setTimeout(intTimeOut);
            if (requestInstance.masterRecord.Include_Certificate__c) {
                request.setClientCertificateName(AUSF_ApexConstants.DEFAULT_CERTIFICATE_NAME);
            }
            if(String.isNotBlank(urlQueryParams)){
                request.setEndPoint(requestInstance.masterRecord.End_Point_URL__c + urlQueryParams);
                checklistRecord.Request__c = urlQueryParams;
            }else{
                request.setEndPoint(requestInstance.masterRecord.End_Point_URL__c);
            }
            request.setHeader('content-type', String.isNotBlank(requestInstance.masterRecord.Content_Type__c) ? requestInstance.masterRecord.Content_Type__c : requestInstance.contentType);

            if (requestInstance.headersMap != null && !requestInstance.headersMap.isEmpty()) {
                for (String header : requestInstance.headersMap.keySet()) {                        
                    request.setHeader(header, requestInstance.headersMap.get(header));
                }
            }
            if (requestInstance.masterRecord != null && requestInstance.masterRecord.Interface_Inputs__r != null) {
                for (Interface_Inputs__c each : requestInstance.masterRecord.Interface_Inputs__r) {
                    if (each.RecordType.DeveloperName != 'Header_Parameters') {
                        continue;
                    }
                    request.setHeader(each.Parameter_Name__c, each.Parameter_Value__c);
                }
            }
            if (requestInstance.isBasicAuth) {
                Blob headerValue = Blob.valueOf(requestInstance.username + ':' + requestInstance.password);
                request.setHeader('Authorization', 'Basic ' +  EncodingUtil.base64Encode(headerValue));
            }
            if (String.isNotBlank(requestInstance.bearerAuthorizationHeader)) {
                request.setHeader('Authorization', 'Bearer ' +  requestInstance.bearerAuthorizationHeader);
            }

            if(requestInstance.request != null) {
                request.setBody(requestInstance.request);
            }

            if(requestInstance.requestBlob != null) {
                request.setBodyAsBlob(requestInstance.requestBlob);
                isBlobRequest = true;
            }

            checklistRecord.Request_Initiated_At__c = System.now();
            if (requestInstance.captureRequestInAttachment) {
                checklistRecord.Is_Request_In_Attachment__c = true;
            } else {
                 // If block is is used to mask the sensitive data in the request
                 if(requestInstance.encryptChecklistRequest <> null && requestInstance.encryptChecklistRequest){
                    Type t = Type.forName(requestInstance.dataMaskingClass);
                    AUSF_DataMaskingInterface d = (AUSF_DataMaskingInterface)t.newInstance();
                    checklistRecord.Request__c = requestInstance.masterRecord.HTTP_Method__c != 'GET' ? d.maskRequest(requestInstance.request) : checklistRecord.Request__c;
                }else{
                    checklistRecord.Request__c = requestInstance.masterRecord.HTTP_Method__c != 'GET' ? requestInstance.request : checklistRecord.Request__c;
                }
            }
            Http http = new Http();
            if (!requestInstance.masterRecord.Disable_api__c) {
                response = http.send(request);
                if (response.getStatusCode() < 200 || response.getStatusCode() > 299) { 
                    checklistRecord.Status__c = 'Failed';
                } else {    
                    checklistRecord.Status__c = 'Completed'; // trigger layer uses callback service to set this to failed if response is not intact 
                    system.debug(LoggingLevel.DEBUG,'Response : ' + response.getBody());
                    if(response.getBody().length() >= 131072){
                        requestInstance.captureResponseInAttachment = true;
                    }
                }
            }
            if (requestInstance.returnHardcodedResponse || requestInstance.masterRecord.Disable_api__c) { // setting this for mock responses
                checklistRecord.Status__c = 'Completed'; 
            }
        } catch(CalloutException ex) {
            // no logging required here because we're already capturing this in Integration Checklist
            checklistRecord.Status__c = 'Failed';
            checklistRecord.Response__c = String.valueOf(response);
            if (ex.getMessage().contains('Read timed out')) {
                checklistRecord.Request__c = requestInstance.request;
                checklistRecord.Response__c = 'Read timed out';
            }
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,'','Integration',requestInstance.masterRecord.Name);
            system.debug(LoggingLevel.ERROR,'Exception ' + ex + ' at line ' + ex.getLineNumber());
            //throw ex;
        } catch (Exception ex) {
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,'','Integration',requestInstance.masterRecord.Name);
            system.debug(LoggingLevel.ERROR,'Exception ' + ex + ' at line ' + ex.getLineNumber());
            //throw ex;
        }
        checklistRecord.Response_Received_At__c = System.now();

        // Below code for mock responses - remove after interfaces are in place
        String responseHardcoded = '';
        if ((requestInstance.returnHardcodedResponse || requestInstance.masterRecord.Disable_api__c) && requestInstance.masterRecord.Static_Response__c != '') {
            responseHardcoded = requestInstance.masterRecord.Static_Response__c;
        }
        if (requestInstance.captureResponseInAttachment) {
            checklistRecord.Is_Response_In_Attachment__c = true;
        } else {
                checklistRecord.Response__c = String.isNotBlank(responseHardcoded) ? responseHardcoded : response?.getBody();
        }
        responseInstance.checklistRecord = checklistRecord;
        if (String.isNotBlank(responseHardcoded)) {
            responseInstance.statusCode = 200;
            responseInstance.response = responseHardcoded;
            responseInstance.checklistRecord.Status__c = 'Completed';
        } else {
            responseInstance.statusCode = response?.getStatusCode();
            responseInstance.response = response?.getBody();
        }

        if (requestInstance.performDML) {
            if (String.isNotBlank(checklistRecord.Request_Id__c)) {
                upsert checklistRecord Request_Id__c;
            }
            else {
                upsert checklistRecord;
            }
            
            responseInstance.checklistRecord.Id = checklistRecord.Id;
        }
        

        if ((requestInstance.captureRequestInAttachment || requestInstance.captureResponseInAttachment) && requestInstance.performDML) {
            List<ContentVersion> calloutDetails = new List<ContentVersion>();
            if (requestInstance.captureRequestInAttachment) {
                calloutDetails.add(new ContentVersion(VersionData = (isBlobRequest ? requestInstance.requestBlob : Blob.valueOf(requestInstance.request)), Title = 'Request', Document_Type__c = 'Callout Request', PathOnClient = 'Request.txt', FirstPublishLocationId = checklistRecord.Id));
            }
            if (requestInstance.captureResponseInAttachment) {
                calloutDetails.add(new ContentVersion(VersionData = Blob.valueOf(String.isNotBlank(responseHardcoded) ? responseHardCoded : response.getBody()), Title = 'Response', Document_Type__c = 'Callout Response', PathOnClient = 'Response.txt', FirstPublishLocationId = checklistRecord.Id));
            }
            upsert calloutDetails;
        }
        return responseInstance;
    }
    
    /*
    @description    - run logic to check rerun
    @param1         - requestInstance - request wrapper
    */
    public AUSF_INT_IntegrationResponseWrapper.ResponseWrapper getReRunOptions(AUSF_INT_IntegrationRequestWrapper.RequestWrapper requestInstance){
        AUSF_INT_IntegrationResponseWrapper.ResponseWrapper responseInstance = new AUSF_INT_IntegrationResponseWrapper.ResponseWrapper();
        responseInstance.isRetryAllowed = true;        
        responseInstance.isReinitiateAllowed = true;
        Map<String, String> mapTargetField = new Map<String, String>{'Loan_Application__c' => 'Loan_Application__c', 'Applicant__c' => 'Applicant__c','Lead_Stage__c' => 'Lead_Stage__c'};
        //retry logic
        if(requestInstance.entityId != null){
            String objectApiName = requestInstance.entityId.getSObjectType().getDescribe().getName();
            String targetField = mapTargetField.containsKey(objectApiName) ? mapTargetField.get(objectApiName) : null;
            if(targetField == null){
                return null;
            }
            Id intngMasterId = requestInstance.masterRecord.Id;
            Id objId = requestInstance.entityId;
            String queryString = 'Select Id,Response_Received_At__c,Status__c,Integration_Master__r.Max_number_of_retries_allowed__c,Integration_Master__r.Max_No_Of_Reinitiates_Allowed__c,Integration_Master__r.Allow_Retry__c,Integration_Master__r.Allow_Reinitiate__c,Integration_Master__r.Reinitiate_Customer_Message__c,Integration_Master__r.Reinitiate_Internal_Message__c,Integration_Master__r.Retry_Customer_Message__c,Integration_Master__r.Retry_Internal_Message__c from Integration_Checklist__c where Integration_Master__c=:intngMasterId and '+targetField+' =:objId Order By Response_Received_At__c DESC NULLS Last';
            List<Integration_Checklist__c> lstChecklist = Database.query(queryString);
            if(!lstChecklist.isEmpty()){
                Integer todayexecutedCount = 0; 
                Integer totalexecutedCount = 0;
                for(Integration_Checklist__c checklist : lstChecklist){
                    if(checklist.Status__c == 'Failed'){
                        if(checklist.Response_Received_At__c != null && checklist.Response_Received_At__c.date() == System.today()){
                            todayexecutedCount++;
                        }
                    }
                    if(checklist.Status__c != 'Failed'){
                        totalexecutedCount++;
                    }
                }
                Integration_Master__c master = lstChecklist[0].Integration_Master__r;
                //most recent attempt is failed
                if(lstChecklist[0].Status__c == 'Failed'){
                    //retry attempt exceeded
                    if(master.Allow_Retry__c && master.Max_number_of_retries_allowed__c != NULL && !(master.Allow_Retry__c && todayexecutedCount < master.Max_number_of_retries_allowed__c)){
                        //guest user
                        if (Auth.CommunitiesUtil.isGuestUser()){
                            responseInstance.errorMessage = String.isNotBlank(master.Retry_Customer_Message__c) ? master.Retry_Customer_Message__c : System.label.Generic_Retry_Error_Message;
                        }else{
                            responseInstance.errorMessage = String.isNotBlank(master.Retry_Internal_Message__c) ? master.Retry_Internal_Message__c : System.label.Generic_Retry_Error_Message;
                        }
                        responseInstance.isRetryAllowed = false;
                        return responseInstance;
                    }
                } else {
                    if(master.Allow_Reinitiate__c && master.Max_No_Of_Reinitiates_Allowed__c!= NULL && !(master.Allow_Reinitiate__c && totalexecutedCount < master.Max_No_Of_Reinitiates_Allowed__c)){
                        //false and 1 <0
                        //guest user
                        responseInstance.isReinitiateAllowed = false;
                        if (Auth.CommunitiesUtil.isGuestUser()){
                            responseInstance.errorMessage = String.isNotBlank(master.Reinitiate_Customer_Message__c) ? master.Reinitiate_Customer_Message__c : System.label.Generic_ReInitiate_Message_Guest;
                        }else{
                            responseInstance.errorMessage = String.isNotBlank(master.Reinitiate_Internal_Message__c) ? master.Reinitiate_Internal_Message__c : System.label.Generic_ReInitiate_Error_Message_Internal;
                        }
                        responseInstance.isReinitiateAllowed = false;
                        return responseInstance;
                    }
                }
            }
        }
        return responseInstance;
    }

    /*
    @description    - this method call the handler to identify the pre-requisites and generate request
    @param1         - inputWrapper - wrapper passed from parent controller
    */
    public AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper constructRequest(InputWrapper inputWrapper) {
        if (inputWrapper == null) {
            throw new HandledException('Input details are mandatory for constructing request');
        }
        if (String.isBlank(inputWrapper.integrationMasterRecord.Apex_Class_Name__c)) {
            throw new HandledException('Handler name is mandatory for constructing request. Please update in master');
        }
        AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper responseInstance = new AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper();
        AUSF_INT_IntegrationHandlerInterface service = (AUSF_INT_IntegrationHandlerInterface) Type.forName(inputWrapper.integrationMasterRecord.Apex_Class_Name__c).newInstance();
        List<String> preReqs = service.validateInputData(new List<Object>{inputWrapper});
        responseInstance.preRequisites = preReqs != null && preReqs.size() > 0 ? preReqs.get(0) : null;
        if (String.isBlank(responseInstance.preRequisites)) {
            List<Object> requestStrings = service.generateRequest(new List<Object>{inputWrapper});
            responseInstance.request = requestStrings != null && !requestStrings.isEmpty() ? (String) requestStrings.get(0) : null;
        }
        return responseInstance;
    }
    
    /*
    @description    - Enryption
    */
    public static Blob encryptData(String algorithmName, Blob privateKey, Blob initializationVector, Blob clearText){
        return Crypto.encrypt(algorithmName,privateKey,initializationVector,clearText);
    }
    
    /*
    @description    - Decryption
    */
    public static blob decryptData(String algorithmName, Blob privateKey, Blob initializationVector, Blob clearText){
        return Crypto.decrypt(algorithmName,privateKey,initializationVector,clearText);
    }

    /*
    @description    - Query on Integration Master based on Name
    @param1         - name - Integration Master Name
    */
    public static Integration_Master__c getIntegrationMasterRecord(String name){
        Integration_Master__c objIntMapper;
        objIntMapper = [
            SELECT id, Name, End_Point_URL__c, IV__c, Encryption_Key__c,HTTP_Method__c,Timeout__c, Include_Certificate__c, Disable_api__c, Channel__c, Content_Type__c, Apex_Class_Name__c, Static_Response__c, Static_Response_Name__c, 
            (SELECT Parameter_Name__c, Parameter_Value__c, RecordType.DeveloperName FROM Interface_Inputs__r)  
            FROM Integration_Master__c
            WHERE Name = :name and Active__c = true
            LIMIT 1
        ];
        return objIntMapper;
    }

    /*
    @description    - Query on Integration Checklist based on recordId
    @param1         - icRecordId - IC recordId
    */
    public static Integration_Checklist__c getIntegrationChecklist(Id icRecordId){
        List<Integration_Checklist__c>  lstIC = [SELECT ID, Name FROM Integration_Checklist__c WHERE ID =: icRecordId LIMIT 1];
        return lstIC.isEmpty() ? NULL : lstIC[0];
    }

    /*
    @description    - get the reference Id passed in request body
    */
    public static String getReferenceId(){
        Integer charLength = 25;
        String hashString = '1000' + String.valueOf(Datetime.now().formatGMT('yyyy-MM-dd HH:mm:ss.SSS'));
        Blob hash = Crypto.generateDigest('MD5', Blob.valueOf(hashString));
        String hexDigest = EncodingUtil.convertToHex(hash).left(charLength);
       // return 'SFDCDEV'+'_'+hexDigest;
       return label.SFPLAPIORGIDENTIFIER+'_'+hexDigest;
    }

    /*
    @description - bind URL parameter in case of "GET" HTTP method
    */
    public static String generateURLQueryParams(Map<String,String> urlParamsMap){
        String strURLQueryParams;
        if(urlParamsMap != null){
            for(String strURLQueryParam : urlParamsMap.keySet()){
                if(strURLQueryParams!=null){
                    strURLQueryParams += strURLQueryParam + '=' + urlParamsMap.get(strURLQueryParam)+ '&';
                }else{
                    strURLQueryParams = strURLQueryParam + '=' + urlParamsMap.get(strURLQueryParam) + '&';
                }
            }
        }
        //remove & from the URL end
        if(strURLQueryParams.endsWith('&')){
            strURLQueryParams = strURLQueryParams.removeEnd('&');
        }
        return strURLQueryParams;
    }

    // This method is used to replace reserved words in JSON
    public static String mogrifyJSON(String data, Map<String, String> replacements) {
       String regexFormat = '(?m)^\\s*"{0}"\\s*:';
        String replacementFormat = '"{0}" :';
        String formattedJSON = JSON.serializePretty(JSON.deserializeUntyped(data));
        for (String key : replacements.keySet()) {
            String regex = String.format(
                regexFormat,
                new List<String> {key}
            );
            String replacement = String.format(
                replacementFormat,
                new List<String> {replacements.get(key)}
            );
            // Find all and replace
            formattedJSON = formattedJSON.replaceAll(regex, replacement);
        }
        return formattedJSON;
    }
    //AccountType tagging of Dedupe api
    public static Map<String,String> getAccountTypes(){
        return new Map<String,String>{'1'=>'ACCOUNT CLOSED','2'=>'ACCOUNT BLOCKED','3'=>'ACCOUNT OPEN - NO DEBIT','4'=>'ACCOUNT OPEN - NO CREDIT',
            '5'=>'ACCOUNT CLOSED TODAY','6'=>'ACCOUNT OPENED TODAY','7'=>'ACCOUNT DORMANT','8'=>'ACCOUNT OPEN REGULAR','9'=>'ACCOUNT INOPERATIVE',
            '10'=>'ACCOUNT BLOCKED DORMANT','11'=>'ACCOUNT DORMANT - NO DEBIT','12'=>'ACCOUNT DORMANT - NO CREDIT','13'=>'ACCOUNT INOPERATIVE BLOCKED','14'=>'ACCOUNT INOPERATIVE - NO DEBIT',
        '15'=>'ACCOUNT INOPERATIVE - NO CREDIT','16'=>'ACCOUNT OPEN - DEBIT WITH OVERRIDE','17'=>'ACCOUNT OPEN - CREDIT WITH OVERRIDE'};
    }

    public class IntegrationMessageWrapper {
        public String integrationChecklistId;
        public String request;
        public String svcName;
        public String status;
        public String clientId;
        public String execMode;
        public String ReqDocId;
        public Boolean isLatest;
    }

    // Wrapper class used for all generate platform events methods in integration handlers
    public class InputWrapper {
        public Applicant__c applicantRecord;
        public Integration_Checklist__c integrationChecklistRecord;
        public Integration_Master__c integrationMasterRecord;
        public Loan_Application__c loanRecord;
        public Object dynamicQueryInput;
        public List<Applicant__c> relatedApplicants;
        public Map<String, Object> dynamicInputs;
        public Map<String, String> defaultData;
        public Lead_Stage__c leadStageRecord; //Added By Tejendra on 27-06-2024
        public List<Document_Checklist__c> lstDocChecklist;
    }
    //Method to get params value for static params Metadata
    public static Map<String,String> getParamsValue(String masterName){
        Map<String,String> paramsValueMap = new Map<String,String>();
        for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c
                                                                           FROM Integration_Static_Param__mdt
                                                                           WHERE API_Name__c = :masterName]){
            paramsValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
        }
        return paramsValueMap;
    }
}