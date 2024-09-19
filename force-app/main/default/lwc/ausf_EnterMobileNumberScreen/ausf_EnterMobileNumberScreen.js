/**
 * @description       : 
 * @author            : Asmita Mathur
 * @group             : 
 * @last modified on  : 07-01-2024
 * @last modified by  : Ruturaj Chothe
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-01-2024   Asmita Mathur   Initial Version
**/
import { LightningElement,track,api,wire} from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import getGenericMasterRecords from '@salesforce/apex/AUSF_Utility.getGenericMasterRecords';
import getScreenCustomTextRecords from '@salesforce/apex/AUSF_Utility.getScreenCustomTextRecords';
import getRelatedLeadStage from '@salesforce/apex/AUSF_Utility.getRelatedLeadStage';
import getApplicationDetails from '@salesforce/apex/AUSF_Utility.getApplicationDetails';
import getRelatedLeadStageById from '@salesforce/apex/AUSF_Utility.getRelatedLeadStageById';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isguest from '@salesforce/user/isGuest';
import createLeadStage from '@salesforce/apex/AUSF_Utility.createLeadStage';
import updateLeadStage from '@salesforce/apex/AUSF_Utility.updateLeadStage';
import getDecodedValue from '@salesforce/apex/AUSF_DIYUtility.getDecodedValue';
import getURLEncryptedId from '@salesforce/apex/AUSF_DIYUtility.getURLEncryptedId';
import sendAllNotification from '@salesforce/apex/AUSF_NotificationController.sendAllNotification';
import mobileOtpVerificationHandler from '@salesforce/apex/AUSF_MobileOtpController.mobileOtpVerificationHandler';
import createLeadStageRecord from '@salesforce/apex/AUSF_Utility.createLeadStageRecord';



export default class ausf_EnterMobileNumberScreen extends LightningElement {

    screenName = 'Enter Mobile Number';
    headerContents = 'Apply for Personal Loan';
    showContents = false;
    enableBackButton = false;
    // isGuestUser = true;
    isGuestUser = isguest;

    openTermsPopup = false;
    openUsagePopup = false;
    consentReceived = false;
    isIntervalStarted = false;
    digitalLending;
    personalLoan;
    invalidMobErrrMsg;
    invaliCodeMobErrMsg;
    agreeNotCheckedErrMsg;
    gcheckBox = false;
    @api leadStageId;
    disableCheckbox;
    showResend = false;
    assistedInterval;
    response;
    errorMessageApi = '';
    genericApiErrMsg;
    showLoader = false;
    encryptedLeadId;
    isDIYJourney
    
    closeImg = AU_Assets + '/AU_Assets/images/Button.png';
    AUlogoImg = AU_Assets + '/AU_Assets/images/IB.png';
    AUManImg = AU_Assets + '/AU_Assets/images/Man.png';
    AUMoneyImg = AU_Assets + '/AU_Assets/images/Money.png';
    AURupeeImg = AU_Assets + '/AU_Assets/images/Rupee.png';
    AUCalendarImg = AU_Assets + '/AU_Assets/images/calendar.png';
    AUGroupImg = AU_Assets + '/AU_Assets/images/GroupPeople.png';
    AUArrowImg = AU_Assets + '/AU_Assets/images/GreyArrow.png';
    AUArrowOrgImg = AU_Assets + '/AU_Assets/images/OrangeArrow.png';
    AUStudyImg = AU_Assets + '/AU_Assets/images/Study.png';
    AUPlaneImg = AU_Assets + '/AU_Assets/images/Plane.png';
    AUHealthImg = AU_Assets + '/AU_Assets/images/Health.png';
    AURingImg = AU_Assets + '/AU_Assets/images/ring.png';
    AUChevronRightImg = AU_Assets + '/AU_Assets/images/Outline/chevron-right.png';
    AUErrorImg = AU_Assets + '/AU_Assets/images/warning_icon.png';

    @track isSubmitDisabled = true;
    @track phoneNumber = '';
    @track errorMessage = '';
    @track openModal = false;
    @track phoneInputClass = "phone-input";
    @track phoneLabelClass = "phone-label";
    @track usagePolicy;
    @track termsPolicy;
    @track blnDisablePhoneNumber = false;

