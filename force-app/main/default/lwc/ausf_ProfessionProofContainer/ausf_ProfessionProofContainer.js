import { LightningElement, api, track } from 'lwc';


export default class Ausf_ProfessionProofContainer extends LightningElement {
    // screen rendering variables
    @track screens = {
        IMPORT_EXPORT_CERTIFICATE: false,
        FSSAI_CERTIFICATE: false,
        SHOP_ESTABLISHMENT_CERTIFICATE: false,
        PHARMACY_LICENSE: false,
        MUNICIPAL_CORP_GOVT_ISSUED_CERTIFICATE: false,
        STATE_CENTRAL_POLLUTION_CONTROL_BOARD_CERTIFICATE: false,
        FACTORY_REGISTRATION_CERTIFICATE: false,
        GST_REGISTRATION_CERTIFICATE: false,
        OTHERS: false,
        ICAI_CERTIFICATE: false,
        ICSI_CERTIFICATE: false,
        ICWAI_CERTIFICATE: false,
        IMPORT_EXPORT_CERTIFICATE: false,
        MEDICAL_DEGREE_BY_MEDICAL_COUNCIL_OF_INDIA: false
    }
    
    screenName = 'Profession Proof Container';
    @api childScreenName = '';

    formatString(input) {
        return input
                .toUpperCase()                    // Convert to uppercase
                .replace(/[^A-Z\s]/g, '_')        // Replace non-alphabet characters with underscores
                .replace(/\s+/g, '_');            // Replace spaces with underscores
    }

    connectedCallback() {
        this.childScreenName = this.formatString(this.childScreenName);
    }

}