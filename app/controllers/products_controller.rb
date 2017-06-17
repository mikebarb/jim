class ProductsController < ApplicationController
  before_action :set_product, only: [:show, :edit, :update, :destroy]

  # GET /displayproducts
  def display
    #@products = Product.includes(:sector).all
    #            .order("sectors.name, title")
                
    @products = Product.find_by_sql [ "
      SELECT p.id as product_id, p.title, p.description, p.leadtime, p.price, p.inactive, s.name as sector_name
      FROM products AS p
      INNER JOIN sectors AS s ON p.sector_id = s.id and p.inactive = FALSE
      ORDER BY s.name, p.title
    "]
    logger.debug "@products: " + @products.inspect
  end

  # GET /products
  # GET /products.json
  def index
    #@products = Product.all
    #            .order("title")
    @products = Product.includes(:sector).all
                .order("sectors.name, title")
  end

  # GET /products/1
  # GET /products/1.json
  def show
  end

  # GET /products/new
  def new
    @product = Product.new
    @sector_options = Sector.all.map{ |u| [u.name, u.id] }
  end

  # GET /products/1/edit
  def edit
    @sector_options = Sector.all.map{ |u| [u.name, u.id] }
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to products_path, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /products/1
  # PATCH/PUT /products/1.json
  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to products_path, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  # never what a product destroyed as it it linked to the orders
  # Can inactive through the edit panel.
  ###def destroy
  ###  @product.destroy
  ###  respond_to do |format|
  ###    format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
  ###    format.json { head :no_content }
  ###  end
  ###end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product
      @product = Product.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def product_params
      params.require(:product).permit(:title, :description, :leadtime, :price, :sector_id, :sector, :inactive)
    end
end
