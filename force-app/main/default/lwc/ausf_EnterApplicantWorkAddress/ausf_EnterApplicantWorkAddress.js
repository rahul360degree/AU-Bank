import { LightningElement, api, track } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';
import createAddress from '@salesforce/apex/AUSF_Utility.createAddress';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import validatePinCode from '@salesforce/apex/AUSF_ConfirmPersonalDetailsController.validatePinCode';

export default class Ausf_EnterApplicantWorkAddress extends LightningElement {

    pinImg = Assets + '/AU_Assets/images/Group_427321515.png';
    closeIcon = Assets + '/AU_Assets/images/Outline/x.png';
    infoImg = Assets + '/AU_Assets/images/info.png';
    tickImgUrl = Assets + '/AU_Assets/images/add.png';

    showAddressModal = false;
    isDisableAddressSubmit = true;
    addr1Value = '';
    addr2Value = '';
    addr3Value = '';
    pincode = '';
    pincodedetails = '';
    state = '';
    city = '';
    durationSubmitButtonDisabled = false;
    submitButtonCls = '';
    showOnlyPincode = false;
    showWheels = false;
    hasRendered = false;

    @api year = '1';
    @api month = '0';
    @api typeOfResidence = '';

    @track itemsMonth = [];
    @track itemsYear = [];

    fullAddress = '';
    yearsDuration = '';
    monthsDuration = '';
    addressSource = '';
    addrs2Show = '';
    addrs3Show = '';



    @api screenname = '';
    @api applicantId;
    @api addressheader = '';
    @api existingAdress = [];
    addressId;
    //get initial data from server
    connectedCallback() {
        if (this.screenname == 'Confirm Personal Details') {
            this.showOnlyPincode = true;
            getCurrentScreenData({ loanApplicationId: '', applicantId: this.applicantId, screenName: '', masterName: '' })
                .then(result => {
                    console.log('result ', result);
                    if (result.applicantList[0] && result.applicantList[0].Current_Pincode__c) {
                        this.pincode = result.applicantList[0].Current_Pincode__c;
                    }
                })
                .catch(error => {
                    this.error = error;
                    console.log('Error is ' + this.error);
                });
        } else {
            this.showOnlyPincode = false;
            for (let i = 1; i <= 4; i++) {
                for (let j = 0; j <= 11; j++) {
                    this.itemsMonth.push({ id: j, name: `${j}` });
                }
            }

            for (let i = 1; i <= 4; i++) {
                for (let j = 0; j <= 60; j++) {
                    this.itemsYear.push({ id: j, name: `${j}` });
                }
            }
            this.validateDurationInputs();
            console.log(this.year, this.month, this.typeOfResidence); 
            
            if(this.existingAdress.length > 0){
                this.addr2Value = (this.existingAdress[0].Address_Line_2__c) ? this.existingAdress[0].Address_Line_2__c : '';
                this.addr1Value = (this.existingAdress[0].Address_Line_1__c) ? this.existingAdress[0].Address_Line_1__c : '';
                this.addr3Value = (this.existingAdress[0].Address_Line_3__c) ? this.existingAdress[0].Address_Line_3__c : '';
                this.pincode = this.existingAdress[0].Pincode__c;
                this.typeOfResidence = this.existingAdress[0].Residence_Ownership_Type__c;
                this.month = this.existingAdress[0].Duration_of_Current_Stay_Months__c;
                this.year = this.existingAdress[0].Duration_of_Current_Stay_years__c;
                this.addressId = this.existingAdress[0].Id;
            }
            
        }
        
        

    }

    renderedCallback() {
        //To show city and state on the screen based on the pincode present on screen
        if (this.pincode && !this.hasRendered) {
            this.validatePinCode();
            this.hasRendered = true;
        }
        if (this.typeOfResidence) {
            this.updateType({
                target: {
                    innerText: this.typeOfResidence
                }
            });
        }

    }

    validatePinCode(){
        validatePinCode({ pinCode: this.pincode, loanApplicationId: '' })
                .then(result => {
                    if ((result && result.length > 0)) {
                        this.pincodedetails = result[0].City__c + ', ' + result[0].State__c;
                        this.city = result[0].City__c;
                        this.state = result[0].State__c;
                    } else {
                        this.pincodedetails = '';
                    }
                })
                .catch(error => {
                    console.error(error);
                })
    }

    get addrModalBtnClass() {
        return this.isDisableAddressSubmit == true ? 'addrBtnDisabled' : 'addrButton';
    }

