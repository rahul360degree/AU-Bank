import { LightningElement, track, api, wire } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';

import getCurrentScreenData from '@salesforce/apex/AUSF_Utility.getCurrentScreenData';

export default class Ausf_FinalOfferScreen extends LightningElement {

    screenName = 'Final Offer';
    headerContents = 'Apply for Personal Loan';
    headerDescription = 'Final Offer';
    stepsInCurrentJourney = 2;
    currentStep = 1;
    showContents = true;
    enableBackButton = false;

    finalOfferImg = Assets +'/AU_Assets/images/loan_offer.png'
    notchImg = Assets +'/AU_Assets/images/Triangle.png'
    closeImg = Assets +'/AU_Assets/images/whiteCross.png'
    closeIconURL = Assets + '/AU_Assets/images/Outline/x.png';
    breakupStrokeImg = Assets +'/AU_Assets/images/grey_stroke.png'
    infoBtn = Assets +'/AU_Assets/images/orange_info.png'
    warningIconURL = Assets +'/AU_Assets/images/warning_icon.png';

    showLoader = true;
    titleText = 'Select required loan';
    subtitleText = 'It helps us determine how much to transfer to your bank account to fulfil your dream';
    interestValue;  //in percent
    disableProceedBtn = true;
    loanAmount = 200000; // ₹2,00,000
    minSliderValue = 25000; 
    maxSliderValue = 200000;
    minLoanAmount;
    maxLoanAmount;
    sliderStep = 1000;
    emiPlanList;
    totalCharges  //-₹5,900
    aprValue = ''; //20.2%
    amountYouGet  //₹1,94,100
    helpText = 'APR is the effective annualised rate charged to the borrower of a digital loan. APR is based on an all-inclusive cost and margin';
    processingFee//₹4,000
    gst //₹800
    stampDuty //₹40
    totalDeductions //₹5,610
    openBreakupModal = false;
    showHelpText = false;
    anyValidationError = false;
    validationErrorMessage;
    emiStepSize;
    breakupChargesTitle;
    emiSubtitle
    emiTitle
    gstPercent
    loanSummaryTitle
    minTenure = 12; // 12 sample value
    maxTenure = 36  // 36 sample value

    processingFeeGrid = '{"pfGrid": [ { "minLoanAmount": 0, "maxLoanAmount": 199999, "processingFeesRate": 3 }, { "minLoanAmount": 200000, "maxLoanAmount": 850000, "processingFeesRate": 2.5 } ]}';
    stampDutyGrid = '{"stampDutyGrid": [ { "minLoanAmount": 200000, "maxLoanAmount": 850000, "stampDutyRate": 4.25 },{ "minLoanAmount": 100000, "maxLoanAmount": 200000, "stampDutyRate": 4.25 } ]}';
    roiGrid = '{"roiGrid": [ { "minLoanAmount": 0, "maxLoanAmount": 199999, "roi": 12.25 }, { "minLoanAmount": 200000, "maxLoanAmount": 850000, "roi": 10.25 } ]}';
    loanTenureGrid = '{"loanAmountTenureGrid": [ { "minLoanAmount": 0, "maxLoanAmount": 159999, "maxTenure": 24 }, { "minLoanAmount": 160000, "maxLoanAmount": 850000, "maxTenure": 48 } ]}';

    selectedEMIPlan;

    @api loanApplicationId;
    @api applicantId;

    get cnfButtonClassVar() {
        return this.disableProceedBtn == true ? 'btnDisabled' : 'btnEnabled';
    }

