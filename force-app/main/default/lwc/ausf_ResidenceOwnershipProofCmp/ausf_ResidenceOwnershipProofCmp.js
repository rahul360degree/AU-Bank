import { LightningElement, track, api, wire } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import {NavigationMixin} from 'lightning/navigation'

import uploadFile from '@salesforce/apex/AUSF_Utility.uploadFile';
import getRelatedFiles from '@salesforce/apex/AUSF_Utility.getRelatedFiles';
import createDocumentChecklist from '@salesforce/apex/AUSF_Utility.createDocumentChecklist';
import deleteSelectedFile from '@salesforce/apex/AUSF_Utility.deleteSelectedFile';
import test from '@salesforce/apex/AUSF_Utility.test';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import JSZIP from '@salesforce/resourceUrl/jszip'; // The static resource name for JSZip
import { loadScript } from 'lightning/platformResourceLoader';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';


export default class Ausf_ResidenceOwnershipProofCmp extends NavigationMixin(LightningElement) {

    screenName = 'Residence Ownership Proof';
    headerContents = 'Apply for Personal Loan';
    headerDescription
    stepsInCurrentJourney
    currentStep
    showContents = true;
    enableBackButton = true;

    showLoader = true;
    isMultipleAllowed = true;
    insertFiles = false;
    titleText = 'Residence ownership proof';
    subtitleText = 'It helps the lender verify that you resides at the stated address';
    typeOfBillList = [];
    disableProceedBtn = true;
    openUploadModal = false;
    fileDataList;
    selectedBill;
    previewScreen = false;
    openPreviewModal = false;
    previewFileData
    errorMsg;
    inputClass = 'phone-input';
    labelClass = 'phone-label';
    activeChecklist;
    isPDF;
    allowedFileTypes;
    fileUploadNote;
    metadataTitleValue;
    isOtherSubmit;
    otherDocumentName = '';
    documentChecklist;
    jszipInitialized = false;
    showElectricityBillScreen = false;
    documentMasterName;


    labelImgSRC = Assets + '/AU_Assets/images/Driving_License.png';
    previewImgURL = Assets + '/AU_Assets/images/eye.png';
    deleteImgURL = Assets + '/AU_Assets/images/trash2.png';


    @api loanApplicationId
    @api applicantId

    get cnfButtonClassVar() {
        return this.disableProceedBtn == true ? 'btnDisabled' : 'btnEnabled';
    }

    setInitialData(){
        let billList =  ['Electricity bill', 'Water bill', 'House Tax receipt', 'Others'];
        let uiBillList = [];
        let counter = 0;
        this.previewScreen = false;
        this.fileDataList = null;
        billList.forEach(element => {
            let showInstant = false
            if(element == 'Electricity bill'){
                showInstant = true;
            }
            uiBillList.push({ label: element, index: counter, radioBtnClass: 'round-checkbox', selectionCardClass: 'Selection-card',size: null, isFile: false, showInstant:showInstant });
            counter += 1;
        });
        this.typeOfBillList = uiBillList;
        this.titleText = this.metadataTitleValue;

    }

