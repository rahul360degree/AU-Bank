@isTest
public class AUSF_CommunicationAddressController_Test {
    
    @isTest
    static void testRejectApplication(){
        Loan_Application__c loanApp = new Loan_Application__c();
        insert loanApp;
        Applicant__c applicant = new Applicant__c(Loan_Application__c = loanApp.id);
        insert applicant;
        
        AUSF_CommunicationAddressController.rejectApplication(loanApp.id, 'PEP');
        AUSF_CommunicationAddressController.rejectApplication(loanApp.id, 'NRI');
        
        AUSF_CommunicationAddressController.rejectApplication('loanApp.id', 'NEGATIVETEST');
    }


    @isTest
    static void testUpdateApplicantAddressTenuret(){
        Loan_Application__c loanApp = new Loan_Application__c();
        insert loanApp;
        Applicant__c applicant = new Applicant__c(Loan_Application__c = loanApp.id);
        insert applicant;
        Address__c addressObj = new Address__c();
        addressObj.Pincode__c = '111111';
        addressObj.Address_Type__c = 'Current';
        addressObj.Address_Line_1__c = 'TestAddrs1';
        addressObj.Address_Line_2__c = 'TestAddrs2';
        addressObj.Address_Line_3__c = 'TestAddrs3';
        addressObj.Applicant__c = applicant.id;
        addressObj.Active__c = true;

        Address__c addressObj1 = new Address__c();
        addressObj1.Pincode__c = '111111';
        addressObj1.Address_Type__c = 'Current';
        addressObj1.Address_Line_1__c = 'TestAddrs1';
        addressObj1.Address_Line_2__c = 'TestAddrs2';
        addressObj1.Address_Line_3__c = 'TestAddrs3';
        addressObj1.Applicant__c = applicant.id;
        addressObj1.Active__c = true;
        insert new List<Address__c> {addressObj, addressObj1};

        AUSF_CommunicationAddressController.updateApplicantAddressTenure(addressObj.id, '2', '2', 'Owned', applicant.id);
        AUSF_CommunicationAddressController.updateApplicantAddressTenure('addressObj.id', '2', '2', 'NEGATIVE', 'applicant.id');

    }
}