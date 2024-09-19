/**
 * @description       : 
 * @author            : Murtaza Ali
 * @group             : 
 * @last modified on  : 04-07-2024
 * @last modified by  : Murtaza Ali
 * @Jira Story        : APL-103
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   04-07-2024   Murtaza Ali   Initial Version
**/
import { LightningElement, track, api, wire } from 'lwc';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import AUSF_MultipleMatchDisc from '@salesforce/label/c.AUSF_MultipleMatchDisc';
import AUSF_MultipleMatchFound from '@salesforce/label/c.AUSF_MultipleMatchFound';
import AUSF_SelectCustomerId from '@salesforce/label/c.AUSF_SelectCustomerId';
import AUSF_BasicDetails from '@salesforce/label/c.AUSF_BasicDetails';
import AUSF_ApplyForPersonalLoan from '@salesforce/label/c.AUSF_ApplyForPersonalLoan';
import getCustomerDedupe from '@salesforce/apex/AUSF_CustomerDedupeLWCController.getCustomerDedupe';
import updateRecordForCIF from '@salesforce/apex/AUSF_CustomerDedupeLWCController.updateRecordForCIF';
import AUSF_GenericTechnicalError from '@salesforce/label/c.AUSF_GenericTechnicalError';

export default class Ausf_CheckCustomerDedupe extends LightningElement {
    label = {
        AUSF_MultipleMatchDisc,
        AUSF_MultipleMatchFound,
        AUSF_SelectCustomerId,
        AUSF_BasicDetails,
        AUSF_ApplyForPersonalLoan,
        AUSF_GenericTechnicalError
    };
    screenName = this.label.AUSF_MultipleMatchFound;
    headerContents = this.label.AUSF_ApplyForPersonalLoan;
    headerDescription;
    stepsInCurrentJourney
    currentStep
    showContents = true;
    enableBackButton = false;
    buttonClass = 'button-disable';
    disableButton = true;
    showLoader = true;
    maskedCustomerData = [];
    @track selectedCustomerId = null;
    responseWrapper;
    @api customerDatas = [];
    @api loanApplicationId;// = 'a01C100000GfUNVIA3';
    @api applicantId;// = 'a02C1000002JKl3IAG';
    @api panNumber //= 'AHXPJ1050D';
    errorMessage;
    noRecordFound = false;
    dedupeCheckFail = false;
    recordFound = true;
    errorTitle;
    transactionError = false;
    connectedCallback() {  
        console.log(this.panNumber,this.loanApplicationId,this.applicantId);
        getCustomerDedupe({panNumber:this.panNumber,loanId:this.loanApplicationId,applicantId:this.applicantId}).then(data=>{
            if(data){
                console.log(JSON.stringify(data));
                this.responseWrapper = data;
                this.handleResponse();
            }
        }).catch(error => {
            console.error(error);
            this.errorMessage = this.label.AUSF_GenericTechnicalError;
            this.transactionError = true;

        });
    }

    maskCustomerData() {
        this.maskedCustomerData = this.customerDatas.map(customer => {
        return {
        ...customer,
        cifId: this.maskCISFID(customer.CIF)
        };
        });
    }
    maskCISFID(pan) {
        if (pan.length < 4) {
        return pan;
        }
        const last4 = pan.slice(-4);
        const masked = 'x'.repeat(pan.length - 4) + last4;
        return masked;
    }



    handleRecordSlection(event) {
        // Get the checkbox element
        const checkbox = event.target;
        this.template.querySelectorAll('input[type="checkbox"]').forEach(cb => {
            if (cb !== checkbox) {
                cb.checked = false;
                const parentDiv = cb.closest('div[data-id]');
                parentDiv.className='customer-row';
            }
        });
        // Get the parent div of the checkbox
        const parentDiv = checkbox.closest('div[data-id]');
        parentDiv.className='customer-row-selection';
        this.selectedCustomerId = event.target.value;
        this.disableButton = false;
        this.buttonClass = 'button-enabled';
    }
    handleProceedButton(){
        this.showLoader = true;
        updateRecordForCIF({CIF:this.selectedCustomerId,applicantId:this.applicantId}).then(result=>{
            if(result){
                const selectedCustomer = this.customerDatas.find(customer => customer.CIF === this.selectedCustomerId);
                if (selectedCustomer) {
                    this.checkCustomerRecords(selectedCustomer);
                }
            }else{
                this.errorMessage = this.label.AUSF_GenericTechnicalError;
                this.transactionError = true;
            }
            
        })
        .catch((error) => {
            console.error(error);
            this.errorMessage = this.label.AUSF_GenericTechnicalError;
            this.transactionError = true;
        });
        this.showLoader = false;
    }

    handleResponse() {
        
        if (!this.responseWrapper.blnSuccess && !this.responseWrapper.blnIntegrationSuccess) {
            this.errorMessage = this.label.AUSF_GenericTechnicalError+' - IC'+(this.responseWrapper.strMessage && typeof this.responseWrapper.strMessage === 'string' && this.responseWrapper.strMessage.includes('-') && this.responseWrapper.strMessage.split('-').length > 3 ? this.responseWrapper.strMessage.split('-')[3] : 'null');
            //this.dedupeCheckFail = true;
            this.transactionError = true;
        } else {
            this.customerDatas = this.responseWrapper.customers;
            if(!this.customerDatas){
                this.dedupeCheckFail = true;
                this.errorTitle = 'Customer_Dedupe_Fail';
                this.recordFound = false;
            }
            else if (this.customerDatas.length === 1) {
                this.checkCustomerRecords(this.customerDatas[0]);
            }else if (this.customerDatas.length === 0) {
                this.dedupeCheckFail = true;
                this.errorTitle = 'Customer_Dedupe_Fail';
                this.recordFound = false;
            }
            else{
                this.getCurrentScreenData();
                if (this.customerDatas) {
                    this.maskCustomerData();
                }
            }
        }
        this.showLoader = false;
    }
    checkCustomerRecords(customer) {
        if (customer.DPD || customer.NPA) {
            this.dedupeCheckFail = true;
            this.errorTitle = 'Customer_Dedupe_Fail';
            this.recordFound = false;
            
        } else {
                this.checkPreApprovedOffer(customer);
        }
    }
    
    getCurrentScreenData(){
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
                
            })
            .catch(error => {
                console.error(error);
                this.errorMessage = this.label.AUSF_GenericTechnicalError;
                this.transactionError = true;
            });
    }

    checkPreApprovedOffer(customer) {
        if (!customer.preApprovedOffer) {
            this.dedupeCheckFail = true;
            this.recordFound = false;
            this.errorTitle = 'Customer_Dedupe_Fail';
            
        } else {
            // proceed with next screen
            const nextEvent = new CustomEvent('submitevent', {
                detail: {
                    currentScreen: this.screenName,
                    refreshData:true
                }
            });
            this.dispatchEvent(nextEvent);
        }
    }
}