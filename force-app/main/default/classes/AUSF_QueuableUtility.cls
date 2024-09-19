/**
* @author        Tejendra
* @date          3-August-2024
* @description   Queueable utility class for Karza name match and address match callout
* Modification Log:
--------------------------------------------------------------------------------------------
Developer             Date            Description
--------------------------------------------------------------------------------------------
Tejendra              3-August-2024    Initial Version - APL-150
*/

public without sharing class AUSF_QueuableUtility implements Queueable, Database.AllowsCallouts {
    Applicant__c objApplicant; 
    Employment_Detail__c employmentDetail;
    //String strName1 = '';
    //String strName2 = '';

    /*
    @description    : AUSF_QueuableUtility - Constructor of queueable class
    @param1         : objApplicant - Applicant record
    @param2         : employmentDetail - Employment Detail Record
    */
    public AUSF_QueuableUtility(Applicant__c objApplicant,Employment_Detail__c employmentDetail) {
    //public AUSF_QueuableUtility(Applicant__c objApplicant,Employment_Detail__c employmentDetail, String strName1, String strName2) {
        this.objApplicant = objApplicant;
        this.employmentDetail = employmentDetail;
        //this.strName1 = strName1;
        //this.strName2 = strName2;
    }
    //Queueable execute method for making karza name match callout and update employment detail record
    public void execute(QueueableContext context) {
        try{
            AUSF_KarzaNameMatchController.NameMatchWrapper nameMatchWrapperObj = AUSF_KarzaNameMatchController.nameMatch(objApplicant.Full_Name__c,employmentDetail.Owner_Name__c,objApplicant.Id);
            //AUSF_KarzaNameMatchController.NameMatchWrapper nameMatchWrapperObj = AUSF_KarzaNameMatchController.nameMatch(strName1,strName2,objApplicant.Id);
            if(nameMatchWrapperObj != NULL && nameMatchWrapperObj.nameMatchWrap != NULL && nameMatchWrapperObj.nameMatchWrap.nameMatchResponse != NULL && nameMatchWrapperObj.nameMatchWrap.nameMatchResponse.result != NULL && nameMatchWrapperObj.nameMatchWrap.nameMatchResponse.result.score != NULL){
                Double nameMatchscore =  nameMatchWrapperObj.nameMatchWrap.nameMatchResponse.result.score;
                //if (employmentDetail != NULL) {
                    Employment_Detail__c employmentDetailObj = new Employment_Detail__c();
                    employmentDetailObj.Id = employmentDetail.Id;
                    employmentDetailObj.Owner_Name_Vintage_Verified__c = nameMatchscore > Integer.valueOf(System.Label.KarzaNameMatchThresholdScore) ? true : false;
                    update employmentDetailObj;
                //}
            }
        }catch(Exception ex){
            AUSF_Log.error(ex, AUSF_Log.SeverityType.High,objApplicant.Id,'Applicant',AUSF_ApexConstants.AUSF_GST_AUTHENTICATION);
        }
    }
}