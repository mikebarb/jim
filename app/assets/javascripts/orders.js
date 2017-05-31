/*
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
*/

/* global $ */

$(document).ready(function() {
    console.log("document ready");
  
    $(".qty").mouseleave(function(){
        //console.log("mouse left quantity =  " + $(this).val() + " id = " + $(this).attr("id") );
        //console.log("https://ide.c9.io/micmac/jim/orders_id/" + $(this).attr("id"));
        //console.log("quantity: " + $(this).val());
        //console.log("now call ajax");
       
        // do some checking if the value has changed
        var eleorigqty = $(this).parent().find(".origqty");
        var thisqty = Number($(this).val());
        var thisorigqty = Number($(eleorigqty).text());
        console.log("quantity values - thisqty:" + thisqty +
                " thisorigqty:" + thisorigqty);
        if (thisqty == thisorigqty){   // no values changed - do nothing.
         console.log("quantity has not changed thisqty:" + thisqty + " thisorigqty:" + thisorigqty);
         return;
        }
        if (thisorigqty == 0){         // so need to creaate an order record.
            console.log("now call ajax to create an order record");
            var myproduct_id = Number($("#user_id").text());
            var myshop_id = Number($("#shop_id").text());
            var myday = $("#day").text();
            var myuser_id = Number($("#user_id").text());
            console.log("thisqty:" + thisqty);
            console.log("thisorigqty:" + thisorigqty);
            console.log("myproduct_id:" + myproduct_id);
            console.log("myshop_id:" + myshop_id);
            console.log("myday:" + myday);
            console.log("myuser_id:" + myuser_id);
            if(1){
                return;
            }            
            $.ajax({
                type: 'POST',
                url: "https://jim-micmac.c9users.io/orders",
                data: {
                        order: {
                                  product_id: myproduct_id,
                                  shop_id: myshop_id,
                                  day: myday,
                                  quantity: thisqty,
                                  locked: 0,
                                  userid: myuser_id
                                },
                        origqty: thisorigqty
                      },
                dataType: 'json',
                success: function(){
                    $(eleorigqty).text(thisqty.toString());
                    console.log("order record added by ajax successfully");
                    alert("order record added");
                },
                error: function(){
                    console.log("orders ajax update failed");
                    alert("failed to add order record");
                }
            });
            return;
        }
        if (thisqty == 0){         // so need to destroy an order record.
            console.log("now call ajax to detroy this order record");
            return;
        }
        // well, we can just update the quantity.
        console.log("now call ajax to update quantity on existing record");
        $.ajax({
            type: 'POST',
            url: "https://jim-micmac.c9users.io/orders/" + Number($(this).attr("id")),

            data: {
                    order: {
                              quantity: Number($(this).val())
                            },
                    id: 1
                  },
            dataType: 'json',
            success: function(){
                $(eleorigqty).text(thisqty.toString());
                console.log("orders ajax update done");
                //alert("quantity updated");
            },
            error: function(){
                console.log("orders ajax update failed");
                alert("Faild to update quantity");
            }
        });       
    });
});
    