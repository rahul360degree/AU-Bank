/**
* @author Nitesh Jaiswal
* @company Salesforce.com
* @description Controller class of AUPL_GenericWizardCmp
* Test Class: AUPL_LoanPurposeScreenController_Test
*/

public without sharing class AUSF_GenericWizardController {

    @AuraEnabled
    public static ScreenDataWrapper getScreenOrderMapping(string loanApplicationId){
        ScreenDataWrapper screenDataWrapperObj = new ScreenDataWrapper();
        try {
            Id userProfileId = UserInfo.getProfileId();

            String profileName = [SELECT Id,Name FROM Profile WHERE Id =: userProfileId LIMIT 1].Name;

            List<Profile_to_UI_Wizard_Mapping__mdt> profileToWizardMetadataList = [SELECT Profile_Name__c,Wizard_Metadata_Name__c,Label FROM Profile_to_UI_Wizard_Mapping__mdt WHERE Profile_Name__c=:profileName LIMIT 1];
            List<Loan_Application__c> loanApplicationList = new List<Loan_Application__c>();
            if(loanApplicationId != null){
                loanApplicationList = [SELECT Id,Name,Last_visited_Page__c,Stage__c, (SELECT Product_Type__c FROM Pre_Approved_Offers__r ORDER BY CreatedDate DESC LIMIT 1) FROM Loan_Application__c WHERE Id =:loanApplicationId LIMIT 1];
                screenDataWrapperObj.loanApplicationList = loanApplicationList;
            }
            if(profileToWizardMetadataList.size()>0){
                string metadataToBeUsed = profileToWizardMetadataList[0].Wizard_Metadata_Name__c;
                if(metadataToBeUsed == 'Generic_UI_Wizard_Mapping_DIY__mdt'){
                    List<Generic_UI_Wizard_Mapping_DIY__mdt> wizardUIMapping = new List<Generic_UI_Wizard_Mapping_DIY__mdt>();

                    if(loanApplicationList.size() > 0 && loanApplicationList[0].Pre_Approved_Offers__r.size() > 0){
                        wizardUIMapping = [SELECT Category__c,Current_Screen_Name__c,Is_Default__c,Order__c,Progress_in_Current_Step__c,Overall_Step__c,Current_Screen_Component__c,Label,Component_Tag__c,Product_Type__c FROM Generic_UI_Wizard_Mapping_DIY__mdt WHERE Product_Type__c =:loanApplicationList[0].Pre_Approved_Offers__r[0].Product_Type__c  ORDER BY Order__c LIMIT 1000];
                    }else{
                        wizardUIMapping = [SELECT Category__c,Current_Screen_Name__c,Is_Default__c,Order__c,Progress_in_Current_Step__c,Overall_Step__c,Current_Screen_Component__c,Label,Component_Tag__c,Product_Type__c FROM Generic_UI_Wizard_Mapping_DIY__mdt ORDER BY Order__c LIMIT 1000];
                    }
                    screenDataWrapperObj.wizardDataDIYList = wizardUIMapping;
                    
                }else if(metadataToBeUsed == 'Generic_UI_Wizard_Mapping_Assisted__mdt'){
                    List<Generic_UI_Wizard_Mapping_Assisted__mdt> wizardUIMapping = new List<Generic_UI_Wizard_Mapping_Assisted__mdt>();

                    if(loanApplicationList.size() > 0 && loanApplicationList[0].Pre_Approved_Offers__r.size() > 0){
                        wizardUIMapping = [SELECT Category__c,Current_Screen_Name__c,Is_Default__c,Order__c,Progress_in_Current_Step__c,Overall_Step__c,Current_Screen_Component__c,Label,Component_Tag__c,Product_Type__c FROM Generic_UI_Wizard_Mapping_Assisted__mdt WHERE Product_Type__c =:loanApplicationList[0].Pre_Approved_Offers__r[0].Product_Type__c  ORDER BY Order__c LIMIT 1000];
                    }else{
                        wizardUIMapping = [SELECT Category__c,Current_Screen_Name__c,Is_Default__c,Order__c,Progress_in_Current_Step__c,Overall_Step__c,Current_Screen_Component__c,Label,Component_Tag__c,Product_Type__c FROM Generic_UI_Wizard_Mapping_Assisted__mdt ORDER BY Order__c LIMIT 1000];
                    }
                    screenDataWrapperObj.wizardDataAssistedList = wizardUIMapping;
                    // Progress_in_Overall_Step__c
                }
            }

            // List<Profile_to_Screen_Visibility_Mapping__mdt> profileToScreenMetadataList = [SELECT Profile_Name__c,Is_Screen_Visible__c,Screen_Name__c,Label FROM Profile_to_Screen_Visibility_Mapping__mdt WHERE Profile_Name__c=:profileName LIMIT 1000];

            // if(profileToScreenMetadataList.size() > 0){
            //     screenDataWrapperObj.screenVisibilityList = profileToScreenMetadataList;
            // }

        } catch (Exception e) {
            screenDataWrapperObj.errorMessage = e.getMessage();
            AUSF_Log.error(e, AUSF_Log.SeverityType.Medium,loanApplicationId,null,'Generic Wizard Controller');
        }
        return screenDataWrapperObj;

    }

    public class ScreenDataWrapper{
        @AuraEnabled
        public  List<Generic_UI_Wizard_Mapping_DIY__mdt> wizardDataDIYList;
        @AuraEnabled
        public  List<Generic_UI_Wizard_Mapping_Assisted__mdt> wizardDataAssistedList;
        @AuraEnabled
        public  List<Loan_Application__c> loanApplicationList;
        // @AuraEnabled
        // public  List<Profile_to_Screen_Visibility_Mapping__mdt> screenVisibilityList;
        @AuraEnabled
        public  String errorMessage;
    }
}