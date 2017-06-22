class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception

    before_action :authorise
    before_action :make_menus
    

    protected
    
        def authorise
            # This module controls access to all the controllers based on roles assigned to users
            # root: can access anything
            # not logged in or login with role none: can only get to login page
            # all other roles controlled by the hash table based on controller and action.
            
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
                                                    "index"     => ["owner", "baker"],
                                                    "show"      => ["owner", "baker"],
                                                    "new"       => ["owner", "baker"],
                                                    "edit"      => ["owner", "baker"],
                                                    "create"    => ["owner", "baker"],
                                                    "update"    => ["owner", "baker"],
                                                    "destroy"   => ["owner", "baker"]
                                                },
                            "lockdays" =>    {
                                                    "index"     => ["owner", "baker"],
                                                    "new"       => ["owner"],
                                                    "create"    => ["owner", "baker"],
                                                    "destroy"   => ["owner", "baker"],
                                                    "locktoday" => ["owner", "baker"]
                                                },
                            "orderlogs" =>    {
                                                    "index"     => ["owner"],
                                                    "create"    => ["owner", "baker", "shop"],
                                                    "indexdayshop" => ["owner", "baker", "shop"]
                                                },
                            "orders" =>         {
                                                    "index"     => ["owner"],
                                                    "show"      => ["owner"],
                                                    "new"       => ["owner"],
                                                    "edit"      => ["owner"],
                                                    "create"    => ["owner", "baker", "shop"],
                                                    "update"    => ["owner", "baker", "shop"],
                                                    "destroy"   => ["owner", "baker", "shop"],
                                                  "productshop" => ["owner", "baker"],
                                                    "bakers"     => ["owner", "baker"],
                                                    "bakerdoes" => ["owner", "baker"],
                                                    "delivery"  => ["owner", "baker"],
                                                  "deliverypdf" => ["owner", "baker"],
                                                    "indexedit" => ["owner", "baker", "shop"]
                                                },
                            "products" =>       {
                                                    "index"     => ["owner", "baker"],
                                                    "show"      => ["owner"],
                                                    "new"       => ["owner"],
                                                    "edit"      => ["owner"],
                                                    "create"    => ["owner"],
                                                    "update"    => ["owner"],
                                                    "display"   => ["owner", "baker", "shop"]
                                                },
                            "recipes" =>       {
                                                    "index"     => ["owner", "baker"],
                                                    "show"      => ["owner", "baker"],
                                                    "new"       => ["owner", "baker"],
                                                    "edit"      => ["owner", "baker"],
                                                    "create"    => ["owner", "baker"],
                                                    "update"    => ["owner", "baker"],
                                                    "destroy"   => ["owner", "baker"]
                                                },
                            "sectors" =>       {
                                                    "index"     => ["owner"],
                                                    "show"      => ["owner"],
                                                    "new"       => ["owner"],
                                                    "edit"      => ["owner"],
                                                    "create"    => ["owner"],
                                                    "update"    => ["owner"],
                                                    "destroy"   => ["owner"]
                                                },
                            "shops" =>       {
                                                    "index"     => ["owner"],
                                                    "show"      => ["owner"],
                                                    "new"       => ["owner"],
                                                    "edit"      => ["owner"],
                                                    "create"    => ["owner"],
                                                    "update"    => ["owner"]
                                                },
                            "users" =>       {
                                                    "index"     => ["owner"],
                                                    "show"      => ["owner"],
                                                    "new"       => ["owner"],
                                                    "edit"      => ["owner"],
                                                    "create"    => ["owner"],
                                                    "update"    => ["owner"],
                                                    "destroy"   => ["owner"],
                                                  "editdayshop" => ["owner", "baker", "shop"],
                                                "updatedayshop" => ["owner", "baker", "shop"]
                                                },
                            "usershops" =>       {
                                                    "index"     => ["owner"],
                                                    "show"      => ["owner"],
                                                    "new"       => ["owner"],
                                                    "edit"      => ["owner"],
                                                    "create"    => ["owner"],
                                                    "update"    => ["owner"],
                                                    "destroy"   => ["owner"]
                                                },
                        }
        
            @temp = @access.dig @current_controller, @current_action
            if @temp.nil?
                redirect_to ordersedit_url, notice: "This function is not available"
            else
                if @temp.include? @current_role
                    return true
                else
                    redirect_to ordersedit_url, notice: "You do not have permission to access this function"
                    return false
                end
            end
        end
        
        def get_shop_options
            # users with role of shop can ony see the shops they are linked to (usershops table)
            # all other logged in users can see all shops.
            if @current_role == "shop"
                #logger.debug "get_shop_options - in role shop"
                @shop_list = Shop.find_by_sql [ "
                    select DISTINCT ON (s.name) s.name, u.id as user_id, u.name as user_name, s.id as shop_id
                    FROM shops AS s
                    JOIN usershops AS x ON x.shop_id = s.id
                    JOIN users AS u ON u.id =x.user_id
                    WHERE user_id = ?
                ", session[:user_id] ]
            else
                #logger.debug "get_shop_options - get all shops"
                @shop_list = Shop.find_by_sql [ "
                    select DISTINCT ON (s.name) s.name, u.id as user_id, u.name as user_name, s.id as shop_id
                    FROM shops AS s
                    JOIN usershops AS x ON x.shop_id = s.id
                    JOIN users AS u ON u.id =x.user_id
                "]
            end
            @shop_options = @shop_list.map{ |u| [u.name]}
            #logger.debug "@shop_options: " + @shop_options.inspect
        end
        
        # set a flag to allow order updates to be done for certain roles
        # normally, updates are automatically prevented after the delivery day starts
        # or for some products, even earlier controlled by the product leadtime.
        # bakers and owners need to be able to bypass this allow them to do updates untill the day is manually locked.
        def check_allow_update_until_daylocked
            if ["baker", "owner"].include? @current_role
                return true
            else
                return false
            end
        end


        def make_menus
            if ["owner", "root"].include? @current_role
                # can do everything
                @menu =[
                        ["Shopping", 
                            [   ["Ordering",    "ordersedit"],
                                ["Products",    "displayproducts"],
                                ["Order Logs", "orderlogdayshop"],
                                ["Logout",   "logout"]
                            ]
                        ], 
                        ["Baking", 
                            [   ["Whiteboard",  "ordersproductshops"],
                                ["Products to Bake", "ordersbakers"],
                                ["Dough Listing", "ordersbakerdoes"],
                                ["Recipes", "recipes"],
                                ["Ingredients", "ingredients"],
                                ["Locked days", "lockdays"]
                            ]
                        ],
                        ["Delivery", 
                            [   ["Packaging Summary",  "ordersproductshops"],
                                ["Delivery Dockets", "ordersdelivery"]
                            ]
                        ],
                        ["Manage", 
                            [   ["Users",  "users"],
                                ["Shops", "shops"],
                                ["Users & Shops", "usershops"],
                                ["Products", "products"],
                                ["Product Categories", "sectors"],
                                ["All Orders", "orders"]
                            ]
                        ],
                        ["Admin", 
                            [   ["Locking days", "lockdays"],
                                ["Order Logs", "orderlogs"]
                            ]
                        ]
                       ]
            elsif ["baker"].include? @current_role                       
                @menu =[
                        ["Shopping", 
                            [   ["Ordering",    "ordersedit"],
                                ["Products",    "displayproducts"],
                                ["Order Logs", "orderlogdayshop"],
                                ["Logout",   "logout"]
                            ]
                        ], 
                        ["Baking", 
                            [   ["Whiteboard",  "ordersproductshops"],
                                ["Products to Bake", "ordersbakers"],
                                ["Dough Listing", "ordersbakerdoes"],
                                ["Recipes", "recipes"],
                                ["Ingredients", "ingredients"],
                                ["Locked days", "lockdays"]
                            ]
                        ],
                        ["Delivery", 
                            [   ["Packaging Summary",  "ordersproductshops"],
                                ["Delivery Dockets", "ordersdelivery"]
                            ]
                        ]
                     ]
            elsif ["shop"].include? @current_role                       
                @menu =[
                        ["Shopping", 
                            [   ["Ordering",    "ordersedit"],
                                ["Products",    "displayproducts"],
                                ["Order Logs", "orderlogdayshop"],
                                ["Logout",   "logout"]                            ]
                        ]
                     ]                   
            elsif ["none", nil].include? @current_role
                    # minimum capability - login only, will makes menu logic work
                    @menu =[
                        ["Shopping", 
                            [   ["Login",    "login"]
                            ]
                        ]
                     ]                       
            end
        end
end
