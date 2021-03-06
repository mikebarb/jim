/*
# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
*/

/* global $ */

//$(document).ready(function() {     
var ordersready = function() {
    console.log("document ready from inside ordersready");
    
    $('.info-wrapper').find('form[class="edit_user"]').find('input[type=submit]').hide();
    
    $(".auto-submit-item").on('change', (function(){
        console.log("autosubmit");
        console.log(this);
        $(this).parents("form").submit();
    }));
    
    
    
    $(".sector").click(function(){
        console.log("sector clicked");
        var mytable = $(this).next();
        console.log (this);
        console.log (mytable);
        $(mytable).slideToggle();
        $(mytable).toggleClass("hideme");
        var myval = 0;
        if ($(mytable).hasClass("hideme")) {
            var flagContent = 0;
            $.each($(this).next().find(".qty"), function( index, el ){
                myval = Number($(el).val());
                if (myval > 0) {
                    flagContent += 1;
                }
            })
            $.each($(this).next().find(".qty_locked"), function( index, el ){
                myval = Number($(el).text());
                if (myval > 0) {
                    flagContent += 1;
                }
            })        
            $(this).children("b").children("span").remove();
            if (flagContent > 0){
                $(this).children("b").append("<span> +    selected " + flagContent + " items </span>");
            } else {
                $(this).children("b").append("<span> + </span>");
            }
        } else {
            $(this).children("b").children("span").remove();
            $(this).children("b").append("<span> - </span>");
        }
        console.log (this);
    });
    
    $(".qty").each(function() {
        if ($(this).val() != "") {
            $(this).parent().parent().css('background-color', '#FCB3BC');
        }
    });
    
    $(".qty_locked").each(function() {
        if ($(this).text() != "") {
            $(this).parent().css('background-color', '#FCB3BC');
        }
    });

    $(".noclonebutton").click(function(){
        console.log("noclonebutton clicked");
        $(this).parents(".checkordersempty").empty();
    });
  
    $(".qty").on("focusout keypress", function(e){
        if(e.type == "keypress"){
            console.log("detected keypress");
            var keycode = (e.keyCode ? e.keyCode : e.which); 
            if(keycode != '13'){
              return;
            }
        }
       
        // do some checking if the value has changed
        var eleqty = $(this);
        var eleorigqty = $(this).parent().find(".origqty");
        var eleorderid = $(this).parent().parent().find(".order_id");
        var orderid = Number($(eleorderid).text());
        console.log("orderid: " + orderid);
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
            var myshop = $('#shop option:selected').attr('value');
            var myshop_id = Number($('#shop_id').text());
            var myday = $("#day").val();
            var myuser_id = Number($("#user_id").val());
            //console.log(myshop);
            //console.log("myshop_id: " + myshop_id);
            //console.log("thisqty:" + thisqty);
            //console.log("thisorigqty:" + thisorigqty);
            //console.log("myproduct_id:" + myproduct_id);
            //console.log("myday:" + myday);
            //console.log("myuser_id:" + myuser_id);
            $.ajax({
                type: 'POST',
                url: "orders",
                data: {
                        order: {
                                  product_id: myproduct_id,
                                  shop_id: myshop_id,
                                  day: myday,
                                  quantity: thisqty,
                                  locked: 0,
                                  cost: 0,
                                  user_id: myuser_id
                                },
                        origqty: thisorigqty
                      },
                dataType: 'json',
                success: function(data){
                    $(eleorigqty).text(thisqty.toString());
                    $(eleqty).attr("id", data.id);
                    $(eleorderid).text(data.id);
                    $(eleqty).parent().parent().css('background-color', '#FCB3BC');
                    
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
            var myorder_id = orderid;
            //console.log("thisqty:" + thisqty);
            //console.log("thisorigqty:" + thisorigqty);
            //console.log("myproduct_id:" + myproduct_id);
            //console.log("myshop_id:" + myshop_id);
            //console.log("myday:" + myday);
            //console.log("myuser_id:" + myuser_id);
            //console.log("myorder_id:" + myorder_id);
            $.ajax({
                type: 'DELETE',
                url: "orders/" + myorder_id,
                dataType: 'json',
                success: function(){
                    $(eleorigqty).text("");
                    $(eleqty).val("");
                    $(eleqty).attr("id", "");
                    $(eleorderid).text("");
                    $(eleqty).parent().parent().css('background-color', '#FFFFFF');
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
            $(eleqty).parent().parent().css('background-color', '#FFFFFF');
            $.ajax({
                type: 'POST',
                url: "orders/" + orderid,
    
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
                    $(eleqty).parent().parent().css('background-color', '#FCB3BC');
                },
                error: function(){
                    console.log("orders ajax update failed");
                    alert("Faild to update quantity");
                    $(eleqty).parent().parent().css('background-color', '#FCB3BC');
                }
            });
        }
    });
};

//$(document).on('turbolinks:load', ordersready);
$(document).on('turbolinks:load', ordersready);

