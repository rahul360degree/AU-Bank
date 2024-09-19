import { LightningElement,api,wire } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';

import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';


export default class Ausf_ChooseLoanAmountScreenCmp extends LightningElement {

    screenName = 'Choose Loan Amount';
    headerContents = 'Apply for Personal Loan';
    headerDescription;
    stepsInCurrentJourney;
    currentStep;
    showContents = true;
    enableBackButton = true;

    @api loanApplicationId;
    @api applicantId;

    showLoader = true;
    headerIconURL = Assets +'/AU_Assets/images/IB.png';
    warningIconURL = Assets +'/AU_Assets/images/warning_icon.png';
    infoGreyURL = Assets +'/AU_Assets/images/Icon.png';
    moneyBucket1URL = Assets +'/AU_Assets/images/Frame_1171281177.png';
    moneyBucket2URL = Assets +'/AU_Assets/images/Frame_1171281178.png';
    moneyBucket3URL = Assets +'/AU_Assets/images/Frame_1171281179.png';
    moneyBucketURL = this.moneyBucket1URL;
    sliderStep = 1000;
    sliderValue = 25000;
    minSliderValue = 25000;
    maxSliderValue = 2500000;
    anyValidationError = false;
    validationErrorMessage = '';
    screenTitle;
    screenSubtitle;
    maxAmountErrorMessage;
    minAmountErrorMessage;
    stepSizeErrorMessage;
    helpText;

    get cnfButtonClassVar(){
        return this.anyValidationError ? 'cnfButtonDisabled' : 'cnfButton';
    }

    connectedCallback() {  
        // window.history.pushState(null, null, window.location.href);
        // window.onpopstate = function () {
        //     window.history.go(1);
        // };

        getCurrentScreenData({ loanApplicationId: this.loanApplicationId, screenName: this.screenName })
        .then(result => {
            let loanApplicationData = result.loanApplicationList ? result.loanApplicationList[0] : null;

            let customTextList = result.screenCustomTextList ? result.screenCustomTextList : null;
            if (customTextList) {
                customTextList.forEach(element => {
                    if(element.Label == 'Step Size'){
                        this.sliderStep = parseInt(element.Custom_String__c);
                    }else if(element.Label == 'Minimum Loan Amount'){
                        this.minSliderValue = parseInt(element.Custom_String__c);
                    }else if(element.Label == 'Maximum Loan Amount'){
                        this.maxSliderValue = parseInt(element.Custom_String__c);
                    }else if(element.Label == 'Loan Amount Screen Title'){
                        this.screenTitle = element.Custom_String__c;
                    }else if(element.Label == 'Loan Amount Screen Subtitle'){
                        this.screenSubtitle = element.Custom_String__c;
                    }else if(element.Label == 'Maximum Loan Amount Error Message'){
                        this.maxAmountErrorMessage = element.Custom_String__c;
                    }else if(element.Label == 'Minimum Loan Amount Error Message'){
                        this.minAmountErrorMessage = element.Custom_String__c;
                    }else if(element.Label == 'Step Size Error Message'){
                        this.stepSizeErrorMessage = element.Custom_String__c;
                    }else if(element.Label == 'Loan Amount Screen Helptext'){
                        this.helpText = element.Custom_String__c;
                    }else if(element.Label == 'Default Loan Amount'){
                        this.sliderValue = parseInt(element.Custom_String__c);
                    }
                });
            }
            let metadataToConsider = result.wizardDataDIYList ? result.wizardDataDIYList : result.wizardDataAssistedList ? result.wizardDataAssistedList : [];
            if (metadataToConsider && metadataToConsider.length > 0) {
                this.stepsInCurrentJourney = parseInt(metadataToConsider[0].Overall_Step__c);
                this.currentStep = parseInt(metadataToConsider[0].Progress_in_Current_Step__c);
                this.headerDescription = metadataToConsider[0].Category__c;
            }

            if (loanApplicationData) {
                let loanAmount = loanApplicationData.Loan_Amount__c;
                if(loanAmount){
                    this.validateLoanAmount(loanAmount);
                }
            }

            this.showLoader = false;

            const amountInputBox = this.template.querySelector('.Input-Text1');
            console.log('i',amountInputBox);
            if(amountInputBox){
                amountInputBox.focus();
            }else{
                setTimeout(() => {
                    const amountInputBox = this.template.querySelector('.Input-Text1');
                    console.log('i',amountInputBox);
                    if(amountInputBox){
                        amountInputBox.focus();
                    }
                }, 300);
            }
        })
        .catch(error => {
            console.error(error);
        });
    }

    handleInputChange(event){
        console.log(event.target.name);
        let changedFrom = event.target.name;
        // if(changedFrom && changedFrom == 'slider'){
        //     const amountInputBox = this.template.querySelector('.Input-Text1');
        //     if(amountInputBox){
        //         amountInputBox.focus();
        //     }
        // }
        this.validateLoanAmount(event.target.value);
    }

    validateLoanAmount(loanAmount){
        try {
            // console.log(event.target.value,event.detail.value);
            this.sliderValue = loanAmount;
            if((this.sliderValue > this.maxSliderValue)){
                this.anyValidationError = true;
                this.validationErrorMessage = this.maxAmountErrorMessage;
            }else if ((this.sliderValue < this.minSliderValue) ){
                this.anyValidationError = true;
                this.validationErrorMessage = this.minAmountErrorMessage;
            }else if((this.sliderValue % this.sliderStep != 0)){
                this.anyValidationError = true;
                this.validationErrorMessage = this.stepSizeErrorMessage+' '+this.sliderStep;
            }else{
                this.anyValidationError = false;
            }

            if(this.sliderValue >= 25000 && this.sliderValue < 500000){
                this.moneyBucketURL = this.moneyBucket1URL;
            } else if(this.sliderValue >= 500000 && this.sliderValue < 1500000){
                this.moneyBucketURL = this.moneyBucket2URL;
            } else if(this.sliderValue >= 1500000){
                this.moneyBucketURL = this.moneyBucket3URL;
            }


            // console.log(this.isSliderOutOfRange);
        } catch (error) {
            console.error();
        }
    }

    handleSubmit(){

        let loanApplcationObj = {
            'Id': this.loanApplicationId,
            'Loan_Amount__c': this.sliderValue,
            'Requested_Loan_Amount__c': this.sliderValue,
            'Total_Loan_Amount__c': this.sliderValue,
            'Last_visited_Page__c':this.screenName
        }
  
        updateLoanApplication({loanApplcationObj:JSON.stringify(loanApplcationObj),loanApplicationId:this.loanApplicationId,screenName:this.screenName})
        .then((result) => {
            console.log(result,'Loan Amount Updated');
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

        //need to dispatch event for redirection to other screen
    }
}