import { LightningElement,track,api } from 'lwc';
import getScreenOrderMapping from '@salesforce/apex/AUSF_GenericWizardController.getScreenOrderMapping';
import doBackendOperation from '@salesforce/apex/AUSF_Utility.doBackendOperation';

export default class Ausf_GenericWizardCmp extends LightningElement {

    showLoader = true;
    @track screenList;
    @api loanApplicationId
    @api applicantId;
    @api isGuestUser;
    @api cookieData;

    mobileNumber;
    panNumber;
    DOB;
    panName;
    refreshData

    screenVisibilityList;
    selectedMethod;
    isBusinessProofApi;


    async connectedCallback(){
        let resultData = await getScreenOrderMapping({loanApplicationId:this.loanApplicationId});
        if(resultData){
            let screenObj = this.handleScreenData(resultData);
            if(screenObj){        
                this.screenList = screenObj;
                this.showLoader = false;
                console.log('screen mapping ->',JSON.stringify(this.screenList));
            }
        }
    }

    handleScreenData(result){
        try {
            console.log('wrapperdata->',JSON.stringify(result));
            let metadataToConsider = result.wizardDataDIYList ? result.wizardDataDIYList : result.wizardDataAssistedList ? result.wizardDataAssistedList : [];
            let loanApplicationData = result.loanApplicationList ? result.loanApplicationList[0] : null;
            // this.screenVisibilityList = result.screenVisibilityList ? result.screenVisibilityList : null;
            let screenObj = {};
            if(metadataToConsider){
                let foundNextPage = false;
                metadataToConsider.forEach(element => {
                    let key = element.Current_Screen_Name__c.split(' ').join('');
                    // console.log(foundNextPage);
                    // if(loanApplicationData && loanApplicationData.Last_visited_Page__c){
                    //     if(foundNextPage){
                    //         screenObj[key] = true;
                    //         foundNextPage = false;
                    //     }else{
                    //         if(element.Current_Screen_Name__c == loanApplicationData.Last_visited_Page__c){
                    //             foundNextPage = true;
                    //             screenObj[key] = false;
                    //         }else{
                    //             screenObj[key] = false;
                    //         }
                    //     }
                    // }else if(loanApplicationData && !loanApplicationData.Last_visited_Page__c && element.Is_Default__c){
                    //     screenObj[key] = true;
                    // }
                    // else if(!loanApplicationData && element.Is_Default__c){
                    //     screenObj[key] = true;
                    // }else{
                    //     screenObj[key] = false;
                    // }
                    if(element.Is_Default__c && !this.refreshData){
                        screenObj[key] = true;
                    }else{
                        screenObj[key] = false;
                    }
                });
            }
            return screenObj;
        } catch (error) {
            console.error(error);
        }
    }

    async handleNextScreenMethod(event){
        try {
            const eventData = event.detail;
            console.log(JSON.stringify(eventData));
            let currentScreen = eventData.currentScreen.split(' ').join('');
            this.loanApplicationId = this.loanApplicationId ? this.loanApplicationId : eventData.loanAppId ? eventData.loanAppId : null;
            this.applicantId = this.applicantId ? this.applicantId : eventData.applicantId ? eventData.applicantId : null;
            this.mobileNumber = this.mobileNumber ? this.mobileNumber : eventData.mobileNumber ? eventData.mobileNumber : null;
            this.panName = this.panName ? this.panName : eventData.panName ? eventData.panName : '';
            this.panNumber = this.panNumber ? this.panNumber : eventData.panNumber ? eventData.panNumber : '';
            this.DOB = this.DOB ? this.DOB : eventData.DOB ? eventData.DOB : '';
            let skipNext = eventData.skipNext ? eventData.skipNext ? 1 : 0 : 0;
            let doBackendOperationVar = eventData.doBackendOperation ? eventData.doBackendOperation : false;
            this.selectedMethod = eventData.selectedMethod ? eventData.selectedMethod : undefined;
            this.isBusinessProofApi = eventData.isApi ? eventData.isApi : undefined;

            this.refreshData = eventData.refreshData ? eventData.refreshData : false;
            
            if(doBackendOperationVar){
                let obj = {
                    'loanApplicationId':this.loanApplicationId,
                    'applicantId':this.applicantId,
                    'screenName':eventData.currentScreen
                }
                await doBackendOperation({wrapperString:JSON.stringify(obj)})
                .then(result=>{
                    console.log(result);
                })
            }
            if(this.refreshData){
                this.showLoader = true;
                let resultData = await getScreenOrderMapping({loanApplicationId:this.loanApplicationId});
                if(resultData){
                    let screenObj = this.handleScreenData(resultData);
                    if(screenObj){        
                        this.screenList = screenObj;
                        console.log('screen mapping ->',JSON.stringify(this.screenList));
                        this.handleNavigationMethod(currentScreen,1,skipNext);
                    }
                }                
            }else{
                this.handleNavigationMethod(currentScreen,1,skipNext);
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleBackScreenMethod(event){
        const eventData = event.detail;
        let currentScreen = eventData.currentScreen.split(' ').join('');
        let skipNext = eventData.skipNext ? eventData.skipNext ? 1 : 0 : 0;
        if (eventData.skipPrevious) {
            this.handleNavigationMethod(currentScreen, -2, skipNext);
        } else {
            this.handleNavigationMethod(currentScreen, -1, skipNext);    
        }
        
    }

    handleNavigationMethod(currentScreen,indexToBeMoved,indexTobeSkipped){
        try {
            let keys = Object.keys(this.screenList);
            let nextScreen = keys[keys.indexOf(currentScreen)+(indexToBeMoved)+(indexTobeSkipped)];
            console.log(indexTobeSkipped);
            console.log(keys);
            console.log(keys.indexOf(currentScreen));
            console.log(currentScreen);
            console.log(nextScreen);
            keys.map(screenName=>{
                this.screenList[screenName] =  false
            })
            this.screenList[nextScreen] = true;
            this.showLoader = false;
        } catch (error) {
            console.error(error);
        }
    }
}