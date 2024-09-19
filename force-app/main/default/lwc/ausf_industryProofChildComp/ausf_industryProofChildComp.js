import { LightningElement,api, track } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';
import AUSF_ApplyForPersonalLoan from '@salesforce/label/c.AUSF_ApplyForPersonalLoan';
export default class Ausf_industryProofChildComp extends LightningElement {
    AUlogoImg = Assets + '/AU_Assets/images/IB.png';
    label = {
        AUSF_ApplyForPersonalLoan
    };
    @api fieldName;
    @api hasSearch = false;
    @api searchPlaceholder = '';
    
    @track searchTerm = '';
    @track filteredOptions = [];
    activeBackButtonURL = Assets +'/AU_Assets/images/arrow-left-active.png';
    _options = [];
    arrowRight = Assets + '/AU_Assets/images/chevron-right.png';
    searchIcon = Assets + '/AU_Assets/images/search.png';
    closeIcon = Assets + '/AU_Assets/images/close.png';
    @api
    get options() {
        return this._options;
    }

    set options(value) {
        this._options = value;
        this.filterOptions();
    }
    connectedCallback() {
        this.filteredOptions = this.options;
    }

    filterOptions() {
        if (this.searchTerm) {
            this.filteredOptions = this.options.filter(option => 
                option.label.toLowerCase().includes(this.searchTerm)
            );
        } else {
            this.filteredOptions = this.options;
        }
    }

    // renderedCallback(){
    //     //this.filterOptions();
    // }
    handleSearchChange(event) {
        this.searchTerm = event.target.value.toLowerCase();
        this.filterOptions();
    }

    handleOptionClick(event) {
        const selectedOption = event.currentTarget.dataset.option;
        // Redirect to another LWC component based on the selected option
        // This can be handled by firing a custom event or using navigation
        console.log(`Selected option: ${selectedOption}`);
        const fieldName = this.fieldName;
        this.searchTerm = '';
        // Fire custom event with selected option
        const optionSelectEvent = new CustomEvent('optionselect', {
            detail: { fieldName, selectedOption }
        });
        this.dispatchEvent(optionSelectEvent);
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
    clearSearch() {
        this.searchTerm = '';
        this.template.querySelector('input').value = '';
        this.filterOptions();
    }
}