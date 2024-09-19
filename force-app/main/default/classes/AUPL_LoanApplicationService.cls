/**
* @author Murtaza Ali
* @company Salesforce.com
* @description A service class for the Loan Application
* Test Class: AUPL_LoanApplicationService_test
* Jira Story Number : APL-88
*/

public with sharing class AUPL_LoanApplicationService {
    // Configurable value for the number of days
    public static Integer nDays = Integer.valueOf(Label.AUPL_LastNDaysConfig);
    
    public class DedupeResult {
        public String dedupeStatus;
        public String message;
        public Loan_Application__c existingLoanApplication;
    }
    /** 
	* @description Function to check if already a Loan Application Present in the LOS data base 
	* Inputs: Mobile Number of the user.
	* Returns: result whether active loan appliaction is present in the system or not.
    * Jira Story :- APL-88
	*/
    public static Map<String, DedupeResult> localDedupeSearch(List<String> mobileNumbers) {
        Map<String, DedupeResult> results = new Map<String, DedupeResult>();
        Date nDaysAgo = Date.today().addDays(-nDays);
        // Query to find loan applications with the given mobile numbers
        List<Loan_Application__c> loanApplications = [
            SELECT Id, Name, Branch__c, Lead_reference_number__c, SO_Name__c, SO_Employee_Id__c, Stage__c, Exempt_Duplicate__c, LastModifiedDate, Mobile_Number__c
            FROM Loan_Application__c
            WHERE Mobile_Number__c IN :mobileNumbers
            AND LastModifiedDate >= :nDaysAgo
            AND Exempt_Duplicate__c = false
        ];
        // Group loan applications by mobile number
        Map<String, List<Loan_Application__c>> loanAppsByMobile = new Map<String, List<Loan_Application__c>>();
        for (Loan_Application__c loanApp : loanApplications) {
            if (!loanAppsByMobile.containsKey(loanApp.Mobile_Number__c)) {
                loanAppsByMobile.put(loanApp.Mobile_Number__c, new List<Loan_Application__c>());
            }
            loanAppsByMobile.get(loanApp.Mobile_Number__c).add(loanApp);
        }
        // Process each mobile number
        for (String mobileNumber : mobileNumbers) {
            DedupeResult result = new DedupeResult();
            result.dedupeStatus = '';
            result.message = '';
            Boolean activeApplication = false;
            Boolean cancelledApp = false;
            Boolean rejectApp = false;
            Loan_Application__c rejectLoan;
            if (loanAppsByMobile.containsKey(mobileNumber)) {
                List<Loan_Application__c> loanApps = loanAppsByMobile.get(mobileNumber);
                for (Loan_Application__c loanApp : loanApps) {
                    if (loanApp.Stage__c != 'Cancelled' && loanApp.Stage__c != 'Reject') {
                        if (loanApp.Stage__c == 'disbursed') {
                            result.dedupeStatus = 'Disbursed';
                            result.existingLoanApplication = loanApp;
                            result.message = '';
                            activeApplication = true;
                        } else {
                            result.dedupeStatus = 'Resume';
                            result.existingLoanApplication = loanApp;
                            activeApplication = true;
                        }
                        break;
                    } else if (loanApp.Stage__c == 'Cancelled') {
                        cancelledApp = true;
                    } else {
                        rejectApp = true;
                        rejectLoan = loanApp;
                    }
                }
                if (!activeApplication && !rejectApp) {
                    // Allow fresh lead creation
                    result.dedupeStatus = 'New';
                    result.existingLoanApplication = createNewLoanApplication(mobileNumber);
                } else if (!activeApplication && rejectLoan != null) {
                    result.dedupeStatus = 'Reject';
                    result.message = 'Lead has been rejected with following params: ' +
                        'Name: ' + rejectLoan.Name + ', ' +
                        'Branch: ' + rejectLoan.Branch__c + ', ' +
                        'Reference Number: ' + rejectLoan.Lead_reference_number__c + ', ' +
                        'SO Name: ' + rejectLoan.SO_Name__c + ', ' +
                        'SO Employee Id: ' + rejectLoan.SO_Employee_Id__c + ', ' +
                        'Stage: ' + rejectLoan.Stage__c;
                    result.existingLoanApplication = rejectLoan;
                }
            } else {
                // No duplicate lead found, create a new loan application
                result.dedupeStatus = 'New';
                result.existingLoanApplication = createNewLoanApplication(mobileNumber);
            }
            results.put(mobileNumber, result);
        }
        return results;
    }
    
    /** 
	* @description Function to create a new loan application record 
	* Inputs: Mobile Number of the user.
	* Returns: new created loan application record instance 
    * Jira Story : APL-88
	*/
    @testVisible
    private static Loan_Application__c createNewLoanApplication(String mobileNumber) {
        RecordType personalLoanRecordType = [SELECT Id FROM RecordType WHERE SObjectType = 'Loan_Application__c' AND Name = 'Personal Loan' LIMIT 1];
        Loan_Application__c newLoanApp = new Loan_Application__c();
        newLoanApp.Mobile_Number__c = mobileNumber;
        newLoanApp.Loan_Processing_Consent__c = true;
        newLoanApp.Loan_Processing_Consent_Captured_At__c = System.now();
        newLoanApp.Stage__c = 'Lead';
        newLoanApp.RecordTypeId = personalLoanRecordType.Id;
        insert newLoanApp;
        System.debug('New loan application created with mobile number: ' + mobileNumber);
        return newLoanApp;
        
    }

    /** 
	* @description Function to populate Loan Application Number with the required format after claim offer
	* Inputs: List of Applicants records
	* Returns: void
    * Jira Story : APL-700
	*/
    public static void populateLoanApplicationNumber(List<Applicant__c> applicants) {
        // Query Applicants with related Loan Applications and Branch (Account)
        List<Applicant__c> applicantsWithLoanApps = [
        SELECT Id, Employment_Type__c, Loan_Application__c,
        Loan_Application__r.Name,
        Loan_Application__r.Branch__c, Loan_Application__r.Lead_reference_number__c,Loan_Application__r.Branch__r.City__c
        FROM Applicant__c
        WHERE Id IN :applicants
        ];
        // Prepare list to update Loan Applications
        List<Loan_Application__c> loanApplicationsToUpdate = new List<Loan_Application__c>();
        // Iterate over applicants and populate Loan Application Number
        for (Applicant__c applicant : applicantsWithLoanApps) {
            Loan_Application__c loanApp = applicant.Loan_Application__r;
            if (loanApp != null) {
                String employmentTypePrefix = 'BL'; // Default to 'BL'
                if (applicant.Employment_Type__c != null && applicant.Employment_Type__c.equalsIgnoreCase('Salaried')) {
                    employmentTypePrefix = 'PL';
                }
                String city = loanApp.Branch__r.City__c != null ? loanApp.Branch__r.City__c : '';
                String cityPrefix = city.length() >= 3 ? city.substring(0, 3).toUpperCase() : city.toUpperCase();
                String autoNumber = loanApp.Lead_reference_number__c != null ? loanApp.Lead_reference_number__c.substring(5) : '';
                // Construct the Loan Application Number
                String loanAppNumber = employmentTypePrefix + cityPrefix + '-' + autoNumber;
                // Set the Loan Application Number
                loanApp.Name = loanAppNumber;
                // Add to the list for update
                loanApplicationsToUpdate.add(loanApp);
            }
        }
        // Update Loan Applications
        if (!loanApplicationsToUpdate.isEmpty()) {
            update loanApplicationsToUpdate;
        }
    }
}