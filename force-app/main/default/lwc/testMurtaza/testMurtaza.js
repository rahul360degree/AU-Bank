import { LightningElement,api,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import getScreenCustomTextRecords from '@salesforce/apex/AUSF_Utility.getScreenCustomTextRecords';
import createEmploymentDetails from '@salesforce/apex/AUSF_Utility.createEmploymentDetails';
import createDocumentChecklistRec from '@salesforce/apex/AUSF_Utility.createDocumentChecklistRec';
import getGenericBuisnessMetadaData from '@salesforce/apex/AUSF_Utility.getGenericBuisnessMetadaData';
import uploadFile from '@salesforce/apex/AUSF_Utility.uploadFile';
import getEmploymentDetail from '@salesforce/apex/AUSF_Utility.getEmploymentDetail'; // Import the Apex method
export default class TestMurtaza extends LightningElement {
    GroupUrl = AU_Assets + '/AU_Assets/images/Group.png';
    AUDrivingLicenseImg = AU_Assets + '/AU_Assets/images/File_Upload.png';
    previewImg = AU_Assets + '/AU_Assets/images/eye.png';
    deleteImg = AU_Assets + '/AU_Assets/images/trash2.png';
    AUChevronRightImg = AU_Assets + '/AU_Assets/images/Outline/chevron-right.png';
    AUVectorImg = AU_Assets + '/AU_Assets/images/Vector_973.png';
    AUMaskGrpImg = AU_Assets + '/AU_Assets/images/Mask_group1.png';
    AUGrpImg = AU_Assets + '/AU_Assets/images/Group_1321314549.png';
    AUErrorImg = AU_Assets + '/AU_Assets/images/warning_icon.png';
   
    //For header 
    screenName = 'Profession Type';
    headerContents = 'Apply for Personal Loan';
    headerDescription;
    stepsInCurrentJourney;
    currentStep;
    showContents = true;
    enableBackButton = true;

    //For main screen
    title;
    subtitle;
    isDocNumber = false;
    isBuisnessPrfName = false;
    isDateOfIncopration = false;
    isRegisteredBuisnessName = false;
    isUploadSection = false;

    @api applicantId = 'a02C1000002WEptIAG';
    @api loanApplicationId;

    documentNumber = '';
    businessProofName = '';
    registeredBusinessName = '';
    dateOfIncorporation = '';
    errorMsg = '';
    invalidDate = '';
    documentMasterName = 'Business Proof-Others';
    documentCategory = 'Employment Document';
    activeChecklist;
    
    disableSubmitBtn = true;
    DOBinput = 'phone-input customDateInput';
    DOBlabel = 'phone-label';
    dInputClass = 'phone-input';
    dInputLabel = 'phone-label';
    businessInput = 'phone-input';
    businessLabel = 'phone-label';
    registeredInput = 'phone-input';
    registeredLabel = 'phone-label';
    employmentDetId;
    addressId;
    activity;
    sector;
    subIndustry;
    industry;
    employmentDetId;
    //for upload file and delete file
   openUploadModal = false;
   openPreviewModal = false;
   @track showUploadDocument = false;
   isMultipleAllowed = true;
   insertFiles = false;
   fileDataList = [];
   allowedFileTypes;
   fileUploadNote; 
   isPDF;
   previewFileData;
   fieldName;
   @api componentLabelName = 'Medical degree';
   //address modal
   showAddressModal = false;
   employmentRecordName = '';
   employeeRecordType = '';
   //industry 
   isSelectTitleHide = true;
   hideMainScreen = false;
   componentHeight = '1123px';
   fields = [
    { label: 'Sector', name: 'Sector', selectedValue: '', disabled: false, containerClass: 'field-container',hasSearch:false },
    { label: 'Industry', name: 'Industry', selectedValue: '', disabled: true, containerClass: 'field-container disabled',hasSearch:true },
    { label: 'Sub Industry', name: 'Sub_Industry', selectedValue: '', disabled: true, containerClass: 'field-container disabled',hasSearch:true },
    { label: 'Activity', name: 'Activity', selectedValue: '', disabled: true, containerClass: 'field-container disabled',hasSearch:true }];

   

   get cnfButtonClassVar() {
    return this.disableSubmitBtn == true ? 'btnDisabled' : 'btnEnabled';
   }

    connectedCallback() {    
         this.getInitialData();                
    }
    renderedCallback(){
        this.adjustBackgroundBoxHeight();
    }

     // Fetches initial data required when component loads 
    getInitialData(){
         getCurrentScreenData({ loanApplicationId: this.loanApplicationId, screenName: this.screenName })
         .then(result => {
              console.log('result first ',result);
         let metadataToConsider = result.wizardDataDIYList ? result.wizardDataDIYList : result.wizardDataAssistedList ? result.wizardDataAssistedList : [];
         if (metadataToConsider && metadataToConsider.length > 0) {
              this.stepsInCurrentJourney = parseInt(metadataToConsider[0].Overall_Step__c);
              this.currentStep = parseInt(metadataToConsider[0].Progress_in_Current_Step__c);
              this.headerDescription = metadataToConsider[0].Category__c;
         }
         })
         .catch(error => {
         console.error(error);
         });

        //  getScreenCustomTextRecords({screenName: this.screenName})
        //  .then(result => {
        //      console.log('metadata result ',result);
        //      result.forEach(element => {
        //          if(element.DeveloperName == 'Business_proof_subtitle'){
        //              this.subtitle = element.Custom_String__c;
        //           }
        //          if(element.DeveloperName == 'Business_proof'){
        //             this.title = element.Custom_String__c;
        //          }
        //          if(element.DeveloperName == 'Invalid_Date'){
        //            this.invalidDate = element.Custom_String__c;
        //         }
        //       });
        //  }) 
        //  .catch(error => {
        //      console.error(error);
        //  });
         getGenericBuisnessMetadaData({labelName: this.componentLabelName})
         .then(result => {
             console.log('metadata result ',result);
             if(result){
                this.subtitle = result[0].Page_Sub_Title__c
                this.title = result[0].Page_Title__c
                this.isDocNumber = result[0].isDocNumber__c;
                this.isBuisnessPrfName = result[0].isBuisnessPrfName__c;
                this.isDateOfIncopration = result[0].isDateOfIncopration__c;
                this.isRegisteredBuisnessName = result[0].isRegisteredBuisnessName__c;
                this.isUploadSection = result[0].isUploadSection__c;
                this.componentHeight = result[0].component_Height__c;
                this.employmentRecordName = result[0].Employment_Record_Name__c;
                this.employeeRecordType = result[0].Employment_Record_Type__c;
                this.adjustBackgroundBoxHeight();
                this.getExistingData();
             }
         }) 
         .catch(error => {
             console.error(error);
         });
         // Fetch employment detail record for the given applicant ID
        
    }

    getExistingData(){
        getEmploymentDetail({ applicantId: this.applicantId,recordName:this.employmentRecordName })
        .then((result) => {
            if (result && result.length > 0) {
                this.employmentDetId = result[0].Id; // Store the existing record ID
                this.documentNumber = result[0].Document_Number__c?result[0].Document_Number__c:'';
                this.dInputLabel = this.documentNumber?'phone-label-value':'phone-label';
                this.businessProofName = result[0].Others_Business_Proof_Name__c?result[0].Others_Business_Proof_Name__c:'';
                this.businessLabel = this.businessProofName?'phone-label-value':'phone-label';
                this.dateOfIncorporation = result[0].Date_of_Incorporation__c?result[0].Date_of_Incorporation__c:'';
                this.DOBlabel = this.dateOfIncorporation?'phone-label-value':'phone-label';
                this.registeredBusinessName = result[0].Registered_Business_name__c?result[0].Registered_Business_name__c:'';
                this.registeredLabel = this.registeredBusinessName?'phone-label-value':'phone-label';
                this.sector = result[0].Sector__c?result[0].Sector__c:'';
                this.industry = result[0].Industry__c?result[0].Industry__c:'';
                this.subIndustry = result[0].Sub_Industry__c?result[0].Sub_Industry__c:'';
                this.activity = result[0].Activity__c?result[0].Activity__c:'';

                // Populate fields array with the values
                this.fields = [
                    { label: 'Sector', name: 'Sector', selectedValue: this.sector, disabled: false, containerClass: 'field-container', hasSearch: false,labelClass: this.sector?'field-label has-value':'field-label' },
                    { label: 'Industry', name: 'Industry', selectedValue: this.industry, disabled: this.sector?false:true, containerClass: this.industry?'field-container':'field-container disabled', hasSearch: true,labelClass: this.industry?'field-label has-value':'field-label' },
                    { label: 'Sub Industry', name: 'Sub_Industry', selectedValue: this.subIndustry, disabled: this.industry?false:true, containerClass: this.subIndustry?'field-container':'field-container disabled', hasSearch: true,labelClass: this.subIndustry?'field-label has-value':'field-label' },
                    { label: 'Activity', name: 'Activity', selectedValue: this.activity, disabled: this.subIndustry?false:true, containerClass: this.activity?'field-container':'field-container disabled', hasSearch: true,labelClass: this.activity?'field-label has-value':'field-label' }
                ];
            }
        })
        .catch((error) => {
            this.errorMsg = error.body.message;
        });
    }

    handleDocumentNumberInput(event){
         this.documentNumber = event.target.value;
         this.documentNumber = this.documentNumber.toUpperCase().replaceAll(' ','');
         if (this.documentNumber == '') {
              this.dInputClass = 'phone-input customDateInput';
              this.dInputLabel = 'phone-label';
        }
        else {
              this.dInputLabel = 'phone-label-value';
         }
         this.handleAllInputValues();
    }

    handleBusinessProofNameInput(event){
         this.businessProofName = event.target.value;
         if (this.businessProofName == '') {
              this.businessInput = 'phone-input customDateInput';
              this.businessLabel = 'phone-label';
         }
        else {
              this.businessLabel = 'phone-label-value';
         }
         this.handleAllInputValues();

    }

    handleRegisteredBusinessNameInput(event){
         this.registeredBusinessName = event.target.value;
         if (this.registeredBusinessName == '') {
              this.registeredInput = 'phone-input customDateInput';
              this.registeredLabel = 'phone-label';
        }
        else {
              this.registeredLabel = 'phone-label-value';
         }
         this.handleAllInputValues();

    }

    handledateOfIncorporationInput(event){
         this.dateOfIncorporation = event.target.value;
         if (this.dateOfIncorporation == '') {
              this.DOBinput = 'phone-input customDateInput';
              this.DOBlabel = 'phone-label';
        }
        else {
         this.DOBlabel = 'phone-label-value';
         const corpDate = new Date(this.dateOfIncorporation); 
         const currentDate = new Date();
         if(corpDate >= currentDate){
            this.errorMsg = this.invalidDate;
           console.log('The input date is not in the past.');
         }else{
              this.errorMsg = '';
         } 
         }
         this.handleAllInputValues();

    }

    dateFocused(event){
         if(event.target.type == 'text' ){
                 event.target.type = 'date';
         }
    }

    dateBlurred(event){
         if(event.target.value == ''){
                 event.target.type = 'text';
         }
    }

    handleAllInputValues(){
         if(this.documentNumber){
        // if(this.documentNumber && this.dateOfIncorporation && this.businessProofName && this.registeredBusinessName 
           // && this.activity && this.subIndustry && this.industry && this.sector && this.fileDataList.length > 0){
              this.disableSubmitBtn = false; 
         }else{
              this.disableSubmitBtn = true; 
         }
    }

    handleUploadDocClick(){
         this.disableSubmitBtn = true;
         this.openUploadModal = true;
         
    }

    handleFileUpload(event) {
         try {
             let flist =[];
             let fcounter = 0;
             this.fileDataList = null;
             this.fileDataList = event.detail.filesList;
             this.fileDataList.forEach(element => {
                    console.log('element'+JSON.stringify(element));
                 flist.push({ label: element, index: fcounter });
                 fcounter += 1;
             });
             this.fileDataList = flist;
             if(this.fileDataList.length > 0){
              this.showUploadDocument = true;
          }   
             this.handleAllInputValues();

             //this.disableSubmitBtn = false; //need to update
             this.openUploadModal = false;
         } catch (error) {
             console.error(error);
         }
     }

    handlePreview(event){
         try {
             let selectedIndex = event.currentTarget.dataset.index;
             console.log('selectedIndex',selectedIndex);
             if(selectedIndex != null){
                 let selectedFile = this.fileDataList[selectedIndex].label;
                 console.log('file',selectedFile);
                 let base64 = 'data:'+selectedFile.fileType+';base64,'+selectedFile.base64;
                 this.previewFileData = base64;
                 this.isPDF = selectedFile.isPdf;
                 this.openPreviewModal = true;
             }
         } catch (error) {
             console.error(error);
         }
 
    }

    handleDeleteFile(event){
         try {
              let selectedIndex = event.currentTarget.dataset.index;
              console.log('selectedIndex',selectedIndex);
              if(selectedIndex != null){
                  let selectedFile = this.fileDataList[selectedIndex].label;
                  console.log('file',selectedFile);
                  if(selectedFile.filename){
                   this.showLoader = true;
                   let dataList = this.fileDataList;
                   dataList.splice(selectedIndex,1);
                   let counter=0;
                   dataList.forEach(element => {
                      element.index = counter;
                      counter +=1;
                   });
                   console.log('data list length ',dataList.length);
                      this.fileDataList = dataList;
                   if(this.fileDataList.length == 0){
                       this.showUploadDocument = false;
                   }
                  console.log('fileDataList list length ',this.fileDataList.length);
                   this.showLoader = false;
                   let title = `File deleted successfully!!`
                   const toastEvent = new ShowToastEvent({
                          title, 
                          variant:"success"
                   })
                   this.dispatchEvent(toastEvent);
                  }
              }
          } catch (error) {
              console.error(error);
         }  
    }

    handleCloseModal(){
         this.openPreviewModal = false;
         this.openUploadModal = false;
         this.handleAllInputValues();
    }

    handleSubmitMethod(){
         console.log('inside handle Submit');
         this.createEmploymentDetails();
         this.showAddressModal = true;           
    }

    createEmploymentDetails(){
         console.log('inside employment details');
         let employmentObj = {
              'Applicant__c' : this.applicantId,
              'Name' : this.employmentRecordName,
              'Business_Address_Validity__c' : false,
              'Business_Proof_Validity__c' : false,
              'Owner_Name_Vintage_Verified__c': false,
              'Document_Number__c': this.documentNumber,
              'Others_Business_Proof_Name__c': this.businessProofName,
              'Active__c':true,
              'Registered_Business_name__c' : this.registeredBusinessName,
              'Date_of_Incorporation__c' : this.dateOfIncorporation ? this.dateOfIncorporation : null,
              'Address__c' :this.addressId ? this.addressId : null,
              'Id' : this.employmentDetId ? this.employmentDetId : null,
              'Activity__c':  this.activity,
              'Sector__c' : this.sector,
              'Industry__c' : this.industry,
              'Sub_Industry__c' : this.subIndustry
         }
         createEmploymentDetails({employmentDetObj :JSON.stringify(employmentObj), screenName: this.screenName, recordTypeName: this.employeeRecordType})
         .then(result=>{
           if(result){
              this.employmentDetId = result;
              console.log('employmentd details created successfully ', this.employmentDetId);
              this.createDocChecklist();
           }
         })
         .catch(error=>{
           console.error(error);
         })

    }
    createDocChecklist(){
         console.log('inside create checklist');
         let docChecklistObj = {
             'Applicant__c': this.applicantId,
             'Loan_Application__c': this.loanApplicationId,
             'Active__c': true,
             'Id' : this.activeChecklist ? this.activeChecklist : null,
             'Employment_Detail__c' : this.employmentDetId ? this.employmentDetId : null
         }
         console.log(this.documentMasterName, docChecklistObj);
         createDocumentChecklistRec({masterName :this.documentMasterName,documentChecklistObj:JSON.stringify(docChecklistObj),documentCategory :this.documentCategory})
             .then(checkListResponse=>{
                 console.log(checkListResponse);
                 if(checkListResponse){
                     this.activeChecklist = checkListResponse;
                     console.log('document checklist created successfully ', this.activeChecklist);
                   for (let index = 0; index < this.fileDataList.length; index++) {
                        console.log('list fileDatalist inside for ',this.fileDataList);
                        let fileData = this.fileDataList[index].label;
                        console.log('list fileData inside for ',fileData);
                        let jsonString = {
                             'base64':fileData.base64,
                             'filename':fileData.filename,
                             'recordId':this.activeChecklist,
                             'applicantId':this.applicantId,
                             'loanId':this.loanApplicationId
                        }
                        console.log('json string ',jsonString);
                        uploadFile({ jsonString:JSON.stringify(jsonString) })
                         .then(result=>{
                        console.log('file upload result ',result);
                        })
                        .catch(error=>{
                        console.error(error);
                        })
         
                   }
                 }
             })
             .catch(error=>{
                 console.error(error);
             })
 
    }

    closeAddressPopup(){
       this.showAddressModal = false;
    }

    showParentCmpScreen(event){
       this.hideMainScreen = event.detail.showDynamicComponent; 
       this.fieldName = event.detail.fieldName;
       console.log('fields fieldName parent screen',this.fieldName);
    }
    
    getSelectedValueByLabel(array, label){
      const selectedField = array.find( item=> item.label === label);
      return selectedField ? selectedField.selectedValue : '';
    }
    
    handleFieldsChanged(event){
         this.hideMainScreen = event.detail.showDynamicComponent;
         this.fieldName = event.detail.fieldName;
         this.fields = event.detail.fields;
         console.log('this.fields', this.fields);
         this.sector = this.getSelectedValueByLabel(this.fields,'Sector');
         this.industry = this.getSelectedValueByLabel(this.fields,'Industry');
         this.subIndustry = this.getSelectedValueByLabel(this.fields,'Sub Industry');
         this.activity = this.getSelectedValueByLabel(this.fields,'Activity');
         console.log('sector indusrtry ', this.sector, this.industry, this.subIndustry, this.activity);
         console.log('fields fieldName handleFields changed',this.fieldName);
         this.handleAllInputValues();
    }

    handleAddressSubmit(event){
         console.log('address Id ',event.detail.addressId);
         this.addressId = event.detail.addressId;
         this.createEmploymentDetails();
    }
    adjustBackgroundBoxHeight() {
        const backgroundBox = this.template.querySelector('.background-box');
        if (backgroundBox) {
            backgroundBox.style.height = this.componentHeight;
        }
    }
}