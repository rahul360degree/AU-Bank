/**
 * @author        Pradeep Sharma
 * Class :		 AUSF_CustomerDedupeController
 * Test Class	 AUSF_CustomerDedupeTest
 * @date          28-June-2024
 * @description   Controller for customer dedupe detail integration
 * Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Pradeep Sharma        28-June-2024    Initial Version
Mohit M.              05-Aug-2024     Fetch PAN Number from Applicant
*/
public without Sharing class AUSF_CustomerDedupeController {
    /*
    @description    : getCustomerDedupe - return the AUSF_INT_CustomerDedupeResponseWrapper
    @param1         : panNumber - pan number of the applicant
    @param2         : loanId - Loan application Id
    @param3         : applicantId - Id of the applicant
    @return         : AUSF_INT_CustomerDedupeResponseWrapper
     */
    @AuraEnabled
    public static AUSF_INT_CustomerDedupeResponseWrapper getCustomerDedupe(String panNumber,String loanId,String applicantId){
        AUSF_INT_CustomerDedupeResponseWrapper objResponse = new AUSF_INT_CustomerDedupeResponseWrapper();
        Integration_Master__c objIntMapper = AUSF_INT_IntegrationUtility.getIntegrationMasterRecord(AUSF_ApexConstants.AUSF_CustomerDedupe_INTEGRATION_MASTER);
        String respBody;
        String strIntMessage = '';
        if (objIntMapper == NULL || objIntMapper.Id == NULL) {
            throw new CustomException(AUSF_ApexConstants.INTEGRATION_MASTER_MISSING);
        }
        try{
            Applicant__c applicant = [SELECT Id,Name,Mobile_Number__c,Birth_Date__c,Full_Name__c,CIF__c,First_Name__c,Last_Name__c,Prefix__c,Middle_Name__c,PAN__c,Gender__c,Aadhaar_Reference_Number__c,KYC_Type__c,NTB_ETB__c,Has_NPA__c,Has_DPD__c, RecordType.DeveloperName,Loan_Application__c,Loan_Application__r.Stage__c FROM Applicant__c where Id=:applicantId limit 1];
            // Check and Fetch PAN Number from Applicant
            String strPANNumber = String.isNotBlank(panNumber) ? applicant.PAN__c : panNumber;
            Integration_Checklist__c newChecklistInstance = new Integration_Checklist__c();
            newChecklistInstance.Integration_Master__c = objIntMapper.Id;
            newChecklistInstance.Applicant__c = applicant.Id;
            AUSF_INT_IntegrationUtility.InputWrapper inputData = new AUSF_INT_IntegrationUtility.InputWrapper();
            inputData.integrationChecklistRecord = newChecklistInstance;
            inputData.integrationMasterRecord = objIntMapper;
            inputData.applicantRecord = applicant;
            inputData.dynamicInputs = new Map<String, Object>();
            inputData.dynamicInputs.put('panNumber', strPANNumber);
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
            if (calloutResponseWrapper.errorMessage!=null) {
                throw new CustomException(calloutResponseWrapper.errorMessage);
            }
            if (calloutResponseWrapper.statusCode < 200 || calloutResponseWrapper.statusCode > 299) {
                calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                upsert calloutResponseWrapper.checklistRecord;
                strIntMessage = 'Error With Service - ' + objIntMapper.Name + ' and record reference - ';
                objResponse.objIntResponse = calloutResponseWrapper;
            }
            else  {
                AUSF_CustomerDedupeResponseWrapper res = (AUSF_CustomerDedupeResponseWrapper)JSON.deserialize(calloutResponseWrapper.response,AUSF_CustomerDedupeResponseWrapper.class);
                List<Pre_Approved_Offer__c> preOffers = new List<Pre_Approved_Offer__c>();
                List<Address__c> addresses = new List<Address__c>();
                List<Bank_Account_Records__c> bankAccounts = new List<Bank_Account_Records__c>();
                Loan_Application__c loanToUpdate = new Loan_Application__c(Id=applicant.Loan_Application__c);
                if (res.TransactionStatus.ResponseCode == '0') {
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_COMPLETED;
                    objResponse.blnIntegrationSuccess = true;
                    objResponse.objIntResponse = calloutResponseWrapper;
                    objResponse.customers = AUSF_CustomerDedupeUtility.getCustomers(res,applicant);

                    //single customer match Scenario.
                    if(objResponse.customers.size() == 0)
                    {
                        AUSF_CustomerDedupeUtility.rejectAndNotifyLoanApplication(loanToUpdate.Id,  applicant.Id);
                        objResponse.strMessage = 'Customer Not Found';      
                        throw new CustomException(objResponse.strMessage);
                    }

                    if(objResponse.customers.size() == 1){

                        if(res.MatchFound[0].CRMQueryResults.size() == 0 || res.MatchFound[0].CRMQueryResults == null)
                        {
                            Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                            
                            AUSF_CustomerDedupeUtility.rejectAndNotifyLoanApplication(loanToUpdate.Id,  applicant.Id);

                            objResponse.strMessage = 'Customer Match Not Found';      
                            throw new CustomException(objResponse.strMessage);
                        }

                        applicant = AUSF_CustomerDedupeUtility.updateApplicant(res,applicant,objResponse.customers[0].CIF);
                        
                        addresses = AUSF_CustomerDedupeUtility.getAddressRecords(res,applicantId,objResponse.customers[0].CIF);
                        bankAccounts = AUSF_CustomerDedupeUtility.getBankAccounts(res,applicantId,objResponse.customers[0].CIF);
                        loanToUpdate = AUSF_CustomerDedupeUtility.updateLoanApplication(res,applicant.Loan_Application__c,applicant,objResponse.customers[0].CIF);
                        loanToUpdate = AUSF_CustomerDedupeUtility.updateLoanAppForPAOffer(loanToUpdate,preOffers); // APL-684 update loan app on the basis of PA offer
                        preOffers = AUSF_CustomerDedupeUtility.preApprovedOffersToCreate(res,applicant.Loan_Application__c,objResponse.customers[0].CIF,applicantId);
                        update applicant;
                        upsert addresses;
                        Map<String, Bank_Account_Records__c> existingAccountsMap = new Map<String, Bank_Account_Records__c>();
                        List<Bank_Account_Records__c> accountsToUpdate = new List<Bank_Account_Records__c>();
                        List<Bank_Account_Records__c> accountsToDeactivate = new List<Bank_Account_Records__c>();
                        for (Bank_Account_Records__c account : bankAccounts) {
                            if (String.isNotBlank(account.Account_Number__c)) {
                                existingAccountsMap.put(account.Account_Number__c, account);
                            }
                        }
                        List<Bank_Account_Records__c> existingAccounts = [SELECT Id, Account_Number__c, InActive__c,Source__c,Product_Code__c,Product__c,
                                                                            Bank_Name__c,Current_Status__c,Current_Balance__c,Branch_Name__c,Account_Opening_Date__c,
                                                                            Date_Of_Enquiry__c,Fixed_Interest_Rate__c,Account_Name__c,Applicant__c,Account_Type__c,
                                                                            OD_Limit_Sanctioned__c,Customer_Relationship__c FROM Bank_Account_Records__c WHERE  Applicant__c = :applicantID AND
                                                                            (Source__c = :AUSF_ApexConstants.AUSF_BANK_SOURCE_CUSTOMER_DEDUPE OR Source__c = :AUSF_ApexConstants.AUSF_BANK_SOURCE_PRE_APPROVED_OFFER )];
                        for (Bank_Account_Records__c account : bankAccounts) {
                            if (existingAccountsMap.containsKey(account.Account_Number__c)) {
                                Bank_Account_Records__c existingAccount = existingAccountsMap.get(account.Account_Number__c);
                                accountsToUpdate.add(existingAccount);
                            } else {
                                accountsToUpdate.add(account);
                            }
                        }
                        upsert accountsToUpdate Account_Number__c;
                        for (Bank_Account_Records__c existingAccount : existingAccounts) {
                            if (!existingAccountsMap.containsKey(existingAccount.Account_Number__c)) {
                                existingAccount.InActive__c = true;
                                accountsToDeactivate.add(existingAccount);
                            }
                        }
                        update accountsToDeactivate;
                        upsert preOffers;
                        update loanToUpdate;

                        if( loanToUpdate.stage__c ==  AUSF_ApexConstants.AUSF_REJECT)
                        {
                            AUSF_CustomerDedupeUtility.loanRejectNotify(loanToUpdate,  applicant.Id);
                        }
                    }
                }
                else{
                    calloutResponseWrapper.checklistRecord.Status__c = AUSF_ApexConstants.AUSF_IC_FAILED;
                    strIntMessage = 'Error with Service - '  + objIntMapper.Name + ' and record reference - ';
                    calloutResponseWrapper.errorMessage = strIntMessage;
                    objResponse.objIntResponse = calloutResponseWrapper;
                }
                upsert calloutRequestWrapper.checklistRecord;
                
            }
            if (!objResponse.blnIntegrationSuccess && calloutResponseWrapper.checklistRecord != NULL && calloutResponseWrapper.checklistRecord.Id != NULL) {
                Integration_Checklist__c objChecklist = AUSF_INT_IntegrationUtility.getIntegrationChecklist(calloutResponseWrapper.checklistRecord.Id);
                objResponse.strMessage = String.isNotBlank(strIntMessage) ? strIntMessage  + objChecklist.Name : '';
                throw new CustomException(objResponse.strMessage);
            }
            objResponse.blnSuccess = true;
        }
        catch (Exception ex) {
            objResponse.strMessage = ex.getMessage();
            System.debug(LoggingLevel.Error,'Exception in class ' + ex + ex.getLineNumber());
            AUSF_Log.error(ex,AUSF_Log.SeverityType.Medium,applicantId,'Applicant',AUSF_ApexConstants.AUSF_CustomerDedupe_INTEGRATION_MASTER);
        }
        System.debug('objResponse--->'+JSON.serialize(objResponse));
        return objResponse;
    }
    
    
    public class CustomException extends Exception {}
    
    
}