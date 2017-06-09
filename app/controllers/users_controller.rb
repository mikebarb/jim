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
    @shop_options = Shop.all.order(:name).map{ |u| [u.name] }
  end

  # GET /users/1/edit
  def edit
    @shop_options = Shop.all.order(:name).map{ |u| [u.name] }
  end

  # GET /users/1/editdayshop
  def editdayshop
    unless session[:user_id].nil?  # check that we are logged in
      @user = User.where(id: session[:user_id])
      @shop_options = Shop.all.order(:name).map{ |u| [u.name] }
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
    logger.debug "@user:" + @user.inspect

    @myparams = user_params
    logger.debug "@myparams:" + @myparams.inspect

    @currentparams = @user.attributes
    logger.debug "@currentparams:" + @currentparams.inspect

    @myshop = user_params[:shop]
    logger.debug "@myshop:" + @myshop.inspect

    #@myday =Date.new @myparams["day(1i)"].to_i, @myparams["day(2i)"].to_i, @myparams["day(3i)"].to_i
    @myday = @myparams["day"]
    logger.debug "@myparams day:" + @myparams["day"]
    logger.debug "@myday:" + @myday.inspect
    
    if @user.shop != @myshop
      logger.debug "shop has changed"
      unless @myshop.nil?
        logger.debug "shop has valid value" + @myshop.inspect
        @user.update_attribute(:shop, @myshop)
      end
    end
    
    if @user.day != @myday
      logger.debug "day has changed"
      unless @myday.nil?
        logger.debug "day has valid value" + @myday.inspect
        @user.update_attribute(:day, @myday)
      end
    end
    logger.debug "@user:" + @user.inspect

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
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:id, :name, :email, :password, :password_confirmation, :role, :day, :shop)
    end
end
