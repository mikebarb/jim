class OrdersController < ApplicationController
  ###before_action :check_login
  before_action :set_order, only: [:show, :edit, :update, :destroy]

  # GET /productshop
  def productshop
    @prodshop = Order.find_by_sql ["
      SELECT o.id, p.title, s.name, o.quantity, p.price, o.cost
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

    ###@rowheaders_keep = Order.find_by_sql ["
    ###  SELECT DISTINCT ON (p.title) p.title, o.id, o.product_id, p.sector_id
    ###  FROM orders AS o
    ###  INNER JOIN products AS p 
    ###  ON o.product_id = p.id AND o.day = ?
    ###  ORDER BY p.title ASC
    ###", @current_day]

    @rowheaders = Order.find_by_sql ["
      SELECT DISTINCT ON (p.title) p.title, o.id, o.product_id, p.sector_id, s.name
      FROM orders AS o
      INNER JOIN products AS p ON o.product_id = p.id AND o.day = ?
      INNER JOIN sectors AS s ON s.id = p.sector_id
      ORDER BY p.title ASC
    ", @current_day]
    #logger.debug "@rowheaders: " + @rowheaders.inspect 

    @summary = Array.new(2 + @rowheaders.count){Array.new(3 + @colheaders.count){Hash.new()}}

    i = 1
    @rowindex = Hash.new
    @rowheaders.sort_by(&:name).each do |entry|
      i += 1
      thisproduct=entry.title
      @summary[i][2]["value"] = 0
      @summary[i][0]["value"] = entry.name.to_str 
      @summary[i][1]["value"] = thisproduct 
      @rowindex[thisproduct] = i
    end
    #logger.debug "@rowindex: " + @rowindex.inspect
    
    j = 2
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
    @summary[1][2]["value"] = "Totals"
    @summary[1][0]["value"] = "Category"
    @summary[1][1]["value"] = "Products"
    @summary[0][3]["value"] = "Shops"
    
    @prodshop.each do |entry|
      thisprod = entry.title    #row - i
      thisshop = entry.name     #col - j
      @summary[@rowindex[thisprod]][@colindex[thisshop]]["value"]   = entry.quantity
      unless entry.cost.nil?    # if has not been locked yet, treat as 0 value.
        @summary[1][@colindex[thisshop]]["value"] += entry.quantity * entry.cost          #was price for product price, now from order table
      end
      @summary[@rowindex[thisprod]][2]["value"] += entry.quantity
    end
    j=2
    # format the currency cells
    @colheaders.each do |entry|
      j += 1
      @summary[1][j]["value"] = "$" + sprintf("%.2f", @summary[1][j]["value"])
    end
    
    #logger.debug "@summary: " + @summary.inspect
  end


  # GET /bakers
  def bakers
    #logger.debug "bakers:" + @bakers.inspect
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
              
    #logger.debug "lockday:" + @lockday.inspect
  end

 # GET /bakerdoes
  def bakerdoes
    @bakerdoes = Order.find_by_sql ["
      SELECT sum(quantity * r.amount) as totalqty, i.item, i.unit
      FROM orders AS o
      INNER JOIN products AS p ON o.product_id = p.id AND o.day = ?
      INNER JOIN recipes AS r ON p.id = r.product_id
      INNER JOIN ingredients AS i ON r.ingredient_id = i.id
      GROUP BY i.item, i.unit
    ", @current_day]
  end

  # GET /delivery
  def delivery
    @bakery = Shop.find(1)
    bakeryAddress = @bakery.address
    logger.debug("@bakery: " + @bakery.inspect)
    @bakeryA = bakeryAddress.split(",")
    logger.debug("@bakeryA: " + @bakeryA.inspect)
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
    @bakery = Shop.find(1)
    bakeryA = @bakery.address
    @bakeryA = bakeryA.split(",")
    logger.debug("@bakeryA: " + @bakeryA.inspect)
    logger.debug("@bakery: " + @bakery.inspect)
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
                    layout: "layouts/pdf.html.erb",
                    template: "orders/deliverypdf.pdf.erb",
                    locals: {:delivery => @delivery}#,
                    #show_as_html: true
      end
    end
  end

  # GET /ordersedit
  def indexedit
  # stuff required for the user update of day and shops
  logger.debug "current_user_id:" + @current_user_id.inspect
  @user = User.find(@current_user_id)
  logger.debug "@user:" + @user.inspect
  @shop_options = get_shop_options
  logger.debug "@shop_options: " + @shop_options.inspect
  # first up - check if there are already orders for this day
  # if not, give the user a chance to clone from an existing order
    @orders = Order.all
    .where("day = ? AND shop_id = ?", @current_day, @current_shop_id)
    if @orders.empty?                     # there are no orders for this day
      @noorders = true
      @copy_from_day = params[:copyfrom]
      unless @copy_from_day.blank?        # parameters has provided a day to copy from
        @orders_from = Order
                       .where("day =? AND shop_id = ?", @copy_from_day, @current_shop_id)
        if @orders_from.empty?         # make sure there is somethign to copy
          @noorders = true
          @copymessage = "You tried to copy from a day (" + @copy_from_day + ") that has no orders!!!"
        else                          # now proceed with the copy
          # determine fields for updating - copied orders and logging
          logfields = Hash.new
          logfields[:day] = @current_day
          logfields[:user_id] = @current_user_id
          logfields[:shop_id] = @current_shop_id
          @orders_from.each do |order|
            @order_new = Order.new(logfields)
            @order_new.product_id = order.product_id
            @order_new.quantity = order.quantity
            @order_new.locked = false
            @order_new.save
            # now for the audit log on the Order updates, creates and deletes
            @log = Orderlog.new(logfields)
            @log.product_id = order.product_id
            @log.quantity = order.quantity
            @log.oldquantity = 0
            @log.save
          end
          @noorders = false           # orders now present for today
        end
      end
    else
      @noorders = false
    end
    
    # We now process the normal display for ordering information.
    # Above this was simply detecting if this order was empty and what action to take.
    @products = Product.find_by_sql [ "
      SELECT p.id as product_id, p.title, p.description, p.leadtime, p.price, p.inactive, o.id as order_id, o.quantity, o.shop_id, o.day, o.locked, o.user_id, s.name as sector_name, o.cost
      FROM products AS p
      LEFT OUTER JOIN orders AS o ON p.id = o.product_id AND o.day = ? AND o.shop_id = ?
      INNER JOIN sectors AS s ON p.sector_id = s.id 
      WHERE p.inactive = false
      ORDER BY s.name, p.title
    ", @current_day, @current_shop_id ]
    
    ###logger.debug "@products: " + @products.inspect

    # Locked order items and days needs to be passed into the view simply.
    # The lock attribute on the ordered product is set here but never saved.
    # This order attribute is then used to determine if the view locks the 
    # quantity field - so that it cannot be changed in the view.
    #
    # check if this day has been locked by the baker
    # shown by the delivery day being added to the locked table
    @locked = Lockday
             .where("day = ?", @current_day)
             .count
    if @locked > 0
      # So lock all the products in this order
      @products.each do |p|  
        p.locked = true
      end
    elsif ["baker", "owner"].include? @current_role 
      # baker can overide individual locking limits based on time (but not if day is locked).
      # do nothing - all enteries are already false   
    else
      # check if individual products need to be locked based on time of week.
      # Need to now do some work to see if any ordere products for today should be locked
      # Need to reference midnight as the start of delivery day being processed.
      timedeliveryday = @current_day.to_time                  # epoch time of the currnt day at midnight
      timenow = Time.now                                      # epoch time of this  instant
      hoursdifference = (timedeliveryday - timenow)/3600      # how many hour till this order is due for delivery
      @products.each do |p|
        if(hoursdifference < p.leadtime)                             # order is OK to update
          p.locked = true
        end
      end        
    end
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
    @order.locked = false
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
    #logger.debug "@order: " + @order.inspect
    # now create the order log record
    @log = Orderlog.new
    @log.day = @order.day
    @log.user_id = @order.user_id
    @log.shop_id = @order.shop_id
    @log.product_id = @order.product_id
    @log.quantity = 0
    @log.oldquantity = @order.quantity
    #logger.debug "logging record: " + @log.inspect
    @order.destroy
    @log.save
    #logger.debug "logging record after save: " + @log.inspect
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
      params.require(:order).permit(:product_id, :shop_id, :day, :quantity, :locked, :user_id, :origqty, :cost)
    end
    
    # Check that the user has logged in
    ###def check_login
    ###  @current_user = session[:user_name]
    ###  if @current_user.nil? 
    ###    redirect_to login_url, alert: "login required to view & update Orders!!"
    ###  end
    ###  @current_shop = session[:user_shop]
    ###  @current_day = session[:user_day]
    ###  @current_shop_id = session[:user_shop_id]
    ###  @current_user_id = session[:user_id]
    ###end
end
