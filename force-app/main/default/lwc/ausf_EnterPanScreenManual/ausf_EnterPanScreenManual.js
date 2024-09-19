/** 
* @description       : 
 * @author            : Charchit Nirayanwal
 * @group             : 
 * @last modified on  : 04-07-2024
 * @last modified by  : Charchit Nirayanwal
 * @Jira Story        : APL-683
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   04-07-2024   Charchit Nirayanwal  Initial Version 
 **/

import { LightningElement, api, wire } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import PAN_CARD_FIELD from '@salesforce/schema/Applicant__c.PAN__c';
import IS_MANUALLY_TYPED_FIELD from '@salesforce/schema/Applicant__c.PAN_entered_manually__c';
import BIRTH_DATE from '@salesforce/schema/Applicant__c.Birth_Date__c';
import FULL_NAME from '@salesforce/schema/Applicant__c.Full_Name__c';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';
import updateApplicant from '@salesforce/apex/AUSF_Utility.updateApplicant';
import getPANDOB from '@salesforce/apex/AUSF_PanDobController.getPANDOB';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import AUSF_BasicDetails from '@salesforce/label/c.AUSF_BasicDetails';
import AUSF_ApplyForPersonalLoan from '@salesforce/label/c.AUSF_ApplyForPersonalLoan';
import AUSF_GenericTechnicalError from '@salesforce/label/c.AUSF_GenericTechnicalError';
import AUSF_EnterPanManual from '@salesforce/label/c.AUSF_EnterPanManual';
import AUSF_EnterPanManualTextFooter from '@salesforce/label/c.AUSF_EnterPanManualTextFooter';
import AUSF_EnterPanManualInvalidPanER from '@salesforce/label/c.AUSF_EnterPanManualInvalidPanER';
import AUSF_EnterPanManualPAN from '@salesforce/label/c.AUSF_EnterPanManualPAN';
import AUSF_EnterPanManualTitle from '@salesforce/label/c.AUSF_EnterPanManualTitle';
import AUSF_EnterPanManualSUBTitle from '@salesforce/label/c.AUSF_EnterPanManualSUBTitle';







export default class ausf_EnterPanScreenManual extends LightningElement {


    // Static Image Files
    AUlogoImgURL = AU_Assets + '/AU_Assets/images/IB.png';
    closeIconURL = AU_Assets + '/AU_Assets/images/Outline/x.png';
    WarningIconURL = AU_Assets + '/AU_Assets/images/warning_icon.png';
    BackIconURL = AU_Assets + '/AU_Assets/images/arrow-left-active.png';
    EmblemURL = AU_Assets + '/AU_Assets/images/Frame_1171279937.png';
    greenTickURL = AU_Assets + '/AU_Assets/images/green_tick.png';

    label = {
        AUSF_BasicDetails,
        AUSF_ApplyForPersonalLoan,
        AUSF_GenericTechnicalError,
        AUSF_EnterPanManual,
        AUSF_EnterPanManualTextFooter,
        AUSF_EnterPanManualInvalidPanER,
        AUSF_EnterPanManualPAN,
        AUSF_EnterPanManualTitle,
        AUSF_EnterPanManualSUBTitle

    };
    

    @api loanApplicationId ;
    @api applicantId;

    headerContent = this.label.AUSF_ApplyForPersonalLoan;
    screenName = this.label.AUSF_EnterPanManual;
    headerDescription;
    stepsInCurrentJourney;
    currentStep;
    enableBackButton = true;
    showContents=true;

    VerifyButtonCSS = 'verifyButton-disabled'
    PanInput = 'Pan-Input';
    IsInvalidPanERROR = false;
    IsClearButtonEnabled = false;
    isVerifyPanDisabled = true;
    panName
    dob
    panNumber = '';
    errorMessageApi = '';
    showErrorModal=false;
    showLoader=false;
    invalidPanError



    connectedCallback(){
        this.getCurrentScreenData();
    }

    handleCloseErrorModal(){
        this.showErrorModal = false;

    }

    getCurrentScreenData() {
        this.showLoader=true;
        getCurrentScreenData({ loanApplicationId: this.loanApplicationId, applicantId: this.applicantId, screenName: this.screenName })
                .then(result => {
                        let applicantData = result.applicantList ? result.applicantList[0] : null;
                        if (applicantData) {
                                this.panNumber = applicantData.PAN__c ? applicantData.PAN__c : '';
                        }
                        if(this.panNumber!=''){
                                this.HandlePanChange();
                        }

                        let metadataToConsider = result.wizardDataDIYList ? result.wizardDataDIYList : result.wizardDataAssistedList ? result.wizardDataAssistedList : [];
                        if (metadataToConsider && metadataToConsider.length > 0) {
                            this.stepsInCurrentJourney = parseInt(metadataToConsider[0].Overall_Step__c);
                            this.currentStep = parseInt(metadataToConsider[0].Progress_in_Current_Step__c);
                            this.headerDescription = metadataToConsider[0].Category__c;
                        }
                        this.showLoader=false;
                })
                .catch(error => {
                        this.showLoader=false;
                        this.errorMessageApi = this.label.AUSF_GenericTechnicalError;
                        this.transactionError = true;
                });
}



