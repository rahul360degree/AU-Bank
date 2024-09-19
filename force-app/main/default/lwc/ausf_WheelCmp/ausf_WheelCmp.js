/**
 * @description       : Wheel Component For AU Tenure Selection
 * @author            : Charchit Nirayanwal
 * @group             : 
 * @last modified on  : 12-07-2024 
 * @last modified by  : Charchit Nirayanwal
 * @Jira Story        : APL-942
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   12-07-2024   Charchit Nirayanwal  Initial Version
**/

import { LightningElement, api } from 'lwc';

export default class Ausf_WheelCmp extends LightningElement {
    @api items
    @api heading = 'Year'
    @api value
    rendered = false;

    handleScroll(event) {
        const container = event.target;
        const items = Array.from(container.querySelectorAll('.item'));

        const itemRect = items[0].offsetHeight;
        const numberOfElementsScrolled = Math.round(container.scrollTop / itemRect);

        items.forEach(item => {
            item.classList.remove('highlight');
        });

        items[numberOfElementsScrolled + 2].classList.add('highlight');

        const eventSend = new CustomEvent('update', {
            detail: {
                value: items[numberOfElementsScrolled + 2].innerText
            }
        });
        this.dispatchEvent(eventSend);
    }


    connectedCallback(){
        this.updateInputField()

    }

    // renderedCallback() {
    //     if (!this.rendered) {
    //         this.rendered = true;
    //         this.updateInputField();
    //     }
    // }

    updateInputField() {
        requestAnimationFrame(() => {
            const scrollWin = this.template.querySelector('.scroll-container');
            const scrollItems = scrollWin.querySelectorAll('.item')

            if (scrollItems && scrollWin) {
                if (this.value == null || this.value == '' || this.value == undefined) {
                    scrollWin.scrollTop = (((this.items.length / 2) - 2) * scrollItems[0].offsetHeight);
                    scrollItems[(this.items.length / 2) + 2].classList.add('highlight');
                }
                else {

                    for (let i = scrollItems.length/2; i < scrollItems.length; i++) {
                        if (scrollItems[i].innerText == this.value) {
                            console.log("innertext-->", scrollItems[i].innerText)
                            scrollItems[i].classList.add('highlight');
                            scrollWin.scrollTop = (i - 2) * (scrollItems[0].offsetHeight);
                            break;
                        }
                    }
                }
            }
        })
    }
}