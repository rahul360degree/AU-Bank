import { LightningElement,api,track } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';
import isguest from '@salesforce/user/isGuest';
import viewer from '@salesforce/resourceUrl/pdfjstest';
import JSPDF from '@salesforce/resourceUrl/jspdftest';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class Ausf_FilePreviewCmp extends LightningElement {

    fileData;
    @api fileContents
    @api isPdf
    imgStyling
    fileType
    @track showControls = true;
    closeIconURL = Assets + '/AU_Assets/images/Outline/x.png';
    fileEncodedata;
    viewerUrl = viewer + '/pdfjstest/web/viewer.html?file='; ///resource/pdfjs/pdfjs/web/viewer.html?file=
    @track fileSrc;
    @track isImage = false;
    @track isPdf = false;
    @track zoomLevel = 1;
    @track rotation = 0;
    pdfUrl;
    connectedCallback() {
        this.fileType = this.isPdf?'application/pdf':'image/png';
        console.log('this.fileContents'+this.fileContents);
        this.fileSrc = this.fileContents;
        this.isImage = this.fileType.startsWith('image/');
        this.showControls = isguest?false:true;
        if(this.isPdf){
            Promise.all([
                loadScript(this, JSPDF), this.loadData()
            ]).catch(error => {
                this.showToastMessage('Error loading Preview Libraries', "Error", 'Error');
                console.log('ERROR', error);
            });
        }
        
    }
    get imageStyle() {
        return `transform: scale(${this.zoomLevel}) rotate(${this.rotation}deg);`;
    }
    get pdfStyle() {
        return `transform: scale(${this.zoomLevel});`;
        }
    zoomIn() {
        this.zoomLevel += 0.1;
    }
    zoomOut() {
        if (this.zoomLevel > 0.1) {
        this.zoomLevel -= 0.1;
    }
    }
    rotate() {
        this.rotation += 90;
        if (this.rotation === 360) {
            this.rotation = 0;
        }
    }
    handleCloseModal(){
        const closeEvent = new CustomEvent('close', {
            detail: {
            },

        });
        this.dispatchEvent(closeEvent);   
    }

    loadData(){
        try {
            //const iframe = event.target;
            const base64Data = this.fileContents.split(',')[1];
            console.log(this.template.querySelector('.preview-pdf'));
            if (!this.isValidBase64(base64Data)) {
                console.log('not valid');
            }
            var blob_url = URL.createObjectURL(new Blob([this.b64toBlob(this.fileContents.split(',')[1])], { type: 'application/pdf' }));
            console.log(blob_url);
            this.testBlobUrl(blob_url);
            this.viewerUrl = this.viewerUrl + encodeURIComponent(blob_url);
        } catch (error) {
            console.error(error);
        }
    }

    b64toBlob(b64Data,contentType,sliceSize){
        var binary_string = window.atob(b64Data);
        var len = binary_string.length;
        var bytes = new Uint8Array(len);
        for (var i = 0; i < len; i++) {
            bytes[i] = binary_string.charCodeAt(i);
        }
        console.log(bytes.buffer);
        return bytes.buffer;
    }
    isValidBase64(str) {
        const base64Regex = /^(?:[A-Za-z0-9+\/]{4})*?(?:[A-Za-z0-9+\/]{2}==|[A-Za-z0-9+\/]{3}=)?$/;
        return base64Regex.test(str);
    }

    async testBlobUrl(blobUrl) {
        try {
            const response = await fetch(blobUrl);
            if (response.ok) {
                console.log('Blob URL is valid');
            } else {
                console.error('Blob URL is invalid');
            }
        } catch (error) {
            console.error('Blob URL is invalid', error);
        }
    }
}