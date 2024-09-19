import { LightningElement,wire,track,api } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';

import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import getCurrentScreenDataCatg from '@salesforce/apex/AUSF_Utility.getCurrentScreenDataCatg';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';
import updateApplicant from '@salesforce/apex/AUSF_Utility.updateApplicant';
import cloneAddress from '@salesforce/apex/AUSF_Utility.cloneAddress';
import validatePinCode from '@salesforce/apex/AUSF_ConfirmPersonalDetailsController.validatePinCode';
import doEmailAuthentication from '@salesforce/apex/AUSF_EmailAuthenticationController.doEmailAuthentication';
import sendRejectionNotifications from '@salesforce/apex/AUSF_Utility.sendRejectionNotifications';
import aditionalDedupeCheck from '@salesforce/apex/AUSF_Utility.aditionalDedupeCheck';


export default class Ausf_ConfirmPersonalDetailsCmp extends LightningElement {

    screenName = 'Confirm Personal Details';
    headerContents = 'Apply for Personal Loan';
    headerDescription;
    stepsInCurrentJourney
    currentStep
    showContents = true;
    enableBackButton = false;
    @track addressResult = [];

    showLoader = false;
    isEmailVerified = false;
    subTitleValue = '';
    openEmailModal = false;
    openPinModal = false;
    openRetryModal = false;
    errorScreen = false;
    disableSubmitButton = true;
    disableEmailModalSubmit = true;
    disablePinModalSubmit = true;
    emailValue = ''
    emailModalValue = ''
    pinCodeValue = ''
    fullName = ''
    dob = ''
    gender = ''
    invalidEmail = false;
    invalidPIN = false;
    validPIN = false;
    isServicableArea = false;
    pinValidationSuccessMsg;
    allowedRetries;
    currentPinCode;
    currentRetries;
    retriesLeft;
    emailValidationErrorMsg;
    pinValidationErrorMsg;
    dedupeAddressList;
    showBREIPALoader = false;
    addressId;

    headerIconURL = Assets + '/AU_Assets/images/IB.png';
    warningIconURL = Assets + '/AU_Assets/images/warning_icon.png';
    personalDetailImgURL = Assets + '/AU_Assets/images/Personal_Details.png';
    personImgURL = Assets + '/AU_Assets/images/human_purple_profile.png';
    vectorURL = Assets + '/AU_Assets/images/Vector_973.png';
    formURL = Assets + '/AU_Assets/images/Group427322418.png';
    barImgURL = Assets + '/AU_Assets/images/straight_bar.png';
    redCloseImgURL = Assets + '/AU_Assets/images/red_close.png';
    closeIconURL = Assets + '/AU_Assets/images/Outline/x.png';
    emailIconURL = Assets + '/AU_Assets/images/email.png';
    pinImgURL = Assets + '/AU_Assets/images/Group_427321515.png';
    greentickImgURL = Assets + '/AU_Assets/images/tick-circle.png';
    retryIMGURL = Assets + '/AU_Assets/images/Group_1234.png';
    pinCodeErrorImgURL = Assets + '/AU_Assets/images/Group_427321903.png';


    @api loanApplicationId;
    @api applicantId = 'a02C1000002WEptIAG';
    @api showAddressModal = false;



    get cnfButtonClassVar() {
        return this.disableSubmitButton == true ? 'cnfButtonDisabled' : 'cnfButton';
    }
    get emailModalBtnClass() {
        return this.disableEmailModalSubmit == true ? 'cnfButtonDisabled' : 'cnfButton';
    }
    get pinModalBtnClass() {
        return this.disablePinModalSubmit == true ? 'pinBtnDisabled' : 'pinButton';
    }

