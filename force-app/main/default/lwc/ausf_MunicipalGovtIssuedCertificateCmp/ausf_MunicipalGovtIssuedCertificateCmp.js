import { LightningElement } from 'lwc';

export default class Ausf_MunicipalGovtIssuedCertificateCmp extends LightningElement {
    
    // header variables
    screenName = 'Municipal Corporation/ Govt issued certificate';
    headerContents = 'Apply for Personal Loan';
    headerDescription;
    stepsInCurrentJourney;
    currentStep;
    showContents = true;
    enableBackButton = true;

    // Screen variables
    title = 'Municipal Corporation/ Govt issued certificate';
    subtitle = 'Enter your employment details so that we can verify your business profile';

    //industry 
    isSelectTitleHide = true;
    hideMainScreen = false;
    fields = [
        { label: 'Sector', name: 'Sector', selectedValue: '', disabled: false, containerClass: 'field-container', hasSearch: false },
        { label: 'Industry', name: 'Industry', selectedValue: '', disabled: true, containerClass: 'field-container disabled', hasSearch: true },
        { label: 'Sub Industry', name: 'Sub_Industry', selectedValue: '', disabled: true, containerClass: 'field-container disabled', hasSearch: true },
        { label: 'Activity', name: 'Activity', selectedValue: '', disabled: true, containerClass: 'field-container disabled', hasSearch: true }];

    showParentCmpScreen(event) {
        this.hideMainScreen = event.detail.showDynamicComponent;
        this.fieldName = event.detail.fieldName;
        console.log('fields fieldName parent screen', this.fieldName);
    }
    
    handleFieldsChanged(event) {
        this.hideMainScreen = event.detail.showDynamicComponent;
        this.fieldName = event.detail.fieldName;
        this.fields = event.detail.fields;
        console.log('this.fields', this.fields);
        this.sector = this.getSelectedValueByLabel(this.fields, 'Sector');
        this.industry = this.getSelectedValueByLabel(this.fields, 'Industry');
        this.subIndustry = this.getSelectedValueByLabel(this.fields, 'Sub Industry');
        this.activity = this.getSelectedValueByLabel(this.fields, 'Activity');
        console.log('sector indusrtry ', this.sector, this.industry, this.subIndustry, this.activity);
        console.log('fields fieldName handleFields changed', this.fieldName);
        this.handleAllInputValues();
    }
}