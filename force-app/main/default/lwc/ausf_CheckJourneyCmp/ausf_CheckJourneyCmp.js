import { LightningElement,api,wire } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';
import isguest from '@salesforce/user/isGuest';

import getDedupeResult from '@salesforce/apex/AUSF_CheckJourneyController.getDedupeResult';
import createNewJourneyRecords from '@salesforce/apex/AUSF_CheckJourneyController.createNewJourneyRecords';
import getApplicationDetails from '@salesforce/apex/AUSF_Utility.getApplicationDetails';
import updateLeadStage from '@salesforce/apex/AUSF_Utility.updateLeadStage';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';
import deleteLeadStage from '@salesforce/apex/AUSF_Utility.deleteLeadStage';
import sendAllNotification from '@salesforce/apex/AUSF_NotificationController.sendAllNotification';


export default class Ausf_CheckJourneyCmp extends LightningElement {

    screenName = 'Check Journey';
    headerContents = 'Apply for Personal Loan';
    showContents = false;

    @api mobileNumber;
    isGuestUser = isguest;
    // isGuestUser = true;
    showLoader = true;
    errorScreen = false;
    openconsentModal = false;
    showConsentBtn = true;
    thankyouScreen = false;
    errorScreenContents;
    assistUserName;
    assistUserId;
    greentickImgURL = Assets + '/AU_Assets/images/tick-circle.png';
    consentIMGURL = Assets + '/AU_Assets/images/Group_1234.png';
    relatedLeadId;
    loanApplicationId;
    applicantId;
    dedupeResultData;
    applicationData;


    connectedCallback(){

        getApplicationDetails({phoneNumber:this.mobileNumber,screenName:this.screenName})
        .then(result=>{
            if(result){
                console.log(result);
                this.relatedLeadId = result.leadStageList && result.leadStageList.length > 0 ? result.leadStageList[0].Id : null;
                this.loanApplicationId = result.loanApplicationList && result.loanApplicationList.length > 0 ? result.loanApplicationList[0].Id : null;
                this.applicantId = this.loanApplicationId ?  result.loanApplicationList[0].Applicants__r[0].Id : null;
                this.applicationData = result;
                let relatedLeadStage = result.leadStageList && result.leadStageList.length > 0 ? result.leadStageList[0] : null;
                this.assistUserName = relatedLeadStage ?  relatedLeadStage.CreatedBy.Salutation__c ? relatedLeadStage.CreatedBy.Salutation__c + ' ' + relatedLeadStage.CreatedBy.FirstName : relatedLeadStage.CreatedBy.FirstName : '';
                this.assistUserId = relatedLeadStage ? relatedLeadStage.CreatedById : null

                if(!this.loanApplicationId){
                    getDedupeResult({mobileNumber:this.mobileNumber})
                    .then(result=>{
                        console.log(JSON.stringify(result),JSON.stringify(result.dedupeResult),JSON.stringify(result.dedupeResult[this.mobileNumber]));
                        let dedupeResult = result.dedupeResult[this.mobileNumber];
                        this.dedupeResultData = dedupeResult;
                        this.handleDedupeStatus(dedupeResult,relatedLeadStage);
            
                    })
                    .catch(error=>{
                        console.error(error);
                    })
                }else{
                    let loanApp = this.applicationData.loanApplicationList[0];  
                    if(loanApp && loanApp.Stage__c && loanApp.Stage__c =='Reject'){
                        this.showLoader = false;
                        this.errorScreenContents = 'Lead has been rejected with following params: ' +
                        'Name: ' + (loanApp.Name ? loanApp.Name : '' )+ ', ' +
                        'Branch: ' + (loanApp.Branch__c ? loanApp.Branch__c : '') + ', ' +
                        'Reference Number: ' + (loanApp.Lead_reference_number__c ? loanApp.Lead_reference_number__c : '') + ', ' +
                        'SO Name: ' + (loanApp.SO_Name__c ? loanApp.SO_Name__c : '') + ', ' +
                        'SO Employee Id: ' + (loanApp.SO_Employee_Id__c ? loanApp.SO_Employee_Id__c : '') + ', ' +
                        'Stage: ' + (loanApp.Stage__c ? loanApp.Stage__c : '');
                        this.errorScreen = true;
                    }else{
                        if (this.isGuestUser && loanApp.Journey_Mode__c == 'Assisted') {
                            this.showConsentBtn = false;
                            this.thankyouScreen = true;
                            this.showLoader = false;
                        }
                        else {
                            deleteLeadStage({leadId:this.relatedLeadId,screenName:this.screenName})
                            .then(response=>{
                                if(response){
                                    try {
                                        console.log('lead deleted on second run',loanApp);
                                        const nextEvent = new CustomEvent('submitevent', {
                                            detail: {
                                                currentScreen: loanApp.Last_visited_Page__c ? loanApp.Last_visited_Page__c : this.screenName,
                                                loanAppId:loanApp.Id,
                                                applicantId:loanApp.Applicants__r[0].Id,
                                                guestJourneyMode: loanApp.Journey_Mode__c ? loanApp.Journey_Mode__c : null, // MM
                                                refreshData:true
                                            }
                                        });
                                        console.log(JSON.stringify(nextEvent));
                                        this.dispatchEvent(nextEvent)
                                    } catch (error) {
                                        console.error(error);
                                    }
                                }
                            })
                            .catch(error=>{
                                console.error(error);
                            })
                        }
                    }
                }
            }
        })
        .catch(error=>{
            console.error(error);
        })
    }

