json.extract! orderlog, :id, :product, :shop, :day, :user, :created_at, :updated_at
json.url orderlog_url(orderlog, format: :json)