    connectedCallback(){       
        this.setInitialData();

        getCurrentScreenData({loanApplicationId:this.loanApplicationId, applicantId:this.applicantId,screenName: this.screenName})
            .then(result => {
                console.log(result);

                let loanApplicationData = result.loanApplicationList ? result.loanApplicationList[0] : null;
                let applicantData = result.applicantList ? result.applicantList[0] : null;
                this.documentChecklist = applicantData && applicantData.Document_Checklists__r && applicantData.Document_Checklists__r.length > 0 ? applicantData.Document_Checklists__r : null;
                console.log(this.documentChecklist);
                let activeBill;
                if(this.documentChecklist){
                    this.documentChecklist.forEach(element => {
                        // console.log(element.Active__c);
                        if(element.Active__c){
                            this.activeChecklist = element.Id;
                            activeBill = element;
                            // console.log(bill);
                        }
                    });
                }


                let customTextList = result.screenCustomTextList ? result.screenCustomTextList : null;
                if (customTextList) {
                    customTextList.forEach(element => {
                        if(element.Label == 'Residence Proof Title'){
                            this.titleText = element.Custom_String__c;
                            this.metadataTitleValue = element.Custom_String__c;
                        }else if(element.Label == 'Residence Proof Subitle'){
                            this.subtitleText = element.Custom_String__c;
                        }
                        // else if(element.Label == 'Allowed File Types'){
                        //     this.allowedFileTypes = element.Custom_String__c;
                        // }else if(element.Label == 'File Upload Note'){
                        //     this.fileUploadNote = element.Custom_String__c;
                        // }
                    });
                }

                let metadataToConsider = result.wizardDataDIYList ? result.wizardDataDIYList : result.wizardDataAssistedList ? result.wizardDataAssistedList : [];
                if (metadataToConsider && metadataToConsider.length > 0) {
                    this.stepsInCurrentJourney = parseInt(metadataToConsider[0].Overall_Step__c);
                    this.currentStep = parseInt(metadataToConsider[0].Progress_in_Current_Step__c);
                    this.headerDescription = metadataToConsider[0].Category__c;
                }

                if(activeBill){
                    if(this.template.querySelectorAll('input[type="checkbox"]') && this.template.querySelectorAll('input[type="checkbox"]').length > 0){
                        this.template.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                            if(cb.value == activeBill.Document_Name__c){
                                cb.checked = true;
                                this.selectedBill = cb.value;
                            }else if(activeBill.Document_Name__c && activeBill.Document_Name__c.includes('house') && cb.value == 'House Tax receipt'){
                                cb.checked = true;
                                this.selectedBill = cb.value;
                            }else if(activeBill.Owned_Address_Proof_Type__c && activeBill.Owned_Address_Proof_Type__c.includes('Others') && cb.value == 'Others'){
                                cb.checked = true;
                                this.selectedBill = cb.value;
                                this.otherDocumentName = activeBill.Document_Name__c;
                                this.labelClass = 'phone-label-value';
                                this.typeOfBillList = this.typeOfBillList.reduce((acc, item) => {
                                    if (item.label == 'Others') {
                                        acc.push({...item,label:'Others ('+this.otherDocumentName+')'});
                                    }else{
                                        acc.push(item);
                                    }
                                    return acc;
                                }, []);
                            }
                        })
                        this.disableProceedBtn = this.selectedBill ? false : true;
                    }else{
                        setTimeout(() => {
                        this.template.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                            if(cb.value == activeBill.Document_Name__c){
                                cb.checked = true;
                                this.selectedBill = cb.value;
                            }else if(activeBill.Document_Name__c && activeBill.Document_Name__c.includes('house') && cb.value == 'House Tax receipt'){
                                cb.checked = true;
                                this.selectedBill = cb.value;
                            }else if(activeBill.Owned_Address_Proof_Type__c && activeBill.Owned_Address_Proof_Type__c.includes('Others') && cb.value == 'Others'){
                                cb.checked = true;
                                this.selectedBill = cb.value;
                                this.otherDocumentName = activeBill.Document_Name__c;
                                this.labelClass = 'phone-label-value';
                                this.typeOfBillList = this.typeOfBillList.reduce((acc, item) => {
                                    if (item.label == 'Others') {
                                        acc.push({...item,label:'Others ('+this.otherDocumentName+')'});
                                    }else{
                                        acc.push(item);
                                    }
                                    return acc;
                                }, []);
                            }
                        })
                        this.disableProceedBtn = this.selectedBill ? false : true;
                        }, 300);
                    }
                }

                this.showLoader = false;

            })
            loadScript(this, JSZIP).then(() => {
                this.jszipInitialized = true;
            });
    }

    handleSelection(event) {
        try {
            this.template.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                // console.log(cb.checked);
                if (cb != event.target) {
                    cb.checked = false;
                }else{
                    cb.checked = true;
                }
            });
    
            let selectedIndex = event.currentTarget.dataset.id;
            if(selectedIndex != null){
                console.log(this.typeOfBillList[selectedIndex]);
                let selectedBillLabel = this.typeOfBillList[selectedIndex];
                this.selectedBill = selectedBillLabel.label ? selectedBillLabel.label.includes('Others') ? 'Others' : selectedBillLabel.label : null;
    
                if(selectedBillLabel.label == 'Electricity bill'){
                    this.showElectricityBillScreen = true;
                }else{
                    let checkList;
                    if(this.documentChecklist){
                        this.documentChecklist.forEach(element => {
                            if(element.Document_Name__c == this.selectedBill){
                                checkList = element.Id;
                            }else if(element.Owned_Address_Proof_Type__c && element.Owned_Address_Proof_Type__c.includes('Others') && this.selectedBill == 'Others'){
                                checkList = element.Id;
                            }
                        });
                    }
                    console.log(checkList);
                    if(!checkList){
                        this.documentMasterName = this.selectedBill == 'House Tax receipt' ? 'House tax' : this.selectedBill
                        this.openUploadModal = true;
                        this.disableProceedBtn = true;
                    }else{
                        this.activeChecklist = checkList;
                        this.disableProceedBtn = false;
                    }
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleSubmitMethod(){
        try {
            this.showLoader = true;
            console.log('in submit',this.previewScreen,this.fileDataList,this.selectedBill);

            if(!this.previewScreen){
                if(this.fileDataList){
                    let docChecklistObj = {
                        'Document_Name__c': this.selectedBill,
                        'Applicant__c': this.applicantId,
                        'Loan_Application__c': this.loanApplicationId,
                        'Active__c': true,
                        'Owned_Address_Proof_Type__c':this.selectedBill == 'House Tax receipt' ? 'House tax' : this.selectedBill,
                    }
                    console.log(docChecklistObj);
                    createDocumentChecklist({masterName:docChecklistObj.Owned_Address_Proof_Type__c,documentChecklistObj:JSON.stringify(docChecklistObj)})
                    .then(checkListResponse=>{
                        console.log(checkListResponse);
                        if(checkListResponse){
                            this.activeChecklist = checkListResponse;
                            let updatedData = [];
                            let counter = 1;
                            this.fileDataList.forEach(fileData => {
                                let jsonString = {
                                    'base64':fileData.base64,
                                    'filename':fileData.filename,
                                    'recordId':checkListResponse,
                                    'applicantId':this.applicantId,
                                    'loanId':this.loanApplicationId,
                                    'docMasterName':docChecklistObj.Owned_Address_Proof_Type__c
                                }
                                uploadFile({ jsonString:JSON.stringify(jsonString) })
                                .then(result=>{
                                    if(result){
                                        console.log(result, 'file uploaded');
                                        fileData['contentVersionId'] = result;
                                        updatedData.push({...fileData});
                                        // this.fileData = null;
                                        if(counter == this.fileDataList.length){
                                            let title = `Files uploaded successfully!!`
                                            const toastEvent = new ShowToastEvent({
                                                title, 
                                                variant:"success"
                                            })
                                            this.dispatchEvent(toastEvent); 
    
                                            this.getExistingFiles();
    
                                            // this.showLoader = false;
                                            // console.log(dataList);
                                            if(this.selectedBill == 'Others'){
                                                this.isOtherSubmit = true;
                                            }else{
                                                this.isOtherSubmit = false;
                                            }
                                        }    
                                        counter+=1;   
                                    }
                                })
                                .catch(error=>{
                                    console.error(error);
                                })
                            });
                        }
                    })
                    .catch(error=>{
                        console.error(error);
                    })
                }else{
                    this.getExistingFiles();
                }
            }else{
                if(this.isOtherSubmit){
                    let docChecklistObj = {
                        'Document_Name__c': this.otherDocumentName,
                        'Applicant__c': this.applicantId,
                        'Loan_Application__c': this.loanApplicationId,
                        'Active__c': true,
                        'Owned_Address_Proof_Type__c':'Others',
                        'Owned_Address_Proof_Type_Others__c':this.otherDocumentName,
                        'Id':this.activeChecklist
                    }
                    createDocumentChecklist({masterName:'Others',documentChecklistObj:JSON.stringify(docChecklistObj)})
                    .then(checkListResponse=>{
                        console.log(checkListResponse);
                        if(checkListResponse){
                            console.log(checkListResponse, 'other doc name updated');
                            this.uploadZipFile();
                        }
                    })
                    .catch(error=>{
                        console.error(error);
                    })
                }else{
                    this.uploadZipFile();
                }
            }

        } catch (error) {
            console.error(error);
        }
    }

    uploadZipFile(){
        if (this.jszipInitialized && this.typeOfBillList.length > 0) {
            console.log(this.typeOfBillList);
            let zip = new JSZip();
            this.typeOfBillList.forEach(file => {
                console.log(file);
                zip.file(file.label, new Blob([this.b64toBlob(file.base64.split(',')[1])], { type: file.base64.split(',')[0] }));
            });

            zip.generateAsync({ type: 'blob' })
                .then((zipBlob) => {
                    // Convert blob to base64
                    let reader = new FileReader();
                    reader.onloadend = () => {
                        let base64data = reader.result.split(',')[1];
                        let docChecklistObj = {
                            'Document_Name__c': this.selectedBill,
                            'Applicant__c': this.applicantId,
                            'Loan_Application__c': this.loanApplicationId,
                            'Active__c': true,
                            'Owned_Address_Proof_Type__c':this.selectedBill == 'House Tax receipt' ? 'House tax' : this.selectedBill,
                        }
                        

                        createDocumentChecklist({masterName:docChecklistObj.Owned_Address_Proof_Type__c,documentChecklistObj:JSON.stringify(docChecklistObj)})
                        .then(checkListResponse=>{
                            let jsonString = {
                                'base64':base64data,
                                'filename':'Documents.zip',
                                'recordId':checkListResponse,
                                'applicantId':this.applicantId,
                                'loanId':this.loanApplicationId,
                                'docMasterName':this.selectedBill == 'House Tax receipt' ? 'House tax' : this.selectedBill,
                                'isZipped':true
                            }
                            console.log(jsonString);
                            uploadFile({ jsonString:JSON.stringify(jsonString) })
                            .then(result => {
                                // this.showToast('Success', 'All files zipped and uploaded successfully.', 'success');
                                this.filesToUpload = []; // Clear the selected files after upload

                                let loanApplcationObj = {
                                    'Id': this.loanApplicationId,
                                    'Last_visited_Page__c': this.screenName
                                }
                        
                                updateLoanApplication({ loanApplcationObj: JSON.stringify(loanApplcationObj), loanApplicationId: this.loanApplicationId, screenName: this.screenName })
                                    .then((result) => {
                                        console.log(result, 'Residence SCreen final submitted');
                                        this.showLoader = false;

                                        if(result){
                                            const nextEvent = new CustomEvent('submitevent', {
                                                detail: {
                                                    currentScreen: this.screenName,
                                                }
                                            });
                                            this.dispatchEvent(nextEvent)
                                        }
                                    })
                                    .catch((error) => {
                                        console.error(error);
                                    });
                            })
                            .catch(error => {
                                console.log(error);
                                // this.showToast('Error', 'Error uploading zip file: ' + error.body.message, 'error');
                            });
                        })
                        .catch(error=>{
                            console.error(error);
                        })
                    };
                    reader.readAsDataURL(zipBlob);
                })
                .catch(error => {
                    this.showToast('Error', 'Error creating zip file.', 'error');
                });
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

    getExistingFiles(){
        if(this.selectedBill){

            getRelatedFiles({documentChecklistRec: this.activeChecklist})
            .then(result=>{
                if(result && result.length > 0){
                    console.log(result);
                    let updatedData = [];
    
                    result.forEach(file => {
                        // let reader = new FileReader();
                        // reader.readAsDataURL(file.VersionData);
                        // reader.onloadend = function () {
                        // let base64String = reader.result;
                        // console.log(base64String);
                        // console.log(file.VersionData);
                        // console.log(file.VersionData.replace(/^data:image\/(png|jpeg|jpg);base64,/, ''));
                        // console.log(btoa(file.VersionData));
                        // console.log(atob(file.VersionData.replace(/^data:image\/(png|jpeg|jpg);base64,/, '')));
                        let fileData = {
                            'filename': file.contentVersionObj.Title,
                            'size': (parseFloat(file.contentVersionObj.ContentSize)/1000) + ' kbs',
                            'fileType':file.contentVersionObj.FileExtension && !file.contentVersionObj.FileExtension.includes('pdf') ? 'image/'+file.contentVersionObj.FileExtension : 'application/'+file.contentVersionObj.FileExtension,
                            'isPdf': file.contentVersionObj.FileExtension && file.contentVersionObj.FileExtension.includes('pdf') ? true : false,
                            'contentVersionId':file.contentVersionObj.Id,
                            'base64':file.base64
                        }
                        updatedData.push(fileData);
                        // }
    
                    });
                    this.setFileData(updatedData);
                }else{
                    this.showLoader = false;
                    this.openUploadModal = true;
                }
            })
            .catch(error=>{
                console.error(error);
            })
        }
    }

    setFileData(updatedData){
        let filesList = updatedData;
        this.previewScreen = true;
        this.titleText = this.selectedBill ? this.selectedBill != 'Others' ? this.selectedBill : this.titleText : this.titleText ;
        let dataList = [];
        let counter = 0;
        filesList.forEach(element => {
            // 'data:'+element.fileType+';base64,'+
            let obj = { label: element.filename, index: counter, radioBtnClass: 'round-checkbox', selectionCardClass: 'Selection-card',size:element.size, isFile: true, base64: 'data:'+element.fileType+';base64,'+element.base64,isOther: false, fileType: element.fileType, isPdf: element.isPdf, contentVersionId:element.contentVersionId }
            console.log((counter+1) == filesList.length,this.selectedBill);
            if((counter+1) == filesList.length && this.selectedBill == 'Others'){
                obj.isOther = true;
                this.disableProceedBtn = true;
            }
            dataList.push(obj);
            counter++;

        });
        this.typeOfBillList = dataList;
        this.showLoader = false;
        console.log(this.typeOfBillList);
    }

    handleFileUpload(event) {
        console.log(JSON.stringify(event.detail));
        console.log(this.selectedBill);
        try {
            this.fileDataList = null;
            this.fileDataList = event.detail.filesList;
            this.disableProceedBtn = false;
            this.openUploadModal = false;
            if(this.selectedBill){
                this.template.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                    // console.log(cb.checked);
                    if (cb.value != this.selectedBill) {
                        cb.checked = false;
                    }else{
                        cb.checked = true;
                    }
                });
            }
        } catch (error) {
            console.error(error);
        }
    }

    handlePreview(event){
        try {
            let selectedIndex = event.currentTarget.dataset.index;
            console.log('selectedIndex',selectedIndex);
            if(selectedIndex != null){
                let selectedFile = this.typeOfBillList[selectedIndex];
                console.log('file',selectedFile);
                this.previewFileData = selectedFile.base64;
                this.isPDF = selectedFile.isPdf;
                // this.template.querySelector('.elementHoldingHTMLContent').innerHTML = atob(this.previewFileData);
                this.openPreviewModal = true;
                // var baseURL = 'https://'+location.host+'/';
                // var previewURL = baseURL + 'sfc/servlet.shepherd/version/renditionDownload?rendition=THUMB720BY480&versionId=068C1000003W8GsIAK';
                // this[NavigationMixin.Navigate]({
                //     type: 'standard__webPage',
                //     attributes: {
                //     url: previewURL
                //     }
                // }, false );
    
        }
        } catch (error) {
            console.log(error);
        }

    }

    handleDeleteFile(event){
        try {
            let selectedIndex = event.currentTarget.dataset.index;
            console.log('selectedIndex',selectedIndex);
            if(selectedIndex != null){
                let selectedFile = this.typeOfBillList[selectedIndex];
                console.log('file',selectedFile);
                if(selectedFile.contentVersionId){
                    this.showLoader = true;
                    deleteSelectedFile({contentVersionId:selectedFile.contentVersionId})
                    .then(response=>{
                        console.log(response,'file deleted');
                        if(response){
                            let dataList = this.typeOfBillList;
                            dataList.splice(selectedIndex,1);
                            let counter=0;
                            dataList.forEach(element => {
                                element.index = counter;
                                counter +=1;
                            });
                            if(dataList.length > 0){
                                this.typeOfBillList = dataList;
                            }else{
                                this.setInitialData();
                            }
                            console.log(this.typeOfBillList);
                            this.showLoader = false;
                            let title = `File deleted successfully!!`
                            const toastEvent = new ShowToastEvent({
                                title, 
                                variant:"success"
                            })
                            this.dispatchEvent(toastEvent); 
                        }
                    })
                    .catch(error=>{
                        console.error(error);
                    })
                }
            }
        } catch (error) {
            console.error(error);
        }
    }

    handleCloseModal(){
        this.openPreviewModal = false;
        this.openUploadModal = false;
    }

    handleDocNameChange(event){
        this.labelClass = 'phone-label-value';
        this.otherDocumentName = event.target.value;
        if(this.otherDocumentName){
            this.disableProceedBtn = false;
        }else{
            this.disableProceedBtn = true;
        }
    }

    handleELectricityScreen(){
        this.showElectricityBillScreen = false;
    }


}