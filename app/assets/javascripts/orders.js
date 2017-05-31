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
        var eleqty = $(this);
        var eleorigqty = $(this).parent().find(".origqty");
        var eleorderid = $(this).parent().parent().find(".order_id");
        var thisqty = Number($(this).val());
        var thisorigqty = Number($(eleorigqty).text());
        console.log("quantity values - thisqty:" + thisqty +
                " thisorigqty:" + thisorigqty);
        if (thisqty == thisorigqty){   // no values changed - do nothing.
         console.log("quantity has not changed thisqty:" + thisqty + " thisorigqty:" + thisorigqty);
         return;
        }
        if (thisorigqty == 0){         // so need to create an order record.
            console.log("now call ajax to create an order record");
            var myproduct_id = Number($(this).parent().parent().attr("id"));
            var myshop_id = Number($("#shop_id").text());
            var myday = $("#day").text();
            var myuser_id = Number($("#user_id").text());
            console.log("thisqty:" + thisqty);
            console.log("thisorigqty:" + thisorigqty);
            console.log("myproduct_id:" + myproduct_id);
            console.log("myshop_id:" + myshop_id);
            console.log("myday:" + myday);
            console.log("myuser_id:" + myuser_id);
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
                                  user_id: myuser_id
                                },
                        origqty: thisorigqty
                      },
                dataType: 'json',
                success: function(data){
                    $(eleorigqty).text(thisqty.toString());
                    $(eleqty).attr("id", data.id);
                    $(eleorderid).text(data.id);
                    
                    console.log("order record added by ajax successfully");
                    console.log(data);
                    console.log("returned id:" + data.id);
                    //alert("order record added");
                },
                error: function(){
                    console.log("orders ajax update failed");
                    alert("failed to add order record");
                }
            });
            return;
        } else if (thisqty == 0){         // so need to destroy an order record.
            console.log("now call ajax to detroy this order record");
            var myproduct_id = Number($(this).parent().parent().attr("id"));
            var myshop_id = Number($("#shop_id").text());
            var myday = $("#day").text();
            var myuser_id = Number($("#user_id").text());
            var myorder_id = Number($(this).attr("id"));
            console.log("thisqty:" + thisqty);
            console.log("thisorigqty:" + thisorigqty);
            console.log("myproduct_id:" + myproduct_id);
            console.log("myshop_id:" + myshop_id);
            console.log("myday:" + myday);
            console.log("myuser_id:" + myuser_id);
            console.log("myorder_id:" + myorder_id);
            $.ajax({
                type: 'DELETE',
                url: "https://jim-micmac.c9users.io/orders/" + myorder_id,
                dataType: 'json',
                success: function(){
                    $(eleorigqty).text("");
                    $(eleqty).val("");
                    $(eleqty).attr("id", "");
                    $(eleorderid).text("");
                    console.log("order record deleted by ajax successfully" + myorder_id);
                    //alert("order record deleted - myorder_id");
                },
                error: function(){
                    console.log("orders ajax deletion failed" + myorder_id);
                    alert("failed to delete order record - myorder_id");
                }
            });            
        } else {
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
        }
    });
});
    