import { LightningElement, api } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';


import PL_Loading_Icon from '@salesforce/resourceUrl/AULoader';

export default class UiLoader extends LightningElement {
    @api size = 'medium';
    @api variant = 'base';
    @api spinnerText = 'Loading details...';
    showAnimation = false;
    loaderAnimationJSONSrc = AU_Assets + '/AU_Assets/PL_Animations/Spinner_loader/orange_loader_Secondary_loader.json';
    loaderAnimationJSON = '';

    iconUrl = PL_Loading_Icon;

    @api set helpText(value) {
        value='Loading details...';
    }
    
    get helpText(){
        return this.spinnerText ? this.spinnerText : 'Loading details...';
    }

    connectedCallback(){
        var loader = new XMLHttpRequest();
        
        loader.open("GET", this.loaderAnimationJSONSrc);
        loader.onload = () => {
            this.showAnimation = true;
            this.loaderAnimationJSON = loader.responseText;
            this.animationJSON = loader.responseText;
        }
        loader.send(null);
    }
}