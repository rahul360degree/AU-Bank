import { LightningElement } from 'lwc';

export default class TransitionTest extends LightningElement {
   
    currentIndex = 0;
    elements = [];

    showElement(index, direction) {
        console.log('index - > ' + index + ' AND direction -> ' + direction);

        if (direction === 'next') {
            this.elements.forEach((element, i) => {
                element.classList.remove('visible');
                element.classList.add('hidden');
            });
    
            const element = this.elements[index];
            element.classList.remove('hidden');
            element.classList.add('visible');
            element.animate([
                { opacity: 0, transform: 'translateX(100%) scale(0.5)' },
                { opacity: 1, transform: 'translateX(0) scale(1)' }
            ], { duration: 700, easing: 'ease-in' }).onfinish = () => {
                element.style.opacity = 1;
                element.style.transform = 'translateX(0) scale(1)';
            };
        }else if (direction === 'back') {
            const element = this.elements[index + 1];
            const elementPrev = this.elements[index];
            console.log(element.classList);
            console.log(elementPrev.classList);
            
            element.animate([
                { opacity: 1, transform: 'translateX(0) scale(1)' },
                { opacity: 0, transform: 'translateX(100%) scale(0.5)' }
            ], { duration: 700, easing: 'ease-in' }).onfinish = () => {
                element.style.opacity = 0;
                element.style.transform = 'translateX(100%) scale(0.5)';
                elementPrev.classList.remove('hidden');
                elementPrev.classList.add('visible');
                element.classList.add('hidden');
            };
        }
    }

    handleNext() {
        console.log('NEXT');
        if (this.currentIndex < this.elements.length - 1) {
            this.currentIndex++;
            this.showElement(this.currentIndex, 'next');
        }
    }

    handleBack() {
        console.log('BACK');
        if (this.currentIndex > 0) {
            this.currentIndex--;
            this.showElement(this.currentIndex, 'back');
        }
    }



    renderedCallback() {
        // Initial display
        this.currentIndex = 0;
        this.elements = [
            this.template.querySelector('.screen-element1'),
            this.template.querySelector('.screen-element2')
        ];
        this.elements.forEach((element, i) => {
            element.classList.remove('visible');
            element.classList.add('hidden');
        });

        const element = this.elements[this.currentIndex];
        element.classList.remove('hidden');
        element.classList.add('visible');

        console.log('elements');
        console.log(this.elements);
        this.showElement(this.currentIndex);
    }

}