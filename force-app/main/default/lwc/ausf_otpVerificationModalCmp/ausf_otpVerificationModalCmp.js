/**
 * @description       : 
 * @author            : Ruturaj Chothe
 * @group             : 
 * @last modified on  : 07-02-2024
 * @last modified by  : Ruturaj Chothe
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-27-2024   Ruturaj Chothe   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import isOtpVerified from '@salesforce/apex/AUPL_MockResponses.isOtpVerified';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import mobileOtpVerificationHandler from '@salesforce/apex/AUSF_MobileOtpController.mobileOtpVerificationHandler';
import updateLeadStage from '@salesforce/apex/AUSF_Utility.updateLeadStage';



export default class Aupl_OtpVerificationModalCmp extends LightningElement {
    
    @api screenName = '';
    @api mobileNum = '';
    @api leadStageId = '';
    mobileNumber;
    applicantNumber = '';
    AUlogoImg = AU_Assets + '/AU_Assets/images/IB.png';
    crossSymbolImage = AU_Assets + '/AU_Assets/images/Outline/x.png';
    @api otpResult = 'OTP Fetching'
    @track isOtpFetched = false;
    @track isOtpEntered = false;
    @track resendOtpTimer = ''
    @track otpResponseFlag = false;
    response;

    @track combinedOtp = '';
    otpParts = ['', '', '', '', '', ''];
    otpResult = '';

    showLoader = false;

    count = 30;
    timer;

    resendClass = 'Resend-Inactive';

    // Resend Otp timer
    startResendOtpTimer() {
        this.count = 30;
        this.timer = setInterval(() => {
            if (!this.count) {
                clearInterval(this.timer);
                this.resendOtpTimer = '';
                this.resendClass = 'Resend-Active'
            } else {
                this.resendClass = 'Resend-Inactive'
                this.count--;
                this.resendOtpTimer = 'in ' + this.count + 's';
            }
        }, 1000);
    }

    // combines otp inputs and auto focuses to next input once user enters the value
    handleOtpChange(event) {
        console.log('otp value entered -> ' + event.target.value);
        const index = event.target.dataset.index;
        this.otpParts[index] = event.target.value;

        this.combinedOtp = this.otpParts.join('');
        if (this.combinedOtp.length === 6) {
            this.isOtpEntered = true;
        }else{
            this.isOtpEntered = false;
        }

        const currentInput = event.target;

        // Check if the current input has reached its maximum length
        if (currentInput.value.length === 1 && index < 6) {
            // Find the next input field
            const nextInput = this.template.querySelector(`[data-index="${+index + 1}"]`);
            // If there's a next input field, focus on it
            if (nextInput) {
                nextInput.focus();
            }
        }
    }


    get isSubmitDisabled() {
        return !this.isOtpFetched && !this.isOtpEntered;
    }

    // Handles the OTP submission part
    async handleSubmit() {
        console.log('screenname -> ' + this.screenName);
        console.log(this.combinedOtp);
        console.log(this.applicantNumber);
        try{
            this.showLoader = true;
            mobileOtpVerificationHandler({mobileNumber:this.applicantNumber, otp: this.combinedOtp, leadId: this.leadStageId, otpValue :'Mobile Validate OTP'})
                    .then((result) => {
                        this.response = result;
                        console.log('response ', this.response);
                        if (this.response.blnSuccess && this.response.otpResponse.statusCode == '100'){
                            //this.showLoader = false;
                            this.setRightInputStyling();
                            this.otpResult = 'OTP Verified.'
                            this.setOtpSuccessStyling();

                            let leadObj = {
                                'Id': this.leadStageId,
                                'Customer_OTP_Validated__c': true,
                            }
                      
                            updateLeadStage({leadObj:JSON.stringify(leadObj),leadId:this.leadStageId,screenName:this.screenName})
                            .then((result) => {
                            })
                            .catch((error) => {
                                console.error(error);
                            });

                            const nextEvent = new CustomEvent('submitevent', {
                                detail: {
                                    currentScreen: this.screenName,
                                    mobileNumber: this.mobileNumber
                                },
                                composed:true,
                                bubbles:true
                
                            });
                            this.dispatchEvent(nextEvent);
                        }else{
                            this.showLoader = false;
                            this.setWrongInputStyling();
                            this.otpResult = 'Enter Valid OTP.'
                            this.setOtpErrorStyling();
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching response', error);
                        const otpErrorEvent = new CustomEvent('otperrorevent', {
                            detail: {
                                errorMessage: 'Please try again letter.'
                            }
                        });
                        this.dispatchEvent(otpErrorEvent);
                    })
        }catch (error){
            console.error('Error Fetching Response');
            let genericApiErrMsg =  this.response.strMessage.includes('IC') ? this.genericApiErrMsg +' -IC' +this.response.strMessage.split("-")[3] : this.genericApiErrMsg;
            const otpErrorEvent = new CustomEvent('otperrorevent', {
                detail: {
                    errorMessage: genericApiErrMsg
                }
            });
            this.dispatchEvent(otpErrorEvent);
        }

    }


    // Handles resend otp functionality
    remainingOtpResendCounts = 3;
    resendToastMsg = '';
    variant = ''
    handleResend() {
        this.showLoader = true;
        if(this.remainingOtpResendCounts > 0){
            mobileOtpVerificationHandler({mobileNumber:this.applicantNumber, otp: '', leadId: this.leadStageId, otpValue :'Mobile Resend OTP'})
                    .then((result) => {
                        this.response = result;
                        console.log('response ', this.response);
                        this.showLoader = false;
                        if (this.response.blnSuccess && this.response.otpResponse.statusCode == '100'){
                            this.remainingOtpResendCounts--;
                            this.combinedOtp = '';
                            this.otpParts = ['', '', '', '', '', ''];
                            this.template.querySelector('form').reset();
                            this.resendToastMsg = 'OTP resent successfully. ' + this.remainingOtpResendCounts + ' attempts left.'
                            this.variant = 'success';
                            const evt = new ShowToastEvent({
                                title: '',
                                message: this.resendToastMsg,
                                variant: this.variant,
                              });
                            this.dispatchEvent(evt);
                            this.startResendOtpTimer();
                        }else{
                            this.showLoader = false;
                            let genericApiErrMsg =  this.response.strMessage.includes('IC') ? this.genericApiErrMsg +' -IC' +this.response.strMessage.split("-")[3] : this.genericApiErrMsg;
                            const resendErrorEvent = new CustomEvent('otperrorevent', {
                                detail: {
                                    errorMessage: genericApiErrMsg
                                }
                            });
                            this.dispatchEvent(resendErrorEvent);
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching response', error);
                        this.showLoader = false;
                        const otpErrorEvent = new CustomEvent('otperrorevent', {
                            detail: {
                                errorMessage: 'Please try again letter.'
                            }
                        });
                        this.dispatchEvent(otpErrorEvent);
                    })
        }else{
            this.showLoader = false;
            this.resendToastMsg = 'Max attempts reached, try later'
            this.variant = 'info';
            const evt = new ShowToastEvent({
                title: '',
                message: this.resendToastMsg,
                variant: this.variant,
            });
            this.dispatchEvent(evt);
        }
    }

    closeOtpModal(){
        // Send event to close modal
        const closeModalEvent = new CustomEvent('closemodalevent');
        this.dispatchEvent(closeModalEvent);
    }


    connectedCallback() {
        // Starts initial Otp timer
        this.applicantNumber = this.mobileNum;
        this.mobileNumber = this.mobileNumber ? this.mobileNumber : this.applicantNumber;
        this.startResendOtpTimer();
        // masks the mobile number coming from parent and shows last 4 digits of the number
        if(this.mobileNum !== '' && this.mobileNum !== null){
            this.mobileNum = 'XX' + this.mobileNum.substring(this.mobileNum.length - 4);
        }
        // this.template.root.setProperty('--_slds-g-shadow-outset-focus', 'none')
        const inputAligncenter = document.createElement('style');
        inputAligncenter.innerText = `.input-text-align_right input{ text-align: center!important; }`;
        document.body.appendChild(inputAligncenter);

        // this.template.querySelector(`[data-index="0"]`).focus();
    }
    disconnectedCallback() {
        // Clears timer when modal is disconnected from DOM
        clearInterval(this.timer);
        document.documentElement.style.setProperty('--slds-c-input-color-border', '#c9c9c9');
    }

    renderedCallback() {
        console.log(this.screenName);
    }

    setWrongInputStyling(){
        document.documentElement.style.setProperty('--slds-c-input-color-border', '#CF2433');
    }

    setRightInputStyling(){
        document.documentElement.style.setProperty('--slds-c-input-color-border', '#008033');
    }

    setOtpSuccessStyling(){
        document.documentElement.style.setProperty('--otpResultColor', '#008033');
    }

    setOtpErrorStyling(){
        document.documentElement.style.setProperty('--otpResultColor', '#CF2433');
    }
}