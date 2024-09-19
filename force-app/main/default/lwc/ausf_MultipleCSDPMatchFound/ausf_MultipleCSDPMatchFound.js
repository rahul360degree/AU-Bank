import { LightningElement, track, api, wire } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import AUSF_MultipleMatchDisc from '@salesforce/label/c.AUSF_MultipleMatchDisc';
import AUSF_MultipleMatchFound from '@salesforce/label/c.AUSF_MultipleMatchFound';
import AUSF_SelectCustomerId from '@salesforce/label/c.AUSF_SelectCustomerId';
import AUSF_BasicDetails from '@salesforce/label/c.AUSF_BasicDetails';
import AUSF_ApplyForPersonalLoan from '@salesforce/label/c.AUSF_ApplyForPersonalLoan';
import rejectLoanApp from '@salesforce/apex/AUSF_CustomerDedupeLWCController.rejectLoanApp';
import getCustomerDedupe from '@salesforce/apex/AUSF_CustomerDedupeLWCController.getCustomerDedupe';

export default class Ausf_MultipleCSDPMatchFound extends LightningElement {
    label = {
        AUSF_MultipleMatchDisc,
        AUSF_MultipleMatchFound,
        AUSF_SelectCustomerId,
        AUSF_BasicDetails,
        AUSF_ApplyForPersonalLoan
    };
    screenName = this.label.AUSF_MultipleMatchFound;
    headerContents = this.label.AUSF_ApplyForPersonalLoan;
    headerDescription = this.label.AUSF_BasicDetails;
    overallJourneySteps = 3;
    currentJourney = 1;
    stepsInCurrentJourney = 6;
    currentStep = 5;
    showContents = true;
    enableBackButton = false;
    buttonClass = 'button-disable';
    disableButton = true;
    showLoader = true;
    maskedCustomerData = [];
    @track selectedCustomerId = null;
    responseWrapper;
    @api customerDatas = [];
    @api loanApplicationId;
    @api applicantId;
    @api panNumber;
    errorMessage;
    noRecordFound = false;
    dedupeCheckFail = false;
    transactionError = false;
    recordFound = true;

    connectedCallback() {  
        getCustomerDedupe({panNumber:this.panNumber,loanId:this.loanApplicationId,applicantId:this.applicantId}).then(data=>{
            if(data){
                this.responseWrapper = data;
                this.handleResponse();
            }
        }).catch(error => {
            console.error(error);
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
        const selectedCustomer = this.customerDatas.find(customer => customer.CIF === this.selectedCustomerId);
        if (selectedCustomer) {
            this.checkCustomerRecords(selectedCustomer);
        }
        console.log('event');
        const nextEvent = new CustomEvent('submitevent', {
            detail: {
                currentScreen: this.screenName,
            }
        });
        this.dispatchEvent(nextEvent);
    }

    handleResponse() {
        
        if (!this.responseWrapper.blnSuccess && !this.responseWrapper.blnIntegrationSuccess) {
            this.errorMessage = this.responseWrapper.strMessage;
            this.transactionError = true;
            this.recordFound = false;
        } else {
            this.customerDatas = this.responseWrapper.customers;
            if(!this.customerDatas){
                this.transactionError = true;
                this.recordFound = false;
            }
            else if (this.customerDatas.length === 1) {
                this.checkCustomerRecords(this.customerDatas[0]);
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
            this.recordFound = false;
            let rejectReason = customer.DPD?'DPD Check':'NPA Check';
            rejectLoanApp({loanId:this.loanApplicationId,rejectResaon:rejectReason}).then(result=>{
                this.loanRejected = true;
                this.rejectionReason = 'Loan application rejected due to DPD or NPA flags.';
            }).catch(error => {
                console.error(error);
            });
            
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
                }
                
            })
            .catch(error => {
                console.error(error);
            });
    }

    checkPreApprovedOffer(customer) {
        if (!customer.preApprovedOffer) {
            this.dedupeCheckFail = true;
            this.recordFound = false;
            rejectLoanApp({loanId:this.loanApplicationId,rejectResaon:'PA offer not found'}).then(result=>{
                this.loanRejected = true;
                this.rejectionReason = 'Loan application rejected due to absence of a pre-approved offer.';
            }).catch(error => {
                console.error(error);
            });
            
        } else {
            // proceed with next screen
        }
    }

}