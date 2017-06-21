class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
    get_shop_options
    set_role_options
    #@role_options = ["shop", "baker", "owner", "root", "none"]
    #@shop_options = Shop.all.order(:name).map{ |u| [u.name] }
    #logger.debug "@shop_options: " + @shop_optons.inspect
    #logger.debug "@role_options: " + @role_optons.inspect
  end

  # GET /users/1/edit
  def edit
    get_shop_options
    ###@shop_options = Shop.all.order(:name).map{ |u| [u.name] }
    #logger.debug "@shop_options: " + @shop_optons.inspect
    set_role_options
    #@role_options = ["shop", "baker", "owner", "root", "none"]
    #logger.debug "@role_options: " + @role_optons.inspect
  end

  # GET /users/1/editdayshop
  def editdayshop
    unless session[:user_id].nil?  # check that we are logged in
      @user = User.where(id: session[:user_id])
      ###@shop_list = Shop.find_by_sql [ "
      ###  select u.id as user_id, u.name, s.name, s.id as shop_id
      ###  FROM shops AS s
      ###  JOIN usershops AS x ON x.shop_id = s.id
      ###  JOIN users AS u ON u.id =x.user_id
      ###  WHERE user_id = ?
      ###", session[:user_id] ]
      ###@shop_options = @shop_list.map{ |u| [u.name]}
      #logger.debug "@shop_options: " + @shop_options.inspect
      get_shop_options
    else
      redirect_to users_url, notice: 'User is not logged in!!!'
    end
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        logger.debug "users controller - update => update successful"
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { render :show, status: :ok, location: @user }
      else
        logger.debug "users controller - update => update failed"
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1/updatedayshop
  # PATCH/PUT /users/1.json
  def updatedayshop
    @user = User.find(user_params[:id])
    #logger.debug "@user:" + @user.inspect

    @myparams = user_params
    #logger.debug "@myparams:" + @myparams.inspect

    @currentparams = @user.attributes
    #logger.debug "@currentparams:" + @currentparams.inspect

    @myshop = user_params[:shop]
    #logger.debug "@myshop:" + @myshop.inspect

    #@myday =Date.new @myparams["day(1i)"].to_i, @myparams["day(2i)"].to_i, @myparams["day(3i)"].to_i
    @myday = @myparams["day"]
    #logger.debug "@myparams day:" + @myparams["day"]
    #logger.debug "@myday:" + @myday.inspect
    
    if @user.shop != @myshop
      #logger.debug "shop has changed"
      unless @myshop.nil?
        #logger.debug "shop has valid value" + @myshop.inspect
        @user.update_attribute(:shop, @myshop)
      end
    end
    
    if @user.day != @myday
      #logger.debug "day has changed"
      unless @myday.nil?
        #logger.debug "day has valid value" + @myday.inspect
        @user.update_attribute(:day, @myday)
      end
    end
    #logger.debug "@user:" + @user.inspect

    respond_to do |format|
      if @user.save
        unless session[:user_id].nil?  # user is logged in
          # update matching session parameters
          session[:user_day] = @myday unless @myday.nil?
          unless @myshop.nil?
            @shop = Shop.find_by(name: @myshop)
            session[:user_shop] = @myshop
            session[:user_shop_id] = @shop.id
          end
        end
        logger.debug "users controller - update => update successful"
        format.html { redirect_to ordersedit_path }
        format.json { render :show, status: :ok, location: @user }
        
      else
        logger.debug "users controller - update => update failed"
        format.html { render :edit }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  # DELETE /users/1
  # DELETE /users/1.json
  # Never want to destroy users as they linked in the orders audit trail.
  # To disable a user, set the role to "none"
  def destroy
    respond_to do |format|
      if @user.destroy
        format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
        format.json { head :no_content }
      else
        if @user.errors.any?
          @notice_message = "prohibited this user from being destroyed"
          @user.errors.full_messages.each do |message|
            @notice_message += ": " + message
          end
        end
        format.html { redirect_to users_url, notice: @notice_message }
        format.json { head :no_content }      
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:id, :name, :email, :password, :password_confirmation, :role, :day, :shop,
        :shop_ids => []
      )
    end
    
    # consistent generatoion of the role options across the actions
    def set_role_options
      @role_options = ["shop", "baker", "owner", "root", "none"]
    end
end
