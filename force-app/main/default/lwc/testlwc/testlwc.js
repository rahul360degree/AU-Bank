import { LightningElement, api, track } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';
import viewer from '@salesforce/resourceUrl/pdfjstest';
import JSPDF from '@salesforce/resourceUrl/jspdftest';



import isguest from '@salesforce/user/isGuest';
//import getPdfUrl from '@salesforce/apex/AUSF_Utility.getPdfUrl';
import test from '@salesforce/apex/AUSF_Utility.test';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';

export default class Ausf_FilePreviewCmp extends LightningElement {

    fileData;
    @api fileContents
    // @api isPdf = true
    imgStyling
    fileType
    @track showControls = true;
    closeIconURL = Assets + '/AU_Assets/images/Outline/x.png';
    fileEncodedata;

    @track fileSrc;
    @track isImage = false;
    @track isPdf = true;
    @track zoomLevel = 1;
    @track rotation = 0;
    pdfUrl;
    // connectedCallback() {
    //     this.fileType = this.isPdf?'application/pdf':'image/png';
    //     //this.fileSrc = this.fileContents;
    //     this.isImage = this.fileType.startsWith('image/');
    //     this.isPdf = true;
    //     this.showControls = isguest?false:true;
    //     if(this.isPdf){
    //         getPdfUrl({ contentDocumentId: '069C1000003PUnaIAG' })
    //         .then(result => {
    //             this.fileEncodedata = result;
    //         })
    //         .catch(error => {
    //             console.error('Error getting PDF URL:', error);
    //         });

    //         test({id:'a0EC1000002ZmgYMAS'})
    //         .then(p=>{
    //             console.log(p);
    //             // p= "data:image/jpeg;base64,"+p;
    //             // console.log(URL.createObjectURL(new Blob([this.base64ToArrayBuffer(p)], { type: 'image/jpeg' })));
    //             // console.log(encodeURIComponent(URL.createObjectURL(new Blob([this.base64ToArrayBuffer(p)], { type: 'image/jpeg' }))));
    //             this.fileContents = viewer + '/pdfjstest/web/viewer.html?file=' + encodeURIComponent(URL.createObjectURL(new Blob([this.base64ToArrayBuffer(p)], { type: 'image/jpeg' })));
    //             // console.log(this.fileContents);
    //             // this.fileContents = viewer + '/pdfjstest/web/viewer.html';
    //             // console.log(this.template.querySelector('iframe'));
    //             // this.template.querySelector('iframe').contentWindow.postMessage(p, window.location.origin);

    //         })
    //         //this.loadData();
    //     }
    // }


    @api contentversionid;
    @api fileId;
    @api heightInRem = 40;
    @api extension;
    blobPdf;
    src = viewer + '/pdfjstest/web/viewer.html?file='; ///resource/pdfjs/pdfjs/web/viewer.html?file=
    blbUrl = '';
    blobPdfFinal;
    base64dataFinal = '';
    @track hex = '';
    @track pdfdata;
    plainTxt;


    connectedCallback() {
        Promise.all([
            loadScript(this, JSPDF), this.callDoinIt()
        ]).catch(error => {
            this.showToastMessage('Error loading Preview Libraries', "Error", 'Error');
            console.log('ERROR', error);
        });
        //   this.callDoinIt();
    }


    callDoinIt() {
        test({ id: 'a0EC1000002ZmgYMAS' })
            .then(p => {
                console.log(p);
                // this.fileContents = viewer + '/pdfjstest/web/viewer.html?file=' + encodeURIComponent(URL.createObjectURL(new Blob([this.base64ToArrayBuffer(p)], { type: 'image/jpeg' })));
                this.plainTxt = p;
                this.blobPdf = new Blob([this.base64ToArrayBuffer(p)], { type: 'application/pdf' }); //blob data for img
                this.getFileType(this.blobPdf);

            })
        // getRelatedFileByRecordId({ recordId: this.contentversionid })
        //     .then(data => {
        //         if (data) {

        //             this.plainTxt = atob(data);
        //             // console.log('data', data);
        //             this.blobPdf = new Blob([this.base64ToArrayBuffer(data)], { type: 'image/jpeg' }); //blob data for img
        //             //  this.blobPdf = new Blob([this.base64ToArrayBuffer(data)], {type: 'application/pdf'}); //blob data for pdf
        //             this.getFileType(this.blobPdf);
        //         } else if (error) {
        //             this.showToastMessage('Error', 'An Error occur while fetching the file. No File found', 'Error');
        //         }
        //     })
        //     .catch(error => {
        //         console.log('Error in loadApplicantFields: ' + JSON.stringify(error));
        //     })
    }

