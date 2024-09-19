import { LightningElement, api, track } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';

export default class Aupl_OtpVerificationScreenCmp extends LightningElement {

    AUlogoImg = AU_Assets + '/AU_Assets/images/IB.png';
    crossSymbolImage = AU_Assets + '/AU_Assets/images/Outline/x.png';

    @api showModal = false;
    openModal(){
        this.showModal = true;
    }

    closeOtpModalWindow(){
        this.showModal = false;
    }
    
    connectedCallback() {
        this.showModal = true;
    }
    disconnectedCallback() {
    }

    renderedCallback() {
    }

}