/*
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
*/

/* global $ */

$(document).ready(function() {
  console.log("document ready");
  
  $(".qty").mouseleave(function(){
       console.log("mouse left quantity =  " + $(this).val() + " id = " + $(this).attr("id") );
       console.log("https://ide.c9.io/micmac/jim/orders_id/" + $(this).attr("id"));
       console.log("quantity: " + $(this).val());
       console.log("now call ajax");
       
     $.ajax({
        type: 'POST',
        url: "https://jim-micmac.c9users.io/orders/" + Number($(this).attr("id")),
        data: {
                quantity: Number($(this).val())
              },
        dataType: 'json',
        success: function(){
            console.log("orders ajax update done");
            alert("quantity updated")
        },
        error: function(){
            console.log("orders ajax update failed");
            alert("Faild to update quantity");
        }
      });       
  });
});
    