    connectedCallback() {  
        this.showLoader = true;
        let dataJsonString = {
            'loanApplicationId': this.loanApplicationId,
            'applicantId': this.applicantId,
            'screenName': this.screenName,
            'addressId': this.addressId,
            'addressSource': 'your input'
        }
        //getCurrentScreenData({ loanApplicationId: this.loanApplicationId,applicantId:this.applicantId, screenName: this.screenName })
        getCurrentScreenDataCatg({ jsonString: JSON.stringify(dataJsonString)})
        .then(result => {
            let loanApplicationData = result.loanApplicationList ? result.loanApplicationList[0] : null;
            let applicantData = result.applicantList ? result.applicantList[0] : null;
            this.dedupeAddressList = result.dedupeAddressList ? result.dedupeAddressList : null;
            if (applicantData) {
                this.emailValue = applicantData.Personal_email_ID__c ? applicantData.Personal_email_ID__c : null;
                this.fullName = applicantData.Full_Name__c;
                let dobData = applicantData.Birth_Date__c
                this.dob = dobData ? (new Date(dobData)).toLocaleDateString() : '';
                this.gender = applicantData.Gender__c;
                this.currentPinCode = applicantData.Current_Pincode__c;
                let applicantRetries = applicantData.Current_Pincode_Retry_Count__c;
                this.currentRetries = applicantRetries ? applicantRetries : 0;
                this.isEmailVerified = applicantData.Is_Personal_Email_Id_Verified__c;
                if(this.emailValue){
                    this.disableSubmitButton = false;
                }
            }

            let customTextList = result.screenCustomTextList ? result.screenCustomTextList : null;
            if (customTextList) {
                customTextList.forEach(element => {
                    if(element.Label == 'Confirm Personal Details Subtitle'){
                        this.subTitleValue = element.Custom_String__c;
                    }else if(element.Label == 'Email Validation Error Message'){
                        this.emailValidationErrorMsg = element.Custom_String__c;
                    }else if(element.Label == 'PIN Validation Error Message'){
                        this.pinValidationErrorMsg = element.Custom_String__c;
                    }else if(element.Label == 'Max PIN Code Retries'){
                        this.allowedRetries = parseInt(element.Custom_String__c);
                        this.retriesLeft = this.allowedRetries - this.currentRetries;
                        if(this.retriesLeft <= 0){
                            this.showContents = false;
                            this.errorScreen = true;
                        }
                    }
                });
            }

            let metadataToConsider = result.wizardDataDIYList ? result.wizardDataDIYList : result.wizardDataAssistedList ? result.wizardDataAssistedList : [];
            if (metadataToConsider && metadataToConsider.length > 0) {
                this.stepsInCurrentJourney = parseInt(metadataToConsider[0].Overall_Step__c);
                this.currentStep = parseInt(metadataToConsider[0].Progress_in_Current_Step__c);
                this.headerDescription = metadataToConsider[0].Category__c;
            }
            this.showLoader = false;
            console.log('asmita ', this.dedupeAddressList);
            // if (result.dedupeAddressList) {
            //     this.addressResult = result.dedupeAddressList;
            // }
        })
        .catch(error => {
            console.error(error);
        });
    }

    handleEmailModal(){
        this.openEmailModal = true;
        // focus on email modal input
        const modalInput = this.template.querySelector('.Input-Text1');
        console.log('i',modalInput);
        if(modalInput){
            modalInput.focus();
        }else{
            setTimeout(() => {
                const modalInput = this.template.querySelector('.Input-Text1');
                console.log('i',modalInput);
                if(modalInput){
                    modalInput.focus();
                }
            }, 300);
        }
    }

    handlePINChange(event){
        this.pinCodeValue = event.target.value;
        this.validPIN = false;
        this.invalidPIN = false;
        if(this.pinCodeValue.length >=6){

            validatePinCode({pinCode:this.pinCodeValue,loanApplicationId:this.loanApplicationId})
            .then(result=>{
                if((result && result.length > 0)){
                    this.invalidPIN = false;
                    this.validPIN = true;
                    this.pinValidationSuccessMsg = result[0].City__c + ', ' + result[0].State__c;
                    this.disablePinModalSubmit = false;
                    this.isServicableArea = result[0].Working_Area__c == 'Yes' ? true : false;
                }else{
                    this.validPIN = false;
                    this.disablePinModalSubmit = true;
                    this.invalidPIN = true;
                }
            })
            .catch(error=>{
                console.error(error);
            })
        }
    }

