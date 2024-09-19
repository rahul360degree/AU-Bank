public without sharing class AUSF_AddressSplitUtilty {
    public static Address__c addressSplitOnSuccess(AUSF_AddressSplitResponseWrapper.splitaddress address, String applicantId){
        Address__c newAddress = new Address__c();
        address.Care_Of = address.Care_Of!=null?address.Care_Of+' ':'';
        address.House = address.House!=null?address.House+' ':'';
        address.Floor = address.Floor!=null?address.Floor+' ':'';
        address.Building = address.Building!=null?address.Building+' ':'';
        address.Complex = address.Complex!=null?address.Complex+' ':'';
        address.Street = address.Street!=null?address.Street+' ':'';
        address.Untagged = address.Untagged!=null?address.Untagged+' ':'';
        address.Landmark = address.Landmark!=null?address.Landmark:'';
        address.Pin = address.Pin!=null? address.Pin:null;
        String addressLine1 = address.Care_Of+address.House+address.Floor+address.Building+address.Complex;
        String addressLine2 = address.Street+address.Untagged;
        String addressLine3 =  address.Landmark;
        String remainingAddressNotIncluded = '';
        list<String> tempAdd= new List<String>{'', '', '','','',''};
        Integer count = 0;
        System.debug('address.Care_Of='+address.Care_Of +address.House+address.Floor);
        if(addressLine1.length()>35 ){
            for (String str :  addressLine1.split(' ')) {
                if((tempAdd[count].length() + str.length()) > 35 && count < 2)
                {
                    count++;
                }
                tempAdd[count] += str+' ';
            }
            newAddress.Address_Line_1__c = tempAdd[0] != null ? tempAdd[0] : '';
            addressLine2 = tempAdd[1]+tempAdd[2] + addressLine2;
        }
        else
        {
            newAddress.Address_Line_1__c = addressLine1  != null ? addressLine1 : '';
        }
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
            newAddress.Address_Line_2__c = tempAdd[0]  != null ? tempAdd[0] : '';
            addressLine3 = tempAdd[1]+tempAdd[2]+addressLine3;
        }
        else
        {
            newAddress.Address_Line_2__c = addressLine2 != null ? addressLine2 : '';
        }
        List<Location_Master__c> location = [SELECT Id,Name,State__c,City__c,Zip_Code__c FROM Location_Master__c WHERE Zip_Code__c=:String.valueOf(address.Pin) LIMIT 1];
        newAddress.State__c = !location.isEmpty()?location[0].State__c:'';
        newAddress.Pincode__c = !location.isEmpty()?location[0].Name:'';
        newAddress.City__c = !location.isEmpty()?location[0].City__c:'';
        newAddress.Address_Source__c = AUSF_ApexConstants.AUSF_AddressSource_OWNERSHIP_PROOF;
        newAddress.Applicant__c = applicantId;
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
            newAddress.Address_Line_3__c = tempAdd[0] != null ? tempAdd[0] : '';
            remainingAddressNotIncluded = tempAdd[1]+tempAdd[2]+remainingAddressNotIncluded;
        }
        else
        {
            newAddress.Address_Line_3__c = addressLine3 != null ? addressLine3 : '';
        }
        return newAddress;
    }
    public static Address__c addressSplitOnFailure(String address, String applicantId){
        Address__c newAddress = new Address__c();
        String pincode = '';        
        Pattern idPattern = Pattern.compile('([1-9]{1}\\d{2}?\\d{3})');
        Matcher idMatcher = idPattern.matcher(address);
        if (idMatcher.find()) {
            pincode = idMatcher.group();
        }
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
            newAddress.Address_Line_1__c = tempAdd[0]  != null ? tempAdd[0] : '';
            addressLine2 = tempAdd[1]+tempAdd[2];
        }
        else
        {
            newAddress.Address_Line_1__c = addressLine1 != null ? addressLine1 : '';
        }
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

            newAddress.Address_Line_2__c = tempAdd[0] != null ? tempAdd[0] : '';
            
            addressLine3 = tempAdd[1]+tempAdd[2]+addressLine3;
        }
        else
        {
            newAddress.Address_Line_2__c = addressLine2 != null ? addressLine2 : ''; 
        }
        if(pincode != '')
        {
            List<Location_Master__c> location = [SELECT Id,Name,State__c,City__c,Zip_Code__c FROM Location_Master__c WHERE Zip_Code__c=:pincode LIMIT 1];
            System.debug('location-->'+location);
            newAddress.State__c = !location.isEmpty()?location[0].State__c:'';
            newAddress.Pincode__c = !location.isEmpty()?location[0].Name:'';
            newAddress.City__c = !location.isEmpty()?location[0].City__c:'';      
        }
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
            newAddress.Address_Line_3__c = tempAdd[0]  != null ? tempAdd[0] : '';
            remainingAddressNotIncluded = tempAdd[1]+tempAdd[2]+remainingAddressNotIncluded;
        }
        else
        {
            newAddress.Address_Line_3__c = addressLine3 != null ? addressLine3 : ''; 
        }
        return newAddress;
    }
}