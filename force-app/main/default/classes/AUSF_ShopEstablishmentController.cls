/**
* @author        Enuganti Ram
* @date          07-July-2024
* @description   Fetch Shop Establishment details Controller class
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Enuganti Ram              07-July-2024    Initial Version - APL-204
*/
public without sharing class AUSF_ShopEstablishmentController {
    
    /*
@description    : fetchshopestablishdetails - Fetch Shop establish details service method
@param1         : applicantId - Applicant Record Id
@param2         : registrationNo - registration number
@param3         : areaCode  - area code
@param4         : employmentId - Employment Id
@return         : Wrapper class contains return result
*/
    
    @AuraEnabled
    public static ShopEstablishmentWrapper getShopAndEstablish(String applicantId, String registrationNo, string areaCode, String employmentId){
        ShopEstablishmentWrapper objResponse = new ShopEstablishmentWrapper();
        Applicant__c objApplicant;
        try{
            Map<String, String> paramValueMap = new Map<String, String>();
            for(Integration_Static_Param__mdt integrationStaticParamObj : [SELECT API_Name__c, Param_Name__c, Param_Value__c 
                                                                           FROM Integration_Static_Param__mdt 
                                                                           WHERE API_Name__c =: AUSF_ApexConstants.AUSF_SHOP_ESTABLISH_INTEGRATION_MASTER]){
                                                                               paramValueMap.put(integrationStaticParamObj.Param_Name__c,integrationStaticParamObj.Param_Value__c);
                                                                           }
            objApplicant = [SELECT Id FROM Applicant__c where Id =: applicantId limit 1];
            Integration_Checklist__c checklistRecord = new Integration_Checklist__c(Applicant__c = objApplicant.Id);
            Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_SHOP_ESTABLISH_INTEGRATION_MASTER);
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicantId;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = objApplicant;
            inputData.dynamicInputs = createRequestDynamicInputData(registrationNo,areaCode,paramValueMap,objIntMapper);
            newChecklistInstance.Request_Id__c =JSON.serialize(inputData.dynamicInputs.get('requestid')).replace('"','');
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            system.debug('requestDetails'+requestDetails);
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(newChecklistInstance.Id);
                throw new CustomException(requestDetails.preRequisites+'-'+objChecklist.Name);
            }
            AUSF_INT_ShopEstablishResponseWrapper objShopEstablishmentResponse = new AUSF_INT_ShopEstablishResponseWrapper(); 
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper;
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = objApplicant.Id;
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            //Check for api hit limit restrictions for user
            if (calloutResponseWrapper.errorMessage!=null) {    
                objResponse.strIntMessage = calloutResponseWrapper.errorMessage;
                throw new CustomException (objResponse.strIntMessage);
            }
            // Check for HTTP Status Code
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299 || calloutResponseWrapper == NULL || calloutResponseWrapper.response == NULL || calloutResponseWrapper.response.startsWithIgnoreCase('<html>') || calloutResponseWrapper.response.startsWithIgnoreCase('<xml>') || calloutResponseWrapper.errorMessage!=null) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                Integration_Checklist__c objChecklist1 = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - '+objChecklist1.Name;
                throw new CustomException(objResponse.strIntMessage);
            }else  {
                objShopEstablishmentResponse = (AUSF_INT_ShopEstablishResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_INT_ShopEstablishResponseWrapper.class);
                objShopEstablishmentResponse.responseWrapper = calloutResponseWrapper; 
                objResponse.shopEstablishmentResponseWrap = objShopEstablishmentResponse;
                //Check for api status code
                if(objShopEstablishmentResponse != NULL && objShopEstablishmentResponse.result != NULL && objShopEstablishmentResponse.statusCode == 101 && objShopEstablishmentResponse.result.ownerName != NULL){
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    upsert calloutRequestWrapper.checklistRecord;
                    objResponse.blnIntegrationSuccess = true;
                    String addressObjId = '';
                    objResponse.addressId = addressObjId;
                    InnerWrapper objWrap = upsertEmploymentDetailRecord(registrationNo,employmentId,objApplicant,objShopEstablishmentResponse);
                    objResponse.addressId = objWrap.addressId ;
                    objResponse.employmentId = objWrap.employmentDetailId;
                    
                }else{
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    upsert calloutResponseWrapper.checklistRecord;
                    Integration_Checklist__c objChecklist2 = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                    objResponse.strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - '+objChecklist2.Name;
                    throw new CustomException(objResponse.strIntMessage);
                }
            }
            objResponse.blnSuccess = true;
            
        }
        catch (Exception ex) {
            System.debug('ex.getMessage()='+ex.getMessage());
            System.debug('ex.getLineNUmber()='+ex.getLineNUmber());
            objResponse.strMessage = ex.getMessage();
            AUSF_Log.error(ex, AUSF_Log.SeverityType.High,objApplicant.Id,'Applicant',AUSF_ApexConstants.AUSF_SHOP_ESTABLISH_INTEGRATION_MASTER);
            
        }
        return objResponse;
    }
    /*
@description    : upsertEmploymentDetailRecord - upsert employment detail & Address records
@param1         : employmentId - employment detail record id
@param2         : objApplicant - Applicant Record
@param3         : objShopEstablishmentResponse - AUSF_INT_ShopEstablishResponseWrapper wrapper object
@param4         : addressObjId - Address record id
@return         : String
*/
    public static InnerWrapper upsertEmploymentDetailRecord(string registrationNo,String employmentId, Applicant__c objApplicant, AUSF_INT_ShopEstablishResponseWrapper objShopEstablishmentResponse){
        InnerWrapper objWrap = new InnerWrapper();
        Address__c addr = new Address__c();
        Employment_Detail__c employmentDetail = new Employment_Detail__c();
        boolean isNameMatchCall = true;
    String recordTypeId_ShopEstablish = [SELECT Id, Name, DeveloperName, SobjectType, IsActive FROM RecordType WHERE SobjectType ='Employment_Detail__c' AND DeveloperName ='SEC' LIMIT 1][0].Id;

        if(String.isBlank(employmentId)){
            employmentDetail.Applicant__c = String.isNotBlank(objApplicant.Id)?objApplicant.Id:null;
        }
        else{
            // Id Assignment and Old Attach Address is making inactive.
            employmentDetail = [SELECT Id, Name, Address__c from Employment_Detail__c where Id = :employmentId];
            if(employmentDetail.Address__c != null)
            {
                Address__c oldAdr = new Address__c(Id = employmentDetail.Address__c, Active__c = false);
                update oldAdr;
            }
            isNameMatchCall =  employmentDetail.Owner_Name__c == objShopEstablishmentResponse.result.ownerName ? false : true ; // if Exsiting Owner Name Is equal to Response Name Then we no need to call Name Match API.
            
        }
        if(objShopEstablishmentResponse.result != NULL && objShopEstablishmentResponse.result.splitaddress!=null){
            addr = AUSF_AddressSplitUtilty.addressSplitOnSuccess(objShopEstablishmentResponse.result.splitaddress,objApplicant.Id);
        }
        else if (objShopEstablishmentResponse.result != NULL && objShopEstablishmentResponse.result.address!=null){
            addr = AUSF_AddressSplitUtilty.addressSplitOnFailure(objShopEstablishmentResponse.result.address,objApplicant.Id);
        }
        addr.Address_Type__c = AUSF_ApexConstants.AUSF_ADDRTYPE_WORK;
        addr.Address_Source__c = AUSF_ApexConstants.AUSF_BUSINESSOWNERSHIPPROOF;
        if (addr.Applicant__c != NULL)
        {
            insert addr;
            objWrap.addressId = addr.Id;  
        }
        employmentDetail.Id = String.isBlank(employmentId) ? NULL : employmentId;
        employmentDetail.Address__c  = addr.Id;
        employmentDetail.Document_Number__c	=registrationNo;
        employmentDetail.RecordTypeId = recordTypeId_ShopEstablish ;      
         if(objShopEstablishmentResponse.result != NULL){
            employmentDetail.Date_of_Incorporation__c = String.isNotbLANK(objShopEstablishmentResponse.result.commenceDate ) ? Date.parse(objShopEstablishmentResponse.result.commenceDate ) : NULL;
            employmentDetail.Registered_Business_name__c = objShopEstablishmentResponse.result.entityName;
            employmentDetail.Owner_Name__c = objShopEstablishmentResponse.result.ownerName;
            if(objShopEstablishmentResponse.result.status == 'Active'){
                employmentDetail.Business_Proof_Validity__c = true;
            }else{
                employmentDetail.Business_Proof_Validity__c = false;
            }
            if(objShopEstablishmentResponse.result.address != NULL && String.isNotBlank(objShopEstablishmentResponse.result.address)){
                employmentDetail.Business_Address_Validity__c = true;
            }else{
                employmentDetail.Business_Address_Validity__c = false;
            }
            if(String.isNotBlank(objShopEstablishmentResponse.result.commenceDate)){
                Date apiDate = date.parse(objShopEstablishmentResponse.result.commenceDate);
                Integer apiDateMonth = apiDate.month();
                Date currentDate = date.today();
                Integer currentDateMonth = currentDate.month();
                Integer monthDifference = apiDateMonth - currentDateMonth;
                Integer vintageYears = apiDate.monthsBetween(currentDate)/12;
                employmentDetail.Business_Vintage_Years__c = String.valueOf(vintageYears);
                employmentDetail.Business_Vintage_Months__c = String.valueOf(math.abs(monthDifference));
            }
            objWrap.employmentDetailId = employmentDetail.Id;
            upsert employmentDetail;
        }
        //check for employment record Null values
        if(employmentDetail.Date_of_Incorporation__c != NULL && String.IsNotBlank(employmentDetail.Owner_Name__c)){
            //check for applicant and employment record null values
            if(isNameMatchCall && String.isNotBlank(objApplicant.Full_Name__c) && String.isNotBlank(employmentDetail.Owner_Name__c) && String.isNotBlank(objApplicant.Id)){
                Id JobId = System.enqueueJob(new AUSF_QueuableUtility(objApplicant,employmentDetail));
            }
        }
        return objWrap;
    }
    
    public class InnerWrapper{
        public String addressId;
        public String employmentDetailId;
    }
    
    public static Map<String,String> createRequestDynamicInputData(String registrationNo,String areaCode,Map<String,String> paramValueMap,Integration_Master__c objIntMapper){
        Map<String,String> dynamicInputs = new Map<String,String>();
        dynamicInputs.put('requestid', AUSF_INT_IntegrationUtility.getReferenceId());
        dynamicInputs.put('channel', objIntMapper.Channel__c);
        dynamicInputs.put('consent',paramValueMap.get('consent'));
        dynamicInputs.put('regNo',registrationNo);
        dynamicInputs.put('areaCode',areaCode);
        dynamicInputs.put('pdfRequired',paramValueMap.get('pdfRequired'));
        return dynamicInputs; 
    }
    
    public class ShopEstablishmentWrapper {
        @AuraEnabled
        public AUSF_INT_ShopEstablishResponseWrapper shopEstablishmentResponseWrap {get;set;}
        @AuraEnabled
        public String employmentId {get;set;}
        @AuraEnabled
        public String addressId {get;set;}
        @AuraEnabled
        public Boolean blnIntegrationSuccess = false;
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public String strMessage {get;set;}
        @AuraEnabled
        public String strIntMessage {get;set;}
    }
    public class CustomException extends Exception {}
    
}