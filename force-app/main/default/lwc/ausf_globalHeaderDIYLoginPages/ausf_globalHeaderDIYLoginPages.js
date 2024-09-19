import { LightningElement } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import DIY_Styles from '@salesforce/resourceUrl/AUPLDIYStyles';

export default class Ausf_globalHeaderDIYLoginPages extends LightningElement {
    auLogo = DIY_Styles + '/AUPLDIYStyles/img/AUBankLogo.png';
    stylesLoaded = false;

    renderedCallback() {
        console.log('MM 1 ' + this.auLogo);
        console.log('MM 2 ' + DIY_Styles);
        if (this.stylesLoaded) {
            return;
        }
        Promise.all([
            loadStyle(this, DIY_Styles + '/AUPLDIYStyles/styles/styles.css')
        ]).then(() => {
            this.stylesLoaded = true;
        })
        .catch(error => {
            console.log('Styles could not be loaded', error);
        });
    }
}