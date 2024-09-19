/**
* @author        Enuganti Ram
* Class :        AUSF_DelegatedAuthService
* Test Class     AUSF_DelegatedAuthServiceTest
* @date          23-June-2024
* @description   LDAP service used for authentication
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Enuganti Ram        23-June-2024    Initial Version
*/

@RestResource(urlMapping='/delegatedauth/*')
global with sharing class AUSF_DelegatedAuthService {
    static final Blob AUTH_TRUE = Blob.valueOf('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><AuthenticateResponse xmlns="urn:authentication.soap.sforce.com"><Authenticated>true</Authenticated></AuthenticateResponse></soapenv:Body></soapenv:Envelope>');
    static final Blob AUTH_FALSE = Blob.valueOf('<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"><soapenv:Body><AuthenticateResponse xmlns="urn:authentication.soap.sforce.com"><Authenticated>false</Authenticated></AuthenticateResponse></soapenv:Body></soapenv:Envelope>');
    static final String IDENTITY_CONNECT = 'https://YOUR_HOST_AND_PORT/openidm/info/login';
    @HttpPost
    global static void doPost() {
        Blob responseBody = AUTH_FALSE;
        RestRequest req = RestContext.request;
        Dom.Document doc = new Dom.Document();
        doc.load(req.requestBody.toString());
        Dom.XMLNode authRequest = doc.getRootElement();
        Dom.XMLNode body = authRequest.getChildElement('Body', 'http://schemas.xmlsoap.org/soap/envelope/');
        Dom.XMLNode authenticate = body.getChildElement('Authenticate', 'urn:authentication.soap.sforce.com');
        String username = authenticate.getChildElement('username', 'urn:authentication.soap.sforce.com').getText();
        String password = authenticate.getChildElement('password', 'urn:authentication.soap.sforce.com').getText();
        String sourceIp = authenticate.getChildElement('sourceIp', 'urn:authentication.soap.sforce.com').getText();
        if(username.contains('@')){
            username = username.split('@')[0];
        }
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_LDAP_IDAM_INTEGRATION_MASTER);
        String strPwd = password;
        String strPrivateKey = objIntMapper.Encryption_Key__c;
        Blob key = Blob.valueOf(strPrivateKey);
        Blob blobPwd = Blob.valueOf(strPwd);
        String strIv = EncodingUtil.convertToHex(key);
        Blob ivfinal = EncodingUtil.convertFromHex(strIv.left(32));
        Blob encrypted = Crypto.encrypt('AES128', key, ivfinal, blobPwd);
        String strPasswordEncrypted = EncodingUtil.base64Encode(encrypted);
        Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
        newChecklistInstance.Integration_Master__c = objIntMapper.Id;
        AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
        inputData.integrationChecklistRecord = newChecklistInstance;
        inputData.integrationMasterRecord = objIntMapper;
        inputData.dynamicInputs = new Map<String, Object>();
        inputData.dynamicInputs.put('UserId', username);
        inputData.dynamicInputs.put('Password', strPasswordEncrypted);
        inputData.dynamicInputs.put('Channel', objIntMapper.Channel__c);
        AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
        AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails  = utilityInstance.constructRequest(inputData);
        String objectId = '';
        AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
        calloutRequestWrapper.request = requestDetails.request;
        calloutRequestWrapper.method = objIntMapper.HTTP_Method__c;
        calloutRequestWrapper.masterRecord = objIntMapper;
        calloutRequestWrapper.checklistRecord = newChecklistInstance;
        AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);   
        AUSF_INT_IntegrationResponseWrapper.ResponseWrapper resp = calloutResponseWrapper;
        String respBody = calloutResponseWrapper.response;
        if(calloutResponseWrapper.statusCode == 200){
            calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
            upsert calloutResponseWrapper.checklistRecord;
        }
        else {
            calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
            upsert calloutResponseWrapper.checklistRecord;
            
        }
        String returnValue;
        JSONParser parser = JSON.createParser(respBody);
        while (parser.nextToken() != null) {
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) && (parser.getText() == 'return')) {
                parser.nextToken();
                returnValue = parser.getText();
            }
        }
       RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/soap+xml');
        res.statusCode = 200;
        if(returnValue == 'true'){
            res.responseBody = AUTH_TRUE;
        }
        else{
            res.responseBody = AUTH_FALSE;
        }
        
    }
    
}