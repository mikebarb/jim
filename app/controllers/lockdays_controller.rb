class LockdaysController < ApplicationController
  before_action :set_lockday, only: [:show, :edit, :update, :destroy]

  # GET /lockdays
  # GET /lockdays.json
  def index
    @lockdays = Lockday.all
  end

  # GET /lockdays/1
  # GET /lockdays/1.json
  def show
  end

  # GET /lockdays/new
  def new
    @lockday = Lockday.new
  end

  # GET /lockdays/1/edit
  def edit
  end

  # POST /locktoday
  def locktoday
    @lockday = Lockday.new()
    @lockday.day = session[:user_day]
    @lockday.locked = true
    @lockday.user_id = session[:user_id]
    respond_to do |format|
      if @lockday.save
        format.html { redirect_to ordersedit_path, notice: 'Lockday was successfully created.' }
        format.json { render :show, status: :created, location: @lockday }
      else
        format.html { render :new }
        format.json { render json: @lockday.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /lockdays
  # POST /lockdays.json
  def create
    @lockday = Lockday.new(lockday_params)
    respond_to do |format|
      if @lockday.save
        format.html { redirect_to @lockday, notice: 'Lockday was successfully created.' }
        format.json { render :show, status: :created, location: @lockday }
      else
        format.html { render :new }
        format.json { render json: @lockday.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lockdays/1
  # PATCH/PUT /lockdays/1.json
  def update
    respond_to do |format|
      if @lockday.update(lockday_params)
        format.html { redirect_to @lockday, notice: 'Lockday was successfully updated.' }
        format.json { render :show, status: :ok, location: @lockday }
      else
        format.html { render :edit }
        format.json { render json: @lockday.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lockdays/1
  # DELETE /lockdays/1.json
  def destroy
    @lockday.destroy
    respond_to do |format|
      format.html { redirect_to lockdays_url, notice: 'Lockday was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_lockday
      @lockday = Lockday.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lockday_params
      params.require(:lockday).permit(:day, :locked, :user_id)
    end
end