    //Closes the modal on close icon click
    handleCloseModal() {
        const closeModalEvent = new CustomEvent('closemodalevent');
        this.dispatchEvent(closeModalEvent);
    }

    handleAddressLine1(event) {
        this.addr1Value = event.target.value;
        this.handleAllInputValues();
    }

    handleAddressLine2(event) {
        this.addr2Value = event.target.value;
    }

    handleAddressLine3(event) {
        this.addr3Value = event.target.value;
    }

    handlePinCode(event) {

        this.pincode = event.target.value;
        this.validatePinCode();
        this.handleAllInputValues();
    }

    updateType(event) {
        
        if (event.target.innerText != '') {
            console.log(event);
            this.template.querySelectorAll('.chips,.chips-enabled').forEach(item => {
                item.className = '';
                if (event.target.innerText == item.innerText) {
                    this.typeOfResidence = event.target.innerText;
                    item.classList.add('chips-enabled');
                }
                else {
                    item.classList.add('chips');
                }
            });
            this.handleAllInputValues();
        }


    }

    handleAllInputValues() {

        if (!this.showOnlyPincode) {
            if (this.typeOfResidence && this.pincode && this.addr1Value) {
                this.isDisableAddressSubmit = false;
            } else {
                this.isDisableAddressSubmit = true;
            }
        } else {
            if (this.pincode && this.addr1Value) {
                this.isDisableAddressSubmit = false;
            } else {
                this.isDisableAddressSubmit = true;
            }

        }
    }

    updateYear(event) {
        this.year = event.detail.value;
        this.validateDurationInputs()

    }

    updateMonth(event) {
        this.month = event.detail.value;
        this.validateDurationInputs();

    }

    validateDurationInputs() {

        if (this.typeOfResidence != '' && this.typeOfResidence != null && this.year != null && this.month != null && (this.year != 0 || this.month != 0)) {
            this.submitButtonCls = 'agree-box';
            this.durationSubmitButtonDisabled = false;
        }
        else {
            this.submitButtonCls = 'agree-box-disabled';
            this.durationSubmitButtonDisabled = true;
        }
    }

    handleAddressModalSubmit() {
        try {
            if (this.showOnlyPincode) {
                this.addressType = 'Current';
                this.addressSource = 'your input';
                this.createAddress();
            } else {

                this.addressType = 'Work';
                this.addressSource = 'business ownership proof';
                this.yearsDuration = this.year;
                this.monthsDuration = this.month;
                this.addrs2Show = this.addr2Value ? ',' + this.addr2Value : '';
                this.addrs3Show = this.addr3Value ? ',' + this.addr3Value : '';
                this.fullAddress = this.addr1Value + this.addrs2Show + this.addrs3Show + ',' + this.city + ',' + this.state + ',' + this.pincode;
                if(this.typeOfResidence != 'Owned'){
                   this.showWheels = false;
                   this.createAddress();
                }else{
                    this.showWheels = true;
                }
            }
        } catch (error) {
            console.error();
        }
    }

    createAddress() {

        let addressObj = {
            'Address_Line_1__c': this.addr1Value,
            'Address_Line_2__c': this.addr2Value,
            'Address_Line_3__c': this.addr3Value,
            'Pincode__c': this.pincode,
            'Address_Type__c': this.addressType,
            'Address_Source__c': this.addressSource,
            'Working_Area__c': 'Yes',
            'Applicant__c': this.applicantId,
            'Active__c': true,
            'City__c': this.city,
            'State__c': this.state,
            'Duration_of_Current_Stay_Months__c': this.monthsDuration,
            'Duration_of_Current_Stay_years__c': this.yearsDuration,
            'Residence_Ownership_Type__c': this.typeOfResidence,
            'Id': this.addressId ? this.addressId : null
        }
        createAddress({ addressObj: JSON.stringify(addressObj), pincode: this.pincode, screenName: this.screenName })
            .then(result => {
                if (result) {
                    this.addressId = result;
                    console.log('address created successfully ', this.addressId);
                    const submitAddressEvent = new CustomEvent('submitaddressevent', {
                        detail: {
                            addressId: this.addressId
                        }
                    });
                    this.dispatchEvent(submitAddressEvent);
                }
            })
            .catch(error => {
                console.error(error);
            })


    }

    handleDurationSubmit() {
        this.yearsDuration = this.year;
        this.monthsDuration = this.month;
        this.createAddress();
        const submitdurationevent = new CustomEvent('submitdurationevent');
        this.dispatchEvent(submitdurationevent);
        this.showWheels = false;
    }

}