    handleDedupeStatus(dedupeResult,relatedLeadStage){
        let loanApp;
        if(dedupeResult.dedupeStatus && dedupeResult.dedupeStatus == 'New' && !this.loanApplicationId){
                        
            createNewJourneyRecords({mobileNumber:this.mobileNumber})
            .then(result=>{
                console.log(JSON.stringify(result));
                if(result.dataWrapper){
                    loanApp = result.dataWrapper.newLoanApplications[0];
                    this.applicantId = result.dataWrapper.newApplicants[0].Id; // MM
                    if(relatedLeadStage && (!relatedLeadStage.Journey_Mode__c || relatedLeadStage.Journey_Mode__c != 'DIY')  && this.isGuestUser){
                        //stamp loan Id on lead 
                        let leadObj = {
                            'Id': this.relatedLeadId,
                            'Loan_Application__c': loanApp.Id,
                        }
                        
                        updateLeadStage({leadObj:JSON.stringify(leadObj),leadId:this.relatedLeadId,screenName:this.screenName})
                        .then((result) => {
                            console.log(result,'Lead Updated with loan App Updated');
                            this.loanApplicationId = loanApp.Id; // MM
                            this.showConsentBtn = true;
                            this.thankyouScreen = true;
                            this.showLoader = false;
                        })
                        .catch((error) => {
                            console.error(error);
                        });
                    }else{
                        deleteLeadStage({leadId:this.relatedLeadId,screenName:this.screenName})
                        .then(response=>{
                            if(response){
                                let loanObj = {
                                    'Id': loanApp.Id,
                                    'Journey_Mode__c':'DIY',
                                }
                          
                                updateLoanApplication({loanApplcationObj:JSON.stringify(loanObj),loanApplicationId:this.loanApplicationId,screenName:this.screenName})
                                .then((rstUpdateLoan) => {
                                    console.log(rstUpdateLoan,'Loan Journey Updated');
                                    this.showConsentBtn = false;

                                    const nextEvent = new CustomEvent('submitevent', {
                                        detail: {
                                            currentScreen: this.screenName,
                                            loanAppId:loanApp.Id,
                                            applicantId:result.dataWrapper.newApplicants[0].Id,
                                            guestJourneyMode: 'DIY' // MM
                                        }
                                    });
                                    console.log('event fired with details',JSON.stringify(nextEvent));
                                    this.dispatchEvent(nextEvent);

                                })
                                .catch((error) => {
                                    console.error(error);
                                });
                                /* MM
                                const nextEvent = new CustomEvent('submitevent', {
                                    detail: {
                                        currentScreen: this.screenName,
                                        loanAppId:loanApp.Id,
                                        applicantId:result.dataWrapper.newApplicants[0].Id,
                                        guestJourneyMode: 'DIY' // MM
                                    }
                                });
                                console.log('event fired with details',JSON.stringify(nextEvent));
                                this.dispatchEvent(nextEvent)
                                */
                            }
                        })
                        .catch(error=>{
                            console.error(error);
                        })
                    }
                }
            })
            .catch(error=>{
                console.error(error);
            })
        }
        /* MM Start */
        if(dedupeResult.dedupeStatus && dedupeResult.dedupeStatus == 'New' && this.loanApplicationId){
            if(relatedLeadStage && (!relatedLeadStage.Journey_Mode__c || relatedLeadStage.Journey_Mode__c != 'DIY')  && this.isGuestUser){
                deleteLeadStage({leadId:this.relatedLeadId,screenName:this.screenName})
                    .then(response=>{
                        if(response){
                            let loanObj = {
                                'Id': this.loanApplicationId,
                                'Journey_Mode__c':'DIY',
                            }
                            updateLoanApplication({loanApplcationObj:JSON.stringify(loanObj),loanApplicationId:this.loanApplicationId,screenName:this.screenName})
                            .then((result) => {
                                console.log(result,'Loan Journey Updated');
                                this.showConsentBtn = false;
                            })
                            .catch((error) => {
                                console.error(error);
                            });
                            const nextEvent = new CustomEvent('submitevent', {
                                detail: {
                                    currentScreen: this.screenName,
                                    loanAppId:this.loanApplicationId,
                                    applicantId:this.applicantId,
                                    guestJourneyMode: 'DIY' // MM
                                }
                            });
                            this.dispatchEvent(nextEvent)
                        }
                    })
                    .catch(error=>{
                        console.error(error);
                    })
            }
        }
        /* MM End */
        else if(dedupeResult.dedupeStatus && dedupeResult.dedupeStatus == 'Resume'){
            loanApp = dedupeResult.existingLoanApplication;
            if(relatedLeadStage && (loanApp.Journey_Mode__c && loanApp.Journey_Mode__c != 'DIY')  && this.isGuestUser){
                //stamp loan Id on lead 
                let leadObj = {
                    'Id': this.relatedLeadId,
                    'Loan_Application__c': loanApp.Id
                }
          
                updateLeadStage({leadObj:JSON.stringify(leadObj),leadId:this.relatedLeadId,screenName:this.screenName})
                .then((result) => {
                    console.log(result,'Lead Updated with loan App Updated');
                    // this.showConsentBtn = true;
                    this.thankyouScreen = true;
                    this.showLoader = false;
                })
                .catch((error) => {
                    console.error(error);
                });
            }else{

                deleteLeadStage({leadId:this.relatedLeadId,screenName:this.screenName})
                .then(response=>{
                    if(response){
                        const nextEvent = new CustomEvent('submitevent', {
                            detail: {
                                currentScreen: loanApp.Last_visited_Page__c ? loanApp.Last_visited_Page__c : this.screenName,
                                loanAppId:loanApp.Id,
                                applicantId:loanApp.Applicants__r[0].Id,
                                guestJourneyMode: loanApp.Journey_Mode__c // MM
                            }
                        });
                        this.dispatchEvent(nextEvent)

                        this.loanApplicationId = loanApp.Id;
                    }
                })
                .catch(error=>{
                    console.error(error);
                })
            }
        }else if(dedupeResult.dedupeStatus && dedupeResult.dedupeStatus == 'Reject'){
            this.showLoader = false;
            this.errorScreenContents = dedupeResult.message;
            this.errorScreen = true;
        }else if(dedupeResult.dedupeStatus && dedupeResult.dedupeStatus == 'Disbursed'){
            this.showLoader = false;
            this.errorScreenContents = dedupeResult.message;
            this.errorScreen = true;
        }else if(dedupeResult.dedupeStatus && dedupeResult.dedupeStatus == 'Cancelled'){
            this.showLoader = false;
            this.errorScreenContents = dedupeResult.message;
            this.errorScreen = true;
        }
    }

