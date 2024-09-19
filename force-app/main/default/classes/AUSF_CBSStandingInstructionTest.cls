@isTest
public class AUSF_CBSStandingInstructionTest {
    @testSetup 
    public static void setup() {
        Integration_Master__c intMaster = AUSF_TestDataFactory.createIntegrationMaster(AUSF_ApexConstants.AUSF_CBSSI_INTEGRATION_MASTER, 'https://api.aubankuat.in/sfdccbs/CBSLoanAccountDrawdownInstMntService/LoanAccountDrawDown','SFDC','POST', 'application/json', 'AUSF_CBSStandingInstructionHandler');
        Loan_Application__c loanApp = AUSF_TestDataFactory.createActiveLoanApplications(new List<Loan_Application__c>(),1)[0];
        insert loanApp;
        insert intMaster;
    }
    @isTest
    public static void testSuccess(){
        Test.startTest();
        String loanId = [SELECT Id FROM Loan_Application__c][0].Id;
        Test.setMock(HttpCalloutMock.class, new AUSF_IntegrationMockResponse('200','0'));
        AUSF_INT_CBSSIWrapper objResponse = AUSF_CBSStandingInstructionController.callCBSSIApi(loanId);
        AUSF_CBSStandingInstructionHandler cbsSIApi = new AUSF_CBSStandingInstructionHandler();
        cbsSIApi.beforeUpdateService(null,null);
        cbsSIApi.callbackService(null, null);
        cbsSIApi.generatePlatformEvents(null);
        Test.StopTest();
        String Status=[SELECT Id,Name,Status__c FROM Integration_Checklist__c WHERE Loan_Application__c = :loanId LIMIT 1].Status__c;
        Assert.areEqual('Completed' ,status ,'IC-Complete');

    }
}