/*******************************************************************************************
* @Name         AUSF_CustomerDedupeLWCController
* @Author       Murtaza Ali
* @Description  
* @Test Class   AUSF_CustomerDedupeLWCController_Test
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer            Date                    Description
*-------------------------------------------------------------------------------------------
*  1.0             Murtaza Ali.             03-July-2024            Initial Creation 
*******************************************************************************************/
public without sharing class AUSF_CustomerDedupeLWCController {
    @AuraEnabled
    public static AUSF_INT_CustomerDedupeResponseWrapper getCustomerDedupe(String panNumber,String loanId,String applicantId){
        AUSF_INT_CustomerDedupeResponseWrapper integrationWrapper = AUSF_CustomerDedupeController.getCustomerDedupe(panNumber,loanId,applicantId);
        // AUSF_INT_CustomerDedupeResponseWrapper integrationWrapper = getMockResponse();
        return integrationWrapper;
    }

    @AuraEnabled
    public static AUSF_CustomerDedupeUtility.InnerResponse updateRecordForCIF(String CIF,String applicantId){
        //return AUSF_CustomerDedupeController.updateRecordForCIF(CIF,applicantId);
        // return true;
        return AUSF_CustomerDedupeUtility.updateRecordForCIF(CIF,applicantId);
    }


    /** 
	* @description Function to reject loan application record 
	* Inputs: loan id and reject reason.
	* Returns: void
    * Jira Story : APL-806
	*/
    @AuraEnabled
    public static void rejectLoanApp(String loanId,String rejectResaon){
        try{
            List<Loan_Application__c> loanApp = [SELECT Id,Stage__c,Reject_Sub_Reason__c,Reject_Reason__c FROM Loan_Application__c WHERE Id=:loanId];
            Loan_Application__c rejectLoan = loanApp[0];
            rejectLoan.Stage__c = AUSF_ApexConstants.AUSF_REJECT;
            rejectLoan.Reject_Reason__c = rejectResaon;
            rejectLoan.Reject_Sub_Reason__c = getRejectMessageMap().get(rejectResaon);
            update rejectLoan;
        }catch(Exception ex){
            AUSF_Log.error(ex,AUSF_Log.SeverityType.Medium,loanId,'Loan Application','Reject Loan Application');
        }
        

    }
    
    private static Map<String,String> getRejectMessageMap(){
        
        Map<String,String> getRejectMessageMap = new Map<String,String>();
        getRejectMessageMap.put('DPD check','P224');
        getRejectMessageMap.put('NPA check','P227');
        getRejectMessageMap.put('PA offer not found','P230');
        return getRejectMessageMap;
    }

    public static AUSF_INT_CustomerDedupeResponseWrapper getMockResponse(){
        AUSF_INT_IntegrationResponseWrapper.ResponseWrapper objIntResponse = new AUSF_INT_IntegrationResponseWrapper.ResponseWrapper();
        Boolean blnSuccess = true;
        String strMessage = 'Integration successful';
        Boolean blnIntegrationSuccess = true;
        List<AUSF_INT_CustomerDedupeResponseWrapper.Customer> customers = new List<AUSF_INT_CustomerDedupeResponseWrapper.Customer>();
        AUSF_INT_CustomerDedupeResponseWrapper.Customer customer1 = new AUSF_INT_CustomerDedupeResponseWrapper.Customer();
        customer1.CIF = 'CIF12345';
        customer1.Name = 'John Doe';
        customer1.MobileNo = '1234567890';
        customer1.PAN = 'ABCDE1234F';
        customer1.Type = 'Individual';
        customer1.unsecureDLODMatch = true;
        customer1.overDraftCheck = false;
        customer1.DPD = false;
        customer1.NPA = false;
        AUSF_INT_CustomerDedupeResponseWrapper.PA preApprovedOffer1 = new AUSF_INT_CustomerDedupeResponseWrapper.PA();
        preApprovedOffer1.ProductType = 'Personal Loan';
        preApprovedOffer1.OfferAmount = '50000';
        preApprovedOffer1.OfferType = 'Pre-Approved';
        preApprovedOffer1.ProcessingFee = '500';
        preApprovedOffer1.BankAccountNumber = '123456789012';
        customer1.preApprovedOffer = preApprovedOffer1;
        customers.add(customer1);
        AUSF_INT_CustomerDedupeResponseWrapper.Customer customer2 = new AUSF_INT_CustomerDedupeResponseWrapper.Customer();
        customer2.CIF = 'CIF67890';
        customer2.Name = 'Jane Smith';
        customer2.MobileNo = '0987654321';
        customer2.PAN = 'FGHIJ5678K';
        customer2.Type = 'Business';
        customer2.unsecureDLODMatch = false;
        customer2.overDraftCheck = true;
        customer2.DPD = true;
        customer2.NPA = true;
        AUSF_INT_CustomerDedupeResponseWrapper.PA preApprovedOffer2 = new AUSF_INT_CustomerDedupeResponseWrapper.PA();
        preApprovedOffer2.ProductType = 'Business Loan';
        preApprovedOffer2.OfferAmount = '100000';
        preApprovedOffer2.OfferType = 'Pre-Approved';
        preApprovedOffer2.ProcessingFee = '1000';
        preApprovedOffer2.BankAccountNumber = '987654321098';
        customer2.preApprovedOffer = preApprovedOffer2;
        customers.add(customer2);
        // Assigning the mock data to the wrapper class
        AUSF_INT_CustomerDedupeResponseWrapper mockResponse = new AUSF_INT_CustomerDedupeResponseWrapper();
        mockResponse.objIntResponse = objIntResponse;
        mockResponse.blnSuccess = blnSuccess;
        mockResponse.strMessage = strMessage;
        mockResponse.blnIntegrationSuccess = blnIntegrationSuccess;
        mockResponse.customers = customers;
        return mockResponse;
    }
}