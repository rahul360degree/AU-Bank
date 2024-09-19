import { LightningElement, track, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import isGuest from '@salesforce/user/isGuest';

export default class Ausf_PurposeofLoanScreenDIY extends NavigationMixin(LightningElement) {
    @api recordId
    isMobile = FORM_FACTOR == 'Small';
    blnLoadChild = false;
    leadId = '';
    loanId = '';
    applicantId = '';
    blnGotoNextPage = false;
    blnGoToPreviousPage = false;
    nextPageName = '';
    previousPageName = '';
    nextScreenName = '';
    previousScreenName = '';
    lastVisitedPage = '';
    currentScreenOrder;
    nextScreenOrder;
    currentPageRecordId='';
    leadRecord;
    mobileNumber;
    

    connectedCallback() {
        /*
        if (isGuest) {
            this.currentPageRecordId = this.recordId;
        }
        */
        console.log('Parent record Id ' + this.recordId);
    }
    
    handleFromChild(event) {
        this.recordId = event.detail.byEventRecordId;
        this.leadId = event.detail.byEventLeadId;
        this.loanId = event.detail.byEventLoanId;
        this.applicantId = event.detail.byEventApplicantId;
        this.blnGotoNextPage = event.detail.byEventGoToNextPage;
        this.blnGoToPreviousPage = event.detail.byEventGoToPreviousPage;
        this.nextPageName = event.detail.byEventNextPageName;
        this.previousPageName = event.detail.byEventPreviousPageName;
        this.nextScreenName = event.detail.byEventNextScreenName;
        this.previousScreenName = event.detail.byEventPreviousScreenName;
        this.lastVisitedPage = event.detail.byEventlastVisitedPage;
        this.currentScreenOrder = event.detail.byEventCurrentScreenOrder;
        this.nextScreenOrder = event.detail.byEventNextScreenOrder;
        this.leadRecord = event.detail.byEventLeadRecord;
        this.mobileNumber = this.leadRecord ? this.leadRecord.Name : '';
        this.blnLoadChild = true;
    }

    handleNextScreenMethod(event){
        try {
            const eventData = event.detail;
            let currentScreen = eventData.currentScreen.split(' ').join('');
            if (!this.leadId && eventData.leadId) {
                // create Cookies
                // check recordId in html file
            }
            else if (!this.loanId && eventData.loanId) {
                // create Cookies
            }
            this.handleNavigationMethod('next',1);
        } catch (error) {
            console.error(error);
        }
    }

    handleBackScreenMethod(event){
        const eventData = event.detail;
        let currentScreen = eventData.currentScreen.split(' ').join('');
        this.handleNavigationMethod('back',-1);

    }

    handleNavigationMethod (action, step) {
        if (action == 'next') {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: this.nextPageName
                },
                state: {
                    
                }
            });
        }
        else if (action == 'back') {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: this.previousPageName
                },
                state: {
                    
                }
            });
        }
    }

    /*
    handleLeadCreateEvent (event) {
        console.log('on handleRecordId ' + JSON.stringify(event));
        if (this.currentScreenOrder == 10) {
            this.recordId = event.detail;
            const eventData = event.detail;
            this.template.querySelector("c-ausf_-parent-container-d-i-y").handleCustomEvent (eventData);
        }
    }
    */    
}