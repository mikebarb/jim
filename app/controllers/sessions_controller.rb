class SessionsController < ApplicationController
  skip_before_action :authorise
  def new
  end

  def create
    user = User.find_by(name: params[:name])
    if user.try(:authenticate, params[:password])
      session[:user_id] = user.id
      session[:user_name] = user.name
      session[:user_role] = user.role
      shop = Shop.find_by(name: user.shop)
      session[:user_shop] = user.shop
      session[:user_shop_id] = shop.id
      session[:user_day] = user.day
      redirect_to ordersedit_url
    else
      redirect_to login_url, alert: "Invalid user/password combination"
    end
  end

  def destroy
    session[:user_id] = nil
    session[:user_name] = nil
    session[:user_shop] = nil
    session[:user_shop_id] = nil
    session[:user_day] = nil
    session[:user_role] = nil
    redirect_to login_url, notice: "Logged out"
  end
end