    @api dtTime;
    @api loanApplicationId;
    @api applicantId;
    @api showOtpModal = false;
    @api errorModal = false;
    @api leadFromParam = {
        strLeadObject : {'sobjectType':'Lead_Stage__c'},
        strmobile_number : '',
        strCampaign_id : '',
        strCampaign_name : '',
        strUtm_source : '',
        strUtm_medium : '',
        strUtm_campaign : '',
        strUtm_content : '',
        strUtm_term : '',
        screenName : ''
    }
    @track blnPhAutofill = false;

    @track objLeadRecord = {
        strLeadObject : {'sobjectType':'Lead_Stage__c'},
        strmobile_number : '',
        strCampaign_id : '',
        strCampaign_name : '',
        strUtm_source : '',
        strUtm_medium : '',
        strUtm_campaign : '',
        strUtm_content : '',
        strUtm_term : '',
        screenName : ''
    }

    get isGettingStarted(){
        if(this.assistedInterval){
            let timer = 0;
            let intervalValue = 10000;
            // console.log('called',this.leadStageId,this.isIntervalStarted);
            if(this.leadStageId && !this.isIntervalStarted && !this.consentReceived && !this.isGuestUser){
                // console.log('started');
                const checkStatus = setInterval((() => {
                    this.isIntervalStarted = true;
                    if(timer <= this.assistedInterval){
                        getApplicationDetails({phoneNumber:this.phoneNumber,screenName:this.screenName})
                        .then(result=>{
                            timer += intervalValue;
                            console.log(timer,JSON.stringify(result));
                            let leadObj = result && result.leadStageList && result.leadStageList.length > 0 ? result.leadStageList[0] : null;
                            if(result && leadObj && leadObj.Customer_OTP_Validated__c && result.loanApplicationList && result.loanApplicationList.length > 0){
                                let loanAppn = result.loanApplicationList[0];
                                if(loanAppn.Journey_Mode__c && loanAppn.Journey_Mode__c == 'Assisted'){
                                    this.consentReceived = true;
                                    clearInterval(checkStatus);
                                }
                            }
                            if(result && result.leadStageList && result.leadStageList.length > 0){
                                if(this.isGuestUser){
                                    this.template.querySelector(".check-box").checked = true;
                                }
                            }
                        })
                    }else{
                        clearInterval(checkStatus);
                    }
                }), intervalValue);
            }
            return this.consentReceived;
        }
    }

    get showErrorModal(){
        return this.errorModal;
    }

