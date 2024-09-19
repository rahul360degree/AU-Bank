/*******************************************************************************************
* @Name         AUSF_NotificationUtility
* @Author       Charchit Nirayanwal
* @Description  
* @Test Class   AUSF_NotificationControllerTest
*******************************************************************************************/
/* MODIFICATION LOG
* Version                   Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Charhit Nirayanwal            03-July-2024            Initial Creation 
*******************************************************************************************/

public without sharing class AUSF_NotificationUtility {
    
    public static Map<String, Schema.SObjectField> LoanAppfieldsMap = Loan_Application__c.SObjectType.getDescribe().fields.getMap();
    public static Map<String, Schema.SObjectField> ApplicantfieldsMap = Applicant__c.SObjectType.getDescribe().fields.getMap();
    
    public static string bindValues(AUSF_NotificationController.LoanAppWrapper loanAppWrap,string content){
        
        // Define a regular expression pattern to find identifiers after 'loan.' or any prefix
        String patternStr = '\\{(\\w+\\.\\w+)\\}';
        Pattern findPattern = Pattern.compile(patternStr);
        Matcher matcherVal = findPattern.matcher(content);
        
        // Set to hold matched identifiers
        Set<String> matchedIdentifiers = new Set<String>();
        
        // Find all matches
        while (matcherVal.find()) {
            // Group 1 will contain the matched identifier after the prefix 
            String matchedIdentifier = matcherVal.group(1);
            matchedIdentifiers.add(matchedIdentifier);
        }
        
        Map<String, list<String>> ObjNameFieldsMap = new Map<String, list<String>>();
        
        // Iterate through inputList to populate the map
        for (String pair : matchedIdentifiers) {
            // Split each pair into key and value based on dot
            List<String> keyValue = pair.split('\\.');
            
            if (keyValue.size() == 2) {
                String key = keyValue[0].trim();
                String value = keyValue[1].trim();
                if(key == 'Loan_Application__c'){
                    if(!LoanAppfieldsMap.keyset().contains(value.toLowerCase())){
                        continue;
                    }
                }
                else if(key == 'Applicant__c'){ 
                    if(!ApplicantFieldsMap.keyset().contains(value.toLowerCase())){
                        continue;
                    }
                    
                }
                if(ObjNameFieldsMap.get(key) != null){
                    ObjNameFieldsMap.get(key).add(value);
                }
                else{
                    ObjNameFieldsMap.put(key, new list<string>{value});
                }
            }
        }
        
        system.debug('#1001' + ObjNameFieldsMap);
        
        
        	list<Loan_Application__c> loanLst = new list<Loan_Application__c>{loanAppWrap.ObjLoan};
            list<Applicant__c> AppLst = new list<Applicant__c>{loanAppWrap.ObjApp};
                
                
                system.debug('ObjLoan' + loanAppWrap.ObjLoan);
              if(loanAppWrap.ObjLoan == null){
                  system.debug('#1002');
                    Map<String, Object> binds = new Map<String, Object>{'objId' => loanAppWrap.loanApplicationId};
                        string query = formDynamicQuery(ObjNameFieldsMap,'Loan_Application__c');
                    if(query!=null){
                        loanLst = Database.queryWithBinds(query,binds,AccessLevel.SYSTEM_MODE);
                    }
                }
        if(loanAppWrap.ObjApp == null){
            system.debug('#1003');
            Map<String, Object> binds = new Map<String, Object>{'objId' => loanAppWrap.applicantId};
                string query = formDynamicQuery(ObjNameFieldsMap,'Applicant__c');
            if(query!=null){
                AppLst = Database.queryWithBinds(query,binds,AccessLevel.SYSTEM_MODE);
            }
        }
        
        for(string s: matchedIdentifiers){
            List<String> keyValue = s.split('\\.');
            if (keyValue.size() == 2) {
                if(keyValue[0].trim() == 'Loan_Application__c' && loanLst != NULL && LoanAppfieldsMap.keyset().contains(keyValue[1].toLowerCase()) ){
                    content = content.replace('{'+s+'}',(string)loanLst[0].get(keyValue[1]));
                }
                if(keyValue[0].trim() == 'Applicant__c' && AppLst != NULL && ApplicantfieldsMap.keyset().contains(keyValue[1].toLowerCase()) ){
                    content = content.replace('{'+s+'}',(string)AppLst[0].get(keyValue[1]));
                }
                
            }
        }
        
        return content;
        
        
    }
    
    public static string formDynamicQuery(Map<String, list<String>> ObjNameFieldsMap,string objName){
        
        if(ObjNameFieldsMap.get(objName) != NULL){
            String query = 'SELECT ';
            query += String.join(ObjNameFieldsMap.get(objName), ', ');
            query += ' FROM ' + objName;
            query +=' where Id=:objId';
            query = String.escapeSingleQuotes(query);
            return query;
            
        }
        return null;
    }
    
    
}