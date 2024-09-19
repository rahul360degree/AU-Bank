import { LightningElement, track, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import isGuest from '@salesforce/user/isGuest';

export default class Ausf_EnterMobileNumberScreenDIY extends NavigationMixin(LightningElement) {
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
    /* START -  AUPL-605 */
    /* strmobile_number = '';
    strCampaign_id = '';
    strCampaign_name = '';
    strUtm_source = '';
    strUtm_medium = '';
    strUtm_campaign = '';
    strUtm_content = '';
    strUtm_term = ''; */
    /* END -  AUPL-605 */
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
        if (isGuest) {
            this.currentPageRecordId = this.recordId;
            this.deleteCookies('applicantVerifiedDetails','',-1);
        }
    }
    
    renderedCallback(){
        if (isGuest) {
            this.deleteCookies('applicantVerifiedDetails','',-1);
        }
    }
    
    /* Event from Parent Component */
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
        this.strExistingJourneyScreen = event.detail.byEventCurrentScreenPageName;
        
        this.leadFromParam = event.detail.byEventLeadFromParam;
        /*
        this.leadFromParam.strmobile_number = event.detail.byEventMobile_number;
        this.leadFromParam.strCampaign_id = event.detail.byEventCampaign_id;
        this.leadFromParam.strCampaign_name = event.detail.byEventCampaign_name;
        this.leadFromParam.this.strUtm_source = event.detail.byEventUtm_source;
        this.leadFromParam.strUtm_medium = event.detail.byEventUtm_medium;
        this.leadFromParam.this.strUtm_campaign = event.detail.byEventUtm_campaign;
        this.leadFromParam.strUtm_content = event.detail.byEventUtm_content;
        this.leadFromParam.strUtm_term = event.detail.byEventUtm_term; */
        this.blnLoadChild = true;
    }

    /* Handle Navigation on Submit OTP */
    async handleNextScreenMethod(event){
        try {
            const eventData = event.detail;
            let currentScreen = eventData.currentScreen.split(' ').join('');
            await this.template.querySelector("c-ausf_-parent-container-d-i-y").handleCustomEvent (this.recordId);
            this.handleNavigationMethod('next',1);
        } catch (error) {
            console.error(error);
        }
    }

    /* handle Back Navigation */
    handleBackScreenMethod(event){
        const eventData = event.detail;
        let currentScreen = eventData.currentScreen.split(' ').join('');
        this.handleNavigationMethod('back',-1);

    }

    /* handle Navigation */
    handleNavigationMethod (action, step) {
        this.template.querySelector("c-ausf_-parent-container-d-i-y").getCookie('applicantVerifiedDetails');
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

    /* Event invoked by child component on Lead Creation */
    async handleLeadCreateEvent (event) {
        if (this.currentScreenOrder == 10) {
            this.recordId = event.detail;
            const eventData = event.detail;
            await this.template.querySelector("c-ausf_-parent-container-d-i-y").handleCustomEvent (eventData);
        }
        
    }   
    
    /* Delete Cookies */
    deleteCookies(name, value, days) {
        var expires;
        if (days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            expires = "; expires=" + date.toGMTString();
        }
        else {
            expires = "";
        }
        document.cookie = name + "=" + value + expires + ";path=/";
    }
}