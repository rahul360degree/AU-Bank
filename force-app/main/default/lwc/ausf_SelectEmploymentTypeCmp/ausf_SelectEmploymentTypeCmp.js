/**
* @description       : AU Select Employment Type
* @author            : Charchit Nirayanwal
* @group             : 
* @last modified on  : 12-07-2024 
* @last modified by  : Charchit Nirayanwal
* @Jira Story        : APL-942
* Modifications Log
* Ver   Date         Author           Modification
* 1.0   12-07-2024   Charchit Nirayanwal  Initial Version
**/

import { LightningElement, track, api } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';

export default class Ausf_SelectEmploymentTypeCmp extends LightningElement {

    closeImg = AU_Assets + '/AU_Assets/images/Button.png';
    tickImgUrl = AU_Assets + '/AU_Assets/images/add.png';
    businessEmpTypeImgURL = AU_Assets + '/AU_Assets/images/FrameBusinessEmp.svg';
    nonBusinessEmpTypeImgURL = AU_Assets + '/AU_Assets/images/FrameProfessional.svg';
    buttonEnabledCls = 'agree-box'
    buttonDisabledCls = 'agree-box-disabled'

    submitButtonCls = this.buttonDisabledCls
    @api selectedEmpType

    // label = JSON.parse(Ausf_CommunicationAddressTenureCMPLabel);


    connectedCallback() {}


    renderedCallback() { 
        if(this.selectedEmpType != null){
            this.template.querySelectorAll('.radiobtn').forEach(item => {
                if (item.dataset.id != this.selectedEmpType) {
                    item.checked = false;
                }
                else {
                    item.checked = true;
                    this.validateInput();
                }
            })
        }
     }

    handleSelection(event) {
        event.target.checked = false

        this.template.querySelectorAll('.radiobtn').forEach(item => {
            if (item.dataset.id != event.target.dataset.id) {
                item.checked = false;
            }
            else {
                item.checked = true;
            }
        })

        this.selectedEmpType = event.target.dataset.id;
        this.validateInput();
    }


    validateInput() {
        if (this.selectedEmpType) {
            this.submitButtonCls = this.buttonEnabledCls
        }
        else {
            this.submitButtonCls = this.buttonDisabledCls
        }

    }

    onSubmit() {
        const submitEvent = new CustomEvent('submit', {
            detail: {
                empType: this.selectedEmpType
            }
        });
        this.dispatchEvent(submitEvent);
    }

    handleCloseModal(){
        this.dispatchEvent(new CustomEvent('submit'));
    }


}