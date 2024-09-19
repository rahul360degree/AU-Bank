import { LightningElement,api } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import checkBREIPAResponse from '@salesforce/apex/AUSF_Utility.checkBREIPAResponse';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import getBreResponse from '@salesforce/apex/AUSF_INT_BRE_Controller.getBreResponse';
import getICRecords from '@salesforce/apex/AUSF_Utility.getICRecords';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';
import createIntegrationChecklistRecord from '@salesforce/apex/AUSF_Utility.createIntegrationChecklistRecord';




export default class Ausf_BRELoaderCmp extends LightningElement {

    loaderAnimationJSONSrc = AU_Assets + '/AU_Assets/PL_Animations/BRE_Loader/BRE_Loader.json';
    loaderAnimationJSON = '';

    screenName = 'IPA BRE Loader';
    headerContents = 'Apply for Personal Loan';
    showContents = false;
    showAnimation = false;
    icMasterName = 'FICO KNOCKOUT BRE';
    showErrorScreen = false;
    showRetry = false;
    functionalRetryCount;
    technicalRetryCount;
    technicalRetryAfter;
    staticIntervalValue;
    maxPollerIntervalValue;
    beyondThreshold = false;
    errorMessage;
    applicationIdData;
    errorFromAPI = false;
    skipNext = false;
    isResumeJourney = false;
    foundResponse = false;

    @api loanApplicationId 
    @api applicantId

    headingLabel ='Processing your application';
    messagelabel ='We are collecting and verifying all your details to offer the best loan limit';

    async connectedCallback(){
        try {
            var loader = new XMLHttpRequest();
            loader.open("GET", this.loaderAnimationJSONSrc);
            loader.onload = () => {
                this.showAnimation = true;
                this.loaderAnimationJSON = loader.responseText;
            }
            loader.send(null);

            getCurrentScreenData({loanApplicationId:this.loanApplicationId, applicantId:this.applicantId,screenName: this.screenName,masterName:this.icMasterName})
            .then(result => {
                console.log(result);
    
                let loanApplicationData = result.loanApplicationList ? result.loanApplicationList[0] : null;
                let applicantData = result.applicantList ? result.applicantList[0] : null;

                this.applicationIdData = loanApplicationData ? loanApplicationData.Name : null;

                let profileName = result.profileName ? result.profileName : null;

                let restrictedIPAProfileList = [];
    
                let customTextList = result.screenCustomTextList ? result.screenCustomTextList : null;
                if (customTextList) {
                    customTextList.forEach(element => {
                        if(element.Label == 'Functional Retries'){
                            this.functionalRetryCount = parseInt(element.Custom_String__c);
                        }else if(element.Label == 'Technical Retry After'){
                            this.technicalRetryAfter = parseInt(element.Custom_String__c)*60000;
                        }else if(element.Label == 'Max Interval Value'){
                            this.staticIntervalValue = parseInt(element.Custom_String__c)*60000;
                        }else if(element.Label == 'Max Poller Interval Value'){
                            this.maxPollerIntervalValue = parseInt(element.Custom_String__c)*60000;
                        }else if(element.Label == 'Technical Failure Error Message'){
                            this.errorMessage = element.Custom_String__c;
                        }else if(element.Label == 'IPA Screen Restrict Visibility'){
                            restrictedIPAProfileList = element.Custom_String__c.split(',');
                        }
                    });
                }

                if(restrictedIPAProfileList && restrictedIPAProfileList.length > 0 && profileName){
                    this.skipNext = restrictedIPAProfileList.includes(profileName);
                }

                let masterDetails = result.masterDetails ? result.masterDetails :null;
                if(masterDetails){
                    this.functionalRetryCount = masterDetails[0].Max_number_of_functional_retries__c;
                    this.technicalRetryCount = masterDetails[0].Max_number_of_retries_allowed__c;
                }

                //check if BRE is triggered or not

                this.getIntegrationChecklistRecords();
            })            
        } catch (error) {
            console.error(error);
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
                    if(icRecord.Status__c && icRecord.Status__c != 'Pending'){
                        let icCreatedDate = new Date(icRecord.CreatedDate);
                        //logic of re trigger api after technical retry delay incase of technical failure also check for max retry
                        if(this.technicalRetryAfter && this.technicalRetryCount > technicalFailures.length){
                            let thresholdDelayTime = new Date(icCreatedDate.getTime() + (parseInt(this.technicalRetryAfter)));
                            if(thresholdDelayTime < new Date()){
                                this.handleBREApiCallout();
                            }
                        }
                        else if(this.functionalRetryCount && this.functionalRetryCount > functionalFailures.length){
                            this.handleBREApiCallout();
                        }
                        else if((technicalFailures.length >= this.technicalRetryCount) || (this.functionalRetryCount && this.functionalRetryCount < functionalFailures.length)){
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
                    }else{
                        this.errorFromAPI = true;
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

}