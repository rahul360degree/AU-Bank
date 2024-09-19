import { LightningElement, api } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';
import updateApplicant from '@salesforce/apex/AUSF_Utility.updateApplicant';
import updateLoanApplicationNumber from '@salesforce/apex/AUSF_CheckJourneyController.updateLoanApplicationNumber';



export default class Ausf_IPAScreenCmp extends LightningElement {

    screenName = 'IPA Screen';
    headerContents = 'Apply for Personal Loan';
    overallJourneySteps = 4;
    currentJourney = 1;
    stepsInCurrentJourney;
    currentStep;
    showContents = false;
    enableBackButton = false;
    footerText = '';
    applicationIdData = '';
    requestedLoanAmount;
    offeredLoanAmount;
    actualOfferedAmount;
    isHappyScreen = false
    //label vs image name ( in static resource)
    labelVsImageList = [{ label: "Vacation", value: "Vacation" }, { label: "Education", value: "Education" }, { label: "Marriage", value: "Marriage" }, { label: "Medical Needs", value: "Medicine" }, { label: "Others", value: "Other" }];
    showEmpTypeSelectionModal = false;
    empType;
    productType;
    performSubmitOperation = false;

    showLoader = true;
    purposeImgURL = Assets + '/AU_Assets/images/Vacation.png';
    background2URL = Assets + '/AU_Assets/images/Rectangle34624831.png';
    giftBoxURL = Assets + '/AU_Assets/images/Frame_1171281181.png';
    footerImgURL = Assets + '/AU_Assets/images/path3536.png';
    lightningIMGURL = Assets + '/AU_Assets/images/lightning.png';
    strokeIMGURL = Assets + '/AU_Assets/images/Stroke.png';


    @api loanApplicationId = 'a01C100000Gu3TSIAZ';
    @api applicantId='a02C1000002XUMLIA4';

    connectedCallback() {
        getCurrentScreenData({ loanApplicationId: this.loanApplicationId, applicantId: this.applicantId, screenName: this.screenName })
            .then(result => {
                console.log(result);

                let loanApplicationData = result.loanApplicationList ? result.loanApplicationList[0] : null;
                let applicantData = result.applicantList ? result.applicantList[0] : null;

                if (loanApplicationData) {
                    this.offeredLoanAmount = loanApplicationData.IPA_Offer_Amount__c;
                    this.actualOfferedAmount = loanApplicationData.IPA_Offer_Amount__c;
                    this.requestedLoanAmount = loanApplicationData.Loan_Amount__c;
                    this.isHappyScreen = this.offeredLoanAmount - this.requestedLoanAmount > 0 ? true : false;
                    this.offeredLoanAmount = '₹' + this.offeredLoanAmount.toLocaleString('en-IN');
                    this.requestedLoanAmount = '₹' + this.requestedLoanAmount.toLocaleString('en-IN');
                    this.applicationIdData = loanApplicationData.Name;
                    this.labelVsImageList.forEach(element => {
                        if (element.label == loanApplicationData.Purpose_of_Loan__c) {
                            this.purposeImgURL = Assets + '/AU_Assets/images/' + element.value + '.png'
                        }
                    });

                    this.productType = loanApplicationData.Pre_Approved_Offers__r && loanApplicationData.Pre_Approved_Offers__r.length > 0 && loanApplicationData.Pre_Approved_Offers__r[0].Product_Type__c;
                }

                let customTextList = result.screenCustomTextList ? result.screenCustomTextList : null;
                if (customTextList) {
                    customTextList.forEach(element => {
                        if (element.Label == 'Footer text') {
                            this.footerText = element.Custom_String__c;
                        }
                    });
                }

                this.showLoader = false;

            })
            .catch(error => {
                console.error(error);
            })
    }

    handleSubmitMethod() {
        if(this.productType && this.productType == 'BL' && !this.performSubmitOperation){
            this.showEmpTypeSelectionModal = true;
        }else if((this.productType && this.productType == 'PL') || this.performSubmitOperation){

            let loanApplcationObj = {
                'Id': this.loanApplicationId,
                'Last_visited_Page__c': this.screenName,
                'Loan_Amount__c': this.actualOfferedAmount
            }
    
            updateLoanApplication({ loanApplcationObj: JSON.stringify(loanApplcationObj), loanApplicationId: this.loanApplicationId, screenName: this.screenName })
                .then((result) => {
                    console.log(result, 'Loan Purpose Updated');
                    updateLoanApplicationNumber({ applicantId: this.applicantId })
                        .then(resp => {
                            console.log(resp, 'lead to loan updated');
                            if (resp && resp.msg) {
                                const nextEvent = new CustomEvent('submitevent', {
                                    detail: {
                                        currentScreen: this.screenName,
                                    }
                                });
                                this.dispatchEvent(nextEvent)
                            }
                        })
                })
                .catch((error) => {
                    console.error(error);
                });
        }
    }



    handleEmpTypeSelect(event) {
        this.showEmpTypeSelectionModal = false;
        if (event.detail != null && event.detail.empType != null) {
            this.empType = event.detail.empType;
            this.performSubmitOperation = true;

            let currentDate = new Date();

            let applicantObj = {
                'Id': this.applicantId,
                'Employment_Type__c': this.empType,
                'GST_Consent_Date_Time__c': currentDate ,
                'GST_Authentication_Consent_Date_time__c':currentDate
            }

            updateApplicant({ applicantObj: JSON.stringify(applicantObj), applicantId: this.applicantId, screenName: this.screenName })
            .then((result) => {
                console.log(result, 'Applicant Updated');
                this.handleSubmitMethod();
            })
            .catch(error => {
                console.error(error);
            });
        }
    }
}