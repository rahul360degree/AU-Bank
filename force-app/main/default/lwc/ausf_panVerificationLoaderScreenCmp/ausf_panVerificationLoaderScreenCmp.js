/**
 * @description       : 
 * @author            : Ruturaj Chothe
 * @group             : 
 * @last modified on  : 06-28-2024
 * @last modified by  : Ruturaj Chothe
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-25-2024   Ruturaj Chothe   Initial Version
**/
import { LightningElement } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';


export default class Ausf_panVerificationLoaderScreenCmp extends LightningElement {

    animationJSON = ''

    AUlogoImg = AU_Assets + '/AU_Assets/images/IB.png';
    loaderAnimationJSONSrc = AU_Assets + '/AU_Assets/PL_Animations/PAN_validation_loader/Loader_PAN.json';
    loaderAnimationJSON = '';
    panSuccessAnimationJSONSrc = AU_Assets + '/AU_Assets/PL_Animations/PAN_validation_loader/PAN_Success.json';
    panSuccessAnimationJSON = '';

    animationFlag = false;

    get getLoaderAnimationFlag(){
        if(!this.animationFlag){
            return true;
        }else{
            return false;
        }
    }

    get getPANSuccesAnimationFlag(){
        if(this.animationFlag){
            return true;
        }else{
            return false;
        }
    }

    changeAnimation(){
        this.animationFlag = !this.animationFlag;
    }

    renderedCallback() {
    }

    connectedCallback(){
        // Load loader animation JSON
        var loader = new XMLHttpRequest();
        loader.open("GET", this.loaderAnimationJSONSrc);
        loader.onload = () => {
            this.loaderAnimationJSON = loader.responseText;
            this.animationJSON = loader.responseText;
        }
        loader.send(null);

        // Load PAN success animation JSON
        var panSuccess = new XMLHttpRequest();
        panSuccess.open("GET", this.panSuccessAnimationJSONSrc);
        panSuccess.onload = () => {
            this.panSuccessAnimationJSON = panSuccess.responseText;
        }
        panSuccess.send(null);

    }

}