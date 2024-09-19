/**
 * @description       : 
 * @author            : Charchit Nirayanwal
 * @group             : 
 * @last modified on  : 20-07-2024
 * @last modified by  : Charchit Nirayanwal
 * @Jira Story        : APL-661
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   20-07-2024  Charchit Nirayanwal  Initial Version
**/

import { LightningElement, api } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import cfrCheck from '@salesforce/apex/AUSF_CFRCheck.checkCFR';
import amlApi from '@salesforce/apex/AUSF_AMLController.doAML';
import hunterApi from '@salesforce/apex/AUSF_HunterAPIController.callHunterApi';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import getBreResponse from '@salesforce/apex/AUSF_INT_BRE_Controller.getBreResponse';
import getICRecords from '@salesforce/apex/AUSF_Utility.getICRecords';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';




export default class Ausf_fraudCheckCmp extends LightningElement {

    loaderAnimationJSONSrc = AU_Assets + '/AU_Assets/PL_Animations/BRE_Loader/BRE_Loader.json';
    loaderAnimationJSON = '';

    screenName = 'Fraud Check Screen';
    headerContents = 'Apply for Personal Loan';
    showContents = false;
    showAnimation = false;
    icName;
    showErrorScreen = false;
    showRetry = false;
    functionalRetryCount;
    technicalRetryAfter;
    maxIntervalValue;
    beyondThreshold = false;
    showRejectScreen=false;

    @api applicantId = ''
    @api loanApplicationId = ''


    loanApplicationData
    applicantData

    headingLabel = 'Processing your application';
    messagelabel = 'We are collecting and verifying all your details to offer the best loan limit';

    connectedCallback() {
        try {
            var loader = new XMLHttpRequest();
            loader.open("GET", this.loaderAnimationJSONSrc);
            loader.onload = () => {
                this.showAnimation = true;
                this.loaderAnimationJSON = loader.responseText;
            }
            loader.send(null);

            this.checkData();

        } catch (error) {
            console.error(error);
        }
    }

    async handleFraudCheckCallout() {
        if (this.applicantData != null) {
            if (this.applicantData.CFR_Check__c == null) {
                this.cfrCheckRes = await cfrCheck({ applicantId: this.applicantId, loanApplicationId: this.loanApplicationId });
                console.log('Api Response CFR -->', this.cfrCheckRes)

                if (this.cfrCheckRes == null) {
                    this.showErrorScreen = true;
                }
                else if (this.cfrCheckRes == true) {
                    console.log("CFR TRUE REJECT");
                    this.showRejectScreen = true;
                    return;
                }
            }
            else if (this.applicantData.CFR_Check__c == 'True') {
                console.log("CFR TRUE REJECT");
                this.showRejectScreen = true;
                return;
            }

            if (this.applicantData.AML_verified__c == null) {
                this.amlApiRes = await amlApi({ loanId: this.loanApplicationId, applicantId: this.applicantId });
                console.log('API Response AML -->', this.amlApiRes);

                if (this.amlApiRes != null && !this.amlApiRes.blnSuccess) {
                    this.showErrorScreen = true;
                    this.errorMessage = this.amlApiRes.errorMessage;
                    return;
                }
                else if (this.amlApiRes.strAMLStatus == "Rejected") {
                    // Reject Screen
                    this.showRejectScreen = true;
                    console.log("AML Not Approved REJECT")
                    return;
                }
            }
            if (this.applicantData.AML_verified__c == 'Yes') {
                this.showRejectScreen = true;
                console.log("AML Not Approved REJECT")
                return;
            }

            // Call the second API and wait for the response

            if (this.applicantData.Hunter_Status__c == null) {
                this.hunterApiRes = await hunterApi({ applicantId: this.applicantId });
                console.log('API Response hunter -->', this.hunterApiRes);

                if (this.hunterApiRes != null && !this.hunterApiRes.blnSuccess) {
                    this.showErrorScreen = true;
                    this.errorMessage = this.amlApiRes.hunterApiRes;
                    return;
                }
                else if (this.hunterApiRes.hunterStatus == "Match Found") {
                    this.showRejectScreen = true;
                    console.log("Hunter Not Approved REJECT")
                    return;
                }
            }
            else if (this.applicantData.Hunter_Status__c == "Match Found") {
                this.showRejectScreen = true;
                console.log("Hunter Not Approved REJECT")
                return;
            }

            // this.getIntegrationChecklistRecords();

            

            let loanApplcationObj = {
                'Id': this.loanApplicationId,
                'Last_visited_Page__c': this.screenName
            }

            updateLoanApplication({ loanApplcationObj: JSON.stringify(loanApplcationObj), loanApplicationId: this.loanApplicationId, screenName: this.screenName })
                .then((result) => {
                    const nextEvent = new CustomEvent('submitevent', {
                        detail: {
                            currentScreen: this.screenName,
                        }
                    });
                    this.dispatchEvent(nextEvent)
                    return 'SUCCESS'
                })
                .catch((error) => {
                });


        }
    }

