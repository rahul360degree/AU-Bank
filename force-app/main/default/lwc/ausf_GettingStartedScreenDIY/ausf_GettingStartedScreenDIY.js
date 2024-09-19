import { LightningElement, track, api } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';

export default class Ausf_GettingStartedScreenDIY extends LightningElement {
    @api recordId
    isMobile = FORM_FACTOR == 'Small';
    blnLoadChild = false;
    loanId = '';
    applicantId = '';
    blnGotoNextPage = false;
    blnGoToPreviousPage = false;
    nextPageName = '';
    previousPageName = '';
    nextScreenName = '';
    previousScreenName = '';

    connectedCallback() {
        console.log('Parent record Id ' + this.recordId);
    }

    handleFromChild(event) {
        console.log('Event ' + JSON.stringify(event));
        this.recordId = event.detail.byEventRecordId;
        this.loanId = event.detail.byEventRecordId;
        this.applicantId = event.detail.byEventApplicantId;
        this.blnGotoNextPage = event.detail.byEventGoToNextPage;
        this.this.blnGoToPreviousPage = event.detail.byEventGoToPreviousPage;
        this.nextPageName = event.detail.byEventNextPageName;
        this.previousPageName = event.detail.byEventPreviousPageName;
        this.nextScreenName = event.detail.byEventNextScreenName;
        this.previousScreenName = event.detail.byEventPreviousScreenName;
        console.log('From record Id ' + this.recordId);
        this.blnLoadChild = true;
    }

    handleNextScreenMethod(event){
        try {
            console.log('current screen on next ' + JSON.stringify(event));
            const eventData = event.detail;
            console.log(this.screenList);
            let currentScreen = eventData.currentScreen.split(' ').join('');
            console.log('current screen on next ' + currentScreen);
            this.handleNavigationMethod('next',1);
        } catch (error) {
            console.error(error);
        }
    }

    handleBackScreenMethod(event){
        console.log('current screen on back ' + JSON.stringify(event));
        const eventData = event.detail;
        let currentScreen = eventData.currentScreen.split(' ').join('');
        console.log('current screen on back ' + currentScreen);
        this.handleNavigationMethod('back',-1);

    }

    handleNavigationMethod (action, step) {
        console.log('Action -- ' + action + ' and step ' + step);
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
}