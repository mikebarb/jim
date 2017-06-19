class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    logger.debug "application controller"


    before_action :authorise

    protected
    
        def authorise
            
            
            # Check that the user has logged in
            @current_user = session[:user_name]
            if @current_user.nil? 
                redirect_to login_url, notice: "Please log in"
                return false
            end
            
            @current_shop = session[:user_shop]
            @current_day = session[:user_day]
            @current_shop_id = session[:user_shop_id]
            @current_user_id = session[:user_id]
            @current_role = session[:user_role]
            @current_controller = params[:controller]
            @current_action = params[:action]
            
            if @current_role == "root"
                logger.debug "logged in with root role"
                return true
            end

            if @current_role == "none"
                logger.debug "Checked current role is none - You do not have access to any functions"
                redirect_to login_url, notice: "You do not have access to any functions"
                logger.debug "Should have been redirected!!!"
                return false
            end
            
            logger.debug "application controller - authorise"
            logger.debug "session[:user_id] " + session[:user_id].inspect
            logger.debug "session[:role] " + session[:user_role].inspect
            logger.debug "@current_role " + @current_role.inspect
            logger.debug "controller: " + params[:controller]
            logger.debug "action: " + params[:action]

            @access =   {
                            "ingredients" =>    {
                                                    "index"     => ["baker", "owner", ],
                                                    "show"      => ["baker", "owner", ],
                                                    "new"       => ["baker", "owner", ],
                                                    "edit"      => ["baker", "owner", ],
                                                    "create"    => ["baker", "owner", ],
                                                    "update"    => ["baker", "owner", ],
                                                    "destroy"   => ["baker", "owner", ]
                                                },
                            "orders" =>         {
                                                    "index"     => ["owner", ],
                                                    "show"      => ["owner", ],
                                                    "new"       => ["owner", ],
                                                    "edit"      => ["owner", ],
                                                    "create"    => ["baker", "owner", ],
                                                    "update"    => ["baker", "owner", ],
                                                    "destroy"   => ["baker", "owner", ],
                                                    "productshop" => ["baker", "owner", ],
                                                    "baker"     => ["baker", "owner", ],
                                                    "bakerdoes" => ["baker", "owner", ],
                                                    "delivery"  => ["baker", "owner", ],
                                                    "deliverypdf" => ["baker", "owner", ],
                                                    "indexedit" => ["shop", "baker", "owner", ]
                                                },
                        }
        
            logger.debug "@access: " + @access.inspect
            @temp = @access.dig @current_controller, @current_action
            logger.debug "@temp: " + @temp.inspect
            if @temp.nil?
                redirect_to ordersedit_url, notice: "This function is not available"
            else
                logger.debug "@current_role: " + @current_role.inspect
                if @temp.include? @current_role
                    logger.debug "You have permission to access this function"
                    return true
                else
                    logger.debug "You do not have permission to access this function"
                    redirect_to ordersedit_url, notice: "You do not have permission to access this function"
                    return false
                end
            end
        end
end
