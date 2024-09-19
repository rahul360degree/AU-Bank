/**
 * @description       : 
 * @author            : Charchit Nirayanwal
 * @group             : 
 * @last modified on  : 04-07-2024
 * @last modified by  : Charchit Nirayanwal
 * @Jira Story        : APL-94
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   04-07-2024   Charchit Nirayanwal  Initial Version
**/

import { LightningElement, api } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import BIRTH_DATE from '@salesforce/schema/Applicant__c.Birth_Date__c';
import FULL_NAME from '@salesforce/schema/Applicant__c.Full_Name__c';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';
import updateApplicant from '@salesforce/apex/AUSF_Utility.updateApplicant';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import ausf_EnterPanNameAndDobLabel from '@salesforce/label/c.ausf_EnterPanNameAndDobLabel';
import ausf_EnterPanNameAndDobScreenName from '@salesforce/label/c.ausf_EnterPanNameAndDobScreenName';
import AUSF_BasicDetails from '@salesforce/label/c.AUSF_BasicDetails';
import AUSF_ApplyForPersonalLoan from '@salesforce/label/c.AUSF_ApplyForPersonalLoan';
import AUSF_GenericTechnicalError from '@salesforce/label/c.AUSF_GenericTechnicalError';



export default class ausf_EnterPanNameAndDob extends LightningElement {


        // Static Image Files
        AUlogoImgURL = AU_Assets + '/AU_Assets/images/IB.png';
        closeIconURL = AU_Assets + '/AU_Assets/images/Outline/x.png';
        WarningIconURL = AU_Assets + '/AU_Assets/images/warning_icon.png';
        BackIconURL = AU_Assets + '/AU_Assets/images/arrow-left-active.png';
        EmblemURL = AU_Assets + '/AU_Assets/images/Frame_1171279937.png';
        greenTickURL = AU_Assets + '/AU_Assets/images/green_tick.png';
        maskGroupUrl = AU_Assets + '/AU_Assets/images/Mask_group.png';
        GroupUrl = AU_Assets + '/AU_Assets/images/Group.png';

        mainlabel = {
                AUSF_BasicDetails,
                AUSF_ApplyForPersonalLoan,
                AUSF_GenericTechnicalError,
                ausf_EnterPanNameAndDobScreenName
        };

        headerContent = this.mainlabel.AUSF_ApplyForPersonalLoan;
        screenName = this.mainlabel.ausf_EnterPanNameAndDobScreenName;
        headerDescription;
        stepsInCurrentJourney;
        currentStep;
        enableBackButton = true;
        showContents = true;
        showLoader = false;

        callNsdl = false;
        label = JSON.parse(ausf_EnterPanNameAndDobLabel);
        DOBNSDL

        @api loanApplicationId;
        @api applicantId;
        @api pan = ''
        @api panName = ''
        @api dob = ''

        ConfirmButtonCSS = 'confirm-Button-Disabled';
        nameinput = 'phone-input'
        namelabel = 'phone-label'
        DOBinput = 'phone-input customDateInput'
        DOBlabel = 'phone-label'
        showNameError = false;
        showDateError = false;
        isRendered = false;

        connectedCallback() {
                this.getCurrentScreenData();
        }

        renderedCallback() {
                if (!this.isRendered) {
                        console.log('DOB AND Type->>',this.dob,'type--->',this.template.querySelector('[data-id="DOB"]')?.type )
                        if (this.dob != '') {
                                if (this.template.querySelector('[data-id="DOB"]')?.type != null) {
                                        this.isRendered = true
                                        this.DOBlabel = 'phone-label-value';
                                        this.template.querySelector('[data-id="DOB"]').type = 'date';
                                }
                        }
                        else {
                                this.isRendered = true
                        }
                }
        }

        getCurrentScreenData() {
                this.showLoader = true;
                getCurrentScreenData({ loanApplicationId: this.loanApplicationId, applicantId: this.applicantId, screenName: this.screenName })
                        .then(result => {
                                let applicantData = result.applicantList ? result.applicantList[0] : null;
                                if (applicantData) {
                                        this.dob = applicantData.Birth_Date__c ? applicantData.Birth_Date__c : '';
                                        this.panName = applicantData.Full_Name__c ? applicantData.Full_Name__c : '';
                                        this.pan = applicantData.PAN__c ? applicantData.PAN__c : '';
                                }
                                if (this.dob != '') {
                                        this.handleChange();
                                        this.DOBlabel = 'phone-label-value';
                                        console.log('type---->', this.template.querySelector('[data-id="DOB"]')?.type);
                                        // this.template.querySelector('[data-id="DOB"]').type = 'date'; 
                                }
                                if (this.panName != '') {
                                        this.handleChange();
                                        this.namelabel = 'phone-label-value';

                                }


                                let metadataToConsider = result.wizardDataDIYList ? result.wizardDataDIYList : result.wizardDataAssistedList ? result.wizardDataAssistedList : [];
                                if (metadataToConsider && metadataToConsider.length > 0) {
                                        this.stepsInCurrentJourney = parseInt(metadataToConsider[0].Overall_Step__c);
                                        this.currentStep = parseInt(metadataToConsider[0].Progress_in_Current_Step__c);
                                        this.headerDescription = metadataToConsider[0].Category__c;
                                }
                                this.showLoader = false;
                        })
                        .catch(error => {
                                this.showLoader = false;
                        });
        }

        get nsdlRendering() {
                return this.callNsdl;
        }

        get userInputRendering() {
                return !this.callNsdl;
        }


