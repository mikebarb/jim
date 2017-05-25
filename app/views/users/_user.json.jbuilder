json.extract! user, :id, :name, :email, :role, :day, :shop, :created_at, :updated_at
json.url user_url(user, format: :json)
