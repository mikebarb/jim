class OrdersController < ApplicationController
  before_action :check_login
  before_action :set_order, only: [:show, :edit, :update, :destroy]

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
    logger.debug "products:" + @products.inspect
  end

  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.all
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