    connectedCallback(){
        // let data = [{index:0,amount:17137,tenure:12,emiCardClass:'emiPlan'},{index:1,amount:9029,tenure:24,emiCardClass:'emiPlan'},{index:2,amount:7412,tenure:30,emiCardClass:'emiPlan'}];
        this.minLoanAmount = this.minSliderValue.toLocaleString('en-IN');
        this.maxLoanAmount = this.maxSliderValue.toLocaleString('en-IN');
        this.processingFeeGrid = JSON.parse(this.processingFeeGrid);
        this.stampDutyGrid = JSON.parse(this.stampDutyGrid);
        this.roiGrid = JSON.parse(this.roiGrid);
        this.loanTenureGrid = JSON.parse(this.loanTenureGrid);


        getCurrentScreenData({ loanApplicationId: this.loanApplicationId, screenName: this.screenName })
        .then(result => {
            console.log(result);
            let loanApplicationData = result.loanApplicationList ? result.loanApplicationList[0] : null;

            let breData = loanApplicationData && loanApplicationData.BRE_Response__r && loanApplicationData.BRE_Response__r.length > 0 ? loanApplicationData.BRE_Response__r[0] : null;
            console.log('breData',breData);
            if(breData){
                this.processingFeeGrid = JSON.parse(breData.Processing_Fee_Grid__c);
                this.stampDutyGrid = JSON.parse(breData.Stamp_Duty_Grid__c);
                this.roiGrid = JSON.parse(breData.ROI_Grid__c);
                this.loanTenureGrid = JSON.parse(breData.Loan_Amount_Tenure_Grid__c);
                this.minTenure = loanApplicationData.Min_Loan_Tenure_in_Months__c;
                this.maxTenure = loanApplicationData.Max_Loan_Tenure_in_Months__c;
            }

            let customTextList = result.screenCustomTextList ? result.screenCustomTextList : null;
            if (customTextList) {
                customTextList.forEach(element => {
                    if(element.Label == 'Step Size'){
                        this.sliderStep = parseInt(element.Custom_String__c);
                    }else if(element.Label == 'EMI Step size'){
                        this.emiStepSize = parseInt(element.Custom_String__c);
                    }else if(element.Label == 'EMI Subtitle'){
                        this.emiSubtitle = element.Custom_String__c;
                    }else if(element.Label == 'EMI Title'){
                        this.emiTitle = element.Custom_String__c;
                    }else if(element.Label == 'GST Percent'){
                        this.gstPercent = parseInt(element.Custom_String__c);
                    }else if(element.Label == 'Loan Sumary Title'){
                        this.loanSummaryTitle = element.Custom_String__c;
                    }else if(element.Label == 'Breakup Charges Title'){
                        this.breakupChargesTitle = element.Custom_String__c;
                    }
                });
            }

            let valueMap = result.customLabelMap;

            if(valueMap){
                for (var key in valueMap) {
                    if(key == 'GST Percent'){
                        this.gstPercent = parseInt(valueMap[key]);
                    }else if(key == 'Slider Step Size'){
                        this.sliderStep = parseInt(valueMap[key]);
                    }else if(key == 'Minimum Loan Amount'){
                        this.minSliderValue = parseInt(valueMap[key]);
                        this.minLoanAmount = this.minSliderValue.toLocaleString('en-IN');
                    }
                }
            }

            let metadataToConsider = result.wizardDataDIYList ? result.wizardDataDIYList : result.wizardDataAssistedList ? result.wizardDataAssistedList : [];
            if (metadataToConsider && metadataToConsider.length > 0) {
                this.stepsInCurrentJourney = parseInt(metadataToConsider[0].Overall_Step__c);
                this.currentStep = parseInt(metadataToConsider[0].Progress_in_Current_Step__c);
                this.headerDescription = metadataToConsider[0].Category__c;
            }

            this.calculateAllData();


            if (loanApplicationData) {

                
            }

            this.showLoader = false;

            const amountInputBox = this.template.querySelector('.inputText');
            console.log('i',amountInputBox);
            if(amountInputBox){
                amountInputBox.focus();
            }else{
                setTimeout(() => {
                    const amountInputBox = this.template.querySelector('.inputText');
                    console.log('i',amountInputBox);
                    if(amountInputBox){
                        amountInputBox.focus();
                    }
                }, 300);
            }
        })
        .catch(error => {
            console.error(error);
        });


        // let netDisbursement = loanAmount - totalDeduction;
        // let EMI = this.calculateEMI(loanAmount,roi,tenure);
        // let APR = parseFloat((this.calculateAPR(tenure, EMI, -netDisbursement, 0, 0)*12*100).toFixed(1));
        // let APR2 = parseFloat((this.calculateAPR2(tenure, -EMI, netDisbursement, 0, 0)*12*100).toFixed(1));
        // let netInterest = Math.round(EMI * tenure - loanAmount);
        // let emiStartDate = this.calculateEMIStartDate(disbursementDate);
    }

