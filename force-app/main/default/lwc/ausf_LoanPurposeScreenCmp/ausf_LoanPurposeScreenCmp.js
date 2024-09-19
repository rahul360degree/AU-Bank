import { LightningElement, track, api, wire } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';

import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';
import validateReferralCode from '@salesforce/apex/AUSF_LoanPurposeScreenController.validateReferralCode';


export default class Ausf_LoanPurposeScreenCmp extends LightningElement {

    screenName = 'Purpose of Loan';
    headerContents = 'Apply for Personal Loan';
    headerDescription;
    stepsInCurrentJourney;
    currentStep;
    showContents = true;
    enableBackButton = false;

    showLoader = true;
    headerIconURL = Assets + '/AU_Assets/images/IB.png';
    warningIconURL = Assets + '/AU_Assets/images/warning_icon.png';
    rightChevronURL = Assets + '/AU_Assets/images/Outline/chevron-right.png';
    mobileIconURL = Assets + '/AU_Assets/images/Group_427322555.png';
    greenTickURL = Assets + '/AU_Assets/images/green_tick.png';
    moneyPouchURL = Assets + '/AU_Assets/images/money_pouch.png';
    closeIconURL = Assets + '/AU_Assets/images/Outline/x.png';
    disableLoanPurposeSubmit = true;
    disableLoanPurposeModalSubmit = true;
    disableReferralModalSubmit = true;
    openLoanPurposeOtherModal = false;
    openReferralModal = false;
    invalidCode = false;
    referralCodeSubmitted = false;
    supportingText = 'Is someone assisting you?';
    selectedRadioButton;        
    referralCodeErrorMessage;
    referralUserId;

    //label vs image name ( in static resource)
    @track loanPurposesCollection = [{ label: "Vacation", value: "Vacation" }, { label: "Education", value: "Education" }, { label: "Marriage", value: "Marriage" }, { label: "Medical Needs", value: "Medicine" }, { label: "Other", value: "Other" }];
    @track loanPurposesUIData = [];
    loanPurposeValue = '';
    referralCode = '';
    initialLoad = true;
    jsLoad = false;

    @api loanApplicationId;
    @api applicantId;


    get purposeModalClass() {
        return this.openLoanPurposeOtherModal == true ? 'modal-container' : 'hideSection';
    }
    get cnfButtonClassVar() {
        return this.disableLoanPurposeSubmit == true ? 'cnfButtonDisabled' : 'cnfButton';
    }
    get loanPurposeModalBtnClass() {
        return this.disableLoanPurposeModalSubmit == true ? 'cnfButtonDisabled' : 'cnfButton';
    }
    get referralModalBtnClass() {
        return this.disableReferralModalSubmit == true ? 'cnfButtonDisabled' : 'cnfButton';
    }

