import { LightningElement,api,track } from 'lwc';
import fetchOptions from '@salesforce/apex/AUSF_Utility.fetchOptions';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';

export default class Ausf_industryProofSelection extends LightningElement {
    // @api fields = [
    //     { label: 'Sector', name: 'Sector', selectedValue: '', disabled: false, containerClass: 'field-container',hasSearch:false },
    //     { label: 'Industry', name: 'Industry', selectedValue: '', disabled: true, containerClass: 'field-container disabled',hasSearch:true },
    //     { label: 'Sub Industry', name: 'Sub_Industry', selectedValue: '', disabled: true, containerClass: 'field-container disabled',hasSearch:true },
    //     { label: 'Activity', name: 'Activity', selectedValue: '', disabled: true, containerClass: 'field-container disabled',hasSearch:true },
    // ];
    @api fields = [];
    @api isSecondTime = false;
    @api secondTimeFieldName = '';
    @api isSelectTitleHide = false;
    
    @track selectedField = '';
    @track showDynamicComponent = false;
    @track dynamicOptions = [];
    @track hasSearch = false;
    @track searchPlaceholder = '';
    arrowDown = AU_Assets + '/AU_Assets/images/chevron-down.png';

    connectedCallback(){
        if(this.isSecondTime && this.secondTimeFieldName){
            const field = this.fields.find(field => field.label === this.secondTimeFieldName);
            this.selectedField = this.secondTimeFieldName;
            const parentValue = field ? (this.fields[this.fields.indexOf(field) - 1] ? this.fields[this.fields.indexOf(field) - 1].selectedValue : field.selectedValue) : undefined;
            this.loadDynamicOptions(this.secondTimeFieldName,parentValue);
        }
        this.fields = this.fields.map(field => {
            return {
                ...field,
                labelClass: field.selectedValue ? 'field-label has-value' : 'field-label'
            };
        });
        console.log(JSON.stringify(this.fields));
    }
    renderedCallback(){
        this.fields = this.fields.map(field => {
            return {
                ...field,
                labelClass: field.selectedValue ? 'field-label has-value' : 'field-label'
            };
        });
        console.log(JSON.stringify(this.fields));

    }

    handleFieldClick(event) {
        console.log('enter');
        const fieldName = event.currentTarget.dataset.name;
        const field = this.fields.find(field => field.label === fieldName);
        const parentValue = field ? (this.fields[this.fields.indexOf(field) - 1] ? this.fields[this.fields.indexOf(field) - 1].selectedValue : field.selectedValue) : undefined;
        if (!field.disabled) {
            this.selectedField = fieldName;
            this.loadDynamicOptions(fieldName,parentValue);
        }
        
    }

    renderedCallback() {
        this.updateFieldClasses();
    }
    loadDynamicOptions(fieldName, parentSelection = null) {
        fetchOptions({ recordTypeName: this.getRecordTypeName(fieldName), parentValue: parentSelection })
            .then(result => {
                this.dynamicOptions = result.map(option => ({ label: option.name, value: option.code }));
                this.hasSearch = this.hasSearchEnable(fieldName);
                this.searchPlaceholder = `Search ${fieldName}`;
                this.showDynamicComponent = true;
                const showComponentEvent = new CustomEvent('showcomponentchange', {
                    detail: { fieldName:fieldName,showDynamicComponent: this.showDynamicComponent }
                });
                this.dispatchEvent(showComponentEvent);
            })
            .catch(error => {
                console.error('Error fetching options:', error);
            });
    }
    getRecordTypeName(fieldName) {
        const field = this.fields.find(field => field.label === fieldName);
        return field ? field.name : '';
    }
    hasSearchEnable(fieldName){
        return this.fields.some((field) => field.label === fieldName && field.hasSearch);
    }
    updateFieldClasses() {
        this.fields.forEach(field => {
            const fieldElement = this.template.querySelector(`div[data-name="${field.label}"]`);
            if (fieldElement) {
                if (field.disabled) {
                    fieldElement.classList.add('disabled');
                } else {
                    fieldElement.classList.remove('disabled');
                }
            }
        });
    }
    handleClose(event) {
        this.showDynamicComponent = false;
        const showComponentEvent = new CustomEvent('showcomponentchange', {
            detail: {fieldName:this.selectedField, showDynamicComponent: this.showDynamicComponent }
        });
        this.dispatchEvent(showComponentEvent);
    }
    handleOptionSelect(event) {
        try{
        event.stopPropagation();
        const { fieldName, selectedOption } = event.detail;
        let isValueChanged = false;
        this.fields = JSON.parse(JSON.stringify(this.fields));
        this.fields = this.fields.map((field, index) => {
            if (field.label === fieldName) {
                // Update selected value of the current field
                if(field.selectedValue && field.selectedValue != selectedOption){
                    isValueChanged = true;
                }
                field['selectedValue'] = selectedOption;
                // Enable the next field if it exists
                if (this.fields[index + 1]) {
                    this.fields[index + 1].selectedValue = '';
                    this.fields[index + 1].disabled = false;
                    this.fields[index + 1].containerClass = 'field-container';
                    this.selectedField = this.fields[index + 1].label;
                    this.loadDynamicOptions(this.fields[index + 1].label, selectedOption);
                }
            }else if(isValueChanged){
                if (this.fields[index + 1]) {
                    this.fields[index + 1].selectedValue = '';
                    this.fields[index + 1].disabled = true;
                    this.fields[index + 1].containerClass = 'field-container disabled';
                }
            }

            return field;
        });

        // // Hide the dynamic component if 'Activity' is selected
        // Check if the selected field is the last one in the fields array
        const isLastField = this.fields[this.fields.length - 1].label === fieldName;
        if (isLastField) {
            this.showDynamicComponent = false;
        }
        // if (fieldName === 'Activity') {
        //     this.showDynamicComponent = false;
        // }
        // Dispatch the custom event with the fields and showDynamicComponent
        const fieldsChangeEvent = new CustomEvent('fieldschanged', {
        detail: { fields: this.fields, showDynamicComponent: this.showDynamicComponent }
        });
        this.dispatchEvent(fieldsChangeEvent);
    }catch(error){
        console.log(error);
        console.log(JSON.stringify(error));
    }
}
}