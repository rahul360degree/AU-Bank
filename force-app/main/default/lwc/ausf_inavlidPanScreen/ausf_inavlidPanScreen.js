/**
 * @description       : 
 * @author            : Ruturaj Chothe
 * @group             : 
 * @last modified on  : 06-28-2024
 * @last modified by  : Ruturaj Chothe
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   06-28-2024   Ruturaj Chothe   Initial Version
**/
import { LightningElement, api, wire } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import getScreenCustomTextRecords from '@salesforce/apex/AUSF_Utility.getScreenCustomTextRecords';

export default class Ausf_inavlidPanScreen extends LightningElement {
    AUlogoImg = AU_Assets + '/AU_Assets/images/IB.png';
    invalidPanImage = AU_Assets + '/AU_Assets/images/Group_427322087.png';
    maximumAttemptsText = '';

    @wire(getScreenCustomTextRecords, {screenName: 'Enter Mobile Number' })
    getConigurableTextFromMetadata({ data, error }) {
        if (data) {
            console.log(data);
            data.forEach(element => {
                if (element.DeveloperName == 'Maximum_Attempts_Text') {
                    this.maximumAttemptsText = element.Custom_String__c;
                }
            });
        } else if (error) {
            console.error(error);
        }
    };

}