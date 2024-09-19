/**
 * @description       : Select Gst Number
 * @author            : Charchit Nirayanwal
 * @group             : 
 * @last modified on  : 07-07-2024 
 * @last modified by  : Charchit Nirayanwal
 * @Jira Story        : APL-132
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-07-2024   Charchit Nirayanwal  Initial Version
**/




import { LightningElement, api } from 'lwc';
import fetchGstDetails from '@salesforce/apex/AUSF_GstPanController.fetchGstDetails';
import fetchGstAuthenticationDetails from '@salesforce/apex/AUSF_GstAuthenticationController.fetchGstAuthenticationDetails';
import getIntegrationChecklist from '@salesforce/apex/AUSF_Utility.getIntegrationChecklist';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';


export default class Ausf_SelectGstNumberScreenCmp extends LightningElement {

    showLoader = false;
    showErrorModal = false;
    errorMessageApi
    gstValues
    addGstManually
    screenName = 'Select Gst Number';
    headerContents = 'Apply for Personal Loan';
    headerDescription = 'Application Process';
    overallJourneySteps = 3;
    currentJourney = 2;
    stepsInCurrentJourney = 3;
    currentStep = 1;
    showContents = true;
    enableBackButton = true;
    @api gstNo
    @api gstNoActive
    @api applicantId = 'a02C1000002d2IXIAY'
    @api loanApplicationId = 'a01C100000HLPMhIAP'
    showNotVerifiedScreen = false
    isProceedDisabled = true;
    ConfirmButtonCSS = 'confirm-Button-Disabled';
    employmentDetId
    showAuthSuccessScreen = false;
    addressId;
    gstListLen

    connectedCallback() {
        this.getGstValues();
        this.updateInputField();
    }


    // Q how to find the selected GST if user click on back button.
    updateInputField() {
        this.template.querySelectorAll('.radiobtn').forEach(item => {
            if (item.dataset.value != this.gstNo) {
                item.checked = false;
            }
            else {
                item.checked = true;
            }
        })
    }

    async getGstValues() {
        this.showLoader = true;
        let latestICList = await getIntegrationChecklist({ masterName: 'GST_PAN', strObjectName: 'Applicant__c', strRelatedRecordId: this.applicantId, screenName: this.screenName })
        console.log('latestICList-->', latestICList)

        
        let result = await fetchGstDetails({ applicantId: this.applicantId });
        console.log('gstApi  ---- >', result);

        if (result?.blnSuccess) {
            console.log('length------>', result.gstPanResponseWrap.result.length)
            if (result?.gstPanResponseWrap.result?.length == 0) {
                this.gstListLen = 0;
                this.showLoader = false;
                this.handleProceed();
            }
            else if (result?.gstPanResponseWrap.result?.length == 1) {
                this.gstNo = result.gstPanResponseWrap.result[0].gstin;
                this.gstNoActive = result.gstPanResponseWrap.result[0].authStatus;
                this.gstListLen = 1;
                console.log(' ------- Gst Selection -------- Just One gst moving to Gst Authentication');
                this.showLoader = false;
                this.handleProceed();
            }
            else {
                this.gstListLen = result.gstPanResponseWrap.result.length;
                this.gstValues = result.gstPanResponseWrap.result;
                this.showLoader = false;
            }
        }
        else {
            this.showLoader = false;
            this.handleProceed();
        }
    }

    handleCloseErrorModal() {
        this.showErrorModal = false;
        this.getGstValues();
    }


    handleSelection(event) {
        this.template.querySelectorAll('.radiobtn').forEach(item => {
            console.log(event.target.dataset.value, event.target.dataset.active);
            item.checked = false;
            if (item.dataset.value == event.target.dataset.value) {
                item.checked = true;
                this.gstNo = event.target.dataset.value;
                this.gstNoActive = event.target.dataset.active;
                console.log('Gst No + Is active --->', this.gstNo, this.gstNoActive);
            }
        })

        this.validateInput();
    }

    validateInput() {
        console.log('gstno validateinput--->', this.gstNo);
        if (this.gstNo != null) {
            this.isProceedDisabled = false;
            this.ConfirmButtonCSS = 'confirm-Button-Enabled';
        }
        else {
            this.isProceedDisabled = true;
            this.ConfirmButtonCSS = 'confirm-Button-Disabled';
        }
    }

    async handleProceed() {
        this.showLoader = true;
        console.log("gstno and active ->>>", this.gstNo, this.gstNoActive)


        if (this.gstListLen >= 1) {
            if (this.gstNoActive == 'Active') {
                let authRes = await this.callGstAuthentication();  
                if (authRes == 'SUCCESS') {
                    this.showAuthSuccessScreen = true;
                    return;
                }
                else {
                    this.showNotVerifiedScreen = true;
                    this.errorMessageApi = 'We are unable to verify your GST details at this time. Please try using an alternate method';
                    return;
                }
            }
            else {
                this.addGstManually = true;
                console.log('manual Addition of gst');
                return;
            }
        }

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
                return 'SUCCESS'
            })
            .catch((error) => {
            });
    }

    async callGstAuthentication() {
        try {
            let res = await fetchGstAuthenticationDetails({ applicantId: this.applicantId, gstin: this.gstNo, employmentId: this.employmentDetId })

            console.log('gstAuthApi', res)
            if (res.blnSuccess) {
                this.showLoader = false;
                this.addressId = res.addressId;
                console.log('send to complete your work profile GST api screen');
                return 'SUCCESS'
            }
        }
        catch (e) {
            this.showLoader = false;
            console.error(e);
            return 'failed';
        }
    }
}