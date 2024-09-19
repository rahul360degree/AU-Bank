import { LightningElement, track, api, wire } from 'lwc';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import getScreenDetails from '@salesforce/apex/AUSF_DIYUtility.getScreenDetails';
import checkForValidSessionWithScreen from '@salesforce/apex/AUSF_DIYUtility.checkForValidSessionWithScreen';
import getEncryptedId from '@salesforce/apex/AUSF_DIYUtility.getEncryptedId';
import checkValidRecordScreen from '@salesforce/apex/AUSF_DIYUtility.checkValidRecordScreen';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import isGuest from '@salesforce/user/isGuest';


export default class ausf_ParentContainerDIY extends NavigationMixin(LightningElement) {
    @api recordId
    @api currentScreenName
    @api firstPage = false;
    showLoading = false;
    isMobile = FORM_FACTOR == 'Small';
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
    cookieToBeCreate = false;
    @wire(CurrentPageReference)
    currentPageReference;
    isGuestUser = false;
    currentScreenOrder;
    nextScreenOrder;
    leadRecord;
    strAppJourney='';
    applicantRecord;
    blnExistingJourney = false;
    strExistingJourneyScreen = '';
    /* START -  AUPL-605 */
    strmobile_number = '';
    strCampaign_id = '';
    strCampaign_name = '';
    strUtm_source = '';
    strUtm_medium = '';
    strUtm_campaign = '';
    strUtm_content = '';
    strUtm_term = '';

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

    /* END -  AUPL-605 */


    connectedCallback() {
        this.showLoading = true;
        this.isGuestUser = isGuest;
        let sessionKey;
        if (this.isGuestUser && this.firstPage) {
            //MM this.deleteCookies('applicantVerifiedDetails','',-1);
        }
        if (this.isGuestUser) {
            sessionKey = this.getCookie('applicantVerifiedDetails');
            this.cookieToBeCreate = sessionKey ? false : true;
        }
        /*
        if (this.currentPageReference.state.leadId && this.currentPageReference.state.leadId != undefined && this.currentPageReference.state.leadId != '') {
            sessionKey = this.currentPageReference.state.leadId;
        }
        else */ 
        if (this.currentPageReference.state.appId && this.currentPageReference.state.appId != undefined && this.currentPageReference.state.appId != '') {
            sessionKey = this.currentPageReference.state.appId;
            this.deleteCookies('applicantVerifiedDetails','',-1);
        }
        else if (!this.isGuestUser && this.currentPageReference.state.Id) {
            this.recordId = this.currentPageReference.state.Id;
            //sessionKey = this.currentPageReference.state.appId;
        }
        else if (this.isGuestUser) {
            sessionKey = this.getCookie('applicantVerifiedDetails');
        }
        if (this.isGuestUser) {
            this.recordId = sessionKey ? sessionKey : '';
            if (this.firstPage == false && !sessionKey) {
                // Navigate to First Page with return url
            }
        }

        if (this.firstPage) {
            this.leadFromParam.strmobile_number = this.currentPageReference.state.MOBILE_NO ? this.currentPageReference.state.MOBILE_NO : '';
            this.leadFromParam.strCampaign_id = this.currentPageReference.state.campaign_id ? this.currentPageReference.state.campaign_id : '';
            this.leadFromParam.strCampaign_name = this.currentPageReference.state.campaign_name ? this.currentPageReference.state.campaign_name : '';
            this.leadFromParam.strUtm_source = this.currentPageReference.state.utm_source ? this.currentPageReference.state.utm_source : '';
            this.leadFromParam.strUtm_medium = this.currentPageReference.state.utm_medium ? this.currentPageReference.state.utm_medium : '';
            this.leadFromParam.strUtm_campaign = this.currentPageReference.state.utm_campaign ? this.currentPageReference.state.utm_campaign : '';
            this.leadFromParam.strUtm_content = this.currentPageReference.state.utm_content ? this.currentPageReference.state.utm_content : '';
            this.leadFromParam.strUtm_term = this.currentPageReference.state.Utm_term ? this.currentPageReference.state.Utm_term : '';
        }
        
            /*
        else if (!this.currentPageReference.state.appId || this.currentPageReference.state.appId == undefined || this.currentPageReference.state.appId == '') {
            sessionKey = this.getCookie('applicantVerifiedDetails');
        }
        */
        // Fetch Session and Page Navigation details from Server 
        checkForValidSessionWithScreen ({sessionKey : sessionKey, strCurrentScreen : this.currentScreenName, isGuestUser : this.isGuestUser, strRecordId : this.recordId, blnCheckExisting : this.currentScreenName == 'Check Journey' })
            .then(result => {
                this.checkLocalForValidSessionWithScreen(result, true, false);
            })
            .catch(error => {
                console.log('error... ', JSON.stringify(error.message));
                this.showLoading = false;
                this.showToast('Error', 'There is some error.', 'Error', 'dismissable');
            })
    }