    connectedCallback() {
        /* Start - AUPL-605 */
        if (this.leadFromParam) {
            this.phoneNumber = this.leadFromParam.strmobile_number ? this.leadFromParam.strmobile_number : '';
            this.blnPhAutofill = this.phoneNumber ? true : false;
            this.objLeadRecord.strmobile_number = this.leadFromParam.strmobile_number;
            this.objLeadRecord.strCampaign_id = this.leadFromParam.strCampaign_id;
            this.objLeadRecord.strCampaign_name = this.leadFromParam.strCampaign_name;
            this.objLeadRecord.strUtm_source = this.leadFromParam.strUtm_source;
            this.objLeadRecord.strUtm_medium = this.leadFromParam.strUtm_medium;
            this.objLeadRecord.strUtm_campaign = this.leadFromParam.strUtm_campaign;
            this.objLeadRecord.strUtm_content = this.leadFromParam.strUtm_content;
            this.objLeadRecord.strUtm_term = this.leadFromParam.strUtm_term;
            this.objLeadRecord.screenName = this.screenName;
        }
        this.blnPhAutofill = this.leadStageId ? true : this.blnPhAutofill;
        
        getScreenCustomTextRecords({screenName: this.screenName})
        .then(result => {
            console.log('Asmita connected ',result);
            result.forEach(element => {
                if (element.DeveloperName == 'Digital_Lending_Link') {
                    this.digitalLending = element.Custom_String_for_DIY__c;
                }
                if (element.DeveloperName == 'Personal_Loan_Link') {
                    this.personalLoan = element.Custom_String_for_DIY__c;
                }
                if (element.DeveloperName == 'Invalid_Mobile_Number_Error_Message') {
                    this.invalidMobErrrMsg = element.Custom_String_for_DIY__c;
                }
                if (element.DeveloperName == 'Invalid_Code_Mobile_Number_Error_Message') {
                    this.invaliCodeMobErrMsg = element.Custom_String_for_DIY__c;
                }
                if (element.DeveloperName == 'Agree_Not_Checked_Error_Message') {
                    this.agreeNotCheckedErrMsg = element.Custom_String_for_DIY__c;
                }
                if (element.DeveloperName == 'Assisted_Journey_Interval') {
                    this.assistedInterval = element.Custom_String_for_DIY__c;
                }
                if (element.DeveloperName == 'Generic_API_Error_Message') {
                    this.genericApiErrMsg = element.Custom_String_for_DIY__c;
                }
                
            });
            if (this.blnPhAutofill && this.phoneNumber) {
                this.phoneNumber = this.phoneNumber.replace(/[^0-9+()]/g, '');
                if (this.phoneNumber) {
                    this.template.querySelector('.phone-input').style = 'padding-bottom: 4px;';
                    this.template.querySelector('.phone-input').focus();
                    this.validatePhoneNumber ();
                    if (!this.isSubmitDisabled) {
                        this.template.querySelector('.phone-input').disabled = true;
                    }
                }
            }
        }) 
        .catch(error => {
            console.log('In connected call back error....');
            this.error = error;
            console.log('Error is ' + this.error);
        });

        console.log('leadStage',this.leadStageId);
        if(!this.isGuestUser){
            this.disableCheckbox = true;
        }
        if(this.leadStageId){
            // getDecodedValue({recordId:this.encryptedLeadId})
            // .then(result=>{
            //     if(result && result.blnSuccess){
            //         this.leadStageId = result.strSessionId;
                    getRelatedLeadStageById({leadId :this.leadStageId})
                    .then(data => {
                        console.log('related leadStage ',data); 
                        this.phoneNumber = data[0].Name;
                        if (this.blnPhAutofill && this.phoneNumber && this.phoneNumber.length > 0 && !data[0].Name.toLowerCase().startsWith('aupl')) {
                            this.template.querySelector('.phone-input').style = 'padding-bottom: 4px;';
                            this.template.querySelector('.phone-input').disabled = true;
                            if (data[0].Is_Mobile_Number_Verified__c && data[0].Is_Mobile_Number_Verified__c == 'Yes') {
                                this.consentReceived = true;
                            }
                        }
                        /*
                        else if (this.blnPhAutofill && this.phoneNumber && this.phoneNumber.toUpperCase().startsWtih('AUPL-')) {
                            this.phoneNumber = '';
                        }
                        */
                        // this.disableCheckbox = true;
                        // this.template.querySelector(".check-box").checked = true;
                        // this.gcheckBox = true;
                        this.isSubmitDisabled = false;
                        const leadEvent = new CustomEvent("leadevent", {detail: this.leadStageId});
                        this.dispatchEvent(leadEvent);
                    })
                    .catch(error => {
                        console.log('In connected call back error fetching relatedLeadStage....');
                        this.error = error;
                        console.log('Error is ' + this.error);
                    });
            //     }
            // })
        }
        else {
            if (this.blnPhAutofill && this.phoneNumber) {
                this.phoneInputClass  = "phone-input";
                this.phoneLabelClass = "phone-label";
                //this.template.querySelector('.phone-input').style = 'padding-bottom: 4px;';
                /* this.template.querySelector('.phone-input').focus();
                this.validatePhoneNumber ();
                if (!this.isSubmitDisabled) {
                    this.template.querySelector('.phone-input').disabled = true;
                }
                */
            }
        }
        

    }

