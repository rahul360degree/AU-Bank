import { LightningElement, api } from 'lwc';
import verifyEmploymentDetails from '@salesforce/apex/AUSF_Utility.verifyEmploymentDetails';
export default class Ausf_genericBusinessProofContainer extends LightningElement {
    @api apiFlag;
    @api selectedMethod = 'ICSI certificate';
    @api applicantId = 'a02C1000002colpIAA';
    @api loanApplicationId = 'a01C100000H80SUIAZ';
    @api employmentId;
    isApiSucess = false;
    addressId ;
    screenName = '';
    showLoader = true;
    handleApiVerifaction(event){
        this.isApiSucess = event.detail.apiSuccess;
        this.employmentId = event.detail.employmentId;
        this.addressId = event.detail.addressId
        this.apiFlag = false;
        this.screenName = event.detail.selectedMethod;
    }
    connectedCallback(){
        this.showLoader = true;
        verifyEmploymentDetails({applicantId:this.applicantId})
            .then(result=>{
                if(result){
                    console.log('result'+JSON.stringify(result));
                    this.isApiSucess = result.isSuccess;
                    this.employmentId = result.employmentDetailId?result.employmentDetailId:'';
                    this.addressId = result.addressId?result.addressId:'';
                    this.screenName = result.genericMetadata.Screen_Name__c;
                }
                if(this.employmentId){
                    if(this.isApiSucess){
                        this.apiFlag = false;
                        
                    } else if(result.isInstant){
                        this.apiFlag = true;
                    }else {
                        this.apiFlag = false;
                    }
                }
                this.showLoader = false;

            }).catch(error=>{
                console.log('Error in connectedCallback'+error);
            })
    }
}