    /* Assign the Record and Navigation details and dispatch to parent component */
    checkLocalForValidSessionWithScreen (result, isDispatchEvent, blnNavigatePage) {
        if (result.blnSuccess) {
            this.leadId = result.leadId;
            this.loanId = result.loanId;
            this.applicantId = result.applicantId;
            this.blnGotoNextPage = result.blnGotoNextPage;
            this.blnGoToPreviousPage = result.blnGoToPreviousPage;
            this.nextPageName = result.nextPageName;
            this.previousPageName = result.previousPageName;
            this.nextScreenName = result.nextScreenName;
            this.previousScreenName = result.previousScreenName;
            this.lastVisitedPage = result.lastVisitedPage ? result.lastVisitedPage : '';
            this.currentScreenOrder = result.currentScreenOrder;
            this.nextScreenOrder = result.nextScreenOrder;
            this.leadRecord = result.objLeadRecord;
            this.strAppJourney = result.strAppJourney;
            this.applicantRecord = result.objApplicant;
            this.blnExistingJourney = result.blnExistingJourney;
            this.strExistingJourneyScreen = result.currentScreenPageName;
            /* Mohit */
            if (this.currentScreenOrder > 60 && this.applicantRecord.IsActive__c == false) {
                // Don't do anything
            }
            else if (!this.firstPage && !this.leadId && !this.loanId) {
                // Commented for Now MM - this.navigateToPageMethod('LA_Start_Home__c');
            }
            else if (!isDispatchEvent && !this.firstPage && this.blnExistingJourney && this.lastVisitedPage && blnNavigatePage && this.currentScreenName == 'Check Journey' && this.strAppJourney == 'DIY') {
                this.createCookie('applicantVerifiedDetails',result.strSessionId);
                this.navigateToPageMethod (this.nextPageName);
            }
            else if (!isDispatchEvent && !this.firstPage && this.blnExistingJourney && this.lastVisitedPage && blnNavigatePage && this.currentScreenName == 'Check Journey' && this.strAppJourney != 'DIY') {
                this.createCookie('applicantVerifiedDetails',result.strSessionId);
                this.navigateToPageMethod ('LA_Thank_You__c');
            }
            else if (this.loanId && !isDispatchEvent && !this.firstPage && !this.blnExistingJourney && blnNavigatePage && this.currentScreenName == 'Check Journey' && this.strAppJourney == 'DIY') {
                this.createCookie('applicantVerifiedDetails',result.strSessionId);
                this.navigateToPageMethod (result.nextPageName);
            }
           /* else if (this.loanId && !isDispatchEvent && !this.firstPage && !this.blnExistingJourney && blnNavigatePage && this.currentScreenName == 'Check Journey' && this.strAppJourney == '') {
                this.createCookie('applicantVerifiedDetails',result.strSessionId);
                //this.navigateToPageMethod (result.nextPageName);
            }
                */
             
            /*
            if (this.leadId) {
                this.createCookie('applicantVerifiedDetails',this.leadId); 
                createCookies (this.leadId);
            }
            else if (this.loanId && !isDispatchEvent && !this.firstPage && !this.blnExistingJourney && !this.lastVisitedPage && blnNavigatePage && this.currentScreenName == 'Check Journey' && this.strAppJourney == 'DIY') {
                this.createCookie('applicantVerifiedDetails',this.loanId);
            }
            */
            // Fire custom event to parent
            else if (isDispatchEvent) {
                    if (result.strSessionId) {
                        this.createCookie('applicantVerifiedDetails',result.strSessionId);
                    }
                    const event = new CustomEvent('passtoparent', {
                    detail: {
                        byEventLeadId: this.leadId,
                        byEventRecordId: this.loanId,
                        byEventLoanId: this.loanId,
                        byEventApplicantId: this.applicantId,
                        byEventGoToNextPage: this.blnGotoNextPage,
                        byEventGoToPreviousPage: this.blnGoToPreviousPage,
                        byEventNextPageName: this.nextPageName,
                        byEventPreviousPageName: this.previousPageName,
                        byEventNextScreenName: this.nextScreenName,
                        byEventPreviousScreenName: this.previousScreenName,
                        byEventlastVisitedPage: this.lastVisitedPage,
                        byEventCurrentScreenOrder: this.currentScreenOrder,
                        byEventNextScreenOrder: this.nextScreenOrder,
                        byEventLeadRecord: this.leadRecord,
                        byEventJourneyMode: this.strAppJourney,
                        byEventApplicantRecord: this.applicantRecord,
                        byEventIsExistingJourney: this.blnExistingJourney,
                        byEventCurrentScreenPageName: this.strExistingJourneyScreen,
                        byEventLeadFromParam: this.leadFromParam

                    }
                });
                this.dispatchEvent(event);
            }
            
        }
        else if (!result.blnSuccess) {
            this.showLoading = false;
            // When session is expired
            if (result.blnSessionExpired) {
                this.showToast('Error', result.strMessage + ' Please try again.', 'Error', 'dismissable');
                this.deleteCookies('applicantVerifiedDetails','',null);
                this.navigateToPageMethod('LA_Start_Home__c');
            }
            // when OTP is already validated or Lead record deleted
            else if (result.blnOTPInvalid) {
                this.showToast('Error', result.strMessage, 'Error', 'dismissable');
                this.deleteCookies('applicantVerifiedDetails','',null);
                this.navigateToPageMethod('LA_Start_Home__c');
            }
            // For other unhandled exceptions
            else {
                this.showToast('Error', result.strMessage, 'Error', 'dismissable');
                this.deleteCookies('applicantVerifiedDetails','',null);
            }
            
        }
    }