    handleInput(event) {
        this.phoneNumber = event.target.value;
        this.phoneNumber = this.phoneNumber.replace(/[^0-9+()]/g, '');
        this.errorMessage = '';
        if(this.phoneNumber.length >= 10){
           this.validatePhoneNumber();
        }
        else{
            this.isSubmitDisabled = true;
        }

        if(event.target.value.length === 0){
            console.log('event.target.value.length -> ' + event.target.value.length );
            console.log(this.template.querySelector('.phone-input').style);
            this.template.querySelector('.phone-input').style = 'paddingTop: 4px';
            this.template.querySelector('.phone-input').style = 'paddingBottom: 0px';
        }else{
            console.log('event.target.value.length -> ' + event.target.value.length );
            this.template.querySelector('.phone-input').style = 'padding-bottom: 4px';
        }
    }

    handleBlur() {
        this.validatePhoneNumber();
    }   

    validatePhoneNumber() {
        const firstDigit = this.phoneNumber.charAt(0);
        const allDigitsSame = this.phoneNumber.split('').every(char => char === this.phoneNumber.charAt(0));
        if(this.isGuestUser){
            this.disableCheckbox = false;
        }
        this.showResend = false;

        if (firstDigit == '+' || firstDigit == '0')  { 
            this.errorMessage = this.invaliCodeMobErrMsg;
            this.isSubmitDisabled = true;
            this.phoneInputClass  = "phone-input phone-input-error";
            this.phoneLabelClass = "phone-label phone-label-error";
        }else if ((this.phoneNumber.length > 10) || 
                 (firstDigit >= '1' && firstDigit <= '5') ||
                 (this.phoneNumber.length == 10 && allDigitsSame)){
            this.errorMessage = this.invalidMobErrrMsg;
            this.isSubmitDisabled = true;
            this.phoneInputClass  = "phone-input phone-input-error";
            this.phoneLabelClass = "phone-label phone-label-error";
        }else if (this.phoneNumber.length < 10){
            this.errorMessage = '';
            this.isSubmitDisabled = true;
            this.phoneInputClass  = "phone-input";
            this.phoneLabelClass = "phone-label";
        }else{
            getRelatedLeadStage({mobileNumber:this.phoneNumber})
            .then(result=>{
                console.log('result>',result);
                if(result && result.length > 0){
                    this.leadStageId = result[0].Id;
                    this.disableCheckbox = true;
                    if(this.isGuestUser){
                        this.template.querySelector(".check-box").checked = true;
                    }
                    this.gcheckBox = true;
                    const leadEvent = new CustomEvent("leadevent", {detail: this.leadStageId});
                    this.dispatchEvent(leadEvent);
                }else{
                    if(this.isGuestUser){
                        this.disableCheckbox = false;
                    }
                }
            })
            .catch(error=>{
                console.error(error);
            })
            this.errorMessage = '';
            this.isSubmitDisabled = false;
            this.phoneInputClass  = "phone-input";
            this.phoneLabelClass = "phone-label";
        }
    }

    handleClick(){ 
        console.log('gcheckBox',this.gcheckBox);
        this.dtTime = new Date().toISOString();
        console.log(this.dtTime);
        if(!this.gcheckBox && this.isGuestUser){
            this.errorMessage = this.agreeNotCheckedErrMsg;
        }
        else{        
            this.showLoader = true;
            this.handleConsent(this.dtTime);
        }
    }

    closeOtpModalWindow(){
        this.showOtpModal = false;
    }

    handleUsagePopup() {   
        this.openModal = true;
        this.openUsagePopup = true;
        getGenericMasterRecords({screenName: this.screenName,name: 'AU Usage Terms'})
        .then(result => {
            console.log(result);
            if(this.leadStageId){
                this.usagePolicy = result[0]["Custom_String__c"];
            }else{
                this.usagePolicy = result[0]["Custom_String_for_DIY__c"];
            }
            this.template.querySelector('.usage-modal-body').innerHTML = this.usagePolicy;          
        })
        .catch(error => {
            console.error('Error fetching usage terms', error);
        });
    }

    handleCloseModal(){
        this.openModal = false;
        this.openUsagePopup = false;
        this.openTermsPopup = false;
        if(!this.gcheckBox){
            if(this.isGuestUser){
                this.template.querySelector(".check-box").checked = false;
            }
        }       
       
    }

