/**
 * @author        Pradeep Sharma
 * Class :		 AUSF_HunterAPIHandler
 * Test Class	 AUSF_HunterAPITest
 * @date          5-July-2024
 * @description   Handler for Hunter API
 * Modification Log:
--------------------------------------------------------------------------------------------
    Developer             Date            Description
    --------------------------------------------------------------------------------------------
    Pradeep Sharma        5-July-2024    Initial Version
*/
public without sharing class AUSF_HunterAPIHandler implements AUSF_INT_IntegrationHandlerInterface {
    
        public List < String > generateRequest(List < Object > inputWrappers) {
            List<String> lstRequestString = new List<String>();
            if (inputWrappers.isEmpty()) {
                return new List < String > ();
            }          
            AUSF_INT_IntegrationUtility.InputWrapper inputWrapper = (AUSF_INT_IntegrationUtility.InputWrapper)inputWrappers.get(0);
            AUSF_HunterAPIRequestWrapper objRequest = new AUSF_HunterAPIRequestWrapper();
            AUSF_HunterAPIRequestWrapper.ControlBlock cb = new AUSF_HunterAPIRequestWrapper.ControlBlock();
            AUSF_HunterAPIRequestWrapper.Customer cust= new AUSF_HunterAPIRequestWrapper.Customer();
            AUSF_HunterAPIRequestWrapper.Loading load= new AUSF_HunterAPIRequestWrapper.Loading();
            AUSF_HunterAPIRequestWrapper.Results result= new AUSF_HunterAPIRequestWrapper.Results();
            AUSF_HunterAPIRequestWrapper.Scores score= new AUSF_HunterAPIRequestWrapper.Scores();
            AUSF_HunterAPIRequestWrapper.SpecificScores specScore = new AUSF_HunterAPIRequestWrapper.SpecificScores();
            AUSF_HunterAPIRequestWrapper.Matching match= new AUSF_HunterAPIRequestWrapper.Matching();
            AUSF_HunterAPIRequestWrapper.MatchSchemeSet matchScheme = new AUSF_HunterAPIRequestWrapper.MatchSchemeSet();
            cust.CustomerID = String.valueOf(inputWrapper.dynamicInputs.get('CustomerId'));
            cust.CustomerName = String.valueOf(inputWrapper.dynamicInputs.get('CustomerName'));
            cb.Customer = cust;
            load.SuppressVersion = String.valueOf(inputWrapper.dynamicInputs.get('SuppressVersion'));
            load.SubmissionLoad = String.valueOf(inputWrapper.dynamicInputs.get('SubmissionLoad'));
            cb.Loading = load;
            specScore.ResultType = String.valueOf(inputWrapper.dynamicInputs.get('ResultType'));
            specScore.ScoreType = String.valueOf(inputWrapper.dynamicInputs.get('ScoreType'));
            score.SpecificScores = specScore;
            result.Scores = score;
            result.ResultCode = String.valueOf(inputWrapper.dynamicInputs.get('ResultCode'));
            cb.Results = result;
            matchScheme.SchemeSetID = inputWrapper.dynamicInputs.get('SchemeSetID')!=null?String.valueOf(inputWrapper.dynamicInputs.get('SchemeSetID')).split(','):new List<String>{};
            match.MatchSchemeSet = matchScheme;
            match.WorklistInsert = String.valueOf(inputWrapper.dynamicInputs.get('WorklistInsert'));
            match.PersistMatches = String.valueOf(inputWrapper.dynamicInputs.get('PersistMatches'));
            cb.Matching = match;
            objRequest.ControlBlock = cb;
            AUSF_HunterAPIRequestWrapper.BatchBlock bb = new AUSF_HunterAPIRequestWrapper.BatchBlock();
            AUSF_HunterAPIRequestWrapper.Header head= new AUSF_HunterAPIRequestWrapper.Header();
            AUSF_HunterAPIRequestWrapper.Submissions submissions = new AUSF_HunterAPIRequestWrapper.Submissions();
            AUSF_HunterAPIRequestWrapper.Submission submission = new AUSF_HunterAPIRequestWrapper.Submission();
            AUSF_HunterAPIRequestWrapper.MainApplicant mainApplicant = new AUSF_HunterAPIRequestWrapper.MainApplicant();
            AUSF_HunterAPIRequestWrapper.ResidentialAddress residentialAddress = new AUSF_HunterAPIRequestWrapper.ResidentialAddress();
            AUSF_HunterAPIRequestWrapper.PermanentAddress permanentAddress = new AUSF_HunterAPIRequestWrapper.PermanentAddress();
            AUSF_HunterAPIRequestWrapper.HomeTelephone homeTel = new AUSF_HunterAPIRequestWrapper.HomeTelephone();
            AUSF_HunterAPIRequestWrapper.MobileTelephone mobTel = new AUSF_HunterAPIRequestWrapper.MobileTelephone();
            AUSF_HunterAPIRequestWrapper.BusinessTelephone busTel = new AUSF_HunterAPIRequestWrapper.BusinessTelephone();
            AUSF_HunterAPIRequestWrapper.Email email = new AUSF_HunterAPIRequestWrapper.Email();
            AUSF_HunterAPIRequestWrapper.IDDocument idDoc = new AUSF_HunterAPIRequestWrapper.IDDocument();
            idDoc.DocumentType = String.valueOf(inputWrapper.dynamicInputs.get('DocumentType'));
            idDoc.DocNumber = String.isNotBlank(inputWrapper.applicantRecord.PAN__c)?inputWrapper.applicantRecord.PAN__c:'';
            mainApplicant.IDDocument = idDoc;
            email.EmailAddress = String.isNotBlank(inputWrapper.applicantRecord.Personal_Email_Id__c)?inputWrapper.applicantRecord.Personal_Email_Id__c:'';
            mainApplicant.Email = email;
            busTel.TelephoneNumber = String.isNotBlank(inputWrapper.applicantRecord.Mobile_Number__c)?inputWrapper.applicantRecord.Mobile_Number__c:'';
            mainApplicant.BusinessTelephone = busTel;
            mobTel.TelephoneNumber = String.isNotBlank(inputWrapper.applicantRecord.Mobile_Number__c)?inputWrapper.applicantRecord.Mobile_Number__c:'';
            mainApplicant.MobileTelephone = mobTel;
            homeTel.TelephoneNumber = String.isNotBlank(inputWrapper.applicantRecord.Mobile_Number__c)?inputWrapper.applicantRecord.Mobile_Number__c:'';
            mainApplicant.HomeTelephone = homeTel;
            permanentAddress.AddressLines = String.valueOf(inputWrapper.dynamicInputs.get('PA_AddressLines'));
            permanentAddress.Pincode = String.valueOf(inputWrapper.dynamicInputs.get('PA_Pincode'));
            permanentAddress.Country = String.valueOf(inputWrapper.dynamicInputs.get('Country'));
            permanentAddress.State = String.valueOf(inputWrapper.dynamicInputs.get('PA_State'));
            permanentAddress.City = String.valueOf(inputWrapper.dynamicInputs.get('PA_City'));
            mainApplicant.PermanentAddress = permanentAddress;
            residentialAddress.AddressLines = String.valueOf(inputWrapper.dynamicInputs.get('RA_AddressLines'));
            residentialAddress.Pincode = String.valueOf(inputWrapper.dynamicInputs.get('RA_Pincode'));
            residentialAddress.Country = String.valueOf(inputWrapper.dynamicInputs.get('Country'));
            residentialAddress.State = String.valueOf(inputWrapper.dynamicInputs.get('RA_State'));
            residentialAddress.City = String.valueOf(inputWrapper.dynamicInputs.get('RA_City'));
            mainApplicant.ResidentialAddress = residentialAddress;
            mainApplicant.Age = inputWrapper.applicantRecord.Age__c!=null?String.valueOf(inputWrapper.applicantRecord.Age__c):'';
            mainApplicant.Gender = String.isNotBlank(inputWrapper.applicantRecord.Gender__c) && inputWrapper.applicantRecord.Gender__c=='Others'?'OTHER':String.isNotBlank(inputWrapper.applicantRecord.Gender__c)?inputWrapper.applicantRecord.Gender__c.toUpperCase():'OTHER';
            mainApplicant.DOB = inputWrapper.applicantRecord.Birth_Date__c!=null ?String.valueOf(inputWrapper.applicantRecord.Birth_Date__c):'';
            mainApplicant.MaritalStatus = String.isNotBlank(inputWrapper.applicantRecord.Marital_Status__c)?inputWrapper.applicantRecord.Marital_Status__c:'';
            mainApplicant.LastName = String.isNotBlank(inputWrapper.applicantRecord.Last_Name__c)?inputWrapper.applicantRecord.Last_Name__c:'';
            mainApplicant.Qualification = String.isNotBlank(inputWrapper.applicantRecord.Educational_Qualification__c)?inputWrapper.applicantRecord.Educational_Qualification__c:'';
            mainApplicant.FirstName = String.isNotBlank(inputWrapper.applicantRecord.First_Name__c)?inputWrapper.applicantRecord.First_Name__c:'';
            mainApplicant.MonthlySalary = '';
            mainApplicant.PAN_No = String.isNotBlank(inputWrapper.applicantRecord.PAN__c)?inputWrapper.applicantRecord.PAN__c:'';
            submission.MainApplicant = mainApplicant;
            submission.LoanPurpose = String.valueOf(inputWrapper.dynamicInputs.get('LoanPurpose'));
            submission.ApplicationDate = String.valueOf(Date.Today());
            submission.SubmissionDate = String.valueOf(Date.Today());
            submission.Identifier = String.isNotBlank(inputWrapper.applicantRecord.Loan_application__r.Name)?inputWrapper.applicantRecord.Loan_application__r.Name:'';
            submission.ProductCode = String.valueOf(inputWrapper.dynamicInputs.get('ProductCode'));
            submission.Classification = String.valueOf(inputWrapper.dynamicInputs.get('Classification'));
            submissions.Submission = submission;
            bb.Submissions = submissions;
            head.Originator = String.valueOf(inputWrapper.dynamicInputs.get('Originator'));
            head.Count = String.valueOf(inputWrapper.dynamicInputs.get('Count'));
            bb.Header = head;
            objRequest.BatchBlock = bb;
            objRequest.RequestId = AUSF_INT_IntegrationUtility.getReferenceId();
            objRequest.OriginatingChannel = inputWrapper.integrationMasterRecord.Channel__c;
            objRequest.ReferenceNumber = AUSF_INT_IntegrationUtility.getReferenceId();
            objRequest.TransactionBranch = String.valueOf(inputWrapper.dynamicInputs.get('TransactionBranch'));
            objRequest.Username = String.valueOf(inputWrapper.dynamicInputs.get('Username'));
            objRequest.Password = String.valueOf(inputWrapper.dynamicInputs.get('Password'));
            lstRequestString.add(JSON.serialize(objRequest));
            return lstRequestString;
        }
    
        public List < String > validateInputData(List < Object > inputWrappers) {
            if (inputWrappers.isEmpty()) {
                return new List < String > ();
            }
            List < String > validationErrorsList = new List < String > ();        
            return validationErrorsList;
        }
    
        public void beforeUpdateService(Integration_Checklist__c checklistRecord, ContentVersion responseFile) {
            // TODO
        }
    
        public void callbackService(List < Integration_Checklist__c > checklistRecords, List < ContentVersion > responseFiles) {
            // TODO
        }
    
        public List < sObject > generatePlatformEvents(List < Object > inputWrappers) {
            return null;
        }
}