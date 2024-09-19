import { LightningElement, track, api, wire } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import uploadFile from '@salesforce/apex/AUSF_Utility.uploadFile';
import getDocumentMaster from '@salesforce/apex/AUSF_Utility.getDocumentMaster';


export default class Ausf_FileUploadCmp extends LightningElement {

    filesList = [];
    @api applicantId
    @api loanApplicationId
    @api isMultipleAllowed
    @api recordId
    @api insertFiles
    @api fileUploadNote
    @api allowedFileTypes
    @api documentMasterName //= 'Resident ownership proof';
    fileSize = 1000;
    noOfUploadFile = 2;
    errorMsg
    showLoader = false;
    warningIconURL = Assets +'/AU_Assets/images/warning_icon.png';
    closeIconURL = Assets + '/AU_Assets/images/Outline/x.png';
    firstImgURL = Assets + '/AU_Assets/images/wrong1.png';
    secondImgURL = Assets + '/AU_Assets/images/wrong2.png';
    rightImgUrl = Assets + '/AU_Assets/images/rightImg.png';
    tickImgURL = Assets + '/AU_Assets/images/check-mark1.png';

    connectedCallback(){
        getDocumentMaster({masterName:this.documentMasterName}).then(result=>{
            if(result){
                this.allowedFileTypes = result.Supported_Doc_Types__c;
                this.isMultipleAllowed = result.Multiple_Upload__c;
                this.fileSize = result.File_Size__c;
                this.noOfUploadFile = result.No_Of_Document_Upload__c;
                this.fileUploadNote = result.File_Upload_Note__c;
            }
        })
        .catch(error=>{
            console.error(error);
        })
    }

    handleCloseModal(){
        const closeEvent = new CustomEvent('close', {
            detail: {
            },
        });
        this.dispatchEvent(closeEvent);
    }

    async handleFileChange(event) {
        const files = event.target.files;
        console.log(files);
        let validateFilesSize = true;
        for (let index = 0; index < files.length; index++) {
            const file = files[index];
            if(files.length > this.noOfUploadFile){
                this.errorMsg = 'Max. '+this.noOfUploadFile+' files can be uploaded';
                validateFilesSize = false;
            }
            console.log('file size'+file.size);
            let fileDivider = parseInt(this.fileSize)*1000;
            console.log(parseFloat(file.size/(parseInt(1000000))));
            if(parseFloat(file.size/1000000) > parseInt(this.fileSize/1000)){
                this.errorMsg = 'File size should be less than '+parseInt(this.fileSize/1000)+ 'MB';
                validateFilesSize = false;
            }
        }
        if(validateFilesSize){
            let rawFileList = await Promise.all(
                [...event.target.files].map(file => this.readFile(file))
            );
            console.log(rawFileList);
            this.handleFileUpload(rawFileList)
        }
    }
    
    readFile(fileSource) {
        return new Promise((resolve, reject) => {
          const fileReader = new FileReader();
          fileReader.onerror = () => reject(fileReader.error);
          fileReader.onload = () => resolve({ file:fileSource, base64: fileReader.result.split(',')[1]});
          fileReader.readAsDataURL(fileSource);
        });
    }

    handleFileUpload(rawFileList) {
        try {
                let files = rawFileList;
                let counter = 1;
                for (let index = 0; index < files.length; index++) {

                    const file = files[index].file;
                        var base64 = files[index].base64;
                        let fileData = {
                            'filename': file.name,
                            'recordId': this.recordId,
                            'size': (parseFloat(file.size)/1000) + ' kbs',
                            'fileType':file.type,
                            'isPdf': file.type && file.type.includes('pdf') ? true : false,
                            'base64':base64,
                            'contentVersionId':null
                        }

                        if(this.insertFiles){
                            this.showLoader = true;
                            let jsonString = {
                                'base64':fileData.base64,
                                'filename':fileData.filename,
                                'recordId':this.recordId,
                                'applicantId':this.applicantId,
                                'loanId':this.loanApplicationId,
                                'docMasterName':this.documentMasterName
                            }
                            uploadFile({ jsonString:JSON.stringify(jsonString) })
                            .then(result=>{
                                fileData['contentVersionId'] = result;
                                this.filesList.push({...fileData});
                                // this.fileData = null;
                                if(counter == files.length){
                                    this.showLoader = false;
                                    let title = `Files uploaded successfully!!`
                                    const toastEvent = new ShowToastEvent({
                                        title, 
                                        variant:"success"
                                    })
                                    this.dispatchEvent(toastEvent); 

                                    const successEvent = new CustomEvent('success', {
                                        detail: {
                                            'filesList': this.filesList
                                        },
                                    });
                                    this.dispatchEvent(successEvent);
                                }    
                                counter+=1;   
                            })
                            .catch(error=>{
                                console.error(error);
                            })
                        }else{
                            this.filesList.push(fileData);
                            if(this.filesList.length == rawFileList.length){
                                const successEvent = new CustomEvent('success', {
                                    detail: {
                                        'filesList': this.filesList
                                    },
                                });
                                this.dispatchEvent(successEvent);
                            }
                        }
                }
            } 
            catch (error) {
                console.error(error);
            }   
    }
}