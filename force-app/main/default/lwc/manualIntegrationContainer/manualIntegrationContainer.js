import { LightningElement, api } from 'lwc';
import ManualIntegrationModal from 'c/manualIntegrationModal';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';


export default class ManualIntegrationContainer extends LightningElement {
    @api recordId;
    @api intgChecklistId;

    handleModalOpen(){
        ManualIntegrationModal.open({
            size: 'small',
            inputIds:{
                recordId : this.recordId,
                intgChecklitsId : this.intgChecklistId
            }
        }).then(result =>{
            if(result == 'close'){
                this.showToast('Success','Manually completed the integration','success','dismissible');
                this.dispatchEvent(new CustomEvent('close'));
            }
        });
    }

    showToast(title, message, variant, mode){
        const evt = new ShowToastEvent({
            title: title,
            message:message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(evt);
    }

}