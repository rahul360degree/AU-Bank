import { LightningElement,api,track } from 'lwc';
import Assets from '@salesforce/resourceUrl/AU_Assets';

export default class OuterContainerCmp extends LightningElement {

    disabledBackButtonURL = Assets +'/AU_Assets/images/arrow-left.png';
    activeBackButtonURL = Assets +'/AU_Assets/images/arrow-left-active.png';
    @api containerDescription;
    @api journeySteps;
    @api currentJourney;
    @api numberOfSteps;
    @api activeStep;
    @api enableBackButton;
    @api currentScreenName;
    @api backScreenName;
    @api nextScreenName;
    @track stepsCollection = [];

    connectedCallback(){
        // console.log(this.journeySteps,this.currentJourney,this.numberOfSteps,this.activeStep,this.enableBackButton,typeof this.enableBackButton);
        if(this.journeySteps && this.numberOfSteps && this.activeStep){
            //journery 4 currentjourney 3 steps 5 activestep 3
            let data = [];
            for (let i = 1; i <= this.journeySteps; i++) {
                if(this.currentJourney != i){
                    let element = {class: 'journeyProgress',value:this.currentJourney > i?100:0};
                    data.push(element);
                }
                else if(this.currentJourney == i){
                    let element = {class:'journeyProgress', value:(this.activeStep/this.numberOfSteps)*100};
                    data.push(element);
                }
            }
            this.stepsCollection = [];
            this.stepsCollection = data;
        }
    }

    handleBackRedirection(event){
        try {
            console.log('clicked back');
            const backEvent = new CustomEvent('backevent', {
                detail: {
                    currentScreen:this.currentScreenName,
                },
                composed:true,
                bubbles:true
            });
            this.dispatchEvent(backEvent);
        } catch (error) {
            console.error(error);
        }
    }
}