import { LightningElement, track } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';


export default class ProfessionType extends LightningElement {
    screenName = 'Residence Ownership Proof';
    headerContents = 'Apply for Personal Loan';
    headerDescription = 'Application Process';
    overallJourneySteps = 3;
    currentJourney = 2;
    stepsInCurrentJourney=3;
    currentStep=2;
    showContents = true;
    enableBackButton = true;

    showLoader = false;
    isMultipleAllowed = true;
    insertFiles = false;
    titleText = 'Profession type';
    subtitleText = 'Share your profession type so that we can verify your employment details';

    lightningIMGURL = Assets + '/AU_Assets/images/lightning.png';
    
    @track selectedOption;

    progressValue = 33;

    instantVerificationOptions = [
        { label: 'ICAI Certificate', value: 'APL-726' },
        { label: 'ICSI Certificate', value: 'APL-729' },
        { label: 'ICWAI Certificate', value: 'APL-728' },
        { label: 'Shop & Establishment Certificate', value: 'APL-718' },
        { label: 'Import Export Certificate', value: 'APL-720' }
    ];

    manualUploadOptions = [
        { label: 'Municipal Corp/Govt Issued Certificate', value: 'APL-722' },
        { label: 'Medical Degree by Medical Council of India', value: 'APL-725' },
        { label: 'GST Registration Certificate', value: 'APL-156' },
        { label: 'Others', value: 'APL-685' }
    ];

    handleOptionChange(event) {
        debugger;
        const checkboxes = this.template.querySelectorAll(`input[type="checkbox"][data-section="proofoptions"]`);
        checkboxes.forEach(checkbox => {
            if (checkbox !== event.target) {
                checkbox.checked = false;
            }
        });
    }

    handleConfirmClick() {
        if (this.selectedOption) {
            console.log(`Proceed with ${this.selectedOption}`);
            // Implement navigation or other logic based on the selected option
        }
    }
}