/**
 * @description       : 
 * @author            : Ruturaj Chothe
 * @group             : 
 * @last modified on  : 07-02-2024
 * @last modified by  : Ruturaj Chothe
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-01-2024   Ruturaj Chothe   Initial Version
**/
import { LightningElement, api, wire } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import getRemainingPANValidationAttempts from '@salesforce/apex/AUSF_NSDLPanValidation.getRemainingPANValidationAttempts';
// import getScreenCustomTextRecords from '@salesforce/apex/AUSF_NSDLPanValidation.getScreenCustomTextRecords';
import getGenericMasterRecords from '@salesforce/apex/AUSF_NSDLPanValidation.getGenericMasterRecords';
import ifrFraudCheck from '@salesforce/apex/AUSF_NSDLPanValidation.ifrFraudCheck';
import validatePan from '@salesforce/apex/AUSF_NsdlPanCalloutController.validatePAN';
import isguest from '@salesforce/user/isGuest';
import { NavigationMixin } from "lightning/navigation";
import sendRejectionNotifications from '@salesforce/apex/AUSF_Utility.sendRejectionNotifications'

export default class Ausf_nsdlVerificationScreenCmp extends NavigationMixin(LightningElement) {
    @api errorModal = false;
    AUlogoImg = AU_Assets + '/AU_Assets/images/IB.png';
    invalidPanImage = AU_Assets + '/AU_Assets/images/Group_427322087.png';
    errorMessage = '';
    @api pan;
    @api loanAppId = '';
    @api loanApplicantId = '';
    @api dob = '';
    @api name = '';
    @api screenName = '';
    remainingAttempts = '';
    showErrorScreen = false;
    integrationErrorMessage = '';
    integrationErrorModal = false;
    
    get showContent(){
        return !this.showErrorScreen;
    }

    get showModal(){
        return this.errorModal;
    }

    animationJSON = ''
    showAnimation = false;

    AUlogoImg = AU_Assets + '/AU_Assets/images/IB.png';
    loaderAnimationJSONSrc = AU_Assets + '/AU_Assets/PL_Animations/PAN_validation_loader/Loader_PAN.json';
    loaderAnimationJSON = '';
    panSuccessAnimationJSONSrc = AU_Assets + '/AU_Assets/PL_Animations/PAN_validation_loader/PAN_Success.json';
    panSuccessAnimationJSON = '';

    animationFlag = false;

    get getLoaderAnimationFlag(){
        if(!this.animationFlag){
            return true;
        }else{
            return false;
        }
    }

    get getPANSuccesAnimationFlag(){
        if(this.animationFlag){
            return true;
        }else{
            return false;
        }
    }

    changeAnimation(){
        this.animationFlag = !this.animationFlag;
    }

    

    // maximumAttemptsText = '';

    // @wire(getScreenCustomTextRecords, {screenName: 'Invalid PAN' })
    // getConigurableTextFromMetadata({ data, error }) {
    //     if (data) {
    //         // console.log(data);
    //         data.forEach(element => {
    //             if (element.DeveloperName == 'Maximum_Attempts_Text') {
    //                 this.maximumAttemptsText = element.Custom_String__c;
    //             }
    //         });
    //     } else if (error) {
    //         console.error(error);
    //     }
    // };

    @wire(getGenericMasterRecords, {Name: 'PAN retry message' })
    getConigurableTextFromGenericMaster({ data, error }) {
        if (data) {
            // console.log(data);
            data.forEach(element => {
                if (element.Name == 'PAN retry message') {
                    this.errorMessage = element.Custom_String__c;
                    
                    // this.template.querySelector('.terms-modal-body').innerHTML = this.termsPolicy;
                }
            });
        } else if (error) {
            console.error(error);
        }
    };

    async verifyPan(){
        // NSDL Validation Callout
        console.log('this.loanAppId, this.loanApplicantId, this.pan, this.name, this.dob');
        console.log(this.loanAppId + this.loanApplicantId + this.pan + this.name + this.dob);
        let response = await validatePan({loanApplicationId: this.loanAppId, applicantId: this.loanApplicantId, panNo: this.pan, name: this.name, dob: this.dob});  
        console.log('response');
        console.log(response);
        if(response.status === 'E'){
            // PAN is verified
            this.successfulValidation();       
        } else {
            this.unsuccessfulValidation(response);
        }
        
        
    }

