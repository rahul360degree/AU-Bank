import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import getCurrentScreenDataCatg from '@salesforce/apex/AUSF_Utility.getCurrentScreenDataCatg';
import getScreenCustomTextRecords from '@salesforce/apex/AUSF_Utility.getScreenCustomTextRecords';
import createEmploymentDetails from '@salesforce/apex/AUSF_Utility.createEmploymentDetails';
import createDocumentChecklistRec from '@salesforce/apex/AUSF_Utility.createDocumentChecklistRec';
import getGenericBuisnessMetadaData from '@salesforce/apex/AUSF_Utility.getGenericBuisnessMetadaData';
import getEmploymentDetail from '@salesforce/apex/AUSF_Utility.getEmploymentDetail'; // Import the Apex method
import invokeMethodForScreen from '@salesforce/apex/AUSF_Utility.invokeMethodForScreen'
export default class Ausf_genericBusinessVerificationApiCmp extends LightningElement {
    // Images
    GroupUrl = AU_Assets + '/AU_Assets/images/Group.png';
    AUDrivingLicenseImg = AU_Assets + '/AU_Assets/images/File_Upload.png';
    previewImg = AU_Assets + '/AU_Assets/images/eye.png';
    deleteImg = AU_Assets + '/AU_Assets/images/trash2.png';
    AUChevronRightImg = AU_Assets + '/AU_Assets/images/Outline/chevron-right.png';
    AUVectorImg = AU_Assets + '/AU_Assets/images/Vector_973.png';
    AUMaskGrpImg = AU_Assets + '/AU_Assets/images/Mask_group.svg';
    AUGrpImg = AU_Assets + '/AU_Assets/images/Group_1321314549.svg';
    AUErrorImg = AU_Assets + '/AU_Assets/images/warning_icon.png';

    // Header variables
    screenName = 'Profession Type';
    headerContents = 'Apply for Personal Loan';
    headerDescription;
    stepsInCurrentJourney;
    currentStep = 1;
    showContents = true;
    enableBackButton = true;
    labelValue;

    // Screen Variables
    title;
    subtitle;
    showLoader = true;
    dInputClass = 'phone-input';
    dInputLabel = 'phone-label';
    errorMessage = "Unable to verify your business details.\nPlease fill in manually.";

    // Screen variables
    @api loanApplicationId = 'a01C100000H80SUIAZ';
    @api applicantId = 'a02C1000002Wr01IAC';
    @api selectedMethod = 'ICSI Certificate';
    membershipNumber = '';
    @api employmentId = '';
    addressId;
    errorFromAPI = false;
    
    skipPrevious = false;



    get cnfButtonClassVar() {
        return this.disableSubmitBtn == true ? 'btnDisabled' : 'btnEnabled';
    }

    // Fetches initial data required when component loads 
    getInitialData() {
        this.showLoader = true;
        let screenName = this.selectedMethod;
        getGenericBuisnessMetadaData({ labelName: screenName })
            .then(result => {
                console.log('metadata result ', result);
                if (result) {
                    this.subtitle = result[0].Page_Sub_Title__c
                    this.title = result[0].Page_Title__c
                    this.labelValue = result[0].Doc_Number_Label__c;
                    this.getExistingData();
                }
            })
            .catch(error => {
                console.error(error);
            });
    }

    getExistingData() {
        // getEmploymentDetail({ applicantId: this.applicantId, recordName: this.employmentRecordName })
        //     .then((result) => {
        //         if (result && result.length > 0) {
        //             this.employmentDetId = result[0].Id; // Store the existing record ID
        //             this.addressId = result[0].Address__c;
        //             this.documentNumber = result[0].Document_Number__c ? result[0].Document_Number__c : '';
        //             this.dInputLabel = this.documentNumber ? 'phone-label-value' : 'phone-label';
        //             this.businessProofName = result[0].Others_Business_Proof_Name__c ? result[0].Others_Business_Proof_Name__c : '';
        //             this.businessLabel = this.businessProofName ? 'phone-label-value' : 'phone-label';
        //             this.dateOfIncorporation = result[0].Date_of_Incorporation__c ? this.formatDateForDisplay(result[0].Date_of_Incorporation__c) : '';
        //             this.DOBlabel = this.dateOfIncorporation ? 'phone-label-value' : 'phone-label';
        //             this.registeredBusinessName = result[0].Registered_Business_name__c ? result[0].Registered_Business_name__c : '';
        //             this.registeredLabel = this.registeredBusinessName ? 'phone-label-value' : 'phone-label';
        //             this.sector = result[0].Sector__c ? result[0].Sector__c : '';
        //             this.industry = result[0].Industry__c ? result[0].Industry__c : '';
        //             this.subIndustry = result[0].Sub_Industry__c ? result[0].Sub_Industry__c : '';
        //             this.activity = result[0].Activity__c ? result[0].Activity__c : '';
        //             this.disableSubmitBtn = false;
        //             // Populate fields array with the values
        //             this.fields = [
        //                 { label: 'Sector', name: 'Sector', selectedValue: this.sector, disabled: false, containerClass: 'field-container', hasSearch: false, labelClass: this.sector ? 'field-label has-value' : 'field-label' },
        //                 { label: 'Industry', name: 'Industry', selectedValue: this.industry, disabled: this.sector ? false : true, containerClass: this.industry ? 'field-container' : 'field-container disabled', hasSearch: true, labelClass: this.industry ? 'field-label has-value' : 'field-label' },
        //                 { label: 'Sub Industry', name: 'Sub_Industry', selectedValue: this.subIndustry, disabled: this.industry ? false : true, containerClass: this.subIndustry ? 'field-container' : 'field-container disabled', hasSearch: true, labelClass: this.subIndustry ? 'field-label has-value' : 'field-label' },
        //                 { label: 'Activity', name: 'Activity', selectedValue: this.activity, disabled: this.subIndustry ? false : true, containerClass: this.activity ? 'field-container' : 'field-container disabled', hasSearch: true, labelClass: this.activity ? 'field-label has-value' : 'field-label' }
        //             ];
        //         }
                
            //})
            
            // .catch((error) => {
            //     this.errorMsg = error.body.message;
            // });
            this.getScreenData();
    }

