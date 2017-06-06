class OrderlogsController < ApplicationController
  before_action :check_login
  before_action :set_orderlog, only: [:show, :edit, :update, :destroy]

  # GET /orderlogs
  # GET /orderlogs.json
  def index
    @orderlogs = Product.find_by_sql [ "
      SELECT o.id, o.created_at as updated, o.quantity, o.oldquantity, s.name as shop_name, o.day, u.name as user_name, p.title as product_name
      FROM orderlogs AS o
      INNER JOIN products AS p ON p.id = o.product_id
      INNER JOIN shops AS s ON s.id = o.shop_id
      INNER JOIN users AS u ON u.id = o.user_id
      ORDER BY o.created_at
    "]
    
  end


  # GET /orderlogsdayshop
  # GET /orderlogsdayshop.json
  def indexdayshop
    @orderlogs = Product.find_by_sql [ "
      SELECT o.id, o.created_at as updated, o.quantity, o.oldquantity, s.name as shop_name, o.day, u.name as user_name, p.title as product_name
      FROM orderlogs AS o
      INNER JOIN products AS p ON p.id = o.product_id
      INNER JOIN shops AS s ON s.id = o.shop_id
      INNER JOIN users AS u ON u.id = o.user_id
      AND o.day = ? AND o.shop_id = ?
      ORDER BY o.created_at
    ", @current_day, @current_shop_id ]
  end

  # GET /orderlogs/1
  # GET /orderlogs/1.json
  def show
  end

  # GET /orderlogs/new
  def new
    @orderlog = Orderlog.new
  end

  # GET /orderlogs/1/edit
  def edit
  end

  # POST /orderlogs
  # POST /orderlogs.json
  def create
    @orderlog = Orderlog.new(orderlog_params)

    respond_to do |format|
      if @orderlog.save
        format.html { redirect_to @orderlog, notice: 'Orderlog was successfully created.' }
        format.json { render :show, status: :created, location: @orderlog }
      else
        format.html { render :new }
        format.json { render json: @orderlog.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /orderlogs/1
  # PATCH/PUT /orderlogs/1.json
  def update
    respond_to do |format|
      if @orderlog.update(orderlog_params)
        format.html { redirect_to @orderlog, notice: 'Orderlog was successfully updated.' }
        format.json { render :show, status: :ok, location: @orderlog }
      else
        format.html { render :edit }
        format.json { render json: @orderlog.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /orderlogs/1
  # DELETE /orderlogs/1.json
  def destroy
    @orderlog.destroy
    respond_to do |format|
      format.html { redirect_to orderlogs_url, notice: 'Orderlog was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_orderlog
      @orderlog = Orderlog.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def orderlog_params
      params.require(:orderlog).permit(:product, :shop, :day, :user)
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
