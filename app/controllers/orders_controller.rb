class OrdersController < ApplicationController
  before_action :check_login
  before_action :set_order, only: [:show, :edit, :update, :destroy]


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
              .where(day: params[:day])
              .joins(:product, :shop)
              .order(:product_id)
              
    @lockday = Lockday
                 .where(day: params[:day])
              
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

    @bakerdoes2 = Order.find_by_sql ["
      SELECT quantity as totalqty, p.title, i.item, r.amount
      FROM orders AS o
      INNER JOIN products AS p ON o.product_id = p.id AND o.day = ?
      INNER JOIN recipes AS r ON p.id = r.product_id
      INNER JOIN ingredients AS i ON r.ingredient_id = i.id
    ", @current_day]


    logger.debug "bakerdoes:" + @bakerdoes.inspect
              
  end

  # GET /delivery
  def delivery
    logger.debug "delivery:" + @delivery.inspect
    @delivery = Order.find_by_sql ["
      SELECT o.id, o.quantity, p.title, s.name as shop_name, o.shop_id
      FROM orders AS o
      INNER JOIN products AS p ON o.product_id = p.id AND o.day = ?
      INNER JOIN shops AS s ON o.shop_id = s.id
      ORDER BY s.name ASC, p.title ASC
    ", @current_day]
              
    logger.debug "delivery:" + @delivery.inspect
  end

  # GET /ordersedit
  def indexedit
    @products = Product.find_by_sql [ "
      SELECT p.id as product_id, p.title, p.description, p.leadtime, p.price, o.id as order_id, o.quantity, o.shop_id, o.day, o.locked, o.user_id
      FROM products AS p
      LEFT OUTER JOIN orders AS o 
      ON p.id = o.product_id
      AND o.day = ? AND o.shop_id = ?
      ORDER BY p.title
    ", @current_day, @current_shop_id ]
    
    @lockday = Lockday
             .where(day: @current_day)
    @locked = @lockday.count
          
    logger.debug "lockday:" + @lockday.inspect
    logger.debug "locked:" +  @locked.inspect
    logger.debug "products:" + @products.inspect
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

    respond_to do |format|
      if @order.save
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
    @order.quantity = params[:quantity]
    logger.debug "@order-2=" + @order.inspect
    respond_to do |format|
      if @order.update(order_params)
      #if @order.update(@order.attributes)
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
    @order.destroy
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