    async successfulValidation() {
        // this.getPANSuccesAnimationFlag = true;
        this.showAnimation = true;
        // this.showModal = false;
        this.errorModal = false;
        this.showErrorScreen = false;
        this.animationFlag = true;
        this.integrationErrorModal = false;

        // Do fraud check
        let fraudCheckResult = await ifrFraudCheck({ pan: this.pan, applicationId: this.loanAppId, applicantId: this.loanApplicantId })
        console.log('fraudcheck -> ' + fraudCheckResult);
        if (fraudCheckResult) {
            // No fraud records present
            let twoSecondWating = setTimeout(() => {
                // Show success screen   
                const nextEvent = new CustomEvent('nsdlsuccess', {
                    detail: {
                        currentScreen: this.screenName,
                        loanAppId: this.loanAppId,
                        applicantId: this.loanApplicantId,
                        pan: this.pan
                    }
                });
                this.dispatchEvent(nextEvent);
            }, 2000);
        } else {
            // fraud result present
            let twoSecondWating = setTimeout(() => {
                // show error screen -> End Journey
                this.showAnimation = false;
                // this.showModal = false;
                this.errorModal = false;
                this.showErrorScreen = true;
                this.animationFlag = false;
                this.integrationErrorModal = false;
                sendRejectionNotifications({ loanAppId: this.loanAppId, applicantId: this.loanApplicantId, triggeringPoint: 'NSDL_Rejection', screnName: this.screenName })
            }, 2000);
        }
    }

    async unsuccessfulValidation(response) {
        if (response.blnIntegrationSuccess == false) {
            this.integrationErrorMessage = response.strMessage;
            this.integrationErrorModal = true;
            this.showErrorScreen = false;
            this.showAnimation = false;
            this.errorModal = false;
        } else {
            console.log('ERROR');
            console.log('this.applicantId -> ' + this.applicantId);
            this.remainingAttempts = await getRemainingPANValidationAttempts({ applicationId: this.loanAppId, applicantId: this.loanApplicantId });
            console.log('this.remainingAttempts -> ' + this.remainingAttempts);

            if (this.remainingAttempts > 0) {
                this.errorMessage = this.errorMessage.replace('{remainingAttempts}', this.remainingAttempts);
                this.errorModal = true;
                this.showErrorScreen = false;
                this.showAnimation = false;
                this.integrationErrorModal = false;
            } else {
                this.errorModal = false;
                this.showErrorScreen = true;
                this.showAnimation = false;
                this.integrationErrorModal = false;
                sendRejectionNotifications({ loanAppId: this.loanAppId, applicantId: this.loanApplicantId, triggeringPoint: 'NSDL_Rejection', screnName: this.screenName })
            }
        }
    }

    async checkRemainingAttempts(){
        try{
            this.remainingAttempts = await getRemainingPANValidationAttempts({applicationId : this.loanAppId, applicantId: this.loanApplicantId});
            this.errorMessage = this.errorMessage.replace('{remainingAttempts}', this.remainingAttempts);
        }catch(error){
            this.remainingAttempts = undefined;
            console.log(error);
        }
        
    }

    // redirect user to reenter pan
    handleReEnterPan(){
        const reneterPanEvent = new CustomEvent('reenterpan');
        this.dispatchEvent(reneterPanEvent);
    }

    handleReturnToHome(){
        this.showErrorScreen = true;
        this.showAnimation = false;
        this.errorModal = false;
        this.handleHome();
    }


    renderedCallback() {
    }

    connectedCallback(){
        // Load loader animation JSON

        var loader = new XMLHttpRequest();
        loader.open("GET", this.loaderAnimationJSONSrc);
        loader.onload = () => {
            this.showAnimation = true;
            this.loaderAnimationJSON = loader.responseText;
            this.animationJSON = loader.responseText;
        }
        loader.send(null);

        // Load PAN success animation JSON
        var panSuccess = new XMLHttpRequest();
        panSuccess.open("GET", this.panSuccessAnimationJSONSrc);
        panSuccess.onload = () => {
            this.panSuccessAnimationJSON = panSuccess.responseText;
        }
        panSuccess.send(null);

        // let twoSecondWating = setTimeout(() => {
        //     this.verifyPan();    
        // }, 3000);

        this.verifyPan();    
    }


    handleHome(){
        if(isguest){
            window.location.href = 'https://www.aubank.in/';
        }
        else{
            this[NavigationMixin.Navigate]({
                type: 'standard__namedPage',
                attributes: {
                    pageName: 'home'
                },
            });
        }
    }
}