import { LightningElement,api } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';
import createAddress from '@salesforce/apex/AUSF_Utility.createAddress';
import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';
import validatePinCode from '@salesforce/apex/AUSF_ConfirmPersonalDetailsController.validatePinCode';

export default class Ausf_EnterApplicantAddressDetails extends LightningElement {
    pinImg = Assets + '/AU_Assets/images/Group_427321515.png';
    closeIcon = Assets + '/AU_Assets/images/Outline/x.png';
    infoImg = Assets + '/AU_Assets/images/info.png';

    showAddressModal = false;
    isDisableAddressSubmit = true;
    addr1Value= '';
    addr2Value= '';
    addr3Value= '';
    pincode = '';
    pincodedetails = '';
    state = '';
    city ='';
    
   
    @api screenname = '';
    @api applicantId;

    //get initial data from server
    connectedCallback(){
        getCurrentScreenData({loanApplicationId :'',applicantId:this.applicantId, screenName :''})
        .then(result => {
            console.log('result ',result);
            if(result.applicantList[0] && result.applicantList[0].Current_Pincode__c){
                this.pincode =result.applicantList[0].Current_Pincode__c;
            }
        })
        .catch(error => {
            console.log('In connected call back error....');
            this.error = error;
            console.log('Error is ' + this.error);
        });

        
       
    }
    renderedCallback(){
         //To show city and state on the screen based on the pincode present on screen
        if(this.pincode){
            validatePinCode({pinCode:this.pincode,loanApplicationId:''})
            .then(result=>{
                console.log('pindetails result ',result);
                if((result && result.length > 0)){
                    this.pincodedetails = result[0].City__c + ', ' + result[0].State__c;
                    this.city = result[0].City__c;
                    this.state = result[0].State__c;
                }else{
                    this.pincodedetails = '';
                }
            })
            .catch(error=>{
                console.error(error);
            })
        }

    }

    get addrModalBtnClass() {
        return this.isDisableAddressSubmit == true ? 'addrBtnDisabled' : 'addrButton';
    }
    
    //Closes the modal on close icon click
    handleCloseModal(){
         const closeModalEvent = new CustomEvent('closemodalevent');
         this.dispatchEvent(closeModalEvent);
    }

    handleAddressLine1(event){
        this.addr1Value = event.target.value;
        if(this.addr1Value){
            this.isDisableAddressSubmit = false;
        }else{
            this.isDisableAddressSubmit = true;
        }
    }

    handleAddressLine2(event){
        this.addr2Value = event.target.value;
    }

    handleAddressLine3(event){
        this.addr3Value = event.target.value;
    }

    //Creates Address on the Address__c object with specified parameters below and 
    //dispatch custom event to notify the submit on Confirm Personal details component
    
    handleAddressModalSubmit(){
        try{
            let addressObj = {
                'Pincode__c' :this.pincode,
                'Address_Type__c' : 'Current',
                'Address_Source__c': 'your input',
                'Working_Area__c': 'Yes',
                'Applicant__c':this.applicantId,
                'Active__c':true,
                'City__c' : this.city,
                'State__c' : this.state
            }
            if (this.addr1Value) {
                addressObj['Address_Line_1__c'] = this.addr1Value;
            } if (this.addr2Value) {
                addressObj['Address_Line_2__c'] = this.addr2Value;
            }if (this.addr3Value) {
                addressObj['Address_Line_3__c'] = this.addr3Value;
            }

        createAddress({addressObj :JSON.stringify(addressObj), pincode: this.pincode, screenName: this.screenName})
            .then(() => {
                console.log('Address created on the object');              
            })
            .catch(error => {
                console.error('Error creating address', error);
            });

        } catch (error) {
            console.error();
        }

        const submitAddressEvent = new CustomEvent('submitaddressevent');
        this.dispatchEvent(submitAddressEvent);
    }
    
}