        handleChange(event) {
                if (event != null) {
                        console.log("value  --->", event.target.value)
                        switch (event.target.name) {
                                case 'panName':
                                        this.panName = event.target.value;
                                        if (this.panName == '') {
                                                this.nameinput = 'phone-input';
                                                this.namelabel = 'phone-label';
                                                this.showNameError = false;
                                        }
                                        else {
                                                this.namelabel = 'phone-label-value'
                                                if (this.validateInputs(event.target.name) == 'FAILED') {
                                                        this.showNameError = true;
                                                        this.nameinput = 'phone-input-error';
                                                        this.namelabel = 'phone-label-error';
                                                }
                                                else {

                                                        this.showNameError = false;
                                                        this.nameinput = 'phone-input';
                                                        this.namelabel = 'phone-label-value';
                                                }
                                        }
                                        break;
                                case 'DOB':
                                        console.log("dob Value  --->", event.target.value);
                                        this.dob = event.target.value;
                                        if (this.dob == '') {
                                                this.showDateError = false;
                                                this.DOBinput = 'phone-input customDateInput';
                                                this.DOBlabel = 'phone-label';
                                        }
                                        else {
                                                this.DOBlabel = 'phone-label-value';
                                                if (this.dob.length == 10) {
                                                        if (this.validateInputs(event.target.name) == 'FAILED') {
                                                                this.showDateError = true;
                                                                this.DOBinput = 'phone-input-error customDateInput';
                                                                this.DOBlabel = 'phone-label-error';
                                                        }
                                                        else {
                                                                this.showDateError = false;
                                                                this.DOBinput = 'phone-input customDateInput'
                                                                this.DOBlabel = 'phone-label-value';
                                                        }
                                                }
                                                else {
                                                        this.showDateError = false;
                                                        this.DOBinput = 'phone-input customDateInput'
                                                        this.DOBlabel = 'phone-label-value';
                                                }

                                        }
                                        break;
                        }
                }



                if (this.validateInputs() == 'SUCCESS') {
                        this.ConfirmButtonCSS = 'confirm-Button-Enabled';
                }
                else {
                        this.ConfirmButtonCSS = 'confirm-Button-Disabled';
                }

        }

        validateInputs(name) {
                const dateFormat = /^\d{4}-\d{2}-\d{2}$/;
                const nameFormat = /^[A-Za-z\s]+$/;

                if (!this.panName.match(nameFormat) && (name == 'panName' || name == null)) {
                        return 'FAILED';
                }

                if (name == 'DOB' || name == null) {

                        // Check if the date is in the correct format
                        if (!this.dob.match(dateFormat)) {
                                return 'FAILED';
                        }

                        // Extract day, month, and year from the input value
                        const [year, month, day] = this.dob.split('-').map(Number);
                        const dobDate = new Date(year, month - 1, day);
                        const today = new Date();

                        // Check if the date is valid
                        if (dobDate.getFullYear() !== year || dobDate.getMonth() !== month - 1 || dobDate.getDate() !== day) {
                                return 'FAILED';
                        }

                        let age = today.getFullYear() - dobDate.getFullYear();
                        const monthDiff = today.getMonth() - dobDate.getMonth();

                        // Calculate age considering the month and day
                        if (monthDiff < 0 || (monthDiff === 0 && today.getDate() < dobDate.getDate())) {
                                age--;
                        }

                        // Validate that the age is greater than or equal to 18 and less than 100
                        if (age < 18 || age > 100) {
                                return 'FAILED';

                        }

                }

                return 'SUCCESS';


        }


        makeNSDLAPICall() {
                this.DOBNSDL = this.convertDate(this.dob);
                this.callNsdl = true;
        }

        handleNsdlSucces() {
                this.confirmNameDOB();
        }

        handleReEneterPan() {
                this.callNsdl = false;
                const backEvent = new CustomEvent('backevent', {
                        detail: {
                                currentScreen: this.screenName,
                        },
                        composed: true,
                        bubbles: true
                });
                this.dispatchEvent(backEvent);
        }

        confirmNameDOB() {
                try {
                        if (this.validateInputs() == 'SUCCESS') {
                                let nameArray = this.panName.split(" ");
                                let firstname, lastname, middlename
                                if (nameArray.length == 2) {
                                        firstname = nameArray[0];
                                        lastname = nameArray[1];
                                }
                                else if (nameArray.length == 3) {
                                        firstname = nameArray[0];
                                        middlename = nameArray[1];
                                        lastname = nameArray[2];
                                }
                                else {
                                        firstname = nameArray[0];;
                                }

                                let applicantObj = {};
                                applicantObj['Id'] = ((this.applicantId) == null ? '' : this.applicantId);
                                applicantObj[BIRTH_DATE.fieldApiName] = this.dob;
                                applicantObj[FULL_NAME.fieldApiName] = this.panName;
                                applicantObj['First_Name__c'] = firstname ? firstname : '';
                                applicantObj['Middle_Name__c'] = middlename ? middlename : '';
                                applicantObj['Last_Name__c'] = lastname ? lastname : '';

                                // Update the Applicant Record
                                updateApplicant({ applicantObj: JSON.stringify(applicantObj), applicantId: this.applicantId, screenName: this.screenName })
                                        .then((result) => {
                                        })
                                        .catch(error => { });

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
                                // }
                        }

                }
                catch (e) { }
        }


        dateFocused(event) {
                if (event.target.type == 'text') {
                        event.target.type = 'date';
                }
        }

        dateBlurred(event) {
                if (event.target.value == '') {
                        event.target.type = 'text';
                }
        }

        convertDate(dateStr) {
                const [year, month, day] = dateStr.split('-');
                return `${day}/${month}/${year}`; // Return the date in dd/mm/yyyy format
        }

}