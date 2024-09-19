import { LightningElement, api, wire } from 'lwc';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';

export default class Ausf_CSDPNoRecordFound extends LightningElement {
    AUlogoImg = AU_Assets + '/AU_Assets/images/IB.png';
    invalidPanImage = AU_Assets + '/AU_Assets/images/Group_427322087.png';
    maximumAttemptsText = 'Due to bank\'s current internal policies, unfortunately we can\'t offer you a loan right now. ';
}