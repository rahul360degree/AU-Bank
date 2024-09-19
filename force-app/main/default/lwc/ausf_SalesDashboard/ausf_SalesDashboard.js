import { LightningElement,track} from 'lwc';
import getListViews from '@salesforce/apex/AUSF_ListViewRecordCountController.getListViews';
import getSalesDashboardDetails from '@salesforce/apex/AUSF_Utility.getSalesDashboardDetails';
import getFilteredRecordCount from '@salesforce/apex/AUSF_ListViewRecordCountController.getFilteredRecordCount';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

export default class Ausf_SalesDashboard extends NavigationMixin(LightningElement) {

    listViewName = ''; 
    nmCondMap;   
    @track listViewNameList = [];
    mapOfListView = new Map();
    showEnterMobileNumberScreen = false;
    showRecord = false;
    strUserType = '';
    blnPartnerUser = false;
    


    connectedCallback() {  
       this.getInitialData(); 
    }

    //get initial data when component loads
    getInitialData(){
        getSalesDashboardDetails({screenName: '',name:'Loan Application List View'})
        .then(result => {
            if (result && result.lstGenericMaster && result.lstGenericMaster.length>0 && result.objUser) {
                this.strUserType = result.objUser.UserType;
                this.blnPartnerUser = this.strUserType == 'PowerPartner' ? true : false;
                let orderjson = JSON.parse(result.lstGenericMaster[0].Custom_String_Long__c);
                this.nmCondMap  = new Map(Object.entries(orderjson));
                this.getLists();
            }
        })
        .catch(error => {
            this.error = error;
            console.log('Error is in connected call back error for generic master metadata....' + this.error);
        });
    }

    
    //fetch list views to be shown on screen and their record count
    getLists(){
        getListViews({ObjectName: 'Loan_Application__c'})
        .then(result => {
            let eList = new Map();
            let ecounter = 0;
            this.nmCondMap.forEach((values, keys)=> {
                console.log(values, keys);
                eList.set(keys, ecounter);
                this.listViewNameList.push({label: keys, index: ecounter, recCount: 0});
                ecounter +=1;
            });
            result.forEach(element => {  
                if(this.nmCondMap.get(element.Name)){
                    this.mapOfListView.set(element.Name,element);
                    getFilteredRecordCount({filterCondition: this.nmCondMap.get(element.Name)})
                    .then(result => {
                        let mapIndex = eList.get(element.Name);
                        this.listViewNameList[mapIndex]= {label: element.Name, index: ecounter, recCount: result};
                        this.showRecord = true;
                    })
                    .catch(error => {
                        this.error = error;
                        console.log('Error is in connected call back error for filtered conditions....' + this.error);
                    });   
                }
                
            });
           
        }) 
        .catch(error => {
            this.error = error;
            console.log('Error is in connected call back error for fetching list views...' + this.error);
        });        
    }


    //On clicking of the items shown in screen, redirect to individual list view page
    handleCardClick(event) {
        this.listViewName = event.currentTarget.dataset.id;
        let selValueData = this.mapOfListView.get(this.listViewName);
        let listViewDevloperName = selValueData.DeveloperName;
        if (this.blnPartnerUser) {       
            const baseUrl = '/loan-application/Loan_Application__c/Default';
            this[NavigationMixin.Navigate]({
                type: "standard__webPage",
                attributes: {
                    url: baseUrl+'?Loan_Application__c-filterId='+listViewDevloperName
                }
            });
        }
        else {
            this[NavigationMixin.GenerateUrl]({
                type: "standard__objectPage",
                attributes: {
                    objectApiName: 'Loan_Application__c',
                    actionName: 'list',
                },
                state: {
                    filterName: listViewDevloperName,
                }

            }).then(url => {
                window.open(url, "_blank");
            });
        }
    }
   
    //Opens up new loan screen
    handleNewLoanClick(){
        if (this.blnPartnerUser) {
            this[NavigationMixin.Navigate]({
                type: 'comm__namedPage',
                attributes: {
                    name: 'LA_Start_Loan__c'
                },
                state: {
                    
                }
            });
        }
        else {
            this.showEnterMobileNumberScreen = true;
        }
    }
}