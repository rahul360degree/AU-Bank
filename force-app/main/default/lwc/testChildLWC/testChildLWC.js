import { LightningElement,api, track } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';
export default class TestChildLWC extends LightningElement {
    @api fieldName;
    @api options = [];
    @api hasSearch = false;
    @api searchPlaceholder = '';
    
    @track searchTerm = '';
    @track filteredOptions = [];
    activeBackButtonURL = Assets +'/AU_Assets/images/arrow-left-active.png';
    connectedCallback() {
        this.filteredOptions = this.options;
    }

    filterOptions() {
        if (this.searchTerm) {
            this.filteredOptions = this.options.filter(option => 
                option.toLowerCase().includes(this.searchTerm)
            );
        } else {
            this.filteredOptions = this.options;
        }
    }

    renderedCallback(){
        this.filterOptions();
    }
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
        
        // Fire custom event with selected option
        const optionSelectEvent = new CustomEvent('optionselect', {
            detail: { fieldName, selectedOption }
        });
        this.dispatchEvent(optionSelectEvent);
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }
}