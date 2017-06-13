Rails.application.routes.draw do
  resources :usershops
  resources :sectors
  get 'orderlogdayshop', to: 'orderlogs#indexdayshop'
  resources :orderlogs
  resources :recipes
  resources :ingredients
  resources :lockdays
  get 'reports/baker'
  get 'reports/deliver'

  get 'ordersedit', to: 'orders#indexedit'
  post 'orders/:id', to: 'orders#update'
  get 'ordersproductshops', to: 'orders#productshop'
  get 'ordersbakers', to: 'orders#bakers'
  get 'ordersbakerdoes', to: 'orders#bakerdoes'
  get 'ordersdelivery', to: 'orders#delivery'
  get 'ordersdeliverypdf', to: 'orders#deliverypdf'
  #get 'ordersbakers/:day', to: 'orders#bakers'
  #get 'ordersdelivery/:day', to: 'orders#delivery'
  resources :orders
  #get 'sessions/new'
  #get 'sessions/create'
  #get 'sessions/destroy'

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    get 'logout' => :destroy
    delete 'logout' => :destroy
  end
  
  post 'userdayshop(/:id)', to: 'users#updatedayshop'
  patch 'userdayshop(/:id)', to: 'users#updatedayshop'
  get 'userdayshop', to: 'users#editdayshop'
  resources :users
  resources :shops
  get 'displayproducts', to: 'products#display'
  resources :products
  
  root 'orders#indexedit'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
