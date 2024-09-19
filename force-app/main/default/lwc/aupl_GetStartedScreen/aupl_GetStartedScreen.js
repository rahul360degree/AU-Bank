import { LightningElement,api} from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';

export default class Aupl_GetStartedScreen extends LightningElement {

   
    @api screenname = '';
    @api mobileNumber;

    handleGettingStarted(){
        // alert('Hello Lets get Started');
        console.log(this.screenname,this.mobileNumber);
        const nextEvent = new CustomEvent('submitevent', {
            detail: {
                currentScreen: this.screenname,
                mobileNumber: this.mobileNumber
            },
            composed:true,
            bubbles:true

        });
        this.dispatchEvent(nextEvent);
    }
}