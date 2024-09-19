import { LightningElement, api, track } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import rejectApplication from '@salesforce/apex/AUSF_CommunicationAddressController.rejectApplication';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication'
export default class Ausf_AddressDeclarationModalCmp extends LightningElement {
    @api loanApplicationId = '';
    @api applicantId = '';
    @api skipNext = false;
    @api screenName = '';

    crossSymbolImage = AU_Assets + '/AU_Assets/images/Outline/x.png';
    showLoader = false;


    @track PEP = {
        yesClass: 'Unselected',
        noClass: 'Selected',
        yesText: 'Yes',
        noText: 'No \u2713',
        flag: false,
    };

    @track NRI = {
        yesClass: 'Unselected',
        noClass: 'Selected',
        yesText: 'Yes',
        noText: 'No \u2713',
        flag: false,
    }

    toggleAnswer(event) {
        const questionType = event.target.dataset.question;
        const answerType = event.target.dataset.answer;
        const question = this[questionType];


        if (answerType === 'YES') {
            if (question.yesClass === 'Unselected') {
                question.noClass = 'Unselected';
                question.yesClass = 'Selected';
                question.yesText = 'Yes \u2713';
                question.noText = 'No';
                question.flag = true;
            } else {
                question.noClass = 'Selected';
                question.yesClass = 'Unselected';
                question.noText = 'No \u2713';
                question.yesText = 'Yes';
                question.flag = false;
            }
        } else if (answerType === 'NO') {
            if (question.noClass === 'Unselected') {
                question.yesClass = 'Unselected';
                question.noClass = 'Selected';
                question.noText = 'No \u2713';
                question.yesText = 'Yes';
                question.flag = false;
            } else {
                question.yesClass = 'Selected';
                question.noClass = 'Unselected';
                question.yesText = 'Yes \u2713';
                question.noText = 'No';
                question.flag = true;
            }
        }

    }

    /*
    PEPYesAnswerClass = 'Unselected';
    PEPNoAnswerClass = 'Selected';

    NRIYesAnswerClass = 'Unselected';
    NRINoAnswerClass = 'Selected';

    PEPYes = 'Yes';
    PEPNo = 'No \u2713';
    PEPFlag = false;

    NRIYes = 'Yes';
    NRINo = 'No \u2713';
    NRIFLag = false;

    changePEPYes() {
        if (this.PEPYesAnswerClass === 'Unselected') {
            this.PEPNoAnswerClass = 'Unselected'
            this.PEPYesAnswerClass = 'Selected';
            this.PEPYes = 'Yes \u2713';
            this.PEPNo = 'No';
            this.PEPFlag = true;
        } else {
            this.PEPNoAnswerClass = 'Selected';
            this.PEPYesAnswerClass = 'Unselected';
            this.PEPNo = 'No \u2713';
            this.PEPYes = 'Yes';
            this.PEPFlag = false;
        }
    }

    changePEPNo() {
        if (this.PEPNoAnswerClass === 'Unselected') {
            this.PEPYesAnswerClass = 'Unselected'
            this.PEPNoAnswerClass = 'Selected';
            this.PEPNo = 'No \u2713';
            this.PEPYes = 'Yes'
            this.PEPFlag = false;

        } else {
            this.PEPYesAnswerClass = 'Selected';
            this.PEPNoAnswerClass = 'Unselected';
            this.PEPYes = 'Yes \u2713';
            this.PEPNo = 'No';
            this.PEPFlag = true;
        }
    }

    changeNRIYes() {
        if (this.NRIYesAnswerClass === 'Unselected') {
            this.NRINoAnswerClass = 'Unselected'
            this.NRIYesAnswerClass = 'Selected';
            this.NRIYes = 'Yes \u2713';
            this.NRINo = 'No';
            this.NRIFLag = true;
        } else {
            this.NRINoAnswerClass = 'Selected';
            this.NRIYesAnswerClass = 'Unselected';
            this.NRINo = 'No \u2713';
            this.NRIYes = 'Yes';
            this.NRIFLag = false;
        }
    }

    changeNRINo() {
        if (this.NRINoAnswerClass === 'Unselected') {
            this.NRIYesAnswerClass = 'Unselected'
            this.NRINoAnswerClass = 'Selected';
            this.NRINo = 'No \u2713';
            this.NRIYes = 'Yes'
            this.NRIFLag = false;
        } else {
            this.NRIYesAnswerClass = 'Selected';
            this.NRINoAnswerClass = 'Unselected';
            this.NRIYes = 'Yes \u2713';
            this.NRINo = 'No';
            this.NRIFLag = true;
        }
    }
    */



    closeDeclarationModal() {
        // Send event to close modal
        const closeModalEvent = new CustomEvent('closemodalevent');
        this.dispatchEvent(closeModalEvent);

    }

    handleProceed() {
        if (this.PEP.flag) {
            // Reject application and show error screen
            rejectApplication({ applicationId: this.loanApplicationId, applicantId: this.applicantId, rejectionReason: 'PEP' })
                .then(result => {
                    const rejectEvent = new CustomEvent('rejectevent', {
                    });
                    this.dispatchEvent(rejectEvent);
                }).catch(error => {
                })
        } else if (this.NRI.flag) {
            // Reject application and show error screen
            rejectApplication({ applicationId: this.loanApplicationId, applicantId: this.applicantId, rejectionReason: 'NRI' })
                .then(result => {
                    const rejectEvent = new CustomEvent('rejectevent', {});
                    this.dispatchEvent(rejectEvent);
                }).catch(error => {
                })
        } else {
            // Proceed to next screen
            let loanApplcationObj = {
                'Id': this.loanApplicationId,
                'Last_visited_Page__c': this.screenName
            }

            updateLoanApplication({ loanApplcationObj: JSON.stringify(loanApplcationObj), loanApplicationId: this.loanApplicationId, screenName: this.screenName })
            .then((result) => {
                const nextEvent = new CustomEvent('submitevent', {
                    detail: {
                        currentScreen: this.screenName,
                        skipNext: this.skipNext
                    },
                    composed: true,
                    bubbles: true

                });
                this.dispatchEvent(nextEvent);
            })

        }
    }
}