    calculateAllData(){
        try {
            let processingFee;
            let roi;
            let gst;
            let stampDuty;
    
            // hardcoded grids needs to be replaced with fields

            if(this.processingFeeGrid && this.processingFeeGrid.pfGrid){
    
                let pfGrid = this.processingFeeGrid.pfGrid;
                pfGrid.forEach(element => {
                    if(element.minLoanAmount <= this.loanAmount && element.maxLoanAmount >= this.loanAmount){
                        processingFee = element.processingFeeAmount && element.processingFeeAmount >0 ? element.processingFeeAmount.toLocaleString('en-IN') : element.processingFeesRate ? ((element.processingFeesRate * this.loanAmount)/100) : 0; // processingFeeAmount key can be changed and will based on what we receive in the response
                    }
                });
            }
    
            if(this.stampDutyGrid && this.stampDutyGrid.stampDutyGrid){
    
                let stGrid = this.stampDutyGrid.stampDutyGrid;
                stGrid.forEach(element => {
                    if(element.minLoanAmount <= this.loanAmount && element.maxLoanAmount >= this.loanAmount){
                        stampDuty = element.MaxStampDutyCapping ? Math.min(((element.stampDutyRate * this.loanAmount)/100),element.MaxStampDutyCapping) : ((element.stampDutyRate * this.loanAmount)/100); // MaxStampDutyCapping key can be changed and will based on what we receive in the response
                    }
                });
            }
    
            if(this.roiGrid && this.roiGrid.roiGrid){
    
                let interestGrid = this.roiGrid.roiGrid;
                interestGrid.forEach(element => {
                    if(element.minLoanAmount <= this.loanAmount && element.maxLoanAmount >= this.loanAmount){
                        roi = element.roi;
                    }
                });
            }
    
            // let gstPerc = 18; //in percent;
            gst = ((this.gstPercent * processingFee)/100);
            
            let totalCharges = parseFloat(processingFee ? processingFee : 0) + parseFloat(gst ? gst : 0) + parseFloat(stampDuty ? stampDuty : 0);
            console.log(processingFee,gst,stampDuty,totalCharges,roi);
            this.amountYouGet = (this.loanAmount - totalCharges).toLocaleString('en-IN');
    
            this.processingFee = processingFee?.toLocaleString('en-IN');
            this.stampDuty = stampDuty?.toLocaleString('en-IN');
            this.gst = gst?.toLocaleString('en-IN');
            this.interestValue = roi;
            this.totalCharges = totalCharges?.toLocaleString('en-IN');
            this.totalDeductions = totalCharges?.toLocaleString('en-IN');
            
            this.setEMIPlanList();

        } catch (error) {
            console.error(error);
        }
    }

    setEMIPlanList(){
        try {
            console.log(this.interestValue,this.minTenure,this.maxTenure,this.emiStepSize);

    
            let data = [];
            let index = 0;

            for (let t = this.minTenure; t <= this.maxTenure; t+=this.emiStepSize) {
                let disableEmi = true;
                if(this.loanTenureGrid && this.loanTenureGrid.loanAmountTenureGrid){
                    this.loanTenureGrid.loanAmountTenureGrid.forEach(element => {
                        if(this.loanAmount && element.minLoanAmount <= this.loanAmount && element.maxLoanAmount >= this.loanAmount && t<= element.maxTenure){
                            disableEmi = false
                        }
                    });
                }
                
                let element ={
                    index:index,
                    amount:this.calculateEMI(this.loanAmount,this.interestValue,t).toLocaleString('en-IN'),
                    tenure:t,
                    emiCardClass:'emiPlan',
                    disabled:disableEmi
                }
                data.push(element);
                index += 1;
            }
    
            console.log('data',data);
            
            this.emiPlanList = data;
            this.showLoader = false;
        } catch (error) {
            console.error(error);
        }
    }

    handleInputChange(event){
        this.selectedEMIPlan = null;
        this.aprValue = null;
        this.template.querySelectorAll('input[type="checkbox"]').forEach(cb => {
            if (cb != event.target) {
                cb.checked = false;
            }else{
                cb.checked = true;
            }
        });
        this.disableProceedBtn = true;
        this.loanAmount = event.target.value;
        if(this.loanAmount){
            if((this.loanAmount > this.maxSliderValue)){
                this.anyValidationError = true;
                this.validationErrorMessage = 'Loan amount should be less than '+this.maxSliderValue+'.';
            }else if ((this.loanAmount < this.minSliderValue) ){
                this.anyValidationError = true;
                this.validationErrorMessage = 'Loan amount should be greater than '+this.minSliderValue+'.';
            }else if((this.loanAmount % this.sliderStep != 0)){
                this.anyValidationError = true;
                this.validationErrorMessage = 'Loan amount should be in size of ' + this.sliderStep;
            }else{
                this.anyValidationError = false;
                this.calculateAllData();
            }

        }
    }

