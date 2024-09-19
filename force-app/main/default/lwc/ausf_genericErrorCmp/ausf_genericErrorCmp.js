/**
 * @description       : 
 * @author            : Ruturaj Chothe
 * @group             : 
 * @last modified on  : 07-02-2024
 * @last modified by  : Ruturaj Chothe
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-01-2024   Ruturaj Chothe   Initial Version
**/
import { LightningElement, api } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';


export default class Ausf_genericErrorCmp extends LightningElement {
    @api errormessage = '';
    @api errortitle = '';
    @api showreturntohome = false;
    @api buttonname = '';
    errorImage = AU_Assets + '/AU_Assets/images/Frame_427319856.png';
    @api hideretry = false;

    get showRetryButton(){
        return !this.hideretry;
    }

    handleSubmit(){
        const closeModalEvent = new CustomEvent('closemodalevent');
        this.dispatchEvent(closeModalEvent);
    }

    handleReturnHome(){
        const returnHomeEvent = new CustomEvent('returnhome');
        this.dispatchEvent(returnHomeEvent);
    }

    renderedCallback(){
        this.template.querySelector('.Error-Message').innerHTML = this.errormessage;
    }
}