    async getIntegrationChecklistRecords(){
        let latestICList = await getICRecords({masterName:this.icMasterName,loanApplication:this.loanApplicationId,screenName:this.screenName})

        console.log(latestICList);
        if(latestICList && latestICList.length > 0){
            console.log('BRE was triggered');
            this.isResumeJourney = true;
            await this.checkBREResponse();
        
            console.log('foundResponse before counter',this.foundResponse);
            
            // setTimeout(() => {
                console.log('foundResponse after counter',this.foundResponse);

                if(!this.foundResponse){
                    let technicalFailures = latestICList.filter(ic=>{
                        return ic.Failure_Type__c == 'Technical';
                    })
                    let functionalFailures = latestICList.filter(ic=>{
                        return ic.Failure_Type__c == 'Functional';
                    })
                    console.log(this.technicalRetryAfter,this.technicalRetryCount,this.functionalRetryCount,technicalFailures,functionalFailures,this.technicalRetryAfter && this.technicalRetryCount > technicalFailures.length);
                    let icRecord = latestICList[0];
                    let icCreatedDate = new Date(icRecord.CreatedDate);
                    //logic of re trigger api after technical retry delay incase of technical failure also check for max retry
                    if(this.technicalRetryAfter && this.technicalRetryCount > technicalFailures.length){
                        let thresholdDelayTime = new Date(icCreatedDate.getTime() + (parseInt(this.technicalRetryAfter)));
                        if(thresholdDelayTime < new Date()){
                            this.handleBREApiCallout();
                        }
                    }else if(technicalFailures.length >= this.technicalRetryCount){
                        let loanApplcationObj = {
                            'Id': this.loanApplicationId,
                            'Stage__c':'Drop-Off'
                        }
                        updateLoanApplication({loanApplcationObj:JSON.stringify(loanApplcationObj),loanApplicationId:this.loanApplicationId,screenName:this.screenName})
                        .then((result) => {
                            console.log(result,'Stage Drop off');   
                            this.showErrorScreen = true;
                        })
                        .catch((error) => {
                            console.error(error);
                        });
                    }
                }
            // }, 2000);
            // functional retry mechanism needs to be done
        }else{
            console.log('BRE did not triggered');
            // invoke BRE callout
            this.handleBREApiCallout();
        }
    }