    HandlePanChange(event) {
        if (event != null) {
            this.panNumber = event.target.value.toUpperCase();
        }
        if (this.panNumber != null) {
            if (this.panNumber.length == 10) {
                if (this.validatePan() == 'SUCCESS') {
                    this.isVerifyPanDisabled = false;
                    this.VerifyButtonCSS = 'verifyButton-enabled';
                }
                else {
                    this.isVerifyPanDisabled = true;
                    this.VerifyButtonCSS = 'verifyButton-disabled';
                }
            }
            else {
                this.isVerifyPanDisabled = true;
                this.IsInvalidPanERROR = false;
                this.IsClearButtonEnabled = false;
                this.VerifyButtonCSS = 'verifyButton-disabled';
                this.PanInput = 'Pan-Input';
            }
        }
    }

    validatePan() {
        let pan = this.panNumber.trim();
        let panRegex = /^[A-Z]{5}[0-9]{4}[A-Z]$/;

        // Check if PAN is empty
        if (pan === '') {
            this.IsInvalidPanERROR = true;
            this.IsClearButtonEnabled = true;
            this.PanInput = 'Pan-Input-error';
            return 'FAILED';
        }

        // Check if PAN matches the regex pattern
        if (!panRegex.test(pan) || pan[3] !== 'P') {
            this.IsInvalidPanERROR = true;
            this.IsClearButtonEnabled = true;
            this.PanInput = 'Pan-Input-error';
            return 'FAILED';
        }

        return 'SUCCESS';

    }

    clearPan() {
        if (this.panNumber != '') {
            this.panNumber = '';
        }


        this.IsInvalidPanERROR = false;
        this.IsClearButtonEnabled = false;
        this.PanInput = 'Pan-Input';

    }

    async verifyPan() {
        this.showLoader = true;
        if (this.validatePan() == 'SUCCESS') {
            if (await this.CheckPanAPI() == 'SUCCESS') {
                let result = await this.updateApplicantAndLoanRecord();
                if(result == 'SUCCESS'){
                    return 'SUCCESS'
                }
            }
            else{
                this.showLoader = false;
            }
        }
        else{
            this.showLoader = false;
        }
    }


    async CheckPanAPI() {
        try {
            
            let result = await getPANDOB({ applicantId: this.applicantId, panNo: this.panNumber, otpValue: 'PAN-DOB' });
            if (result.blnSuccess) {
                this.dob = result.DOB;
                this.panName = result.name;
                return 'SUCCESS';
            }
            else{
                if(result.statusCode == '102' || result.statusCode == '103'  ){
                this.errorMessageApi =  result.strMessage.includes('IC') ? this.label.AUSF_EnterPanManualInvalidPanER+' -IC ' +result.strMessage.split("IC-")[1] : this.label.AUSF_EnterPanManualInvalidPanER;
                this.showErrorModal = true;
                }
                else{
                    this.errorMessageApi =  result.strMessage.includes('IC') ? this.label.AUSF_GenericTechnicalError+' -IC ' +result.strMessage.split("IC-")[1] : this.label.AUSF_GenericTechnicalError;
                    this.showErrorModal = true;
                }
                return 'FAILED';
            }

        }
        catch (e) {
            return 'FAILED';

        }
    }

    async updateApplicantAndLoanRecord() {

        try {
            let applicantObj = {};
            let dobDate = this.formatDate(this.dob)
            applicantObj['NSDL_Consent_Captured_At__c'] = new Date().toISOString();
            applicantObj['Id'] = ((this.applicantId) == null ? '' : this.applicantId);
            applicantObj[PAN_CARD_FIELD.fieldApiName] = this.panNumber;
            applicantObj[IS_MANUALLY_TYPED_FIELD.fieldApiName] = true;
            applicantObj[BIRTH_DATE.fieldApiName] = this.dob;
            applicantObj[FULL_NAME.fieldApiName] = this.panName;

            // Update the Applicant Record
            updateApplicant({ applicantObj: JSON.stringify(applicantObj), applicantId: this.applicantId, screenName: this.screenName })
                .then((result) => {
                })
                .catch(error => {
                    this.showLoader = false;
                    this.showErrorModal=true;
                    this.errorMessageApi=this.label.AUSF_GenericTechnicalError;
                    return 'FAILED';

                });



            let loanApplcationObj = {
                'Id': this.loanApplicationId,
                'Last_visited_Page__c': this.screenName
            }


            updateLoanApplication({ loanApplcationObj: JSON.stringify(loanApplcationObj), loanApplicationId: this.loanApplicationId, screenName: this.screenName })
                .then((result) => {
                    const nextEvent = new CustomEvent('submitevent', {
                        detail: {
                            currentScreen: this.screenName,
                        }
                    });
                    this.dispatchEvent(nextEvent)
                    this.showLoader = false;
                    return 'SUCCESS';
                })
                .catch((error) => {
                    this.showLoader = false;
                    this.showErrorModal=true;
                    this.errorMessageApi=this.label.AUSF_GenericTechnicalError
                    return 'FAILED';
                });
        } catch (error) {
            this.showLoader = false;
            this.showErrorModal=true;
            this.errorMessageApi=this.label.AUSF_GenericTechnicalError;
            return 'FAILED';
        }
    }




    formatDate(inputDate) {
        let dateParts = inputDate.split('-');

        // Extract year, month, and day
        let year = dateParts[0];
        let month = dateParts[1];
        let day = dateParts[2];

        
        let dobDate = new Date(year, month-1, day+1).toISOString().split('T')[0];

        return dobDate;

}


}