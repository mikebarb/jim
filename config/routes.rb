Rails.application.routes.draw do
  get 'reports/baker'

  get 'reports/deliver'

  get 'ordersedit', to: 'orders#indexedit'
  post 'orders/:id', to: 'orders#update'
  get 'ordersbakers/:day', to: 'orders#bakers'
  resources :orders
  #get 'sessions/new'
  #get 'sessions/create'
  #get 'sessions/destroy'

  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end
  
  resources :users
  resources :shops
  resources :products
  
  root 'product#index', as: 'product_index'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
