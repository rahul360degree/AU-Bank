import { LightningElement, api, track } from 'lwc';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import getApplicationDetailsById from '@salesforce/apex/AUSF_Utility.getApplicationDetailsById';
import getActiveEmploymentDetailRecords from '@salesforce/apex/AUSF_ProfessionTypeScreenController.getActiveEmploymentDetailRecords';
import updateRemainingEmploymentDetailsRecords from '@salesforce/apex/AUSF_ProfessionTypeScreenController.updateRemainingEmploymentDetailsRecords';
import getEmploymentDetailRecordTypeMap from '@salesforce/apex/AUSF_Utility.getEmploymentDetailRecordTypeMap';
import createEmploymentDetails from '@salesforce/apex/AUSF_Utility.createEmploymentDetails';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';

const SEP = 'Self Employed Professional';
const SENP = 'Self Employed Non-Professional';


export default class Ausf_ProfessionTypeCmp extends LightningElement {
    // Generic Header Variables
    showLoader = false;
    showContent = false;
    screenName = 'Profession Type';
    headerContents = 'Apply for Personal Loan';
    headerDescription;
    @track stepsInCurrentJourney;
    @track currentStep;
    showContents = true;
    enableBackButton = true;
    showGeneric = false;

    // Screen variables
    @api loanApplicationId = 'a01C100000HPaHrIAL';
    @api applicantId = 'a02C1000002enDlIAI';

    title;
    subtitle;
    selectedMethod;
    isApi;
    proceedButtonFlag = false;
    isDIYJourney = false;
    employmentType;
    applicantNumber;
    activeEmploymentDetailId;

    @track instantVerificationArray;
    @track manualUploadArray;

    
    instantVerificationSEPArray = [];
    instantVerificationSENPArray = [];
    manualMethodsSEPArray = [];
    manualMethodsSENPArray = [];

    employmentDetailRecordTypeMap;
    empDetailRecordTypeName;
    isDisableAddressProceed() {
        return !this.proceedButtonFlag;
    }

    get addrModalBtnClass() {
        return this.isDisableAddressProceed() == true ? 'addrBtnDisabled' : 'addrButton';
    }

    handleVerificationMethodSelection(event) {

        let selectedMethodId = event.target.dataset.id;
        this.selectedMethod = event.target.dataset.name;
        this.isApi = true;

        this.instantVerificationArray = this.instantVerificationArray.map(method => {
            return {
                ...method,
                checked: +method.id === +selectedMethodId
            };
        });

        this.manualUploadArray = this.manualUploadArray.map(manualUpload => {
            return {
                ...manualUpload,
                checked: false
            };
        });

        this.proceedButtonFlag = true;

    }

    handleManualUploadSelection(event) {

        let selectedMannualUploadId = event.target.dataset.id;
        this.selectedMethod = event.target.dataset.name;
        this.isApi = false;
        this.manualUploadArray = this.manualUploadArray.map(manualUpload => {
            return {
                ...manualUpload,
                checked: +manualUpload.id === +selectedMannualUploadId
            };
        });

        this.instantVerificationArray = this.instantVerificationArray.map(method => {
            return {
                ...method,
                checked: false
            };
        });

        this.proceedButtonFlag = true;

    }

    // Set verification method array
    setVerificationMethodArray(customString, type) {
        if (customString) {
            let splitArray = customString.split(',');
            splitArray.forEach((value, index) => {
                this[type].push({
                    id: index,
                    name: value,
                    checked: false,
                    class: (index !== splitArray.length - 1) ? 'slds-grid slds-wrap Verification-Method Bottom-Border' : 'slds-grid slds-wrap Verification-Method'
                });
            });
        }
    }

    handleVerificationProceed() {
        // Proceed to next screen
        
        this.showLoader = true;
        this.showContent = false;
        //console.log(this.selectedMethod);
        //console.log('this.selectedMethod');
        this.updateRemainingEmpDetRecords();
        
    }

    createEmpDetailRecord() {
        let recordName;
        if (this.applicantNumber) {
            recordName = this.selectedMethod + ' - ' + this.applicantNumber;    
        } else {
            recordName = this.selectedMethod;
        }
        //console.log('rec -< ' + recordName);
        let employmentObj = {
            'Applicant__c': this.applicantId,
            'Name': recordName,
            'Active__c': true,
            'Id': this.activeEmploymentDetailId ? this.activeEmploymentDetailId : null,
            'Type_Verification__c':this.isApi?'API':'Manual Upload'
        }

        //console.log('employmentObj');
        //console.log(employmentObj);
        createEmploymentDetails({ employmentDetObj: JSON.stringify(employmentObj), screenName: this.screenName, recordTypeName: this.empDetailRecordTypeName })
            .then(result => {
                //console.log('result');
                //console.log(result);
                if (result) {
                    this.activeEmploymentDetailId = result;
                    //console.log('employmentd details created successfully ', this.activeEmploymentDetailId);
                    let loanApplcationObj = {
                        'Id': this.loanApplicationId,
                        'Last_visited_Page__c': this.screenName
                    }
                    updateLoanApplication({ loanApplcationObj: JSON.stringify(loanApplcationObj), loanApplicationId: this.loanApplicationId, screenName: this.screenName })
                    const nextEvent = new CustomEvent('submitevent', {
                        detail: {
                            currentScreen: this.screenName,
                            selectedMethod: this.selectedMethod,
                            isApi: this.isApi,
                            activeEmploymentDetailId: this.activeEmploymentDetailId
                        },
                        composed: true,
                        bubbles: true

                    });
                    this.dispatchEvent(nextEvent);
                    this.showLoader = false;
                    this.showGeneric = true;
                    this.showContent = false;
                }
            })
            .catch(error => {
                console.error(error);
            })
    }
    
