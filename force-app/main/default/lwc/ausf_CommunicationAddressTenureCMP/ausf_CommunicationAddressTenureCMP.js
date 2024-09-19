/**
 * @description       : AU Tenure Selection
 * @author            : Charchit Nirayanwal
 * @group             : 
 * @last modified on  : 12-07-2024 
 * @last modified by  : Charchit Nirayanwal
 * @Jira Story        : APL-942
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   12-07-2024   Charchit Nirayanwal  Initial Version
**/

import { LightningElement, track,api } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import Ausf_CommunicationAddressTenureCMPLabel from '@salesforce/label/c.Ausf_CommunicationAddressTenureCMP';

export default class Ausf_CommunicationAddressTenureCMP extends LightningElement {

    closeImg = AU_Assets + '/AU_Assets/images/Button.png';
    tickImgUrl = AU_Assets + '/AU_Assets/images/add.png';
    @track itemsMonth = []
    @track itemsYear = []
    @api year = 0
    @api month = 0
    @api typeOfResidence = 'Rented'
    yearHeading = 'Year'
    monthHeading = 'Month'
    buttonEnabledCls = 'agree-box'
    buttonDisabledCls = 'agree-box-disabled'
    submitButtonCls
    submitButtonDisabled = true;
    label = JSON.parse(Ausf_CommunicationAddressTenureCMPLabel);
    showYear
    showMonth

    rendered = false


    connectedCallback(){
        this.updateInputField();
    }

    renderedCallback() {
            if (this.typeOfResidence != '' && this.typeOfResidence,this.template.querySelectorAll('.chips,.chips-enabled')?.length && !this.rendered) {
                this.rendered = true;
                this.template.querySelectorAll('.chips,.chips-enabled').forEach(item => {
                    item.className = ''
    
                    if (this.typeOfResidence!=null && this.typeOfResidence.toLowerCase()  == item.innerText.toLowerCase()) {
                        item.classList.add('chips-enabled');
                    }
                    else {
                        item.classList.add('chips');
                    }
                });
                this.validateInputs();
            }
    }

    updateInputField(){
        for (let i = 1; i <= 4; i++) {
            for (let j = 0; j <= 11; j++) {
                this.itemsMonth.push({ id: j, name: `${j}` });
            }
        }
        for (let i = 1; i <= 4; i++) {
            for (let j = 0; j <= 60; j++) {
                this.itemsYear.push({ id: j, name: `${j}` });
            }
        }
        this.showMonth = true;
        this.showYear = true;
    }


    updateType(event) {
        if (event.target.innerText != '') {
            this.template.querySelectorAll('.chips,.chips-enabled').forEach(item => {
                item.className = ''

                if (event.target.innerText == item.innerText) {
                    this.typeOfResidence = event.target.innerText;
                    item.classList.add('chips-enabled');
                }
                else {
                    item.classList.add('chips');
                }
            });
            this.validateInputs();
        }
    }

    updateYear(event) {
        this.year = event.detail.value
        this.validateInputs()
    }

    updateMonth(event) {
        this.month = event.detail.value
        this.validateInputs();
    }

    handleSubmit() {
        const event = new CustomEvent('submit', {
            detail: {
                year: this.year,
                month: this.month,
                typeOfResidence: this.typeOfResidence
            }
        });
        this.dispatchEvent(event);
    }

    handleCloseModal() {
        this.dispatchEvent(new CustomEvent('closemodalevent'));
    }


    validateInputs() {
        if (this.typeOfResidence != '' && this.typeOfResidence != null && this.year != null && this.month != null && (this.year != 0 || this.month != 0)) {
            this.submitButtonCls = this.buttonEnabledCls
            this.submitButtonDisabled = false;
        }
        else {
            this.submitButtonCls = this.buttonDisabledCls
            this.submitButtonDisabled = true;
        }
    }
}