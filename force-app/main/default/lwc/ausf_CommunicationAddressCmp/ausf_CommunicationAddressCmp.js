import { LightningElement, api } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import getApplicantAddressList from '@salesforce/apex/AUSF_Utility.getApplicantAddressList';
import updateApplicantAddressTenure from '@salesforce/apex/AUSF_CommunicationAddressController.updateApplicantAddressTenure';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';

export default class Ausf_CommunicationAddressCmp extends LightningElement {

    screenName = 'Communication Address';
    headerContents = 'Apply for Personal Loan';
    
    // headerDescription = 'Application process';
    // overallJourneySteps = 1;
    // currentJourney = 1;
    // stepsInCurrentJourney = 1;
    // currentStep = 1;
    // showContents = true;

    headerDescription;
    stepsInCurrentJourney;
    currentStep;
    showContents = true;
    enableBackButton = false;


    title;
    subtitle;
    openModal = false;
    showConsentModal = false;
    showDurationModal = false;
    showErrorScreen = false;
    proceedButtonFlag = false;
    isAddressTenureCaptured = false;
    communicationAddressContentFlag = false;
    showLoader = false;
    showContent = false;
    selectedAddress = '';

    selectedMonth;
    selectedYear;
    selectedType;

    skipNext = false;

    get showAddressContent(){
        return !this.communicationAddressContentFlag;
    }

    get disableProceedButton(){
        return !this.proceedButtonFlag;
    }


    isDisableAddressProceed(){
        return !this.proceedButtonFlag;
    }

    @api loanApplicationId = 'a01C100000H80SUIAZ';
    @api applicantId = 'a02C1000002Wr01IAC';


    applicantAddressArray = [];

    handleAddressSelection(event){

        this.template.querySelectorAll('.Selected-Address').forEach(element => {
            element.classList.remove('Selected-Address');
        });
        
        let selectedAddressId = event.target.name;
        this.selectedAddress = event.target.name;

        this.applicantAddressArray = this.applicantAddressArray.map(address => {
            return {
                ...address,
                Checked: address.Id === selectedAddressId
            };
        });
        this.proceedButtonFlag = true;
        

        this.template.querySelector(`[data-id="${selectedAddressId}"]`).classList.add('Selected-Address');
        
    }

    closeImg = AU_Assets + '/AU_Assets/images/Button.png';

    get addrModalBtnClass() {
        return this.isDisableAddressProceed() == true ? 'addrBtnDisabled' : 'addrButton';
    }

    handleAddressProceed(){
        // Capture address tenure of selected address

        let isTenureCaptured = false;
        this.applicantAddressArray.forEach(address => {
            if (address.Checked == true) {
                isTenureCaptured = address.isAddressTenureCaptured;
            }
        });

        if(isTenureCaptured === false){
            this.showDurationModal = true;
            this.communicationAddressContentFlag = true;
        }else{
            // Proceed with selected address
            this.showConsentModal = true;
            this.communicationAddressContentFlag = true;
        }
    }

    handleCloseModal(){
        this.openModal = false;
    }

    renderedCallback(){
        if(this.selectedAddress !== ''){
            if (this.template.querySelector(`[data-id="${this.selectedAddress}"]`)) {
                this.template.querySelector(`[data-id="${this.selectedAddress}"]`).classList.add('Selected-Address');   
            }
            this.proceedButtonFlag = true;
        }
    }

    showrejectScreen(){
        this.showConsentModal = false;
        this.showDurationModal = false;
        this.showLoader = false;
        this.showErrorScreen = true;
        this.showContent = false;
    }


    connectedCallback(){
        this.showLoader = true;
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
                    if (element.Label == 'Communication Address Title') {
                        this.title = element.Custom_String__c;
                    } else if (element.Label == 'Communication Address Subtitle') { 
                        this.subtitle = element.Custom_String__c;
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
            this.showContent = true;
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


        getApplicantAddressList({'applicantId': this.applicantId})
        .then((result) => {
            if (result) {
                this.showLoader = false;
                this.applicantAddressArray = result.map(address => {
                    if (address.Is_Communication_Address__c) {
                        this.selectedAddress = address.Name;
                    }
                    const fullAddress = [
                        address.Address_Line_1__c,
                        address.Address_Line_2__c,
                        address.Address_Line_3__c,
                        address.City__c,
                        address.State__c,
                        address.Pincode__c
                    ].filter(part => part).join(', ');
                    return {
                        'Id': address.Name,
                        'Source': 'From' + ' ' + address.Address_Source__c,
                        // 'Address': address.Address_Line_1__c + ', ' + address.Address_Line_2__c + ', ' + address.Address_Line_3__c + ', ' + address.City__c + ', ' + address.State__c + ', ' + address.Pincode__c,
                        'Address': fullAddress,
                        'typeOfResidence': address.Residence_Ownership_Type__c,
                        'year': address.Duration_of_Current_Stay_years__c,
                        'month': address.Duration_of_Current_Stay_Months__c,
                        // 'durationEntered': (address.Duration_of_Current_Stay_years__c != null) ? true : false,
                        'Checked': (address.Is_Communication_Address__c) ? true : false,
                        'recordId': address.Id,
                        'isAddressTenureCaptured': (address.Residence_Ownership_Type__c != null) ||
                            (address.Duration_of_Current_Stay_years__c != null) ||
                            (address.Duration_of_Current_Stay_Months__c != null) ? true : false
                    }
                })
            }
        })
        .catch(error => {
            console.error(error);
        })
    }

    handleConsentModalClose(){
        this.showConsentModal = false;
        this.communicationAddressContentFlag = true;
    }
    handleCloseDurationModal(){
        this.showDurationModal = false;
        this.communicationAddressContentFlag = false;
    }

    handleTenureSubmit(event){
        let year = event.detail.year;
        let month = event.detail.month;
        let typeOfResidence = event.detail.typeOfResidence;

        if(typeOfResidence === 'Owned'){
            this.skipNext = true;
        }

        let addressId = '';
        this.applicantAddressArray.forEach(address => {
            if(address.Checked == true){
                address.durationEntered = true;
                address.month = month;
                address.year = year;
                address.typeOfResidence = typeOfResidence;
                address.isAddressTenureCaptured = true;
                addressId = address.recordId
            }
        });
        
        // this.isAddressTenureCaptured = true;
        updateApplicantAddressTenure({'addressId': addressId, 'month': month, 'year': year, 'typeOfResidence': typeOfResidence, 'applicantId': this.applicantId})
        .then((result) => {
            this.showDurationModal = false;
        })
        .catch(error => {
            console.error(error);
        })


    }

    handleAddressDurationEdit(event){

        this.selectedMonth = event.target.dataset.month;
        this.selectedYear = event.target.dataset.year;
        this.selectedType = event.target.dataset.type;
        this.showDurationModal = true;
    }
}