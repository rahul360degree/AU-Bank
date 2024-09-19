import { LightningElement,api,track } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';

export default class Ausf_GenericHeaderCmp extends LightningElement {

    headerIconURL = Assets + '/AU_Assets/images/IB.png';
    disabledBackButtonURL = Assets +'/AU_Assets/images/arrow-left.png';
    activeBackButtonURL = Assets +'/AU_Assets/images/arrow-left-active.png';

    @api showContents;
    @api headerContents
    @api containerDescription;
    @api journeySteps;
    @api currentJourney;
    @api numberOfSteps;
    @api activeStep;
    @api enableBackButton;
    @api currentScreenName;
    @api backScreenName;
    @api nextScreenName;
    @api overrideBack = false;

    @track stepsCollection = [];

    connectedCallback(){
        // console.log(this.journeySteps,this.currentJourney,this.numberOfSteps,this.activeStep,this.enableBackButton,typeof this.enableBackButton);
        // if(this.journeySteps && this.numberOfSteps && this.activeStep){
        //     //journery 4 currentjourney 3 steps 5 activestep 3
        //     let data = [];
        //     for (let i = 1; i <= this.journeySteps; i++) {
        //         if(this.currentJourney != i){
        //             let element = {class: 'journeyProgress',value:this.currentJourney > i?100:0};
        //             data.push(element);
        //         }
        //         else if(this.currentJourney == i){
        //             let element = {class:'journeyProgress', value:(this.activeStep/this.numberOfSteps)*100};
        //             data.push(element);
        //         }
        //     }
        //     this.stepsCollection = [];
        //     this.stepsCollection = data;
        // }
        if(this.numberOfSteps && this.activeStep){
            //journery 4 currentjourney 3 steps 5 activestep 3
            let data = [];
            for (let i = 1; i <= this.numberOfSteps; i++) {

                if(this.activeStep != i){
                    let element = {class: 'journeyProgress',value:this.activeStep > i?100:0};
                    data.push(element);
                }
                else if(this.activeStep == i){
                    let element = {class:'journeyProgress', value:50};
                    data.push(element);
                }
            }
            console.log(data,this.numberOfSteps,this.activeStep);
            this.stepsCollection = [];
            this.stepsCollection = data;
        }
    }

    handleBackRedirection(event){
        try {
            console.log('clicked back',this.overrideBack);
            if(this.overrideBack){
                const backEvent = new CustomEvent('backevent', {
                    detail: {
                        currentScreen:this.currentScreenName,
                    },
                });
                this.dispatchEvent(backEvent);
            }else{
                const backEvent = new CustomEvent('backevent', {
                    detail: {
                        currentScreen:this.currentScreenName,
                    },
                    composed:true,
                    bubbles:true
                });
                this.dispatchEvent(backEvent);
            }
        } catch (error) {
            console.error(error);
        }
    }
}