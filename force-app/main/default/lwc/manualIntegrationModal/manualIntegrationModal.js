import { api, track } from 'lwc';
import LightningModal from 'lightning/modal';
import manuallyCompleteIntegration from '@salesforce/apex/AUSF_IntegrationContainerController.manuallyCompleteIntegration';

export default class ManualIntegrationModal extends LightningModal {
    @api inputIds;
    remarks = '';
    @track filesData = [];
    hasFiles = false;
    fileNames = [];
    hasError = false;
    error = '';

    handleRemarks(event){
        this.remarks = event.target.value;
    }

    handleFileUpload(event){
        let totalFiles = event.target.files.length;
        if(totalFiles > 0){
            for(var i = 0; i < totalFiles; i++){
                let file = event.target.files[i];
                
                let reader = new FileReader();
                reader.onload = e => {
                    let fileName = '';
                    //let index = this.filesData.length > 0 ? this.filesData.length : 0;
                    var fileContents = reader.result.split(',')[1];
                    this.filesData.push({'fileName':file.name, 'fileContent':fileContents});
                    
                    if(this.filesData.length > 0){
                        let index = 0;
                        let fileList = [];
                        this.filesData.forEach(item =>{
                            let fileItem = {};
                            fileItem.fileName = item.fileName;
                            fileItem.fileContent = item.fileContent;
                            fileItem.index = index;
                            fileList.push(fileItem);
                            index++;
                        })
                        this.filesData = fileList;
                    }
                    this.fileNames.push(fileName);
                    this.hasFiles = true;
                };
                reader.readAsDataURL(file);
            }
        }
    }

    handleSubmit(){
        const allValid = [
            ...this.template.querySelectorAll('lightning-input'),
        ].reduce((validSoFar, inputCmp) => {
            inputCmp.reportValidity();
            return validSoFar && inputCmp.checkValidity();
        }, true);
        if (allValid) {
            manuallyCompleteIntegration({ intgChecklistId : this.inputIds.intgChecklitsId, recordId : this.inputIds.recordId, remarks: this.remarks, fileData: this.filesData})
            .then(result =>{
                this.hasError = false;
                this.close('close');
            })
            .catch(error =>{
                console.warn(error);
                this.error = error;
                this.hasError = true;
            })
        }
        inputCmp.reportValidity();
    }
    handleDelete(event){
        let index = Number.parseInt(event.target.dataset.id);

        /*let result = */this.filesData.splice(index,1);
        //this.filesData = result;
        if(this.filesData.length == 0){
            this.hasFiles = false;
        }
    }



}