    handleEmailChange(event){
        // console.log(event.target.value);
        try {
            this.emailModalValue = event.target.value;
            const emailValidatorRegex = /^[a-zA-Z0-9._%+-]{3,}@[a-zA-Z0-9.-]{3,}\.[a-zA-Z]{2,}$/;
            // console.log(emailValidatorRegex.test(this.emailModalValue));
            if(emailValidatorRegex.test(this.emailModalValue)){
                this.isEmailVerified = this.emailModalValue == this.emailValue ? this.isEmailVerified : false;
                this.invalidEmail = false;
                this.disableEmailModalSubmit = false;
            }else{
                this.invalidEmail = true;
                this.disableEmailModalSubmit = true;
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleInputClose(){
        this.emailModalValue = '';
        this.invalidEmail = false;
    }
    handlePINInputClose(){
        this.pinCodeValue = '';
        this.invalidPIN = false;
    }

    handleCloseModal(){
        this.openEmailModal = false;
        this.openPinModal = false;
    }

    handleEmailModalSubmit(){
        this.emailValue = this.emailModalValue;
        this.openEmailModal = false;
        this.disableSubmitButton = false;
    }

    handlePinModalSubmit(){
        // console.log('clicked');
        // this.appId = this.applicantId;
        // console.log('inside appId ',this.appId);
        //const applicantEvent = new CustomEvent("applicantevent", {detail: this.applicantId});
        //this.dispatchEvent(applicantEvent);
        console.log(this.dedupeAddressList);
        if(this.isServicableArea){
            console.log('asmita ',this.pinCodeValue);
            let applicantObj = {
                'Id': this.applicantId,
                'Current_Pincode__c': this.pinCodeValue
            }
            updateApplicant({applicantObj:JSON.stringify(applicantObj),applicantId:this.applicantId,screenName:this.screenName})
            .then((result) => {
                this.showAddressModal = true;
                console.log(result,'Current pincode Updated');
                //clone address logic
                if(this.dedupeAddressList && this.dedupeAddressList.length > 0){

                    cloneAddress({applicantId:this.applicantId})
                    .then(result=>{
                        console.log(result,'copied address and marked as current');
                        
    
                    })
                    .catch(error=>{
                        console.error(error);
                    })
    
                    // apply additional dedupe check
                    aditionalDedupeCheck({applicantId:this.applicantId})
                    .then(result=>{
                        console.log(result);
                    }).catch(error=>{
                        console.error(error);
                    })
                    // this.dedupeAddressList.forEach(element => {
                    //     if(element.Pincode__c && element.Pincode__c == this.pinCodeValue){
                    //         // do additional dedupe check
                    //         // handleAdditionalDedupeCheck()
                    //         // .then(result=>{
    
                    //         // })
                    //         // .catch(error=>{
                    //         //     console.error(error);
                    //         // })
                    //     }
                    // });
    
                }
                this.openPinModal = false;
            })
            .catch((error) => {
                console.error(error);
            });            

        }else{
            // console.log(this.currentRetries,this.allowedRetries);
            if(this.currentRetries < this.allowedRetries){
                this.openRetryModal = true;
                this.openPinModal = false;

            }else{
                let loanApplcationObj = {
                    'Id': this.loanApplicationId,
                    'Stage__c': 'Reject',
                    'Reject_Reason__c':'MCP',
                    'Reject_Sub_Reason__c': 'P229'
                }
          
                updateLoanApplication({loanApplcationObj:JSON.stringify(loanApplcationObj),loanApplicationId:this.loanApplicationId,screenName:this.screenName})
                .then((result) => {
                    console.log(result,'Stage Updated');
                    this.errorScreen = true;
                    this.showHeader = false;
                    this.showContents = false;
                    this.openPinModal = false;
                    sendRejectionNotifications({loanAppId:this.loanApplicationId,applicantId:this.applicantId,triggeringPoint:'Confirm_Personal_Details',screenName:this.screenName})
                    .then(result=>{
                        if(result){
                            console.log(result,'sent rejected notification');
                        }
                    })
                    .catch(error=>{
                        console.error(error);
                    })
                })
                .catch((error) => {
                    console.error(error);
                });
            }
        }
    }

    handleReEnterPinCode(){
        this.openRetryModal = false;
        this.currentRetries = this.currentRetries != null ? this.currentRetries + 1 : 1;
        this.retriesLeft = this.allowedRetries - this.currentRetries;
        this.openPinModal = true;

        let applicantObj = {
            'Id': this.applicantId,
            'Current_Pincode_Retry_Count__c': parseInt(this.currentRetries)
        }
        
        updateApplicant({applicantObj:JSON.stringify(applicantObj),applicantId:this.applicantId,screenName:this.screenName})
        .then((result) => {
            console.log(result,'Current_Pincode_Retry_Count__c Updated');
        })
        .catch((error) => {
            console.error(error);
        });
    }

    handleHomeClick(){

    }

    handleSubmitMethod(){

        //logic for verification trigger is pending

        let applicantObj = {
            'Id': this.applicantId,
            'Personal_email_ID__c': this.emailValue
        }
        
        updateApplicant({applicantObj:JSON.stringify(applicantObj),applicantId:this.applicantId,screenName:this.screenName})
        .then((result) => {
            console.log(result,'Email Updated');
            this.openPinModal = true;
            //focus on in modal input
            const modalInput = this.template.querySelector('.Input-Text1');
            console.log('i',modalInput);
            if(modalInput){
                modalInput.focus();
            }else{
                setTimeout(() => {
                    const modalInput = this.template.querySelector('.Input-Text1');
                    console.log('i',modalInput);
                    if(modalInput){
                        modalInput.focus();
                    }
                }, 300);
            }
            if(!this.isEmailVerified){
                doEmailAuthentication({loanId:this.loanApplicationId,applicantRecId:this.applicantId,emailAddress:this.emailValue})
                .then(result=>{
                    console.log(this.loanApplicationId,this.applicantId,this.emailValue);
                    if(result && result.blnSuccess){
                        console.log('TU API',JSON.stringify(result));
                    }else{
                        console.error(result.strMessage);
                    }
                })
                .catch((error) => {
                    console.error(error);
                });
            }
        })
        .catch((error) => {
            console.error(error);
        });

        //need to dispatch event for redirection to other screen
    }

    closeAddressPopup(){
        this.showAddressModal = false;
    }

    handleAddressSubmit(event){
        this.addressId = event.detail.addressId;
        console.log('asmita address Id ', this.addressId);
        this.showLoader = false;
        this.showAddressModal = false;
        let loanApplcationObj = {
            'Id': this.loanApplicationId,
            'Last_visited_Page__c':this.screenName
        }
  
        updateLoanApplication({loanApplcationObj:JSON.stringify(loanApplcationObj),loanApplicationId:this.loanApplicationId,screenName:this.screenName})
        .then((result) => {
            console.log(result,'Confirm Personal details sbmitted');
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
    }

}