/**
* @author  Asmita Mathur
* @company Salesforce.com
* @description : Test class for AUSF_ListViewRecordCountController class
* History:
*
*************************************************************************************
MODIFICATION LOG
* Version     Date                Developer            Description
*-------------------------------------------------------------------------------------------
*  1.0    26th July 2024          Asmita Mathur       Initial Creation
*/

@isTest
public class AUSF_ListViewRecordCountController_Test {
     
    @TestSetup
    static void createData(){
        List<Loan_Application__c> loanApps = new List<Loan_Application__c>();   
        loanApps = AUPL_TestDataFactory.createActiveLoanApplications(loanApps,1);
        insert loanApps;
        AUSF_TestDataFactory.createApplicantRecords(loanApps,1);
    }
    @isTest
    public static void getListViewsTest(){
        string ObjectName = 'Loan_Application__c';
        List<ListView> result = AUSF_ListViewRecordCountController.getListViews(ObjectName);
        System.assertEquals(10, result.size());
        
    }
    
    @isTest
    public static void getListViewsFailureTest(){
        string ObjectName = 'TestObject';
        List<ListView> result = AUSF_ListViewRecordCountController.getListViews(null);
        System.assertEquals(0, result.size());
        
    }
    
    @isTest
    public static void getFilteredRecordCountFailureTest(){
        string filterCondition = '';
        Integer result = AUSF_ListViewRecordCountController.getFilteredRecordCount(filterCondition);
        System.assertEquals(null, result);
        
    }
    
    @isTest
    public static void getFilteredRecordCountSuccessTest(){
        List<Loan_Application__c> loanAppList = [SELECT Id, Stage__c FROM Loan_Application__c WHERE Stage__c = 'Pending' LIMIT 1];
        string filterCondition = 'Stage__c = \'Pending\' ' ;
        Integer result = AUSF_ListViewRecordCountController.getFilteredRecordCount(filterCondition);
        System.assertEquals(1, result);
        
    }
    
    

}