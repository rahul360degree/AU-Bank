/**
 * @description       : 
 * @author            : Charchit Nirayanwal
 * @group             : 
 * @last modified on  : 17-07-2024 
 * @last modified by  : Charchit Nirayanwal
 * @Jira Story        : APL-745
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   17-07-2024   Charchit Nirayanwal  Initial Version
**/
import { LightningElement, api } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';


export default class Ausf_PauseScreen extends LightningElement {

    @api imageUrl = AU_Assets + '/AU_Assets/images/Group1321314533.svg';
    @api applicantId 
    @api loanApplicationId 

    screenName = 'Pause Screen';
    headerContents = 'Apply for Personal Loan';
    showContents = false;

    cfrCheckRes
    amlApiRes
    hunterApiRes



    @api messagelabel = 'We are currently processing your loan application and will notify you as soon as the offer is generated'
    @api loanApplicationName ='LA-10101'

    handleHomeButton() {
        this.dispatchEvent(new CustomEvent('homebutton'));
    }

}