    connectedCallback() {  
        getCurrentScreenData({ loanApplicationId: this.loanApplicationId, screenName: this.screenName })
        .then(result => {
            let loanApplicationData = result.loanApplicationList ? result.loanApplicationList[0] : null;
            if (loanApplicationData) {
                this.referralCode = loanApplicationData.Initiation_Referral_code__c ? loanApplicationData.Initiation_Referral_code__r.FederationIdentifier : '';
                this.loanPurposeValue = loanApplicationData.Purpose_of_Loan_Others__c ? loanApplicationData.Purpose_of_Loan_Others__c : '';
                this.selectedRadioButton = loanApplicationData.Purpose_of_Loan__c;
                if (this.referralCode) {
                    this.referralCodeSubmitted = true;
                    this.disableReferralModalSubmit = false;
                }
            }
            let customTextList = result.screenCustomTextList ? result.screenCustomTextList : null;
            if (customTextList) {
                customTextList.forEach(element => {
                    if (element.Label == 'Referral Code Error Message') {
                        this.referralCodeErrorMessage = element.Custom_String__c;
                    }
                });
            }
            let metadataToConsider = result.wizardDataDIYList ? result.wizardDataDIYList : result.wizardDataAssistedList ? result.wizardDataAssistedList : [];
            if (metadataToConsider && metadataToConsider.length > 0) {
                this.stepsInCurrentJourney = parseInt(metadataToConsider[0].Overall_Step__c);
                this.currentStep = parseInt(metadataToConsider[0].Progress_in_Current_Step__c);
                this.headerDescription = metadataToConsider[0].Category__c;
            }
                //console.log("loaded");
            this.jsLoad = true;

            let data1 = []
            let counter = 0;
            this.loanPurposesCollection.forEach(element => {
                let labelValue = this.loanPurposeValue && element.label.includes('Other') ? 'Other (' + this.loanPurposeValue + ')' : element.label;
                data1.push({ label: labelValue, index: counter, radioBtnClass: 'round-checkbox radio' + element.label.split(' ').join(''), selectionCardClass: 'Selection-card', imageSrc: Assets + '/AU_Assets/images/' + element.value + '.png', newEntry: false })
                counter += 1;
            });
            this.loanPurposesUIData = data1;
            this.showLoader = false;
            // Promise.all([
            //     loadScript(this, jQueryJS),
            // ]).then(() => {

            // })
            // .catch(error => {
            //     console.error(error);
            // });
        })
        .catch(error => {
            console.error(error);
        });
    }


    renderedCallback() {
        if (this.initialLoad && this.jsLoad) {
            if (this.loanPurposeValue || this.selectedRadioButton) {
                let selectedRadioBtnClass = '.';
                let modifiedData = this.loanPurposesUIData.map((element) => {
                    let selectedRowLabel = this.loanPurposeValue ? 'Other (' + this.loanPurposeValue + ')' : this.selectedRadioButton
                    if (selectedRowLabel == element.label) {
                        selectedRadioBtnClass += element.radioBtnClass.split('round-checkbox ')[1];
                        return {
                            ...element,
                            selectionCardClass: "Selection-card activeSelection"
                        };
                    }
                    return element;
                });
                this.loanPurposesUIData = modifiedData;
                console.log(selectedRadioBtnClass,this.template.querySelector(selectedRadioBtnClass));
                this.template.querySelector(selectedRadioBtnClass).checked = true;
                // window.jQuery(this.template.querySelector(selectedRadioBtnClass)).prop('checked', true);

                this.disableLoanPurposeSubmit = false;

            }
            this.initialLoad = false;
        }
    }


    handleRadioSelection(event) {
        //console.log('radio clicked');
        //console.log(event.target.value);
        //console.log(event.currentTarget.dataset.id);
        let selectedIndex = event.currentTarget.dataset.id;
        this.highlightSelectedValue(selectedIndex,event);
    }




    highlightSelectedValue(index,event) {
        this.loanPurposesUIData.forEach(element => {
            element.selectionCardClass = "Selection-card";
        });
        this.template.querySelectorAll('input[type="checkbox"]').forEach(cb => {
            // console.log(cb.checked);
            if (cb != event.target) {
                cb.checked = false;
            }else{
                cb.checked = true;
            }
        });
        this.loanPurposesUIData[index].selectionCardClass = "Selection-card activeSelection";
        //console.log('selectedRadioButton',this.selectedRadioButton);
        if (this.loanPurposesUIData[index].label.includes('Other')) {
            this.openLoanPurposeOtherModal = true;
            const otherInput = this.template.querySelector('.Input-Text1');
            console.log('i',otherInput);
            if(otherInput){
                otherInput.focus();
            }else{
                setTimeout(() => {
                    const otherInput = this.template.querySelector('.Input-Text1');
                    console.log('i',otherInput);
                    if(otherInput){
                        otherInput.click(this.handleFocus(otherInput));
                    }
                }, 300);
            }
            this.selectedRadioButton = 'Others';
        } else {
            this.selectedRadioButton = this.loanPurposesUIData[index].label;
            // this.loanPurposeValue = null;
        }
        this.disableLoanPurposeSubmit = this.selectedRadioButton == 'Others' ? true : false;
    }
    handleFocus(otherInput){
        console.log('im',otherInput);
        if(otherInput){
            otherInput.focus();
        }
    }