    updateRemainingEmpDetRecords() {
        //console.log('CLICKED');
        //console.log('employmentDetailRecordTypeMap');
        //console.log(this.employmentDetailRecordTypeMap);
        this.empDetailRecordTypeName = this.employmentDetailRecordTypeMap[this.selectedMethod];
        //console.log('updateRemainingEmpDetRecords');
        updateRemainingEmploymentDetailsRecords({ applicantId: this.applicantId, recordType: this.empDetailRecordTypeName })
            .then(result => {
                //console.log('active Id -> ', result);
                this.activeEmploymentDetailId = result;
                this.createEmpDetailRecord();
                
            })
            .catch(error => {
                console.error(error);
            });
    }

    

    // Fetch screen data from metadata
    getScreenData = () => {
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
                        
                        if (element.Label === 'Profession Type Title') {
                            this.title = element.Custom_String__c;
                        } else if (element.Label === 'Profession Type Subtitle') {
                            this.subtitle = element.Custom_String__c;
                        } else if (element.Label === 'SENP Instant Verification Methods') {
                            this.setVerificationMethodArray(element.Custom_String__c, 'instantVerificationSENPArray');
                        } else if (element.Label === 'SENP Manual Upload Methods') {
                            this.setVerificationMethodArray(element.Custom_String__c, 'manualMethodsSENPArray');
                        } else if (element.Label === 'SEP Instant Verification Methods') {
                            this.setVerificationMethodArray(element.Custom_String__c, 'instantVerificationSEPArray');
                        } else if (element.Label === 'SEP Manual Upload Methods') {
                            this.setVerificationMethodArray(element.Custom_String__c, 'manualMethodsSEPArray');
                        }
                    });
                }
                let metadataToConsider = result.wizardDataDIYList ? result.wizardDataDIYList : result.wizardDataAssistedList ? result.wizardDataAssistedList : [];
                if (metadataToConsider && metadataToConsider.length > 0) {
                    this.stepsInCurrentJourney = parseInt(metadataToConsider[0].Overall_Step__c);
                    this.currentStep = parseInt(metadataToConsider[0].Progress_in_Current_Step__c);
                    this.headerDescription = metadataToConsider[0].Category__c;
                }
                this.getApplicationData();
            })
            .catch(error => {
                console.error(error);
            });
    }

    // Fetch Application details and screen info
    getApplicationData() {
        getApplicationDetailsById({ loanId: this.loanApplicationId, screenName: this.screenName })
            .then(result => {
                let journeyMode = result.loanApplicationList[0].Journey_Mode__c;
                journeyMode == 'DIY' ? this.isDIYJourney = true : this.isDIYJourney = false;
                this.employmentType = result.loanApplicationList[0].Applicants__r[0].Employment_Type__c;

                this.applicantNumber = result.loanApplicationList[0].Applicants__r[0].Name;

                if (this.employmentType === SENP) {
                    this.manualUploadArray = this.manualMethodsSENPArray;
                    this.instantVerificationArray = this.instantVerificationSENPArray
                } else if (this.employmentType === SEP) {
                    this.manualUploadArray = this.manualMethodsSEPArray;
                    this.instantVerificationArray = this.instantVerificationSEPArray
                }
                // this.showLoader = false;
                this.getExistingEmploymentData();
            })
            .catch(error => {
                console.error(error);
            });
    }


    // Fetched existing active employment data
    getExistingEmploymentData() {
        getActiveEmploymentDetailRecords({ 'applicantId': this.applicantId })
            .then(result => {
                let empDetail = result[0];
                

                if (empDetail) {

                    //console.log('emdetail -> ');
                    //console.log(empDetail);
                    let recordType = empDetail?.RecordType?.Name;
                    //console.log('recordType -> ');
                    //console.log(recordType);
                    let methodName;
                    for (let key in this.employmentDetailRecordTypeMap) {
                        if (this.employmentDetailRecordTypeMap[key] === recordType) {
                            methodName = key;
                            break;  // Exit the loop once the key is found
                        }
                    }

                    this.activeEmploymentDetailId = empDetail.Id;
                    let activeEmploymentDetail = methodName
                    this.selectedMethod = activeEmploymentDetail;
                    this.manualUploadArray = this.manualUploadArray?.map(manualUpload => {
                        return {
                            ...manualUpload,
                            checked: manualUpload.name === activeEmploymentDetail
                        };
                    });

                    this.instantVerificationArray = this.instantVerificationArray?.map(method => {
                        if (method.name === activeEmploymentDetail) {
                            this.isApi = true; 
                        }

                        return {
                            ...method,
                            checked: method.name === activeEmploymentDetail
                        };
                    });
                }
                this.proceedButtonFlag = true;
                this.showLoader = false;
                this.showContent = true;
            })
            .catch(error => {
                console.error(error);
            })
    }

    fetchEmpDetailRecordTypeData() {
        getEmploymentDetailRecordTypeMap()
            .then(result => {
                this.employmentDetailRecordTypeMap = result;
            })
            .catch(error => {
                console.error(error);
            });
    }

    handleBackReDirectParent() {

        const backEvent = new CustomEvent('backevent', {
            detail: {
                currentScreen: this.screenName,
                skipPrevious: false
            },
            composed: true,
            bubbles: true
        });
        this.dispatchEvent(backEvent);
    }

    connectedCallback() {
        this.showLoader = true;
        this.getScreenData();
        this.fetchEmpDetailRecordTypeData();
        // this.getApplicationData();
    }
}