    /* Retrieve current page cookies */
    @api getCookie(cookieName) {
        let cookieString = "; " + document.cookie;
        let splitArray = cookieString.split("; " + cookieName + "=");
        if (splitArray.length === 2) {
            return decodeURIComponent(splitArray.pop().split(";").shift());
        }
        console.log('In return null');
        return null;
    }

    /* Create Cookies method */
    createCookie(name, value) {
        var expires;
        expires = "; expires=" + -1;
        document.cookie = name + "=" + encodeURIComponent(value) + expires + "; path=/";
    }

    /*
    deleteCookie(cookieName) {
        this.deleteCookies(cookieName, '', -1null);
    }
    */

    /* Delete Existing cookies / Session */
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

    showToast(titleText, message, variant, mode) {
        const evt = new ShowToastEvent({
            title: titleText,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

    /* Called from other components to create cookies or navigation details recieved from main component */
    @api async handleCustomEvent(leadorloanId) {
        this.deleteCookies('applicantVerifiedDetails', '', -1);
        if (this.currentScreenName != 'Check Journey') {
            await getEncryptedId ({recordId : leadorloanId})
                .then(result => {
                    if (result.blnSuccess) {
                        this.createCookie('applicantVerifiedDetails',result.strSessionId);
                    }
                    else if (!result.blnSuccess) {
                        this.showToast('Error', result.strMessage, 'Error', 'dismissable');
                    }
                })
                .catch(error => {
                    console.log('error... ', JSON.stringify(error.message));
                    this.showLoading = false;
                    this.showToast('Error', 'There is some error.', 'Error', 'dismissable');
                })
        }
        else {
            await checkValidRecordScreen({strRecordId : leadorloanId, strCurrentScreen : this.currentScreenName, blnCheckExisting : this.currentScreenName == 'Check Journey'})
            .then(result => {
                this.checkLocalForValidSessionWithScreen (result, false, true);
            })
            .catch(error => {
                console.log('error... ', JSON.stringify(error.message));
                this.showLoading = false;
                this.showToast('Error', 'There is some error.', 'Error', 'dismissable');
            })
        }
    }

    /* Navigation Logic - for Next / Previous page */
    @api navigateToPageMethod (strNextPageName) {
        console.log('Current Screen ' + this.currentScreenName + ' to Page ' + strNextPageName);
        if (strNextPageName == 'Home') {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'LA_Start_Home__c'
                },
                state: {
                    
                }
            });
        }
        else {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: strNextPageName
                },
                state: {
                    
                }
            });
        }
    }
}