    handleModalInputChange(event) {
        this.loanPurposeValue = event.target.value;
        
        if (this.loanPurposeValue && this.loanPurposeValue.length >= 3) {
            this.disableLoanPurposeModalSubmit = false;
        } else {
            this.disableLoanPurposeModalSubmit = true
        }
    }

    handleReferralCodeChange(event) {
        this.referralCode = event.target.value;
        if (this.referralCode) {
            validateReferralCode({ referralCode: this.referralCode, loanApplicationId:this.loanApplicationId })
                .then(result => {
                    //console.log(result);
                    if (result && result.length > 0) {
                        this.invalidCode = false;
                        this.disableReferralModalSubmit = false;
                        this.referralUserId = result[0].Id;
                    } else {
                        this.invalidCode = true;
                        this.disableReferralModalSubmit = true;
                        this.referralCodeSubmitted = false;
                    }
                })
                .catch(error => {
                    console.error(error);
                });
        } else {
            this.disableReferralModalSubmit = true;
            this.referralCodeSubmitted = false;
        }
    }

    handleSubmitModal(event) {
        //console.log(event.target.value);
        this.isModalOpen1 = false;
        let modifiedData = this.loanPurposesUIData.map((element) => {
            if (element.label.includes('Other')) {
                return {
                    ...element,
                    label: 'Other (' + this.loanPurposeValue + ')',
                };
            }
            return element;
        });
        this.loanPurposesUIData = modifiedData;
        this.disableLoanPurposeSubmit = false;
        this.openLoanPurposeOtherModal = false;
    }

    handleReferralModalSubmit() {
        this.supportingText = 'Employee code ' + this.referralCode + ' applied';
        this.referralCodeSubmitted = true;
        this.openReferralModal = false;
    }

    handleCloseModal() {
        this.openLoanPurposeOtherModal = false;
        this.openReferralModal = false;
        if(!this.loanPurposeValue){
            this.loanPurposesUIData.forEach(element => {
                element.selectionCardClass = "Selection-card";
                let selectedRadioBtnClass = '.'+element.radioBtnClass;
                window.jQuery(this.template.querySelector(selectedRadioBtnClass)).prop('checked', false);
                this.disableLoanPurposeSubmit = true;
            });
        }
    }
    handleReferralModal() {
        this.openReferralModal = true;
    }

    handleSubmitMethod() {
        try {
            //console.log('clicked submit');

            let loanApplcationObj = {
                'Id': this.loanApplicationId,
                'Last_visited_Page__c':this.screenName
            }
            if (this.referralUserId) {
                loanApplcationObj['Initiation_Referral_code__c'] = this.referralUserId
            }
            if (this.loanPurposeValue && this.selectedRadioButton == 'Others') {
                loanApplcationObj['Purpose_of_Loan__c'] = 'Others';
                loanApplcationObj['Purpose_of_Loan_Others__c'] = this.loanPurposeValue;

            } else {
                loanApplcationObj['Purpose_of_Loan__c'] = this.selectedRadioButton;
                loanApplcationObj['Purpose_of_Loan_Others__c'] = null;
            }

            
            updateLoanApplication({loanApplcationObj:JSON.stringify(loanApplcationObj),loanApplicationId:this.loanApplicationId,screenName:this.screenName})
                .then((result) => {
                    console.log(result,'Loan Purpose Updated');
                    const nextEvent = new CustomEvent('submitevent', {
                        detail: {
                            currentScreen: this.screenName,
                        }
                    });
                    this.dispatchEvent(nextEvent)
                })
                .catch((error) => {
                    console.error(error);
                });
        } catch (error) {
            console.error();
        }
    }

}