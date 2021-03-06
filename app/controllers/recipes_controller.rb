class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :update, :destroy]

  # GET /recipes
  # GET /recipes.json
  #def index1
  #  @recipes = Recipe.all
  #end

  def index
    @recipes = Recipe.find_by_sql [ "
      SELECT r.id, r.product_id AS product_id, r.ingredient_id AS ingredient_id, p.title,  r.amount, i.item, i.unit
      FROM recipes AS r
      FULL OUTER JOIN products AS p ON p.id = r.product_id
      FULL OUTER JOIN ingredients AS i ON i.id = r.ingredient_id
      ORDER BY p.title
    " ]   
  end
  logger.debug "@recipes" + @recipes.inspect

  # GET /recipes/1
  # GET /recipes/1.json
  def show
  end

  # GET /recipes/new
  def new
    @recipe = Recipe.new
    @product_options = Product.all.order(:title).map{ |u| [u.title, u.id] }
    @ingredient_options = Ingredient.all.order(:item).map{ |u| [u.item, u.id] }
    
  end

  # GET /recipes/1/edit
  def edit
    @product_options = Product.all.map{ |u| [u.title, u.id] }
    @ingredient_options = Ingredient.all.map{ |u| [u.item, u.id] }
  end

  # POST /recipes
  # POST /recipes.json
  def create
    @recipe = Recipe.new(recipe_params)

    respond_to do |format|
      if @recipe.save
        format.html { redirect_to recipes_path }
        format.json { render :show, status: :created, location: @recipe }
      else
        format.html { render :new }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /recipes/1
  # PATCH/PUT /recipes/1.json
  def update
    respond_to do |format|
      if @recipe.update(recipe_params)
        format.html { redirect_to @recipe, notice: 'Recipe was successfully updated.' }
        format.json { render :show, status: :ok, location: @recipe }
      else
        format.html { render :edit }
        format.json { render json: @recipe.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /recipes/1
  # DELETE /recipes/1.json
  def destroy
    @recipe.destroy
    respond_to do |format|
      format.html { redirect_to recipes_url, notice: 'Recipe was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_recipe
      @recipe = Recipe.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def recipe_params
      params.require(:recipe).permit(:product_id, :ingredient_id, :amount)
    end
end
