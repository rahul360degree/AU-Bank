import { LightningElement,track,api ,wire} from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import getGenericMasterRecords from '@salesforce/apex/AUSF_Utility.getGenericMasterRecords';
import getScreenCustomTextRecords from '@salesforce/apex/AUSF_Utility.getScreenCustomTextRecords';
import { createRecord} from "lightning/uiRecordApi";

import LEAD_STAGE_OBJECT from "@salesforce/schema/Lead_Stage__c";
import BUSINESS_PROOF_CONSENT_FIELD from "@salesforce/schema/Lead_Stage__c.Business_Proof_Consent_Date_Time__c";
import CART_CONSENT_FIELD from "@salesforce/schema/Lead_Stage__c.CART_Consent_Date_Time__c";
import ELECTRICITY_BILL_CONSENT_FIELD from "@salesforce/schema/Lead_Stage__c.Electricity_Bill_Consent_Date_Time__c";
import GST_AUTHENTICATION_CONSENT_FIELD from "@salesforce/schema/Lead_Stage__c.GST_Authentication_Consent_Date_time__c";
import GST_CONSENT_FIELD from "@salesforce/schema/Lead_Stage__c.GST_Consent_Date_Time__c";
import SALARY_SLIP_CONSENT_FIELD from "@salesforce/schema/Lead_Stage__c.Salary_Slip_Consent_Date_Time__c";
import NAME_FIELD from "@salesforce/schema/Lead_Stage__c.Name";



export default class Aupl_EnterMobileNumberScreenDummy extends LightningElement {
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
    AUCheckboxImg = AU_Assets + '/AU_Assets/images/Checkbox.png';

    @track isSubmitDisabled = true;
    @track isChecked = false;
    @track phoneNumber = '';
    @track errorMessage = '';
    @track openModal = false;
    @track phoneInputClass = "phone-input";
    @track phoneLabelClass = "phone-label";
    @track usagePolicy;
    openTermsPopup = false;
    openUsagePopup = false;
    isGettingStarted = false;
    @api dtTime;
    digitalLending;
    personalLoan;
    invalidMobErrrMsg;
    invaliCodeMobErrMsg;

    @wire(getScreenCustomTextRecords, {screenName: 'Enter Mobile Number' })
    getConigurableTextFromMetadata({ data, error }) {
        if (data) {
            console.log(data);
            data.forEach(element => {
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
            });
        } else if (error) {
            console.error(error);
        }
    };

    handleInput(event) {
        this.phoneNumber = event.target.value;
        this.phoneNumber = this.phoneNumber.replace(/[^0-9+()]/g, '');
        this.errorMessage = '';
        // if(this.phoneNumber.length < 10){
        //     this.isSubmitDisabled = true; 
        // }
        if(this.phoneNumber.length >= 10){
           this.validatePhoneNumber();
        }
        else{
            this.isSubmitDisabled = true;
        }
    }

    handleBlur() {
        this.validatePhoneNumber();
    }   

    validatePhoneNumber() {
        const firstDigit = this.phoneNumber.charAt(0);
        const allDigitsSame = this.phoneNumber.split('').every(char => char === this.phoneNumber.charAt(0));

        if ((this.phoneNumber.length > 10) || 
           (firstDigit >= '1' && firstDigit <= '5') ||
           (this.phoneNumber.length == 10 && allDigitsSame))  { 
             this.errorMessage = this.invalidMobErrrMsg;
             this.isSubmitDisabled = true;
             this.phoneInputClass  = "phone-input phone-input-error";
             this.phoneLabelClass = "phone-label phone-label-error";
        }else if (firstDigit == '+' || firstDigit == '0'){
            this.errorMessage = this.invaliCodeMobErrMsg;
            this.isSubmitDisabled = true;
            this.phoneInputClass  = "phone-input phone-input-error";
            this.phoneLabelClass = "phone-label phone-label-error";
        }else if (this.phoneNumber.length < 10){
            this.errorMessage = '';
            this.isSubmitDisabled = true;
            this.phoneInputClass  = "phone-input";
            this.phoneLabelClass = "phone-label";
        }else{
            this.errorMessage = '';
            this.isSubmitDisabled = false;
            this.phoneInputClass  = "phone-input";
            this.phoneLabelClass = "phone-label";
        }

    }

    handleClick(){
      
        alert('Hello!');
        console.log('Heyy There Asmita GM');
        var checked_box = this.template.querySelector(".check-box").checked;
       
        console.log('checkbox ',checked_box);
    }

    handleUsagePopup() {   
        this.openModal = true;
        this.openUsagePopup = true;
        getGenericMasterRecords({screenName: 'Usage Policy'})
        .then(result => {
            console.log(result);
            this.usagePolicy = result[0]["Custom_String_for_DIY__c"];
            this.template.querySelector('.usage-modal-body').innerHTML = this.usagePolicy;          
        })
        .catch(error => {
            console.error('Error fetching usage terms', error);
        });
    }

    handleModal(){
        this.openModal = false;
        this.openUsagePopup = false;
        this.openTermsPopup = false;
        this.dtTime = new Date().toISOString();
        console.log(this.dtTime);
        //Stamping consent fields with time stamp 
        const fields = {};
        if(this.phoneNumber){
           fields[NAME_FIELD.fieldApiName] = this.phoneNumber;
        }
        
        if(this.dtTime){
            console.log('hy there !');  
            fields[BUSINESS_PROOF_CONSENT_FIELD.fieldApiName] = this.dtTime;
            fields[CART_CONSENT_FIELD.fieldApiName]           = this.dtTime;
            fields[ELECTRICITY_BILL_CONSENT_FIELD.fieldApiName] = this.dtTime;
            fields[GST_AUTHENTICATION_CONSENT_FIELD.fieldApiName] = this.dtTime;
            fields[GST_CONSENT_FIELD.fieldApiName]                = this.dtTime;
            fields[SALARY_SLIP_CONSENT_FIELD.fieldApiName]        = this.dtTime;
        }
        const recordInput = { apiName: LEAD_STAGE_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(() => {
                console.log('TimeStamp Updated on the fields');              
            })
            .catch(error => {
                console.error('Error stamping consent timestamp', error);
            })
    }

    handleTermsPopup(){
        this.openModal = true;
        this.isChecked = true;
        this.openTermsPopup = true;
        getGenericMasterRecords({screenName:'Terms And Conditions'})
        .then(result => {
            this.termsPolicy = result[0]["Custom_String_for_DIY__c"];
            this.template.querySelector('.terms-modal-body').innerHTML = this.termsPolicy;          
        })
        .catch(error => {
            console.error('Error fetching terms of use', error);
        });
    }

}