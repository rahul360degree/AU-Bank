import { LightningElement, api, wire } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import getScreenCustomTextRecords from '@salesforce/apex/AUSF_Utility.getScreenCustomTextRecords';

export default class Ausf_GenericErrorComponent extends LightningElement {
    AUlogoImg = AU_Assets + '/AU_Assets/images/IB.png';
    
    errortext;
    @api screenName;
    @api errorTitle;
    @api errorImage;
    errorIcon; 
    connectedCallback(){
        getScreenCustomTextRecords({screenName: this.screenName}).then(result=>{
            if (result) {
                result.forEach(element => {
                    if (element.DeveloperName == this.errorTitle) {
                        this.errortext = element.Custom_String__c;
                    }
                });
            } else if (error) {
                console.error(error);
            }
        }).catch(error => {
            console.error(error);
        });
        this.errorIcon = AU_Assets + '/AU_Assets/images/'+this.errorImage;
    }
}