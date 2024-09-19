public without sharing class AUSF_AddressSplitController {
    public static AUSF_INT_AddressSplitWrapper callAddressSplitApi(String address, String strApplicantId){
        AUSF_INT_AddressSplitWrapper objResponse = new AUSF_INT_AddressSplitWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_AddressSplit_INTEGRATION_MASTER);
        String respBody;
        String strIntMessage = '';
        String previousRequestId='';
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.GENERIC_MASTER_MISSING_ERROR_MSG);
        }
        try{
            Applicant__c applicant = [SELECT Id,Loan_Application__c FROM Applicant__c where Id=:strApplicantId limit 1];
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicant.Id;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = applicant;
            inputData.dynamicInputs = new Map<String, Object>();
            inputData.dynamicInputs.put('address', address);
            inputData.dynamicInputs.put('channel', objIntMapper.Channel__c);
            AUSF_INT_IntegrationUtility utilityInstance = new AUSF_INT_IntegrationUtility();
            AUSF_INT_IntegrationRequestWrapper.HTTPRequestWrapper requestDetails = utilityInstance.constructRequest(inputData);
            if (String.isNotBlank(requestDetails.preRequisites)) {
                newChecklistInstance.Status__c = AUSF_ApexConstants.MISSING_PRE_REQUISITES;
                newChecklistInstance.Missing_Pre_requisites__c = requestDetails.preRequisites;
                upsert newChecklistInstance;
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(newChecklistInstance.Id);
                throw new CustomException(requestDetails.preRequisites+' - '+objChecklist.Name);
            }
            AUSF_INT_IntegrationResponseWrapper.ResponseWrapper calloutResponseWrapper = new AUSF_INT_IntegrationResponseWrapper.ResponseWrapper();
            AUSF_INT_IntegrationRequestWrapper.RequestWrapper calloutRequestWrapper = new AUSF_INT_IntegrationRequestWrapper.RequestWrapper();
            calloutRequestWrapper.request = requestDetails.request;
            calloutRequestWrapper.masterRecord = objIntMapper;
            calloutRequestWrapper.checklistRecord = newChecklistInstance;
            calloutRequestWrapper.entityId = applicant.Id;
            calloutResponseWrapper = utilityInstance.initiateCallout(calloutRequestWrapper);
            System.debug('Response--->'+calloutResponseWrapper.response);
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - ';
            }
            else  {
                Address__c newAddress = new Address__c();
                if(calloutResponseWrapper.statusCode == 200){
                    Map<String,String> replacements = new Map<String,String>{'C/O'=>'Care_Of','status-Code'=>'statusCode'};
                    String mogrifiedJSON = AUSF_INT_IntegrationUtility.mogrifyJSON(calloutResponseWrapper.response,replacements);
                    calloutResponseWrapper.response = mogrifiedJSON;
                    AUSF_AddressSplitResponseWrapper response = (AUSF_AddressSplitResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_AddressSplitResponseWrapper.class);
                    newAddress=AUSF_AddressSplitUtilty.addressSplitOnSuccess(response.splitaddress,strApplicantId);
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    objResponse.blnIntegrationSuccess = true;
                }
                else{
                    newAddress=AUSF_AddressSplitUtilty.addressSplitOnFailure(address,strApplicantId);
                }
                insert newAddress;
                objResponse.address = newAddress;
            }
            upsert calloutResponseWrapper.checklistRecord;
            objResponse.objIntResponse = calloutResponseWrapper;
            if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strMessage = String.isNotBlank(strIntMessage) ? strIntMessage  + objChecklist.Name : '';
                throw new CustomException(objResponse.strMessage);
            }
            objResponse.blnSuccess = true;
        }
        catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            System.debug(LoggingLevel.Error,'Exception in class ' + ex.getLineNumber()+ ''+ex.getCause());
            AUSF_Log.error(ex, AUSF_Log.SeverityType.Medium,strApplicantId,'Applicant',AUSF_ApexConstants.AUSF_AddressSplit_INTEGRATION_MASTER);
        }
        System.debug('objResponse--->'+objResponse);
        return objresponse;
    }


    public static Address__c addressSplitOnSuccess(AUSF_AddressSplitResponseWrapper.splitaddress address, String applicantId){

        System.debug('address-->'+address);
        Address__c newAddress = new Address__c();
        address.Care_Of = address.Care_Of!=''?address.Care_Of+' ':'';
        address.House = address.House!=''?address.House+' ':'';
        address.Floor = address.Floor!=''?address.Floor+' ':'';
        address.Building = address.Building!=''?address.Building+' ':'';
        address.Complex = address.Complex!=''?address.Complex+' ':'';
        address.Street = address.Street!=''?address.Street+' ':'';
        address.Untagged = address.Untagged!=''?address.Untagged+' ':'';
        address.Landmark = address.Landmark!=''?address.Landmark:'';
        address.Pin = address.Pin!=null? address.Pin:null;
        String addressLine1 = address.Care_Of+address.House+address.Floor+address.Building+address.Complex;
        String addressLine2 = address.Street+address.Untagged;
        String addressLine3 =  address.Landmark;
        String remainingAddressNotIncluded = '';

        list<String> tempAdd= new List<String>{'', '', '','','',''};

        Integer count = 0;

        if(addressLine1.length()>35 ){
            for (String str :  addressLine1.split(' ')) {
                if((tempAdd[count].length() + str.length()) > 35 && count < 2)
                {
                        count++; 
                }     
                tempAdd[count] += str+' ';
            }
            newAddress.Address_Line_1__c = tempAdd[0];

            addressLine2 = tempAdd[1]+tempAdd[2] + addressLine2;
        }
        else
        {
            newAddress.Address_Line_1__c = addressLine1;    
        }

        System.debug('Remaning in Address in 1');
        System.debug('Address_Line_1__c------>'+newAddress.Address_Line_1__c);
        System.debug('addressLine2------>'+addressLine2);

        tempAdd = new List<String>{'', '', '','','',''};
        count = 0;

        if(addressLine2.length()>35){

            for (String str :  addressLine2.split(' ')) {
                if((tempAdd[count].length() + str.length()) > 35 && count < 2)
                {
                        count++;    
                }     
                tempAdd[count] += str+' ';
            }

            newAddress.Address_Line_2__c = tempAdd[0];

            addressLine3 = tempAdd[1]+tempAdd[2]+addressLine3;
        }
        else
        {
            newAddress.Address_Line_2__c = addressLine2;    
        }

        System.debug('Remailing in Address 3------>'+tempAdd[1]+tempAdd[2]);
        System.debug('Address_Line_2__c------>'+newAddress.Address_Line_2__c);
        System.debug('addressLine3------>'+addressLine3);

        List<Location_Master__c> location = [SELECT Id,Name,State__c,City__c,Zip_Code__c FROM Location_Master__c WHERE Zip_Code__c=:String.valueOf(address.Pin) LIMIT 1];
        System.debug('location-->'+location);
        newAddress.State__c = !location.isEmpty()?location[0].State__c:'';
        newAddress.Pincode__c = !location.isEmpty()?location[0].Name:'';
        newAddress.City__c = !location.isEmpty()?location[0].City__c:'';
        newAddress.Address_Source__c = AUSF_ApexConstants.AUSF_AddressSource_OWNERSHIP_PROOF;
        newAddress.Applicant__c = applicantId;
        system.debug('Address__c '+newAddress);

        addressLine3 += ' '+(!location.isEmpty()?location[0].City__c+' ':'')+(!location.isEmpty()?location[0].State__c:'');


        tempAdd = new List<String>{'', '', '','','',''};
        count = 0;

        if(addressLine3.length() > 35)
        {
            for (String str :  addressLine3.split(' ')) {
                if((tempAdd[count].length() + str.length()) > 35 && count < 2)
                {   
                    count++;
                }     
                tempAdd[count] += str+' ';
            }
            newAddress.Address_Line_3__c = tempAdd[0];
            remainingAddressNotIncluded = tempAdd[1]+tempAdd[2]+remainingAddressNotIncluded;
        }
        else
        {
            newAddress.Address_Line_3__c = addressLine3;  
        }

        System.debug('Address_Line_3__c------>'+newAddress.Address_Line_3__c);
        System.debug('remainingAddressNotIncluded------>'+remainingAddressNotIncluded);

        return newAddress;
    }


    public static Address__c addressSplitOnFailure(String address, String applicantId){

        Address__c newAddress = new Address__c();
        String pincode = '';
        
        Pattern idPattern = Pattern.compile('([1-9]{1}\\d{2}?\\d{3})');
        Matcher idMatcher = idPattern.matcher(address);
        if (idMatcher.find()) {
            pincode = idMatcher.group();
            System.debug('pin code found :->'+pincode);
        }

        System.debug('address-->'+address);
        String addressLine1 = address;
        String addressLine2 = '';
        String addressLine3 = '';
        String remainingAddressNotIncluded = '';

        list<String> tempAdd= new List<String>{'', '', ''};

        Integer count = 0;

        if(addressLine1.length()>35 ){
            for (String str :  addressLine1.split(' ')) {
                if((tempAdd[count].length() + str.length()) > 35 && count < 2)
                {
                        count++; 
                }     
                tempAdd[count] += str+' ';
            }
            newAddress.Address_Line_1__c = tempAdd[0];

            addressLine2 = tempAdd[1]+tempAdd[2];
        }
        else
        {
            newAddress.Address_Line_1__c = addressLine1;    
        }

        System.debug('Remaning in Address in 1');
        System.debug('Address_Line_1__c------>'+newAddress.Address_Line_1__c);
        System.debug('addressLine2------>'+addressLine2);

        tempAdd = new List<String>{'', '', '','','',''};
        count = 0;

        if(addressLine2.length()>35){

            for (String str :  addressLine2.split(' ')) {
                if((tempAdd[count].length() + str.length()) > 35 && count < 2)
                {
                        count++;    
                }     
                tempAdd[count] += str+' ';
            }

            newAddress.Address_Line_2__c = tempAdd[0];

            addressLine3 = tempAdd[1]+tempAdd[2]+addressLine3;
        }
        else
        {
            newAddress.Address_Line_2__c = addressLine2;    
        }

        System.debug('Remailing in Address 3------>'+tempAdd[1]+tempAdd[2]);
        System.debug('Address_Line_2__c------>'+newAddress.Address_Line_2__c);
        System.debug('addressLine3------>'+addressLine3);

        if(pincode != '')
        {
            List<Location_Master__c> location = [SELECT Id,Name,State__c,City__c,Zip_Code__c FROM Location_Master__c WHERE Zip_Code__c=:pincode LIMIT 1];
            System.debug('location-->'+location);
            newAddress.State__c = !location.isEmpty()?location[0].State__c:'';
            newAddress.Pincode__c = !location.isEmpty()?location[0].Name:'';
            newAddress.City__c = !location.isEmpty()?location[0].City__c:'';      
            //addressLine3 += ' '+(!location.isEmpty()?location[0].City__c+' ':'')+(!location.isEmpty()?location[0].State__c:'');
        }

        system.debug('Address__c '+newAddress);
        newAddress.Address_Source__c = AUSF_ApexConstants.AUSF_AddressSource_OWNERSHIP_PROOF;
        newAddress.Applicant__c = applicantId;


        tempAdd = new List<String>{'', '', '','','',''};
        count = 0;

        if(addressLine3.length() > 35)
        {
            for (String str :  addressLine3.split(' ')) {
                if((tempAdd[count].length() + str.length()) > 35 && count < 2)
                {   
                    count++;
                }     
                tempAdd[count] += str+' ';
            }
            newAddress.Address_Line_3__c = tempAdd[0];
            remainingAddressNotIncluded = tempAdd[1]+tempAdd[2]+remainingAddressNotIncluded;
        }
        else
        {
            newAddress.Address_Line_3__c = addressLine3;  
        }

        System.debug('Address_Line_3__c------>'+newAddress.Address_Line_3__c);
        System.debug('remainingAddressNotIncluded------>'+remainingAddressNotIncluded);

        return newAddress;
    }
    
    public class CustomException extends Exception {}
}