json.extract! recipe, :id, :product_id, :ingredient_id, :amount, :created_at, :updated_at
json.url recipe_url(recipe, format: :json)