    handleAgreeClick(){
        this.openModal = false;
        this.openTermsPopup = false;
        this.template.querySelector(".check-box").checked = true;
        this.gcheckBox = true;  
        if (this.errorMessage == this.agreeNotCheckedErrMsg){
            this.errorMessage = '';
        }     
    }

    handleTermsPopup(){
        this.openModal = true;
        this.openTermsPopup = true;
        if(this.gcheckBox){
            if(this.isGuestUser){
                this.template.querySelector(".check-box").checked = true;
            }
        }
        getGenericMasterRecords({screenName: this.screenName, name:'AU Terms Of Use'})
        .then(result => {
            if(this.leadStageId){
                this.termsPolicy = result[0]["Custom_String__c"];
            }else{
                this.termsPolicy = result[0]["Custom_String_for_DIY__c"];
            }
            this.template.querySelector('.terms-modal-body').innerHTML = this.termsPolicy;          
        })
        .catch(error => {
            console.error('Error fetching terms of use', error);
        });
    }
    
    handleConsent(){
        try{
            if(!this.leadStageId){
                /*
                let leadStageObj = {
                    'Name' :this.phoneNumber
                }
                this.isDIYJourney = false;
                if (this.dtTime && this.isGuestUser) {
                        if(this.isGuestUser){
                            leadStageObj['Journey_Mode__c'] = 'DIY';
                            leadStageObj['Loan_Application__r.Journey_Mode__c'] = 'DIY';
                            this.isDIYJourney = true;
                        }
                }
                */
                
                this.objLeadRecord.strLeadObject.Name = this.phoneNumber;

                if (this.dtTime && this.isGuestUser) {
                    if(this.isGuestUser){
                        this.objLeadRecord.strLeadObject.Journey_Mode__c = 'DIY';
                        this.isDIYJourney = true;
                        this.objLeadRecord.strLeadObject.Campaign_Id__c = this.leadFromParam.strCampaign_id ? this.leadFromParam.strCampaign_id : '';
                        this.objLeadRecord.strLeadObject.Campaign_Name__c = this.leadFromParam.strCampaign_name ? this.leadFromParam.strCampaign_name : '';
                        this.objLeadRecord.strLeadObject.UTM_Source__c = this.leadFromParam.strUtm_source ? this.leadFromParam.strUtm_source : '';
                        this.objLeadRecord.strLeadObject.UTM_Medium__c = this.leadFromParam.strUtm_medium ? this.leadFromParam.strUtm_medium : '';
                        this.objLeadRecord.strLeadObject.UTM_Campaign__c = this.leadFromParam.strUtm_campaign ? this.leadFromParam.strUtm_campaign : '';
                        this.objLeadRecord.strLeadObject.UTM_Content__c = this.leadFromParam.strUtm_content ? this.leadFromParam.strUtm_content : '';
                        this.objLeadRecord.strLeadObject.UTM_Term__c = this.leadFromParam.strUtm_term ? this.leadFromParam.strUtm_term : '';
                    }
                }

                createLeadStageRecord ({leadStageParams : JSON.stringify(this.objLeadRecord)})
                .then((result) => {
                    this.leadStageId = result;
                    console.log('TimeStamp Updated on the fields',result);  
                    const leadEvent = new CustomEvent("leadevent", {detail: this.leadStageId});
                    this.dispatchEvent(leadEvent);
                    this.handleResponse();             
                })
                .catch(error => {
                    console.error('Error stamping consent timestamp', error);
                })
                
                
                /*
                createLeadStage({leadStageObj :JSON.stringify(leadStageObj), screenName: this.screenName})
                .then((result) => {
                        this.leadStageId = result;
                        console.log('TimeStamp Updated on the fields',result);  
                        const leadEvent = new CustomEvent("leadevent", {detail: this.leadStageId});
                        this.dispatchEvent(leadEvent);
                        this.handleResponse();             
                    })
                    .catch(error => {
                        console.error('Error stamping consent timestamp', error);
                    })
                */
                
            }else{
                this.handleResponse();             
            }

        }catch(error){
            console.error(error);
        }
    }

