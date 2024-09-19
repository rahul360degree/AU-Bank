public without sharing class AUSF_CustomerDedupeUtility {
    /*
    @description    : updateRecordForCIF - return the InnerResponse which contains success ,fail anf failed msg
    @param1         : CIF - CustomerId from customer dedupe
    @param2         : applicantId - Id of the applicant
    @return         : InnerResponse wrapper
     */
    @AuraEnabled
    public static InnerResponse updateRecordForCIF (String CIF,String applicantId)
    {
        InnerResponse objWrap = new InnerResponse();

        try{
            Integration_Checklist__c  ic = [SELECT Id,Loan_Application__c,Applicant__c,Applicant__r.Loan_Application__c,Applicant__r.Loan_Application__r.Stage__c,Name,Response__c,Status__c FROM Integration_Checklist__c WHERE 
                                            Integration_Master__r.Name = :AUSF_ApexConstants.AUSF_CustomerDedupe_INTEGRATION_MASTER AND Status__c = :AUSF_ApexConstants.AUSF_IC_COMPLETED AND Applicant__c = :applicantId ORDER BY CreatedDate DESC LIMIT 1];
            String response = ic.Response__c ;
            AUSF_CustomerDedupeResponseWrapper res = (AUSF_CustomerDedupeResponseWrapper)JSON.deserialize(response,AUSF_CustomerDedupeResponseWrapper.class);
            List<Pre_Approved_Offer__c> preOffers = new List<Pre_Approved_Offer__c>();
            List<Address__c> addresses = new List<Address__c>();
            List<Bank_Account_Records__c> bankAccounts = new List<Bank_Account_Records__c>();
            Loan_Application__c loanToUpdate = new Loan_Application__c(Id=ic.applicant__r.Loan_Application__c);
            if(ic.Applicant__r.Loan_Application__r.Stage__c == 'Reject'){
                objWrap.blnStageReject = true;
            }
            Applicant__c applicant = [SELECT Id,Name,Mobile_Number__c,Birth_Date__c,Full_Name__c,CIF__c,
                                     First_Name__c,Last_Name__c,Prefix__c,Middle_Name__c,PAN__c,Gender__c,
                                     Aadhaar_Reference_Number__c,KYC_Type__c,NTB_ETB__c,Has_NPA__c,Has_DPD__c,
                                     RecordType.DeveloperName,Loan_Application__c,Loan_Application__r.Stage__c
                                     FROM Applicant__c where Id=:applicantId limit 1];
        
            AUSF_CustomerDedupeResponseWrapper.MatchFound matchFoundRes = new AUSF_CustomerDedupeResponseWrapper.MatchFound();

            Boolean isCustomerFound = false;

            //Need to discuss with Mohit Why we are using this for loop CIF check already existes in every methode.
            for(AUSF_CustomerDedupeResponseWrapper.MatchFound resRec :res.MatchFound){

                if(resRec.CustomerResponse.CustomerBasicInquiry.CustomerId == CIF){
                    isCustomerFound = true;

                    break;
                }
                
            }

            if(isCustomerFound)
            {
                applicant = updateApplicant(res,applicant,CIF);
                update applicant;

                addresses = getAddressRecords(res,applicantId,CIF);
                upsert addresses;

                bankAccounts = getBankAccounts(res,applicantId,CIF);
                upsert bankAccounts Account_Number__c;

                preOffers = preApprovedOffersToCreate(res,ic.applicant__r.Loan_Application__c,CIF,applicantId);
                upsert preOffers;
               
                loanToUpdate = updateLoanApplication(res,ic.applicant__r.Loan_Application__c,applicant,CIF);
                loanToUpdate = updateLoanAppForPAOffer(loanToUpdate,preOffers); // APL-684 update loan app on the basis of PA offer
            }
            
            

            //we can only inactive or upsert [so as dissced we commented the code]
            /* 
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
                                                                (Source__c = :AUSF_ApexConstants.AUSF_BANK_SOURCE_CUSTOMER_DEDUPE OR Source__c = :AUSF_ApexConstants.AUSF_BANK_SOURCE_PRE_APPROVED_OFFER ) AND Account_Number__c];
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
            update accountsToDeactivate;    */
            update loanToUpdate;

            if( loanToUpdate.stage__c ==  AUSF_ApexConstants.AUSF_REJECT)
            {
                loanRejectNotify(loanToUpdate, applicant.Id);
            }


            objWrap.blnSuccess = true;
        }
        catch(exception ex){
            objWrap.strMsg = ex.getMessage();
            System.debug(LoggingLevel.Error,'Exception in class ' + ex + ex.getLineNumber());
            AUSF_Log.error(ex,AUSF_Log.SeverityType.Medium,applicantId,'Applicant',AUSF_ApexConstants.AUSF_CustomerDedupe_INTEGRATION_MASTER);
        }
        return objWrap;
    }
    //customer class fields mapping
    public static List<AUSF_INT_CustomerDedupeResponseWrapper.Customer> getCustomers(AUSF_CustomerDedupeResponseWrapper res,Applicant__c applicant){
        List<AUSF_INT_CustomerDedupeResponseWrapper.Customer> customerRecords = new List<AUSF_INT_CustomerDedupeResponseWrapper.Customer>();
        Map<String, String> paramValueMap = AUSF_INT_IntegrationUtility.getParamsValue(AUSF_ApexConstants.AUSF_CustomerDedupe_INTEGRATION_MASTER);
        list<Integer> pidList = new list<Integer>();
        for(String Pid : paramValueMap.get('productId').split(','))
        {
            pidList.add(Integer.valueOf(Pid));
        }

        System.debug('pidList :->'+pidList);

        if(res.MatchFound!=null){
            for(AUSF_CustomerDedupeResponseWrapper.MatchFound resRec :res.MatchFound){
                Boolean fullKycNotDone = getRejectedCustomers(resRec.CustomerResponse.CustomerBasicInquiry,'Full KYC',applicant);
                Boolean mobileCheckNotDone = getRejectedCustomers(resRec.CustomerResponse.CustomerBasicInquiry,'Mobile Check',applicant);
                if( !(fullKycNotDone && mobileCheckNotDone))
                {
                    AUSF_INT_CustomerDedupeResponseWrapper.Customer cus = new AUSF_INT_CustomerDedupeResponseWrapper.Customer();
                    cus.CIF = resRec.CustomerResponse.CustomerBasicInquiry.CustomerId;
                    cus.Name = resRec.CustomerResponse.CustomerBasicInquiry.CustomerName.FullName;
                    cus.MobileNo = resRec.CustomerResponse.CustomerBasicInquiry.MobileNumber;
                    cus.PAN = resRec.CustomerResponse.CustomerBasicInquiry.PAN;
                    cus.Type = resRec.CustomerResponse.CustomerBasicInquiry.CustomerType;
                    cus.unsecureDLODMatch = true;
                    cus.overDraftCheck = true;
                    boolean blnNPAFound = false;
                    boolean blnDPDFound = false;
                    for(Integer j = 0;j<resRec.NPADPD.size();j++){
                        if (resRec.NPADPD[j].NPAStatus == 'N' && !blnNPAFound) {
                            blnNPAFound = true;
                        }
                        if (resRec.NPADPD[j].DPD > 0  && !blnDPDFound) {
                            blnDPDFound = true;
                        }
                        if(blnNPAFound && blnDPDFound){
                            break;
                        }
                    }
                    cus.NPA = blnNPAFound;
                    cus.DPD = blnDPDFound;
                    if(resRec.CRMQueryResults!=null){
                        for(integer i=0 ; i<resRec.CRMQueryResults.size();i++){
                            AUSF_INT_CustomerDedupeResponseWrapper.PA preAppOffers = new  AUSF_INT_CustomerDedupeResponseWrapper.PA();
                            if(pidList.contains(resRec.CRMQueryResults[i].ProductId)){
                                preAppOffers.ProductType = String.valueOf(resRec.CRMQueryResults[0].ProductId);
                                preAppOffers.OfferAmount = String.valueOf(resRec.CRMQueryResults[0].FirstOfferAmount);
                                preAppOffers.OfferType = resRec.CRMQueryResults[0].OfferType;
                                preAppOffers.ProcessingFee = String.valueOf(resRec.CRMQueryResults[0].Comments);
                                preAppOffers.BankAccountNumber= String.valueOf(resRec.CRMQueryResults[0].BankAccountNumber);
                                cus.preApprovedOffer = preAppOffers;
                            }
                        }
                    }
                    customerRecords.add(cus);
                }
            }
        }
        return customerRecords;
    }
    //used for applicant fields mapping with custommer dedupe response
    public static Applicant__c updateApplicant(AUSF_CustomerDedupeResponseWrapper res,Applicant__c applicant,String strCIFId){
        if(res.MatchFound!=null){
            for(AUSF_CustomerDedupeResponseWrapper.MatchFound resRec :res.MatchFound){
                if(resRec.CustomerResponse.CustomerBasicInquiry.CustomerId==strCIFId){
                    applicant.CIF__c = resRec.CustomerResponse.CustomerBasicInquiry.CustomerId;
                    applicant.First_Name__c = resRec.CustomerResponse.CustomerBasicInquiry.CustomerName.FirstName;
                    applicant.Last_Name__c = resRec.CustomerResponse.CustomerBasicInquiry.CustomerName.LastName;
                    applicant.Prefix__c = resRec.CustomerResponse.CustomerBasicInquiry.CustomerName.Prefix;
                    applicant.Middle_Name__c = resRec.CustomerResponse.CustomerBasicInquiry.CustomerName.MidName;
                    applicant.PAN__c = resRec.CustomerResponse.CustomerBasicInquiry.PAN;
                    applicant.Gender__c = resRec.CustomerResponse.CustomerBasicInquiry.Sex == 'M'? 'Male':resRec.CustomerResponse.CustomerBasicInquiry.Sex == 'F'?'Female':'Others';
                    applicant.Birth_Date__c = resRec.CustomerResponse.CustomerBasicInquiry.BirthDateText!=null?Date.valueOf(resRec.CustomerResponse.CustomerBasicInquiry.BirthDateText):null;
                    String refNumber = resRec.CustomerResponse.CustomerBasicInquiry.AadhaarDetail.AadhaarNumber;
                    applicant.Aadhaar_Reference_Number__c = String.isNotBlank(refNumber)?refNumber.substring(refNumber.length()-4,refNumber.length()):'';
                    applicant.KYC_Type__c = String.isNotBlank(resRec.CustomerResponse.CustomerBasicInquiry.CategoryType)?getKYCTypeField().get(resRec.CustomerResponse.CustomerBasicInquiry.CategoryType):'';
                    applicant.NTB_ETB__c = AUSF_ApexConstants.AUSF_ETB;
                    applicant.Personal_email_ID__c = resRec.CustomerResponse.CustomerBasicInquiry.EmailAddress;
                    boolean blnNPAFound = false;
                    boolean blnDPDFound = false;
                    for(Integer i = 0;i<resRec.NPADPD.Size();i++){
                        if (resRec.NPADPD[i].NPAStatus == 'N' && !blnNPAFound) {
                            blnNPAFound = true;
                        }
                        if (resRec.NPADPD[i].DPD > 0  && !blnDPDFound) {
                            blnDPDFound = true;
                        }
                        if(blnNPAFound && blnDPDFound){
                            break;
                        }
                    }
                    applicant.Has_NPA__c = blnNPAFound;
                    applicant.Has_DPD__c = blnDPDFound;
                }
            }
        }
        else{
            applicant.NTB_ETB__c = AUSF_ApexConstants.AUSF_NTB;
        }
        return applicant;
    }
    //Method to Map the preApproved Offer to create in salesforce with customer dedupe response
    public static List<Pre_Approved_Offer__c> preApprovedOffersToCreate(AUSF_CustomerDedupeResponseWrapper res ,String loanId,String strCIFId,String applicantId){

        list<Pre_Approved_Offer__c> existingPreAppOfferList =  [SELECT Id, Name, Avail__c, Customer_Id__c, BankName__c, Is_Selected__c, Loan_Application__c, Product_Id__c, Bank_Account_Number__c, Product_Type__c FROM Pre_Approved_Offer__c where Loan_Application__c = :loanId limit 1];
 
        List<Pre_Approved_Offer__c> preAppOffersList = new List<Pre_Approved_Offer__c>();
        List<Bank_Account_Records__c> bankAccounts = new List<Bank_Account_Records__c>();
        Map<String, String> paramValueMap = AUSF_INT_IntegrationUtility.getParamsValue(AUSF_ApexConstants.AUSF_CustomerDedupe_INTEGRATION_MASTER);
        
        list<Integer> pidList = new list<Integer>();
        for(String Pid : paramValueMap.get('productId').split(','))
        {
            pidList.add(Integer.valueOf(Pid));
        }
        System.debug('pidList :->'+pidList);

        if(res.MatchFound!=null){
            for(AUSF_CustomerDedupeResponseWrapper.MatchFound resRec :res.MatchFound){
                if(resRec.CustomerResponse.CustomerBasicInquiry.CustomerId==strCIFId){
                    if(resRec.CRMQueryResults!=null || resRec.CRMQueryResults.size() > 0){
                        Pre_Approved_Offer__c preAppOffers = new Pre_Approved_Offer__c();
                        for(integer i=0 ; i<resRec.CRMQueryResults.size();i++){
                            if(pidList.contains(resRec.CRMQueryResults[i].ProductId)){
                                if(existingPreAppOfferList.size() > 0)
                                {
                                    preAppOffers.Id = existingPreAppOfferList[0].Id;
                                }
                                preAppOffers.FirstOfferAmount__c = resRec.CRMQueryResults[i].FirstOfferAmount;
                                preAppOffers.Product_Type__c = AUSF_ApexConstants.AUSF_EMPLOYMENTPREFIX_PL;
                                preAppOffers.BankName__c= resRec.CRMQueryResults[i].BankName;
                                preAppOffers.Scheme__c= resRec.CRMQueryResults[i].Scheme;
                                preAppOffers.Avail__c= resRec.CRMQueryResults[i].Avail;
                                preAppOffers.off_ex1_8__c= resRec.CRMQueryResults[i].off_ex1_8;
                                preAppOffers.Product_Id__c = resRec.CRMQueryResults[i].ProductId;
                                preAppOffers.OfferType__c = resRec.CRMQueryResults[i].OfferType;
                                preAppOffers.Offer_Id__c= resRec.CRMQueryResults[i].OfferId;
                                preAppOffers.RatingID__c= resRec.CRMQueryResults[i].RatingID;
                                preAppOffers.ValidFrom__c= resRec.CRMQueryResults[i].ValidFrom!=null?Date.valueOf(resRec.CRMQueryResults[i].ValidFrom):null;
                                preAppOffers.OfferDescription__c= resRec.CRMQueryResults[i].OfferDescription;
                                preAppOffers.Royale__c= resRec.CRMQueryResults[i].Royale;
                                preAppOffers.MinLoanTenureinMonths__c= resRec.CRMQueryResults[i].MinLoanTenureinMonths!=null?Integer.valueOf(resRec.CRMQueryResults[i].MinLoanTenureinMonths):null;
                                preAppOffers.CustomerNameinBankAccount__c= resRec.CRMQueryResults[i].CustomerNameinBankAccount;
                                preAppOffers.Customer_Id__c = String.valueOf(resRec.CRMQueryResults[i].CustomerId);
                                preAppOffers.OfferIsActive__c= resRec.CRMQueryResults[i].OfferIsActive!= null ? Boolean.valueOf(resRec.CRMQueryResults[i].OfferIsActive):null;
                                preAppOffers.RepaymentMode__c= resRec.CRMQueryResults[i].RepaymentMode;
                                preAppOffers.Mobile__c= resRec.CRMQueryResults[i].Mobile;
                                preAppOffers.CurrencyID__c= resRec.CRMQueryResults[i].CurrencyID;
                                preAppOffers.MaxLoanTenureinMonths__c= resRec.CRMQueryResults[i].MaxLoanTenureinMonths!=null?Integer.valueOf(resRec.CRMQueryResults[i].MaxLoanTenureinMonths):null;
                                preAppOffers.Offer_Name__c= resRec.CRMQueryResults[i].OfferName;
                                preAppOffers.Occupation__c= resRec.CRMQueryResults[i].Occupation;
                                preAppOffers.IFSCcode__c= resRec.CRMQueryResults[i].IFSCcode;
                                preAppOffers.RowNumber__c= resRec.CRMQueryResults[i].RowNumber;
                                preAppOffers.Employee__c= resRec.CRMQueryResults[i].Employee;
                                preAppOffers.BankBranch__c= resRec.CRMQueryResults[i].BankBranch;
                                preAppOffers.ValidTill__c= resRec.CRMQueryResults[i].ValidTill!=null?Date.valueOf(resRec.CRMQueryResults[i].ValidTill):null;
                                preAppOffers.Image_Offers__c= resRec.CRMQueryResults[i].Image_Offers;
                                preAppOffers.TermsAndCondition__c= resRec.CRMQueryResults[i].TermsAndCondition;
                                preAppOffers.RateofInterest__c = resRec.CRMQueryResults[i].RateofInterest!=null?Decimal.valueOf(resRec.CRMQueryResults[i].RateofInterest):null;
                                preAppOffers.Location__c = resRec.CRMQueryResults[i].Location;
                                preAppOffers.Loan_Application__c = loanId;
                                preAppOffers.Processing_Fee__c = resRec.CRMQueryResults[i].RateofInterest!=null?Decimal.valueOf(resRec.CRMQueryResults[i].Comments):null;
                                preAppOffers.Bank_Account_Number__c = resRec.CRMQueryResults[i].BankAccountNumber;
                                preAppOffersList.add(preAppOffers);

                                if(resRec.CRMQueryResults[i].BankAccountNumber!=null){
                                    Bank_Account_Records__c bankRec = new Bank_Account_Records__c();
                                    bankRec.Account_Number__c =resRec.CRMQueryResults[i].BankAccountNumber;
                                    bankRec.Applicant__c = applicantId;
                                    bankRec.Account_Type__c = AUSF_ApexConstants.AUSF_AccountType_CASA;
                                    bankRec.Source__c = AUSF_ApexConstants.AUSF_BANK_SOURCE_PRE_APPROVED_OFFER;
                                    bankRec.Bank_Name__c = AUSF_ApexConstants.AUSF_CustomerDedupe_BANKNAME;
                                    bankAccounts.add(bankRec);
                                }
                             /*   Map<String, Bank_Account_Records__c> existingAccountsMap = new Map<String, Bank_Account_Records__c>();
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
                                }*/
                               // upsert accountsToUpdate Account_Number__c;

                               system.debug('bankAccounts :::_>'+bankAccounts);
                               upsert bankAccounts Account_Number__c;

                               /* for (Bank_Account_Records__c existingAccount : existingAccounts) {
                                    if (!existingAccountsMap.containsKey(existingAccount.Account_Number__c)) {
                                        existingAccount.InActive__c = true;
                                        existingAccount.Source__c = AUSF_ApexConstants.AUSF_BANK_SOURCE_PRE_APPROVED_OFFER;
                                        accountsToDeactivate.add(existingAccount);
                                    }
                                }
                                update accountsToDeactivate;*/
                                
                            }
                        }
                    }
                    else
                    {
                        rejectAndNotifyLoanApplication(loanId, applicantId); // reject and notify loan application.
                        throw new CustomException('Customer Match Not Found');
                    }
                }
                
            }
        }
        return preAppOffersList;
    }
    // Method to map Address__c object fields from customer dedupe response
    public static List<Address__c> getAddressRecords(AUSF_CustomerDedupeResponseWrapper res ,String applicantId, String strCIFId){
        List<Address__c> addrList = new List<Address__c>();

        //Updating existing addresses record as inactive.
        List<Address__c> exAddress = [SELECT Id, Name, Active__c, Applicant__c , Address_Source__c FROM Address__c where Applicant__c = :applicantId AND Address_Source__c = :AUSF_ApexConstants.AUSF_ADDRESS_SOURCE_CUSTOMER_DEDUPE]; 

        if(exAddress.size() > 0)
        {
            for(Address__c ad : exAddress){
                ad.Active__c = false;
                addrList.add(ad);
            }
        }

        if(res.MatchFound!=null){
            for(AUSF_CustomerDedupeResponseWrapper.MatchFound resRec :res.MatchFound){
                if(resRec.CustomerResponse.CustomerBasicInquiry.CustomerId==strCIFId){
                    Address__c  addr = new Address__c();
                    addr.Active__c = true;
                    addr.Address_Type__c = AUSF_ApexConstants.AUSF_ADDRESS_TYPE_PERMANENT;
                    addr.Address_Line_1__c = resRec.CustomerResponse.CustomerBasicInquiry.CustomerAddress.Line1;
                    addr.Address_Line_2__c = resRec.CustomerResponse.CustomerBasicInquiry.CustomerAddress.Line2;
                    addr.Address_Line_3__c = resRec.CustomerResponse.CustomerBasicInquiry.CustomerAddress.Line3;
                    addr.City__c = resRec.CustomerResponse.CustomerBasicInquiry.CustomerAddress.City;
                    addr.State__c = resRec.CustomerResponse.CustomerBasicInquiry.CustomerAddress.State;
                    addr.Pincode__c = resRec.CustomerResponse.CustomerBasicInquiry.CustomerAddress.Zip;
                    addr.Address_Source__c = AUSF_ApexConstants.AUSF_ADDRESS_SOURCE_CUSTOMER_DEDUPE;
                    addr.Applicant__c = applicantId;
                    addrList.add(addr);
                }
            }
        }
        return addrList;
    }
    // Method to map Bank_Account_Records__c object fields from customer dedupe response
    public static List<Bank_Account_Records__c> getBankAccounts(AUSF_CustomerDedupeResponseWrapper res ,String applicantId, String strCIFId){
        List<Bank_Account_Records__c>  bankAccounts = new List<Bank_Account_Records__c>();
        Map<String,String> accountTypes = AUSF_INT_IntegrationUtility.getAccountTypes();
        if(res.MatchFound!=null){
            for(AUSF_CustomerDedupeResponseWrapper.MatchFound resRec :res.MatchFound){
                if(resRec.CustomerResponse.CustomerBasicInquiry.CustomerId==strCIFId){
                    if(resRec.AccountDetails!=null){
                        for(integer i = 0; i < resRec.AccountDetails.CustomerAccount.size(); i++){
                            if(resRec.AccountDetails.CustomerAccount[i].ModuleCode == 'C'){
                                String productName = resRec.AccountDetails.CustomerAccount[i].ProductName;
                                List<String> result = productName.split('-', 2);
                                Bank_Account_Records__c bankRec = new Bank_Account_Records__c();
                                bankRec.Product_Code__c = !result.isEmpty()?result[0]:'';
                                bankRec.Product__c = !result.isEmpty()?result[1]:'';
                                bankRec.Bank_Name__c = AUSF_ApexConstants.AUSF_CustomerDedupe_BANKNAME;
                                bankRec.Account_Number__c = resRec.AccountDetails.CustomerAccount[i].AccountId;
                                bankRec.Customer_Relationship__c = resRec.AccountDetails.CustomerAccount[i].CustomerRelationship;
                                bankRec.Current_Status__c = accountTypes.get(resRec.AccountDetails.CustomerAccount[i].CurrentStatus);
                                bankRec.Current_Balance__c = resRec.AccountDetails.CustomerAccount[i].AvailableBalance!=null?Integer.valueOf(resRec.AccountDetails.CustomerAccount[i].AvailableBalance):null;
                                bankRec.Branch_Name__c = resRec.AccountDetails.CustomerAccount[i].BranchName;
                                bankRec.Account_Opening_Date__c = resRec.AccountDetails.CustomerAccount[i].DateAccountOpen!=null?Date.valueOf(resRec.AccountDetails.CustomerAccount[i].DateAccountOpen):null;
                                bankRec.Date_Of_Enquiry__c = resRec.AccountDetails.CustomerAccount[i].DateValue!=null?Date.ValueOf(resRec.AccountDetails.CustomerAccount[i].DateValue):null;
                                bankRec.Fixed_Interest_Rate__c = resRec.AccountDetails.CustomerAccount[i].IntRate!=null?Integer.valueOf(resRec.AccountDetails.CustomerAccount[i].IntRate):null;
                                bankRec.Account_Name__c = String.isNotBlank(resRec.AccountDetails.CustomerAccount[i].CASAAccountName)?resRec.AccountDetails.CustomerAccount[i].CASAAccountName:'';
                                bankRec.Applicant__c = applicantId;
                                bankRec.Account_Type__c = AUSF_ApexConstants.AUSF_AccountType_CASA;
                                bankRec.OD_Limit_Sanctioned__c = resRec.AccountDetails.CustomerAccount[i].ODLimitSactioned!=null? Decimal.valueOf(resRec.AccountDetails.CustomerAccount[i].ODLimitSactioned):null;
                                bankRec.Source__c = AUSF_ApexConstants.AUSF_BANK_SOURCE_CUSTOMER_DEDUPE;
                                bankAccounts.add(bankRec);
                            }
                        }
                    }
                }
            }
        }
        return bankAccounts;
    }
    //Method to return the Loan_aaplication__c Object fields mapped based on different criterias
    public static Loan_Application__c updateLoanApplication(AUSF_CustomerDedupeResponseWrapper res ,String loanId, Applicant__c applicant, String strCIFId){
        Loan_Application__c loanApp = [SELECT Id,Name,Stage__c,Reject_Reason__c,Reject_Sub_Reason__c FROM Loan_Application__c WHERE Id = :loanId LIMIT 1];
        Map<String,String> accountTypes = AUSF_INT_IntegrationUtility.getAccountTypes();
        Map<String,String> paramsValueMap = AUSF_INT_IntegrationUtility.getParamsValue(AUSF_ApexConstants.AUSF_CustomerDedupe_INTEGRATION_MASTER);
        Boolean odFound = false;
        if(res.MatchFound!=null){
            for(AUSF_CustomerDedupeResponseWrapper.MatchFound resRec :res.MatchFound){
                if(resRec.CustomerResponse.CustomerBasicInquiry.CustomerId==strCIFId){
                    loanApp.Branch__c = String.isNotBlank(resRec.CustomerResponse.CustomerBasicInquiry.HomeBranch)?getBranchForApplication(resRec.CustomerResponse.CustomerBasicInquiry.HomeBranch):null;
                    if(resRec.CustomerResponse.CustomerBasicInquiry.CustomerType == '105' || resRec.CustomerResponse.CustomerBasicInquiry.CustomerType == '130' || resRec.CustomerResponse.CustomerBasicInquiry.CustomerType == '101'){
                        loanApp.stage__c = AUSF_ApexConstants.AUSF_REJECT;
                        loanApp.Reject_Reason__c = AUSF_ApexConstants.REJECT_REASON_Dedupe_check;
                        loanApp.Reject_Sub_Reason__c = AUSF_ApexConstants.REJECT_SUB_REASON_Customer_is_not_full_KYC;
                        break;
                    }
                    if(resRec.CustomerResponse.CustomerBasicInquiry.MobileNumber!=applicant.Mobile_Number__c){
                        loanApp.stage__c = AUSF_ApexConstants.AUSF_REJECT;
                        loanApp.Reject_Reason__c = AUSF_ApexConstants.REJECT_REASON_Dedupe_check;
                        loanApp.Reject_Sub_Reason__c = AUSF_ApexConstants.REJECT_SUB_REASON_MobileNumberNotMatch;
                        break;
                    }
                    boolean blnNPAFound = false;
                    boolean blnDPDFound = false;
                    if(resRec.NPADPD!=null){
                        for(integer i=0 ; i<resRec.NPADPD.size();i++){
                            if (resRec.NPADPD[i].NPAStatus == 'N' && !blnNPAFound) {
                                blnNPAFound = true;
                            }
                            if (resRec.NPADPD[i].DPD > 0  && !blnDPDFound) {
                                blnDPDFound = true;
                            }
                            if(blnNPAFound && blnDPDFound){
                                break;
                            }
                        }
                        if(blnNPAFound){
                            loanApp.Stage__c = AUSF_ApexConstants.AUSF_REJECT;
                            loanApp.Reject_Reason__c = AUSF_ApexConstants.REJECT_REASON_NPA_CHECK;
                            loanApp.Reject_Sub_Reason__c = AUSF_ApexConstants.REJECT_SUB_REASON_NPA_found;
                            break;
                        }
                        if(blnDPDFound){
                            loanApp.Reject_Reason__c = AUSF_ApexConstants.REJECT_REASON_DPD_CHECK;
                            loanApp.Stage__c = AUSF_ApexConstants.AUSF_REJECT;
                            loanApp.Reject_Sub_Reason__c = AUSF_ApexConstants.REJECT_SUB_REASON_DPD_found;
                            break;
                        }
                    }

                    if(resRec.AccountDetails!=null){
                        for(integer i=0; i < resRec.AccountDetails.CustomerAccount.size(); i++){
                            if(resRec.AccountDetails.CustomerAccount[i].ModuleCode == 'C' && (resRec.AccountDetails.CustomerAccount[i].CurrentStatus == '6' || resRec.AccountDetails.CustomerAccount[i].CurrentStatus == '8') && Integer.valueOf(resRec.AccountDetails.CustomerAccount[i].ODLimitSactioned)>0){
                                odFound = true;
                                break;
                            }
                        }
                        if(odFound){
                            loanApp.stage__c = AUSF_ApexConstants.AUSF_REJECT;
                            loanApp.Reject_Reason__c = AUSF_ApexConstants.REJECT_REASON_Dedupe_check;
                            loanApp.Reject_Sub_Reason__c = AUSF_ApexConstants.REJECT_SUB_REASON_OD_found;
                            break;
                        }
                    }
                    Boolean isPfa = false;
                    Boolean isvalid = false;
                    if(resRec.CRMQueryResults!=null){
                        for(integer i=0; i < resRec.CRMQueryResults.size() ;i++){
                            if(resRec.CRMQueryResults[i].ProductId == Integer.valueOf(paramsValueMap.get('productId'))){
                                isPfa = true;
                            }
                            if(resRec.CRMQueryResults[i].ValidTill!=null && Date.valueOf(resRec.CRMQueryResults[i].ValidTill) > Date.valueOf(System.Today())){
                                isValid  = true;
                            }
                            
                        }
                    }
                    if(!isPfa){
                        loanApp.Reject_Reason__c = AUSF_ApexConstants.REJECT_REASON_Offer_eligibility;
                        loanApp.Stage__c = AUSF_ApexConstants.AUSF_REJECT;
                        loanApp.Reject_Sub_Reason__c = AUSF_ApexConstants.REJECT_SUB_REASON_PA_offer_not_found;
                        break;
                    }
                    
                    if(!isValid){
                        loanApp.Reject_Reason__c = AUSF_ApexConstants.REJECT_REASON_Offer_eligibility;
                        loanApp.Stage__c = AUSF_ApexConstants.AUSF_REJECT;
                        loanApp.Reject_Sub_Reason__c = AUSF_ApexConstants.REJECT_SUB_REASON_PA_Offer_Expired;
                        break;
                    }
                }
            }
        }
        else{
            loanApp.Stage__c = AUSF_ApexConstants.AUSF_REJECT;
            loanApp.Reject_Reason__c = AUSF_ApexConstants.REJECT_REASON_Offer_eligibility;
            loanApp.Reject_Sub_Reason__c = AUSF_ApexConstants.REJECT_SUB_REASON_NTB_Customer;
        }
        return loanApp;
    }
    
    /**
     * @description Function to update Loan App fields on the basis of PA Record
     * Inputs: Loan Application and Pre Approved Offer Record
     * Returns: Updated loan application record instance
     * Jira Story : APL-684
     */
    public static Loan_Application__c updateLoanAppForPAOffer(Loan_Application__c loanApp,List<Pre_Approved_Offer__c> preOffers){
        Map<String, Id> recordTypeMap = new Map<String, Id>();
        for (RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Loan_Application__c' AND DeveloperName IN ('Business_Loan', 'Personal_Loan')]) {
            recordTypeMap.put(rt.DeveloperName, rt.Id);
        }
        if(preOffers.size()>0){
            loanApp.Has_PA_Offer__c = true;
            if(preOffers[0].Product_Type__c == AUSF_ApexConstants.AUSF_EMPLOYMENTPREFIX_PL){
                loanApp.Employment_Type_Formula__c = AUSF_ApexConstants.AUSF_SALARIED;
                loanApp.RecordTypeId = recordTypeMap.get('Personal_Loan');
            }else{
                loanApp.Employment_Type_Formula__c = AUSF_ApexConstants.AUSF_SELF_EMPLOYEED;
                loanApp.RecordTypeId = recordTypeMap.get('Business_Loan');
            }
        }else{
            loanApp.Has_PA_Offer__c = false;
        }
        return loanApp;
    }
    //Method to get AccountId to link with Loan_Application__c Object Branch__c field
    public static String getBranchForApplication(String accountCode){
        List<Account> accRec = [SELECT Id,Account_Code__c FROM Account WHERE Account_Code__c=:accountCode];
        if(!accRec.isEmpty()){
            return accRec[0].id;
        }
        return null;
    }
    //Method to get Kyc type field
    public static Map<String,String> getKYCTypeField(){
        Map<String,String> kycMap = new Map<String,String>{'INDIVIDUAL - FULL KYC'=>'100','INDIVIDUAL - NO KYC'=>'101','INDIVIDUAL- NRI'=>'102','INDIVIDUAL - NRE'=>'103','INDIVIDUAL - MIN KYC'=>'104','ARTIFICIAL JURIDICAL PERSON'=>'ARTIFICIAL JURIDICAL PERSON','NRO NON ITR'=>'NRO NON ITR','FOREIGN NATIONAL STUDENTS'=>'FOREIGN NATIONAL STUDENTS','FOREIGN NATIONAL'=>'FOREIGN NATIONAL',
            'INDIVIDUAL SENIOR CITIZEN-SPL'=>'INDIVIDUAL SENIOR CITIZEN-SPL','INDIVIDUAL-SPL'=>'INDIVIDUAL-SPL','MICROFINANCE INSTITUTION NON TAX'=>'MICROFINANCE INSTITUTION NON TAX','MICROFINANCE INSTITUTION TAX'=>'MICROFINANCE INSTITUTION TAX','PSU NO TAX'=>'PSU NO TAX','PSU TAX'=>'PSU TAX','ARC NO TAX'=>'ARC NO TAX','ARC TAX'=>'ARC TAX','HFC NO TAX'=>'HFC NO TAX','HFC TAX'=>'HFC TAX',
            'SEC. 8 COMPANY'=>'SEC. 8 COMPANY','BENEFICIARY OWNER'=>'BENEFICIARY OWNER','NRI MINOR'=>'NRI MINOR','NBFC NO TAX'=>'NBFC NO TAX','NBFC TAX'=>'NBFC TAX','PF NO TAX'=>'PF NO TAX','PF TAX'=>'PF TAX','PENSION NO TAX'=>'PENSION NO TAX','PENSION TAX'=>'PENSION TAX','INSURANCE NO TAX'=>'INSURANCE NO TAX','INSURANCE TAX'=>'INSURANCE TAX','MUTUAL FUNDS NO TAX'=>'MUTUAL FUNDS NO TAX',
            'MUTUAL FUNDS TAX'=>'MUTUAL FUNDS TAX','FINANCIAL INSTITUTIONS NO TAX'=>'FINANCIAL INSTITUTIONS NO TAX','FINANCIAL INSTITUTIONS TAX'=>'FINANCIAL INSTITUTIONS TAX','INDIVIDUAL SENIOR CITIZEN- NO KYC'=>'INDIVIDUAL SENIOR CITIZEN- NO KYC','INDIVIDUAL SENIOR CITIZEN - MIN KYC'=>'INDIVIDUAL SENIOR CITIZEN - MIN KYC','INDIVIDUAL SENIOR CITIZEN - FULL KYC'=>'INDIVIDUAL SENIOR CITIZEN - FULL KYC',
            'GOVERNMENT (TAXABLE)'=>'GOVERNMENT (TAXABLE)','SHG (STANDS FOR SELF HELP GROUP)'=>'SHG (STANDS FOR SELF HELP GROUP)','BANK'=>'BANK','PATNERSHIP ULTD LIAB'=>'PATNERSHIP ULTD LIAB','PATNERSHIP LTD LIAB'=>'PATNERSHIP LTD LIAB','OTHERS'=>'OTHERS','INSTITUTION'=>'INSTITUTION','GOVT.'=>'GOVT.','UNIVERSITY'=>'UNIVERSITY','TRUST'=>'TRUST','CLUB'=>'CLUB','SOCIETY'=>'SOCIETY','AOP'=>'AOP',
        'MNC'=>'MNC','PUBLIC LTD CO.'=>'PUBLIC LTD CO.','PVT LTD'=>'PVT LTD','HUF'=>'HUF','SOLE PROPERTARY'=>'SOLE PROPERTARY','BUSINESS'=>'BUSINESS','PARTNERSHIP FIRMS'=>'PARTNERSHIP FIRMS','INDIVIDUAL BUSINESS'=>'INDIVIDUAL BUSINESS','INDIVIDUAL MINOR'=>'INDIVIDUAL MINOR','INDIVIDUAL - MIN KYC'=>'INDIVIDUAL - MIN KYC'};
        return kycMap;
    }
    public static Boolean getRejectedCustomers(AUSF_CustomerDedupeResponseWrapper.CustomerBasicInquiry customer,String filter,applicant__c applicant){
        Boolean blnReject = false;
        if(filter == 'Full KYC' && (customer.CustomerType == '105' || customer.CustomerType == '130' || customer.CustomerType == '101')){
            blnReject = true;
        }
        if(filter== 'Mobile Check' && customer.MobileNumber!=applicant.Mobile_Number__c)
        {
            blnReject = true;
        }
        return blnReject;
    }

    public static void loanRejectNotify(Loan_Application__c loanToUpdate, String applicantId)
    {
        if(loanToUpdate.Stage__c == AUSF_ApexConstants.AUSF_REJECT){
            String strTriggerPoint = AUSF_ApexConstants.AUSF_TriggerPoint_Case_Rejection;
            AUSF_NotificationController.LoanAppWrapper loanAppWrapperObj = new AUSF_NotificationController.LoanAppWrapper(null,null,applicantId,loanToUpdate.Id,strTriggerPoint,null);
            AUSF_SMSNotificationHandler.sendSmsNotification(loanAppWrapperObj);
        }
    }

    public static void rejectAndNotifyLoanApplication(String loanId, String applicantId)
    {
        Loan_Application__c loanToUpdate = new Loan_Application__c(Id=loanId);
        loanToUpdate.stage__c = AUSF_ApexConstants.AUSF_REJECT;
        loanToUpdate.Reject_Reason__c = AUSF_ApexConstants.REJECT_REASON_Dedupe_check;
        loanToUpdate.Reject_Sub_Reason__c = 'Pre-Approved Offers Not Found';
        update loanToUpdate;

        loanRejectNotify(loanToUpdate, applicantId);
    }

    public class InnerResponse {
        @AuraEnabled
        public String strMsg {get; set;}
        @AuraEnabled
        public Boolean blnSuccess = false;
        @AuraEnabled
        public Boolean blnStageReject = false;
    }

    public class CustomException extends Exception {}
}