/**
 * @description       : 
 * @author            : Murtaza Ali
 * @group             : 
 * @last modified on  : 04-07-2024
 * @last modified by  : Murtaza Ali
 * @Jira Story        : APL-103
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   04-07-2024   Murtaza Ali   Initial Version
**/
import { LightningElement, api, wire } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import getScreenCustomTextRecords from '@salesforce/apex/AUSF_Utility.getScreenCustomTextRecords';
import AUSF_ApplyForPersonalLoan from '@salesforce/label/c.AUSF_ApplyForPersonalLoan';
import isguest from '@salesforce/user/isGuest';
import {NavigationMixin} from 'lightning/navigation'

export default class Ausf_GenericErrorScreenComponent extends NavigationMixin(LightningElement) {
    AUlogoImg = AU_Assets + '/AU_Assets/images/IB.png';
    label = {
        AUSF_ApplyForPersonalLoan
    };
    @api errortext;
    @api screenName;
    @api errorTitle;
    @api errorImage;
    @api homeButtonHide = false;
    errorIcon; 
    connectedCallback(){
        console.log(this.errortext);
        getScreenCustomTextRecords({screenName: this.screenName}).then(result=>{
            if (result) {
                result.forEach(element => {
                    if (element.DeveloperName == this.errorTitle) {
                        this.errortext = element.Custom_String__c;
                        console.log(this.errortext);
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
    handleHome(){
        
        if(isguest){
            
            window.location.href = 'https://www.aubank.in/';
        }
        else{  
            window.location.reload();
        }
        
    }
}