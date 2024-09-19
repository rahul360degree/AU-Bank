import { LightningElement, track, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import isGuest from '@salesforce/user/isGuest';

export default class Ausf_CheckJourneyDIY extends NavigationMixin(LightningElement) {
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
    strAppJourney='';
    blnExistingJourney = false;
    strExistingJourneyScreen = '';
    leadFromParam = {
        strLeadObject : {'sobjectType':'Lead_Stage__c'},
        strmobile_number : '',
        strCampaign_id : '',
        strCampaign_name : '',
        strUtm_source : '',
        strUtm_medium : '',
        strUtm_campaign : '',
        strUtm_content : '',
        strUtm_term : '',
        screenName : ''
    }
    

    connectedCallback() {
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
        let applicantRecord = event.detail.byEventApplicantRecord;
        this.mobileNumber = (this.leadRecord ? this.leadRecord.Name : (applicantRecord ? applicantRecord.Mobile_Number__c : ''));
        this.strAppJourney = event.detail.byEventJourneyMode;
        this.blnExistingJourney = event.detail.byEventIsExistingJourney;
        this.strExistingJourneyScreen = event.detail.byEventCurrentScreenPageName;
        this.leadFromParam = event.detail.byEventLeadFromParam;
        if (this.loanId && this.blnExistingJourney && this.strAppJourney == 'DIY') {
            this.handleNavigationMethod ('next',1);
        }
        else {
            this.blnLoadChild = true;
        }
        
        /*
        if (this.strAppJourney == 'DIY') {
            this.template.querySelector("c-ausf_-parent-container-d-i-y").navigateToPageMethod ('LA_Purpose_of_Loan__c');
        }
        else {
            this.blnLoadChild = true;
        }
        */

    }

    async handleNextScreenMethod(event){
        try {
            const eventData = event.detail;
            let currentScreen = eventData.currentScreen.split(' ').join('');
            let guestJourneyMode = eventData.guestJourneyMode;
            this.leadId = '';
            if (!this.loanId && eventData.loanAppId) {
                await this.handleLeadCreateEvent(eventData.loanAppId);
                /*
                if (!guestJourneyMode && this.strAppJourney == 'DIY') { 
                    this.handleNavigationMethod('next',1);
                }
                if (guestJourneyMode == 'DIY') { 
                    this.handleNavigationMethod('next',1);
                }
                */
                /*
                if (this.strAppJourney != 'DIY') {
                    this.template.querySelector("c-ausf_-parent-container-d-i-y").navigateToPageMethod ('LA_Purpose_of_Loan__c');
                }
                */
            }
            else if (!guestJourneyMode && this.strAppJourney == 'DIY') { 
                this.handleNavigationMethod('next',1);
            }
            else if (guestJourneyMode == 'DIY') { 
                this.handleNavigationMethod('next',1);
            }
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

    async handleLeadCreateEvent (loanAppId) {
        console.log('on handleRecordId ');
        await this.template.querySelector("c-ausf_-parent-container-d-i-y").handleCustomEvent (loanAppId);
    }
}