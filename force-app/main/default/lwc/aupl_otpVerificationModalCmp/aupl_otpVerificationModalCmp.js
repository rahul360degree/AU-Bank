/**
 * @description       : 
 * @author            : Ruturaj Chothe
 * @group             : 
 * @last modified on  : 06-27-2024
 * @last modified by  : Ruturaj Chothe
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-27-2024   Ruturaj Chothe   Initial Version
**/
import { LightningElement, api, track } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import isOtpVerified from '@salesforce/apex/AUPL_MockResponses.isOtpVerified';
import { ShowToastEvent } from "lightning/platformShowToastEvent";


export default class Aupl_OtpVerificationModalCmp extends LightningElement {
    

    @api mobilenum = '';
    AUlogoImg = AU_Assets + '/AU_Assets/images/IB.png';
    crossSymbolImage = AU_Assets + '/AU_Assets/images/Outline/x.png';
    @api otpResult = 'OTP Fetching'
    @track isOtpFetched = false;
    @track isOtpEntered = false;
    @track resendOtpTimer = ''
    @track otpResponseFlag = false;

    @track combinedOtp = '';
    otpParts = ['', '', '', '', '', ''];
    otpResult = '';

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
        try{
            this.otpResponseFlag = await isOtpVerified({'otpString' : this.combinedOtp})
            if(this.otpResponseFlag){
                this.setRightInputStyling();
                this.otpResult = 'OTP Verified.'
                this.setOtpSuccessStyling();
            }else{
                this.setWrongInputStyling();
                this.otpResult = 'Enter Valid OTP.'
                this.setOtpErrorStyling();
            }
        }catch (error){

        }

    }

    // Handles resend otp functionality
    remainingOtpResendCounts = 3;
    resendToastMsg = '';
    variant = ''
    handleResend() {
        if(this.remainingOtpResendCounts > 0){
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
        this.close('okay');
    }


    connectedCallback() {
        // Starts initial Otp timer
        this.startResendOtpTimer();
        // masks the mobile number coming from parent and shows last 4 digits of the number
        if(this.mobilenum !== '' && this.mobilenum !== null){
            this.mobilenum = 'XX' + this.mobilenum.substring(this.mobilenum.length - 4);
        }
        
    }
    disconnectedCallback() {
        // Clears timer when modal is disconnected from DOM
        clearInterval(this.timer);
    }

    renderedCallback() {
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