    getScreenData() {
        let dataJsonString = {
            'loanApplicationId': this.loanApplicationId,
            'applicantId': this.applicantId,
            'screenName': this.screenName,
        }
        getCurrentScreenDataCatg({ jsonString: JSON.stringify(dataJsonString) })
            .then(result => {
                console.log('result first ', result);
                let metadataToConsider = result.wizardDataDIYList ? result.wizardDataDIYList : result.wizardDataAssistedList ? result.wizardDataAssistedList : [];
                if (metadataToConsider && metadataToConsider.length > 0) {
                    this.stepsInCurrentJourney = parseInt(metadataToConsider[0].Overall_Step__c);
                    this.currentStep = parseInt(metadataToConsider[0].Progress_in_Current_Step__c);
                    this.headerDescription = metadataToConsider[0].Category__c;
                }
                this.showLoader = false;
            })
            .catch(error => {
                console.error(error);
            });
    }

    connectedCallback() {
        this.getInitialData();
    }
    handleSubmitMethod() {
        this.showLoader = true;
        console.log('number'+this.membershipNumber);
        let jsonString = {
            'applicantId': this.applicantId,
            'MembershipNo' : this.membershipNumber,
            'employmentId' : this.employmentId
        }
        invokeMethodForScreen({screenName:this.selectedMethod,jsonString:JSON.stringify(jsonString)})
            .then(returnResult => {
                //let returnResult = JSON.parse(result);

            if (returnResult) {
                this.showLoader = false;
                console.log(returnResult);
                //let returnResult = JSON.parse(result);
                console.log(returnResult.isSuccess);
                let isSuccess = returnResult.isSuccess
                this.employmentId = returnResult.employmentDetailId;
                this.addressId = returnResult.addressId;

                if (isSuccess) {
                    this.selectedMethod = this.selectedMethod.replace('Failure', 'Pass');
                    const apiverification = new CustomEvent('apiverification', {
                        detail: { apiSuccess: isSuccess, employmentId: returnResult.employmentDetailId, addressId: returnResult.addressId, selectedMethod: this.selectedMethod }
                    });
                    this.dispatchEvent(apiverification);
                } else {
                    this.errorFromAPI = true;
                }
            }
        }).catch(e=>{
            console.log(e);
        })
    }

    sendBackToParentContainer() {
        const apiverification = new CustomEvent('apiverification', {
            detail: { apiSuccess: false, employmentId: this.employmentId, addressId: this.addressId, selectedMethod: this.selectedMethod }
        });
        this.dispatchEvent(apiverification);
    }

    handleDocumentNumberInput(event) {
        this.membershipNumber = event.target.value;
        this.membershipNumber = this.membershipNumber.toUpperCase().replaceAll(' ', '');
        if (this.membershipNumber == '') {
            this.dInputClass = 'phone-input customDateInput';
            this.dInputLabel = 'phone-label';
        }
        else {
            this.dInputLabel = 'phone-label-value';
        }
        //this.handleAllInputValues();
    }

    handleBackReDirectParent() {
        // Skip Profession Type Selection Screen in Geenric Wizard
        if (this.selectedMethod == 'GST') {
            this.skipPrevious = true;
        }

        const backEvent = new CustomEvent('backevent', {
            detail: {
                currentScreen: this.screenName,
                skipPrevious: this.skipPrevious
            },
            composed: true,
            bubbles: true
        });
        this.dispatchEvent(backEvent);
    }
}