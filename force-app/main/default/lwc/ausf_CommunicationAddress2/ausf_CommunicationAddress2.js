import { LightningElement } from 'lwc';

export default class Ausf_CommunicationAddress2 extends LightningElement {
    wheelPickerList = '';
    startPosition =  0;
    isScrolling = false;
    currentY = 0;


    connectedCallback(){
        this.wheelPickerList = this.template.querySelector('.wheel-picker--list').addEventListener('mousedown', function(event) {
            this.isScrolling = true;
            this.startPosition = event.clientY;
            this.currentY = this.wheelPickerList.offsetTop;
        
            this.template.addEventListener('mousemove', this.handleMouseMove());
            this.template.addEventListener('mouseup', this.handleMouseUp());
          });

    }

    
        handleMouseMove(event) {
          if (!this.isScrolling) return;
      
          const deltaY = event.clientY - startPosition;
          const newPosition = this.currentY + deltaY;
          wheelPickerList.style.top = `${newPosition}px`;
        }
      
        handleMouseUp() {
          isScrolling = false;
          this.template.removeEventListener('mousemove', handleMouseMove);
          this.template.removeEventListener('mouseup', handleMouseUp);
        }
    
}