    handleResponse(){
        if(this.isGuestUser){

            if(!this.isDIYJourney){
                let leadStageObj = {
                    'Id' :this.leadStageId
                }         
                leadStageObj['Business_Proof_Consent_Date_Time__c'] = this.dtTime;
                leadStageObj['CART_Consent_Date_Time__c'] = this.dtTime;
                leadStageObj['Electricity_Bill_Consent_Date_Time__c'] = this.dtTime;
                leadStageObj['GST_Authentication_Consent_Date_time__c'] = this.dtTime;
                leadStageObj['GST_Consent_Date_Time__c'] = this.dtTime;
                leadStageObj['Salary_Slip_Consent_Date_Time__c'] = this.dtTime;

                this.showLoader = true;
                        
                updateLeadStage({leadObj:JSON.stringify(leadStageObj),leadId:this.leadStageId,screenName:this.screenName})
                .then((result) => {
                    console.log(result,'Lead Updated with Consent');
                    this.showLoader = false
                })
                .catch((error) => {
                    console.error(error);
                });
            }else{
                let leadStageObj = {
                    'Id' :this.leadStageId
                }         
                leadStageObj['Electricity_Bill_Consent_Date_Time__c'] = this.dtTime;
                this.showLoader = true;
                
                updateLeadStage({leadObj:JSON.stringify(leadStageObj),leadId:this.leadStageId,screenName:this.screenName})
                .then((result) => {
                    console.log(result,'Lead Updated with Consent');
                    this.showLoader = false
                })
                .catch((error) => {
                    console.error(error);
                });
            }
            mobileOtpVerificationHandler({mobileNumber :this.phoneNumber, otp :'', leadId :this.leadStageId, otpValue :'Mobile Generate OTP'})
                    .then((result) => {
                        this.response = result;
                        this.showLoader = false;
                        console.log('response ', this.response);
                        if (this.response.blnSuccess && this.response.otpResponse.statusCode == '100'){
                          this.showOtpModal = true;
                        }else{
                            let localErrorMsg =  this.response.strMessage.includes('IC') ? this.genericApiErrMsg +' -IC' +this.response.strMessage.split("-")[3] : this.genericApiErrMsg;
                            this.errorMessageApi = localErrorMsg;
                            this.errorModal = true;
                        }
                    })
                    .catch(error => {
                        console.error('Error fetching response', error);
                    })
        }else{
            this.handleSendLink();
        }

    }

    handleCloseErrorModal(){
       this.errorModal = false;
this.errorMessageApi = '';
    }

    handleSendLink(){
        //logic for sending link to the customer in place of OTP

        // sendAllNotification({objApp:null,objLoan:null,applicantId:null,loanId:null,strTriggerPoint:'test'})
        // .then(result=>{
        //     if(result){
        //     }
        // })
        // .catch(error=>{
        //     console.error(error);
        // })

        getURLEncryptedId({recordId:this.leadStageId,blnNotification:true})
        .then(data=>{
            if(data && data.blnSuccess){
                this.encryptedLeadId = data.strSessionId;

                let leadStageObj = {
                    'Id' :this.leadStageId,
                    'Community_Encrypted_Link__c':'https://ausfplos--dev1.sandbox.my.site.com/s/la-start-home?appId='+this.encryptedLeadId
                }
        
                updateLeadStage({leadObj:JSON.stringify(leadStageObj),leadId:this.leadStageId,screenName:this.screenName})
                .then((result) => {
                    console.log(result,'Lead Updated with link');
                    this.showLoader = false;
                    const event = new ShowToastEvent({
                        title: 'Success',
                        message:
                            'SMS is sent to the customer',
                        variant:'success'
                    });
                    this.dispatchEvent(event);
            
                    this.showResend = true;
                })
                .catch((error) => {
                    console.error(error);
                });
            }
        })
        .catch(error=>{
            console.error(error);
        })
    }

    handleOtpVerificationErrors(event){
        let errorMessage = event.detail.errorMessage ? event.detail.errorMessage : 'Please try again letter';
        this.errorMessageApi = this.genericApiErrMsg;
        this.errorModal = true;
        this.showOtpModal = false;
    }

}