    getFileType(blobFile) {
        const getblob = blobFile.slice(0, 4);
        const filereader = new FileReader()

        filereader.onload = f => {
            if (filereader.readyState === FileReader.DONE) {
                const uint = new Uint8Array(filereader.result);
                let bytes = [];
                uint.forEach((byte) => {
                    bytes.push(byte.toString(16));
                });
                const hexStr = bytes.join('').toUpperCase();
                this.hex = hexStr;
                this.callMain();
            }
        }
        filereader.readAsArrayBuffer(getblob);

    }

    callMain() {
        console.log('hex type', this.hex);
        this.extension = 'pdf'
        var fileExtension = this.extension.toLowerCase();
        if (fileExtension == 'pdf') {
            //this.showToastMessage('info','Please wait for 4-5 Seconds. PDF is rendering!!!', 'info');
            this.pdfToView();
        } else if (fileExtension == 'jpg' || fileExtension == 'png' || fileExtension == 'jpeg') {
            this.blobToView();
        }
        else if (fileExtension == 'text') {
            this.textFileToView();
        }
        else if (fileExtension == 'Unknown filetype') {
            this.showToastMessage('Error', 'An Error occur while fetching the file. File extension not supported', 'Error');
        }

    }



    pdfToView() {
        try {
            var blobUrl = URL.createObjectURL(this.blobPdf);
            console.log('blobUrl : ' + blobUrl);
            this.src = this.src + encodeURIComponent(blobUrl);
            this.fileContents = this.src
            console.log('src : ' + this.src);
        } catch (error) {
            console.error(error);
        }

        // window.open('https://'+window.location.hostname+'/KotakInternalVlos'+this.src, '_blank');
    }

    textFileToView() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF('p', 'pt', 'a4');
        var reader = new FileReader();
        reader.onload = f => {
            var base64data = reader.result;
            let obj = { 'maxWidth': 550 };
            //let charArray = this.plainTxt.split(' ');
            //let loopCount = Math.ceil(charArray.length/350);
            let loopCount = Math.ceil(this.plainTxt.length / 800);
            let start = 0;
            let final = 0;
            for (let i = 1; i <= loopCount; i++) {
                let textForSinglePage = this.plainTxt.slice(start, i * 1000);
                let indexOfLastSpace = textForSinglePage.lastIndexOf(" ");
                final = final + indexOfLastSpace;
                if (i < loopCount) {
                    doc.text(this.plainTxt.slice(start, final), 20, 20, obj);
                } else if (loopCount == 1) {
                    doc.text(this.plainTxt.slice(0, textForSinglePage.length), 20, 20, obj);
                } else {
                    doc.text(this.plainTxt.slice(start, final + textForSinglePage.length), 20, 20, obj);
                }

                start = final;
                if (i < loopCount) {
                    doc.addPage('a4', 'p');
                }
            }
            this.src = location.origin + this.src + encodeURIComponent(doc.output('bloburl'));
            // window.open('https://'+window.location.hostname+'/KotakInternalVlos'+this.src, '_blank');
        }
        reader.readAsDataURL(this.blobPdf);
    }

    blobToView() {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF('p', 'pt', 'a4');
        var reader = new FileReader();
        reader.onload = f => {
            var base64data = reader.result;
            //doc.text(5, 5, this.plainTxt);
            //doc.addPage('a4', 'p');
            //doc.text(20, 20, this.plainTxt);
            //doc.addImage(base64data, 'JPEG', 100, 160, 400, 276);
            doc.addImage(base64data, 'JPEG', 10, 16, 500, 700);
            this.src = location.origin + this.src + encodeURIComponent(doc.output('bloburl'));
            // window.open('https://'+window.location.hostname+'/KotakInternalVlos'+this.src, '_blank');
        }
        reader.readAsDataURL(this.blobPdf);
    }

    /*getMimetype(signature) {
        switch (signature) {
            case '89504E47':
                return 'image/png'
            case '47494638':
                return 'image/gif'
            case '25504446':
                return 'application/pdf'
            case 'FFD8FFDB':
            case 'FFD8FFE0':
                return 'image/jpeg'
            case '504B0304':
                return 'application/zip'
            case '564C4F53':
                return 'text/plain';//text/plain
            default:
                return 'Unknown filetype'
        }
    }*/

    base64ToArrayBuffer(base64) {
        console.log('called', base64);
        var binary_string = window.atob(base64);
        var len = binary_string.length;
        var bytes = new Uint8Array(len);
        for (var i = 0; i < len; i++) {
            bytes[i] = binary_string.charCodeAt(i);
        }
        console.log(bytes.buffer);
        return bytes.buffer;
    }

    get pdfHeight() {
        return 'height: ' + this.heightInRem + 'rem';
    }



    showToastMessage(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }


}