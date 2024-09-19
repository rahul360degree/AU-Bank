/**
* @author  Nitesh jaiswal
* @company Salesforce.com
* @description :
* History:
*
*************************************************************************************
MODIFICATION LOG
* Version     Date                Developer            Description
*-------------------------------------------------------------------------------------------
*  1.0    27th June 2024          Nitesh jaiswal       Initial Creation
*/

@istest
public  class AUSF_ConfirmPersonalDetailControler_Test {

    @TestSetup
    static void makeData(){
        Location_Master__c locationMasterObj = new Location_Master__c();
        locationMasterObj.Name = '132024';
        locationMasterObj.Zip_Code__c  = '132024';
        locationMasterObj.Working_Area__c = 'No';
        locationMasterObj.City__c = 'Test';
        locationMasterObj.State__c = 'Rajasthan';
        insert locationMasterObj;

        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();   
        loanApps = AUPL_TestDataFactory.createActiveLoanApplications(loanApps,1);
        insert loanApps;
    }

    @istest
    static void validatePinCodeTest(){
        test.startTest();
        string pinCode = '132024';
        List<Location_Master__c> locationMasterList = AUSF_ConfirmPersonalDetailsController.validatePinCode(pinCode,[SELECT Id FROM Loan_Application__c LIMIT 1].Id);
        system.assertEquals(1,locationMasterList.size());
        test.stopTest();
    }
    @istest
    static void validatePinCodeCatch(){
        test.startTest();
        string pinCode = '132024';
        AUSF_ConfirmPersonalDetailsController.throwException = true;
        List<Location_Master__c> locationMasterList = AUSF_ConfirmPersonalDetailsController.validatePinCode(pinCode,[SELECT Id FROM Loan_Application__c LIMIT 1].Id);
        test.stopTest();
    }
}