import { LightningElement, track } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import SwiperBundleJS from '@salesforce/resourceUrl/SwiperJS';
import SwiperBundleCss from '@salesforce/resourceUrl/SwiperCss';

export default class ausf_CommunicationAddressCmp_Backup extends LightningElement {

    swiperLoaded = false;

     connectedCallback() {
        Promise.all([
            // loadScript(this, SwiperJS + '/swiper-bundle.min.js'),
            // loadStyle(this, SwiperCSS + '/swiper-bundle.min.css')
            loadScript(this, SwiperBundleJS),
            loadStyle(this, SwiperBundleCss)
            // loadScript(this, 'https://unpkg.com/swiper/swiper-bundle.min.js'),
            // loadStyle(this, 'https://unpkg.com/swiper/swiper-bundle.min.css')
        ])
        .then(() => {
            this.swiperLoaded = true;
            this.initializeSwiper();
        })
        .catch(error => {
            console.error('Error loading SwiperJS', error);
        });
    }

    initializeSwiper() {
            const swiper = new SwiperJS.Swiper('.swiper-container', {
                slidesPerView: 'auto',
                centeredSlides: true,
                loop: true,
                loopedSlides: 12, // Number of total slides
                navigation: {
                    nextEl: '.swiper-button-next',
                    prevEl: '.swiper-button-prev',
                },
            });
        }
}