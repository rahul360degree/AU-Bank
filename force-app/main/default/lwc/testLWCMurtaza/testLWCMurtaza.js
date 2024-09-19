import { LightningElement,track,api } from 'lwc';

export default class TestLWCMurtaza extends LightningElement {
    @api fields = [
        { label: 'Sector', name: 'sector', selectedValue: '', disabled: false, containerClass: 'field-container' },
        { label: 'Industry', name: 'industry', selectedValue: '', disabled: true, containerClass: 'field-container disabled' },
        { label: 'Sub Industry', name: 'subIndustry', selectedValue: '', disabled: true, containerClass: 'field-container disabled' },
        { label: 'Industry type', name: 'industryType', selectedValue: '', disabled: true, containerClass: 'field-container disabled' },
        { label: 'Activity', name: 'activity', selectedValue: '', disabled: true, containerClass: 'field-container disabled' },
    ];

    // Cascading options based on previous selections
    optionData = {
        Sector: {
            Farmer: ['Industry 1', 'Industry 2'],
            Manufacturer: ['Industry 3', 'Industry 4'],
            // Add other sectors and their corresponding industries
        },
        Industry: {
            'Industry 1': ['Sub Industry 1-1', 'Sub Industry 1-2'],
            'Industry 2': ['Sub Industry 2-1', 'Sub Industry 2-2'],
            // Add other industries and their corresponding sub-industries
        },
        SubIndustry: {
            'Sub Industry 1-1': ['Industry Type 1-1-1', 'Industry Type 1-1-2'],
            'Sub Industry 2-1': ['Industry Type 2-1-1', 'Industry Type 2-1-2'],
            // Add other sub-industries and their corresponding industry types
        },
        IndustryType: {
            'Industry Type 1-1-1': ['Activity 1-1-1-1', 'Activity 1-1-1-2'],
            'Industry Type 2-1-1': ['Activity 2-1-1-1', 'Activity 2-1-1-2'],
            // Add other industry types and their corresponding activities
        }
    };
    
    @track selectedField = '';
    @track showDynamicComponent = false;
    @track dynamicOptions = [];
    @track hasSearch = false;
    @track searchPlaceholder = '';

    handleFieldClick(event) {
        const fieldName = event.currentTarget.dataset.name;
        const field = this.fields.find(field => field.label === fieldName);
        const parentValue = field ? (this.fields[this.fields.indexOf(field) - 1] ? this.fields[this.fields.indexOf(field) - 1].selectedValue : field.selectedValue) : undefined;
        if (!field.disabled) {
            this.selectedField = fieldName;
            this.loadDynamicOptions(fieldName,parentValue);
            this.showDynamicComponent = true;
        }
    }

    renderedCallback() {
        this.updateFieldClasses();
    }
    loadDynamicOptions(fieldName, parentSelection = null) {
        if (fieldName === 'Sector') {
            this.dynamicOptions = Object.keys(this.optionData.Sector);
            this.hasSearch = false;
        } else if (fieldName === 'Industry' && parentSelection) {
            console.log('loadDynamic data'+parentSelection);
            this.dynamicOptions = this.optionData.Sector[parentSelection];
            console.log(this.dynamicOptions);
            this.hasSearch = true;
            this.searchPlaceholder = 'Search Industry';
        } else if (fieldName === 'Sub Industry' && parentSelection) {
            this.dynamicOptions = this.optionData.Industry[parentSelection];
            this.hasSearch = true;
            this.searchPlaceholder = 'Search Sub Industry';
        } else if (fieldName === 'Industry type' && parentSelection) {
            this.dynamicOptions = this.optionData.SubIndustry[parentSelection];
            this.hasSearch = true;
            this.searchPlaceholder = 'Search Industry Type';
        } else if (fieldName === 'Activity' && parentSelection) {
            this.dynamicOptions = this.optionData.IndustryType[parentSelection];
            this.hasSearch = true;
            this.searchPlaceholder = 'Search Activity';
        }
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
    handleClose() {
        this.showDynamicComponent = false;
    }
    handleOptionSelect(event) {
        const { fieldName, selectedOption } = event.detail;
        let isValueChanged = false;
        this.fields = this.fields.map((field, index) => {
            if (field.label === fieldName) {
                // Update selected value of the current field
                if(field.selectedValue != selectedOption){
                    isValueChanged = true;
                }
                field.selectedValue = selectedOption;

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

    // Hide the dynamic component if 'Activity' is selected
    if (fieldName === 'Activity') {
        this.showDynamicComponent = false;
    }
    }
}