    async handleBREApiCallout(){
        //actual method signature needs to be put.
        await createIntegrationChecklistRecord({strMasterName:'FICO KNOCKOUT BRE',strObject:'Loan_Application__c',strRecordId:this.loanApplicationId})
        .then(icResponse=>{
            console.log(icResponse);
            if(icResponse && icResponse.blnSuccess && icResponse.objIC){
                getBreResponse({loanId:this.loanApplicationId,callType:'DP_KNOCKOUT',icRecordId:icResponse.objIC.Id})
                .then(breResposne=>{
                    this.isResumeJourney = false;
                    console.log(breResposne);
                    if(breResposne && breResposne.blnSuccess){
                        console.log('waiting for BRE response');
                    }
                    let intervalValue = 5000;
                    let timer = 0;
                    // this.isResumeJourney = true;
                    console.log(this.maxPollerIntervalValue,this.isResumeJourney,this.staticIntervalValue);
                    if(this.maxPollerIntervalValue && !this.isResumeJourney){
                        const checkStatus = setInterval((() => {
                            if(timer > this.staticIntervalValue){
                                this.beyondThreshold = true;
                            }
                            if(timer <= this.maxPollerIntervalValue){
                                timer+=intervalValue;
                                console.log(timer);
                                this.checkBREResponse(checkStatus);
                            }
                        }), intervalValue);
                        console.log(this.beyondThreshold);
                    }
                })
                .catch(error=>{
                    console.error(error);
                })
            }

        })
        .catch(error=>{
            console.error(error);
        })
    }

    async checkBREResponse(interval){
        await checkBREIPAResponse({masterName:this.icMasterName,loanApplication:this.loanApplicationId,screenName:this.screenName})
        .then(resp=>{
            console.log(resp,'found IPA result',interval);
            if(resp && resp.length > 0){
                this.foundResponse = true;
                console.log(this.isResumeJourney);
                let loanAppStatus = resp[0].Loan_Application__c ? resp[0].Loan_Application__r.Stage__c : null;
                if(loanAppStatus && loanAppStatus == 'Reject'){
                    if(interval){
                        clearInterval(interval);
                    }
                    this.showErrorScreen = true;

                }else if(!this.isResumeJourney && resp[0].BRE_Decision__c && resp[0].BRE_Decision__c == 'FAILED'){
                    this.errorFromAPI = true;
                    if(interval){
                        clearInterval(interval);
                    }
                }else if(resp[0].BRE_Decision__c && resp[0].BRE_Decision__c != 'FAILED'){
                    if(interval){
                        clearInterval(interval);
                    }
                    console.log('here');
                    const nextEvent = new CustomEvent('submitevent', {
                        detail: {
                            currentScreen: this.screenName,
                            skipNext : this.skipNext,
                            doBackendOperation : this.skipNext ? true : null
                        },
                        bubbles:true,
                        composed:true
                    });
                    this.dispatchEvent(nextEvent);
                    console.log('dispatched');
                }
                console.log('execution finished');

            }
        })
        .catch(error=>{
            console.error(error);
        })
    }


    async checkData() {

        getCurrentScreenData({ loanApplicationId: this.loanApplicationId, applicantId: this.applicantId, screenName: this.screenName })
            .then(result => {
                console.log("Loan Info--->", result);

                this.loanApplicationData = result.loanApplicationList ? result.loanApplicationList[0] : null; // get the stage and if its rejected show rejected screen
                this.applicantData = result.applicantList ? result.applicantList[0] : null; // use this to check the status for CFR, AML, Hunter CFR is Done  -> aml -> onhold/approved -> hunter api -> hold/ approved

                let customTextList = result.screenCustomTextList ? result.screenCustomTextList : null;
                if (customTextList) {
                    customTextList.forEach(element => {
                        if (element.Label == 'Functional Retries') {
                            this.functionalRetryCount = parseInt(element.Custom_String__c);
                        } else if (element.Label == 'Technical Retry After') {
                            this.technicalRetryAfter = parseInt(element.Custom_String__c);
                        } else if (element.Label == 'Max Interval Value') {
                            this.maxIntervalValue = parseInt(element.Custom_String__c);
                        }
                    });
                }

                let loanAppStatus = this.loanApplicationData ? this.loanApplicationData.Stage__c : null;
                if(loanAppStatus && loanAppStatus == 'Reject'){
                    this.showErrorScreen = true;
                    return;
                }

                this.handleFraudCheckCallout()
                return "SUCCESS"
            });
    }
}