    handleSelection(event){
        try {
            let index = event.target.value;
            let data = this.emiPlanList
            data.forEach(element => {
                element.emiCardClass = 'emiPlan';
                if(element.index == index){
                    element.emiCardClass = 'emiPlan activeSelection';
                    this.disableProceedBtn = false;
                }
            });
            this.template.querySelectorAll('input[type="checkbox"]').forEach(cb => {
                if (cb != event.target) {
                    cb.checked = false;
                }else{
                    cb.checked = true;
                }
            });

            this.selectedEMIPlan = this.emiPlanList[index];
            console.log(this.selectedEMIPlan);

            let netDisbursement = this.amountYouGet ? this.amountYouGet.includes(',') ? parseFloat(this.amountYouGet.split(',').join('')) : parseFloat(this.amountYouGet) : null;

            let emiAmount = this.selectedEMIPlan.amount ? this.selectedEMIPlan.amount.includes(',') ? parseFloat(this.selectedEMIPlan.amount.split(',').join('')) : parseFloat(this.selectedEMIPlan.amount) : null;
            this.aprValue = parseFloat((this.calculateAPR2(this.selectedEMIPlan.tenure, -emiAmount, netDisbursement, 0, 0)*12*100).toFixed(1));
            
            console.log(this.aprValue);
            this.emiPlanList = [...data];
        } catch (error) {
            console.error(error);
        }
    }

    handleSubmitMethod(){

    }

    handleCloseModal(){
        this.showHelpText = false;
        this.openBreakupModal = false;
    }

    handleHelpText(){
        this.showHelpText = true;
    }

    handleViewBreakup(){
        this.openBreakupModal = true
    }



    calculateEMI(loanAmount, roi, tenure)
    {
        let emi;
        roi = roi / (12 * 100); // interest per month
        emi = (loanAmount * roi * Math.pow(1 + roi, tenure)) / (Math.pow(1 + roi, tenure) - 1);
        return Math.round((emi + 0.000414));
    }


    calculateAPR2(nper, pmt, pv, fv, type, guess) { 
        // Sets default values for missing parameters
        fv = typeof fv !== 'undefined' ? fv : 0;
        type = typeof type !== 'undefined' ? type : 0;
        guess = typeof guess !== 'undefined' ? guess : 0.1;
    
        // Sets the limits for possible guesses to any
        // number between 0% and 100%
        var lowLimit = 0;
        var highLimit = 1;
    
        // Defines a tolerance of up to +/- 0.00005% of pmt, to accept
        // the solution as valid.
        var tolerance = Math.abs(0.00000005 * pmt);
    
        // Tries at most 40 times to find a solution within the tolerance.
        for (var i = 0; i < 40; i++) {
            // Resets the balance to the original pv.
            var balance = pv;
    
            // Calculates the balance at the end of the loan, based
            // on loan conditions.
            for (var j = 0; j < nper; j++ ) {
                if (type == 0) {
                    // Interests applied before payment
                    balance = balance * (1 + guess) + pmt;
                } else {
                    // Payments applied before insterests
                    balance = (balance + pmt) * (1 + guess);
                }
            }
    
            // Returns the guess if balance is within tolerance.  If not, adjusts
            // the limits and starts with a new guess.
            if (Math.abs(balance + fv) < tolerance) {
                return guess;
            } else if (balance + fv > 0) {
                // Sets a new highLimit knowing that
                // the current guess was too big.
                highLimit = guess;
            } else  {
                // Sets a new lowLimit knowing that
                // the current guess was too small.
                lowLimit = guess;
            }
    
            // Calculates the new guess.
            guess = (highLimit + lowLimit) / 2;
        }
    
        // Returns null if no acceptable result was found after 40 tries.
        return null;
    };

    calculateEMIStartDate(disbursementDate){
        return disbursementDate.getDate() <=25 ? new Date(disbursementDate.getFullYear(), disbursementDate.getMonth() + 1, 10) : new Date(disbursementDate.getFullYear(), disbursementDate.getMonth() + 2, 10);
     }
}