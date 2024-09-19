/**
* @author           :   Mohit M.
* @date             :   25-June-2024
* @description      :   Code coverage for AUSF_RuleEngineHandler
* @Covered          :   AUSF_RuleEngineHandler
* @Code Coverage    :   
* Modification Log:
  --------------------------------------------------------------------------------------------
  Developer             Date            Description
  --------------------------------------------------------------------------------------------
  Mohit M.              24-June-2024    Initial Version
*/
@isTest
public class AUSF_RuleEngineHandler_Test {
    @testSetup 
    static void setup() {

        Profile objProfile = [SELECT Id, Name FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User objUser = new User(Alias = 'adminstd', Email='adminstd@testorg.com', 
                            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                            LocaleSidKey='en_US', ProfileId = objProfile.Id,
                            TimeZoneSidKey='America/Los_Angeles', UserName='adminstd@testorg.com');
        insert objUser ;
        system.runAs(objUser) {
            List<Document_Master__c> lstDM = new List<Document_Master__c>();

            Document_Master__c  docMaster = new Document_Master__c();
            docMaster.Name ='AUPL000001';
            docMaster.Document_Id__c = 'AUPL000001';
            docMaster.Active__c = true;
            lstDM.add(docMaster);

            docMaster = new Document_Master__c();
            docMaster.Name ='AUPL000002';
            docMaster.Document_Id__c = 'AUPL000002';
            docMaster.Active__c = true;
            lstDM.add(docMaster);

            docMaster = new Document_Master__c();
            docMaster.Name ='AUPL000003';
            docMaster.Document_Id__c = 'AUPL000003';
            docMaster.Active__c = true;
            lstDM.add(docMaster);

            insert lstDM;

            List<Rule_Definition__c> lstRuleDef = new List<Rule_Definition__c>();

            Rule_Definition__c objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = 'Personal_Loan';
            objRuleDef.Subject_Field__c = 'Record_Type_Developer_Name__c';
            objRuleDef.Rule_Condition__c = 'Contains';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 1;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);

            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = 'Personal_Loan';
            objRuleDef.Subject_Field__c = 'Record_Type_Developer_Name__c';
            objRuleDef.Rule_Condition__c = 'Equals';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 2;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);

            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = 'Personal_Loan';
            objRuleDef.Subject_Field__c = 'Record_Type_Developer_Name__c';
            objRuleDef.Rule_Condition__c = 'Starts With';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 3;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);

            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = 'Personal_Loan';
            objRuleDef.Subject_Field__c = 'Record_Type_Developer_Name__c';
            objRuleDef.Rule_Condition__c = 'Ends With';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 4;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);

            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = 'Personal_Loan';
            objRuleDef.Subject_Field__c = 'Record_Type_Developer_Name__c';
            objRuleDef.Rule_Condition__c = 'Not Equals';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 5;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);

            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = 'Personal_Loan';
            objRuleDef.Subject_Field__c = 'Record_Type_Developer_Name__c';
            objRuleDef.Rule_Condition__c = 'Does not Contains';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 6;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);

            
            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = '100000';
            objRuleDef.Attribute_Lower_Limit__c = 100000;
            objRuleDef.Attribute_Upper_Limit__c = 120000;
            objRuleDef.Subject_Field__c = 'Loan_Amount__c';
            objRuleDef.Rule_Condition__c = 'Between';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 1;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);
            

            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = 'Personal_Loan';
            objRuleDef.Subject_Field__c = 'Record_Type_Developer_Name__c';
            objRuleDef.Rule_Condition__c = 'Includes';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 7;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);

            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = 'Personal_Loan';
            objRuleDef.Subject_Field__c = 'Record_Type_Developer_Name__c';
            objRuleDef.Rule_Condition__c = 'Excludes';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 8;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);

            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = '100000';
            objRuleDef.Subject_Field__c = 'Loan_Amount__c';
            objRuleDef.Rule_Condition__c = 'Greater Than';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 9;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);

            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = '100000';
            objRuleDef.Subject_Field__c = 'Loan_Amount__c';
            objRuleDef.Rule_Condition__c = 'Less Than';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 10;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);

            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = '100000';
            objRuleDef.Subject_Field__c = 'Loan_Amount__c';
            objRuleDef.Rule_Condition__c = 'Equals';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 11;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);

            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = '100000';
            objRuleDef.Subject_Field__c = 'Loan_Amount__c';
            objRuleDef.Rule_Condition__c = 'Less or Equal';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 12;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);

            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = '100000';
            objRuleDef.Subject_Field__c = 'Loan_Amount__c';
            objRuleDef.Rule_Condition__c = 'Greater or Equal';
            objRuleDef.Subject_Object__c = 'Loan_Application__c';
            objRuleDef.Target_Object__c = 'Document_Checklist__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 13;
            objRuleDef.Rule_Name__c = 'Application Rule';
            lstRuleDef.add(objRuleDef);
            insert lstRuleDef;

            /*
            objRuleDef = new Rule_Definition__c();
            objRuleDef.Attribute_Fixed_Value__c = 'Personal_Loan';
            objRuleDef.Subject_Field__c = 'Loan_Application__r.Record_Type_Developer_Name__c';
            objRuleDef.Rule_Condition__c = 'Contains';
            objRuleDef.Target_Object__c = 'Applicant__c';
            objRuleDef.Value_Field__c = 'Value';
            objRuleDef.Sequence__c = 1;
            objRuleDef.Rule_Name__c = 'Applicant Rule';
            lstRuleDef.ad1d(objRuleDef);
            */

            List<Rule_Driver__c> lstRuleDriver = new List<Rule_Driver__c>();

            for (Integer i=1;i<=1;i++) {
                Rule_Driver__c objRuleDriver = new Rule_Driver__c();
                objRuleDriver.Configuring_For__c = 'Document checklist';
                objRuleDriver.Effective_From__c = System.today().addDays(-1);
                objRuleDriver.Effective_To__c = System.today().addDays(30);
                objRuleDriver.Logical_Expression__c = String.valueOf(i);
                objRuleDriver.Match_Criteria__c = 'All Match';
                objRuleDriver.Object_Name__c = 'Loan_Application__c';
                lstRuleDriver.add(objRuleDriver);
            }
            /*
            objRuleDriver = new Rule_Driver__c();
            objRuleDriver.Configuring_For__c = 'Document checklist';
            objRuleDriver.Effective_From__c = System.today().addDays(-1);
            objRuleDriver.Effective_To__c = System.today().addDays(30);
            objRuleDriver.Logical_Expression__c = '1 OR 2';
            objRuleDriver.Match_Criteria__c = 'All Match';
            objRuleDriver.Object_Name__c = 'Loan_Application__c';
            lstRuleDriver.add(objRuleDriver);
            
            objRuleDriver = new Rule_Driver__c();
            objRuleDriver.Configuring_For__c = 'Document checklist';
            objRuleDriver.Effective_From__c = System.today().addDays(-1);
            objRuleDriver.Effective_To__c = System.today().addDays(30);
            objRuleDriver.Logical_Expression__c = '1 OR 2';
            objRuleDriver.Match_Criteria__c = 'All Match';
            objRuleDriver.Object_Name__c = 'Loan_Application__c';
            lstRuleDriver.add(objRuleDriver);
            */
            insert lstRuleDriver;

            List<Rule_Definition_Driver_Mapping__c> lstRuleMapping = new List<Rule_Definition_Driver_Mapping__c>();

            for (Integer i=0;i<14;i++) {
                Rule_Definition_Driver_Mapping__c objMapping = new Rule_Definition_Driver_Mapping__c();
                objMapping.Rule_ID__c = lstRuleDef[i].Id;
                objMapping.Rule_Driver_ID__c = lstRuleDriver[0].Id;
                lstRuleMapping.add(objMapping);
            }
            insert lstRuleMapping;

            /*
            Rule_Definition_Driver_Mapping__c objMapping = new Rule_Definition_Driver_Mapping__c();
            objMapping.Rule_ID__c = lstRuleDef[0].Id;
            objMapping.Rule_Driver_ID__c = lstRuleDriver[0].Id;
            lstRuleMapping.add(objMapping);

            objMapping = new Rule_Definition_Driver_Mapping__c();
            objMapping.Rule_ID__c = lstRuleDef[1].Id;
            objMapping.Rule_Driver_ID__c = lstRuleDriver[1].Id;
            lstRuleMapping.add(objMapping);

            objMapping = new Rule_Definition_Driver_Mapping__c();
            objMapping.Rule_ID__c = lstRuleDef[2].Id;
            objMapping.Rule_Driver_ID__c = lstRuleDriver[2].Id;
            lstRuleMapping.add(objMapping);

            insert lstRuleMapping;
            */

        }
    }        
    
    @isTest 
    static void testRuleCondition1() {
        Test.startTest();
            RecordType plRecordTypeId = [SELECT Id from RecordType where DeveloperName = 'Personal_Loan' and sObjectType = 'Loan_Application__c' LIMIT 1];
            RecordType primaryAppRecordTypeId = [SELECT Id from RecordType where DeveloperName = 'Primary' and sObjectType = 'Applicant__c' LIMIT 1];
        	
            Loan_Application__c loanAppl = new Loan_Application__c();
            loanAppl.Name  = 'AP-12345';
            loanAppl.Stage__c = 'Lead';
            loanAppl.RecordTypeId = plRecordTypeId.Id;
            loanAppl.Loan_Amount__c = 120000;
            insert loanAppl;
            Set<String> setLoanId = new Set<String>();
            setLoanId.add(loanAppl.Id);

            AUSF_LoanApplicationTriggerService objLoanService = new AUSF_LoanApplicationTriggerService();
            objLoanService.createChecklists(setLoanId,true);
            
            /*
            Applicant__c appl = new Applicant__c();
            appl.First_Name__c = 'Test';
            appl.Middle_Name__c = 'Kumar';
            appl.Last_Name__c = 'User';
            appl.Loan_Application__c =loanAppl.Id;
            appl.Mobile_Number__c='1234567890';
            appl.PAN__c='BKDPK4370H';
            appl.RecordTypeId = primaryAppRecordTypeId.Id;
            insert appl;

            Set<String> setApplicantId = new Set<String>();
            setApplicantId.add(appl.Id);

            AUSF_ApplicantTriggerService objApplicantService = new AUSF_ApplicantTriggerService();
            objApplicantService.createChecklists(setApplicantId,true);
            */

        Test.stopTest();
    }
}