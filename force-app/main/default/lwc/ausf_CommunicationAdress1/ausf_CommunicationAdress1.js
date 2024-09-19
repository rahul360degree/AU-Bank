import { LightningElement } from 'lwc';

export default class Ausf_CommunicationAdress1 extends LightningElement {
    handleWheel(event) {
        const delta = Math.sign(event.deltaY); // Check the direction of the wheel
        const wheelPickerList = this.template.querySelector('.wheel-picker--list');
        wheelPickerList.scrollTop += delta * 40; // Adjust the scroll speed as needed
    }
}