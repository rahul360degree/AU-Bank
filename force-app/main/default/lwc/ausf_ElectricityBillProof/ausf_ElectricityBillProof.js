import { LightningElement,api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import AU_Assets from '@salesforce/resourceUrl/AU_Assets';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import getScreenCustomTextRecords from '@salesforce/apex/AUSF_Utility.getScreenCustomTextRecords';
import getGenericMasterRecordsByRecordTypes from '@salesforce/apex/AUSF_Utility.getGenericMasterRecordsByRecordTypes';
import getApplicationDetailsById from '@salesforce/apex/AUSF_Utility.getApplicationDetailsById';
import createDocumentChecklist from '@salesforce/apex/AUSF_Utility.createDocumentChecklist';
import updateApplicant from '@salesforce/apex/AUSF_Utility.updateApplicant';
import doElectricityBillCallOut from '@salesforce/apex/AUSF_INT_ElectricityBillController.doElectricityBillCallOut';
import deleteSelectedFile from '@salesforce/apex/AUSF_Utility.deleteSelectedFile';
import getRelatedFiles from '@salesforce/apex/AUSF_Utility.getRelatedFiles';
import updateLoanApplication from '@salesforce/apex/AUSF_Utility.updateLoanApplication';



export default class Ausf_ElectricityBillProof extends LightningElement {
    
    AUChevronRightImg = AU_Assets + '/AU_Assets/images/Outline/chevron-right.png';
    activeBackButtonImg = AU_Assets +'/AU_Assets/images/arrow-left-active.png';
    searchImg = AU_Assets +'/AU_Assets/images/search.png';
    AUErrorImg = AU_Assets + '/AU_Assets/images/warning_icon.png';
    AUDrivingLicenseImg = AU_Assets + '/AU_Assets/images/Driving_License.png';
    previewImg = AU_Assets + '/AU_Assets/images/eye.png';
    deleteImg = AU_Assets + '/AU_Assets/images/trash2.png';
    tickImg = AU_Assets + '/AU_Assets/images/tick-circle-whitebg.png';
    
    //For header 
    screenName = 'Residence Ownership Proof';
    headerContents = 'Apply for Personal Loan';
    headerDescription;
    stepsInCurrentJourney;
    currentStep;
    showContents = true;
    enableBackButton = true;


    @api applicantId = 'a02C1000002WEptIAG';
    @api loanApplicationId = 'a01C100000HLcdBIAT';
    
    //For main screen
    title;
    subtitle;
    disableProceedBtn = true;
    recordTypeName = 'Electricity Bill Service Providers';
    documentMasterName = 'Electricity Bill';
    eInputClass = "e-input";
    eLabelClass = "e-label";
    kInputClass = "k-input";
    kLabelClass = "k-label";
    mapOfElectricityProvider = new Map();
    kNumber = '';
    searchTerm = '';  
    selectedValue = '';
    selectedProviderCode;
    selectedProviderValue = '';
    invalidKNumber = '';
    errorMessage = '';
    consumerName = '';
    consumerAddress = '';
    showLoader = false;
    isDIYJourney = false;
    backToParent = true;
    activeChecklist;
    dtTime;
    filteredResults = [];
    electricityCompanyList= [];
    filteredDistrictResults = [];   
    districtList = [];
    showSearchResults = false;
    showDistrictBox = false;
    showDistrictScreen = false;
    showDistrictSearchResults = false;
    selectedDistrictValue = '';
    showMainScreen = true;
    showElectricityCompanyScreen = false;
    showSuccessScreen = false;
    documentChecklist;
    eventFire = false;
    
    //for api call
    errorMessageApi = '';
    showErrorModal = false;
    electricityApiErrMsg;

    //for upload file and delete file
    openUploadModal = false;
    openPreviewModal = false;
    showUploadDocument = false;
    insertFiles = true;
    fileDataList = [];
    isPDF;
    previewFileData;

    get cnfButtonClassVar() {
        return this.disableProceedBtn == true ? 'btnDisabled' : 'btnEnabled';
    }

    connectedCallback() {    
       this.getInitialData();                
    }

    // Fetches initial data required when component loads 
    getInitialData(){
        getCurrentScreenData({ loanApplicationId: this.loanApplicationId, applicantId: this.applicantId, screenName: this.screenName, masterName: ''})
        .then(result => {
            let applicantData = result.applicantList ? result.applicantList[0] : null;
                this.documentChecklist = applicantData && applicantData.Document_Checklists__r && applicantData.Document_Checklists__r.length > 0 ? applicantData.Document_Checklists__r : null;
                if (this.documentChecklist) {
                    this.documentChecklist.forEach(element => {
                        if (element.Document_Name__c = 'Electricity bill' && element.Active__c ) {
                            this.activeChecklist = element.Id;
                            this.kNumber = element.Document_Number__c;       
                            this.selectedProviderValue  = element.Service_Provider__c;
                            this.selectedValue = this.selectedProviderValue;
                            if(this.selectedProviderValue.length > 27){
                                this.selectedProviderValue = this.selectedProviderValue.slice(0,27) + '...';
                            }
                            this.selectedDistrictValue = element.District__c;
                            if(this.selectedProviderValue && this.kNumber){
                                this.disableProceedBtn = false;
                            }
                            this.showDistrictBox = this.selectedDistrictValue ? true : false;
                        }
                    });
                }
            let metadataToConsider = result.wizardDataDIYList ? result.wizardDataDIYList : result.wizardDataAssistedList ? result.wizardDataAssistedList : [];
            if (metadataToConsider && metadataToConsider.length > 0) {
                this.stepsInCurrentJourney = parseInt(metadataToConsider[0].Overall_Step__c);
                this.currentStep = parseInt(metadataToConsider[0].Progress_in_Current_Step__c);
                this.headerDescription = metadataToConsider[0].Category__c;
            }
            this.getExistingFiles();
        })
        .catch(error => {
            console.error(error);
        });
        getScreenCustomTextRecords({screenName: this.screenName})
        .then(result => {
            result.forEach(element => {
                if (element.DeveloperName == 'Invalid_K_number') {
                    this.invalidKNumber = element.Custom_String__c;
                }
                if(element.DeveloperName == 'Residence_Proof_Subitle'){
                    this.subtitle = element.Custom_String__c;
                 }
                if(element.DeveloperName == 'Electricity_Bill'){
                   this.title = element.Custom_String__c;
                }
                if (element.DeveloperName == 'Electricity_API_Error_Message') {
                   this.electricityApiErrMsg = element.Custom_String__c;
                }
                
            });
        }) 
        .catch(error => {
            this.error = error;
            console.log('Error is ' + this.error);
        });

        getApplicationDetailsById({loanId: this.loanApplicationId, screenName: this.screenName})
        .then(result => {
              console.log('loanapplication details ', result);
              let journeyMode = result.loanApplicationList[0].Journey_Mode__c;
              journeyMode == 'DIY' ? this.isDIYJourney = true : this.isDIYJourney = false;
        })
        .catch(error => {
            this.error = error;
            console.log('Error is ' + this.error);
        }); 

        getGenericMasterRecordsByRecordTypes({screenName: this.screenName, recordTypeName: this.recordTypeName, recordTypeName2: 'Electricity Bill Service Providers to District Mapping'})
        .then(result => {
            let eList = [];
            let ecounter = 0;
            result.forEach(element => {    
                this.mapOfElectricityProvider.set(element.Service_Provider_Name__c,element);
               
            });
            this.electricityCompanyList = Array.from(this.mapOfElectricityProvider.keys()).sort();
            console.log('electricityCompanyList', this.electricityCompanyList);

            this.electricityCompanyList.forEach(element => {
                eList.push({ label: element, index: ecounter });
                ecounter += 1;
            });
            this.electricityCompanyList = eList;
        })
        .catch(error => {
            this.error = error;
            console.log('Error is ' + this.error);
        });

    }

    handleKNumberInput(event){
        this.kNumber = event.target.value;
        this.kNumber = this.kNumber.toUpperCase().replaceAll(' ','');
        this.kInputClass = "k-input";
        this.kLabelClass = "k-label";
        if(this.kNumber){
            if(this.kNumber.length > 30 || this.kNumber.length < 5){
                this.errorMessage = this.invalidKNumber;
                this.kInputClass  = "k-input k-input-error";
                this.kLabelClass = "k-label k-label-error";
            }else{        
                this.errorMessage = '';
                this.kInputClass  = "k-input";
                this.kLabelClass = "k-label";
            }
        }else{
            this.errorMessage = '';
            this.kInputClass  = "k-input";
            this.kLabelClass = "k-label";

        }
        if(this.kNumber && this.selectedValue && !this.errorMessage){
            this.disableProceedBtn = false;
            
        }else{
            this.disableProceedBtn = true;
        }    

    }

    handleCompanyInput(event){
        const selectedLabel = event.target.dataset.label;
        this.selectedValue = selectedLabel;
        this.selectedDistrictValue = '';
        this.districtList = '';
        if(this.selectedValue.length > 27){
            this.selectedProviderValue = this.selectedValue.slice(0,27) + '...';
        }else{
            this.selectedProviderValue = this.selectedValue;
        }
        if(this.selectedValue){
            this.showElectricityCompanyScreen = false;
            this.searchTerm = '';
            this.showMainScreen = true;
            this.eLabelClass = "e-label";
            this.eInputClass = "e-input";
            let selValueData = this.mapOfElectricityProvider.get(this.selectedValue);
            let districtMappingFlag = selValueData.Has_district_mapping__c;
            this.selectedProviderCode = selValueData.Service_Provider_Code__c;
            if(districtMappingFlag){
                let distCounter = 0;
                let uiDistrictList = [];
                this.showDistrictBox = true;
                let district = selValueData.District__c.replace(/,\s*$/, "");
                this.districtList = district.split(', ').sort();
                    this.districtList.forEach(element => {
                    uiDistrictList.push({ label: element, index: distCounter });
                    distCounter += 1;
                });
                this.districtList = uiDistrictList;
            }
            else{
                this.showDistrictBox = false;
                
            }
        
        }
        
        if(this.kNumber && this.selectedValue && !this.showDistrictBox){
            this.disableProceedBtn = false;            
        }
        else{
            this.disableProceedBtn = true;
        }
        
    }

    handleDistrictInput(event){
        const selectedLabel = event.target.dataset.label;
        this.selectedDistrictValue = selectedLabel;
        if(this.selectedDistrictValue){
            this.showMainScreen = true;
            this.showDistrictScreen = false;
        }
        if((this.showDistrictBox && !this.selectedDistrictValue) || (this.kNumber == '' && this.selectedDistrictValue) ) {
          this.disableProceedBtn = true;
        }
        else{
          this.disableProceedBtn = false;
        }
    }

    handleSubmitMethod(){
        if(this.eventFire){
            this.updateLoanApplication();     
        }else{
            if(this.selectedValue && this.kNumber){
                this.handleDocChecklist(); 
                this.updateApplicant();
                if(this.selectedValue == 'Other'){
                    this.showUploadDocument = true;
                    this.checkEnableProceed();
    
                }else{
                    this.showLoader = true;
                    this.handleElectricityCallout();
                }
                this.eventFire = true;
                          
            }
        }
        
         
    }

    updateLoanApplication(){
        let loanApplcationObj = {
            'Id': this.loanApplicationId,
            'Last_visited_Page__c':this.screenName
        }
  
        updateLoanApplication({loanApplcationObj:JSON.stringify(loanApplcationObj),loanApplicationId:this.loanApplicationId,screenName:this.screenName})
        .then((result) => {
            console.log(result,'Confirm Personal details sbmitted');
            const nextEvent = new CustomEvent('submitevent', {
                detail: {
                    currentScreen: this.screenName,
                }
            });
            this.dispatchEvent(nextEvent);

        })
        .catch((error) => {
            console.error(error);
        });
    }

    // Callout to elecitricity bill api to verify consumer details entered by user.
    //  In case of response is success , user sees success screen , 
    //else error screen is displayed along with error message with Integration checkilist record number.
    handleElectricityCallout(){
            doElectricityBillCallOut({loanId :this.loanApplicationId, applicantId :this.applicantId,consumer_id :this.kNumber, service_provider :this.selectedProviderCode})
            .then((result) => {
                let response = result;
                this.showLoader = false;
                this.disableProceedBtn = true;
                console.log('response ', response);
                if (response.blnSuccess){
                    if(response.result.address){
                       this.consumerAddress = response.result.address;
                    }
                    if(response.result.consumer_name){
                        this.consumerName = response.result.consumer_name;
                    }
                    this.handleDocChecklist();
                    this.showSuccessScreen = true;
                }else{
                    let localErrorMsg =  response.strMessage.includes('IC') ? this.electricityApiErrMsg +' -IC' + response.strMessage.split("-")[3] : this.electricityApiErrMsg;
                    this.errorMessageApi = localErrorMsg;
                    this.showErrorModal = true;  
                    console.log('Response fail errormsg ');
                }
            })
            .catch(error => {
                console.error('Error fetching response', error);
            })
    }
    
    //Create or update Document_Checklist__c record for current applicant
    
    handleDocChecklist(){
        let docChecklistObj = {
            'Applicant__c': this.applicantId,
            'Loan_Application__c': this.loanApplicationId,
            'Active__c': true,
            'Document_Name__c': 'Electricity bill',
            'Document_Number__c' : this.kNumber,
            'Service_Provider__c' : this.selectedValue,
            'District__c' : this.selectedDistrictValue,
            'Address__c' :this.consumerAddress ? this.consumerAddress : '',
            'Consumer_Name__c' :this.consumerName ? this.consumerName : '',
            'Id' : this.activeChecklist ? this.activeChecklist : null,
            'Owned_Address_Proof_Type__c' : 'Electricity bill'
        }
        createDocumentChecklist({masterName :this.documentMasterName,documentChecklistObj:JSON.stringify(docChecklistObj)})
            .then(checkListResponse=>{
                console.log(checkListResponse);
                if(checkListResponse){
                    this.activeChecklist = checkListResponse;
                    console.log('document created successfully ', this.activeChecklist);
                }
            })
            .catch(error=>{
                console.error(error);
            })

    }

    updateApplicant(){

        if(this.isDIYJourney){
            console.log('inside update applicant ');
            this.dtTime = new Date().toISOString();
            console.log(this.dtTime);
            let applicantObj = {
                'Id': this.applicantId,
                'Electricity_Bill_Consent_Date_Time__c': this.dtTime
            }
            updateApplicant({applicantObj:JSON.stringify(applicantObj),applicantId:this.applicantId,screenName:this.screenName})
            .then((result) => {
                console.log('applicant updated with consent');
            })
            .catch(error=>{
                console.error(error);
            })
        }
       
    }

    handleEletcricityClick(){
        this.showElectricityCompanyScreen = true;
        this.showMainScreen = false;
        this.filteredResults = this.electricityCompanyList;

    }

    handleSearch(event){
        this.searchTerm = event.target.value;
        if(this.showElectricityCompanyScreen){
            if (this.searchTerm.length >= 3) {
                this.filteredResults = this.electricityCompanyList.filter(result =>
                    result.label.toLowerCase().includes(this.searchTerm.toLowerCase())
                );
                console.log('filter result ',this.filteredResults);
                this.showSearchResults = true;
            } else {
                console.log('filter result else',this.filteredResults);
                this.showSearchResults = false;
                this.filteredResults = [];
            }
        }
        else{
            if (this.searchTerm.length >= 3) {
                let localdistrict = [];
                for (let i = 0; i < this.districtList.length; i++) {
                    let result = this.districtList[i];
                    if (result.label && result.label.toLowerCase().includes(this.searchTerm.toLowerCase())) {
                        localdistrict.push(result);
                    }
                }
                this.filteredDistrictResults = localdistrict;
                this.showDistrictSearchResults = true;
            }else {
                this.showDistrictSearchResults = false;
                this.filteredDistrictResults = [];
            }
        }
        
    }    

    handleDistrictClick(){
        this.showDistrictScreen = true;
        this.showElectricityCompanyScreen = false;
        this.searchTerm = '';
        this.filteredDistrictResults = this.districtList;
        if(this.showDistrictScreen && !this.showElectricityCompanyScreen){
            this.showMainScreen = false;
        }
        if(this.showDistrictBox && !this.selectedDistrictValue && !this.kNumber) {
            this.disableProceedBtn = true;
         }
         else{
          this.disableProceedBtn = false;
         }

    }

    handleCloseErrorModal(){
        this.showErrorModal = false;
        this.errorMessageApi = '';
        this.showUploadDocument = true;
        this.checkEnableProceed();

    }

    checkEnableProceed(){
        if(this.fileDataList.length > 0){
            this.disableProceedBtn = false;
        }
    }

    handleCloseModal(){
        this.openPreviewModal = false;
        this.openUploadModal = false;
        this.disableProceedBtn = false;
    }

    handleBackReDirectParent(){
        const backEvent = new CustomEvent('backtoparentevent', {
            detail: {
                currentScreen:this.screenName,
            }
        });
        this.dispatchEvent(backEvent);
    }

    handleUploadDocClick(){
       this.openUploadModal = true;
       this.disableProceedBtn = true;
    }

    handleBackRedirection(){
        this.showElectricityCompanyScreen = false;
        this.showDistrictScreen = false;
        this.showMainScreen = true;
    }

    handleFileUpload(event) {
        try {
            let flist =[];
            let fcounter = 0;
            this.fileDataList = null;
            this.fileDataList = event.detail.filesList;
            this.fileDataList.forEach(element => {
                flist.push({ label: element, index: fcounter });
                fcounter += 1;
            });
            this.fileDataList = flist;
            console.log('this.fileDataList', this.fileDataList);
            this.disableProceedBtn = false;
            this.openUploadModal = false;
            //this.showEvent = true;
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
                console.log('previewFileData',this.previewFileData);
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
                if(selectedFile.contentVersionId){
                    this.showLoader = true;
                    deleteSelectedFile({contentVersionId:selectedFile.contentVersionId})
                    .then(response=>{
                        console.log(response,'file deleted');
                        if(response){
                            let dataList = this.fileDataList;
                            dataList.splice(selectedIndex,1);
                            let counter=0;
                            dataList.forEach(element => {
                                element.index = counter;
                                counter +=1;
                            });
                            console.log('data list length ',dataList.length);
                            if(dataList.length > 0){
                                this.fileDataList = dataList;
                            }
                            else{
                                this.fileDataList = [];
                               // this.showUploadDocument = true;
                                //this.showEvent = false;
                            }
                            console.log(this.fileDataList);
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

    getExistingFiles() {
        console.log('existing file' + this.activeChecklist);
        getRelatedFiles({ documentChecklistRec: this.activeChecklist })
            .then(result => {
                if (result && result.length > 0) {
                    console.log(result);
                    let updatedData = [];
                    let fcounter = 0;
                    result.forEach(file => {
                        let fileData = {
                            'filename': file.contentVersionObj.Title,
                            'size': (parseFloat(file.contentVersionObj.ContentSize) / 1000) + ' kbs',
                            'fileType': file.contentVersionObj.FileExtension && !file.contentVersionObj.FileExtension.includes('pdf') ? 'image/' + file.contentVersionObj.FileExtension : 'application/' + file.contentVersionObj.FileExtension,
                            'isPdf': file.contentVersionObj.FileExtension && file.contentVersionObj.FileExtension.includes('pdf') ? true : false,
                            'contentVersionId': file.contentVersionObj.Id,
                            'base64': file.base64
                        }
                        updatedData.push({ label: fileData, index: fcounter });
                        fcounter += 1;

                    });
                    this.fileDataList = updatedData;
                    console.log('asmita file data list ', this.fileDataList.length);
                    // if(this.showUploadDocument){
                    //     this.disableProceedBtn = false;
                    // }
                    //this.showUploadDocument = true;

                } else {
                    console.log('inside else of file ');
                    //this.showUploadDocument = false;
                }
            })
            .catch(error => {
                console.error(error);
            })
    }

    handleSuccessProceed(){
        this.showSuccessScreen = false;
        this.updateLoanApplication();

    }
    
}