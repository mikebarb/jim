class OrdersController < ApplicationController
  before_action :check_login
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /productshop
  def productshop
    @prodshop = Order.find_by_sql ["
      SELECT o.id, p.title, s.name, o.quantity, p.price
      FROM orders AS o
      INNER JOIN products AS p ON o.product_id = p.id AND o.day = ?
      INNER JOIN shops AS s ON o.shop_id = s.id
    ", @current_day]
    #logger.debug "@prodshop: " + @prodshop.inspect 

    @colheaders = Order.find_by_sql ["
      SELECT DISTINCT ON (s.name) o.id, s.name, o.shop_id
      FROM orders AS o
      INNER JOIN shops AS s 
      ON o.shop_id = s.id AND o.day = ?
      ORDER BY s.name ASC
    ", @current_day]
    #logger.debug "@colheaders: " + @colheaders.inspect 

    @rowheaders = Order.find_by_sql ["
      SELECT DISTINCT ON (p.title) p.title, o.id, o.product_id
      FROM orders AS o
      INNER JOIN products AS p 
      ON o.product_id = p.id AND o.day = ?
      ORDER BY p.title ASC
    ", @current_day]
    #logger.debug "@rowheaders: " + @rowheaders.inspect 

    @summary = Array.new(2 + @rowheaders.count){Array.new(2 + @colheaders.count){Hash.new()}}

    i = 1
    @rowindex = Hash.new
    @rowheaders.each do |entry|
      i += 1
      thisproduct=entry.title
      @summary[i][1]["value"] = 0
      @summary[i][0]["value"] = thisproduct
      @rowindex[thisproduct] = i
    end
    #logger.debug "@rowindex: " + @rowindex.inspect
    
    j = 1
    @colindex = Hash.new
    @colheaders.each do |entry|
      j += 1
      thisshop=entry.name
      @summary[1][j]["value"] = 0
      @summary[0][j]["value"] = thisshop
      @colindex[thisshop] = j
    end
    #logger.debug "@colindex: " + @colindex.inspect
    
    #misc headers
    @summary[1][1]["value"] = "Totals"
    @summary[1][0]["value"] = "Products"
    @summary[0][1]["value"] = "Shops"
    
    
    @prodshop.each do |entry|
      thisprod = entry.title    #row - i
      thisshop = entry.name     #col - j
      @summary[@rowindex[thisprod]][@colindex[thisshop]]["value"]   = entry.quantity
      @summary[1][@colindex[thisshop]]["value"] += entry.quantity * entry.price
      @summary[@rowindex[thisprod]][1]["value"] += entry.quantity
    end
    j=1
    # format the currency cells
    @colheaders.each do |entry|
      j += 1
      @summary[1][j]["value"] = "$" + sprintf("%.2f", @summary[1][j]["value"])
    end
    
    #logger.debug "@summary: " + @summary.inspect
  end


  # GET /baker
  def bakers
    logger.debug "bakers:" + @bakers.inspect
    @bakers = Order.find_by_sql ["
      SELECT SUM(quantity) as totalqty, p.title
      FROM orders AS o
      INNER JOIN products AS p 
      ON o.product_id = p.id AND o.day = ?
      GROUP BY p.title
      ORDER BY p.title ASC
    ", @current_day]
    
    @baker1 = Order
              .where("day = ?", params[:day])
              .joins(:product, :shop)
              .order(:product_id)
              
    @lockday = Lockday
                 .where("day = ?", params[:day])
              
    logger.debug "lockday:" + @lockday.inspect
  end

 # GET /bakerdoes
  def bakerdoes
    @bakerdoes = Order.find_by_sql ["
      SELECT sum(quantity * r.amount) as totalqty, i.item
      FROM orders AS o
      INNER JOIN products AS p ON o.product_id = p.id AND o.day = ?
      INNER JOIN recipes AS r ON p.id = r.product_id
      INNER JOIN ingredients AS i ON r.ingredient_id = i.id
      GROUP BY i.item
    ", @current_day]
  end

  # GET /delivery
  def delivery
    @delivery = Order.find_by_sql ["
      SELECT o.id, o.quantity, p.title, s.name as shop_name, o.shop_id
      FROM orders AS o
      INNER JOIN products AS p ON o.product_id = p.id AND o.day = ?
      INNER JOIN shops AS s ON o.shop_id = s.id
      ORDER BY s.name ASC, p.title ASC
    ", @current_day]
  end

  # GET /deliverypdf
  def deliverypdf
    @delivery = Order.find_by_sql ["
      SELECT o.id, o.quantity, p.title, s.name as shop_name, o.shop_id
      FROM orders AS o
      INNER JOIN products AS p ON o.product_id = p.id AND o.day = ?
      INNER JOIN shops AS s ON o.shop_id = s.id
      ORDER BY s.name ASC, p.title ASC
    ", @current_day]
    
    respond_to do |format|
      format.html do
        render pdf: "Delivery_Dockets",
                    template: "orders/deliverypdf.pdf.erb",
                    locals: {:delivery => @delivery}
      end
    end
  end

  # GET /ordersedit
  def indexedit
  # first up - check if there are already orders for this day
  # if not, give the user a chance to clone from an existing order
    @orders = Order.all
    .where("day = ? AND shop_id = ?", @current_day, @current_shop_id)

    #logger.debug "@orders: " + @orders.inspect

    if @orders.empty? then              # there are no orders for this day
      #logger.debug "today's order array is empty."
      @noorders = true
      #logger.debug "parameters: " + params.inspect
      @copy_from_day = params[:copyfrom]
      #logger.debug "@copy_from_day: " + @copy_from_day.inspect
      
      unless @copy_from_day.blank?        # parameters has provided a day to copy from
        #logger.debug "copy_from_day parameters present " + @copy_from_day.inspect
        @orders_from = Order
                       .where("day =? AND shop_id = ?", @copy_from_day, @current_shop_id)
        #logger.debug "@orders_from: " + @orders_from.inspect
        if @orders_from.empty?         # make sure there is somethign to copy
          @noorders = true
          @copymessage = "You tried to copy from a day (" + @copy_from_day + ") that has no orders!!!"
          #logger.debug "You tried to copy from a day that has no orders!!!" + @copy_from_day
        else                          # now proceed with the copy
          #logger.debug "copy the orders from " + params[:copyfrom] + " to " + params[:copyto];
          # determine fields for updating - copied orders and logging
          logfields = Hash.new
          logfields[:day] = @current_day
          logfields[:user_id] = @current_user_id
          logfields[:shop_id] = @current_shop_id
          #logger.debug "logfields hash: " + logfields.inspect
          @orders_from.each do |order|
            @order_new = Order.new(logfields)
            @order_new.product_id = order.product_id
            @order_new.quantity = order.quantity
            @order_new.locked = false
            #logger.debug "@order_new - just before saving: " + @order_new.inspect
            @order_new.save
            # now for the audit log on the Order updates, creates and deletes
            @log = Orderlog.new(logfields)
            @log.product_id = order.product_id
            @log.quantity = order.quantity
            @log.oldquantity = 0
            #logger.debug "logging record: " + @log.inspect
            @log.save
          end
          @noorders = false           # orders now present for today
        end
      end
    else
      #logger.debug "this order array has content."
      @noorders = false
    end
    #logger.debug "@noorders: " + @noorders.inspect
    #logger.debug "@copymessage: " + @copymessage.inspect

    # We now process the normal display for ordering information.
    # Above this was simply detecting if this order was empty and what action to take.
    @products = Product.find_by_sql [ "
      SELECT p.id as product_id, p.title, p.description, p.leadtime, p.price, o.id as order_id, o.quantity, o.shop_id, o.day, o.locked, o.user_id, s.name as sector_name, o.cost
      FROM products AS p
      LEFT OUTER JOIN orders AS o ON p.id = o.product_id AND o.day = ? AND o.shop_id = ?
      INNER JOIN sectors AS s ON p.sector_id = s.id 
      ORDER BY s.name, p.title
    ", @current_day, @current_shop_id ]

    @lockday = Lockday
             .where("day = ?", @current_day)
    @locked = @lockday.count

    #logger.debug "lockday:" + @lockday.inspect
    #logger.debug "locked:" +  @locked.inspect
    #logger.debug "products:" + @products.inspect
  end

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
    .order(:day, :shop_id, :product_id)
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
  end

  # GET /orders/new
  def new
    @order = Order.new
  end

  # GET /orders/1/edit
  def edit
  end

  # POST /orders
  # POST /orders.json
  def create
    @order = Order.new(order_params)
    logger.debug "@order - passed in: " + @order.inspect
    # now create the order log record
    @log = Orderlog.new
    @log.day = @order.day
    @log.user_id = @order.user_id
    @log.shop_id = @order.shop_id
    @log.product_id = @order.product_id
    @log.quantity = @order.quantity
    @log.oldquantity = 0
    logger.debug "logging record: " + @log.inspect
    respond_to do |format|
      if @order.save
        @log.save
        format.html { redirect_to @order, notice: 'Order was successfully created.' }
        format.json { render :show, status: :created, location: @order }
      else
        format.html { render :new }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orders/1
  # PATCH/PUT /orders/1.json
  def update
    logger.debug "controller orders update called"
    logger.debug "@order-1=" + @order.inspect
    
    # now create the order log record
    @log = Orderlog.new
    @log.oldquantity = @order.quantity
    #@order.quantity = params[:quantity]
    logger.debug "@order-2=" + @order.inspect
    respond_to do |format|
      if @order.update(order_params)
        logger.debug "@order - after update: " + @order.inspect
        @log.day = @order.day
        @log.user_id = @order.user_id
        @log.shop_id = @order.shop_id
        @log.product_id = @order.product_id
        @log.quantity = @order.quantity
        logger.debug "logging record: " + @log.inspect
        @log.save
        logger.debug "Order controller - successful update"
        format.html { redirect_to @order, notice: 'Order was successfully updated.' }
        format.js
        format.json { render :show, status: :ok, location: @order }
      else
        logger.debug "Order controller - failed update"
        format.html { render :edit }
        format.json { render json: @order.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    logger.debug "@order: " + @order.inspect
    # now create the order log record
    @log = Orderlog.new
    @log.day = @order.day
    @log.user_id = @order.user_id
    @log.shop_id = @order.shop_id
    @log.product_id = @order.product_id
    @log.quantity = 0
    @log.oldquantity = @order.quantity
    logger.debug "logging record: " + @log.inspect
    @order.destroy
    @log.save
    logger.debug "logging record after save: " + @log.inspect
    respond_to do |format|
      format.html { redirect_to orders_url, notice: 'Order was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order
      @order = Order.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def order_params
      #params.require(:id).permit(:product_id, :shop_id, :day, :quantity, :locked, :user_id)
      params.require(:order).permit(:product_id, :shop_id, :day, :quantity, :locked, :user_id, :origqty)
    end
    
    # Check that the user has logged in
    def check_login
      @current_user = session[:user_name]
      if @current_user.nil? 
        redirect_to login_url, alert: "login required to view & update Orders!!"
      end
      @current_shop = session[:user_shop]
      @current_day = session[:user_day]
      @current_shop_id = session[:user_shop_id]
      @current_user_id = session[:user_id]
    end
end