    handleConsentBtn(){
        let leadObj = {
            'Id': this.relatedLeadId,
            'Journey_Mode__c':'Assisted',
            'Loan_Application__r.Journey_Mode__c':'Assisted'
        }
  
        updateLeadStage({leadObj:JSON.stringify(leadObj),leadId:this.relatedLeadId,screenName:this.screenName})
        .then((result) => {
            console.log(result,'Lead Journey Updated');
            this.showConsentBtn = false;
        })
        .catch((error) => {
            console.error(error);
        });

        if(this.loanApplicationId){
            let loanObj = {
                'Id': this.loanApplicationId,
                'Journey_Mode__c':'Assisted',
            }
      
            updateLoanApplication({loanApplcationObj:JSON.stringify(loanObj),loanApplicationId:this.loanApplicationId,screenName:this.screenName})
            .then((result) => {
                console.log(result,'Loan Journey Updated');
                    if(this.assistUserId){
                        sendAllNotification({objApp:null,objLoan:null,applicantId:null,loanId:this.loanApplicationId,strTriggerPoint:'Customer_Selected_Assisted_Journey',toUserId:this.assistUserId})
                        .then(result=>{
                            if(result){
                                console.log(result,'sent notification');
                                this.showConsentBtn = false;
                            }
                        })
                        .catch(error=>{
                            console.error(error);
                        })
                    }
            })
            .catch((error) => {
                console.error(error);
            });
        }
    }

    handleDIY(){
        let leadObj = {
            'Id': this.relatedLeadId,
            'Journey_Mode__c':'DIY',
        }
  
        updateLeadStage({leadObj:JSON.stringify(leadObj),leadId:this.relatedLeadId,screenName:this.screenName})
        .then((result) => {
            console.log(result,'Lead Journey Updated');
            this.showConsentBtn = false;
        })
        .catch((error) => {
            console.error(error);
        });

        if(this.loanApplicationId){
            let loanObj = {
                'Id': this.loanApplicationId,
                'Journey_Mode__c':'DIY',
            }
      
            updateLoanApplication({loanApplcationObj:JSON.stringify(loanObj),loanApplicationId:this.loanApplicationId,screenName:this.screenName})
            .then((result) => {
                console.log(result,'Loan Journey Updated');
                this.showConsentBtn = false;
            })
            .catch((error) => {
                console.error(error);
            });
        }
        
        this.handleDedupeStatus(this.dedupeResultData, 'DIY'); // MM 
    }
}