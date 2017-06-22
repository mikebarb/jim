// Added to support the  menu function which is used as a header on all pages.

/* global $ */ 

var ready = function(){
 // hover property will help us set the events for mouse enter and mouse leave
    $('.navigation li').hover(
        // When mouse enters the .navigation element
        function () {
            //Fade in the navigation submenu
            $('ul', this).fadeIn();             // fadeIn will show the sub cat menu
        },
        // When mouse leaves the .navigation element
        function () {
            //Fade out the navigation submenu
            $('ul', this).fadeOut();            // fadeOut will hide the sub cat menu
        }
    );
};

$(document).ready(ready);
$(document).on('turbolinks:load', ready);
