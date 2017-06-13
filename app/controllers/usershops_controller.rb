class UsershopsController < ApplicationController
  before_action :set_usershop, only: [:show, :edit, :update, :destroy]

  # GET /usershops
  # GET /usershops.json
  def index
    @usershops = Usershop.all
  end

  # GET /usershops/1
  # GET /usershops/1.json
  def show
  end

  # GET /usershops/new
  def new
    @usershop = Usershop.new
    @shop_options = Shop.all.order(:name).map{ |u| [u.name, u.id] }
    @user_options = User.all.order(:name).map{ |u| [u.name, u.id] }
  end

  # GET /usershops/1/edit
  def edit
    @shop_options = Shop.all.order(:name).map{ |u| [u.name, u.id] }
    @user_options = User.all.order(:name).map{ |u| [u.name, u.id] }
  end

  # POST /usershops
  # POST /usershops.json
  def create
    @usershop = Usershop.new(usershop_params)
    respond_to do |format|
      if @usershop.save
        format.html { redirect_to usershops_path, notice: 'Usershop was successfully created.' }
        format.json { render :show, status: :created, location: @usershop }
      else
        format.html { render :new }
        format.json { render json: @usershop.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /usershops/1
  # PATCH/PUT /usershops/1.json
  def update
    respond_to do |format|
      if @usershop.update(usershop_params)
        format.html { redirect_to usershops_path, notice: 'Usershop was successfully updated.' }
        format.json { render :show, status: :ok, location: @usershop }
      else
        format.html { render :edit }
        format.json { render json: @usershop.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /usershops/1
  # DELETE /usershops/1.json
  def destroy
    @usershop.destroy
    respond_to do |format|
      format.html { redirect_to usershops_url, notice: 'Usershop was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_usershop
      @usershop = Usershop.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def usershop_params
      params.require(:usershop).permit(:user_id, :shop_id)
    end
end
